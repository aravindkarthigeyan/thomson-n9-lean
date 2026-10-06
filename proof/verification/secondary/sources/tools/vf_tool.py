"""Helpers for run_final_verification.sh (pure Python 3.11+, no Lean).  Writes only where told to.
Fail-closed: every subcommand exits non-zero (or prints a non-PASS status) when an input is missing, unreadable,
ambiguous or inconsistent.  Shared logic (paths, manifests, classification, verdicts) lives in vf_common.py.

Subcommands
  pathcheck   --base B --path P [--new-dir] [--allow-equal]     canonical containment + reparse check; --new-dir
              creates P exclusively (it must not exist).  Prints the absolute path.  Exit 2 on violation.
  safename    NAME [--what W]                                 validate a RUN_ID-like single safe name
  rmfile      --base B --path P        remove ONE regular file inside B after the canonical containment check
  copy        --manifest M --src SRC --dst DST --base B [--report R.json]
              strict manifest; DST must not exist (created exclusively inside B); every file verified in SRC,
              copied with exclusive create, re-verified; exact inventory of DST checked afterwards.
  selfmanifest --src SRC --out M      (only for non-final dry runs without a Codex manifest)
  verify-tree --manifest M --root DIR [--out R.json]   exact inventory: listed hashes, no extra file, no reparse.
  manifest-sha --manifest M          print sha256 of the manifest file and the number of entries (validated)
  deps        --lake-manifest F --cache DIR --pins P [--out deps.json] [--objects-out O.json]
              [--objects-manifest CODEX.json --objects-result-sha S --objects-freeze-sha F] [--compare O0.json]
              every package: git type, plain path, readable HEAD == manifest rev, clean tracked tree, no untracked
              .lean; mathlib == pinned rev; optional object hashes.  Missing/unreadable HEAD is a FAIL.  A Codex
              inventory is used only through its RESULT.json (digest, exact schema, complete evidence inventory) and
              is parsed from the very bytes RESULT.evidenceFiles records.
  run-binding --mode create|verify --file RUN_BINDING.json --external O.json --lean-exe X --leanchecker-exe X
              --checkone X --toolchain-bin D --lake-manifest F --deps deps.json --pins P
              first attempt: bind external objects, toolchain, lake-manifest, dependency HEADs; resume: must be equal
  lakefile-check --lakefile F        exactly moreLeanArgs = ["-j1"] (or none); no other compile/module-set keys
  modules     --root DST --out modules.tsv [--heavy-bytes N] [--heavy-regex RE]     (applies the lakefile policy)
  scan        --root DST --modules modules.tsv --out scan.json
  finals      --root DST [--file Solution.lean] [--modules modules.tsv] [--require NAME=TYPE ...]
  uptodate    --run-root R --module M --src-file F --lean-sha S --args A --deps D --ext-sha E
              exit 0: reuse (every recorded object/log/dependency hash and the run-bound external-object inventory
              hash re-verified); exit 1: rebuild (stale outputs of this module removed one file at a time inside
              R/build); exit 2: error.
  record-module --run-root R --module M --src-file F --lean-sha S --args A --deps D --ext-sha E --log L
  objects     --run-root R --modules modules.tsv --out OBJECTS.json [--olean-txt OLEAN_SHA256.txt]
  verify-objects --root DIR --objects OBJECTS.json
  classify    --kind build|check|leanchecker|checkone --journal J --invocation ID --log L [--module M]
              prints "<STATUS>\t<reason>" (always exit 0; ERROR when anything is missing)
  axioms      --log LOG [--expect NAME ...] [--expect-file F] [--min-reports N] [--allowed A ...] [--out axioms.json]
  pins-check  --log LOG --pins FINAL_PINS.json      required Part-5 lines and axiom reports present
  final-config --pins P --script-dir D [--lean-exe X] [--leanchecker-exe X] [--checkone X]
              [--final-theorems "..."] [--statement-pins F]     prints one non-final reason per line
  verdict     --status STATUS.tsv --required a,b,.. [--requested x,..] --scope S [--reason R ...]
              --out-dir D [--extra k=v ...]          writes VERDICT + VERDICT.json; exit code per vf_common
  gate        --journal J [--journal J2 ...] --step S [--floor 8] [--margin 6]
  summary     --journal J --out S.json
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tomllib
from collections import Counter
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vf_common as C  # noqa: E402

DEFAULT_ALLOWED_AXIOMS = ('propext', 'Classical.choice', 'Quot.sound')
REQUIRED_PKG_FILES = ('lakefile.toml', 'lean-toolchain', 'lake-manifest.json')
MODULE_COMPONENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_']*$")


def die(msg, code=2):
    print('ERROR:', msg, file=sys.stderr)
    return code


# ----------------------------------------------------------------------------------------------- paths
def cmd_rmfile(a):
    """Remove one regular file inside --base (canonical containment); used for scratch copies only."""
    try:
        C.safe_remove_file(a.path, a.base)
    except (C.VFError, OSError) as e:
        return die(str(e))
    return 0


def cmd_safename(a):
    try:
        C.check_safe_name(a.name, a.what)
    except C.VFError as e:
        return die(str(e))
    return 0


def cmd_pathcheck(a):
    try:
        if a.new_dir:
            p = C.make_new_dir(a.path, a.base)
        else:
            p = C.assert_within(a.path, a.base, allow_equal=a.allow_equal)
    except (C.VFError, OSError) as e:
        return die(str(e))
    print(p)
    return 0


# ----------------------------------------------------------------------------------------------- manifests
def cmd_copy(a):
    try:
        entries = C.parse_manifest(a.manifest)
    except (C.VFError, OSError, ValueError) as e:
        return die(f'manifest: {e}', 1)
    src = os.path.abspath(a.src)
    report = {'manifest': os.path.abspath(a.manifest), 'manifest_sha256': C.sha256_file(a.manifest),
              'entries': len(entries), 'files': [], 'errors': []}
    for need in REQUIRED_PKG_FILES:
        if need not in entries:
            report['errors'].append(f'manifest lacks required file {need}')
    try:
        C.assert_plain(src)
        dst = C.make_new_dir(a.dst, a.base)
    except (C.VFError, OSError) as e:
        report['errors'].append(str(e))
        dst = None
    if dst and not report['errors']:
        for rel, meta in entries.items():
            s = os.path.join(src, rel)
            try:
                C.assert_within(s, src)
            except C.VFError as e:
                report['errors'].append(f'source {rel}: {e}')
                continue
            if not os.path.isfile(s):
                report['errors'].append(f'missing in source: {rel}')
                continue
            hs = C.sha256_file(s)
            if hs != meta['sha256']:
                report['errors'].append(f'hash mismatch in source: {rel} manifest={meta["sha256"]} actual={hs}')
                continue
            d = os.path.join(dst, rel)
            os.makedirs(os.path.dirname(d), exist_ok=True)
            try:
                C.assert_within(os.path.dirname(d), dst, allow_equal=True)
                with open(s, 'rb') as fi, open(d, 'xb') as fo:      # exclusive create: never overwrite
                    for chunk in iter(lambda: fi.read(1 << 20), b''):
                        fo.write(chunk)
            except (C.VFError, OSError) as e:
                report['errors'].append(f'copy {rel}: {e}')
                continue
            report['files'].append({'path': rel, 'sha256': meta['sha256'], 'bytes': os.path.getsize(d)})
        if not report['errors']:
            report['errors'] += [f'post-copy inventory: {e}' for e in C.verify_tree(entries, dst)]
    # .lean files present in the source but absent from the manifest (informational; they are never copied)
    unlisted = []
    try:
        for r in _walk_src(src):
            if r.endswith('.lean') and r not in entries:
                unlisted.append(r)
    except (C.VFError, OSError) as e:
        report['errors'].append(f'source walk: {e}')
    report['unlisted_source_lean_files'] = sorted(unlisted)
    if a.report:
        C.write_json(a.report, report)
    print(f'copied {len(report["files"])}/{len(entries)} files; {len(unlisted)} .lean files in source not in manifest '
          f'(not copied)')
    for e in report['errors']:
        print('ERROR:', e)
    return 1 if report['errors'] else 0


def _walk_src(src):
    """Source walk that skips .lake (Codex snapshots contain a .lake/packages junction) and never follows links."""
    out, stack = [], [src]
    while stack:
        d = stack.pop()
        with os.scandir(d) as it:
            for e in it:
                full = os.path.join(d, e.name)
                rel = os.path.relpath(full, src).replace('\\', '/')
                if rel == '.lake' or rel.startswith('.lake/') or rel == '.git':
                    continue
                if C.is_reparse(full):
                    continue
                if e.is_dir(follow_symlinks=False):
                    stack.append(full)
                elif e.is_file(follow_symlinks=False):
                    out.append(rel)
    return out


def cmd_selfmanifest(a):
    src = os.path.abspath(a.src)
    lines = []
    for r in sorted(_walk_src(src)):
        if r.endswith('.lean') or r in REQUIRED_PKG_FILES:
            lines.append(f'{C.sha256_file(os.path.join(src, r))}  {r}')
    with open(a.out, 'x', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(lines) + '\n')
    print(f'self-generated manifest with {len(lines)} entries -> {a.out} (NON-FINAL: not an independent freeze)')
    return 0


def cmd_verify_tree(a):
    try:
        entries = C.parse_manifest(a.manifest)
    except (C.VFError, OSError, ValueError) as e:
        return die(f'manifest: {e}', 1)
    errors = C.verify_tree(entries, a.root)
    if a.out:
        C.write_json(a.out, {'manifest_sha256': C.sha256_file(a.manifest), 'root': os.path.abspath(a.root),
                             'entries': len(entries), 'errors': errors})
    print(f'verify-tree: {len(entries)} manifest entries, {len(errors)} problems')
    for e in errors[:100]:
        print('ERROR:', e)
    return 1 if errors else 0


def cmd_manifest_sha(a):
    try:
        entries = C.parse_manifest(a.manifest)
    except (C.VFError, OSError, ValueError) as e:
        return die(f'manifest: {e}', 1)
    print(f'{C.sha256_file(a.manifest)}\t{len(entries)}')
    return 0


# ----------------------------------------------------------------------------------------------- dependencies
def _git(path, *args):
    try:
        p = subprocess.run(['git', '-C', path, *args], capture_output=True, text=True, timeout=600)
    except (OSError, subprocess.TimeoutExpired) as e:
        return None, str(e)
    if p.returncode != 0:
        return None, (p.stderr or p.stdout).strip()[:300]
    return p.stdout, None


def _object_inventory(cache, names):
    rows = []
    for n in names:
        lib = os.path.join(cache, n, '.lake', 'build', 'lib', 'lean')
        if not os.path.isdir(lib):
            continue
        for r in C.walk_files(lib):
            if re.search(r'\.(olean|ilean)(\.|$)', r):
                full = os.path.join(lib, r)
                rows.append({'path': f'{n}/.lake/build/lib/lean/{r}', 'bytes': os.path.getsize(full),
                             'sha256': C.sha256_file(full)})
    return sorted(rows, key=lambda x: x['path'])


def cmd_deps(a):
    rows, errors = [], []
    pins = C.read_json_strict(a.pins)
    try:
        man = C.read_json_strict(a.lake_manifest)
        pkgs = man['packages']
        if not isinstance(pkgs, list):
            raise C.VFError('packages is not a list')
    except (C.VFError, OSError, ValueError, KeyError) as e:
        return die(f'lake-manifest: {e}', 1)
    cache = os.path.abspath(a.cache)
    try:
        C.assert_plain(cache)
    except C.VFError as e:
        errors.append(str(e))
    names = []
    for p in pkgs:
        name, rev, typ = p.get('name'), p.get('rev'), p.get('type')
        row = {'name': name, 'manifest_rev': rev, 'type': typ, 'ok': False}
        rows.append(row)
        try:
            C.check_safe_name(name, 'package name')
        except C.VFError as e:
            row['error'] = str(e); errors.append(str(e)); continue
        names.append(name)
        if typ != 'git':
            row['error'] = 'only pinned git dependencies are supported'; errors.append(f'{name}: {row["error"]}'); continue
        if not isinstance(rev, str) or not re.match(r'^[0-9a-f]{40}$', rev):
            row['error'] = 'manifest rev is not a 40-hex commit'; errors.append(f'{name}: {row["error"]}'); continue
        path = os.path.join(cache, name)
        try:
            C.assert_within(path, cache)
        except C.VFError as e:
            row['error'] = str(e); errors.append(f'{name}: {e}'); continue
        if not os.path.isdir(path):
            row['error'] = 'package checkout missing'; errors.append(f'{name}: package checkout missing'); continue
        out, err = _git(path, 'rev-parse', 'HEAD')
        head = (out or '').strip()
        row['head'] = head or None
        if err is not None or not re.match(r'^[0-9a-f]{40}$', head):
            row['error'] = f'HEAD unreadable ({err or head!r}): counted as FAILURE, not as a match'
            errors.append(f'{name}: {row["error"]}'); continue
        if head != rev:
            row['error'] = f'HEAD {head} != manifest {rev}'; errors.append(f'{name}: {row["error"]}'); continue
        out, err = _git(path, 'status', '--porcelain', '--untracked-files=no')
        if err is not None or (out or '').strip():
            row['error'] = f'tracked tree not clean or unreadable: {(err or out).strip()[:200]}'
            errors.append(f'{name}: {row["error"]}'); continue
        out, err = _git(path, 'ls-files', '--others', '--exclude-standard', '--', '*.lean')
        if err is not None or (out or '').strip():
            row['error'] = f'untracked .lean sources or unreadable: {(err or out).strip()[:200]}'
            errors.append(f'{name}: {row["error"]}'); continue
        row['ok'] = True
    mrow = next((r for r in rows if r['name'] == 'mathlib'), None)
    if mrow is None or mrow.get('manifest_rev') != pins['mathlib_rev']:
        errors.append(f'mathlib manifest rev {mrow and mrow.get("manifest_rev")} != pinned {pins["mathlib_rev"]}')
    res = {'cache': cache, 'packages': rows, 'errors': errors}
    if a.objects_out or a.objects_manifest or a.compare:
        try:
            inv = _object_inventory(cache, names)
        except (C.VFError, OSError) as e:
            inv = None
            errors.append(f'object inventory: {e}')
        if inv is not None:
            res['object_count'] = len(inv)
            if a.objects_out:
                C.write_json(a.objects_out, inv)
            for label, ref in (('objects-manifest', a.objects_manifest), ('compare', a.compare)):
                if not ref:
                    continue
                try:
                    if label == 'objects-manifest':
                        # a Codex inventory is used only through its successful RESULT: digest, exact schema and the
                        # complete evidence inventory are verified first, and the rows are parsed from the very bytes
                        # whose length and sha256 RESULT.evidenceFiles records
                        rdir = os.path.dirname(os.path.abspath(ref))
                        _, erows, rerrs = C.verify_codex_result(rdir, a.objects_result_sha, a.objects_freeze_sha)
                        if rerrs or erows is None:
                            raise C.VFError('not bound to a successful Codex RESULT: ' + '; '.join(rerrs)[:300])
                        data = C.as_list(C.loads_strict(C.read_bound_evidence(rdir, erows, os.path.basename(ref))
                                                        .decode('utf-8-sig'), ref))
                    else:
                        data = C.read_json_strict(ref)
                    want = {}
                    for r in data:
                        p = r['path'].replace('\\', '/')
                        if p in want:
                            raise C.VFError(f'duplicate row {p}')
                        want[p] = r['sha256'].lower()
                except (C.VFError, OSError, ValueError, KeyError, TypeError, AttributeError, UnicodeDecodeError) as e:
                    errors.append(f'{label} {ref}: unreadable or unbound ({e})'); continue
                have = {r['path']: r['sha256'] for r in inv}
                diff = sorted(set(want) ^ set(have)) + sorted(p for p in set(want) & set(have) if want[p] != have[p])
                if diff:
                    errors.append(f'{label}: {len(diff)} external objects differ, e.g. {diff[:5]}')
                res[f'{label}_checked'] = len(want)
    if a.out:
        C.write_json(a.out, res)
    for r in rows:
        print(f"  {str(r['name']):18s} manifest {str(r.get('manifest_rev'))[:12]}  cache {str(r.get('head'))[:12]}  "
              f"{'ok' if r['ok'] else 'FAIL: ' + r.get('error', '')}")
    for e in errors:
        print('ERROR:', e)
    return 1 if errors else 0


def _run_binding_snapshot(a):
    """Identity of everything outside the frozen sources that a reused object depends on: the external
    (Mathlib/...) object inventory, lean.exe/leanchecker/CheckOne, the pinned toolchain DLLs, the frozen
    lake-manifest and the dependency checkout HEADs."""
    pins = C.read_json_strict(a.pins)
    h = lambda p: C.sha256_file(p) if p and os.path.isfile(p) else None
    snap = {'schema': 1, 'external_objects_sha256': h(a.external), 'external_objects_count': None,
            'lean_sha256': h(a.lean_exe), 'leanchecker_sha256': h(a.leanchecker_exe), 'checkone_sha256': h(a.checkone),
            'toolchain_dll_sha256': {d: h(os.path.join(a.toolchain_bin, d)) for d in sorted(pins.get('toolchain_dll_sha256', {}))},
            'lake_manifest_sha256': h(a.lake_manifest), 'dependency_heads': None}
    try:
        snap['external_objects_count'] = len(C.read_json_strict(a.external))
    except (C.VFError, OSError, ValueError, TypeError):
        pass
    try:
        snap['dependency_heads'] = {r['name']: r.get('head') for r in C.read_json_strict(a.deps)['packages']}
    except (C.VFError, OSError, ValueError, KeyError, TypeError):
        pass
    return snap


def cmd_run_binding(a):
    """create: write RUN_BINDING.json exclusively at the first attempt; verify: on resume, every recorded identity must
    be unchanged (otherwise no object of the run may be reused; the caller fails closed and a new run is needed)."""
    snap = _run_binding_snapshot(a)
    if a.mode == 'create':
        missing = [k for k, v in snap.items() if v is None]
        if missing:
            return die(f'run binding incomplete: {missing}', 1)
        try:
            with open(a.file, 'x', encoding='utf-8', newline='\n') as f:
                f.write(json.dumps(snap, indent=1) + '\n')
        except OSError as e:
            return die(f'run binding: {e}', 1)
        print(f'run binding written: external objects {snap["external_objects_sha256"][:16]} '
              f'({snap["external_objects_count"]} files), lean {snap["lean_sha256"][:16]}')
        return 0
    try:
        old = C.read_json_strict(a.file)
    except (C.VFError, OSError, ValueError) as e:
        return die(f'original run binding unreadable: {e}', 1)
    diffs = [k for k in sorted(set(old) | set(snap)) if old.get(k) != snap.get(k)]
    for k in diffs:
        print(f'ERROR: run binding changed since the original attempt: {k}: {json.dumps(old.get(k))[:120]} -> '
              f'{json.dumps(snap.get(k))[:120]}')
    print('run binding: ' + ('UNCHANGED' if not diffs else 'CHANGED'))
    return 1 if diffs else 0


# ----------------------------------------------------------------------------------------------- lean source
def strip_comments_strings(text):
    """Remove nested block comments, line comments and string/char literals (replaced by spaces, newlines kept)."""
    out, i, n, depth = [], 0, len(text), 0
    while i < n:
        c = text[i]
        if depth:
            if text.startswith('/-', i):
                depth += 1; out.append('  '); i += 2; continue
            if text.startswith('-/', i):
                depth -= 1; out.append('  '); i += 2; continue
            out.append('\n' if c == '\n' else ' '); i += 1; continue
        if text.startswith('/-', i):
            depth = 1; out.append('  '); i += 2; continue
        if text.startswith('--', i):
            j = text.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i)); i = j; continue
        if c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == '\\' else 1
            seg = text[i:j + 1]
            out.append(''.join('\n' if ch == '\n' else ' ' for ch in seg)); i = j + 1; continue
        out.append(c); i += 1
    return ''.join(out)


IMPORT_RE = re.compile(r'^\s*(?:public\s+|private\s+)?(?:meta\s+)?import\s+(?:all\s+)?(.+)$')


def header_imports(text):
    code = strip_comments_strings(text)
    imports = []
    for line in code.splitlines():
        s = line.strip()
        if not s or s in ('prelude', 'module'):
            continue
        m = IMPORT_RE.match(line)
        if m:
            imports += m.group(1).split()
            continue
        break  # first non-header command
    return imports


# lakefile.toml policy (fail closed).  The only accepted compiler option is the single-worker resource control
# moreLeanArgs = ["-j1"] at package level (Codex's delivered package); the runner passes -j1 explicitly to every Lean
# invocation anyway, so no lakefile argument is forwarded.  Any leanOptions / weakLeanArgs / other moreLeanArgs, at
# package or library level, and any key that could change compilation or the module set (roots, globs,
# precompileModules, buildType, ...) are rejected.
LAKE_PKG_KEYS = {'name', 'version', 'description', 'keywords', 'homepage', 'license', 'licenseFiles', 'readmeFile',
                 'defaultTargets', 'moreLeanArgs', 'require', 'lean_lib'}
LAKE_LIB_KEYS = {'name', 'srcDir'}
LAKE_REQUIRE_KEYS = {'name', 'scope', 'git', 'rev'}
LAKE_ALLOWED_MORE_LEAN_ARGS = ['-j1']


def lakefile_errors(lake):
    """Return the lakefile policy violations (empty list = accepted)."""
    errs = []
    for k in sorted(set(lake) - LAKE_PKG_KEYS):
        errs.append(f'lakefile key {k!r} is not accepted (only {sorted(LAKE_PKG_KEYS)})')
    if 'moreLeanArgs' in lake and lake['moreLeanArgs'] != LAKE_ALLOWED_MORE_LEAN_ARGS:
        errs.append(f'moreLeanArgs = {lake["moreLeanArgs"]!r}: only exactly {LAKE_ALLOWED_MORE_LEAN_ARGS!r} is accepted')
    reqs = lake.get('require', [])
    if not isinstance(reqs, list):
        errs.append('require is not an array of tables')
        reqs = []
    for r in reqs:
        if not isinstance(r, dict) or set(r) - LAKE_REQUIRE_KEYS or not re.match(r'^[0-9a-f]{40}$', str(r.get('rev', ''))):
            errs.append(f'require entry {r!r} must have only {sorted(LAKE_REQUIRE_KEYS)} and a 40-hex rev'[:200])
    libs = lake.get('lean_lib', [])
    if not isinstance(libs, list):
        errs.append('lean_lib is not an array of tables')
        libs = []
    for lib in libs:
        if not isinstance(lib, dict):
            errs.append('lean_lib entry is not a table'); continue
        for k in sorted(set(lib) - LAKE_LIB_KEYS):
            errs.append(f'lean_lib {lib.get("name")!r}: key {k!r} is not accepted (leanOptions/moreLeanArgs/'
                        f'weakLeanArgs/roots/globs/... change compilation or the module set; only {sorted(LAKE_LIB_KEYS)})')
    return errs


def cmd_lakefile_check(a):
    try:
        lake = tomllib.loads(Path(a.lakefile).read_text(encoding='utf-8'))
    except (OSError, tomllib.TOMLDecodeError) as e:
        return die(f'lakefile: {e}', 1)
    errs = lakefile_errors(lake)
    for e in errs:
        print('ERROR:', e)
    print('lakefile: ' + ('ACCEPTED' if not errs else 'REJECTED'))
    return 1 if errs else 0


def cmd_modules(a):
    root = os.path.abspath(a.root)
    try:
        C.assert_plain(root)
        lake = tomllib.loads(Path(root, 'lakefile.toml').read_text(encoding='utf-8'))
    except (C.VFError, OSError, tomllib.TOMLDecodeError) as e:
        return die(f'lakefile: {e}', 1)
    errors = lakefile_errors(lake)
    libs = {}
    for lib in lake.get('lean_lib', []) if isinstance(lake.get('lean_lib', []), list) else []:
        if not isinstance(lib, dict):
            continue
        name = lib.get('name')
        if not isinstance(name, str) or not all(MODULE_COMPONENT.match(c) for c in name.split('.')):
            errors.append(f'unsupported lean_lib name {name!r}'); continue
        if name in libs:
            errors.append(f'duplicate lean_lib {name}'); continue
        libs[name] = lib

    def opt_args(lib):
        # nothing is forwarded: the only accepted lakefile argument is -j1, which the runner passes explicitly
        return []
    mods, folded = {}, {}
    for name, lib in libs.items():
        sd = lib.get('srcDir', '.')
        try:
            if sd != '.':
                C.check_rel_path(sd)
            srcdir = os.path.abspath(os.path.join(root, sd))
            C.assert_within(srcdir, root, allow_equal=True)
        except C.VFError as e:
            errors.append(f'lean_lib {name}: srcDir {sd!r}: {e}'); continue
        cands = []
        top = os.path.join(srcdir, *name.split('.')) + '.lean'
        if os.path.isfile(top):
            cands.append(top)
        sub = os.path.join(srcdir, *name.split('.'))
        if os.path.isdir(sub):
            try:
                cands += [os.path.join(sub, r) for r in C.walk_files(sub) if r.endswith('.lean')]
            except C.VFError as e:
                errors.append(f'lean_lib {name}: {e}'); continue
        for f in cands:
            rel = os.path.relpath(f, srcdir).replace('\\', '/')[:-len('.lean')]
            parts = rel.split('/')
            if not all(MODULE_COMPONENT.match(c) for c in parts):
                errors.append(f'unsupported module file name {rel}.lean (fail closed)'); continue
            mod = '.'.join(parts)
            if mod in mods:
                errors.append(f'module {mod} provided twice'); continue
            k = mod.casefold()
            if k in folded:
                errors.append(f'modules {folded[k]} and {mod} collide case-insensitively (same .olean path on Windows)')
                continue
            folded[k] = mod
            mods[mod] = {'lib': name, 'srcdir': sd, 'file': os.path.relpath(f, root).replace('\\', '/'),
                         'bytes': os.path.getsize(f), 'args': opt_args(lib),
                         'imports': header_imports(Path(f).read_text(encoding='utf-8-sig'))}
    for m, d in mods.items():
        d['local'] = []
        for imp in d['imports']:
            if imp in mods:
                d['local'].append(imp)
            elif imp.split('.')[0] in libs:
                errors.append(f'{m} imports {imp}, which is a local library module missing from the copy')
    order, state = [], {}

    def visit(m, stack):
        if state.get(m) == 2:
            return
        if state.get(m) == 1:
            raise SystemExit('import cycle: ' + ' -> '.join(stack + [m]))
        state[m] = 1
        for dep in mods[m]['local']:
            visit(dep, stack + [m])
        state[m] = 2
        order.append(m)
    for m in sorted(mods):
        visit(m, [])
    heavy_re = re.compile(a.heavy_regex) if a.heavy_regex else None
    names = set(mods)
    with open(a.out, 'w', encoding='utf-8', newline='\n') as out:
        for m in order:
            d = mods[m]
            if any('\t' in x or '\n' in x for x in d['args']):
                errors.append(f'{m}: lean argument with tab/newline'); continue
            heavy = int(d['bytes'] >= a.heavy_bytes or bool(heavy_re and heavy_re.search(m)))
            children = int(any(o != m and o.startswith(m + '.') for o in names))
            out.write('\t'.join([m, d['srcdir'], d['file'], str(d['bytes']), str(heavy), str(children),
                                 ','.join(d['local']) or '-', ' '.join(d['args']) or '-']) + '\n')
    print(f'{len(order)} library modules')
    if not order:
        errors.append('no library modules found')
    for e in errors:
        print('ERROR:', e)
    return 1 if errors else 0


HARD = [
    (r'\bsorry\b', 'sorry'), (r'\badmit\b', 'admit'), (r'(?<![\w.])axiom\b', 'axiom declaration'),
    (r'\bnative_decide\b', 'native_decide'), (r'\+\s*native\b|\bnative\s*:=\s*true', 'decide +native'),
    (r'\bimplemented_by\b', 'implemented_by'), (r'@\[\s*extern\b|\bextern\b', 'extern'),
    (r'\bofReduceBool\b|\bofReduceNat\b|\breduceBool\b|\breduceNat\b', 'Lean.ofReduceBool/Nat'),
    (r'\btrustCompiler\b', 'Lean.trustCompiler'), (r'\bunsafe\b', 'unsafe'),
    (r'\bdebug\.skipKernelTC\b', 'debug.skipKernelTC'), (r'\bdebug\.byAsSorry\b', 'debug.byAsSorry'),
    (r'\bsorryAx\b', 'sorryAx'), (r'addDeclCore|addDeclWithoutChecking|Kernel\.Environment\.add\b|setCheckedSync',
                                   'kernel-bypassing environment API'),
    (r'#exit\b', '#exit'),
]
SOFT = [
    (r'^\s*(?:public\s+)?(?:meta\s+)?import\s+Lean\b', 'imports Lean (metaprogramming)'),
    (r'\brun_cmd\b|\brun_elab\b|\brun_meta\b|#eval\b', 'command-time evaluation'),
    (r'^\s*(?:@\[[^\]]*\]\s*)?(?:elab|elab_rules|macro|macro_rules|syntax|initialize|builtin_initialize)\b',
     'syntax/elaborator extension'),
    (r'\bopaque\b', 'opaque'), (r'\bpartial\s+def\b', 'partial def (skipped by kernel replay)'),
    (r'\binclude_str\b|\bIO\.FS\b', 'file access at elaboration time'),
    (r'set_option\s+(?:debug|trace\.compiler|compiler)\S*', 'debug/compiler option'),
]


def cmd_scan(a):
    root = Path(a.root)
    rows = [l.rstrip('\n').split('\t') for l in open(a.modules, encoding='utf-8') if l.strip()]
    if not rows:
        return die('no modules to scan', 1)
    hard, soft = [], []
    for r in rows:
        f = root / r[2]
        raw = f.read_text(encoding='utf-8-sig')
        code = strip_comments_strings(raw)
        for ln, line in enumerate(code.splitlines(), 1):
            for pat, label in HARD:
                if re.search(pat, line):
                    hard.append({'file': r[2], 'line': ln, 'kind': label, 'text': raw.splitlines()[ln - 1].strip()[:200]})
            for pat, label in SOFT:
                if re.search(pat, line):
                    soft.append({'file': r[2], 'line': ln, 'kind': label, 'text': raw.splitlines()[ln - 1].strip()[:200]})
    res = {'files_scanned': len(rows), 'hard_hits': hard, 'soft_hits': soft,
           'hard_patterns': [p for p, _ in HARD], 'soft_patterns': [p for p, _ in SOFT]}
    C.write_json(a.out, res)
    print(f'scanned {len(rows)} module sources: {len(hard)} forbidden hits, {len(soft)} review-level hits')
    for h in hard[:50]:
        print('FORBIDDEN', h['file'], h['line'], h['kind'], '|', h['text'])
    for k, v in Counter(h['kind'] for h in soft).most_common():
        print(f'  review: {v} x {k}')
    return 1 if hard else 0


def cmd_finals(a):
    """Challenge-facing theorems: statement (text up to `:=`) mentions `Challenge.`.  --require NAME=TYPE forces a
    pinned theorem into the list (with its exact target), whether or not the textual scan found it."""
    root = Path(a.root)
    files = [a.file]
    if a.modules:
        files += [l.split('\t')[2] for l in open(a.modules, encoding='utf-8') if l.strip()]
    decl = re.compile(r'^(?:@\[[^\]]*\]\s*)?(?:protected\s+)?theorem\s+(\S+)')
    names = {}
    for rel in dict.fromkeys(files):
        f = root / rel
        if not f.is_file():
            continue
        lines = strip_comments_strings(f.read_text(encoding='utf-8-sig')).splitlines()
        scopes = []
        for i, line in enumerate(lines):
            m = re.match(r'^namespace\s+(\S+)', line)
            if m:
                scopes.append(m.group(1)); continue
            if re.match(r'^(?:noncomputable\s+|public\s+)?section\b', line):
                scopes.append(''); continue
            if re.match(r'^end\b', line) and scopes:
                scopes.pop(); continue
            m = decl.match(line)
            if not m:
                continue
            stmt = []
            for l2 in lines[i:i + 40]:
                stmt.append(l2)
                if ':=' in l2 or re.search(r'\bby\b', l2) or re.search(r'\bwhere\b', l2):
                    break
            s = ' '.join(stmt)
            if 'Challenge.' not in s.split(':=')[0]:
                continue
            ns = '.'.join(x for x in scopes if x)
            n = m.group(1)
            full = n if n.startswith('ThomsonN9.') or not ns else ns + '.' + n
            t = re.match(r'^\s*(?:@\[[^\]]*\]\s*)?(?:protected\s+)?theorem\s+\S+\s*:\s*(\S+)\s*:=', s)
            target = '-'
            if t and 'Challenge.' in t.group(1):
                target = t.group(1)
                if not target.startswith('ThomsonN9.') and ns:
                    target = ns + '.' + target
            names.setdefault(full, (target, rel))
    for req in a.require or []:
        n, _, t = req.partition('=')
        names[n] = (t or '-', 'Solution.lean')
    for n, (t, rel) in names.items():
        print(f'{n}\t{t}\t{rel}')
    return 0 if names else 1


# ----------------------------------------------------------------------------------------------- objects
def _mod_rel(module):
    parts = module.split('.')
    if not parts or not all(MODULE_COMPONENT.match(p) for p in parts):
        raise C.VFError(f'unsafe module name {module!r}')
    return '/'.join(parts)


def _module_outputs(build_root, module):
    """Current output files of `module` under build_root: <rel>.olean, <rel>.olean.*, <rel>.ilean."""
    rel = _mod_rel(module)
    d = os.path.join(build_root, os.path.dirname(rel))
    stem = os.path.basename(rel)
    out = {}
    if not os.path.isdir(d):
        return out
    for e in os.scandir(d):
        if e.name == stem + '.olean' or e.name.startswith(stem + '.olean.') or e.name == stem + '.ilean':
            full = os.path.join(d, e.name)
            if C.is_reparse(full) or not e.is_file(follow_symlinks=False):
                raise C.VFError(f'non-regular object {full}')
            out[(os.path.dirname(rel) + '/' if os.path.dirname(rel) else '') + e.name] = C.sha256_file(full)
    return out


def _deps_list(s):
    return [d for d in (s or '').split(',') if d and d != '-']


def _dep_hashes(build_root, deps):
    res = {}
    for d in deps:
        p = os.path.join(build_root, _mod_rel(d) + '.olean')
        res[d] = C.sha256_file(p) if os.path.isfile(p) else None
    return res


def _paths(a):
    run = os.path.abspath(a.run_root)
    return run, os.path.join(run, 'build', 'lib', 'lean'), os.path.join(run, 'build', 'ok', a.module + '.ok')


def cmd_uptodate(a):
    try:
        run, broot, okf = _paths(a)
        C.assert_plain(run)
        reason = None
        rec = None
        if not os.path.isfile(okf):
            reason = 'no accepted-build record'
        else:
            try:
                rec = C.read_json_strict(okf)
            except (C.VFError, ValueError) as e:
                reason = f'unreadable record: {e}'
        if reason is None:
            src_sha = C.sha256_file(a.src_file)
            deps = _deps_list(a.deps)
            cur_out = _module_outputs(broot, a.module)
            checks = [
                (rec.get('module') == a.module and rec.get('status') == 'PASS', 'record is not an accepted build'),
                (rec.get('src_sha256') == src_sha, 'source hash changed'),
                (rec.get('lean_sha256') == a.lean_sha, 'lean.exe hash changed'),
                (bool(a.ext_sha) and rec.get('external_objects_sha256') == a.ext_sha,
                 'external-object inventory (imported Mathlib/... objects) changed or unavailable'),
                (rec.get('args') == a.args, 'lean arguments changed'),
                (sorted((rec.get('deps') or {}).keys()) == sorted(deps), 'dependency list changed'),
                (rec.get('deps') == _dep_hashes(broot, deps), 'a dependency object changed (dependents rebuilt)'),
                (bool(rec.get('outputs')) and rec.get('outputs') == cur_out, 'object files missing or changed'),
                (any(k.endswith('.olean') for k in cur_out), 'no .olean'),
            ]
            for ok, why in checks:
                if not ok:
                    reason = why
                    break
            if reason is None:
                log = os.path.join(run, rec.get('log', ''))
                if not rec.get('log') or not os.path.isfile(log):
                    reason = 'build log missing'
                else:
                    C.assert_within(log, run)
                    if C.sha256_file(log) != rec.get('log_sha256'):
                        reason = 'build log changed'
                    else:
                        txt = Path(log).read_text(encoding='utf-8', errors='replace')
                        if C.LEAN_ERROR_DIAG.search(txt) or C.LEAN_SORRY.search(txt):
                            reason = 'build log contains an error or sorry'
        if reason is None:
            print(f'reuse {a.module}: source, objects, log, lean, arguments and dependency hashes re-verified')
            return 0
        removed = []
        for rel in list(_module_outputs(broot, a.module)):
            if C.safe_remove_file(os.path.join(broot, rel), os.path.join(run, 'build')):
                removed.append(rel)
        if C.safe_remove_file(okf, os.path.join(run, 'build')):
            removed.append(os.path.relpath(okf, run))
        print(f'rebuild {a.module}: {reason}' + (f' (removed stale: {", ".join(removed)})' if removed else ''))
        return 1
    except (C.VFError, OSError) as e:
        return die(f'uptodate {a.module}: {e}')


def cmd_record_module(a):
    try:
        run, broot, okf = _paths(a)
        C.assert_within(okf, run)
        C.assert_within(a.log, run)
        deps = _deps_list(a.deps)
        outs = _module_outputs(broot, a.module)
        if not any(k.endswith('.olean') for k in outs):
            return die(f'{a.module}: no .olean produced', 1)
        dh = _dep_hashes(broot, deps)
        if any(v is None for v in dh.values()):
            return die(f'{a.module}: dependency object missing: {dh}', 1)
        rec = {'module': a.module, 'status': 'PASS', 'src_file': os.path.relpath(a.src_file, run).replace('\\', '/'),
               'src_sha256': C.sha256_file(a.src_file), 'lean_sha256': a.lean_sha, 'args': a.args, 'deps': dh,
               'external_objects_sha256': a.ext_sha or None,
               'outputs': outs, 'log': os.path.relpath(a.log, run).replace('\\', '/'),
               'log_sha256': C.sha256_file(a.log)}
        os.makedirs(os.path.dirname(okf), exist_ok=True)
        C.write_json(okf, rec)
        return 0
    except (C.VFError, OSError) as e:
        return die(f'record-module {a.module}: {e}')


def cmd_objects(a):
    run = os.path.abspath(a.run_root)
    broot = os.path.join(run, 'build', 'lib', 'lean')
    errors, files, olean_lines = [], {}, []
    mods = [l.rstrip('\n').split('\t') for l in open(a.modules, encoding='utf-8') if l.strip()]
    for row in mods:
        m = row[0]
        okf = os.path.join(run, 'build', 'ok', m + '.ok')
        try:
            rec = C.read_json_strict(okf)
            cur = _module_outputs(broot, m)
        except (C.VFError, OSError, ValueError) as e:
            errors.append(f'{m}: {e}'); continue
        if rec.get('status') != 'PASS' or rec.get('outputs') != cur:
            errors.append(f'{m}: objects differ from the accepted-build record'); continue
        if C.sha256_file(os.path.join(run, 'src', row[2])) != rec.get('src_sha256'):
            errors.append(f'{m}: source differs from the accepted-build record'); continue
        for rel, h in cur.items():
            files[rel] = {'path': rel, 'sha256': h, 'bytes': os.path.getsize(os.path.join(broot, rel)), 'module': m}
        olean = next(k for k in cur if k.endswith('.olean'))
        olean_lines.append(f"{rec['src_sha256']} {cur[olean]} {m}")
    try:
        present = C.walk_files(broot)
    except (C.VFError, OSError) as e:
        present = []
        errors.append(f'inventory: {e}')
    for rel in present:
        if rel not in files:
            errors.append(f'unexpected file in build tree (not an accepted module output): {rel}')
    res = {'schema': 1, 'root': 'build/lib/lean', 'modules': len(mods),
           'files': [files[k] for k in sorted(files)], 'errors': errors}
    C.write_json(a.out, res)
    if a.olean_txt:
        with open(a.olean_txt, 'w', encoding='utf-8', newline='\n') as f:
            f.write('\n'.join(sorted(olean_lines, key=lambda s: s.split()[2])) + '\n')
    print(f'objects: {len(files)} files of {len(mods)} modules; {len(errors)} problems')
    for e in errors[:50]:
        print('ERROR:', e)
    return 1 if errors else 0


def verify_objects(root, objects_json):
    """Exact inventory check of `root` against an OBJECTS.json written by `objects`.  Returns error list."""
    try:
        obj = C.read_json_strict(objects_json)
        want = {f['path']: f['sha256'] for f in obj['files']}
        if obj.get('errors'):
            return [f'{objects_json} records errors: {obj["errors"][:3]}']
    except (C.VFError, OSError, ValueError, KeyError, TypeError) as e:
        return [f'{objects_json}: {e}']
    errors = []
    try:
        present = C.walk_files(root)
    except (C.VFError, OSError) as e:
        return [f'inventory: {e}']
    for rel in present:
        if rel not in want:
            errors.append(f'unlisted object: {rel}')
    for rel, h in want.items():
        p = os.path.join(root, rel)
        if not os.path.isfile(p):
            errors.append(f'missing object: {rel}')
        elif C.sha256_file(p) != h:
            errors.append(f'changed object: {rel}')
    if not want:
        errors.append('empty object inventory')
    return errors


def cmd_verify_objects(a):
    errors = verify_objects(a.root, a.objects)
    print(f'verify-objects: {len(errors)} problems')
    for e in errors[:50]:
        print('ERROR:', e)
    return 1 if errors else 0


# ----------------------------------------------------------------------------------------------- classify / axioms
def cmd_classify(a):
    rec = C.journal_record(a.journal, invocation=a.invocation)
    log = ''
    if a.log and os.path.exists(a.log):
        log = Path(a.log).read_text(encoding='utf-8', errors='replace')
    elif rec is not None and not rec.get('stopped_before_start') and not rec.get('launch_error'):
        print('ERROR\tstep log missing')
        return 0
    st, why = C.classify_lean(a.kind, rec, log, a.module)
    print(f'{st}\t{why}')
    return 0


def parse_axiom_reports(text):
    reports = {}
    for m in re.finditer(r"'(\S+?)' depends on axioms: \[(.*?)\]", text, re.S):
        reports.setdefault(m.group(1), set()).update(
            x.strip() for x in m.group(2).replace('\n', ' ').split(',') if x.strip())
    for m in re.finditer(r"'(\S+?)' does not depend on any axioms", text):
        reports.setdefault(m.group(1), set())
    return reports


def cmd_axioms(a):
    try:
        text = Path(a.log).read_text(encoding='utf-8', errors='replace')
    except OSError as e:
        return die(f'axiom log unreadable: {e}', 1)
    allowed = set(a.allowed or DEFAULT_ALLOWED_AXIOMS)
    reports = parse_axiom_reports(text)       # repeated reports for one name are united, never overwritten
    bad = {n: sorted(x for x in ax if x not in allowed) for n, ax in reports.items()}
    bad = {n: v for n, v in bad.items() if v}
    expect = list(a.expect or [])
    if a.expect_file:
        expect += [l.strip() for l in open(a.expect_file, encoding='utf-8-sig') if l.strip()]
    missing = [n for n in expect if n not in reports]
    too_few = len(reports) < max(a.min_reports, 1)
    res = {'log': a.log, 'reports': len(reports), 'unapproved': bad, 'missing_expected': missing,
           'expected': len(expect), 'min_reports': a.min_reports, 'allowed': sorted(allowed)}
    if a.out:
        C.write_json(a.out, res)
    print(f'{len(reports)} axiom reports; {len(bad)} with unapproved axioms; {len(missing)} expected names missing')
    for n, v in list(bad.items())[:50]:
        print('UNAPPROVED', n, v)
    for n in missing:
        print('MISSING REPORT', n)
    if too_few:
        print(f'TOO FEW REPORTS: {len(reports)} < {max(a.min_reports, 1)}')
    return 1 if bad or missing or too_few else 0


def cmd_pins_check(a):
    pins = C.read_json_strict(a.pins)
    text = Path(a.log).read_text(encoding='utf-8', errors='replace') if os.path.exists(a.log) else ''
    errs = [f'missing line: {l}' for l in pins['statement_pins_required_lines'] if l not in text]
    reps = parse_axiom_reports(text)
    allowed = set(pins['allowed_axioms'])
    for n in pins['statement_pins_axiom_reports']:
        if n not in reps:
            errs.append(f'missing axiom report: {n}')
        elif not reps[n] <= allowed:
            errs.append(f'unapproved axioms for {n}: {sorted(reps[n] - allowed)}')
    for n, ax in reps.items():
        if not ax <= allowed:
            errs.append(f'unapproved axioms for {n}: {sorted(ax - allowed)}')
    print('PASS' if not errs else 'FAILED\t' + '; '.join(errs))
    return 0 if not errs else 1


# ----------------------------------------------------------------------------------------------- scope / verdict
def cmd_final_config(a):
    """Print one reason per line why this configuration is NOT the pinned final configuration."""
    pins = C.read_json_strict(a.pins)
    reasons = []
    tools = pins['tool_sha256']
    for label, path in (('lean.exe', a.lean_exe), ('leanchecker.exe', a.leanchecker_exe), ('CheckOne.lean', a.checkone)):
        if path is None:
            continue
        try:
            h = C.sha256_file(path)
        except OSError as e:
            reasons.append(f'{label} unreadable: {e}'); continue
        if h != tools[label]:
            reasons.append(f'{label} sha256 {h[:16]} != pinned {tools[label][:16]}')
    if a.toolchain_bin is not None:
        for dll, want in pins.get('toolchain_dll_sha256', {}).items():
            p = os.path.join(a.toolchain_bin, dll)
            if not os.path.isfile(p):
                reasons.append(f'toolchain {dll} missing')
            elif C.sha256_file(p) != want:
                reasons.append(f'toolchain {dll} sha256 differs from the pin')
    if a.final_theorems is not None and a.final_theorems.split() and a.final_theorems.split() != [pins['target_theorem']]:
        reasons.append(f'FINAL_THEOREMS override {a.final_theorems!r} != pinned {pins["target_theorem"]}')
    if a.statement_pins is not None:
        if not os.path.isfile(a.statement_pins):
            reasons.append('statement pins file missing')
        elif C.sha256_file(a.statement_pins) != pins['statement_pins_sha256']:
            reasons.append('statement pins sha256 differs from the pinned, audited file')
    for r in reasons:
        print(r)
    return 0


def read_status(path):
    st, detail = {}, {}
    if os.path.exists(path):
        for line in open(path, encoding='utf-8'):
            p = line.rstrip('\n').split('\t')
            if len(p) >= 2 and p[0]:
                st[p[0]] = p[1]
                detail[p[0]] = p[2] if len(p) > 2 else ''
    return st, detail


SUBVERDICTS = {
    'source_provenance': ['deps', 'copy'],
    'clean_build': ['preflight', 'deps', 'copy', 'graph', 'scan', 'build', 'integrity'],
    'axioms': ['axioms'],
    'statement_pins': ['pins'],
    'project_kernel_replay': ['negctl', 'leanchecker'],
    'full_env_replay': ['fresh'],
}


def cmd_verdict(a):
    st, detail = read_status(a.status)
    required = [x for x in a.required.split(',') if x]
    requested = [x for x in (a.requested or '').split(',') if x]
    considered = required + [x for x in requested if x not in required]
    agg = C.aggregate(st, considered)
    reasons = [r for r in (a.reason or []) if r]
    scope = a.scope
    if scope == 'FINAL' and reasons:
        scope = 'CUSTOM'
    text = C.verdict_text(scope, agg)
    subs = {}
    for k, checks in SUBVERDICTS.items():
        cs = [c for c in checks if c in considered]
        subs[k] = C.aggregate(st, cs) if cs else 'NOT-REQUESTED'
    res = {'verdict': text, 'scope': scope, 'aggregate': agg, 'scope_reasons': reasons,
           'considered_checks': considered, 'required_checks': required, 'requested_optional_checks': requested,
           'checks': {c: {'status': st.get(c, 'UNFINISHED' if c in considered else 'NOT-RUN'),
                          'detail': detail.get(c, '')} for c in dict.fromkeys(considered + list(st))},
           'subverdicts': subs}
    for kv in a.extra or []:
        k, _, v = kv.partition('=')
        try:
            res[k] = json.loads(v)
        except ValueError:
            res[k] = v
    os.makedirs(a.out_dir, exist_ok=True)
    C.write_json(os.path.join(a.out_dir, 'VERDICT.json'), res)
    with open(os.path.join(a.out_dir, 'VERDICT'), 'w', encoding='utf-8', newline='\n') as f:
        f.write(text + '\n')
    print(f'VERDICT: {text}')
    for k, v in subs.items():
        print(f'  {k:22s} {v}')
    for c in considered:
        print(f'  check {c:12s} {res["checks"][c]["status"]}  {res["checks"][c]["detail"]}')
    for r in reasons:
        print(f'  non-final: {r}')
    return C.exit_code_for(scope, agg)


# ----------------------------------------------------------------------------------------------- misc
def cmd_gate(a):
    peak = 0.0
    for j in a.journal:
        try:
            for line in open(j, encoding='utf-8'):
                try:
                    r = json.loads(line)
                except ValueError:
                    continue
                if r.get('step') == a.step and r.get('exit_code') == 0:
                    peak = max(peak, r.get('peak_job_commit_gb', 0.0) or 0.0)
        except FileNotFoundError:
            pass
    print(f'{max(a.floor, peak + a.margin):.1f}')
    return 0


def cmd_summary(a):
    rows = []
    for l in open(a.journal, encoding='utf-8'):
        if l.strip():
            try:
                r = json.loads(l)
            except ValueError:
                continue
            if r.get('exit_code') is not None and 'wall_seconds' in r:
                rows.append(r)
    phases = {}
    for r in rows:
        ph = r['step'].split(':', 1)[0]
        p = phases.setdefault(ph, {'steps': 0, 'failed': 0, 'wall_seconds': 0.0, 'cpu_seconds': 0.0,
                                   'max_peak_job_commit_gb': 0.0, 'max_peak_tree_ws_gb': 0.0,
                                   'min_free_physical_gb': 1e9, 'max_step': None})
        p['steps'] += 1
        p['failed'] += int(r['exit_code'] != 0)
        p['wall_seconds'] += r['wall_seconds']
        p['cpu_seconds'] += r['cpu_seconds']
        if r['peak_job_commit_gb'] > p['max_peak_job_commit_gb']:
            p['max_peak_job_commit_gb'] = r['peak_job_commit_gb']; p['max_step'] = r['step']
        p['max_peak_tree_ws_gb'] = max(p['max_peak_tree_ws_gb'], r['peak_tree_working_set_gb_sampled'])
        p['min_free_physical_gb'] = min(p['min_free_physical_gb'], r['min_free_physical_gb_sampled'])
    for p in phases.values():
        p['wall_seconds'] = round(p['wall_seconds'], 1); p['cpu_seconds'] = round(p['cpu_seconds'], 1)
    slow = sorted(rows, key=lambda r: -r['wall_seconds'])[:10]
    res = {'phases': phases, 'total_wall_seconds': round(sum(r['wall_seconds'] for r in rows), 1),
           'slowest_steps': [(r['step'], r['wall_seconds'], r['peak_job_commit_gb']) for r in slow]}
    C.write_json(a.out, res)
    for k, p in phases.items():
        print(f"{k:12s} steps={p['steps']:4d} failed={p['failed']:3d} wall={p['wall_seconds'] / 60:8.1f} min "
              f"peak_commit={p['max_peak_job_commit_gb']:.2f} GB ({p['max_step']})")
    return 0


def main():
    ap = argparse.ArgumentParser()
    sp = ap.add_subparsers(dest='cmd', required=True)
    p = sp.add_parser('pathcheck'); p.add_argument('--base', required=True); p.add_argument('--path', required=True)
    p.add_argument('--new-dir', action='store_true'); p.add_argument('--allow-equal', action='store_true')
    p = sp.add_parser('rmfile'); p.add_argument('--base', required=True); p.add_argument('--path', required=True)
    p = sp.add_parser('safename'); p.add_argument('name'); p.add_argument('--what', default='name')
    p = sp.add_parser('copy'); p.add_argument('--manifest', required=True); p.add_argument('--src', required=True)
    p.add_argument('--dst', required=True); p.add_argument('--base', required=True); p.add_argument('--report')
    p = sp.add_parser('selfmanifest'); p.add_argument('--src', required=True); p.add_argument('--out', required=True)
    p = sp.add_parser('verify-tree'); p.add_argument('--manifest', required=True); p.add_argument('--root', required=True)
    p.add_argument('--out')
    p = sp.add_parser('manifest-sha'); p.add_argument('--manifest', required=True)
    p = sp.add_parser('deps'); p.add_argument('--lake-manifest', required=True); p.add_argument('--cache', required=True)
    p.add_argument('--pins', required=True); p.add_argument('--out'); p.add_argument('--objects-out')
    p.add_argument('--objects-manifest'); p.add_argument('--compare')
    p.add_argument('--objects-result-sha', default=''); p.add_argument('--objects-freeze-sha', default='')
    p = sp.add_parser('lakefile-check'); p.add_argument('--lakefile', required=True)
    p = sp.add_parser('run-binding'); p.add_argument('--mode', required=True, choices=['create', 'verify'])
    p.add_argument('--file', required=True); p.add_argument('--external', required=True)
    p.add_argument('--lean-exe', required=True); p.add_argument('--leanchecker-exe', required=True)
    p.add_argument('--checkone', required=True); p.add_argument('--toolchain-bin', required=True)
    p.add_argument('--lake-manifest', required=True); p.add_argument('--deps', required=True)
    p.add_argument('--pins', required=True)
    p = sp.add_parser('modules'); p.add_argument('--root', required=True); p.add_argument('--out', required=True)
    p.add_argument('--heavy-bytes', type=int, default=2_000_000)
    p.add_argument('--heavy-regex', default=r'AmbientKernel|KernelData')
    p = sp.add_parser('scan'); p.add_argument('--root', required=True); p.add_argument('--modules', required=True)
    p.add_argument('--out', required=True)
    p = sp.add_parser('finals'); p.add_argument('--root', required=True); p.add_argument('--file', default='Solution.lean')
    p.add_argument('--modules'); p.add_argument('--require', action='append')
    for name in ('uptodate', 'record-module'):
        p = sp.add_parser(name); p.add_argument('--run-root', required=True); p.add_argument('--module', required=True)
        p.add_argument('--src-file', required=True); p.add_argument('--lean-sha', required=True)
        p.add_argument('--args', required=True); p.add_argument('--deps', required=True)
        p.add_argument('--ext-sha', required=True, help='sha256 of the run-bound external-object inventory')
        if name == 'record-module':
            p.add_argument('--log', required=True)
    p = sp.add_parser('objects'); p.add_argument('--run-root', required=True); p.add_argument('--modules', required=True)
    p.add_argument('--out', required=True); p.add_argument('--olean-txt')
    p = sp.add_parser('verify-objects'); p.add_argument('--root', required=True); p.add_argument('--objects', required=True)
    p = sp.add_parser('classify'); p.add_argument('--kind', required=True,
                                                  choices=['build', 'check', 'leanchecker', 'checkone'])
    p.add_argument('--journal', required=True); p.add_argument('--invocation', required=True)
    p.add_argument('--log'); p.add_argument('--module')
    p = sp.add_parser('axioms'); p.add_argument('--log', required=True); p.add_argument('--expect', nargs='*')
    p.add_argument('--expect-file'); p.add_argument('--min-reports', type=int, default=1)
    p.add_argument('--allowed', nargs='*'); p.add_argument('--out')
    p = sp.add_parser('pins-check'); p.add_argument('--log', required=True); p.add_argument('--pins', required=True)
    p = sp.add_parser('final-config'); p.add_argument('--pins', required=True); p.add_argument('--script-dir')
    p.add_argument('--lean-exe'); p.add_argument('--leanchecker-exe'); p.add_argument('--checkone')
    p.add_argument('--final-theorems'); p.add_argument('--statement-pins'); p.add_argument('--toolchain-bin')
    p = sp.add_parser('verdict'); p.add_argument('--status', required=True); p.add_argument('--required', required=True)
    p.add_argument('--requested'); p.add_argument('--scope', required=True); p.add_argument('--reason', action='append')
    p.add_argument('--out-dir', required=True); p.add_argument('--extra', action='append')
    p = sp.add_parser('gate'); p.add_argument('--journal', action='append', required=True)
    p.add_argument('--step', required=True)
    p.add_argument('--floor', type=float, default=8.0); p.add_argument('--margin', type=float, default=6.0)
    p = sp.add_parser('summary'); p.add_argument('--journal', required=True); p.add_argument('--out', required=True)
    a = ap.parse_args()
    fn = {'pathcheck': cmd_pathcheck, 'rmfile': cmd_rmfile, 'safename': cmd_safename, 'copy': cmd_copy, 'selfmanifest': cmd_selfmanifest,
          'verify-tree': cmd_verify_tree, 'manifest-sha': cmd_manifest_sha, 'deps': cmd_deps,
          'modules': cmd_modules, 'scan': cmd_scan, 'finals': cmd_finals, 'uptodate': cmd_uptodate,
          'record-module': cmd_record_module, 'objects': cmd_objects, 'verify-objects': cmd_verify_objects,
          'classify': cmd_classify, 'axioms': cmd_axioms, 'pins-check': cmd_pins_check,
          'final-config': cmd_final_config, 'verdict': cmd_verdict, 'gate': cmd_gate, 'summary': cmd_summary,
          'lakefile-check': cmd_lakefile_check, 'run-binding': cmd_run_binding}[a.cmd]
    return fn(a)


if __name__ == '__main__':
    sys.exit(main())
