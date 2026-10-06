"""redirect.py [--max-process-mb N | --max-process-bytes N] OUT ERR CMD [ARGS...]

Runs CMD with stdout -> OUT and stderr -> ERR (separately, so an export file is never polluted by
diagnostics) and exits with CMD's exit code.  Used under run_step.py, whose Windows Job Object then
accounts for CMD's time and peak memory.  Never kills or signals anything (sole exception: its own child,
created suspended, when the --max-process-mb limit cannot be applied; that child has not run yet).

* If CMD cannot be started (missing executable, bad format, ...), a line starting with LAUNCH_MARKER is written
  to ERR and the exit code is 127; sk_tool.py classifies that as ERROR (never as a rejection).
* --max-process-mb N puts CMD (only CMD, not this wrapper) in a nested Job Object with
  JOB_OBJECT_LIMIT_PROCESS_MEMORY = N MiB.  Allocations beyond the limit then fail inside CMD, which is how the
  build self-test forces a genuine resource failure; nothing is ever terminated.  If the limit cannot be applied
  the run is refused (exit 127 with LAUNCH_MARKER), so the control can never silently run unlimited.
* --max-process-bytes uses an exact positive integer byte limit. Limited runs write an exclusive
  ERR.limit.json receipt with limit readback, resume status, raw child exit, and child-only Job peaks.
* A CMD ending in '.py' is run with this Python interpreter (only the unit tests' fake tools).
* Windows NTSTATUS codes (e.g. 0xC00000FD stack overflow) are passed on unchanged as the process exit code.
"""
import ctypes
import json
import subprocess
import sys
from ctypes import wintypes

LAUNCH_MARKER = 'redirect.py: cannot start'


class BASIC(ctypes.Structure):
    _fields_ = [('PerProcessUserTimeLimit', ctypes.c_longlong), ('PerJobUserTimeLimit', ctypes.c_longlong),
                ('LimitFlags', wintypes.DWORD), ('MinimumWorkingSetSize', ctypes.c_size_t),
                ('MaximumWorkingSetSize', ctypes.c_size_t), ('ActiveProcessLimit', wintypes.DWORD),
                ('Affinity', ctypes.c_size_t), ('PriorityClass', wintypes.DWORD),
                ('SchedulingClass', wintypes.DWORD)]


class IOC(ctypes.Structure):
    _fields_ = [(n, ctypes.c_ulonglong) for n in ('a', 'b', 'c', 'd', 'e', 'f')]


class EXT(ctypes.Structure):
    _fields_ = [('BasicLimitInformation', BASIC), ('IoInfo', IOC), ('ProcessMemoryLimit', ctypes.c_size_t),
                ('JobMemoryLimit', ctypes.c_size_t), ('PeakProcessMemoryUsed', ctypes.c_size_t),
                ('PeakJobMemoryUsed', ctypes.c_size_t)]


def positive_limit(text, multiplier=1):
    if not isinstance(text, str) or not text or any(c not in '0123456789' for c in text):
        raise ValueError('memory limit must be a positive integer')
    limit = int(text) * multiplier
    if not 0 < limit <= (1 << (8 * ctypes.sizeof(ctypes.c_size_t))) - 1:
        raise ValueError('memory limit is zero or outside SIZE_T')
    return limit


def parse_args(argv):
    limit = None
    while argv and argv[0].startswith('--max-process-'):
        if limit is not None or len(argv) < 2 or argv[0] not in ('--max-process-mb', '--max-process-bytes'):
            raise ValueError('memory limit options are mutually exclusive and require a value')
        limit = positive_limit(argv[1], 1024 * 1024 if argv[0] == '--max-process-mb' else 1)
        argv = argv[2:]
    if len(argv) < 3:
        raise ValueError('usage: redirect.py [--max-process-mb N | --max-process-bytes N] OUT ERR CMD [ARGS...]')
    return limit, argv


def _limit_job_bytes(limit):
    k32 = ctypes.WinDLL('kernel32', use_last_error=True)
    if type(limit) is not int or positive_limit(str(limit)) != limit:
        raise ValueError('invalid byte limit')
    k32.CreateJobObjectW.restype = wintypes.HANDLE
    k32.CreateJobObjectW.argtypes = [ctypes.c_void_p, wintypes.LPCWSTR]
    k32.SetInformationJobObject.argtypes = [wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD]
    k32.AssignProcessToJobObject.argtypes = [wintypes.HANDLE, wintypes.HANDLE]
    k32.CloseHandle.argtypes = [wintypes.HANDLE]
    job = k32.CreateJobObjectW(None, None)
    if not job:
        raise OSError(ctypes.get_last_error(), 'CreateJobObjectW failed')
    info = EXT()
    info.BasicLimitInformation.LimitFlags = 0x100          # JOB_OBJECT_LIMIT_PROCESS_MEMORY
    info.ProcessMemoryLimit = limit
    if not k32.SetInformationJobObject(job, 9, ctypes.byref(info), ctypes.sizeof(info)):
        error = ctypes.get_last_error()
        k32.CloseHandle(job)
        raise OSError(error, 'SetInformationJobObject failed')
    return k32, job


def _limit_job(mb):
    return _limit_job_bytes(positive_limit(str(mb), 1024 * 1024))


def _read_limit(k32, job, expected):
    k32.QueryInformationJobObject.argtypes = [wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p,
                                             wintypes.DWORD, ctypes.c_void_p]
    info = EXT()
    if not k32.QueryInformationJobObject(job, 9, ctypes.byref(info), ctypes.sizeof(info), None):
        raise OSError(ctypes.get_last_error(), 'QueryInformationJobObject failed')
    if info.BasicLimitInformation.LimitFlags != 0x100 or info.ProcessMemoryLimit != expected:
        raise OSError('memory limit readback differs from requested limit')
    return {'flags': info.BasicLimitInformation.LimitFlags, 'process_limit_bytes': info.ProcessMemoryLimit,
            'peak_process_bytes': info.PeakProcessMemoryUsed, 'peak_job_bytes': info.PeakJobMemoryUsed}


def _assign(k32, job, p):
    if not k32.AssignProcessToJobObject(job, wintypes.HANDLE(int(p._handle))):
        raise OSError(ctypes.get_last_error(), 'AssignProcessToJobObject failed; limit not applied, run refused')


def _resume(p):
    ntdll = ctypes.WinDLL('ntdll')
    ntdll.NtResumeProcess.argtypes = [wintypes.HANDLE]
    ntdll.NtResumeProcess.restype = ctypes.c_long
    status = ntdll.NtResumeProcess(wintypes.HANDLE(int(p._handle)))
    if status < 0:
        raise OSError(f'NtResumeProcess failed: 0x{status & 0xFFFFFFFF:08X}')
    return status


def _limited_call(limit, cmd, o, e, receipt_path):
    # The receipt is reserved before creating any process; stale output refuses the run.
    with open(receipt_path, 'x', encoding='utf-8') as receipt_file:
        receipt = {'schema': 1, 'requested_bytes': limit, 'argv': cmd,
                   'assigned_before_resume': False, 'resumed': False, 'child_pid': None,
                   'child_exit_code': None, 'complete': False}
        k32 = job = p = None
        try:
            k32, job = _limit_job_bytes(limit)
            receipt['before_assignment'] = _read_limit(k32, job, limit)
            p = subprocess.Popen(cmd, stdout=o, stderr=e, stdin=subprocess.DEVNULL, creationflags=0x4)
            receipt['child_pid'] = p.pid
            _assign(k32, job, p)
            receipt['assigned_before_resume'] = True
            receipt['before_resume'] = _read_limit(k32, job, limit)
            receipt['resume_status'] = _resume(p)
            receipt['resumed'] = True
            receipt['child_exit_code'] = p.wait()
            receipt['after_exit'] = _read_limit(k32, job, limit)
            receipt['complete'] = True
            return receipt['child_exit_code']
        except Exception as ex:
            receipt['error'] = f'{type(ex).__name__}: {ex}'
            raise
        finally:
            if p is not None and p.poll() is None:
                # Only our own child, created above. In normal operation it was never resumed.
                p.kill()
                p.wait()
                receipt['own_child_cleanup'] = True
            if job is not None:
                k32.CloseHandle(job)
            json.dump(receipt, receipt_file, indent=2)


def validate_receipt(receipt, limit, cmd, exit_code):
    """Operational evidence only; this function never classifies a proof or error."""
    if type(limit) is not int or limit <= 0 or type(receipt.get('schema')) is not int or \
            receipt['schema'] != 1 or type(receipt.get('requested_bytes')) is not int or \
            receipt['requested_bytes'] != limit or receipt.get('argv') != cmd:
        raise ValueError('limit receipt invocation mismatch')
    if any(receipt.get(key) is not True for key in ('complete', 'assigned_before_resume', 'resumed')):
        raise ValueError('limit receipt incomplete')
    if type(receipt.get('child_pid')) is not int or receipt['child_pid'] <= 0 or receipt.get('error'):
        raise ValueError('limit receipt child/error mismatch')
    if type(receipt.get('resume_status')) is not int or receipt['resume_status'] != 0 or receipt.get('own_child_cleanup'):
        raise ValueError('child did not resume and exit normally under the limit')
    if type(receipt.get('child_exit_code')) is not int or type(exit_code) is not int or \
            (receipt['child_exit_code'] & 0xFFFFFFFF) != (exit_code & 0xFFFFFFFF):
        raise ValueError('child exit does not match the runner record')
    for phase in ('before_assignment', 'before_resume', 'after_exit'):
        data = receipt.get(phase, {})
        if type(data.get('flags')) is not int or data['flags'] != 0x100 or \
                type(data.get('process_limit_bytes')) is not int or data['process_limit_bytes'] != limit or \
                any(type(data.get(k)) is not int or data[k] < 0 for k in ('peak_process_bytes', 'peak_job_bytes')):
            raise ValueError('limit receipt readback invalid')


def main(argv):
    try:
        limit, argv = parse_args(argv)
    except ValueError as ex:
        print(f'{LAUNCH_MARKER}: {ex}', file=sys.stderr)
        return 127
    out, err, cmd = argv[0], argv[1], argv[2:]
    if cmd[0].lower().endswith('.py'):
        cmd = [sys.executable] + cmd
    with open(out, 'wb') as o, open(err, 'wb') as e:
        try:
            if limit is None:
                rc = subprocess.call(cmd, stdout=o, stderr=e, stdin=subprocess.DEVNULL)
            else:
                rc = _limited_call(limit, cmd, o, e, err + '.limit.json')
        except OSError as ex:
            e.write(f'{LAUNCH_MARKER} {cmd[0]}: {type(ex).__name__}: {ex}\n'.encode())
            return 127
    rc &= 0xFFFFFFFF
    # Windows NTSTATUS codes come back unsigned; pass them on unchanged (signed for sys.exit's C long).
    if rc > 0x7FFFFFFF:
        rc -= 1 << 32
    return rc


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
