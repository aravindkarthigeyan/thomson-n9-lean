"""make_semantic_sites.py -- generate nanoda_semantic_sites.json (the pinned whitelist of nanoda_lib 0.4.19 failure
sites that count as a semantic kernel rejection) and nanoda_failure_sites.tsv (inventory of EVERY panic/assert/
unwrap/expect/exit site in the pinned source, with its whitelist status), from the pinned, read-only nanoda_lib
checkout at src/nanoda_lib (commit 3a2407216ee84a75f9e1aead6803d0578be06ae7).  No Rust tool is run.

  python make_semantic_sites.py [--src src/nanoda_lib] [--out nanoda_semantic_sites.json] [--inventory nanoda_failure_sites.tsv]

The REVIEWED list below is the only input that decides membership; this script merely copies the exact source line,
its column and the file hashes out of the pinned source, refuses to write anything if a reviewed site's source line
does not contain the macro that produces the reviewed message, and prints the sha256 of the written JSON (to be pinned
in sk_tool.py SEMANTIC_SITES_SHA256 and FINAL_PINS.json second_kernel.semantic_sites_sha256).

Why these sites and no others (minimal, individually reviewed; see HARDENING.md "Round 2"):
  * every whitelisted panic is reached only when the checked term/declaration is ill-typed (definitional-equality
    failure, projection out of a Prop structure into data, or a type that does not infer to a sort / a function type
    that does not infer to a Pi); none is an internal-invariant, overflow, index, Option/Result unwrap or parser site;
  * tc.rs:955 and tc.rs:505 were observed in the real Phase-2 smoke runs (logs/phase2-smoke-185459);
  * the only non-panic site is the axiom-policy error (parser.rs:777), an explicit `Err` returned by nanoda when the
    export declares an axiom outside the configured whitelist (unpermitted_axiom_hard_error = true).
Everything else -- other lines or files (expr.rs, level.rs, inductive.rs, quot.rs, util.rs, parser.rs panics),
generic assert!/assert_eq!, bare panic!(), unwrap/expect, the multi-thread join panic, 'Declined:' (exit 2), any other
'Error:' (exit 1), NTSTATUS and allocation failures -- is classified ERROR or INCONCLUSIVE by sk_tool.classify_nanoda.
A genuine kernel rejection at an unlisted site is therefore reported as ERROR, which is still never PASS.
"""
import argparse
import hashlib
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
NANODA_REV = '3a2407216ee84a75f9e1aead6803d0578be06ae7'

REVIEWED = [
    dict(id='tc955-assert-def-eq', kind='panic', cls='typecheck', file='src/tc.rs', line=955,
         message='assertion failed: self.def_eq(u, v)',
         meaning='definitional-equality / type mismatch: TypeChecker::assert_def_eq, the only assert of tc.rs:955; its '
                 'callers are the declaration value-vs-type check (tc.rs:92), application argument types (tc.rs:577), '
                 'let values (tc.rs:688), and the inductive/quotient declaration comparisons (inductive.rs, quot.rs); '
                 'the panic location is tc.rs:955 for every caller (no #[track_caller])',
         observed=['phase2-smoke-185459/negctl.out (smuggled false : False)',
                   'phase2-smoke-185459/tiny_tampered_lit.out (natVal 1225 -> 1226)']),
    dict(id='tc505-infer-proj-prop', kind='panic', cls='typecheck', file='src/tc.rs', line=505,
         message='infer_proj prop',
         meaning='projection out of a Prop-valued structure into a non-Prop field (large elimination of a proof), '
                 'final field of TypeChecker::infer_proj',
         observed=['phase2-smoke-185459/neg_bundled.out (nanoda test_resources/ProjFromProp)']),
    dict(id='tc490-infer-proj-prop', kind='panic', cls='typecheck', file='src/tc.rs', line=490,
         message='infer_proj prop',
         meaning='the same projection-from-Prop check of TypeChecker::infer_proj on an earlier, dependent field',
         observed=[]),
    dict(id='tc285-ensure-sort', kind='panic', cls='typecheck', file='src/tc.rs', line=285,
         message='ensur_sort could not produce a sort',
         meaning='inference failure: a declared type (or binder/inductive type) does not reduce to a sort',
         observed=[]),
    dict(id='tc296-ensure-pi', kind='panic', cls='typecheck', file='src/tc.rs', line=296,
         message='ensure_pi could not produce a pi',
         meaning='inference failure: the head of an application does not have a function (Pi) type',
         observed=[]),
    dict(id='tc304-infer-sort-of', kind='panic', cls='typecheck', file='src/tc.rs', line=304,
         message='infer_sort_of could not infer a sort',
         meaning='inference failure: a binder domain / Pi codomain is not a type',
         observed=[]),
    dict(id='parser777-unpermitted-axiom', kind='returned-error', cls='axiom-policy', file='src/parser.rs', line=777,
         message_regex=r'^Error: export file declares unpermitted axiom "(?:[^"\\]|\\.)*"$',
         source_token='"export file declares unpermitted axiom {:?}"',
         meaning='axiom policy: the export declares an axiom outside permitted_axioms with unpermitted_axiom_hard_error '
                 '= true; nanoda returns Err (exit 1, message printed by Rust main as `Error: ...`)',
         observed=[]),
]

FAILURE_RE = re.compile(r'\b(panic!|assert!|assert_eq!|assert_ne!|debug_assert!|debug_assert_eq!|unreachable!|todo!|'
                        r'unimplemented!|process::exit)|\.unwrap\(\)|\.expect\(|Err\(Box')


def sha_lf(data):
    return hashlib.sha256(data.replace(b'\r\n', b'\n')).hexdigest()


def source_token(site):
    if site['kind'] == 'returned-error':
        return site['source_token']
    m = site['message']
    if m.startswith('assertion failed: '):
        return 'assert!(' + m[len('assertion failed: '):] + ')'
    return 'panic!("' + m + '")'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--src', default=os.path.join(HERE, 'src', 'nanoda_lib'))
    ap.add_argument('--out', default=os.path.join(HERE, 'nanoda_semantic_sites.json'))
    ap.add_argument('--inventory', default=os.path.join(HERE, 'nanoda_failure_sites.tsv'))
    a = ap.parse_args()
    files, lines_of, errors = {}, {}, []
    for site in REVIEWED:
        f = site['file']
        if f not in lines_of:
            data = open(os.path.join(a.src, *f.split('/')), 'rb').read()
            files[f] = {'sha256_lf': sha_lf(data), 'lines': data.count(b'\n')}
            lines_of[f] = data.replace(b'\r\n', b'\n').decode('utf-8').split('\n')
    sites = []
    for site in REVIEWED:
        text = lines_of[site['file']][site['line'] - 1]
        tok = source_token(site)
        col = text.find(tok)
        if col < 0:
            errors.append(f'{site["id"]}: {site["file"]}:{site["line"]} does not contain {tok!r}: {text!r}')
            continue
        if site['kind'] == 'panic' and text.count('panic!(') + text.count('assert!(') != 1:
            errors.append(f'{site["id"]}: more than one failure macro on the line')
        row = {k: site[k] for k in ('id', 'kind', 'cls', 'file', 'line')}
        row['column'] = col + 1
        if site['kind'] == 'panic':
            row['message'] = site['message']
        else:
            row['message_regex'] = site['message_regex']
        row['source_token'] = tok
        row['source_line'] = text
        row['source_line_sha256'] = hashlib.sha256(text.encode('utf-8')).hexdigest()
        row['meaning'] = site['meaning']
        row['observed'] = site['observed']
        sites.append(row)
    if errors:
        for e in errors:
            print('ERROR:', e, file=sys.stderr)
        return 1
    doc = {
        'schema': 1,
        'purpose': 'Exact whitelist of nanoda_lib 0.4.19 failure sites whose diagnostic counts as a semantic kernel '
                   'rejection (sk_tool.classify_nanoda REJECTED). Anything not listed is ERROR or INCONCLUSIVE.',
        'nanoda_lib_version': '0.4.19',
        'nanoda_rev': NANODA_REV,
        'source_root': 'claude/verify_final/tools/second_kernel/src/nanoda_lib',
        'hash_rule': 'sha256 over the file bytes with CRLF normalised to LF; source_line is the exact line text',
        'match_rule': 'panic: exit 101, exactly one panic header, thread main, location <file>:<line>:<col> with the '
                      'path relative to the crate root (\\ or /), the message line equal to `message`, no other '
                      'non-blank stderr line except the RUST_BACKTRACE note, empty stdout; returned-error: exit 1, '
                      'the first non-blank stderr line matching `message_regex`, followed only by nanoda\'s help line, '
                      'empty stdout. The column is recorded and reported but not required.',
        'generator': 'claude/verify_final/tools/second_kernel/make_semantic_sites.py',
        'files': files,
        'sites': sites,
    }
    text = json.dumps(doc, indent=1, ensure_ascii=True) + '\n'
    with open(a.out, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)
    # inventory of every failure site in the pinned source (documentation for reviewers; not read at runtime)
    listed = {(s['file'], s['line']) for s in sites}
    rows = ['file\tline\tstatus\ttext']
    srcdir = os.path.join(a.src, 'src')
    for name in sorted(os.listdir(srcdir)):
        if not name.endswith('.rs'):
            continue
        for n, line in enumerate(open(os.path.join(srcdir, name), encoding='utf-8').read().split('\n'), 1):
            if line.lstrip().startswith('//') or not FAILURE_RE.search(line):
                continue
            st = 'WHITELISTED' if ('src/' + name, n) in listed else 'not-semantic-for-classification'
            rows.append(f'src/{name}\t{n}\t{st}\t{line.strip()[:160]}')
    for s in sites:
        if s['kind'] == 'returned-error' and not any(r.startswith(f'{s["file"]}\t{s["line"]}\t') for r in rows):
            rows.append(f'{s["file"]}\t{s["line"]}\tWHITELISTED\t{s["source_line"].strip()[:160]}')
    with open(a.inventory, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(rows) + '\n')
    print(f'wrote {a.out}: {len(sites)} sites; sha256 {hashlib.sha256(text.encode()).hexdigest()}')
    print(f'wrote {a.inventory}: {len(rows) - 1} failure sites inventoried')
    return 0


if __name__ == '__main__':
    sys.exit(main())
