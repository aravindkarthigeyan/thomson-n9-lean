"""Bound one ordinary command in an owned Windows Job Object.

This is process supervision, not proof verification or a Lake build planner.
No process starts unless assignment to the job succeeds while it is suspended.

Derived from ../n8_ordinary/windows_job_guard.py, frozen SHA256
f5bac1a2c7f2d3d85c6a28894737c18cc9eb4b23ea221f535518550f29d870b8.
N8 changes: streaming file hashes and an absolute authorization deadline,
checked again while the assigned root is still suspended and during monitoring.
"""
import ctypes as C
from ctypes import wintypes as W
from datetime import datetime, timezone
import hashlib
import json
import math
import msvcrt
import os
from pathlib import Path
import subprocess
import sys
import time


K = C.WinDLL('kernel32', use_last_error=True)
P = C.WinDLL('psapi', use_last_error=True)
SIZE = C.c_size_t
U64 = C.c_ulonglong
HANDLE = W.HANDLE


class BasicLimit(C.Structure):
    _fields_ = [('ProcessTime', C.c_longlong), ('JobTime', C.c_longlong),
                ('Flags', W.DWORD), ('MinWorking', SIZE), ('MaxWorking', SIZE),
                ('ActiveLimit', W.DWORD), ('Affinity', SIZE),
                ('Priority', W.DWORD), ('Scheduling', W.DWORD)]


class IOCounters(C.Structure):
    _fields_ = [(name, U64) for name in
                ['ReadOps', 'WriteOps', 'OtherOps', 'ReadBytes', 'WriteBytes', 'OtherBytes']]


class ExtendedLimit(C.Structure):
    _fields_ = [('Basic', BasicLimit), ('IO', IOCounters), ('ProcessMemoryLimit', SIZE),
                ('JobMemoryLimit', SIZE), ('PeakProcessMemory', SIZE), ('PeakJobMemory', SIZE)]


class Startup(C.Structure):
    _fields_ = [('cb', W.DWORD), ('reserved', W.LPWSTR), ('desktop', W.LPWSTR),
                ('title', W.LPWSTR), ('x', W.DWORD), ('y', W.DWORD),
                ('xSize', W.DWORD), ('ySize', W.DWORD), ('xChars', W.DWORD),
                ('yChars', W.DWORD), ('fill', W.DWORD), ('flags', W.DWORD),
                ('show', W.WORD), ('reservedSize', W.WORD), ('reservedData', C.c_void_p),
                ('stdin', HANDLE), ('stdout', HANDLE), ('stderr', HANDLE)]


class StartupEx(C.Structure):
    _fields_ = [('startup', Startup), ('attributes', C.c_void_p)]


class ProcessInfo(C.Structure):
    _fields_ = [('process', HANDLE), ('thread', HANDLE), ('pid', W.DWORD), ('tid', W.DWORD)]


class MemoryStatus(C.Structure):
    _fields_ = [('length', W.DWORD), ('load', W.DWORD)] + [(name, U64) for name in
                ['totalPhysical', 'freePhysical', 'totalCommit', 'freeCommit',
                 'totalVirtual', 'freeVirtual', 'extendedVirtual']]


class ProcessMemory(C.Structure):
    _fields_ = [('cb', W.DWORD), ('faults', W.DWORD)] + [(name, SIZE) for name in
                ['peakWorking', 'working', 'peakPaged', 'paged', 'peakNonPaged',
                 'nonPaged', 'pagefile', 'peakPagefile', 'private']]


def api(dll, name, args, result):
    function = getattr(dll, name)
    function.argtypes = args
    function.restype = result
    return function


create_job = api(K, 'CreateJobObjectW', [C.c_void_p, W.LPCWSTR], HANDLE)
set_job = api(K, 'SetInformationJobObject', [HANDLE, C.c_int, C.c_void_p, W.DWORD], W.BOOL)
query_job = api(K, 'QueryInformationJobObject', [HANDLE, C.c_int, C.c_void_p, W.DWORD, C.c_void_p], W.BOOL)
assign_job = api(K, 'AssignProcessToJobObject', [HANDLE, HANDLE], W.BOOL)
is_in_job = api(K, 'IsProcessInJob', [HANDLE, HANDLE, C.POINTER(W.BOOL)], W.BOOL)
terminate_job = api(K, 'TerminateJobObject', [HANDLE, W.UINT], W.BOOL)
close_handle = api(K, 'CloseHandle', [HANDLE], W.BOOL)
terminate_process = api(K, 'TerminateProcess', [HANDLE, W.UINT], W.BOOL)
resume_thread = api(K, 'ResumeThread', [HANDLE], W.DWORD)
exit_code = api(K, 'GetExitCodeProcess', [HANDLE, C.POINTER(W.DWORD)], W.BOOL)
wait_handle = api(K, 'WaitForSingleObject', [HANDLE, W.DWORD], W.DWORD)
open_process = api(K, 'OpenProcess', [W.DWORD, W.BOOL, W.DWORD], HANDLE)
get_memory = api(P, 'GetProcessMemoryInfo', [HANDLE, C.c_void_p, W.DWORD], W.BOOL)
global_memory = api(K, 'GlobalMemoryStatusEx', [C.POINTER(MemoryStatus)], W.BOOL)
initialize_attributes = api(K, 'InitializeProcThreadAttributeList', [C.c_void_p, W.DWORD, W.DWORD, C.POINTER(SIZE)], W.BOOL)
update_attribute = api(K, 'UpdateProcThreadAttribute',
    [C.c_void_p, W.DWORD, SIZE, C.c_void_p, SIZE, C.c_void_p, C.c_void_p], W.BOOL)
delete_attributes = api(K, 'DeleteProcThreadAttributeList', [C.c_void_p], None)
create_process = api(K, 'CreateProcessW',
    [W.LPCWSTR, W.LPWSTR, C.c_void_p, C.c_void_p, W.BOOL, W.DWORD,
     C.c_void_p, W.LPCWSTR, C.c_void_p, C.POINTER(ProcessInfo)], W.BOOL)


def checked(ok, operation):
    if not ok:
        raise OSError(C.get_last_error(), operation)


def file_binding(path):
    path = Path(path).resolve(strict=True)
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            digest.update(block)
    return {'path': str(path), 'sha256': digest.hexdigest()}


def host_memory():
    value = MemoryStatus()
    value.length = C.sizeof(value)
    checked(global_memory(C.byref(value)), 'GlobalMemoryStatusEx')
    return {'free_commit': int(value.freeCommit), 'free_physical': int(value.freePhysical)}


class OwnedJob:
    def __init__(self, private_cap):
        if not isinstance(private_cap, int) or not 0 < private_cap < 1 << (8*C.sizeof(SIZE)):
            raise ValueError('private cap must be a positive SIZE_T byte count')
        self.job = create_job(None, None)
        checked(self.job, 'CreateJobObjectW')
        self.info = ProcessInfo()
        self.resumed = False
        self.assigned = False
        limits = ExtendedLimit()
        limits.Basic.Flags = 0x2000 | 0x200  # KILL_ON_JOB_CLOSE and JOB_MEMORY; no breakaway.
        limits.JobMemoryLimit = private_cap
        try:
            checked(set_job(self.job, 9, C.byref(limits), C.sizeof(limits)), 'SetInformationJobObject')
            actual = self.configuration()
            if actual['flags'] != limits.Basic.Flags or actual['private_cap'] != private_cap:
                raise RuntimeError('job limits were not installed exactly')
        except BaseException:
            close_handle(self.job)
            self.job = None
            raise

    def configuration(self):
        limits = ExtendedLimit()
        checked(query_job(self.job, 9, C.byref(limits), C.sizeof(limits), None),
                'QueryInformationJobObject configured limits')
        return {'flags': int(limits.Basic.Flags), 'private_cap': int(limits.JobMemoryLimit)}

    def start(self, argv, cwd, environment, stdin, stdout, stderr, *, test_assignment_failure=False,
              deadline_epoch=None):
        handles = (HANDLE * 3)(*[msvcrt.get_osfhandle(f.fileno()) for f in [stdin, stdout, stderr]])
        attr_size = SIZE()
        initialize_attributes(None, 1, 0, C.byref(attr_size))
        if not attr_size.value:
            raise OSError(C.get_last_error(), 'InitializeProcThreadAttributeList size')
        attr_buffer = C.create_string_buffer(attr_size.value)
        checked(initialize_attributes(attr_buffer, 1, 0, C.byref(attr_size)), 'InitializeProcThreadAttributeList')
        try:
            for handle in handles:
                os.set_handle_inheritable(handle, True)
            checked(update_attribute(attr_buffer, 0, 0x20002, handles, C.sizeof(handles), None, None),
                    'UpdateProcThreadAttribute HANDLE_LIST')
            startup = StartupEx()
            startup.startup.cb = C.sizeof(startup)
            startup.startup.flags = 0x100
            startup.startup.stdin, startup.startup.stdout, startup.startup.stderr = handles
            startup.attributes = C.cast(attr_buffer, C.c_void_p)
            command = C.create_unicode_buffer(subprocess.list2cmdline(argv))
            env = C.create_unicode_buffer('\0'.join(f'{k}={v}' for k, v in
                sorted(environment.items(), key=lambda pair: pair[0].upper())) + '\0\0')
            flags = 0x4 | 0x08000000 | 0x00080000 | 0x400
            checked(create_process(argv[0], command, None, None, True, flags, env,
                str(cwd), C.byref(startup), C.byref(self.info)), 'CreateProcessW suspended')
            if test_assignment_failure:
                raise OSError('test-only assignment failure before resume')
            checked(assign_job(self.job, self.info.process), 'AssignProcessToJobObject')
            self.assigned = True
            if deadline_epoch is not None and time.time() >= deadline_epoch:
                raise TimeoutError('absolute authorization deadline expired before resume')
            if resume_thread(self.info.thread) == 0xFFFFFFFF:
                raise OSError(C.get_last_error(), 'ResumeThread')
            self.resumed = True
        except BaseException:
            if self.info.process and not self.resumed:
                # This handle is only the suspended process we just created.
                checked(terminate_process(self.info.process, 97), 'TerminateProcess own suspended root')
                if wait_handle(self.info.process, 5000) != 0:
                    raise RuntimeError('suspended-root cleanup did not complete')
            raise
        finally:
            for handle in handles:
                os.set_handle_inheritable(handle, False)
            delete_attributes(attr_buffer)
            if self.info.thread:
                close_handle(self.info.thread)
                self.info.thread = None

    def pids(self):
        capacity = 32
        while capacity <= 65536:
            buffer = C.create_string_buffer(8 + capacity*C.sizeof(SIZE))
            if query_job(self.job, 3, buffer, len(buffer), None):
                count = W.DWORD.from_buffer(buffer, 4).value
                return [int(SIZE.from_buffer(buffer, 8+i*C.sizeof(SIZE)).value) for i in range(count)]
            if C.get_last_error() != 234:
                raise OSError(C.get_last_error(), 'QueryInformationJobObject process list')
            capacity *= 2
        raise RuntimeError('owned process-list capacity exceeded')

    def sample(self):
        pids = self.pids()
        total = 0
        working_total = 0
        max_private = 0
        max_working = 0
        for pid in pids:
            handle = open_process(0x400 | 0x10, False, pid)
            if not handle:
                if pid in self.pids():
                    raise OSError(C.get_last_error(), 'OpenProcess persistent owned child')
                continue
            try:
                owned = W.BOOL()
                checked(is_in_job(handle, self.job, C.byref(owned)), 'IsProcessInJob sampled child')
                if not owned.value:
                    if pid in self.pids():
                        raise RuntimeError('sampled PID no longer identifies the owned child')
                    continue
                counters = ProcessMemory()
                counters.cb = C.sizeof(counters)
                if not get_memory(handle, C.byref(counters), counters.cb):
                    if pid in self.pids():
                        raise OSError(C.get_last_error(), 'GetProcessMemoryInfo persistent owned child')
                    continue
                total += int(counters.private)
                working_total += int(counters.working)
                max_private = max(max_private, int(counters.private))
                max_working = max(max_working, int(counters.working))
            finally:
                close_handle(handle)
        limits = ExtendedLimit()
        checked(query_job(self.job, 9, C.byref(limits), C.sizeof(limits), None), 'QueryInformationJobObject memory')
        return {'pids': pids, 'private_tree': total, 'working_tree': working_total,
                'max_process_private': max_private, 'max_process_working': max_working,
                'peak_job_commit': int(limits.PeakJobMemory),
                'peak_process_commit': int(limits.PeakProcessMemory)}

    def return_code(self):
        state = wait_handle(self.info.process, 0)
        if state == 258:
            return None
        if state != 0:
            raise OSError(C.get_last_error(), 'WaitForSingleObject root exit')
        result = W.DWORD()
        checked(exit_code(self.info.process, C.byref(result)), 'GetExitCodeProcess')
        return int(result.value)

    def terminate_and_wait(self):
        checked(terminate_job(self.job, 98), 'TerminateJobObject owned tree')
        if self.info.process and not self.assigned and self.return_code() is None:
            checked(terminate_process(self.info.process, 98), 'TerminateProcess own unassigned root')
        deadline = time.monotonic() + 5
        while (self.pids() or (self.info.process and self.return_code() is None)) and time.monotonic() < deadline:
            time.sleep(0.02)
        return not self.pids() and (not self.info.process or self.return_code() is not None)

    def close(self):
        if self.job:
            close_handle(self.job)
            self.job = None
        if self.info.process:
            close_handle(self.info.process)
            self.info.process = None


def supervise(argv, *, cwd, report_dir, limits, sources, configs=(), stop_file=None,
              poll_seconds=0.1, environment=None, test_assignment_failure=False,
              test_resource_floor_after=None, deadline_epoch=None):
    """Run one process tree; every unsuccessful outcome is explicitly inconclusive.

    Test hooks only force failure and are permanently recorded in the manifest.
    They cannot create a successful result or bypass Job Object ownership.
    """
    if not 0.02 <= poll_seconds <= 2:
        raise ValueError('poll interval must be between .02 and 2 seconds')
    for field in ['launch_commit', 'launch_physical', 'reserve_commit', 'private_tree_cap']:
        value = getattr(limits, field)
        if isinstance(value, bool) or not isinstance(value, int) or value < 0:
            raise ValueError(f'{field} must be a nonnegative integer byte count')
    if limits.private_tree_cap <= 0 or not math.isfinite(limits.wall_seconds) or limits.wall_seconds <= 0:
        raise ValueError('private cap and finite wall limit must be positive')
    if limits.launch_commit < limits.reserve_commit:
        raise ValueError('launch commit gate must be at least the reserve')
    if not argv or any('\0' in str(item) for item in argv):
        raise ValueError('nonempty argv without NUL characters is required')
    if test_resource_floor_after is not None and (not math.isfinite(test_resource_floor_after) or test_resource_floor_after < 0):
        raise ValueError('test floor time must be nonnegative')
    if deadline_epoch is not None and (isinstance(deadline_epoch, bool)
            or not isinstance(deadline_epoch, (int, float)) or not math.isfinite(deadline_epoch)):
        raise ValueError('absolute authorization deadline must be a finite Unix timestamp')
    argv = [str(item) for item in argv]
    argv[0] = str(Path(argv[0]).resolve(strict=True))
    cwd = Path(cwd).resolve(strict=True)
    report_dir = Path(report_dir).resolve()
    report_dir.mkdir(parents=False, exist_ok=False)
    bindings = {'tool': file_binding(argv[0]), 'sources': [file_binding(p) for p in sources],
                'configs': [file_binding(p) for p in configs]}
    if not bindings['sources']:
        raise ValueError('at least one exact source binding is required')
    environment = dict(os.environ if environment is None else environment)
    if any(not k or '=' in k or '\0' in k or '\0' in v for k, v in environment.items()):
        raise ValueError('invalid environment key/value')
    manifest = {'schema': 'owned-windows-command-v1',
        'supervisor': file_binding(__file__), 'supervisor_interpreter': file_binding(sys.executable),
        'argv': argv, 'windows_command_line': subprocess.list2cmdline(argv),
        'cwd': str(cwd), 'bindings': bindings, 'limits': limits.__dict__,
        'environment_sha256': hashlib.sha256(json.dumps(environment, sort_keys=True).encode()).hexdigest(),
        'poll_seconds': poll_seconds, 'stop_file': str(Path(stop_file).resolve()) if stop_file else None,
        'test_assignment_failure': test_assignment_failure,
        'test_resource_floor_after': test_resource_floor_after,
        'deadline_epoch': deadline_epoch,
        'started_utc': datetime.now(timezone.utc).isoformat()}
    with (report_dir/'manifest.json').open('x', encoding='utf-8') as stream:
        json.dump(manifest, stream, indent=2)
    initial_manifest = file_binding(report_dir/'manifest.json')
    result = {'outcome': 'INCONCLUSIVE_INTERNAL_ERROR', 'mathematical_classification': 'NONE',
              'resumed': False, 'root_pid': None, 'observed_owned_pids': [], 'cleanup_complete': True}
    job = None
    started = time.monotonic()
    observed = set()
    root_exit_seen = None
    stopped = lambda: stop_file is not None and Path(stop_file).exists()
    try:
        memory = host_memory()
        result['prelaunch_memory'] = memory
        if deadline_epoch is not None and time.time() >= deadline_epoch:
            result['outcome'] = 'INCONCLUSIVE_AUTHORIZATION_EXPIRED_PRELAUNCH'
        elif stopped():
            result['outcome'] = 'INCONCLUSIVE_STOP_PRELAUNCH'
        elif memory['free_commit'] < limits.launch_commit or memory['free_physical'] < limits.launch_physical:
            result['outcome'] = 'INCONCLUSIVE_RESOURCE_PRELAUNCH'
        else:
            try:
                job = OwnedJob(limits.private_tree_cap)
            except BaseException:
                result['outcome'] = 'INCONCLUSIVE_OWNERSHIP_SETUP'
                raise
            with open(os.devnull, 'rb') as stdin, (report_dir/'stdout.log').open('xb') as stdout, \
                    (report_dir/'stderr.log').open('xb') as stderr, \
                    (report_dir/'events.jsonl').open('x', encoding='utf-8') as events:
                try:
                    job.start(argv, cwd, environment, stdin, stdout, stderr,
                              test_assignment_failure=test_assignment_failure, deadline_epoch=deadline_epoch)
                except TimeoutError:
                    result['outcome'] = 'INCONCLUSIVE_AUTHORIZATION_EXPIRED_BEFORE_RESUME'
                    raise
                except BaseException:
                    result['outcome'] = 'INCONCLUSIVE_OWNERSHIP_SETUP'
                    raise
                result.update(resumed=job.resumed, root_pid=int(job.info.pid))
                result['job_configuration'] = job.configuration()
                while True:
                    elapsed = time.monotonic()-started
                    sample = {**host_memory(), **job.sample(), 'elapsed_seconds': elapsed}
                    if test_resource_floor_after is not None and elapsed >= test_resource_floor_after:
                        sample['free_commit'] = 0
                        sample['simulated_resource_floor'] = True
                    observed.update(sample['pids'])
                    sample['return_code'] = job.return_code()
                    events.write(json.dumps(sample)+'\n')
                    events.flush()
                    if deadline_epoch is not None and time.time() >= deadline_epoch:
                        outcome = 'INCONCLUSIVE_AUTHORIZATION_EXPIRED'
                    elif sample['free_commit'] < limits.reserve_commit:
                        outcome = 'INCONCLUSIVE_RESOURCE_FLOOR'
                    elif sample['private_tree'] > limits.private_tree_cap:
                        outcome = 'INCONCLUSIVE_PRIVATE_LIMIT'
                    elif elapsed >= limits.wall_seconds:
                        outcome = 'INCONCLUSIVE_TIMEOUT'
                    elif stopped():
                        outcome = 'INCONCLUSIVE_STOP'
                    elif sample['return_code'] is not None:
                        result['return_code'] = sample['return_code']
                        if root_exit_seen is None:
                            root_exit_seen = elapsed
                        # The first sample may predate root exit. Re-query only the owned job.
                        active = job.pids()
                        observed.update(active)
                        # Redirector teardown can outlive root signaling briefly. All resource
                        # and STOP checks continue during this fixed, bounded settling period.
                        if active and elapsed-root_exit_seen < .25:
                            time.sleep(poll_seconds)
                            continue
                        if active:
                            outcome = 'INCONCLUSIVE_DESCENDANTS_REMAINED'
                        elif sample['return_code'] != 0:
                            outcome = 'INCONCLUSIVE_PROCESS_FAILURE'
                        else:
                            outcome = 'PROCESS_SUCCEEDED'
                    else:
                        time.sleep(poll_seconds)
                        continue
                    result['outcome'] = outcome
                    if sample['pids']:
                        result['cleanup_complete'] = job.terminate_and_wait()
                    break
    except BaseException as error:
        result['error'] = repr(error)
        if job is not None:
            result['root_pid'] = int(job.info.pid) or None
            result['resumed'] = job.resumed
            try:
                result['cleanup_complete'] = job.terminate_and_wait()
            except BaseException as cleanup_error:
                result['cleanup_complete'] = False
                result['cleanup_error'] = repr(cleanup_error)
    finally:
        if job is not None:
            job.close()
        result['observed_owned_pids'] = sorted(observed)
        result['wall_seconds'] = time.monotonic()-started
        changed = []
        for bound in [manifest['supervisor'], manifest['supervisor_interpreter'],
                      bindings['tool'], *bindings['sources'], *bindings['configs']]:
            try:
                unchanged = file_binding(bound['path']) == bound
            except OSError:
                unchanged = False
            if not unchanged:
                changed.append(bound['path'])
        result['changed_bindings'] = changed
        if changed:
            result['outcome'] = 'INCONCLUSIVE_BINDING_CHANGED'
        if not result['cleanup_complete']:
            result['outcome'] = 'INCONCLUSIVE_CLEANUP'
        result['manifest_sha256'] = initial_manifest['sha256']
        result['supervisor'] = manifest['supervisor']
        try:
            result['manifest_unchanged'] = file_binding(report_dir/'manifest.json') == initial_manifest
        except OSError:
            result['manifest_unchanged'] = False
        if not result['manifest_unchanged']:
            result['outcome'] = 'INCONCLUSIVE_REPORT_CHANGED'
        result['log_bindings'] = {name: file_binding(report_dir/name) for name in
            ['stdout.log', 'stderr.log', 'events.jsonl'] if (report_dir/name).exists()}
        with (report_dir/'result.json').open('x', encoding='utf-8') as stream:
            json.dump(result, stream, indent=2)
    return result
