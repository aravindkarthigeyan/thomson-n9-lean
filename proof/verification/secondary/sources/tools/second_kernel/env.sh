# env.sh -- sourced by build_second_kernel.sh and run_second_kernel.sh (and by hand: `source env.sh`).
# Pins and paths of the self-contained second-kernel toolchain (lean4export + nanoda_lib).
# Everything Rust/Cargo lives under $SK/rust; nothing is installed system-wide, no PATH/registry edit is
# persisted: PATH is changed only for the current (sub)shell.  Never kills or signals any process.
# The pins below are plain assignments (not environment-overridable); run_second_kernel.sh --preset final also
# checks that they equal ../FINAL_PINS.json.  Tool-path overrides are recorded in SK_TOOL_OVERRIDES and make the
# final preset refuse to run.

W=${W:-/c/Users/REDACTED/Documents/Codex/2026-10-05/analyze-what-s-u}
SK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VF="$(cd "$SK/../.." && pwd)"

# ---- pins (see SECOND_KERNEL.md and PINS.json) ----------------------------------------------------------
SK_RUST_TOOLCHAIN=1.98.1-x86_64-pc-windows-gnu            # rustc 1.98.1 (48a229cea 2026-09-01), cargo 1.98.1 (797e8a9bc)
SK_RUSTC_COMMIT=48a229ceaefd4985c50990b14116b6d856af0985
SK_RUSTUP_INIT_SHA256=6d5b5709addc0122c916d8c810da8d8a7b086a5d64fa805ef404d506392aadc8   # rustup-init 1.29.1 (gnu)
SK_EXPORT_REV=076e8e57707e813375e8f9da8bf989799ace9680     # leanprover/lean4export, tag v4.34.0, format 3.1.0
SK_NANODA_REV=3a2407216ee84a75f9e1aead6803d0578be06ae7     # ammkrn/nanoda_lib 0.4.19
SK_NANODA_LOCK_SHA256=9b921e794ce5ed515eb31db9ada0c2f34df999b6c9b5135ad308a412872e42be  # committed Cargo.lock, LF bytes = git blob 88b43895 (29 packages)
SK_LEAN_TOOLCHAIN_LINE='leanprover/lean4:v4.34.1'          # the ONLY local change in the lean4export checkout
SK_LEAN_COMMIT=5045d0056413266e57c625dcd7c365b10e377c52    # Lean 4.34.1 that wrote the .oleans

# ---- paths -----------------------------------------------------------------------------------------------
SK_TOOL_OVERRIDES=""
for _v in LEAN_TC LEAN_EXE LEAN4EXPORT_EXE NANODA_EXE; do [ -n "${!_v:-}" ] && SK_TOOL_OVERRIDES="$SK_TOOL_OVERRIDES $_v"; done
LEAN_TC=${LEAN_TC:-$W/work/toolchains/lean-4.34.1-windows}  # Codex's toolchain, used read-only
LEAN_BIN=$LEAN_TC/bin
LEAN_EXE=${LEAN_EXE:-$LEAN_BIN/lean.exe}
PKG_CACHE=${PKG_CACHE:-$W/work/prior/thomson-n7-lean/formal/lean/.lake/packages}   # Mathlib d13f23b7 oleans, read-only
PY=${PY:-$W/work/venv/Scripts/python.exe}
RUN_STEP=$VF/tools/run_step.py
SLOT=$VF/.lean_slot
# Existing tool checkouts and executables are external READ-ONLY inputs.
EXTERNAL_SK=$W/claude/verify_final/tools/second_kernel
EXPORT_DIR=$EXTERNAL_SK/src/lean4export
NANODA_DIR=$EXTERNAL_SK/src/nanoda_lib
LEAN4EXPORT_EXE=${LEAN4EXPORT_EXE:-$EXPORT_DIR/.lake/build/bin/lean4export.exe}
NANODA_EXE=${NANODA_EXE:-$NANODA_DIR/target/release/nanoda_bin.exe}

export CARGO_HOME; CARGO_HOME="$(cygpath -w "$SK/rust/cargo")"
export RUSTUP_HOME; RUSTUP_HOME="$(cygpath -w "$SK/rust/rustup")"
export RUSTUP_TOOLCHAIN=$SK_RUST_TOOLCHAIN
RUST_TC_DIR=$EXTERNAL_SK/rust/rustup/toolchains/$SK_RUST_TOOLCHAIN
CARGO_EXE=$RUST_TC_DIR/bin/cargo.exe                        # called directly, not via the rustup proxy
export RUSTC; RUSTC="$(cygpath -w "$RUST_TC_DIR/bin/rustc.exe")"
export CARGO_NET_GIT_FETCH_WITH_CLI=false
export CARGO_INCREMENTAL=0
# Lake: keep every cache inside the lean4export checkout's own .lake; no artifact cache, no cloud cache.
export LAKE_CACHE_DIR; LAKE_CACHE_DIR="$(cygpath -w "$SK/build/lake-cache")"
export LAKE_ARTIFACT_CACHE=false LAKE_NO_CACHE=true
export PATH="$RUST_TC_DIR/bin:$LEAN_BIN:$PATH"              # process-local only
# single-worker policy and a fixed Rust panic format (the semantic-site classifier expects the RUST_BACKTRACE note)
export LEAN_NUM_THREADS=1 RUST_BACKTRACE=0

winp() { cygpath -w "$1"; }
mixp() { cygpath -m "$1"; }

# Footprint guard: the default per-user Rust locations must never appear (CARGO_HOME/RUSTUP_HOME are ours).
sk_footprint_check() {
  local bad=0
  for d in "$HOME/.cargo" "$HOME/.rustup" "/c/Users/REDACTED/.cargo" "/c/Users/REDACTED/.rustup"; do
    [ -e "$d" ] && { echo "FOOTPRINT: $d exists (it must not)"; bad=1; }
  done
  if reg query 'HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Rustup' >/dev/null 2>&1; then
    echo "FOOTPRINT: HKCU ...\\Uninstall\\Rustup registry key exists"; bad=1
  fi
  if reg query 'HKCU\Environment' //v Path 2>/dev/null | grep -qi 'cargo'; then
    echo "FOOTPRINT: user PATH mentions cargo"; bad=1
  fi
  [ $bad = 0 ] && echo "footprint ok: no ~/.cargo, no ~/.rustup, no Rustup uninstall key, user PATH unchanged"
  return $bad
}

# Free physical / free commit in GB (for logs; the gates themselves are in run_step.py).
sk_mem() {
  "$PY" -c "
import ctypes
class M(ctypes.Structure):
    _fields_=[('l',ctypes.c_ulong),('m',ctypes.c_ulong)]+[(n,ctypes.c_ulonglong) for n in ('tp','ap','tf','af','tv','av','ae')]
s=M(); s.l=ctypes.sizeof(s); ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(s))
print('free physical %.2f GB, free commit %.2f GB (commit limit %.1f GB)'%(s.ap/2**30,s.af/2**30,s.tf/2**30))"
}

# Claude slot handling (mkdir is atomic). Only our own owner file is ever removed.
SK_SLOT_OWNED=0
sk_acquire_slot() {  # sk_acquire_slot LABEL WAIT_MIN
  local label=$1 wait_min=${2:-0} waited=0
  until mkdir "$SLOT" 2>/dev/null; do
    if [ "$waited" -ge $((wait_min*60)) ]; then
      echo "Claude Lean slot $SLOT busy ($(cat "$SLOT/owner.txt" 2>/dev/null)); giving up"; return 1
    fi
    [ $((waited % 600)) = 0 ] && echo "[slot] busy ($(cat "$SLOT/owner.txt" 2>/dev/null)); waiting"
    sleep 30; waited=$((waited+30))
  done
  SK_SLOT_OWNED=1
  echo "second_kernel $label pid $$ since $(date -Is)" > "$SLOT/owner.txt"
  echo "[slot] acquired $SLOT"
}
sk_release_slot() {
  if [ "$SK_SLOT_OWNED" = 1 ] && grep -q "second_kernel .* pid $$ " "$SLOT/owner.txt" 2>/dev/null; then
    rm -f "$SLOT/owner.txt"; rmdir "$SLOT" 2>/dev/null; SK_SLOT_OWNED=0; echo "[slot] released"
  fi
}

# PE header stack reserve of a Windows executable (lean4export via leanc gets 100 MiB; nanoda: see build).
# Prints nothing and returns 1 for a non-PE file (fail closed: the caller compares the value).
sk_pe_stack() {
  "$PY" - "$(winp "$1")" <<'EOF'
import struct, sys
try:
    d = open(sys.argv[1], 'rb').read(4096)
    off = struct.unpack_from('<I', d, 0x3C)[0]
    assert d[off:off + 4] == b'PE\0\0'
    opt = off + 24
    res = struct.unpack_from('<Q' if struct.unpack_from('<H', d, opt)[0] == 0x20b else '<I', d, opt + 72)[0]
except Exception:
    sys.exit(1)
print(res)
EOF
}
