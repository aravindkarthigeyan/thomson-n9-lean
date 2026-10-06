"""Replay adversarial checks in isolated processes; never mutate certificates."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]


def run_all(directory, fresh_sos_report):
    if not __debug__:
        raise RuntimeError('Mutation checks require assertions.')
    directory = Path(directory).resolve()
    directory.mkdir(parents=True, exist_ok=True)
    inputs = [ROOT/p for p in (
        'certificates/local.json', 'sdp/lp-separation.json',
        'sdp/lp-separation-05593.json', 'near_sharp/hermite.json',
        'near_sharp/bernstein-minorant.json', 'near_sharp/near-sharp-d10.json',
        'rigidity/exact_gram.json', 'rigidity/window_gram.json')]
    before = {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in inputs}
    integer_report = dict(fresh_sos_report)
    integer_report['certificate_sha256'] = before['near_sharp/near-sharp-d10.json']
    integer_path = directory/'fresh-integer-report.json'
    integer_path.write_text(json.dumps(integer_report, indent=2)+'\n')
    commands = [
        ('local', ['certificates/check_local.py', '--negative-controls',
                   '--report', str(directory/'local.json')]),
        ('covariance_lp', ['certificates/check_lp.py', 'sdp/lp-separation.json',
                           '--negative-control', '--report', str(directory/'covariance-lp.json')]),
        ('separation_lp', ['certificates/check_lp.py', 'sdp/lp-separation-05593.json',
                           '--negative-control', '--report', str(directory/'separation-lp.json')]),
        ('hermite', ['near_sharp/check_hermite.py', 'near_sharp/hermite.json',
                     '--negative-control', '--output', str(directory/'hermite.json')]),
        ('bernstein', ['near_sharp/check_bernstein.py', '--negative-controls',
                       '--output', str(directory/'bernstein.json')]),
        ('integer_sos', ['certificates/test_sos_integer.py']),
        ('rigidity_mutations', ['rigidity/test_rejections.py']),
        ('rigidity_audit', ['verification/audit_rigidity.py']),
        ('full_certificate_audit', ['near_sharp/audit_final_certificate.py',
                                     '--integer-report', str(integer_path)]),
    ]
    results = []
    for name, arguments in commands:
        print('Adversarial suite: '+name, flush=True)
        started = time.monotonic()
        run = subprocess.run([sys.executable, *arguments], cwd=ROOT,
                             capture_output=True, text=True, timeout=1800)
        log = directory/(name+'.log')
        log.write_text(run.stdout+'\n'+run.stderr, encoding='utf-8')
        if run.returncode != 0:
            raise RuntimeError(f'{name} failed with exit {run.returncode}; see {log}')
        results.append({'name': name, 'result': 'PASS',
                        'seconds': time.monotonic()-started,
                        'command': [sys.executable, *arguments],
                        'log_sha256': hashlib.sha256(log.read_bytes()).hexdigest()})
    after = {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
             for p in inputs}
    assert before == after, 'A certificate changed during adversarial replay'
    report = {'result': 'PASS', 'scope': 'Nine adversarial/reconstruction suites',
              'certificates_unchanged': True, 'certificate_sha256': before,
              'suites': results, 'python_version': sys.version}
    (directory/'summary.json').write_text(json.dumps(report, indent=2)+'\n')
    return report
