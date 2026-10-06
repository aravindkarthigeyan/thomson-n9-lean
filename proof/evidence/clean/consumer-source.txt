"""vf_common.py -- shared fail-closed helpers for the verify_final runners (pure Python 3.11+, no Lean, no Rust).

Used by vf_tool.py (run_final_verification.sh) and second_kernel/sk_tool.py (run/build_second_kernel.sh).
Nothing in this module deletes anything except `safe_remove_file`, which removes ONE regular file after a
canonical containment check.  There is no recursive removal anywhere in the verify_final tooling.

Status vocabulary (per check):
  PASS          the check ran to completion and its positive acceptance condition was observed
  REJECTED      a checker positively rejected the input with a recognised *semantic* diagnostic
                (kernel / type-checker rejection), after its input and configuration were read successfully
  FAILED        the check ran and its acceptance condition is violated for a non-kernel reason
                (compile error, sorry, hash mismatch, unapproved axiom, missing report, wrong statement, ...)
  INCONCLUSIVE  resource or platform failure (NTSTATUS crash, stack overflow, out of memory, kernel deep
                recursion, ...): neither acceptance nor rejection
  ERROR         tool / configuration / I-O failure, malformed input, unrecognised diagnostic or exit code
  SKIPPED       the check was not run (not requested, or a precondition was absent)
  UNFINISHED    the check was started or scheduled but stopped (stop file) or never reached
Aggregate over the considered checks (required + requested optional):
  any FAILED/REJECTED -> FAIL; else any ERROR -> ERROR; else any INCONCLUSIVE -> INCONCLUSIVE;
  else any SKIPPED/UNFINISHED/missing -> INCOMPLETE; else PASS.  An empty set of checks is INCOMPLETE.
The VERDICT text is the aggregate only for scope FINAL; any other scope is reported as '<SCOPE>:<aggregate>'
so that no non-final run can ever produce the bare word PASS.
"""
import hashlib
import json
import os
import re
import stat
import unicodedata
from pathlib import PurePosixPath

STATUSES = ('PASS', 'REJECTED', 'FAILED', 'INCONCLUSIVE', 'ERROR', 'SKIPPED', 'UNFINISHED')
AGGREGATES = ('PASS', 'FAIL', 'ERROR', 'INCONCLUSIVE', 'INCOMPLETE')
HEX64 = re.compile(r'^[0-9a-fA-F]{64}$')


class VFError(Exception):
    """A fail-closed precondition was violated (bad path, bad manifest, ...)."""


# ----------------------------------------------------------------------------------------------- hashing
def sha256_file(p):
    h = hashlib.sha256()
    with open(p, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def write_json(path, obj):
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(json.dumps(obj, indent=1, sort_keys=False) + '\n')


def loads_strict(text, label='json'):
    """json.loads that rejects duplicate object keys anywhere (json.loads silently keeps the last one)."""
    def hook(pairs):
        d = {}
        for k, v in pairs:
            if k in d:
                raise VFError(f'{label}: duplicate JSON key {k!r}')
            d[k] = v
        return d
    if text.startswith('﻿'):
        text = text[1:]
    return json.loads(text, object_pairs_hook=hook)


def read_json_strict(path):
    """json.load that rejects duplicate object keys anywhere (json.loads silently keeps the last one)."""
    with open(path, 'rb') as f:
        text = f.read().decode('utf-8-sig')
    return loads_strict(text, path)


# ----------------------------------------------------------------------------------------------- paths
FILE_ATTRIBUTE_REPARSE_POINT = 0x400
SAFE_NAME = re.compile(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$')
WIN_RESERVED = re.compile(r'^(CON|PRN|AUX|NUL|COM[0-9]|LPT[0-9]|CONIN\$|CONOUT\$)(\..*)?$', re.I)
WIN_BAD_CHARS = re.compile(r'[<>:"|?*\x00-\x1f]')


def is_reparse(p):
    """True if `p` itself is a symlink, junction or any other reparse point (does not follow it)."""
    try:
        st = os.lstat(p)
    except FileNotFoundError:
        return False
    return bool(getattr(st, 'st_file_attributes', 0) & FILE_ATTRIBUTE_REPARSE_POINT) or stat.S_ISLNK(st.st_mode)


def _norm(p):
    return os.path.normcase(os.path.abspath(p))


def canon(p):
    """Canonical absolute path: symlinks/junctions/'..' resolved, case folded (Windows)."""
    return os.path.normcase(os.path.realpath(os.path.abspath(p)))


def assert_plain(path):
    """Fail unless no existing component of `path`, up to the drive root, is a reparse point, and resolving the
    path does not move it (i.e. canonical == absolute, case-insensitively)."""
    a = os.path.abspath(path)
    cur = a
    while True:
        if is_reparse(cur):
            raise VFError(f'path traverses a reparse point (symlink/junction): {cur}')
        parent = os.path.dirname(cur)
        if parent == cur:
            break
        cur = parent
    if canon(a) != _norm(a):
        raise VFError(f'path does not resolve to itself: {a} -> {os.path.realpath(a)}')
    return a


def is_within(child, parent, allow_equal=False):
    c, p = canon(child), canon(parent)
    try:
        common = os.path.commonpath([c, p])
    except ValueError:          # different drives
        return False
    if common != p:
        return False
    return allow_equal or c != p


def assert_within(child, parent, allow_equal=False):
    """Canonical containment AND plain (reparse-free) chains for both paths.  Textual prefixes are never used."""
    assert_plain(parent)
    assert_plain(child)
    if not is_within(child, parent, allow_equal):
        raise VFError(f'{child} is not inside {parent} (canonical check)')
    return os.path.abspath(child)


def check_safe_name(name, what='name'):
    if not isinstance(name, str) or not SAFE_NAME.match(name) or '..' in name or WIN_RESERVED.match(name) \
            or name.endswith('.'):
        raise VFError(f'unsafe {what} {name!r}: need [A-Za-z0-9][A-Za-z0-9._-]{{0,79}}, no "..", '
                      f'no reserved device name, no trailing dot')
    return name


def make_new_dir(path, base):
    """Create `path` exclusively (it must not exist) after checking that its parent is a plain directory inside
    `base`.  Never reuses or removes an existing directory."""
    parent = os.path.dirname(os.path.abspath(path))
    assert_within(parent, base, allow_equal=True)
    if os.path.lexists(path):
        raise VFError(f'refusing to reuse existing path {path}; choose a new name')
    os.mkdir(path)            # exclusive: raises FileExistsError on a race
    assert_within(path, base)
    return os.path.abspath(path)


def safe_remove_file(path, base):
    """Remove ONE regular file inside `base` (canonical containment, no reparse points).  Missing file: no-op, but
    the containment check is made first, so an escaping path is an error even when nothing exists there."""
    assert_within(path, base)
    if not os.path.lexists(path):
        return False
    st = os.lstat(path)
    if not stat.S_ISREG(st.st_mode) or is_reparse(path):
        raise VFError(f'refusing to remove non-regular file {path}')
    os.remove(path)
    return True


def check_rel_path(raw, strip_prefixes=(), allow_objects=False):
    """Normalise and validate one manifest-relative path; raise VFError for anything unsafe on Windows.
    Source manifests (allow_objects=False) may not name .lake paths or build objects."""
    if not isinstance(raw, str) or not raw:
        raise VFError(f'empty or non-string manifest path {raw!r}')
    p = raw.replace('\\', '/')
    for pre in strip_prefixes:
        if p.startswith(pre):
            p = p[len(pre):]
            break
    if p.startswith('/') or re.match(r'^[A-Za-z]:', p) or p.startswith('//'):
        raise VFError(f'absolute manifest path {raw!r}')
    parts = p.split('/')
    for c in parts:
        if c in ('', '.', '..'):
            raise VFError(f'manifest path {raw!r} has an empty, "." or ".." component')
        if WIN_BAD_CHARS.search(c):
            raise VFError(f'manifest path {raw!r} has a Windows-invalid character (incl. ":" / alternate stream)')
        if c.endswith('.') or c.endswith(' ') or c.startswith(' '):
            raise VFError(f'manifest path {raw!r} has a component with a leading space or trailing dot/space')
        if WIN_RESERVED.match(c):
            raise VFError(f'manifest path {raw!r} uses a reserved Windows device name')
    if not allow_objects:
        if '.lake' in parts:
            raise VFError(f'manifest path {raw!r} is inside .lake (build objects must never be copied in)')
        if re.search(r'\.(olean|ilean|o|obj|ir|trace|hash|c)(\.|$)', parts[-1]):
            raise VFError(f'manifest path {raw!r} names a build object')
    if len(p) > 240:
        raise VFError(f'manifest path too long: {raw!r}')
    return str(PurePosixPath(p))


def fold_key(rel):
    return unicodedata.normalize('NFC', rel).casefold()


# ----------------------------------------------------------------------------------------------- manifests
def parse_manifest(path, strip_prefixes=('outputs/thomson-n9/lean/', './')):
    """Strict manifest parser.  Accepted shapes:
      * sha256sum text: '<64 hex> <space|*><path>' per line; blank lines and '#' comments allowed, anything else
        is an error;
      * JSON object with a 'files' list of {path, sha256[, bytes]} (Codex FREEZE.json schema 1);
      * JSON list of {path, sha256[, bytes]};
      * JSON object mapping path -> sha256 (every value must be a hash).
    Duplicate JSON keys, duplicate or case/Unicode-colliding normalised paths (even with equal hashes), bad
    hashes and unsafe paths are all errors.  Returns {rel: {'sha256': hex, 'bytes': int|None}} in input order."""
    with open(path, 'rb') as f:
        return parse_manifest_bytes(f.read(), path, strip_prefixes)


def parse_manifest_bytes(blob, path='manifest', strip_prefixes=('outputs/thomson-n9/lean/', './')):
    """parse_manifest on bytes already read (so that a caller can hash and parse the very same bytes)."""
    text = blob.decode('utf-8-sig')
    raw = []
    s = text.lstrip()
    if s.startswith('{') or s.startswith('['):
        data = loads_strict(text, path)
        items = None
        if isinstance(data, dict) and 'files' in data:
            items = data['files']
            if not isinstance(items, list):
                raise VFError(f'{path}: "files" is not a list')
        elif isinstance(data, list):
            items = data
        elif isinstance(data, dict) and data and all(isinstance(v, str) for v in data.values()):
            for k, v in data.items():
                raw.append((k, v, None))
        else:
            raise VFError(f'{path}: unsupported manifest JSON shape')
        if items is not None:
            for it in items:
                if not isinstance(it, dict) or not isinstance(it.get('path'), str) or not isinstance(it.get('sha256'), str):
                    raise VFError(f'{path}: manifest item without string path/sha256: {it!r}'[:300])
                b = it.get('bytes')
                if b is not None and (not isinstance(b, int) or isinstance(b, bool) or b < 0):
                    raise VFError(f'{path}: bad bytes field for {it.get("path")!r}')
                raw.append((it['path'], it['sha256'], b))
    else:
        for n, line in enumerate(text.splitlines(), 1):
            if not line.strip() or line.lstrip().startswith('#'):
                continue
            m = re.match(r'^([0-9a-fA-F]{64}) [ *](.+?)\r?$', line)
            if not m:
                raise VFError(f'{path}:{n}: not a "<sha256>  <path>" line: {line[:120]!r}')
            raw.append((m.group(2), m.group(1), None))
    if not raw:
        raise VFError(f'manifest {path}: no entries')
    entries, folded = {}, {}
    for r, h, b in raw:
        if not isinstance(h, str) or not HEX64.match(h):
            raise VFError(f'{path}: bad sha256 for {r!r}: {h!r}')
        rel = check_rel_path(r, strip_prefixes)
        if rel in entries:
            raise VFError(f'{path}: duplicate manifest entry {rel!r}')
        k = fold_key(rel)
        if k in folded:
            raise VFError(f'{path}: case/Unicode-colliding manifest entries {folded[k]!r} and {rel!r}')
        folded[k] = rel
        entries[rel] = {'sha256': h.lower(), 'bytes': b}
    return entries


def walk_files(root, skip_top=()):
    """All regular files under `root` as posix-relative paths, refusing any reparse point or special file.
    `skip_top`: names of TOP-LEVEL entries that are not entered at all (e.g. a Codex snapshot's '.lake' build/junction
    directory and its 'fresh-evidence' run directories, which are bound separately)."""
    assert_plain(root)
    out = []
    root = os.path.abspath(root)
    stack = [root]
    while stack:
        d = stack.pop()
        with os.scandir(d) as it:
            for e in it:
                full = os.path.join(d, e.name)
                if d == root and e.name in skip_top:
                    continue
                if is_reparse(full):
                    raise VFError(f'reparse point inside tree: {full}')
                if e.is_dir(follow_symlinks=False):
                    stack.append(full)
                elif e.is_file(follow_symlinks=False):
                    out.append(os.path.relpath(full, root).replace('\\', '/'))
                else:
                    raise VFError(f'special file inside tree: {full}')
    return sorted(out)


def verify_tree(entries, root, skip_top=(), extra_allowed=()):
    """Exact inventory check of `root` against manifest `entries`: every listed file present with the listed hash
    (and size if given), no other file (except the top-level names in `extra_allowed`, e.g. FREEZE.json itself),
    no reparse point.  Returns a list of error strings (empty = OK)."""
    errors = []
    try:
        files = walk_files(root, skip_top)
    except (VFError, OSError) as e:
        return [f'cannot inventory {root}: {e}']
    present = set(files)
    for rel, meta in entries.items():
        if rel not in present:
            errors.append(f'missing: {rel}')
            continue
        full = os.path.join(root, rel)
        if meta.get('bytes') is not None and os.path.getsize(full) != meta['bytes']:
            errors.append(f'size mismatch: {rel}')
        h = sha256_file(full)
        if h != meta['sha256']:
            errors.append(f'hash mismatch: {rel} expected {meta["sha256"]} actual {h}')
    for rel in files:
        if rel not in entries and rel not in extra_allowed:
            errors.append(f'unlisted file: {rel}')
    return errors


# ----------------------------------------------------------------------------------------------- Codex FREEZE / RESULT
# The binding policy below mirrors Codex's reviewed archive path (work/n9-lean-drafts/verification/archive_runner.py:
# verify_evidence_inventory and collect_clean), so that a Codex clean result is accepted here under the same rules.
FREEZE_SKIP_TOP = ('.lake', 'fresh-evidence')          # build objects/junction and run evidence: bound separately
RESULT_KEYS = ('status', 'claim', 'manifestSha256', 'modules', 'supplementalTests', 'stepsSha256', 'targetsSha256',
               'driverSha256', 'evidenceFiles', 'finalTheoremsChecked', 'completedUtc')
FREEZE_DRIVER = 'fresh-verification/FreezeRebuild.ps1'
CLEAN_FIXED_STEPS = ('default-targets', 'source-scanner-tests', 'source-audit', 'all-axioms', 'final-target-types',
                     'corrupt-coefficient')
_INT = lambda v: isinstance(v, int) and not isinstance(v, bool)


def load_freeze(path, expected_sha=None):
    """Codex FREEZE.json (schema 1), parsed from the very bytes that are hashed.  Every file row must carry path,
    sha256 and bytes; paths obey the strict manifest rules (no .lake, objects, traversal, ADS, devices, duplicates or
    case collisions); supplemental tests must name frozen files.  Returns (doc, entries, sha256)."""
    with open(path, 'rb') as f:
        raw = f.read()
    sha = sha256_bytes(raw)
    if expected_sha is not None and sha != expected_sha.lower():
        raise VFError(f'FREEZE.json sha256 {sha} != the independently supplied {expected_sha}')
    doc = loads_strict(raw.decode('utf-8-sig'), path)
    if not isinstance(doc, dict) or doc.get('schema') != 1 or not isinstance(doc.get('files'), list) or not doc['files']:
        raise VFError(f'{path}: not a schema-1 FREEZE manifest with a non-empty files list')
    for it in doc['files']:
        if not isinstance(it, dict) or not _INT(it.get('bytes')) or it['bytes'] < 0:
            raise VFError(f'{path}: FREEZE row without an integer bytes field: {it!r}'[:300])
    entries = parse_manifest_bytes(raw, path, strip_prefixes=())
    for t in doc.get('tests') or []:
        if not isinstance(t, dict) or t.get('path') not in entries or t.get('expectation') not in ('pass', 'reject'):
            raise VFError(f'{path}: supplemental test not bound to a frozen file: {t!r}'[:300])
    return doc, entries, sha


def replay_freeze(snapshot, entries):
    """Exact replay of a Codex snapshot against its FREEZE rows: every row present with its bytes and sha256 and
    NO other file anywhere except FREEZE.json itself (top-level .lake and fresh-evidence are bound separately)."""
    return verify_tree(entries, snapshot, skip_top=FREEZE_SKIP_TOP, extra_allowed=('FREEZE.json',))


def check_result_schema(result, freeze_sha, freeze_doc=None):
    """Exact schema of a successful FreezeRebuild.ps1 RESULT.json.  Returns a list of errors."""
    if not isinstance(result, dict):
        return ['RESULT.json is not an object']
    errs = []
    if sorted(result) != sorted(RESULT_KEYS):
        errs.append(f'RESULT keys {sorted(result)} != {sorted(RESULT_KEYS)}')
    if result.get('status') != 'PASS':
        errs.append(f'RESULT status {result.get("status")!r} != PASS')
    if not isinstance(result.get('manifestSha256'), str) or result['manifestSha256'].lower() != (freeze_sha or '').lower() \
            or not freeze_sha:
        errs.append('RESULT manifestSha256 is not the supplied freeze digest')
    if not _INT(result.get('modules')) or result['modules'] < 1:
        errs.append('RESULT modules is not a positive integer')
    if not _INT(result.get('supplementalTests')) or (
            freeze_doc is not None and result['supplementalTests'] != len(freeze_doc.get('tests') or [])):
        errs.append('RESULT supplementalTests does not equal the frozen test count')
    for k in ('stepsSha256', 'targetsSha256', 'driverSha256'):
        if not isinstance(result.get(k), str) or not HEX64.match(result[k]):
            errs.append(f'RESULT {k} is not a sha256')
    if result.get('finalTheoremsChecked') != 6 or not _INT(result.get('finalTheoremsChecked')):
        errs.append('RESULT finalTheoremsChecked != 6')
    ev = result.get('evidenceFiles')
    if not isinstance(ev, list) or not ev:
        errs.append('RESULT evidenceFiles is not a non-empty list')
    else:
        for it in ev:
            if not isinstance(it, dict) or sorted(it) != ['bytes', 'path', 'sha256'] or not isinstance(it['path'], str) \
                    or not _INT(it['bytes']) or it['bytes'] < 0 or not isinstance(it['sha256'], str) \
                    or not HEX64.match(it['sha256']):
                errs.append(f'RESULT evidence row is not exactly {{path, bytes, sha256}}: {it!r}'[:200])
    return errs


def evidence_rows(result):
    """{flat name: row} of RESULT.evidenceFiles; unsafe, nested, RESULT.json, duplicate or case-colliding names raise."""
    rows, folded = {}, set()
    for it in result['evidenceFiles']:
        name = it['path']
        if '/' in name or '\\' in name or name == 'RESULT.json':
            raise VFError(f'invalid flat evidence name {name!r}')
        check_rel_path(name, allow_objects=True)
        if fold_key(name) in folded:
            raise VFError(f'duplicate or case-colliding evidence name {name!r}')
        folded.add(fold_key(name))
        rows[name] = {'bytes': it['bytes'], 'sha256': it['sha256'].lower()}
    return rows


def verify_evidence_inventory(run_dir, rows):
    """The run directory must be flat and contain EXACTLY the evidence files (plus RESULT.json), each with the
    recorded byte length and sha256.  Returns a list of errors."""
    try:
        assert_plain(run_dir)
        names = []
        with os.scandir(run_dir) as it:
            for e in it:
                full = os.path.join(run_dir, e.name)
                if is_reparse(full) or not e.is_file(follow_symlinks=False):
                    return [f'fresh evidence must be a flat plain-file inventory: {full}']
                if e.name != 'RESULT.json':
                    names.append(e.name)
    except (VFError, OSError) as e:
        return [f'fresh evidence directory: {e}']
    if set(names) != set(rows):
        return [f'fresh evidence membership differs from RESULT.evidenceFiles: unlisted '
                f'{sorted(set(names) - set(rows))[:5]}, missing {sorted(set(rows) - set(names))[:5]}']
    errs = []
    for name, row in rows.items():
        p = os.path.join(run_dir, name)
        if os.path.getsize(p) != row['bytes']:
            errs.append(f'fresh evidence size changed: {name}')
        elif sha256_file(p) != row['sha256']:
            errs.append(f'fresh evidence hash changed: {name}')
    return errs


def read_bound_evidence(run_dir, rows, name):
    """Bytes of one evidence file, verified (length and sha256 of exactly these bytes) against its RESULT row."""
    if name not in rows:
        raise VFError(f'{name} is not listed in RESULT.evidenceFiles')
    with open(os.path.join(run_dir, name), 'rb') as f:
        data = f.read()
    if len(data) != rows[name]['bytes'] or sha256_bytes(data) != rows[name]['sha256']:
        raise VFError(f'{name} differs from its RESULT.evidenceFiles row (bytes/sha256)')
    return data


def as_list(v):
    """PowerShell ConvertTo-Json writes a one-element array as a bare object."""
    return [v] if isinstance(v, dict) else v


def verify_codex_result(run_dir, result_sha, freeze_sha, freeze_doc=None):
    """RESULT digest, exact schema, evidence membership/sizes/hashes.  Returns (result, rows, errors); rows is None
    (and nothing may be read from the run directory) unless the evidence inventory verified completely."""
    try:
        with open(os.path.join(run_dir, 'RESULT.json'), 'rb') as f:
            raw = f.read()
    except OSError as e:
        return None, None, [f'clean RESULT.json unreadable: {e}']
    if not result_sha or sha256_bytes(raw) != result_sha.lower():
        return None, None, ['clean RESULT.json sha256 differs from the supplied digest']
    try:
        result = loads_strict(raw.decode('utf-8-sig'), 'RESULT.json')
    except (ValueError, VFError, UnicodeDecodeError) as e:
        return None, None, [f'clean RESULT.json unparsable: {e}']
    errs = check_result_schema(result, freeze_sha, freeze_doc)
    if errs:
        return result, None, errs
    try:
        rows = evidence_rows(result)
    except VFError as e:
        return result, None, [str(e)]
    errs = verify_evidence_inventory(run_dir, rows)
    return result, (None if errs else rows), errs


def bind_codex_result(snapshot, run_dir, freeze_sha, result_sha, lean_sha=None):
    """Full binding of a Codex clean build (FreezeRebuild.ps1) BEFORE any of its inventories is used:
      1. snapshot plain; run directory a direct child of <snapshot>/fresh-evidence;
      2. FREEZE.json digest == supplied, strict schema, snapshotRoot == snapshot;
      3. RESULT.json digest == supplied, exact schema (status PASS, manifestSha256 == freeze, 6 final theorems);
      4. evidence: flat directory == RESULT.evidenceFiles exactly, every byte length and sha256;
      5. only then the bound inventories are read, each from bytes re-verified against its row: toolchain.json,
         targets.txt, steps.json, local-objects.json, external-objects-after.json;
      6. driver/toolchain/target/step cross-checks as in archive_runner.collect_clean (every frozen proof-source
         module built, every step passed with its logs bound, the frozen driver is the one that ran);
      7. exact replay of the frozen source tree against FREEZE.json (no missing, changed or extra file).
    Returns (ctx, errors).  ctx is None when an early step failed."""
    errs = []
    snapshot = os.path.abspath(snapshot)
    run_dir = os.path.abspath(run_dir)
    try:
        assert_plain(snapshot)
        assert_within(run_dir, os.path.join(snapshot, 'fresh-evidence'))
        if canon(os.path.dirname(run_dir)) != canon(os.path.join(snapshot, 'fresh-evidence')):
            raise VFError('the clean run directory must be a direct child of <snapshot>/fresh-evidence')
        doc, entries, fsha = load_freeze(os.path.join(snapshot, 'FREEZE.json'), freeze_sha)
    except (VFError, OSError, ValueError, UnicodeDecodeError) as e:
        return None, [f'freeze: {e}']
    if not isinstance(doc.get('snapshotRoot'), str) or canon(doc['snapshotRoot']) != canon(snapshot):
        errs.append('FREEZE snapshotRoot is not this snapshot')
    result, rows, rerrs = verify_codex_result(run_dir, result_sha, fsha, doc)
    if rerrs or rows is None:
        return None, errs + rerrs
    ctx = {'freeze': doc, 'entries': entries, 'freeze_sha256': fsha, 'result': result, 'rows': rows,
           'evidence_sha256': sha256_bytes(json.dumps(sorted((k, v['bytes'], v['sha256']) for k, v in rows.items()))
                                           .encode())}
    try:
        tool = loads_strict(read_bound_evidence(run_dir, rows, 'toolchain.json').decode('utf-8-sig'), 'toolchain.json')
        tbytes = read_bound_evidence(run_dir, rows, 'targets.txt')
        sbytes = read_bound_evidence(run_dir, rows, 'steps.json')
        steps = as_list(loads_strict(sbytes.decode('utf-8-sig'), 'steps.json'))
        ctx['local_objects'] = as_list(loads_strict(read_bound_evidence(run_dir, rows, 'local-objects.json')
                                                    .decode('utf-8-sig'), 'local-objects.json'))
        ctx['external_objects'] = as_list(loads_strict(read_bound_evidence(run_dir, rows, 'external-objects-after.json')
                                                       .decode('utf-8-sig'), 'external-objects-after.json'))
    except (VFError, OSError, ValueError, UnicodeDecodeError) as e:
        return None, errs + [f'bound evidence: {e}']
    drivers = [r for r in doc['files'] if r.get('path') == FREEZE_DRIVER]
    if len(drivers) != 1 or drivers[0].get('sha256', '').lower() != result['driverSha256'].lower():
        errs.append('clean RESULT driver does not match its frozen source row')
    if not isinstance(tool, dict) or str(tool.get('driverSha256', '')).lower() != result['driverSha256'].lower():
        errs.append('toolchain.json records a different driver')
    if not isinstance(tool, dict) or str(tool.get('leanSha256', '')).lower() != str(doc.get('leanSha256', '')).lower() \
            or (lean_sha is not None and str(tool.get('leanSha256', '')).lower() != lean_sha.lower()):
        errs.append('toolchain.json lean.exe sha256 differs from the FREEZE/pinned lean.exe')
    if sha256_bytes(tbytes) != result['targetsSha256'].lower() or sha256_bytes(sbytes) != result['stepsSha256'].lower():
        errs.append('targets.txt / steps.json differ from the RESULT digests')
    targets = [t.strip() for t in tbytes.decode('utf-8-sig').splitlines() if t.strip()]
    ctx['targets'] = targets
    if len(targets) != result['modules'] or len(set(targets)) != len(targets):
        errs.append('target inventory does not match RESULT modules (or has duplicates)')
    if not isinstance(steps, list) or not all(isinstance(s, dict) for s in steps):
        errs.append('steps.json is not a list of step reports')
        steps = []
    passed = {s.get('name') for s in steps if s.get('passed') is True}
    need = set(targets) | set(CLEAN_FIXED_STEPS) | {t['path'] for t in doc.get('tests') or []}
    if not need <= passed or not all(s.get('passed') is True for s in steps):
        errs.append(f'incomplete or failed clean-run steps: missing {sorted(need - passed)[:5]}')
    for s in steps:
        for k in ('stdout', 'stderr'):
            p = s.get(k)
            name = os.path.basename(str(p).replace('\\', '/')) if p else None
            if not name or name not in rows or rows[name]['sha256'] != str(s.get(k + 'Sha256', '')).lower() \
                    or canon(os.path.dirname(str(p))) != canon(run_dir):
                errs.append(f'step {s.get("name")!r} {k} log is not a bound evidence file of this run')
                break
    for r in doc['files']:
        rel = r['path']
        if rel.endswith('.lean') and not rel.startswith(('frozen-tests/', 'fresh-verification/')):
            mod = (rel[len('vendor/'):] if rel.startswith('vendor/') else rel)[:-len('.lean')].replace('/', '.')
            if mod not in targets:
                errs.append(f'frozen proof-source module {mod} was not built by the clean run')
    errs += [f'frozen source replay: {e}' for e in replay_freeze(snapshot, entries)]
    return ctx, errs


# ----------------------------------------------------------------------------------------------- journal
def journal_record(journal, invocation=None, step=None):
    """The run_step.py record with this invocation id (preferred) or the last record of `step`.
    Returns None when there is no such record (the caller must treat that as ERROR, never as success)."""
    if not journal or not os.path.exists(journal):
        return None
    rec = None
    with open(journal, encoding='utf-8') as f:
        for line in f:
            if not line.strip():
                continue
            try:
                r = json.loads(line)
            except ValueError:
                continue
            if invocation is not None:
                if r.get('invocation') == invocation:
                    rec = r
            elif r.get('step') == step:
                rec = r
    return rec


# ----------------------------------------------------------------------------------------------- exit codes
NTSTATUS = {
    0xC00000FD: 'STATUS_STACK_OVERFLOW',
    0xC0000409: 'STATUS_STACK_BUFFER_OVERRUN (fast-fail abort, e.g. after a failed allocation)',
    0xC0000005: 'STATUS_ACCESS_VIOLATION',
    0xC0000017: 'STATUS_NO_MEMORY',
    0xC000012D: 'STATUS_COMMITMENT_LIMIT',
    0xC000009A: 'STATUS_INSUFFICIENT_RESOURCES',
    0xC000013A: 'STATUS_CONTROL_C_EXIT',
    0xC0000142: 'STATUS_DLL_INIT_FAILED',
    0xC0000374: 'STATUS_HEAP_CORRUPTION',
    0xC000001D: 'STATUS_ILLEGAL_INSTRUCTION',
    0xC0000094: 'STATUS_INTEGER_DIVIDE_BY_ZERO',
    0xC0000420: 'STATUS_ASSERTION_FAILURE',
    0xC0000135: 'STATUS_DLL_NOT_FOUND',
    0xC0000139: 'STATUS_ENTRYPOINT_NOT_FOUND',
    0xC000007B: 'STATUS_INVALID_IMAGE_FORMAT',
}
TOOL_NTSTATUS = {0xC0000135, 0xC0000139, 0xC000007B}   # the executable could not be loaded: tool error


def ntstatus_class(rc):
    """None if rc is an ordinary exit code; else ('INCONCLUSIVE'|'ERROR', description)."""
    if rc is None:
        return None
    code = rc & 0xFFFFFFFF
    if code < 0xC0000000:
        return None
    desc = f'0x{code:08X} {NTSTATUS.get(code, "NTSTATUS")}'
    return ('ERROR', desc) if code in TOOL_NTSTATUS else ('INCONCLUSIVE', desc)


def record_preamble(rec):
    """Common classification of a run_step record: returns (status, reason) or None to continue."""
    if rec is None:
        return 'ERROR', 'no run_step journal record for this invocation (runner did not complete)'
    if rec.get('stopped_before_start'):
        return 'UNFINISHED', 'stop file present; step not started'
    if rec.get('launch_error'):
        return 'ERROR', f'could not start the tool: {rec["launch_error"]}'
    if rec.get('exit_code') is None:
        return 'ERROR', 'journal record has no exit code'
    nt = ntstatus_class(rec['exit_code'])
    if nt:
        return nt[0], f'process ended with {nt[1]}'
    return None


# ----------------------------------------------------------------------------------------------- Lean logs
LEAN_RESOURCE = [
    (re.compile(r'INTERNAL PANIC: out of memory'), 'Lean runtime: out of memory'),
    (re.compile(r'Stack overflow detected\. Aborting'), 'Lean runtime: stack overflow'),
    (re.compile(r'\(kernel\) deep recursion detected'), 'kernel deep recursion (native stack limit)'),
    (re.compile(r'\(kernel\) deterministic timeout'), 'kernel heartbeat limit'),
    (re.compile(r'\(kernel\) interrupted'), 'kernel interrupted'),
    (re.compile(r'(?i)\bout of memory\b|std::bad_alloc|memory allocation failed'), 'out of memory'),
]
LEAN_TOOL_ERRORS = [
    re.compile(r'Could not find any oleans for'), re.compile(r"object file '.*' of module \S+ does not exist"),
    re.compile(r'failed to read module data'), re.compile(r'Could not resolve module'),
    re.compile(r'incompatible header'), re.compile(r'unknown module prefix'), re.compile(r'unknown package'),
    re.compile(r'file not found'), re.compile(r'usage: lean --run CheckOne'),
]
LEAN_ERROR_DIAG = re.compile(r'(?m)^(?:[^\n]*?:\d+:\d+: error\b|error:)')
LEAN_SORRY = re.compile(r"declaration uses 'sorry'")
KERNEL_REJECT = re.compile(r'\(kernel\) (?!deep recursion detected|deterministic timeout|interrupted)\S')


def classify_lean(kind, rec, log, module=None):
    """Classify one Lean-toolchain step from its run_step record and its combined log text.
    kind: 'build' (lean -o), 'check' (lean on a check file), 'leanchecker' (bundled leanchecker -v [--fresh]),
          'checkone' (lean --run CheckOne.lean).  Returns (status, reason)."""
    pre = record_preamble(rec)
    if pre:
        return pre
    rc = rec['exit_code']
    log = (log or '').replace('\r', '')
    for rx, why in LEAN_RESOURCE:
        if rx.search(log):
            return 'INCONCLUSIVE', why
    if kind in ('build', 'check'):
        diag = LEAN_ERROR_DIAG.search(log)
        sorry = LEAN_SORRY.search(log)
        if rc == 0:
            if diag:
                return 'FAILED', 'exit 0 but an error diagnostic is present: ' + diag.group(0)[:200]
            if sorry:
                return 'FAILED', "declaration uses 'sorry'"
            return 'PASS', 'exit 0, no error diagnostic, no sorry'
        if diag:
            return 'FAILED', f'exit {rc}: ' + log[diag.start():diag.start() + 300].split('\n')[0]
        for rx in LEAN_TOOL_ERRORS:
            if rx.search(log):
                return 'ERROR', f'exit {rc}: tool/input error: {rx.pattern}'
        return 'ERROR', f'exit {rc} without a Lean error diagnostic'
    if kind in ('leanchecker', 'checkone'):
        problem = re.search(r'(?:leanchecker|checkone) found a problem in (\S+)', log)
        kern = KERNEL_REJECT.search(log)
        uncaught = 'uncaught exception' in log
        if rc == 0:
            if problem or kern or uncaught:
                return 'ERROR', 'exit 0 but the log reports a problem (inconsistent output)'
            if kind == 'leanchecker':
                ok = module is None or re.search(r'(?m)^replaying ' + re.escape(module) + r'(\s|$)', log)
                if ok and 'replaying ' in log:
                    return 'PASS', 'exit 0 and replay of the module reported'
                return 'ERROR', 'exit 0 but no "replaying <module>" line (unexpected output)'
            ok = module is None or re.search(r'(?m)^checkone: ' + re.escape(module) + r': \d+ constants in module, replay OK',
                                             log)
            if ok and 'replay OK' in log:
                return 'PASS', 'exit 0 and "replay OK" reported'
            return 'ERROR', 'exit 0 but no "replay OK" line (unexpected output)'
        for rx in LEAN_TOOL_ERRORS:
            if rx.search(log):
                return 'ERROR', f'exit {rc}: tool/input error: {rx.pattern}'
        if kern:
            line = log[kern.start():].split('\n')[0]
            who = f' in {problem.group(1)}' if problem else ''
            return 'REJECTED', f'kernel rejection{who}: {line[:200]}'
        return 'ERROR', f'exit {rc} without a recognised kernel rejection'
    return 'ERROR', f'unknown classification kind {kind!r}'


# ----------------------------------------------------------------------------------------------- verdicts
def aggregate(statuses, considered):
    """Aggregate per-check statuses over `considered` (missing = UNFINISHED, unknown = ERROR)."""
    if not considered:
        return 'INCOMPLETE'
    vals = []
    for c in considered:
        v = statuses.get(c, 'UNFINISHED')
        vals.append(v if v in STATUSES else 'ERROR')
    if any(v in ('FAILED', 'REJECTED') for v in vals):
        return 'FAIL'
    if 'ERROR' in vals:
        return 'ERROR'
    if 'INCONCLUSIVE' in vals:
        return 'INCONCLUSIVE'
    if any(v in ('SKIPPED', 'UNFINISHED') for v in vals):
        return 'INCOMPLETE'
    return 'PASS'


def verdict_text(scope, agg):
    return agg if scope == 'FINAL' else f'{scope}:{agg}'


def exit_code_for(scope, agg):
    """0 final PASS; 4 non-final PASS; 1 FAIL; 5 INCONCLUSIVE; 6 ERROR; 3 INCOMPLETE."""
    if agg == 'PASS':
        return 0 if scope == 'FINAL' else 4
    return {'FAIL': 1, 'INCONCLUSIVE': 5, 'ERROR': 6, 'INCOMPLETE': 3}.get(agg, 6)
