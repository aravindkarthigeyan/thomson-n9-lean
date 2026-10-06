"""sk_tool.py -- helpers for run_second_kernel.sh / build_second_kernel.sh (no Lean, no Rust; reads/writes only the
files it is given).  Fail-closed throughout: a missing, unreadable or inconsistent input is ERROR, never success.

  config    --export P --out CFG [--pp "A B"] [--axioms "x y"] [--exclusive]     the ONLY config shape written: single-
            threaded (no num_threads), hard axiom error, both literal extensions, pp to stdout
  config-check --config CFG --export P --pp .. --axioms .. [--require-axioms ..] [--expect-sha S]
            exact key-for-key check of a config (no extra key), prints its sha256 (exit 1 otherwise)
  sites-check --pins P      the pinned semantic-site whitelist validates against the pinned nanoda source and pins
  meta      --export P --lean-commit H [--format 3.1.0]        first line must be lean4export meta, exact versions
  stats     --export P --out S.json [--decls NAME ...] [--lean-commit H] [--format F]
            parse EVERY line (malformed JSON = error), exactly one meta line (the first), count declarations the way
            nanoda_lib 0.4.19 inserts them (axiom/thm/def/opaque/quot = 1, inductive = types+ctors+recs), and
            check that each --decls name is declared in the export
  export-check --journal J --invocation ID --export P --err E --out S.json [--decls ..] [--lean-commit H]
            classify a lean4export run: PASS only for a clean record, exit 0, fully parsable export with the
            required declarations; prints STATUS<TAB>reason (ERROR / INCONCLUSIVE / UNFINISHED otherwise)
  classify  --journal J --invocation ID --out OUT --err ERR [--json RES] [--expected-decls N]
            ACCEPTED | REJECTED | INCONCLUSIVE | ERROR | UNFINISHED  (see classify_nanoda; REJECTED only at a site of
            the pinned whitelist nanoda_semantic_sites.json, re-validated against the pinned nanoda source)
  map-status --result RES.json --role accept|positive|reject|tamper [--reject-class typecheck] [--allowed-axioms ..]
            per-check status (PASS/REJECTED/FAILED/INCONCLUSIVE/ERROR/UNFINISHED) of a classified nanoda run
  tamper    --export P --old OLD --new NEW --out Q [--all]
  result    --journal J --out RES.json --field k=v ...
  control   --name N --expect S[,S..] --result RES.json --controls C.json [--message-regex RX]
  checkout-state --export-dir D --nanoda-dir D --pins P [--phase pre|post] [--out J]
  record    --out REC --controls C.json --pins P --export-dir D --nanoda-dir D --lean4export-exe X --nanoda-exe X
            --lean-exe X --stack-reserve N --expected-stack N [--diff F] [--invocation-dir D] [--partial]
  verify-record --record REC --pins P --export-dir D --nanoda-dir D --lean4export-exe X --nanoda-exe X
  final-overrides --pins P [--set NAME=VALUE ...]   prints one forbidden override per line (exit 1 if any)
  bind      --mode claude-rebuild|codex-clean --pins P --freeze-sha S --modules "M .." --out BIND.json --pkg-cache D
            claude-rebuild: --vf VF --rebuild-dir R ;  codex-clean: --snapshot D --run-dir D --result-sha S
            (codex-clean: RESULT digest + exact schema + complete evidence inventory BEFORE any inventory is read,
            exact FREEZE tree replay -- vf_common.bind_codex_result; claude-rebuild: VERDICT/OBJECTS/RUN_BINDING and
            exact replay of rebuild/src against FREEZE_MANIFEST.copy; both re-inventory the external objects)
  bind-verify --bind BIND.json --pins P
  pp-check  --out nanoda.out --regex RX --names "A B .."
  runmanifest --mode create|verify --manifest RUN_MANIFEST.json --pins P --preset X --scope S --modules ..
            --theorems .. --pp .. --axioms .. --expect .. --pp-regex .. --export EXP --config CFG --record REC?
            --bind BIND? --olean-list L --tool name=path ... --script path ... [--stats S.json]
            (binds the sha256 + parsed options of the actual nanoda.config.json and the whitelist sha256)
"""
import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import vf_common as C  # noqa: E402

LAUNCH_MARKER = 'redirect.py: cannot start'
NANODA_STATUSES = ('ACCEPTED', 'REJECTED', 'INCONCLUSIVE', 'ERROR', 'UNFINISHED')
HERE = os.path.dirname(os.path.abspath(__file__))

# ---- nanoda_lib 0.4.19 (3a240721) semantic-site whitelist --------------------------------------------------------
# REJECTED is decided ONLY by the exact pinned whitelist nanoda_semantic_sites.json (generated from the pinned source
# by make_semantic_sites.py, reviewed, sha256 pinned here AND in FINAL_PINS.json second_kernel.semantic_sites_sha256).
# At load time the file's sha256 is checked, and every listed site is re-validated against the pinned nanoda source:
# per-file sha256 (CRLF->LF), the exact source line text, its sha256, the producing macro/format string and its
# column.  Any difference makes the whitelist invalid, and then nothing can be REJECTED (ERROR 'whitelist-invalid').
NANODA_REV = '3a2407216ee84a75f9e1aead6803d0578be06ae7'
SEMANTIC_SITES_FILE = os.path.join(HERE, 'nanoda_semantic_sites.json')
SEMANTIC_SITES_SHA256 = 'ff6fb1166da58ddb0af8f154ac284961c96371ff4d95be5d20e698ec903f4b2f'
NANODA_SRC_DEFAULT = os.path.join(HERE, 'src', 'nanoda_lib')
# success (src/main.rs:34)
SUCCESS_RE = re.compile(r'^Checked (\d+) declarations with no errors$')
RESOURCE_PANIC = re.compile(r'capacity overflow|memory allocation of \d+ bytes failed')
RESOURCE_TEXT = re.compile(r"has overflowed its stack|fatal runtime error: stack overflow|memory allocation of \d+ bytes "
                           r"failed|out of memory", re.I)
# Rust >= 1.73 panic header (the real Phase-2 runs: "thread 'main' (69740) panicked at src\tc.rs:505:21:")
PANIC_HEADER = re.compile(r"^thread '(?P<thread>[^']*)'(?: \((?P<tid>\d+)\))? panicked at (?P<file>[^\s:][^:]*):"
                          r"(?P<line>\d+):(?P<col>\d+):$")
RUST_NOTE = 'note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace'
HELP_LINE = 'run with `-h` or `--help` for help'          # src/main.rs HELP_SHORT, printed after every `Error:`


def load_semantic_sites(path=None, expected_sha256=None, src_root=None):
    """Load and fully re-validate the whitelist; returns {'sha256', 'panic': {(file, line): site}, 'error': [site]}.
    Raises C.VFError on ANY inconsistency (the caller must then refuse every REJECTED classification)."""
    path = path or SEMANTIC_SITES_FILE
    expected = (expected_sha256 or SEMANTIC_SITES_SHA256).lower()
    src_root = src_root or NANODA_SRC_DEFAULT
    try:
        raw = open(path, 'rb').read()
    except OSError as e:
        raise C.VFError(f'semantic-site whitelist unreadable: {e}')
    if C.sha256_bytes(raw) != expected:
        raise C.VFError(f'semantic-site whitelist sha256 {C.sha256_bytes(raw)} != pinned {expected}')
    doc = C.loads_strict(raw.decode('utf-8'), path)
    if doc.get('schema') != 1 or doc.get('nanoda_rev') != NANODA_REV or not isinstance(doc.get('files'), dict) \
            or not isinstance(doc.get('sites'), list) or not doc['sites']:
        raise C.VFError('semantic-site whitelist: bad schema/nanoda_rev/files/sites')
    lines_of = {}
    for f, meta in doc['files'].items():
        C.check_rel_path(f, allow_objects=True)
        p = os.path.join(src_root, *f.split('/'))
        try:
            data = open(p, 'rb').read()
        except OSError as e:
            raise C.VFError(f'pinned nanoda source {f} unreadable: {e}')
        if C.sha256_bytes(data.replace(b'\r\n', b'\n')) != (meta or {}).get('sha256_lf'):
            raise C.VFError(f'pinned nanoda source {f} differs from the whitelist (sha256 of LF-normalised bytes)')
        lines_of[f] = data.replace(b'\r\n', b'\n').decode('utf-8').split('\n')
    panic, error, ids = {}, [], set()
    for s in doc['sites']:
        try:
            sid, kind, cls, f, line, col = s['id'], s['kind'], s['cls'], s['file'], s['line'], s['column']
            text, token = s['source_line'], s['source_token']
        except (KeyError, TypeError):
            raise C.VFError(f'semantic site without id/kind/cls/file/line/column/source_line/source_token: {s!r}'[:300])
        if sid in ids or not isinstance(line, int) or not isinstance(col, int) or f not in lines_of \
                or not 1 <= line <= len(lines_of[f]):
            raise C.VFError(f'semantic site {sid!r}: duplicate id, bad line/column or unlisted file')
        ids.add(sid)
        if lines_of[f][line - 1] != text or C.sha256_bytes(text.encode('utf-8')) != s.get('source_line_sha256'):
            raise C.VFError(f'semantic site {sid}: {f}:{line} is no longer {text!r} in the pinned source')
        if text.find(token) + 1 != col:
            raise C.VFError(f'semantic site {sid}: token {token!r} not at column {col} of {f}:{line}')
        if kind == 'panic' and cls == 'typecheck':
            msg = s.get('message')
            want = ('assert!(' + msg[len('assertion failed: '):] + ')') if isinstance(msg, str) and \
                msg.startswith('assertion failed: ') else f'panic!("{msg}")'
            if token != want or (f, line) in panic:
                raise C.VFError(f'semantic site {sid}: message {msg!r} is not produced by {token!r} (or duplicate site)')
            panic[(f, line)] = s
        elif kind == 'returned-error' and cls == 'axiom-policy':
            try:
                s['_rx'] = re.compile(s['message_regex'])
            except (KeyError, TypeError, re.error) as e:
                raise C.VFError(f'semantic site {sid}: bad message_regex: {e}')
            lit = token.strip('"').split('{')[0]
            if not s['message_regex'].startswith('^Error: ' + re.escape(lit).replace('\\ ', ' ')):
                raise C.VFError(f'semantic site {sid}: message_regex does not start with the format string {lit!r}')
            error.append(s)
        else:
            raise C.VFError(f'semantic site {sid}: unsupported kind/cls {kind}/{cls}')
    return {'sha256': expected, 'panic': panic, 'error': error, 'path': os.path.abspath(path)}


_DEFAULT_SITES = []


def default_sites():
    """(sites, None) or (None, reason) for the pinned whitelist next to this script (validated once per process)."""
    if not _DEFAULT_SITES:
        try:
            _DEFAULT_SITES.append((load_semantic_sites(), None))
        except Exception as e:          # noqa: BLE001 -- ANY failure means "invalid": fail closed, never REJECTED
            _DEFAULT_SITES.append((None, f'{type(e).__name__}: {e}'))
    return _DEFAULT_SITES[0]


def classify_nanoda(rec, out, err, expected_decls=None, sites=None):
    """Classify one nanoda_bin run.  Returns dict(status, cls, message, declarations, site).
    ACCEPTED     exit 0, exactly one success line which is the last stdout line, no panic/Error on stderr, and (if
                 given) the declaration count equals the export's;
    REJECTED     ONLY at a site of the pinned whitelist (nanoda_semantic_sites.json, re-validated against the pinned
                 source): cls 'typecheck' = exit 101, exactly one panic header, thread 'main', location <file>:<line>
                 of a whitelisted panic site (path relative to the crate root) with exactly its message, no other
                 stderr line but the RUST_BACKTRACE note, empty stdout; cls 'axiom-policy' = exit 1, the whitelisted
                 'Error: export file declares unpermitted axiom "<name>"' followed only by nanoda's help line;
    INCONCLUSIVE NTSTATUS crash (stack overflow, abort after failed allocation, ...), resource panics/messages;
    UNFINISHED   stop file before start;
    ERROR        everything else: no journal record, launch failure, invalid whitelist, config/I-O/parse/format errors
                 ('Error: ...' exit 1, 'Declined: ...' exit 2), any panic at an unlisted (file, line) or with an
                 unlisted message (generic asserts, internal invariants, overflow/index/unwrap, parser, util.rs config
                 panic, expr.rs, ...), several panics or a worker-thread panic, unexpected extra output, success line
                 with non-zero exit, exit 0 without a valid success line, pretty-printer errors, count mismatch,
                 unexpected exit codes."""
    out = (out or '').replace('\r', '')
    err = (err or '').replace('\r', '')
    res = {'status': 'ERROR', 'cls': 'unknown', 'message': '', 'declarations': None, 'site': None}
    pre = C.record_preamble(rec)
    if pre:
        st, why = pre
        res.update(status=st, cls={'UNFINISHED': 'stopped', 'INCONCLUSIVE': 'resource'}.get(st, 'runner'), message=why)
        if st == 'INCONCLUSIVE':
            res['message'] += ' | ' + err.strip()[-300:]
        return res
    rc = rec['exit_code'] & 0xFFFFFFFF
    if LAUNCH_MARKER in err:
        res.update(cls='launch', message=next(l for l in err.split('\n') if LAUNCH_MARKER in l))
        return res
    lines = [l for l in out.split('\n') if l.strip()]
    succ = [l for l in lines if SUCCESS_RE.match(l.strip())]
    err_lines = [l.rstrip() for l in err.split('\n') if l.strip()]
    panic_lines = [l for l in err_lines if ' panicked at ' in l]
    if rc == 0:
        if len(succ) == 1 and lines and SUCCESS_RE.match(lines[-1].strip()) and not panic_lines and 'Error:' not in err:
            n = int(SUCCESS_RE.match(lines[-1].strip()).group(1))
            res['declarations'] = n
            if expected_decls is not None and n != expected_decls:
                res.update(cls='count-mismatch', message=f'nanoda checked {n} declarations, export has {expected_decls}')
                return res
            res.update(status='ACCEPTED', cls='accepted', message=lines[-1].strip())
            return res
        if any('with no typechecker errors' in l for l in lines):
            res.update(cls='pretty-printer', message='type checking finished but pretty-printer errors were reported')
        elif any('skipping exported but unpermitted axioms' in l or l.startswith('Skipped exported but unpermitted')
                 for l in lines):
            res.update(cls='config', message='unpermitted axioms were skipped (configuration is not hard-error)')
        else:
            res.update(cls='no-success-line', message=f'exit 0 but {len(succ)} success lines / success not last')
        return res
    if succ:
        res.update(cls='inconsistent', message=f'success line present but exit code {rc}')
        return res
    if RESOURCE_TEXT.search(err):
        res.update(status='INCONCLUSIVE', cls='resource', message=RESOURCE_TEXT.search(err).group(0))
        return res
    if sites is None:
        sites, sites_err = default_sites()
    else:
        sites_err = None
    if rc == 1:
        e1 = next((l for l in err_lines if l.startswith('Error: ')), None)
        if e1 is None:
            res.update(cls='exit1-unrecognised', message=(err_lines[0] if err_lines else 'exit 1, empty stderr')[:400])
            return res
        if sites is None:
            res.update(cls='whitelist-invalid' if 'unpermitted axiom' in e1 else 'input-or-config',
                       message=(f'{e1[:200]} | semantic-site whitelist invalid: {sites_err}')[:400])
            return res
        site = next((s for s in sites['error'] if s['_rx'].match(e1)), None)
        if site is None:
            res.update(cls='input-or-config', message=e1[:400])
        elif err_lines[0] != e1 or any(l != HELP_LINE for l in err_lines[1:]) or lines:
            res.update(cls='unexpected-output', message=f'axiom-policy message with unexpected extra output: {e1}'[:400])
        else:
            res.update(status='REJECTED', cls=site['cls'], site=site['id'],
                       message=f'{e1} [whitelisted site {site["id"]} {site["file"]}:{site["line"]}]'[:400])
        return res
    if rc == 2 and any(l.startswith('Declined: ') for l in err_lines):
        res.update(cls='malformed-export', message=next(l for l in err_lines if l.startswith('Declined: '))[:400])
        return res
    if rc == 101:
        if not panic_lines:
            res.update(cls='exit101-no-panic', message='exit 101 without a panic header')
            return res
        hdr = [(i, PANIC_HEADER.match(l)) for i, l in enumerate(err_lines) if ' panicked at ' in l]
        if len(hdr) != 1 or hdr[0][1] is None:
            res.update(cls='multiple-panics' if len(hdr) > 1 else 'unrecognised-panic-format',
                       message=' | '.join(panic_lines)[:400])
            return res
        i, m = hdr[0]
        msg = err_lines[i + 1].strip() if i + 1 < len(err_lines) else ''
        f, line, col = m.group('file').replace('\\', '/'), int(m.group('line')), int(m.group('col'))
        where = f'{f}:{line}:{col}'
        if RESOURCE_PANIC.search(msg):
            res.update(status='INCONCLUSIVE', cls='resource', message=f'panic at {where}: {msg}'[:400])
            return res
        if sites is None:
            res.update(cls='whitelist-invalid', message=f'panic at {where}: {msg} | whitelist invalid: {sites_err}'[:400])
            return res
        site = sites['panic'].get((f, line))
        if m.group('thread') != 'main':
            res.update(cls='panic-not-main-thread', message=f"thread '{m.group('thread')}' panicked at {where}: {msg}"[:400])
        elif site is None:
            res.update(cls='unlisted-panic-site', message=f'panic at {where}: {msg} (not a whitelisted semantic site)'[:400])
        elif msg != site['message']:
            res.update(cls='unlisted-panic-message', message=f'panic at {where}: {msg!r} != whitelisted {site["message"]!r}'[:400])
        elif err_lines[:i] or err_lines[i + 2:] not in ([], [RUST_NOTE]):
            res.update(cls='unexpected-stderr', message=f'panic at {where}: {msg} with unexpected extra stderr lines'[:400])
        elif lines:
            res.update(cls='unexpected-stdout', message=f'panic at {where}: {msg} but stdout is not empty'[:400])
        else:
            res.update(status='REJECTED', cls=site['cls'], site=site['id'], column_matches=(col == site['column']),
                       message=f'panic at {where}: {msg} [whitelisted site {site["id"]}]'[:400])
        return res
    res.update(cls='unexpected-exit', message=f'exit {rc}: {(err_lines[0] if err_lines else "")[:300]}')
    return res


def cmd_classify(a):
    rec = C.journal_record(a.journal, invocation=a.invocation)
    rd = lambda p: Path(p).read_text(encoding='utf-8', errors='replace') if p and os.path.exists(p) else None
    out, err = rd(a.out), rd(a.err)
    if rec is not None and not rec.get('stopped_before_start') and not rec.get('launch_error') and (out is None or err is None):
        res = {'status': 'ERROR', 'cls': 'missing-output', 'message': 'nanoda stdout/stderr file missing',
               'declarations': None, 'site': None}
    else:
        res = classify_nanoda(rec, out, err, a.expected_decls)
    sites, sites_err = default_sites()
    axioms = [x.rstrip('.') for x in re.findall(r'^axiom ([^\s:{(]+)', (out or '').replace('\r', ''), re.M)]
    res.update(axioms=axioms, invocation=a.invocation, exit_code=(rec or {}).get('exit_code'),
               wall_seconds=(rec or {}).get('wall_seconds'), peak_job_commit_gb=(rec or {}).get('peak_job_commit_gb'),
               semantic_sites_sha256=SEMANTIC_SITES_SHA256 if sites else None, semantic_sites_error=sites_err)
    if a.json:
        C.write_json(a.json, res)
    print(json.dumps(res))
    return 0


# ---- export helpers --------------------------------------------------------------------------------------------
CONFIG_KEYS = ('export_file_path', 'use_stdin', 'permitted_axioms', 'unpermitted_axiom_hard_error', 'nat_extension',
               'string_extension', 'pp_declars', 'pp_to_stdout', 'unknown_pp_declar_hard_error', 'print_axioms',
               'print_success_message')


def make_config(export, pp, axioms):
    """The ONLY nanoda configuration this tooling writes: single-threaded (no num_threads key -> nanoda checks
    serially on the main thread), hard error on unpermitted axioms, both literal extensions, pp to stdout."""
    return {"export_file_path": export, "use_stdin": False, "permitted_axioms": list(axioms),
            "unpermitted_axiom_hard_error": True, "nat_extension": True, "string_extension": True,
            "pp_declars": list(pp), "pp_to_stdout": True, "unknown_pp_declar_hard_error": True,
            "print_axioms": True, "print_success_message": True}


def config_errors(path, export, pp, axioms, required_axioms=None):
    """Exact check of a nanoda.config.json: returns (sha256, parsed, errors).  The parsed options must equal
    make_config(export, pp, axioms) key for key (no extra key such as num_threads, pp_output_path or
    unsafe_permit_all_axioms); with required_axioms, permitted_axioms must be exactly that set, without duplicates."""
    try:
        raw = open(path, 'rb').read()
        cfg = C.loads_strict(raw.decode('utf-8'), path)
    except (OSError, ValueError, UnicodeDecodeError, C.VFError) as e:
        return None, None, [f'nanoda config unreadable: {e}']
    errs = []
    want = make_config(export, pp, axioms)
    if not isinstance(cfg, dict) or sorted(cfg) != sorted(CONFIG_KEYS):
        errs.append(f'nanoda config keys {sorted(cfg) if isinstance(cfg, dict) else type(cfg)} != {sorted(CONFIG_KEYS)}')
    else:
        for k in CONFIG_KEYS:
            if cfg[k] != want[k] or type(cfg[k]) is not type(want[k]):
                errs.append(f'nanoda config {k} = {cfg[k]!r}, required {want[k]!r}')
    ax = cfg.get('permitted_axioms') if isinstance(cfg, dict) else None
    if required_axioms is not None and (not isinstance(ax, list) or len(ax) != len(set(ax))
                                        or set(ax) != set(required_axioms)):
        errs.append(f'nanoda config permitted_axioms {ax!r} is not exactly {sorted(required_axioms)}')
    return C.sha256_bytes(raw), cfg, errs


def cmd_config(a):
    cfg = make_config(a.export, a.pp.split(), a.axioms.split())
    with open(a.out, 'x' if a.exclusive else 'w', encoding='utf-8', newline='\n') as f:
        f.write(json.dumps(cfg, indent=1) + '\n')
    print(json.dumps(cfg))
    return 0


def cmd_config_check(a):
    """Print the sha256 of an exactly valid nanoda config (exit 0), else the problems (exit 1)."""
    sha, _, errs = config_errors(a.config, a.export, a.pp.split(), a.axioms.split(),
                                 a.require_axioms.split() if a.require_axioms else None)
    if not errs and a.expect_sha and sha != a.expect_sha:
        errs.append(f'nanoda config sha256 {sha} != the bound {a.expect_sha}')
    for e in errs:
        print('ERROR:', e)
    if not errs:
        print(sha)
    return 1 if errs else 0


def check_meta_line(first, lean_commit, fmt):
    try:
        m = json.loads(first)['meta']
    except (ValueError, KeyError, TypeError):
        return 'export does not start with a meta object'
    if not isinstance(m, dict):
        return 'meta is not an object'
    if (m.get('exporter') or {}).get('name') != 'lean4export':
        return f'exporter is not lean4export: {m.get("exporter")}'
    if (m.get('format') or {}).get('version') != fmt:
        return f'format {(m.get("format") or {}).get("version")} != {fmt}'
    if lean_commit and (m.get('lean') or {}).get('githash') != lean_commit:
        return f'lean githash {(m.get("lean") or {}).get("githash")} != {lean_commit}'
    return None


def cmd_meta(a):
    try:
        with open(a.export, 'rb') as f:
            first = f.readline().decode('utf-8', 'replace').strip()
    except OSError as e:
        print(f'export unreadable: {e}'); return 1
    print(first[:400])
    bad = check_meta_line(first, a.lean_commit, a.format)
    if bad:
        print(f'unexpected export meta: {bad}')
    return 1 if bad else 0


def export_stats(path, decl_names=(), lean_commit='', fmt='3.1.0'):
    names = {0: ''} if decl_names else None
    want = set(decl_names)
    found = set()
    counts = {'axiom': 0, 'thm': 0, 'def': 0, 'opaque': 0, 'quot': 0, 'inductive_items': 0}
    lines = meta_lines = 0
    errors = []

    def nm(i):
        return names.get(i) if names is not None else None
    with open(path, 'rb') as f:
        for raw in f:
            lines += 1
            try:
                o = json.loads(raw)
            except ValueError:
                errors.append(f'line {lines}: not JSON'); break
            if not isinstance(o, dict):
                errors.append(f'line {lines}: not an object'); break
            if 'meta' in o:
                meta_lines += 1
                if lines != 1:
                    errors.append(f'line {lines}: extra meta line')
                else:
                    bad = check_meta_line(raw.decode('utf-8', 'replace'), lean_commit, fmt)
                    if bad:
                        errors.append(bad)
                continue
            if lines == 1:
                errors.append('first line is not meta')
            if names is not None and 'in' in o:
                if 'str' in o and isinstance(o['str'], dict):
                    p = nm(o['str'].get('pre'))
                    names[o['in']] = (p + '.' if p else '') + str(o['str'].get('str'))
                elif 'num' in o and isinstance(o['num'], dict):
                    p = nm(o['num'].get('pre'))
                    names[o['in']] = (p + '.' if p else '') + str(o['num'].get('i'))
                continue
            for k in ('axiom', 'thm', 'def', 'opaque', 'quot'):
                if k in o and isinstance(o[k], dict) and 'name' in o[k]:
                    counts[k] += 1
                    if names is not None and nm(o[k]['name']) in want:
                        found.add(nm(o[k]['name']))
            if 'inductive' in o and isinstance(o['inductive'], dict):
                ind = o['inductive']
                for part in ('types', 'ctors', 'recs'):
                    for it in ind.get(part, []):
                        counts['inductive_items'] += 1
                        if names is not None and nm(it.get('name')) in want:
                            found.add(nm(it.get('name')))
    if lines == 0:
        errors.append('empty export')
    if meta_lines != 1:
        errors.append(f'{meta_lines} meta lines (need exactly 1)')
    total = sum(counts.values())
    missing = sorted(want - found)
    if missing:
        errors.append(f'declarations not in export: {missing}')
    return {'lines': lines, 'declarations': total, 'counts': counts, 'decls_required': sorted(want),
            'decls_missing': missing, 'errors': errors}


def cmd_stats(a):
    try:
        st = export_stats(a.export, a.decls or (), a.lean_commit, a.format)
    except OSError as e:
        st = {'errors': [f'unreadable: {e}']}
    st['sha256'] = C.sha256_file(a.export) if os.path.exists(a.export) else None
    st['bytes'] = os.path.getsize(a.export) if os.path.exists(a.export) else None
    C.write_json(a.out, st)
    print(json.dumps({k: st.get(k) for k in ('lines', 'declarations', 'decls_missing', 'errors', 'sha256')}))
    return 1 if st['errors'] else 0


def cmd_export_check(a):
    """Classify one lean4export run (via redirect.py): PASS only if the run record is clean, exit 0, the export
    parses completely, has exactly one valid meta line and declares every --decls name.  Prints STATUS<TAB>reason
    and writes the statistics to --out."""
    rec = C.journal_record(a.journal, invocation=a.invocation)
    err = Path(a.err).read_text(encoding='utf-8', errors='replace') if os.path.exists(a.err) else ''
    st, why = 'PASS', ''
    pre = C.record_preamble(rec)
    if pre:
        st, why = pre
    elif LAUNCH_MARKER in err:
        st, why = 'ERROR', 'exporter could not be started'
    elif re.search(r'INTERNAL PANIC: out of memory|Stack overflow detected|out of memory', err):
        st, why = 'INCONCLUSIVE', 'exporter ran out of memory/stack'
    elif rec['exit_code'] != 0:
        st, why = 'ERROR', f'exporter exit {rec["exit_code"]}: ' + ' '.join(err.split())[:300]
    elif not os.path.exists(a.export) or os.path.getsize(a.export) == 0:
        st, why = 'ERROR', 'exporter produced no output'
    stats = {'errors': [why]} if st != 'PASS' else export_stats(a.export, a.decls or (), a.lean_commit, a.format)
    if st == 'PASS':
        stats['sha256'] = C.sha256_file(a.export)
        stats['bytes'] = os.path.getsize(a.export)
        if stats['errors']:
            st, why = 'ERROR', 'export invalid: ' + '; '.join(stats['errors'])[:400]
        else:
            why = f'{stats["lines"]} lines, {stats["declarations"]} declarations, sha256 {stats["sha256"][:16]}'
    C.write_json(a.out, stats)
    print(f'{st}\t{why}')
    return 0


def map_status(res, role, reject_class='typecheck', allowed_axioms=None):
    """Map a nanoda classification to a per-check status for its role.
      accept / positive: ACCEPTED (and printed axioms within the allow-list) -> PASS; REJECTED -> REJECTED (accept)
                         or FAILED (positive control: the path rejects good input);
      reject / tamper:   REJECTED of class `reject_class` -> PASS; REJECTED of another class -> FAILED;
                         ACCEPTED -> FAILED (a bad proof was accepted);
      all roles:         INCONCLUSIVE / ERROR / UNFINISHED are passed through: never PASS, never a rejection."""
    st, msg = res.get('status'), res.get('message', '')
    if st not in NANODA_STATUSES:
        return 'ERROR', f'unknown nanoda status {st!r}'
    if st in ('INCONCLUSIVE', 'ERROR', 'UNFINISHED'):
        return st, f'{res.get("cls")}: {msg}'
    if st == 'REJECTED' and not res.get('site'):
        # a REJECTED classification must name the whitelisted site it matched (guards against stale result files)
        return 'ERROR', f'REJECTED without a whitelisted semantic site id ({res.get("cls")}): {msg}'
    if role in ('accept', 'positive'):
        if st == 'ACCEPTED':
            bad = [x for x in res.get('axioms', []) if allowed_axioms is not None and x not in allowed_axioms]
            if bad:
                return 'FAILED', f'accepted but with axioms outside the allow-list: {bad}'
            return 'PASS', msg
        return ('REJECTED' if role == 'accept' else 'FAILED'), f'{res.get("cls")}: {msg}'
    if role in ('reject', 'tamper'):
        if st == 'REJECTED':
            if res.get('cls') == reject_class:
                return 'PASS', f'rejected as expected ({res.get("cls")}): {msg}'
            return 'FAILED', f'rejected for an unexpected reason ({res.get("cls")}): {msg}'
        return 'FAILED', f'expected a {reject_class} rejection but nanoda ACCEPTED: {msg}'
    return 'ERROR', f'unknown role {role!r}'


def cmd_map_status(a):
    try:
        res = C.read_json_strict(a.result)
    except (C.VFError, OSError, ValueError) as e:
        print(f'ERROR\tno classification: {e}'); return 0
    st, why = map_status(res, a.role, a.reject_class, a.allowed_axioms.split() if a.allowed_axioms else None)
    print(f'{st}\t{why}')
    return 0


def cmd_tamper(a):
    pat = f'"natVal":"{a.old}"'.encode()
    rep = f'"natVal":"{a.new}"'.encode()
    count = 0
    with open(a.export, 'rb') as f:
        for line in f:
            count += line.count(pat)
    print(f'occurrences of {pat.decode()}: {count}')
    if count == 0 or (count > 1 and not a.all):
        print('refusing to tamper: the literal must occur exactly once (or pass --all)'); return 1
    with open(a.export, 'rb') as f, open(a.out, 'xb') as g:
        for line in f:
            g.write(line.replace(pat, rep))
    return 0


def cmd_result(a):
    res = json.loads(Path(a.out).read_text(encoding='utf-8')) if Path(a.out).exists() else {}
    for kv in a.field:
        k, _, v = kv.partition('=')
        try:
            res[k] = json.loads(v)
        except ValueError:
            res[k] = v
    steps = []
    if Path(a.journal).exists():
        for line in open(a.journal, encoding='utf-8'):
            if line.strip():
                r = json.loads(line)
                steps.append({k: r.get(k) for k in ('step', 'invocation', 'exit_code', 'stopped_before_start',
                                                     'launch_error', 'wall_seconds', 'cpu_seconds', 'peak_job_commit_gb',
                                                     'peak_tree_working_set_gb_sampled', 'min_free_physical_gb_sampled')})
    res['steps'] = steps
    C.write_json(a.out, res)
    return 0


def cmd_pp_check(a):
    out = Path(a.out).read_text(encoding='utf-8', errors='replace').replace('\r', '') if os.path.exists(a.out) else ''
    errs = []
    if not re.search(a.regex, out, re.M):
        errs.append(f'statement does not match /{a.regex}/')
    for n in a.names.split():
        if not re.search(r'(?m)^(?:theorem|def|axiom|opaque|inductive|structure|class|abbrev|instance)\s+'
                         + re.escape(n) + r'\b', out):
            errs.append(f'no pretty-printed declaration {n}')
    print('PASS' if not errs else 'FAILED\t' + '; '.join(errs))
    return 0 if not errs else 1


# ---- controls / tool-build record ----------------------------------------------------------------------------------
def cmd_control(a):
    try:
        r = C.read_json_strict(a.result)
    except (C.VFError, OSError, ValueError) as e:
        r = {'status': 'ERROR', 'message': f'no classification: {e}'}
    expect = a.expect.split(',')
    ok = r.get('status') in expect and (not a.message_regex or re.search(a.message_regex, r.get('message') or ''))
    if r.get('status') == 'REJECTED':
        # a rejection control passes only at the exact whitelisted site it names (never on a generic rejection)
        ok = ok and bool(a.expect_site) and r.get('site') == a.expect_site
    ctl = C.read_json_strict(a.controls) if os.path.exists(a.controls) else {}
    ctl[a.name] = {'expect': expect, 'message_regex': a.message_regex, 'expect_site': a.expect_site,
                   'status': r.get('status'), 'cls': r.get('cls'), 'site': r.get('site'),
                   'message': r.get('message'), 'semantic_sites_sha256': r.get('semantic_sites_sha256'),
                   'pass': bool(ok)}
    C.write_json(a.controls, ctl)
    print(f'control {a.name}: {"PASS" if ok else "FAIL"} (expected {a.expect}'
          f'{" /" + a.message_regex + "/" if a.message_regex else ""}{" at site " + a.expect_site if a.expect_site else ""}'
          f', got {r.get("status")} {r.get("site") or ""}: {r.get("message")})')
    return 0 if ok else 1


def _git(path, *args):
    try:
        p = subprocess.run(['git', '-C', path, *args], capture_output=True, text=True, timeout=300)
    except (OSError, subprocess.TimeoutExpired) as e:
        return None, str(e)
    return (p.stdout, None) if p.returncode == 0 else (None, (p.stderr or p.stdout).strip()[:300])


def checkout_state(export_dir, nanoda_dir, pins, phase='post'):
    sk = pins['second_kernel']
    errs, st = [], {}
    for label, d, rev in (('lean4export', export_dir, sk['lean4export_rev']), ('nanoda', nanoda_dir, sk['nanoda_rev'])):
        try:
            C.assert_plain(d)
        except C.VFError as e:
            errs.append(f'{label}: {e}'); continue
        out, err = _git(d, 'rev-parse', 'HEAD')
        head = (out or '').strip()
        st[label + '_head'] = head or None
        if err is not None or head != rev:
            errs.append(f'{label}: HEAD {head or "unreadable (" + str(err) + ")"} != pinned {rev}')
        out, err = _git(d, 'status', '--porcelain', '--untracked-files=all')
        if err is not None:
            errs.append(f'{label}: git status unreadable: {err}'); continue
        st[label + '_porcelain'] = [l for l in out.split('\n') if l.strip()]
    if 'nanoda_porcelain' in st and st['nanoda_porcelain']:
        errs.append(f'nanoda checkout not clean: {st["nanoda_porcelain"][:5]}')
    lock = os.path.join(nanoda_dir, 'Cargo.lock')
    st['cargo_lock_sha256'] = C.sha256_file(lock) if os.path.isfile(lock) else None
    if st['cargo_lock_sha256'] != sk['nanoda_cargo_lock_sha256']:
        errs.append('nanoda Cargo.lock differs from the pin')
    if 'lean4export_porcelain' in st:
        allowed = [[' M lean-toolchain']] if phase == 'post' else [[], [' M lean-toolchain']]
        if st['lean4export_porcelain'] not in allowed:
            errs.append(f'lean4export local changes other than the lean-toolchain line: {st["lean4export_porcelain"][:5]}')
        tc = os.path.join(export_dir, 'lean-toolchain')
        cur = Path(tc).read_text(encoding='utf-8').strip() if os.path.isfile(tc) else None
        st['lean4export_toolchain'] = cur
        head_tc, err = _git(export_dir, 'show', 'HEAD:lean-toolchain')
        if err is not None or head_tc.strip() != sk['lean4export_upstream_toolchain_line']:
            errs.append('lean4export HEAD lean-toolchain is not the pinned upstream line')
        if phase == 'post' or st['lean4export_porcelain']:
            if cur != pins['lean_toolchain_line']:
                errs.append(f'lean4export lean-toolchain {cur!r} != {pins["lean_toolchain_line"]!r}')
            numstat, err = _git(export_dir, 'diff', '--numstat')
            if err is not None or numstat.strip().replace('\r', '') != '1\t1\tlean-toolchain':
                errs.append(f'lean4export diff is not exactly one changed line in lean-toolchain: {numstat!r}')
            diff, _ = _git(export_dir, 'diff')
            st['lean4export_diff_sha256'] = C.sha256_bytes((diff or '').encode())
    return st, errs


def cmd_checkout_state(a):
    pins = C.read_json_strict(a.pins)
    st, errs = checkout_state(a.export_dir, a.nanoda_dir, pins, a.phase)
    st['errors'] = errs
    if a.out:
        C.write_json(a.out, st)
    for e in errs:
        print('ERROR:', e)
    print('checkout state: ' + ('OK' if not errs else f'{len(errs)} problems'))
    return 1 if errs else 0


def cmd_record(a):
    pins = C.read_json_strict(a.pins)
    req = pins['second_kernel']['required_controls']
    ctl = C.read_json_strict(a.controls) if os.path.exists(a.controls) else {}
    st, errs = checkout_state(a.export_dir, a.nanoda_dir, pins, 'post')
    for n in req:
        if n not in ctl:
            errs.append(f'control {n} not run')
        elif not ctl[n].get('pass'):
            errs.append(f'control {n} failed: {ctl[n].get("status")} {ctl[n].get("message")}')
    exes = {}
    for label, p in (('lean4export', a.lean4export_exe), ('nanoda', a.nanoda_exe), ('lean', a.lean_exe)):
        if label == 'lean' and not p:
            continue
        exes[label] = C.sha256_file(p) if p and os.path.isfile(p) else None
        if exes[label] is None:
            errs.append(f'{label} executable missing')
    if a.lean_exe and exes.get('lean') and exes['lean'] != pins['tool_sha256']['lean.exe']:
        errs.append('lean.exe differs from the pinned toolchain')
    if str(a.stack_reserve) != str(a.expected_stack) and str(a.expected_stack) != '0':
        errs.append(f'nanoda stack reserve {a.stack_reserve} != {a.expected_stack}')
    errs += semantic_sites_errors(pins)
    for n in req:
        c = ctl.get(n) or {}
        if c.get('status') == 'REJECTED' and c.get('semantic_sites_sha256') != SEMANTIC_SITES_SHA256:
            errs.append(f'control {n} was classified with another semantic-site whitelist')
    status = 'PASS' if not errs and not a.partial else ('INCOMPLETE' if a.partial and not errs else 'FAIL')
    rec = {'schema': 1, 'status': status, 'errors': errs, 'invocation_dir': a.invocation_dir,
           'semantic_sites_sha256': SEMANTIC_SITES_SHA256,
           'exe_sha256': exes, 'checkout': st, 'controls': ctl, 'required_controls': req,
           'nanoda_stack_reserve': a.stack_reserve, 'final_pins_sha256': C.sha256_file(a.pins),
           'lean4export_local_diff': Path(a.diff).read_text(encoding='utf-8') if a.diff and os.path.exists(a.diff) else None}
    C.write_json(a.out, rec)
    print(f'TOOL BUILD RECORD: {status}')
    for e in errs:
        print('ERROR:', e)
    return 0 if status == 'PASS' else 1


def semantic_sites_errors(pins):
    """The whitelist next to this script must validate against the pinned nanoda source, and its sha256 must be the
    one pinned in this script and in FINAL_PINS.json second_kernel.semantic_sites_sha256."""
    errs = []
    sites, why = default_sites()
    if sites is None:
        errs.append(f'semantic-site whitelist invalid: {why}')
    if (pins.get('second_kernel') or {}).get('semantic_sites_sha256') != SEMANTIC_SITES_SHA256:
        errs.append('FINAL_PINS second_kernel.semantic_sites_sha256 differs from the whitelist pinned in sk_tool.py')
    return errs


def cmd_sites_check(a):
    """Validate the pinned semantic-site whitelist against the pinned nanoda source and FINAL_PINS (exit 1 if not)."""
    errs = semantic_sites_errors(C.read_json_strict(a.pins))
    sites, _ = default_sites()
    for e in errs:
        print('ERROR:', e)
    if not errs:
        ids = sorted(s['id'] for s in list(sites['panic'].values()) + sites['error'])
        print(f'semantic-site whitelist VALID: sha256 {SEMANTIC_SITES_SHA256}; sites: {" ".join(ids)}')
    return 1 if errs else 0


def verify_record(record, pins, export_dir, nanoda_dir, lean4export_exe, nanoda_exe):
    errs = []
    try:
        rec = C.read_json_strict(record)
    except (C.VFError, OSError, ValueError) as e:
        return None, [f'tool build record unreadable: {e}']
    if rec.get('status') != 'PASS' or rec.get('errors'):
        errs.append(f'tool build record status {rec.get("status")}')
    errs += semantic_sites_errors(pins)
    if rec.get('semantic_sites_sha256') != SEMANTIC_SITES_SHA256:
        errs.append('tool build record controls were classified with another semantic-site whitelist')
    for n in pins['second_kernel']['required_controls']:
        c = (rec.get('controls') or {}).get(n)
        if not c or not c.get('pass'):
            errs.append(f'record lacks a passing control {n}')
    sk = pins['second_kernel']
    for label, p, pin in (('lean4export', lean4export_exe, sk.get('lean4export_sha256')),
                          ('nanoda', nanoda_exe, sk.get('nanoda_sha256'))):
        if not isinstance(pin, str) or not re.fullmatch('[0-9a-f]{64}', pin):
            errs.append(f'{label} binary pin missing or invalid in FINAL_PINS')
        cur = C.sha256_file(p) if os.path.isfile(p) else None
        if cur is None:
            errs.append(f'{label} executable missing: {p}')
        elif cur != (rec.get('exe_sha256') or {}).get(label):
            errs.append(f'{label} sha256 differs from the validated tool build record')
        elif cur != pin:
            errs.append(f'{label} sha256 differs from FINAL_PINS')
    st, cerrs = checkout_state(export_dir, nanoda_dir, pins, 'post')
    errs += cerrs
    if st.get('lean4export_diff_sha256') != (rec.get('checkout') or {}).get('lean4export_diff_sha256'):
        errs.append('lean4export local diff differs from the one recorded at build time')
    return rec, errs


def cmd_verify_record(a):
    pins = C.read_json_strict(a.pins)
    _, errs = verify_record(a.record, pins, a.export_dir, a.nanoda_dir, a.lean4export_exe, a.nanoda_exe)
    for e in errs:
        print('ERROR:', e)
    print('tool build record: ' + ('VALID' if not errs else 'INVALID'))
    return 1 if errs else 0


# ---- final preset: overrides and binding ---------------------------------------------------------------------------
def final_overrides(pins, sets):
    sk = pins['second_kernel']
    fixed = {'SK_THEOREMS': ' '.join(sk['theorems']), 'SK_PP': ' '.join(sk['pp_declars']), 'SK_EXPECT': sk['expect'],
             'SK_EXPECT_PP_REGEX': sk['pp_regex']}
    bad = []
    for k, v in sets.items():
        if k in fixed and v != fixed[k]:
            bad.append(f'{k}={v!r} overrides the final pin {fixed[k]!r}')
        elif k == 'SK_AXIOMS' and set(v.split()) != set(pins['allowed_axioms']):
            bad.append(f'SK_AXIOMS={v!r} differs from the standard three {pins["allowed_axioms"]}')
        elif k in ('SK_BUILD_DIRS', 'SK_EXPECT_DECLS', 'SK_POSITIVE_THEOREMS'):
            bad.append(f'{k} is not accepted by the final preset (inputs come only from the bound rebuild)')
        elif k in ('LEAN4EXPORT_EXE', 'NANODA_EXE', 'LEAN_TC', 'LEAN_EXE') and v:
            bad.append(f'{k} tool override is not accepted by the final preset')
    return bad


def cmd_final_overrides(a):
    pins = C.read_json_strict(a.pins)
    sets = dict(kv.partition('=')[::2] for kv in (a.set or []))
    bad = final_overrides(pins, sets)
    for b in bad:
        print(b)
    return 1 if bad else 0


def _mod_olean(m):
    if not all(re.match(r"^[A-Za-z_][A-Za-z0-9_']*$", p) for p in m.split('.')):
        raise C.VFError(f'unsafe module name {m!r}')
    return m.replace('.', '/') + '.olean'


_VT = None


def _vf_tool():
    global _VT
    if _VT is None:
        import importlib.util
        spec = importlib.util.spec_from_file_location('vf_tool', os.path.join(os.path.dirname(C.__file__), 'vf_tool.py'))
        _VT = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(_VT)
    return _VT


def _external_check(pkg_cache, lake_manifest, reference):
    """Re-inventory the external package objects used by lean4export (Mathlib etc.) and compare them exactly with a
    reference inventory: a list of {path relative to the package cache, sha256} rows, or a path to such a JSON file
    (only for our own rebuild's inventory, whose digest the caller has already checked)."""
    try:
        names = [p['name'] for p in C.read_json_strict(lake_manifest)['packages']]
        for n in names:
            C.check_safe_name(n, 'package name')
        have = {r['path']: r['sha256'] for r in _vf_tool()._object_inventory(os.path.abspath(pkg_cache), names)}
        rows = C.as_list(C.read_json_strict(reference)) if isinstance(reference, str) else reference
        want = {}
        for r in rows:
            p = r['path'].replace('\\', '/')
            if re.search(r'\.(olean|ilean)(\.|$)', p):
                if p in want:
                    raise C.VFError(f'duplicate external object row {p}')
                want[p] = r['sha256'].lower()
    except (C.VFError, OSError, ValueError, KeyError, TypeError, AttributeError) as e:
        return [f'external objects: {e}']
    if not want:
        return ['external objects: empty reference inventory']
    diff = sorted(set(want) ^ set(have)) + sorted(p for p in set(want) & set(have) if want[p] != have[p])
    return [f'external objects differ from the bound inventory ({len(diff)}), e.g. {diff[:5]}'] if diff else []


def bind_claude(vf, rebuild_dir, freeze_sha, pins_path, modules, pkg_cache):
    errs = []
    pins = C.read_json_strict(pins_path)
    try:
        C.check_safe_name(os.path.basename(os.path.normpath(rebuild_dir)), 'rebuild RUN_ID')
        C.assert_within(rebuild_dir, os.path.join(vf, 'rebuild'))
    except C.VFError as e:
        return None, [str(e)]
    vj = os.path.join(rebuild_dir, 'VERDICT.json')
    try:
        v = C.read_json_strict(vj)
    except (C.VFError, OSError, ValueError) as e:
        return None, [f'rebuild VERDICT.json unreadable: {e}']
    checks = v.get('checks') or {}
    want = [('scope', v.get('scope'), 'FINAL'), ('clean_build', (v.get('subverdicts') or {}).get('clean_build'), 'PASS'),
            ('axioms', (checks.get('axioms') or {}).get('status'), 'PASS'),
            ('pins', (checks.get('pins') or {}).get('status'), 'PASS'),
            ('freeze_manifest_sha256', v.get('freeze_manifest_sha256'), freeze_sha),
            ('statement_pins_sha256', v.get('statement_pins_sha256'), pins['statement_pins_sha256']),
            ('final_pins_sha256', v.get('final_pins_sha256'), C.sha256_file(pins_path))]
    for k, have, need in want:
        if have != need:
            errs.append(f'rebuild {k} = {have!r}, required {need!r}')
    fm = os.path.join(rebuild_dir, 'FREEZE_MANIFEST.copy')
    if not os.path.isfile(fm) or C.sha256_file(fm) != freeze_sha:
        errs.append('rebuild FREEZE_MANIFEST.copy does not have the independently supplied freeze sha256')
    else:
        # replay the exact frozen source tree the rebuild compiled (every row, no extra file) against the FREEZE bytes
        try:
            with open(fm, 'rb') as f:
                blob = f.read()
            if C.sha256_bytes(blob) != freeze_sha:
                raise C.VFError('FREEZE_MANIFEST.copy changed while reading')
            errs += [f'frozen source replay: {e}' for e in
                     C.verify_tree(C.parse_manifest_bytes(blob, fm), os.path.join(rebuild_dir, 'src'))]
        except (C.VFError, OSError, ValueError, UnicodeDecodeError) as e:
            errs.append(f'frozen source replay: {e}')
    try:
        ri = C.read_json_strict(os.path.join(rebuild_dir, 'RUN_INFO.json'))
        if ri.get('freeze_manifest_sha256') != freeze_sha or str(ri.get('self_manifest')) != '0':
            errs.append('rebuild RUN_INFO.json is not a FREEZE-bound (non-self-manifest) run of this freeze')
        rb = C.read_json_strict(os.path.join(rebuild_dir, 'RUN_BINDING.json'))
        if rb.get('external_objects_sha256') != v.get('external_objects_sha256'):
            errs.append('rebuild external-object inventory differs from the original attempt binding (RUN_BINDING.json)')
    except (C.VFError, OSError, ValueError) as e:
        errs.append(f'rebuild RUN_INFO.json / RUN_BINDING.json: {e}')
    objs = os.path.join(rebuild_dir, 'OBJECTS.json')
    build = os.path.join(rebuild_dir, 'build', 'lib', 'lean')
    ext = os.path.join(rebuild_dir, 'attempts', str(v.get('attempt')), 'checks', 'external-objects.json')
    if not os.path.isfile(ext) or C.sha256_file(ext) != v.get('external_objects_sha256'):
        errs.append('external-object inventory of the rebuild missing or not the one recorded in VERDICT.json')
    else:
        errs += _external_check(pkg_cache, os.path.join(rebuild_dir, 'src', 'lake-manifest.json'), ext)
    if not os.path.isfile(objs) or C.sha256_file(objs) != v.get('objects_sha256'):
        errs.append('OBJECTS.json missing or not the inventory recorded in VERDICT.json')
    else:
        errs += [f'objects: {e}' for e in _vf_tool().verify_objects(build, objs)]
        listed = {f['path'] for f in C.read_json_strict(objs)['files']}
        for m in modules:
            try:
                if _mod_olean(m) not in listed:
                    errs.append(f'module {m} is not an accepted object of the rebuild')
            except C.VFError as e:
                errs.append(str(e))
    bind = {'mode': 'claude-rebuild', 'rebuild_dir': os.path.abspath(rebuild_dir), 'build_dir': os.path.abspath(build),
            'freeze_sha256': freeze_sha, 'objects_sha256': C.sha256_file(objs) if os.path.isfile(objs) else None,
            'verdict_json_sha256': C.sha256_file(vj), 'rebuild_verdict': v.get('verdict'),
            'statement_pins_sha256': v.get('statement_pins_sha256'), 'modules': modules, 'vf': os.path.abspath(vf),
            'pkg_cache': os.path.abspath(pkg_cache), 'external_objects_sha256': v.get('external_objects_sha256')}
    return bind, errs


def bind_codex(snapshot, run_dir, freeze_sha, result_sha, pins_path, modules, pkg_cache):
    """Bind the export inputs to Codex's successful clean build.  The RESULT digest, its exact schema and its complete
    evidence inventory (membership, byte lengths, sha256) are verified BEFORE any inventory is read
    (vf_common.bind_codex_result, the same policy as Codex's reviewed archive path); the local and external object
    inventories are then taken from the evidence-verified bytes only, and the frozen source tree is replayed
    exactly against FREEZE.json."""
    pins = C.read_json_strict(pins_path)
    ctx, errs = C.bind_codex_result(snapshot, run_dir, freeze_sha, result_sha,
                                    lean_sha=(pins.get('tool_sha256') or {}).get('lean.exe'))
    if ctx is None:
        return None, errs
    build = os.path.join(snapshot, '.lake', 'build', 'lib', 'lean')
    try:
        C.assert_plain(build)
        want = {}
        for o in ctx['local_objects']:
            p = o['path'].replace('\\', '/')
            if not p.startswith('.lake/build/lib/lean/'):
                raise C.VFError(f'object outside the build dir: {p}')
            rel = p[len('.lake/build/lib/lean/'):]
            C.check_rel_path(rel, allow_objects=True)        # Windows path safety ('..', ADS, reserved names, ...)
            if rel in want or C.fold_key(rel) in {C.fold_key(x) for x in want}:
                raise C.VFError(f'duplicate object entry {rel}')
            if not isinstance(o.get('sha256'), str) or not C.HEX64.match(o['sha256']):
                raise C.VFError(f'object entry without a sha256: {rel}')
            want[rel] = o['sha256'].lower()
        present = [r for r in C.walk_files(build) if re.search(r'\.(olean|ilean)(\.|$)', r)]
        for r in present:
            if r not in want:
                errs.append(f'object not in the clean run inventory: {r}')
        for r, h in want.items():
            f = os.path.join(build, r)
            if not os.path.isfile(f) or C.sha256_file(f) != h:
                errs.append(f'object missing or changed since the clean run: {r}')
        for m in modules:
            if _mod_olean(m) not in want:
                errs.append(f'module {m} is not an object of the clean run')
        for t in ctx['targets']:
            if _mod_olean(t) not in want:
                errs.append(f'clean-run target {t} has no bound .olean')
    except (C.VFError, OSError, ValueError, KeyError, TypeError, AttributeError) as e:
        errs.append(f'clean object inventory: {e}')
    errs += _external_check(pkg_cache, os.path.join(snapshot, 'lake-manifest.json'), ctx['external_objects'])
    sp = os.path.join(os.path.dirname(os.path.abspath(pins_path)), '..', 'statement', 'StatementPins.lean')
    sp_sha = C.sha256_file(sp) if os.path.isfile(sp) else None
    if sp_sha != pins['statement_pins_sha256']:
        errs.append('statement pins file differs from the pinned, audited one')
    rows = ctx['rows']
    bind = {'mode': 'codex-clean', 'snapshot': os.path.abspath(snapshot), 'run_dir': os.path.abspath(run_dir),
            'build_dir': os.path.abspath(build), 'freeze_sha256': freeze_sha, 'result_sha256': result_sha,
            'evidence_sha256': ctx['evidence_sha256'], 'evidence_files': len(rows),
            'frozen_files': len(ctx['entries']), 'clean_targets': len(ctx['targets']),
            'local_objects_sha256': rows['local-objects.json']['sha256'],
            'external_objects_sha256': rows['external-objects-after.json']['sha256'],
            'statement_pins_sha256': sp_sha, 'modules': modules, 'pkg_cache': os.path.abspath(pkg_cache)}
    return bind, errs


def cmd_bind(a):
    mods = a.modules.split()
    if a.mode == 'claude-rebuild':
        bind, errs = bind_claude(a.vf, a.rebuild_dir, a.freeze_sha, a.pins, mods, a.pkg_cache)
    else:
        bind, errs = bind_codex(a.snapshot, a.run_dir, a.freeze_sha, a.result_sha, a.pins, mods, a.pkg_cache)
    if bind is not None and not errs:
        bind['final_pins_sha256'] = C.sha256_file(a.pins)
        C.write_json(a.out, bind)
        print(bind['build_dir'])
        return 0
    for e in errs:
        print('ERROR:', e, file=sys.stderr)
    return 1


def cmd_bind_verify(a):
    try:
        b = C.read_json_strict(a.bind)
    except (C.VFError, OSError, ValueError) as e:
        print('ERROR: bind record unreadable:', e); return 1
    if b.get('mode') == 'claude-rebuild':
        nb, errs = bind_claude(b['vf'], b['rebuild_dir'], b['freeze_sha256'], a.pins, b['modules'], b['pkg_cache'])
        keys = ('objects_sha256', 'verdict_json_sha256', 'build_dir', 'external_objects_sha256')
    elif b.get('mode') == 'codex-clean':
        nb, errs = bind_codex(b['snapshot'], b['run_dir'], b['freeze_sha256'], b['result_sha256'], a.pins, b['modules'],
                              b['pkg_cache'])
        keys = ('local_objects_sha256', 'build_dir', 'external_objects_sha256', 'evidence_sha256', 'evidence_files',
                'frozen_files', 'clean_targets')
    else:
        print('ERROR: unknown bind mode'); return 1
    if nb is not None:
        for k in keys:
            if nb.get(k) != b.get(k):
                errs.append(f'binding changed: {k}')
    if b.get('final_pins_sha256') != C.sha256_file(a.pins):
        errs.append('FINAL_PINS.json changed since binding')
    for e in errs:
        print('ERROR:', e)
    print('binding: ' + ('VALID' if not errs else 'INVALID'))
    return 1 if errs else 0


# ---- run manifest ----------------------------------------------------------------------------------------------
def _snapshot(a):
    tools = {}
    for kv in a.tool or []:
        k, _, p = kv.partition('=')
        tools[k] = C.sha256_file(p) if os.path.isfile(p) else None
    scripts = {os.path.basename(p): (C.sha256_file(p) if os.path.isfile(p) else None) for p in a.script or []}
    exp_first = None
    if os.path.isfile(a.export):
        with open(a.export, 'rb') as f:
            exp_first = f.readline().decode('utf-8', 'replace').strip()
    snap = {'schema': 1, 'preset': a.preset, 'scope': a.scope, 'modules': a.modules.split(),
            'theorems': a.theorems.split(), 'pp_declars': a.pp.split(), 'axioms': sorted(a.axioms.split()),
            'expect': a.expect, 'pp_regex': a.pp_regex,
            'export': {'sha256': C.sha256_file(a.export) if os.path.isfile(a.export) else None,
                       'bytes': os.path.getsize(a.export) if os.path.isfile(a.export) else None, 'meta': exp_first},
            'input_objects_list_sha256': C.sha256_file(a.olean_list) if os.path.isfile(a.olean_list) else None,
            'tools': tools, 'scripts': scripts, 'final_pins_sha256': C.sha256_file(a.pins),
            'tool_record_sha256': C.sha256_file(a.record) if a.record and os.path.isfile(a.record) else None,
            'bind_sha256': C.sha256_file(a.bind) if a.bind and os.path.isfile(a.bind) else None,
            'semantic_sites': {'sha256': SEMANTIC_SITES_SHA256, 'valid': default_sites()[0] is not None,
                               'file_sha256': C.sha256_file(SEMANTIC_SITES_FILE)
                               if os.path.isfile(SEMANTIC_SITES_FILE) else None},
            'nanoda_config': None}
    if a.config:
        try:
            raw = open(a.config, 'rb').read()
            snap['nanoda_config'] = {'sha256': C.sha256_bytes(raw), 'options': C.loads_strict(raw.decode('utf-8'), a.config)}
        except (OSError, ValueError, UnicodeDecodeError, C.VFError) as e:
            snap['nanoda_config'] = {'sha256': None, 'error': str(e)}
    return snap


def cmd_runmanifest(a):
    snap = _snapshot(a)
    if a.mode == 'create':
        if a.stats:
            st = C.read_json_strict(a.stats)
            if st.get('errors') or st.get('sha256') != snap['export']['sha256']:
                print('ERROR: export statistics invalid or not for this export'); return 1
            snap['export']['declarations'] = st['declarations']
            snap['export']['lines'] = st['lines']
        if snap['export']['sha256'] is None:
            print('ERROR: no export'); return 1
        if not snap['semantic_sites']['valid']:
            print('ERROR: the semantic-site whitelist is invalid'); return 1
        if a.config and not (snap['nanoda_config'] or {}).get('sha256'):
            print('ERROR: nanoda configuration unreadable'); return 1
        with open(a.manifest, 'x', encoding='utf-8', newline='\n') as f:
            f.write(json.dumps(snap, indent=1) + '\n')
        print('run manifest written')
        return 0
    try:
        old = C.read_json_strict(a.manifest)
    except (C.VFError, OSError, ValueError) as e:
        print('ERROR: run manifest unreadable:', e); return 1
    diffs = []
    for k, v in snap.items():
        ov = old.get(k)
        if k == 'export' and isinstance(ov, dict):
            ov = {x: ov.get(x) for x in ('sha256', 'bytes', 'meta')}
        if ov != v:
            diffs.append(f'{k}: recorded {json.dumps(ov)[:160]} now {json.dumps(v)[:160]}')
    for d in diffs:
        print('ERROR: run manifest mismatch:', d)
    print('run manifest: ' + ('VALID' if not diffs else 'INVALID'))
    if not diffs and a.print_decls:
        print(f'DECLS\t{(old.get("export") or {}).get("declarations")}')
    return 1 if diffs else 0


def main():
    ap = argparse.ArgumentParser()
    sp = ap.add_subparsers(dest='cmd', required=True)
    p = sp.add_parser('config'); p.add_argument('--export', required=True); p.add_argument('--out', required=True)
    p.add_argument('--pp', default=''); p.add_argument('--axioms', default='propext Classical.choice Quot.sound')
    p.add_argument('--exclusive', action='store_true')
    p = sp.add_parser('config-check'); p.add_argument('--config', required=True); p.add_argument('--export', required=True)
    p.add_argument('--pp', default=''); p.add_argument('--axioms', required=True); p.add_argument('--require-axioms')
    p.add_argument('--expect-sha')
    p = sp.add_parser('meta'); p.add_argument('--export', required=True); p.add_argument('--lean-commit', default='')
    p.add_argument('--format', default='3.1.0')
    p = sp.add_parser('stats'); p.add_argument('--export', required=True); p.add_argument('--out', required=True)
    p.add_argument('--decls', nargs='*'); p.add_argument('--lean-commit', default=''); p.add_argument('--format', default='3.1.0')
    p = sp.add_parser('classify'); p.add_argument('--journal', required=True); p.add_argument('--invocation', required=True)
    p.add_argument('--out', required=True); p.add_argument('--err', required=True); p.add_argument('--json')
    p.add_argument('--expected-decls', type=int)
    p = sp.add_parser('map-status'); p.add_argument('--result', required=True)
    p.add_argument('--role', required=True, choices=['accept', 'positive', 'reject', 'tamper'])
    p.add_argument('--reject-class', default='typecheck'); p.add_argument('--allowed-axioms')
    p = sp.add_parser('export-check'); p.add_argument('--journal', required=True); p.add_argument('--invocation', required=True)
    p.add_argument('--export', required=True); p.add_argument('--err', required=True); p.add_argument('--out', required=True)
    p.add_argument('--decls', nargs='*'); p.add_argument('--lean-commit', default=''); p.add_argument('--format', default='3.1.0')
    p = sp.add_parser('tamper'); p.add_argument('--export', required=True); p.add_argument('--old', required=True)
    p.add_argument('--new', required=True); p.add_argument('--out', required=True); p.add_argument('--all', action='store_true')
    p = sp.add_parser('result'); p.add_argument('--journal', required=True); p.add_argument('--out', required=True)
    p.add_argument('--field', action='append', default=[])
    p = sp.add_parser('pp-check'); p.add_argument('--out', required=True); p.add_argument('--regex', required=True)
    p.add_argument('--names', default='')
    p = sp.add_parser('control'); p.add_argument('--name', required=True); p.add_argument('--expect', required=True)
    p.add_argument('--result', required=True); p.add_argument('--controls', required=True); p.add_argument('--message-regex')
    p.add_argument('--expect-site')
    p = sp.add_parser('checkout-state'); p.add_argument('--export-dir', required=True)
    p.add_argument('--nanoda-dir', required=True); p.add_argument('--pins', required=True)
    p.add_argument('--phase', choices=['pre', 'post'], default='post'); p.add_argument('--out')
    p = sp.add_parser('record'); p.add_argument('--out', required=True); p.add_argument('--controls', required=True)
    p.add_argument('--pins', required=True); p.add_argument('--export-dir', required=True)
    p.add_argument('--nanoda-dir', required=True); p.add_argument('--lean4export-exe', required=True)
    p.add_argument('--nanoda-exe', required=True); p.add_argument('--lean-exe')
    p.add_argument('--stack-reserve', required=True); p.add_argument('--expected-stack', required=True)
    p.add_argument('--diff'); p.add_argument('--invocation-dir'); p.add_argument('--partial', action='store_true')
    p = sp.add_parser('verify-record'); p.add_argument('--record', required=True); p.add_argument('--pins', required=True)
    p.add_argument('--export-dir', required=True); p.add_argument('--nanoda-dir', required=True)
    p.add_argument('--lean4export-exe', required=True); p.add_argument('--nanoda-exe', required=True)
    p = sp.add_parser('final-overrides'); p.add_argument('--pins', required=True); p.add_argument('--set', action='append')
    p = sp.add_parser('sites-check'); p.add_argument('--pins', required=True)
    p = sp.add_parser('bind'); p.add_argument('--mode', required=True, choices=['claude-rebuild', 'codex-clean'])
    p.add_argument('--pins', required=True); p.add_argument('--freeze-sha', required=True)
    p.add_argument('--modules', required=True); p.add_argument('--out', required=True)
    p.add_argument('--vf'); p.add_argument('--rebuild-dir'); p.add_argument('--snapshot'); p.add_argument('--run-dir')
    p.add_argument('--result-sha'); p.add_argument('--pkg-cache', required=True)
    p = sp.add_parser('bind-verify'); p.add_argument('--bind', required=True); p.add_argument('--pins', required=True)
    p = sp.add_parser('runmanifest'); p.add_argument('--mode', required=True, choices=['create', 'verify'])
    for k in ('manifest', 'pins', 'preset', 'scope', 'modules', 'theorems', 'pp', 'axioms', 'expect', 'export',
              'olean-list'):
        p.add_argument('--' + k, required=True)
    p.add_argument('--pp-regex', default=''); p.add_argument('--record'); p.add_argument('--bind'); p.add_argument('--config')
    p.add_argument('--tool', action='append'); p.add_argument('--script', action='append'); p.add_argument('--stats')
    p.add_argument('--print-decls', action='store_true')
    a = ap.parse_args()
    if a.cmd == 'bind':
        need = ('vf', 'rebuild_dir') if a.mode == 'claude-rebuild' else ('snapshot', 'run_dir', 'result_sha')
        if any(getattr(a, k) is None for k in need):
            print(f'bind --mode {a.mode} needs ' + ', '.join('--' + k.replace('_', '-') for k in need)); return 2
        a.freeze_sha = a.freeze_sha.lower()
        if not C.HEX64.match(a.freeze_sha) or (a.result_sha and not C.HEX64.match(a.result_sha)):
            print('bind: digests must be 64 hex characters'); return 2
        a.result_sha = (a.result_sha or '').lower() or None
    return {'config': cmd_config, 'config-check': cmd_config_check, 'meta': cmd_meta, 'stats': cmd_stats,
            'classify': cmd_classify, 'tamper': cmd_tamper, 'sites-check': cmd_sites_check,
            'export-check': cmd_export_check, 'map-status': cmd_map_status,
            'result': cmd_result, 'pp-check': cmd_pp_check, 'control': cmd_control, 'checkout-state': cmd_checkout_state,
            'record': cmd_record, 'verify-record': cmd_verify_record, 'final-overrides': cmd_final_overrides,
            'bind': cmd_bind, 'bind-verify': cmd_bind_verify, 'runmanifest': cmd_runmanifest}[a.cmd](a)


if __name__ == '__main__':
    sys.exit(main())
