#!/usr/bin/env bash
# CODEX COPY: only ONLY=selftest is enabled. Tool checkouts/binaries are read-only external inputs.
# Historical build branches below are unreachable and retained only to keep provenance/diff review simple.
# A later real selftest requires explicit root scheduling and a bounded outer supervisor.
# build_second_kernel.sh -- PHASE 2: build the independent second kernel (N=7 recipe, Windows port), then validate
# it with genuine and non-semantic controls and write a tool-build record.  Hardened 2026-10-05 (../../HARDENING.md).
#
#   SK_GO=1 bash claude/verify_final/tools/second_kernel/build_second_kernel.sh            # both tools + controls
#   SK_GO=1 ONLY=lean4export|nanoda|selftest bash .../build_second_kernel.sh               # one part
#
# DO NOT RUN until Codex has allocated the build window (it compiles: Lean -> C -> exe, and rustc with LTO).
#
#   1. lean4export @ 076e8e57 (tag v4.34.0, format 3.1.0), built with Codex's Lean 4.34.1 toolchain (read-only)
#      after changing ONLY the checkout's lean-toolchain file to v4.34.1.  A previous .lake/build is moved aside to
#      .lake/build.stale-<ts> (renamed, never deleted).  `lake build` of the default target only; no dependencies.
#   2. nanoda_lib 0.4.19 @ 3a240721: `cargo rustc --release --locked --offline -j 1 --bin nanoda_bin`
#      with Rust 1.98.1 (x86_64-pc-windows-gnu, self-contained under second_kernel/rust), committed Cargo.lock
#      unchanged, extra link argument -Wl,--stack,$SK_NANODA_STACK_BYTES (default 1 GiB reserve; 0 = plain build).
#   3. controls, all through the SAME run_step.py + redirect.py + nanoda_bin path that run_second_kernel.sh uses:
#        accept_good          lean4export Init -- Nat.add_succ: export valid (meta, declaration present), nanoda
#                             ACCEPTED with the export's exact declaration count
#        reject_projfromprop  nanoda's bundled ProjFromProp: REJECTED at exactly the whitelisted site
#                             tc505-infer-proj-prop (src/tc.rs:505 'infer_proj prop', observed in the real Phase-2 run;
#                             nanoda_semantic_sites.json is the only source of REJECTED, see sk_tool.classify_nanoda)
#        missing_export       config naming a missing export file            -> ERROR (never REJECTED)
#        invalid_config_json  malformed config JSON (panics in src/util.rs)   -> ERROR (never REJECTED)
#        wrong_format         good export with meta format 2.0.0              -> ERROR
#        malformed_export     good export with a truncated JSON line          -> ERROR
#        missing_pp           pp_declars naming an absent declaration         -> ERROR
#        forced_resource      good export under a per-process memory limit    -> INCONCLUSIVE (never REJECTED)
#   4. TOOL_BUILD_RECORD.json: status PASS only if every control passed, both binaries exist, the checkouts are at
#      their pins (nanoda clean incl. untracked files; lean4export changed only in lean-toolchain), Cargo.lock is
#      the pinned one and the stack reserve is as requested.  run_second_kernel.sh --preset final requires it.
#
# Every step runs under ../run_step.py (waits for MIN_FREE_GB / MIN_FREE_COMMIT_GB, default 8 / 8; records time and
# peak commit).  Holds claude/formal/.lean_slot.  Output: second_kernel/build/runs/<ts>/ (a NEW directory per
# invocation; the latest record is also copied to build/TOOL_BUILD_RECORD.json).  Writes only under second_kernel/
# (build/, the two checkouts' build outputs, and the lean4export lean-toolchain line).  Never kills anything.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=env.sh
source "$HERE/env.sh"
PINS="$(cd "$HERE/.." && pwd)/FINAL_PINS.json"
tool() { "$PY" "$HERE/sk_tool.py" "$@"; }
vft() { "$PY" "$HERE/../vf_tool.py" "$@"; }
tool_run() { case $1 in *.py) "$PY" "$@" ;; *) "$@" ;; esac; }

case "${1:-}" in -h|--help) sed -n '2,/^set -uo/p' "$0"; exit 0 ;; esac
[ "${SK_GO:-0}" = 1 ] || { echo "refusing to run: set SK_GO=1 once Codex has allocated the build window"; exit 2; }
[ "$(cd "$HERE" && pwd -P)" = "$(cd "$SK" 2>/dev/null && pwd -P)" ] || { echo "script dir is not \$SK"; exit 2; }
ONLY=${ONLY:-all}
[ "$ONLY" = selftest ] || { echo "REFUSED: tool rebuilds are disabled; only ONLY=selftest uses read-only existing binaries"; exit 2; }
"$PY" "$HERE/../resource_policy.py" || { echo "REFUSED: unsafe inherited resource override"; exit 2; }
MIN_FREE_GB=${MIN_FREE_GB:-6.5}
MIN_FREE_COMMIT_GB=${MIN_FREE_COMMIT_GB:-11.75}
SLOT_WAIT_MIN=${SLOT_WAIT_MIN:-30}
SK_NANODA_STACK_BYTES=${SK_NANODA_STACK_BYTES:-1073741824}
STOP_FILE=$SK/STOP
B=$SK/build
"$PY" - "$(winp "$PINS")" "$(winp "$LEAN4EXPORT_EXE")" "$(winp "$NANODA_EXE")" <<'PY'
import hashlib, json, sys
pins = json.load(open(sys.argv[1], encoding='utf-8'))['second_kernel']
for path, name in zip(sys.argv[2:], ('lean4export_sha256', 'nanoda_sha256')):
    with open(path, 'rb') as stream:
        actual = hashlib.file_digest(stream, 'sha256').hexdigest()
    if not isinstance(pins.get(name), str) or actual != pins[name]:
        raise SystemExit('REFUSED: binary differs from final pin: ' + name)
PY
[ "$?" = 0 ] || exit 2
vft pathcheck --base "$(winp "$SK")" --path "$(winp "$B")" >/dev/null || { echo "$B is not a plain directory"; exit 2; }
vft pathcheck --base "$(winp "$SK")" --path "$(winp "$B/runs")" >/dev/null || { echo "$B/runs is not a plain directory"; exit 2; }
[ -d "$B" ] || mkdir "$B" || exit 2
[ -d "$B/runs" ] || mkdir "$B/runs" || exit 2
TS=$(date +%Y%m%d-%H%M%S)
D=$B/runs/$TS
vft pathcheck --base "$(winp "$B/runs")" --path "$(winp "$D")" --new-dir >/dev/null || { echo "invocation dir $D exists; retry"; exit 2; }
mkdir -p "$D/logs" "$D/selftest"
J=$D/journal.jsonl
exec > >(tee -a "$D/build.log") 2>&1
FAILS=0
say() { printf '\n== %s  %s\n' "$(date +%H:%M:%S)" "$*"; }
fail() { echo "FAIL: $*"; FAILS=$((FAILS+1)); }
SEQ=0; INV=""
step() {  # step NAME CWD LOG CMD...   (RAM-gated, Job-Object measured; sets INV)
  local name=$1 cwd=$2 log=$3; shift 3
  SEQ=$((SEQ+1)); INV="b.$SEQ"
  "$PY" "$RUN_STEP" --journal "$(winp "$J")" --step "$name" --invocation "$INV" --log "$(winp "$log")" --cwd "$(winp "$cwd")" \
    --min-free-gb "$MIN_FREE_GB" --min-free-commit-gb "$MIN_FREE_COMMIT_GB" --stop-file "$(winp "$STOP_FILE")" \
    --env LEAN_NUM_THREADS=1 --env RUST_BACKTRACE=0 ${STEP_ENV:+--env "$STEP_ENV"} -- "$@" < /dev/null
}
trap sk_release_slot EXIT

# ------------------------------------------------------------------------------------------------ preflight
say "preflight ($(date -Is), ONLY=$ONLY, invocation $D)"
{
  echo "date: $(date -Is)"; uname -a
  tool_run "$LEAN_EXE" --version; "$LEAN_BIN/lake.exe" --version
  echo "Read-only existing binaries; no Rust/compiler build or version process required."
  echo "CARGO_HOME=$CARGO_HOME"; echo "RUSTUP_HOME=$RUSTUP_HOME"; echo "RUSTUP_TOOLCHAIN=$RUSTUP_TOOLCHAIN"
  echo "lean4export HEAD $(git -C "$EXPORT_DIR" rev-parse HEAD 2>&1)"; echo "nanoda_lib  HEAD $(git -C "$NANODA_DIR" rev-parse HEAD 2>&1)"
  sha256sum "$LEAN_EXE" "$LEAN4EXPORT_EXE" "$NANODA_EXE" \
            "$NANODA_DIR/Cargo.lock" "$RUN_STEP" "$HERE/../resource_policy.py" "$HERE/redirect.py" "$HERE/sk_tool.py" "$0" "$HERE/env.sh" "$PINS"
  sk_mem
} > "$D/environment.txt" 2>&1
cat "$D/environment.txt"
lv=$(tool_run "$LEAN_EXE" --version 2>&1 | tr -d '\r')
[[ $lv == *"version 4.34.1"*"commit $SK_LEAN_COMMIT"* ]] || { echo "unexpected Lean toolchain: $lv"; exit 1; }
if [ "$ONLY" = all ] || [ "$ONLY" = nanoda ]; then
  "$RUST_TC_DIR/bin/rustc.exe" -Vv | tr -d '\r' | grep -qx "commit-hash: $SK_RUSTC_COMMIT" || { echo "unexpected rustc"; exit 1; }
  "$RUST_TC_DIR/bin/rustc.exe" -Vv | tr -d '\r' | grep -qx "host: x86_64-pc-windows-gnu" || { echo "unexpected rustc host"; exit 1; }
fi
# revisions, nanoda cleanliness (incl. untracked), Cargo.lock, and lean4export changed at most in lean-toolchain
tool checkout-state --export-dir "$(winp "$EXPORT_DIR")" --nanoda-dir "$(winp "$NANODA_DIR")" --pins "$(winp "$PINS")" \
  --phase pre --out "$(winp "$D/checkout-pre.json")" || { echo "checkouts are not in the pinned state"; exit 1; }
sk_footprint_check || exit 1
# the pinned semantic-site whitelist must validate against the pinned nanoda source (else no control can be REJECTED)
tool sites-check --pins "$(winp "$PINS")" || { echo "semantic-site whitelist invalid"; exit 1; }
sk_acquire_slot "build" "$SLOT_WAIT_MIN" || exit 3

# ------------------------------------------------------------------------------------------------ lean4export
if [ "$ONLY" = all ] || [ "$ONLY" = lean4export ]; then
  say "lean4export: set lean-toolchain to $SK_LEAN_TOOLCHAIN_LINE (the only change), lake build (1 job)"
  if [ "$(tr -d '\r\n' < "$EXPORT_DIR/lean-toolchain")" != "$SK_LEAN_TOOLCHAIN_LINE" ]; then
    printf '%s\n' "$SK_LEAN_TOOLCHAIN_LINE" > "$EXPORT_DIR/lean-toolchain"
    if [ -e "$EXPORT_DIR/.lake/build" ]; then
      # move the old build aside (rename inside the checkout's own .lake); nothing is deleted
      vft pathcheck --base "$(winp "$EXPORT_DIR/.lake")" --path "$(winp "$EXPORT_DIR/.lake/build")" >/dev/null \
        || { echo "unsafe $EXPORT_DIR/.lake/build"; exit 1; }
      mv -- "$EXPORT_DIR/.lake/build" "$EXPORT_DIR/.lake/build.stale-$TS" || { echo "cannot move the old build aside"; exit 1; }
    fi
  fi
  git -C "$EXPORT_DIR" diff > "$D/lean4export.local.diff"
  cat "$D/lean4export.local.diff"
  STEP_ENV="LEAN_NUM_THREADS=1" step build:lean4export "$EXPORT_DIR" "$D/logs/build-lean4export.txt" \
    "$(winp "$LEAN_BIN/lake.exe")" build -v
  rc=$?; tail -n 25 "$D/logs/build-lean4export.txt"
  if [ $rc -ne 0 ] || [ ! -f "$LEAN4EXPORT_EXE" ]; then fail "lean4export build (rc=$rc)"
  else echo "lean4export.exe stack reserve: $(sk_pe_stack "$LEAN4EXPORT_EXE") bytes"; fi
fi

# ------------------------------------------------------------------------------------------------ nanoda
if [ "$ONLY" = all ] || [ "$ONLY" = nanoda ]; then
  if [ "$SK_NANODA_STACK_BYTES" = 0 ]; then
    say "nanoda: cargo build --release --locked --offline -j 1 (plain)"
    step build:nanoda "$NANODA_DIR" "$D/logs/build-nanoda.txt" "$(winp "$CARGO_EXE")" build --release --locked --offline -j 1 -v
  else
    say "nanoda: cargo rustc --release --locked --offline -j 1 --bin nanoda_bin -- -C link-arg=-Wl,--stack,$SK_NANODA_STACK_BYTES"
    step build:nanoda "$NANODA_DIR" "$D/logs/build-nanoda.txt" \
      "$(winp "$CARGO_EXE")" rustc --release --locked --offline -j 1 -v --bin nanoda_bin -- \
      -C "link-arg=-Wl,--stack,$SK_NANODA_STACK_BYTES"
  fi
  rc=$?; tail -n 25 "$D/logs/build-nanoda.txt"
  [ $rc -eq 0 ] && [ -f "$NANODA_EXE" ] || fail "nanoda build (rc=$rc)"
fi
tool checkout-state --export-dir "$(winp "$EXPORT_DIR")" --nanoda-dir "$(winp "$NANODA_DIR")" --pins "$(winp "$PINS")" \
  --phase "$([ "$(tr -d '\r\n' < "$EXPORT_DIR/lean-toolchain")" = "$SK_LEAN_TOOLCHAIN_LINE" ] && echo post || echo pre)" \
  --out "$(winp "$D/checkout-post.json")" || fail "a build changed a tracked or untracked file in a checkout"
ST_RES=$(sk_pe_stack "$NANODA_EXE" 2>/dev/null || echo none)
echo "nanoda_bin.exe stack reserve: $ST_RES bytes"

# ------------------------------------------------------------------------------------------------ controls
T=$D/selftest
CTL=$T/controls.json
nanoda_once() {  # nanoda_once NAME CWD CONFIG [MAX_BYTES] [EXPECTED_DECLS] -> $T/NAME.result.json
  local name=$1 cwd=$2 cfg=$3 bytes=${4:-} nd=${5:-}
  local lim=(); [ -n "$bytes" ] && lim=(--max-process-bytes "$bytes")
  step "control:$name" "$cwd" "$T/$name.runner.txt" "$(winp "$PY")" "$(winp "$HERE/redirect.py")" "${lim[@]}" \
    "$(winp "$T/$name.out")" "$(winp "$T/$name.err")" "$(winp "$NANODA_EXE")" "$cfg"
  tool classify --journal "$(winp "$J")" --invocation "$INV" --out "$(winp "$T/$name.out")" --err "$(winp "$T/$name.err")" \
    --json "$(winp "$T/$name.result.json")" ${nd:+--expected-decls "$nd"} >/dev/null
}
nanoda_ctl() {  # nanoda_ctl NAME CWD CONFIG EXPECT [MSG_REGEX] [EXPECTED_DECLS] [WHITELISTED_SITE_ID]
  local name=$1 cwd=$2 cfg=$3 expect=$4 rx=${5:-} nd=${6:-} site=${7:-}
  nanoda_once "$name" "$cwd" "$cfg" "" "$nd"
  tool control --name "$name" --expect "$expect" --result "$(winp "$T/$name.result.json")" --controls "$(winp "$CTL")" \
    ${rx:+--message-regex "$rx"} ${site:+--expect-site "$site"} || fail "control $name"
}
SELFTEST_RAN=0
if { [ "$ONLY" = all ] || [ "$ONLY" = selftest ]; } && [ -f "$LEAN4EXPORT_EXE" ] && [ -f "$NANODA_EXE" ]; then
  SELFTEST_RAN=1
  say "controls (accept good, reject ProjFromProp, six non-semantic failures that must never count as rejection)"
  export LEAN_SYSROOT; LEAN_SYSROOT="$(winp "$LEAN_TC")"
  unset LEAN_PATH
  GOOD=$T/nat_add_succ.ndjson
  step selftest:export "$T" "$T/export.runner.txt" "$(winp "$PY")" "$(winp "$HERE/redirect.py")" \
    "$(winp "$GOOD")" "$(winp "$T/export.err")" "$(winp "$LEAN4EXPORT_EXE")" Init -- Nat.add_succ
  ec=$(tool export-check --journal "$(winp "$J")" --invocation "$INV" --export "$(winp "$GOOD")" --err "$(winp "$T/export.err")" \
         --out "$(winp "$T/export.stats.json")" --decls Nat.add_succ --lean-commit "$SK_LEAN_COMMIT" | tr -d '\r')
  echo "fixture export: $ec"
  if [ "${ec%%$'\t'*}" != PASS ]; then
    fail "fixture export (accept_good cannot run): $ec"
  else
    ND=$("$PY" -c "import json,sys;print(json.load(open(sys.argv[1]))['declarations'])" "$(winp "$T/export.stats.json")" | tr -d '\r')
    "$PY" - "$(mixp "$GOOD")" "$(winp "$T")" <<'EOF'
import json, os, sys
good, t = sys.argv[1], sys.argv[2]
def cfg(name, export, pp):
    json.dump({"export_file_path": export, "use_stdin": False,
               "permitted_axioms": ["propext", "Classical.choice", "Quot.sound"], "unpermitted_axiom_hard_error": True,
               "nat_extension": True, "string_extension": True, "pp_declars": pp, "pp_to_stdout": True,
               "unknown_pp_declar_hard_error": True, "print_axioms": True, "print_success_message": True},
              open(os.path.join(t, name), 'w'), indent=1)
lines = open(good, 'rb').read().split(b'\n')
meta = json.loads(lines[0]); meta['meta']['format']['version'] = '2.0.0'
with open(os.path.join(t, 'wrong_format.ndjson'), 'xb') as f:
    f.write(b'\n'.join([json.dumps(meta).encode()] + lines[1:]))
with open(os.path.join(t, 'malformed.ndjson'), 'xb') as f:
    f.write(b'\n'.join([lines[0], lines[1][:max(1, len(lines[1]) // 2)]] + lines[2:]))
cfg('accept_good.json', good, ['Nat.add_succ'])
cfg('missing_export.json', os.path.join(t, 'does-not-exist.ndjson').replace('\\', '/'), ['Nat.add_succ'])
cfg('wrong_format.json', os.path.join(t, 'wrong_format.ndjson').replace('\\', '/'), ['Nat.add_succ'])
cfg('malformed_export.json', os.path.join(t, 'malformed.ndjson').replace('\\', '/'), ['Nat.add_succ'])
cfg('missing_pp.json', good, ['Nat.add_succ', 'VFSelftest.no_such_declaration'])
cfg('forced_resource.json', good, ['Nat.add_succ'])
with open(os.path.join(t, 'invalid_config.json'), 'w') as f:
    f.write('{ "export_file_path": "x", this is not JSON')
EOF
    nanoda_ctl accept_good "$T" "$(winp "$T/accept_good.json")" ACCEPTED "" "$ND"
    head -n 5 "$T/accept_good.out"
    nanoda_ctl reject_projfromprop "$NANODA_DIR" test_resources/ProjFromProp/config.json REJECTED '' '' tc505-infer-proj-prop
    nanoda_ctl missing_export "$T" "$(winp "$T/missing_export.json")" ERROR
    nanoda_ctl invalid_config_json "$T" "$(winp "$T/invalid_config.json")" ERROR
    nanoda_ctl wrong_format "$T" "$(winp "$T/wrong_format.json")" ERROR
    nanoda_ctl malformed_export "$T" "$(winp "$T/malformed_export.json")" ERROR
    nanoda_ctl missing_pp "$T" "$(winp "$T/missing_pp.json")" ERROR
    # forced resource failure: shrink the per-process memory limit until nanoda can no longer finish; the first
    # non-ACCEPTED outcome must be INCONCLUSIVE (a REJECTED here would be exactly the misclassification to exclude)
    forced=""
    for bytes in 16777216 4194304 1048576 524288 262144 131072 65536; do
      name="forced_resource_${bytes}bytes"
      nanoda_once "$name" "$T" "$(winp "$T/forced_resource.json")" "$bytes" "$ND"
      # Require a matching readback/exit receipt, not just the runner's aggregate memory peak.
      "$PY" - "$(winp "$HERE")" "$(winp "$T/$name.err.limit.json")" "$bytes" "$(winp "$J")" "$INV" <<'PY'
import json, sys
sys.path.insert(0, sys.argv[1])
import redirect
receipt = json.load(open(sys.argv[2], encoding='utf-8'))
records = [json.loads(line) for line in open(sys.argv[4], encoding='utf-8') if line.strip()]
matches = [r for r in records if r.get('invocation') == sys.argv[5]]
if len(matches) != 1:
    raise SystemExit('missing or ambiguous limited-run journal record')
r = matches[0]
if r.get('job_assigned') is not True or r['command'][2:4] != ['--max-process-bytes', sys.argv[3]]:
    raise SystemExit('limited-run journal assignment or argument mismatch')
redirect.validate_receipt(receipt, int(sys.argv[3]), r['command'][6:], r['exit_code'])
PY
      if [ "$?" != 0 ]; then
        printf '{"status":"ERROR","cls":"limit-receipt","message":"limited child receipt validation failed"}\n' > "$T/forced_resource.result.json"
        forced=receipt_error
        break
      fi
      st=$("$PY" -c "import json,sys;print(json.load(open(sys.argv[1]))['status'])" "$(winp "$T/$name.result.json")" | tr -d '\r')
      echo "forced resource limit ${bytes} bytes -> $st"
      [ "$st" != ACCEPTED ] && { forced=$bytes; break; }
    done
    if [ "$forced" = receipt_error ]; then
      : # Preserve the explicit operational error; never skip it to a later smaller cap.
    elif [ -n "$forced" ]; then
      cp "$T/forced_resource_${forced}bytes.result.json" "$T/forced_resource.result.json"
    else   # the limit was never reached: record an explicit failing classification (fail closed)
      printf '{"status":"ACCEPTED","cls":"accepted","message":"nanoda finished even under a 64 KiB limit"}\n' > "$T/forced_resource.result.json"
    fi
    # Generic/unknown crashes remain INCONCLUSIVE to the unchanged classifier, but do not
    # satisfy this specific memory-failure control without an explicit resource signal.
    tool control --name forced_resource --expect INCONCLUSIVE --result "$(winp "$T/forced_resource.result.json")" \
      --message-regex 'memory allocation of [0-9]+ bytes failed|out of memory|0xC0000017|0xC000009A|0xC000012D' \
      --controls "$(winp "$CTL")" || fail "control forced_resource"
  fi
fi

# ------------------------------------------------------------------------------------------------ record
say "record"
{ for f in "$LEAN4EXPORT_EXE" "$NANODA_EXE"; do [ -f "$f" ] && sha256sum "$f"; done; } | tee "$D/BINARIES.sha256"
partial=(); [ "$SELFTEST_RAN" = 1 ] || partial=(--partial)
tool record --out "$(winp "$D/TOOL_BUILD_RECORD.json")" --controls "$(winp "$CTL")" --pins "$(winp "$PINS")" \
  --export-dir "$(winp "$EXPORT_DIR")" --nanoda-dir "$(winp "$NANODA_DIR")" --lean4export-exe "$(winp "$LEAN4EXPORT_EXE")" \
  --nanoda-exe "$(winp "$NANODA_EXE")" --lean-exe "$(winp "$LEAN_EXE")" --stack-reserve "$ST_RES" \
  --expected-stack "$SK_NANODA_STACK_BYTES" --diff "$(winp "$D/lean4export.local.diff")" --invocation-dir "$(winp "$D")" \
  "${partial[@]}" || FAILS=$((FAILS+1))
cp -f "$D/TOOL_BUILD_RECORD.json" "$B/TOOL_BUILD_RECORD.json"     # latest record (PASS, FAIL or INCOMPLETE)
vft summary --journal "$(winp "$J")" --out "$(winp "$D/SUMMARY.json")" >/dev/null 2>&1 || echo "(summary unavailable; see $J)"
sk_footprint_check || FAILS=$((FAILS+1))
sk_mem
if [ $FAILS = 0 ] && [ "$SELFTEST_RAN" = 1 ]; then echo "BUILD: OK (tool build record PASS)"
elif [ $FAILS = 0 ]; then echo "BUILD: parts built, controls not run (record INCOMPLETE; run ONLY=selftest)"; FAILS=1
else echo "BUILD: $FAILS failure(s) (record not PASS)"; fi
exit $FAILS
