#!/usr/bin/env bash
# run_second_kernel.sh -- PHASE 3: export the dependency closure of given theorems with lean4export, then check
# the export with nanoda (an independent Rust implementation of Lean 4's type checker).  N=7 recipe, Windows port,
# hardened 2026-10-05 after the independent Codex review (see ../../HARDENING.md).
#
#   SK_GO=1 bash claude/verify_final/tools/second_kernel/run_second_kernel.sh --preset tiny     # accept + tampered literal rejected
#   SK_GO=1 bash .../run_second_kernel.sh --preset negctl   # positive control accepted AND smuggled `false` rejected (type checker)
#   SK_GO=1 bash .../run_second_kernel.sh --preset mathy    # Mathlib slice: scaling measurement
#   SK_GO=1 SK_FREEZE_SHA256=<announced FREEZE digest> SK_REBUILD_RUN=<FINAL run_final_verification RUN_ID> \
#       bash .../run_second_kernel.sh --preset final                    # bound to our clean rebuild (default SK_BIND)
#   SK_GO=1 SK_BIND=codex-clean SK_FREEZE_SHA256=.. SK_CODEX_SNAPSHOT=<snapshot root> SK_CODEX_RUN=<its fresh-evidence/<ts>>
#       SK_CLEAN_RESULT_SHA256=<RESULT.json digest> bash .../run_second_kernel.sh --preset final   # bound to Codex's clean build
#   custom: SK_GO=1 SK_BUILD_DIRS="<dir> ..." SK_MODULES="M ..." SK_THEOREMS="c ..." bash .../run_second_kernel.sh  (scope CUSTOM)
#
# FINAL preset: theorem list, pretty-printed declarations, acceptance mode, statement regex and axiom whitelist come
# from ../FINAL_PINS.json; any environment override of them, of SK_BUILD_DIRS, or of a tool path (LEAN_TC,
# LEAN_EXE, LEAN4EXPORT_EXE, NANODA_EXE) makes the script REFUSE to run.  The object directory is derived from the
# binding (claude-rebuild: rebuild VERDICT.json scope FINAL with clean_build/axioms/pins PASS, FREEZE copy digest
# == SK_FREEZE_SHA256, build tree == OBJECTS.json, external Mathlib objects == the rebuild's inventory; codex-clean:
# FREEZE.json digest, RESULT.json digest/status/manifestSha256, local-objects.json, external-objects-after.json).
# A validated tool-build record (build_second_kernel.sh: binary hashes + genuine good/bad/non-semantic controls)
# is required, and the checkouts must be at their pins with only lean4export's lean-toolchain line changed.
# RUN_MANIFEST.json binds export bytes/hash/meta, theorems, configuration, tools, scripts, binding, input object list,
# the semantic-site whitelist hash and the sha256 + parsed options of the actual nanoda.config.json (written exclusively,
# checked key for key, re-checked before and after every nanoda child); SK_STAGE=check re-validates all of it before
# running nanoda and again before reporting.  REJECTED comes only from the pinned whitelist nanoda_semantic_sites.json
# (sk_tool.classify_nanoda); nanoda always runs single-threaded (no num_threads), LEAN_NUM_THREADS=1, RUST_BACKTRACE=0.
#
# Settings (environment):
#   SK_STAGE        all (default) | export (export + statistics only; verdict EXPORT-ONLY) | check (reuse RUN_ID's export)
#   SK_EXPECT       accept (default) | reject   (reject needs SK_POSITIVE_THEOREMS and SK_EXPECT_DECLS)
#   SK_EXPECT_REJECT_CLASS  typecheck (default) | axiom-policy
#   SK_TAMPER_NAT   OLD:NEW  extra negative control on a copy of the export (OLD must occur once unless SK_TAMPER_ALL=1)
#   SK_AXIOMS       non-final runs only; NANODA_THREADS may only be 0 or 1 (nanoda is always single-threaded)
#   MIN_FREE_GB / MIN_FREE_COMMIT_GB (default 6.5/11.75, final 16/16, never below6.5/11.75);
#   SK_MIN_FREE_DISK_GB (5, final 60); SLOT_WAIT_MIN 30
#   SK_TOOL_RECORD  validated tool-build record (default ../build/TOOL_BUILD_RECORD.json); SK_KEEP_TAMPERED=1
# Verdict: per-check STATUS.tsv (preflight, bind, export, nanoda, positive, statement, tamper, integrity) aggregated
# as in ../vf_common.py; VERDICT is the bare aggregate only for scope FINAL, else '<SCOPE>:<aggregate>' with scope
# CONTROL (tiny/negctl/mathy), CUSTOM or EXPORT-ONLY.  Exit 0 final PASS, 4 non-final PASS, 1/3/5/6 otherwise, 2 refused.
# Output: second_kernel/runs/<RUN_ID>/ (a NEW directory; SK_STAGE=check writes a NEW runs/<RUN_ID>/check-<ts>/).
# Holds this copy's .lean_slot. Writes only under this copy's second_kernel/runs/. Never kills anything.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SETS=()
for _v in SK_THEOREMS SK_PP SK_EXPECT SK_EXPECT_PP_REGEX SK_AXIOMS SK_BUILD_DIRS SK_EXPECT_DECLS SK_POSITIVE_THEOREMS \
          LEAN4EXPORT_EXE NANODA_EXE LEAN_TC LEAN_EXE; do
  [ -n "${!_v+x}" ] && SETS+=(--set "$_v=${!_v}")
done
# shellcheck source=env.sh
source "$HERE/env.sh"
PINS="$(cd "$HERE/.." && pwd)/FINAL_PINS.json"
refuse() { echo "REFUSED: $*" >&2; exit 2; }
tool() { "$PY" "$HERE/sk_tool.py" "$@"; }
vft() { "$PY" "$HERE/../vf_tool.py" "$@"; }
tool_run() { case $1 in *.py) "$PY" "$@" ;; *) "$@" ;; esac; }
pin() { "$PY" -c "import json,sys;v=json.load(open(sys.argv[1]))
for k in sys.argv[2].split('.'): v=v[k]
print(v if isinstance(v,str) else ' '.join(v))" "$(winp "$PINS")" "$1" | tr -d '\r'; }

[ "$(cd "$HERE" && pwd -P)" = "$(cd "$SK" 2>/dev/null && pwd -P)" ] || refuse "script dir $HERE is not \$SK ($SK)"
PRESET=custom
while [ $# -gt 0 ]; do
  case $1 in
    --preset) [ $# -ge 2 ] || refuse "--preset needs a value"; PRESET=$2; shift 2 ;;
    -h|--help) sed -n '2,/^set -uo/p' "$0"; exit 0 ;;
    *) refuse "unknown argument $1" ;;
  esac
done
[ "${SK_GO:-0}" = 1 ] || refuse "set SK_GO=1 once Codex has allocated the window"
SK_STAGE=${SK_STAGE:-all}
case $SK_STAGE in all|export|check) ;; *) refuse "SK_STAGE must be all, export or check" ;; esac

SMOKE_OUT=$VF/tools/smoke/out
SCOPE=CUSTOM
REASONS=()
case $PRESET in
  tiny)   : "${SK_BUILD_DIRS:=$SMOKE_OUT}" "${SK_MODULES:=VFSmoke.Tiny}" "${SK_THEOREMS:=VFSmoke.two_add_two VFSmoke.decide_small}"
          : "${SK_TAMPER_NAT:=1225:1226}" "${SK_TAMPER_ALL:=1}"; SCOPE=CONTROL ;;   # `decide` proof of sum = 1225 must fail for 1226
  negctl) : "${SK_BUILD_DIRS:=$SMOKE_OUT}" "${SK_MODULES:=VFNeg.UsesFalse}" "${SK_THEOREMS:=VFNeg.oops}" "${SK_EXPECT:=reject}"
          : "${SK_EXPECT_DECLS:=false VFNeg.oops}" "${SK_POSITIVE_THEOREMS:=Nat.add_comm}"; SCOPE=CONTROL ;;
  mathy)  : "${SK_BUILD_DIRS:=$SMOKE_OUT}" "${SK_MODULES:=VFSmoke.Mathy}" "${SK_THEOREMS:=VFSmoke.bern31}"; SCOPE=CONTROL ;;
  final)
    bad=$(tool final-overrides --pins "$(winp "$PINS")" "${SETS[@]}" | tr -d '\r')
    [ -z "$bad" ] || refuse "preset final rejects relaxed overrides (use a custom run, which is never final):"$'\n'"$bad"
    [ -z "${SK_TOOL_OVERRIDES// /}" ] || refuse "preset final rejects tool path overrides:$SK_TOOL_OVERRIDES"
    for kv in "lean4export_rev=$SK_EXPORT_REV" "nanoda_rev=$SK_NANODA_REV" "nanoda_cargo_lock_sha256=$SK_NANODA_LOCK_SHA256"; do
      [ "$(pin "second_kernel.${kv%%=*}")" = "${kv#*=}" ] || refuse "env.sh pin ${kv%%=*} differs from FINAL_PINS.json"
    done
    [ "$(pin lean_commit)" = "$SK_LEAN_COMMIT" ] && [ "$(pin lean_toolchain_line)" = "$SK_LEAN_TOOLCHAIN_LINE" ] \
      || refuse "env.sh Lean pins differ from FINAL_PINS.json"
    SK_THEOREMS=$(pin second_kernel.theorems); SK_PP=$(pin second_kernel.pp_declars); SK_EXPECT=$(pin second_kernel.expect)
    SK_EXPECT_PP_REGEX=$(pin second_kernel.pp_regex); SK_AXIOMS=$(pin allowed_axioms)
    SK_MODULES=${SK_MODULES:-$(pin second_kernel.modules)}
    SK_BIND=${SK_BIND:-claude-rebuild}
    [[ ${SK_FREEZE_SHA256:-} =~ ^[0-9a-fA-F]{64}$ ]] || refuse "preset final needs SK_FREEZE_SHA256 (independently announced freeze manifest digest)"
    case $SK_BIND in
      claude-rebuild) [ -n "${SK_REBUILD_RUN:-}" ] || refuse "preset final needs SK_REBUILD_RUN (RUN_ID of a FINAL run_final_verification rebuild)" ;;
      codex-clean) { [ -n "${SK_CODEX_SNAPSHOT:-}" ] && [ -n "${SK_CODEX_RUN:-}" ] && [[ ${SK_CLEAN_RESULT_SHA256:-} =~ ^[0-9a-fA-F]{64}$ ]]; } \
                     || refuse "SK_BIND=codex-clean needs SK_CODEX_SNAPSHOT, SK_CODEX_RUN and SK_CLEAN_RESULT_SHA256" ;;
      *) refuse "SK_BIND must be claude-rebuild or codex-clean" ;;
    esac
    : "${MIN_FREE_GB:=16}" "${MIN_FREE_COMMIT_GB:=16}" "${SK_MIN_FREE_DISK_GB:=60}"
    SCOPE=FINAL ;;
  custom) { [ -n "${SK_BUILD_DIRS:-}" ] && [ -n "${SK_MODULES:-}" ] && [ -n "${SK_THEOREMS:-}" ]; } \
            || refuse "custom run needs SK_BUILD_DIRS, SK_MODULES and SK_THEOREMS (or use --preset)" ;;
  *) refuse "unknown preset $PRESET" ;;
esac
SK_PP=${SK_PP:-$SK_THEOREMS}
SK_EXPECT=${SK_EXPECT:-accept}
case $SK_EXPECT in accept|reject) ;; *) refuse "SK_EXPECT must be accept or reject" ;; esac
SK_EXPECT_REJECT_CLASS=${SK_EXPECT_REJECT_CLASS:-typecheck}
SK_EXPECT_DECLS=${SK_EXPECT_DECLS:-}
SK_POSITIVE_THEOREMS=${SK_POSITIVE_THEOREMS:-}
if [ "$SK_EXPECT" = reject ]; then
  [ -n "$SK_POSITIVE_THEOREMS" ] || refuse "a negative expectation needs SK_POSITIVE_THEOREMS (positive control through the same path)"
  [ -n "$SK_EXPECT_DECLS" ] || refuse "a negative expectation needs SK_EXPECT_DECLS (bad declarations that must be in the export)"
fi
SK_TAMPER_NAT=${SK_TAMPER_NAT:-}
SK_TAMPER_ALL=${SK_TAMPER_ALL:-0}
SK_AXIOMS=${SK_AXIOMS:-propext Classical.choice Quot.sound}
# single worker: nanoda always checks serially on its main thread (the config never has num_threads), which is also
# what the semantic-site classifier requires (exactly one panic, in thread 'main')
[ -z "${NANODA_THREADS+x}" ] || [ "$NANODA_THREADS" = 0 ] || [ "$NANODA_THREADS" = 1 ] \
  || refuse "NANODA_THREADS=$NANODA_THREADS: nanoda runs single-threaded only (no relaxed thread profile is approved)"
NANODA_THREADS=1
MIN_FREE_GB=${MIN_FREE_GB:-6.5}
MIN_FREE_COMMIT_GB=${MIN_FREE_COMMIT_GB:-11.75}
SK_MIN_FREE_DISK_GB=${SK_MIN_FREE_DISK_GB:-5}
SLOT_WAIT_MIN=${SLOT_WAIT_MIN:-30}
SK_KEEP_TAMPERED=${SK_KEEP_TAMPERED:-0}
SK_EXPECT_PP_REGEX=${SK_EXPECT_PP_REGEX:-}
SK_TOOL_RECORD=${SK_TOOL_RECORD:-$SK/build/TOOL_BUILD_RECORD.json}
STOP_FILE=$SK/STOP
"$PY" "$HERE/../resource_policy.py" || refuse "unsafe inherited resource override"

# ------------------------------------------------------------------------------------------------ run directory
vft pathcheck --base "$(winp "$SK")" --path "$(winp "$SK/runs")" >/dev/null || refuse "$SK/runs is not a plain directory"
[ -d "$SK/runs" ] || mkdir "$SK/runs" || refuse "cannot create $SK/runs"
if [ "$SK_STAGE" = check ]; then
  [ -n "${RUN_ID:-}" ] || refuse "SK_STAGE=check needs RUN_ID of an export run"
  vft safename "$RUN_ID" --what RUN_ID || refuse "unsafe RUN_ID"
  R=$SK/runs/$RUN_ID
  vft pathcheck --base "$(winp "$SK/runs")" --path "$(winp "$R")" >/dev/null || refuse "no plain run dir $R"
  [ -f "$R/RUN_MANIFEST.json" ] && [ -s "$R/export.ndjson" ] || refuse "$R lacks RUN_MANIFEST.json or export.ndjson (not a completed export run)"
  O=$R/check-$(date +%Y%m%d-%H%M%S)
  vft pathcheck --base "$(winp "$R")" --path "$(winp "$O")" --new-dir >/dev/null || refuse "check dir $O exists"
else
  RUN_ID=${RUN_ID:-$PRESET-$(date +%Y%m%d-%H%M%S)}
  vft safename "$RUN_ID" --what RUN_ID || refuse "unsafe RUN_ID"
  R=$SK/runs/$RUN_ID
  vft pathcheck --base "$(winp "$SK/runs")" --path "$(winp "$R")" --new-dir >/dev/null \
    || refuse "run dir $R exists or is unsafe; choose a new RUN_ID"
  O=$R
fi
mkdir -p "$O/tamper" "$O/positive"
J=$O/journal.jsonl
STATUS=$O/STATUS.tsv
: > "$STATUS"
EXP=$R/export.ndjson
printf 'UNFINISHED\n' > "$O/VERDICT"
exec > >(tee -a "$O/run.log") 2>&1
say() { printf '\n== %s  %s\n' "$(date +%H:%M:%S)" "$*"; }
status() { printf '%s\t%s\t%s\n' "$1" "$2" "${3:-}" | tr -d '\r' >> "$STATUS"; echo "[status] $1: $2 ${3:-}"; }
check_status() { awk -F'\t' -v p="$1" '$1==p{v=$2} END{print v}' "$STATUS"; }
SEQ=0; INV=""
step() {  # step NAME CWD CMD...   (RAM-gated, Job-Object measured; sets INV for the classifiers)
  local name=$1 cwd=$2; shift 2
  SEQ=$((SEQ+1)); INV="sk.$SEQ"
  "$PY" "$RUN_STEP" --journal "$(winp "$J")" --step "$name" --invocation "$INV" \
    --log "$(winp "$O/runner-${name//[:\/]/_}.txt")" --cwd "$(winp "$cwd")" --min-free-gb "$MIN_FREE_GB" \
    --min-free-commit-gb "$MIN_FREE_COMMIT_GB" --stop-file "$(winp "$STOP_FILE")" \
    --env LEAN_NUM_THREADS=1 --env RUST_BACKTRACE=0 -- "$@" < /dev/null
}
split() { ST=${1%%$'\t'*}; WHY=${1#*$'\t'}; case $ST in PASS|REJECTED|FAILED|INCONCLUSIVE|ERROR|SKIPPED|UNFINISHED) ;; *) ST=ERROR; WHY="unparsable: $1" ;; esac; }
FINISHED=0; VRC=6
finish() {
  [ "$FINISHED" = 1 ] && return; FINISHED=1
  local required=preflight,export requested="" scope=$SCOPE
  [ "$SCOPE" = FINAL ] && required="$required,bind"
  if [ "$SK_STAGE" = export ]; then scope=EXPORT-ONLY
  else
    required="$required,nanoda"
    [ "$SK_EXPECT" = reject ] && required="$required,positive"
    [ "$SCOPE" = FINAL ] && required="$required,statement,integrity"
    [ "$SCOPE" != FINAL ] && [ -n "$SK_EXPECT_PP_REGEX" ] && requested=statement
    [ -n "$SK_TAMPER_NAT" ] && requested="${requested:+$requested,}tamper"
  fi
  local rargs=(); local r; for r in "${REASONS[@]}"; do rargs+=(--reason "$r"); done
  printf 'ERROR\n' > "$O/VERDICT"
  vft verdict --status "$(winp "$STATUS")" --required "$required" --requested "$requested" --scope "$scope" "${rargs[@]}" \
    --out-dir "$(winp "$O")" --extra "preset=\"$PRESET\"" --extra "stage=\"$SK_STAGE\"" --extra "run_id=\"$RUN_ID\"" \
    --extra "modules=\"$SK_MODULES\"" --extra "theorems=\"$SK_THEOREMS\"" --extra "axioms=\"$SK_AXIOMS\"" \
    --extra "final_pins_sha256=\"$(sha256sum "$PINS" | cut -c1-64)\""
  VRC=$?
  [ -f "$O/VERDICT.json" ] || { VRC=6; printf 'ERROR\n' > "$O/VERDICT"; }
  tool result --journal "$(winp "$J")" --out "$(winp "$O/RESULT.json")" --field "verdict=\"$(tr -d '\r\n' < "$O/VERDICT")\"" >/dev/null 2>&1
  say "VERDICT: $(cat "$O/VERDICT")   ($O/VERDICT.json, $O/run.log)"
  sk_release_slot
}
trap '[ "$FINISHED" = 1 ] || finish' EXIT
die() { status "$1" "$2" "$3"; finish; exit "$VRC"; }

# ------------------------------------------------------------------------------------------------ preflight
say "run $RUN_ID  preset=$PRESET  scope=$SCOPE  stage=$SK_STAGE  expect=$SK_EXPECT"
echo "modules:  $SK_MODULES"; echo "theorems: $SK_THEOREMS"
for f in "$LEAN4EXPORT_EXE" "$NANODA_EXE" "$LEAN_EXE"; do [ -f "$f" ] || die preflight ERROR "missing $f (run build_second_kernel.sh)"; done
lv=$(tool_run "$LEAN_EXE" --version 2>&1 | tr -d '\r')
[[ $lv == *"version 4.34.1"*"commit $SK_LEAN_COMMIT"* ]] || die preflight FAILED "unexpected Lean toolchain: $lv"
# the semantic-site whitelist (the only source of REJECTED) must validate against the pinned nanoda source and pins
tool sites-check --pins "$(winp "$PINS")" || die preflight ERROR "semantic-site whitelist invalid (nothing could be classified REJECTED)"
if tool verify-record --record "$(winp "$SK_TOOL_RECORD")" --pins "$(winp "$PINS")" --export-dir "$(winp "$EXPORT_DIR")" \
     --nanoda-dir "$(winp "$NANODA_DIR")" --lean4export-exe "$(winp "$LEAN4EXPORT_EXE")" --nanoda-exe "$(winp "$NANODA_EXE")" \
     > "$O/tool-record-check.txt" 2>&1; then
  echo "tool build record valid: $SK_TOOL_RECORD"
else
  cat "$O/tool-record-check.txt"
  [ "$SCOPE" = FINAL ] && die preflight FAILED "no valid tool build record (binary hashes + genuine controls + pinned checkouts)"
  REASONS+=("tool build record not valid (see tool-record-check.txt)")
fi
if [ "$SCOPE" = FINAL ]; then
  tc=$(vft final-config --pins "$(winp "$PINS")" --lean-exe "$(winp "$LEAN_EXE")" --toolchain-bin "$(winp "$LEAN_BIN")" | tr -d '\r')
  [ -z "$tc" ] || die preflight FAILED "toolchain differs from FINAL_PINS: $tc"
fi
[ -n "${SK_TOOL_OVERRIDES// /}" ] && REASONS+=("tool path overrides:$SK_TOOL_OVERRIDES")
{
  echo "date: $(date -Is)"; echo "run: $RUN_ID preset=$PRESET scope=$SCOPE stage=$SK_STAGE expect=$SK_EXPECT threads=$NANODA_THREADS"
  echo "modules: $SK_MODULES"; echo "theorems: $SK_THEOREMS"; echo "pp: $SK_PP"; echo "axioms: $SK_AXIOMS"
  echo "tamper: ${SK_TAMPER_NAT:-none} (all=$SK_TAMPER_ALL)"; echo "$lv"
  echo "lean4export $(git -C "$EXPORT_DIR" rev-parse HEAD 2>&1) local: $(git -C "$EXPORT_DIR" status --porcelain 2>&1 | tr '\n' ' ')"
  echo "nanoda_lib  $(git -C "$NANODA_DIR" rev-parse HEAD 2>&1) local: $(git -C "$NANODA_DIR" status --porcelain 2>&1 | tr '\n' ' ')"
  sha256sum "$LEAN4EXPORT_EXE" "$NANODA_EXE" "$LEAN_EXE" "$0" "$HERE/env.sh" "$HERE/sk_tool.py" "$HERE/redirect.py" "$RUN_STEP" "$PINS"
  echo "nanoda_bin stack reserve: $(sk_pe_stack "$NANODA_EXE" 2>/dev/null || echo 'not a PE file')"
  sk_mem
} > "$O/environment.txt" 2>&1
cat "$O/environment.txt"

if [ "$SCOPE" = FINAL ]; then
  if [ "$SK_STAGE" = check ]; then
    tool bind-verify --bind "$(winp "$R/bind.json")" --pins "$(winp "$PINS")" || die bind FAILED "binding of the export run no longer holds"
  else
    if [ "$SK_BIND" = claude-rebuild ]; then
      vft safename "$SK_REBUILD_RUN" --what SK_REBUILD_RUN || die bind ERROR "unsafe SK_REBUILD_RUN"
      bd=$(tool bind --mode claude-rebuild --pins "$(winp "$PINS")" --freeze-sha "$SK_FREEZE_SHA256" --modules "$SK_MODULES" \
             --out "$(winp "$R/bind.json")" --vf "$(winp "$VF")" \
             --rebuild-dir "$(winp "$VF/rebuild/$SK_REBUILD_RUN")" --pkg-cache "$(winp "$PKG_CACHE")") \
        || die bind FAILED "the build directory is not bound to a successful frozen rebuild (see above)"
    else
      bd=$(tool bind --mode codex-clean --pins "$(winp "$PINS")" --freeze-sha "$SK_FREEZE_SHA256" --modules "$SK_MODULES" \
             --out "$(winp "$R/bind.json")" --snapshot "$(winp "$SK_CODEX_SNAPSHOT")" --run-dir "$(winp "$SK_CODEX_RUN")" \
             --result-sha "$SK_CLEAN_RESULT_SHA256" --pkg-cache "$(winp "$PKG_CACHE")") \
        || die bind FAILED "the build directory is not bound to Codex's successful clean build (see above)"
    fi
  fi
  SK_BUILD_DIRS=$(cygpath -u "$("$PY" -c "import json,sys;print(json.load(open(sys.argv[1]))['build_dir'])" "$(winp "$R/bind.json")" | tr -d '\r')")
  status bind PASS "$("$PY" -c "import json,sys;b=json.load(open(sys.argv[1]));print(b['mode'],'freeze',b['freeze_sha256'][:16],'build',b['build_dir'])" "$(winp "$R/bind.json")" | tr -d '\r')"
fi
LP=""
for d in $SK_BUILD_DIRS; do
  [ -d "$d" ] || die preflight ERROR "no such build dir $d"
  vft pathcheck --base "$(winp "$d")" --path "$(winp "$d")" --allow-equal >/dev/null || die preflight ERROR "build dir $d is not plain"
  LP="${LP:+$LP;}$(winp "$d")"
done
for p in mathlib batteries Qq aesop proofwidgets importGraph LeanSearchClient plausible Cli; do
  [ -d "$PKG_CACHE/$p/.lake/build/lib/lean" ] && LP="$LP;$(winp "$PKG_CACHE/$p/.lake/build/lib/lean")"
done
export LEAN_PATH="$LP"
export LEAN_SYSROOT; LEAN_SYSROOT="$(winp "$LEAN_TC")"
for m in $SK_MODULES; do
  rel=${m//.//}.olean; hit=""
  for d in $SK_BUILD_DIRS "$PKG_CACHE"/*/.lake/build/lib/lean; do [ -f "$d/$rel" ] && { hit=$d/$rel; break; }; done
  [ -n "$hit" ] || die preflight ERROR "module $m: no $rel on the search path"
  echo "module $m -> $hit"
done
: > "$O/OLEAN_SHA256.txt"
for d in $SK_BUILD_DIRS; do (cd "$d" && find . -name '*.olean*' -print0 | LC_ALL=C sort -z | xargs -0 -r sha256sum) >> "$O/OLEAN_SHA256.txt"; done
echo "input .olean files hashed: $(wc -l < "$O/OLEAN_SHA256.txt")"
free_gb=$(df -Pk "$O" | awk 'NR==2{printf "%d", $4/1048576}')
[ "${free_gb:-0}" -ge "$SK_MIN_FREE_DISK_GB" ] || die preflight UNFINISHED "only ${free_gb:-?} GB free disk (< $SK_MIN_FREE_DISK_GB)"
sk_footprint_check || die preflight ERROR "Rust footprint check failed"
sk_acquire_slot "run $RUN_ID" "$SLOT_WAIT_MIN" || die preflight UNFINISHED "Claude Lean slot busy"
status preflight PASS "toolchain, tool record$([ ${#REASONS[@]} -gt 0 ] && echo ' (non-final reasons recorded)'), inputs, disk, slot"

RM_ARGS=(--pins "$(winp "$PINS")" --preset "$PRESET" --scope "$SCOPE" --modules "$SK_MODULES" --theorems "$SK_THEOREMS"
         --pp "$SK_PP" --axioms "$SK_AXIOMS" --expect "$SK_EXPECT" --pp-regex "$SK_EXPECT_PP_REGEX" --export "$(winp "$EXP")"
         --olean-list "$(winp "$O/OLEAN_SHA256.txt")" --record "$(winp "$SK_TOOL_RECORD")"
         --tool "lean4export=$(winp "$LEAN4EXPORT_EXE")" --tool "nanoda=$(winp "$NANODA_EXE")" --tool "lean=$(winp "$LEAN_EXE")"
         --script "$(winp "$0")" --script "$(winp "$HERE/sk_tool.py")" --script "$(winp "$HERE/redirect.py")"
         --script "$(winp "$HERE/env.sh")" --script "$(winp "$HERE/../vf_common.py")" --script "$(winp "$HERE/../vf_tool.py")" \
         --script "$(winp "$HERE/../resource_policy.py")"
         --script "$(winp "$RUN_STEP")")
[ "$SCOPE" = FINAL ] && RM_ARGS+=(--bind "$(winp "$R/bind.json")")

# nanoda configuration: written exclusively by sk_tool (single-threaded, hard axiom error, both extensions), checked
# key for key (exactly the standard three axioms in FINAL), its sha256 bound in RUN_MANIFEST.json, and re-checked
# immediately before and after every nanoda child and again at the final integrity step.
REQ_AX=(); [ "$SCOPE" = FINAL ] && REQ_AX=(--require-axioms "$(pin allowed_axioms)")
check_cfg() {  # check_cfg CFG EXPORT PP [EXPECT_SHA] -> prints the config sha256; non-zero if not exactly valid
  local out rc
  out=$(tool config-check --config "$(winp "$1")" --export "$(mixp "$2")" --pp "$3" --axioms "$SK_AXIOMS" "${REQ_AX[@]}" \
          ${4:+--expect-sha "$4"} | tr -d '\r'); rc=$?
  [ $rc = 0 ] || { echo "$out" >&2; return 1; }
  printf '%s' "$out"
}
make_cfg() {  # make_cfg CFG EXPORT PP -> prints the sha256 of the new, exactly valid config
  tool config --export "$(mixp "$2")" --out "$(winp "$1")" --pp "$3" --axioms "$SK_AXIOMS" --exclusive >/dev/null || return 1
  check_cfg "$1" "$2" "$3"
}
CFG=$O/nanoda.config.json

# ------------------------------------------------------------------------------------------------ export
EXPECTED_DECLS=""
if [ "$SK_STAGE" = check ]; then
  say "check-only: re-validate the saved export and its configuration against RUN_MANIFEST.json"
  CFG_SHA=$(make_cfg "$CFG" "$EXP" "$SK_PP") || die export ERROR "cannot write a valid nanoda configuration"
  RM_ARGS+=(--config "$(winp "$CFG")")
  out=$(tool runmanifest --mode verify --manifest "$(winp "$R/RUN_MANIFEST.json")" "${RM_ARGS[@]}" --print-decls | tr -d '\r')
  echo "$out"
  grep -q '^run manifest: VALID$' <<< "$out" || die export FAILED "saved export/configuration differs from RUN_MANIFEST.json"
  EXPECTED_DECLS=$(sed -n 's/^DECLS\t//p' <<< "$out")
  [[ $EXPECTED_DECLS =~ ^[0-9]+$ ]] || die export ERROR "RUN_MANIFEST.json lacks the export declaration count"
  status export PASS "saved export re-validated: sha256, bytes, meta, theorems, configuration, tools, scripts, objects"
else
  say "export: lean4export $SK_MODULES -- $SK_THEOREMS"
  # shellcheck disable=SC2086
  step export "$O" "$(winp "$PY")" "$(winp "$HERE/redirect.py")" "$(winp "$EXP")" "$(winp "$O/export.err")" \
    "$(winp "$LEAN4EXPORT_EXE")" $SK_MODULES -- $SK_THEOREMS
  [ -s "$O/export.err" ] && { echo "--- export stderr:"; head -n 30 "$O/export.err"; }
  # shellcheck disable=SC2086
  split "$(tool export-check --journal "$(winp "$J")" --invocation "$INV" --export "$(winp "$EXP")" --err "$(winp "$O/export.err")" \
           --out "$(winp "$O/export.stats.json")" --decls $SK_EXPECT_DECLS --lean-commit "$SK_LEAN_COMMIT" | tr -d '\r')"
  [ "$ST" = PASS ] || die export "$ST" "$WHY"
  EXPECTED_DECLS=$("$PY" -c "import json,sys;print(json.load(open(sys.argv[1]))['declarations'])" "$(winp "$O/export.stats.json")" | tr -d '\r')
  CFG_SHA=$(make_cfg "$CFG" "$EXP" "$SK_PP") || die export ERROR "cannot write a valid nanoda configuration"
  RM_ARGS+=(--config "$(winp "$CFG")")
  tool runmanifest --mode create --manifest "$(winp "$R/RUN_MANIFEST.json")" "${RM_ARGS[@]}" --stats "$(winp "$O/export.stats.json")" \
    || die export ERROR "cannot write RUN_MANIFEST.json"
  status export PASS "$WHY${SK_EXPECT_DECLS:+; contains the expected bad declarations: $SK_EXPECT_DECLS}"
  if [ "$SK_STAGE" = export ]; then finish; exit "$VRC"; fi
fi

# ------------------------------------------------------------------------------------------------ nanoda
nanoda_run() {  # nanoda_run NAME DIR EXPORT PP EXPECTED_DECLS CFG CFG_SHA -> RES (classification json path)
  local name=$1 dir=$2 exp=$3 pp=$4 nd=$5 cfg=$6 csha=$7
  RES=$dir/$name.result.json
  if ! check_cfg "$cfg" "$exp" "$pp" "$csha" >/dev/null; then
    printf '{"status": "ERROR", "cls": "config", "message": "nanoda configuration is not the bound, exactly valid one (before the run)", "site": null}\n' > "$RES"
    return
  fi
  step "$name" "$dir" "$(winp "$PY")" "$(winp "$HERE/redirect.py")" "$(winp "$dir/$name.out")" "$(winp "$dir/$name.err")" \
    "$(winp "$NANODA_EXE")" "$(winp "$cfg")"
  local inv=$INV
  [ -s "$dir/$name.err" ] && { echo "--- $name stderr (tail):"; tail -n 5 "$dir/$name.err"; }
  if ! check_cfg "$cfg" "$exp" "$pp" "$csha" >/dev/null; then
    printf '{"status": "ERROR", "cls": "config", "message": "nanoda configuration changed during the run", "site": null}\n' > "$RES"
    return
  fi
  tool classify --journal "$(winp "$J")" --invocation "$inv" --out "$(winp "$dir/$name.out")" --err "$(winp "$dir/$name.err")" \
    --json "$(winp "$RES")" ${nd:+--expected-decls "$nd"}
}
say "nanoda: check the export (single-threaded, permitted axioms: $SK_AXIOMS; expect $SK_EXPECT; config sha256 ${CFG_SHA:0:16})"
nanoda_run nanoda "$O" "$EXP" "$SK_PP" "$EXPECTED_DECLS" "$CFG" "$CFG_SHA"
head -c 20000 "$O/nanoda.out"
split "$(tool map-status --result "$(winp "$RES")" --role "$SK_EXPECT" --reject-class "$SK_EXPECT_REJECT_CLASS" \
         --allowed-axioms "$SK_AXIOMS" | tr -d '\r')"
[ "$ST" = UNFINISHED ] && die nanoda UNFINISHED "$WHY"
status nanoda "$ST" "$WHY"
MAIN=$ST

if [ "$SK_EXPECT" = reject ]; then
  say "positive control through the same path: lean4export $SK_MODULES -- $SK_POSITIVE_THEOREMS; nanoda must accept"
  PEXP=$O/positive/export.ndjson
  # shellcheck disable=SC2086
  step export-positive "$O/positive" "$(winp "$PY")" "$(winp "$HERE/redirect.py")" "$(winp "$PEXP")" "$(winp "$O/positive/export.err")" \
    "$(winp "$LEAN4EXPORT_EXE")" $SK_MODULES -- $SK_POSITIVE_THEOREMS
  # shellcheck disable=SC2086
  split "$(tool export-check --journal "$(winp "$J")" --invocation "$INV" --export "$(winp "$PEXP")" \
           --err "$(winp "$O/positive/export.err")" --out "$(winp "$O/positive/export.stats.json")" --decls $SK_POSITIVE_THEOREMS \
           --lean-commit "$SK_LEAN_COMMIT" | tr -d '\r')"
  if [ "$ST" != PASS ]; then status positive "$ST" "positive-control export: $WHY"
  else
    pd=$("$PY" -c "import json,sys;print(json.load(open(sys.argv[1]))['declarations'])" "$(winp "$O/positive/export.stats.json")" | tr -d '\r')
    if PSHA=$(make_cfg "$O/positive/nanoda.config.json" "$PEXP" "$SK_POSITIVE_THEOREMS"); then
      nanoda_run nanoda-positive "$O/positive" "$PEXP" "$SK_POSITIVE_THEOREMS" "$pd" "$O/positive/nanoda.config.json" "$PSHA"
      split "$(tool map-status --result "$(winp "$RES")" --role positive --allowed-axioms "$SK_AXIOMS" | tr -d '\r')"
      status positive "$ST" "$WHY"
    else status positive ERROR "cannot write a valid positive-control nanoda configuration"; fi
  fi
fi

if [ -n "$SK_EXPECT_PP_REGEX" ]; then
  if [ "$MAIN" = PASS ]; then
    split "$(tool pp-check --out "$(winp "$O/nanoda.out")" --regex "$SK_EXPECT_PP_REGEX" --names "$SK_PP" | tr -d '\r')"
    [ "$ST" = PASS ] && WHY="statement /$SK_EXPECT_PP_REGEX/ and all of: $SK_PP printed by nanoda"
    status statement "$ST" "$WHY"
  else status statement SKIPPED "nanoda did not accept the export"; fi
fi

# ------------------------------------------------------------------------------------------------ tamper
if [ -n "$SK_TAMPER_NAT" ]; then
  if [ "$MAIN" = PASS ] && [ "$SK_EXPECT" = accept ]; then
    old=${SK_TAMPER_NAT%%:*}; new=${SK_TAMPER_NAT#*:}
    say "negative control: literal $old -> $new in a copy of the export; nanoda must reject it (type checker)"
    TE=$O/tamper/export.tampered.ndjson
    if tool tamper --export "$(winp "$EXP")" --old "$old" --new "$new" --out "$(winp "$TE")" $([ "$SK_TAMPER_ALL" = 1 ] && echo --all) \
       && TSHA=$(make_cfg "$O/tamper/nanoda.config.json" "$TE" ""); then
      nanoda_run nanoda-tampered "$O/tamper" "$TE" "" "" "$O/tamper/nanoda.config.json" "$TSHA"
      split "$(tool map-status --result "$(winp "$RES")" --role tamper | tr -d '\r')"
      status tamper "$ST" "$WHY"
      [ "$SK_KEEP_TAMPERED" = 1 ] || vft rmfile --base "$(winp "$O/tamper")" --path "$(winp "$TE")"   # our own scratch copy
    else
      status tamper ERROR "literal $old not present exactly once (SK_TAMPER_ALL=$SK_TAMPER_ALL), or no valid tamper config"
    fi
  else status tamper SKIPPED "main check did not pass (or expectation is reject)"; fi
fi

# ------------------------------------------------------------------------------------------------ integrity (final)
if [ "$SCOPE" = FINAL ]; then
  say "integrity: binding and run manifest re-verified before reporting"
  ok=1
  tool bind-verify --bind "$(winp "$R/bind.json")" --pins "$(winp "$PINS")" || ok=0
  check_cfg "$CFG" "$EXP" "$SK_PP" "$CFG_SHA" >/dev/null || { ok=0; echo "nanoda configuration changed"; }
  tool sites-check --pins "$(winp "$PINS")" >/dev/null || { ok=0; echo "semantic-site whitelist no longer valid"; }
  : > "$O/OLEAN_SHA256.end.txt"
  for d in $SK_BUILD_DIRS; do (cd "$d" && find . -name '*.olean*' -print0 | LC_ALL=C sort -z | xargs -0 -r sha256sum) >> "$O/OLEAN_SHA256.end.txt"; done
  cmp -s "$O/OLEAN_SHA256.txt" "$O/OLEAN_SHA256.end.txt" || ok=0
  RM_END=("${RM_ARGS[@]}"); RM_END+=(--olean-list "$(winp "$O/OLEAN_SHA256.end.txt")")
  tool runmanifest --mode verify --manifest "$(winp "$R/RUN_MANIFEST.json")" "${RM_END[@]}" || ok=0
  if [ $ok = 1 ]; then status integrity PASS "binding, input objects, export, configuration and tools unchanged at the end"
  else status integrity FAILED "something changed during the run (see run.log)"; fi
fi
sk_mem
finish
exit "$VRC"
