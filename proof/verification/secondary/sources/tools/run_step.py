"""Run one verification step with RAM gating and peak-memory accounting (Windows).

Usage:
  python run_step.py --journal J.jsonl --step NAME [--invocation ID] [--log OUT.txt] [--cwd DIR]
                     [--min-free-gb 6] [--min-free-commit-gb 4] [--env K=V ...] -- CMD ARGS...

* Before starting, waits (polling every 10 s, never killing anything) until free physical RAM and free
  commit are above the thresholds, and until no stop file exists (--stop-file).
* The child is created suspended, put in a fresh Windows Job Object, then resumed, so every descendant
  (e.g. lean.exe under lake.exe) is accounted.  After exit the job's PeakJobMemoryUsed (peak committed
  bytes of the whole tree), PeakProcessMemoryUsed (largest single process), CPU times and process count
  are recorded, together with a 0.5 s sampled peak working set of the tree (psutil) and the minimum free
  physical RAM seen.
* Only processes this runner created are ever touched.  No timeout, no termination: if the runner itself
  is interrupted the job handle closes without KILL_ON_JOB_CLOSE, i.e. the child is left alone.
* A JSON line is appended to --journal for EVERY outcome: a normal run (exit_code = the child's exact
  unsigned 32-bit exit code, so NTSTATUS values such as 0xC00000FD stay recognisable), a stop before start
  (stopped_before_start: true; runner exit 75) and a launch failure (launch_error: "..."; runner exit 127).
  --invocation ID is copied into the record so that callers classify exactly this run and never a stale record
  of an earlier attempt with the same step name.  Callers must classify from the journal, not from the runner's
  own exit status (which is the child's code if <= 255, else 1).
* A command whose first element ends in '.py' is run with this Python interpreter (used only by the unit tests'
  fake tools; real tools are .exe files and are started unchanged).
"""
import argparse
import ctypes
import hashlib
import json
import os
import subprocess
import sys
import threading
import time
from ctypes import wintypes
from resource_policy import effective_gates, MIN_PHYSICAL_GIB, MIN_COMMIT_GIB

try:
    import psutil
except ImportError:  # sampling of working sets is optional
    psutil = None

GB = 2 ** 30
k32 = ctypes.WinDLL('kernel32', use_last_error=True)
ntdll = ctypes.WinDLL('ntdll')


class MEMORYSTATUSEX(ctypes.Structure):
    _fields_ = [('dwLength', wintypes.DWORD), ('dwMemoryLoad', wintypes.DWORD),
                ('ullTotalPhys', ctypes.c_ulonglong), ('ullAvailPhys', ctypes.c_ulonglong),
                ('ullTotalPageFile', ctypes.c_ulonglong), ('ullAvailPageFile', ctypes.c_ulonglong),
                ('ullTotalVirtual', ctypes.c_ulonglong), ('ullAvailVirtual', ctypes.c_ulonglong),
                ('ullAvailExtendedVirtual', ctypes.c_ulonglong)]


def free_memory():
    s = MEMORYSTATUSEX()
    s.dwLength = ctypes.sizeof(s)
    if not k32.GlobalMemoryStatusEx(ctypes.byref(s)):
        raise OSError('GlobalMemoryStatusEx failed')
    return s.ullAvailPhys, s.ullAvailPageFile


class IO_COUNTERS(ctypes.Structure):
    _fields_ = [(n, ctypes.c_ulonglong) for n in (
        'ReadOperationCount', 'WriteOperationCount', 'OtherOperationCount',
        'ReadTransferCount', 'WriteTransferCount', 'OtherTransferCount')]


class JOBOBJECT_BASIC_LIMIT_INFORMATION(ctypes.Structure):
    _fields_ = [('PerProcessUserTimeLimit', ctypes.c_longlong), ('PerJobUserTimeLimit', ctypes.c_longlong),
                ('LimitFlags', wintypes.DWORD), ('MinimumWorkingSetSize', ctypes.c_size_t),
                ('MaximumWorkingSetSize', ctypes.c_size_t), ('ActiveProcessLimit', wintypes.DWORD),
                ('Affinity', ctypes.c_size_t), ('PriorityClass', wintypes.DWORD),
                ('SchedulingClass', wintypes.DWORD)]


class JOBOBJECT_EXTENDED_LIMIT_INFORMATION(ctypes.Structure):
    _fields_ = [('BasicLimitInformation', JOBOBJECT_BASIC_LIMIT_INFORMATION), ('IoInfo', IO_COUNTERS),
                ('ProcessMemoryLimit', ctypes.c_size_t), ('JobMemoryLimit', ctypes.c_size_t),
                ('PeakProcessMemoryUsed', ctypes.c_size_t), ('PeakJobMemoryUsed', ctypes.c_size_t)]


class JOBOBJECT_BASIC_ACCOUNTING_INFORMATION(ctypes.Structure):
    _fields_ = [('TotalUserTime', ctypes.c_longlong), ('TotalKernelTime', ctypes.c_longlong),
                ('ThisPeriodTotalUserTime', ctypes.c_longlong), ('ThisPeriodTotalKernelTime', ctypes.c_longlong),
                ('TotalPageFaultCount', wintypes.DWORD), ('TotalProcesses', wintypes.DWORD),
                ('ActiveProcesses', wintypes.DWORD), ('TotalTerminatedProcesses', wintypes.DWORD)]


k32.CreateJobObjectW.restype = wintypes.HANDLE
k32.CreateJobObjectW.argtypes = [ctypes.c_void_p, wintypes.LPCWSTR]
k32.AssignProcessToJobObject.argtypes = [wintypes.HANDLE, wintypes.HANDLE]
k32.QueryInformationJobObject.argtypes = [wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD,
                                          ctypes.c_void_p]
k32.CloseHandle.argtypes = [wintypes.HANDLE]
ntdll.NtResumeProcess.argtypes = [wintypes.HANDLE]


def tree_working_set(pid):
    if psutil is None:
        return 0
    try:
        p = psutil.Process(pid)
        procs = [p] + p.children(recursive=True)
    except psutil.Error:
        return 0
    total = 0
    for q in procs:
        try:
            total += q.memory_info().rss
        except psutil.Error:
            pass
    return total


def append_journal(path, rec):
    with open(path, 'a', encoding='utf-8') as j:
        j.write(json.dumps(rec) + '\n')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--journal', required=True)
    ap.add_argument('--step', required=True)
    ap.add_argument('--invocation', default=None, help='unique id copied into the journal record')
    ap.add_argument('--log', help='file receiving the child stdout+stderr (default: inherit)')
    ap.add_argument('--cwd')
    ap.add_argument('--min-free-gb', type=float, default=MIN_PHYSICAL_GIB)
    ap.add_argument('--min-free-commit-gb', type=float, default=MIN_COMMIT_GIB)
    ap.add_argument('--stop-file')
    ap.add_argument('--env', action='append', default=[], help='K=V added to the child environment')
    ap.add_argument('cmd', nargs=argparse.REMAINDER)
    a = ap.parse_args()
    cmd = a.cmd[1:] if a.cmd and a.cmd[0] == '--' else a.cmd
    if not cmd:
        ap.error('missing command')
    try:
        a.min_free_gb, a.min_free_commit_gb = effective_gates(a.min_free_gb, a.min_free_commit_gb)
    except ValueError as error:
        ap.error(str(error))

    # RAM gate (never acts on other processes; just waits).
    last = 0.0
    t_gate = time.time()
    while True:
        if a.stop_file and os.path.exists(a.stop_file):
            print(f'[run_step] stop file {a.stop_file} present; not starting {a.step}', flush=True)
            append_journal(a.journal, {'step': a.step, 'invocation': a.invocation, 'command': cmd, 'exit_code': None,
                                       'stopped_before_start': True,
                                       'effective_min_physical_gib': a.min_free_gb,
                                       'effective_min_commit_gib': a.min_free_commit_gb,
                                       'finished': time.strftime('%Y-%m-%dT%H:%M:%S')})
            return 75
        phys, commit = free_memory()
        if phys >= a.min_free_gb * GB and commit >= a.min_free_commit_gb * GB:
            break
        if time.time() - last > 60:
            print(f'[run_step] {a.step}: waiting for memory (free {phys / GB:.1f} GB phys, '
                  f'{commit / GB:.1f} GB commit; need {a.min_free_gb} / {a.min_free_commit_gb})', flush=True)
            last = time.time()
        time.sleep(10)
    waited = time.time() - t_gate

    env = os.environ.copy()
    for kv in a.env:
        k, _, v = kv.partition('=')
        env[k] = v
    if cmd[0].lower().endswith('.py'):
        cmd = [sys.executable] + cmd
    out = open(a.log, 'wb') if a.log else None
    job = k32.CreateJobObjectW(None, None)
    if not job:
        raise OSError(ctypes.get_last_error(), 'CreateJobObjectW failed')
    CREATE_SUSPENDED = 0x4
    t0 = time.time()
    try:
        proc = subprocess.Popen(cmd, cwd=a.cwd, env=env, stdout=out or None,
                                stderr=subprocess.STDOUT if out else None, creationflags=CREATE_SUSPENDED)
    except OSError as e:
        if out:
            out.write(f'[run_step] could not start {cmd[0]}: {e}\n'.encode())
            out.close()
        k32.CloseHandle(job)
        append_journal(a.journal, {'step': a.step, 'invocation': a.invocation, 'command': cmd, 'exit_code': None,
                                   'launch_error': f'{type(e).__name__}: {e}',
                                   'effective_min_physical_gib': a.min_free_gb,
                                   'effective_min_commit_gib': a.min_free_commit_gb,
                                   'finished': time.strftime('%Y-%m-%dT%H:%M:%S')})
        print(f'[run_step] {a.step}: could not start {cmd[0]}: {e}', flush=True)
        return 127
    assigned = bool(k32.AssignProcessToJobObject(job, wintypes.HANDLE(int(proc._handle))))
    ntdll.NtResumeProcess(wintypes.HANDLE(int(proc._handle)))

    peak_ws = 0
    min_free = free_memory()[0]
    done = threading.Event()

    def sampler():
        nonlocal peak_ws, min_free
        while not done.is_set():
            peak_ws = max(peak_ws, tree_working_set(proc.pid))
            min_free = min(min_free, free_memory()[0])
            done.wait(0.5)

    th = threading.Thread(target=sampler, daemon=True)
    th.start()
    rc = proc.wait() & 0xFFFFFFFF          # Windows exit codes are unsigned 32-bit
    wall = time.time() - t0
    done.set()
    th.join()
    if out:
        out.close()

    ext = JOBOBJECT_EXTENDED_LIMIT_INFORMATION()
    acc = JOBOBJECT_BASIC_ACCOUNTING_INFORMATION()
    k32.QueryInformationJobObject(job, 9, ctypes.byref(ext), ctypes.sizeof(ext), None)   # extended limits
    k32.QueryInformationJobObject(job, 1, ctypes.byref(acc), ctypes.sizeof(acc), None)   # basic accounting
    k32.CloseHandle(job)
    rec = {
        'step': a.step, 'invocation': a.invocation, 'command': cmd, 'cwd': a.cwd, 'exit_code': rc,
        'env_LEAN_NUM_THREADS': env.get('LEAN_NUM_THREADS'),
        'effective_min_physical_gib': a.min_free_gb,
        'effective_min_commit_gib': a.min_free_commit_gb,
        'wall_seconds': round(wall, 2), 'waited_for_memory_seconds': round(waited, 1),
        'cpu_seconds': round((acc.TotalUserTime + acc.TotalKernelTime) / 1e7, 2),
        'processes_in_job': acc.TotalProcesses, 'job_assigned': assigned,
        'peak_job_commit_gb': round(ext.PeakJobMemoryUsed / GB, 3),
        'peak_process_commit_gb': round(ext.PeakProcessMemoryUsed / GB, 3),
        'peak_tree_working_set_gb_sampled': round(peak_ws / GB, 3),
        'min_free_physical_gb_sampled': round(min_free / GB, 3),
        'finished': time.strftime('%Y-%m-%dT%H:%M:%S'),
    }
    if a.log and os.path.exists(a.log):
        rec['log'] = a.log
        with open(a.log, 'rb') as f:
            rec['log_sha256'] = hashlib.sha256(f.read()).hexdigest()
    append_journal(a.journal, rec)
    print('[run_step] ' + json.dumps({k: rec[k] for k in (
        'step', 'exit_code', 'wall_seconds', 'cpu_seconds', 'peak_job_commit_gb',
        'peak_tree_working_set_gb_sampled')}), flush=True)
    return rc if rc <= 255 else 1


if __name__ == '__main__':
    sys.exit(main())
