# Optional Second-Kernel Reproduction

The source package's pinned Lean clean build is the primary
verification. This optional check exports its proof terms and checks them
with nanoda, an independently implemented Rust type checker. It uses no
numerical solver, external theorem oracle, or pre-approved certificate
answer. The NDJSON export is an inspectable proof-term artifact.

**Observed Windows result:** the actual full N9 dependency closure was
accepted by nanoda with exit zero: `Checked 55248 declarations with no errors`.
It printed the complete theorem and all four requested challenge definitions;
its only axioms were `propext`, `Quot.sound` and `Classical.choice`. The final
pipeline passed preflight, export binding, clean-build binding, nanoda,
statement and final integrity checks. The raw evidence is recorded below.

The same Windows tool binaries previously passed eight actual smoke
controls, including a genuine invalid proof, while distinguishing input
errors and resource exhaustion. Those tool controls are separate from the
full N9 check; optional per-N9 positive/tamper reruns were not requested.
The POSIX/Linux recipe below has not been executed. It is not evidence of a
Linux build or bit-reproducible binaries.

## Pins

| Component | Exact source/version |
| --- | --- |
| Lean | `leanprover/lean4:v4.34.1`, commit `5045d0056413266e57c625dcd7c365b10e377c52` |
| Mathlib | `d13f23b723b8a846827a245b89c10fc7d3f11612`, plus the package's committed dependency manifest |
| lean4export | `https://github.com/leanprover/lean4export`, commit `076e8e57707e813375e8f9da8bf989799ace9680` |
| nanoda_lib | `https://github.com/ammkrn/nanoda_lib`, commit `3a2407216ee84a75f9e1aead6803d0578be06ae7`, package version `0.4.19` |
| Rust | `1.98.1`, rustc commit `48a229ceaefd4985c50990b14116b6d856af0985`, LLVM `22.1.8` |
| Cargo | `1.98.1 (797e8a9bc 2026-08-05)`; unchanged nanoda `Cargo.lock` |
| Export format | Lean NDJSON `3.1.0` |

The nanoda lockfile SHA-256 is
`9b921e794ce5ed515eb31db9ada0c2f34df999b6c9b5135ad308a412872e42be`.
Both external repositories carry Apache-2.0 licenses, retained in their
checkouts. No source proof or nanoda source change is required.

The deliberate exporter overlay is exactly one file: replace its upstream
`leanprover/lean4:v4.34.0` line in `lean-toolchain` with
`leanprover/lean4:v4.34.1`. It must use the same Lean version as the N9 object
files. The observed LF Git diff SHA-256 is
`16e572448c2809ce14f408d0a3e34a43f9f752082f911ee5c68c3310d62ae6e9`.

## Source-Based Recipe

Start in an extracted source package. Finish its documented clean Lean
reproduction first, including final theorem types, full axiom reports and
negative controls. `lean/` below means that **locally rebuilt** package,
not downloaded proof objects or an unrelated pre-existing checkout.
The following Bash recipe assumes Git, Python 3, elan and rustup are already
available. These are commands for a new operator, not commands run here.

```bash
set -euo pipefail
N9="$(cd lean && pwd)"
mkdir secondary-verifier
SECONDARY="$(cd secondary-verifier && pwd)"
export CARGO_HOME="$SECONDARY/cargo-home"
export RUSTUP_HOME="$SECONDARY/rustup-home"
rustup toolchain install 1.98.1 --profile minimal
elan toolchain install leanprover/lean4:v4.34.1

git -c core.autocrlf=false clone https://github.com/leanprover/lean4export "$SECONDARY/lean4export"
git -C "$SECONDARY/lean4export" checkout --detach 076e8e57707e813375e8f9da8bf989799ace9680
printf '%s\n' 'leanprover/lean4:v4.34.1' > "$SECONDARY/lean4export/lean-toolchain"
(cd "$SECONDARY/lean4export" && LEAN_NUM_THREADS=1 elan run leanprover/lean4:v4.34.1 lake build)
git -C "$SECONDARY/lean4export" diff -- lean-toolchain

git -c core.autocrlf=false clone https://github.com/ammkrn/nanoda_lib "$SECONDARY/nanoda_lib"
git -C "$SECONDARY/nanoda_lib" checkout --detach 3a2407216ee84a75f9e1aead6803d0578be06ae7
python3 -c 'import hashlib,sys; assert hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest()=="9b921e794ce5ed515eb31db9ada0c2f34df999b6c9b5135ad308a412872e42be"' "$SECONDARY/nanoda_lib/Cargo.lock"
(cd "$SECONDARY/nanoda_lib" && cargo +1.98.1 fetch --locked)
(cd "$SECONDARY/nanoda_lib" && cargo +1.98.1 build --release --locked --offline -j 1 --bin nanoda_bin)

export SECONDARY
EXPORTER="$SECONDARY/lean4export/.lake/build/bin/lean4export"
NANODA="$SECONDARY/nanoda_lib/target/release/nanoda_bin"
(cd "$N9" && LEAN_NUM_THREADS=1 elan run leanprover/lean4:v4.34.1 lake env \
  "$EXPORTER" Solution -- ThomsonN9.thomson_nine_complete) \
  > "$SECONDARY/export.ndjson" 2> "$SECONDARY/export.stderr"
```

The direct exporter command must exit zero, as the observed Windows exporter
did. The Windows orchestration wrapper's export-only exit code `4` means
`EXPORT-ONLY:PASS`; it is not the export executable's exit code and is not a
successful kernel verdict. The direct Bash recipe does not invoke that
wrapper or normalize a nonzero exporter exit.

Fresh platform binaries have platform-specific hashes. Record their hashes
and exact compiler versions; do not substitute them into a claim about the
observed Windows binaries. Keep all Git diffs and lockfile hashes. For
resource-limited machines, serialize the primary Lean build and use OS
process limits. The recipe does not reproduce the Windows Job supervisor.

Create this exact checker configuration from the absolute local export path:

```bash
python3 - <<'PY'
import json, os
from pathlib import Path
s = Path(os.environ["SECONDARY"])
cfg = {
    "export_file_path": str(s / "export.ndjson"),
    "use_stdin": False,
    "permitted_axioms": ["propext", "Classical.choice", "Quot.sound"],
    "unpermitted_axiom_hard_error": True,
    "nat_extension": True,
    "string_extension": True,
    "pp_declars": [
        "ThomsonN9.thomson_nine_complete",
        "ThomsonN9.Challenge.CompleteTarget",
        "ThomsonN9.Challenge.ParameterExistsUnique",
        "ThomsonN9.Challenge.GlobalOptimality",
        "ThomsonN9.Challenge.GlobalUniqueness"],
    "pp_to_stdout": True,
    "unknown_pp_declar_hard_error": True,
    "print_axioms": True,
    "print_success_message": True}
(s / "nanoda.config.json").write_text(json.dumps(cfg, indent=2) + "\n")
PY
# A large main-thread stack may be needed; this fails if the OS refuses it.
ulimit -s 1048576
"$NANODA" "$SECONDARY/nanoda.config.json" \
  > "$SECONDARY/nanoda.stdout" 2> "$SECONDARY/nanoda.stderr"
```

No `num_threads` option is supplied: pinned nanoda checks serially on its
main thread. The literal extensions implement Lean's Nat/String reduction
rules; they are not additional axioms. In particular, do not permit
`sorryAx`, `Lean.trustCompiler`, or arbitrary additional axioms, and do not
disable the hard error or add `unsafe_permit_all_axioms`.

The actual Windows build used Rust host `x86_64-pc-windows-gnu` and
`cargo rustc --release --locked --offline -j 1 --bin nanoda_bin -- -C link-arg=-Wl,--stack,1073741824`
to reserve a 1-GiB main-thread stack. That linker flag is Windows-specific;
the POSIX recipe uses an explicit stack limit instead.

## Scope And Acceptance

The root is the actual theorem
`ThomsonN9.thomson_nine_complete : ThomsonN9.Challenge.CompleteTarget`.
`CompleteTarget` includes the existence and uniqueness of the exact candidate
parameter, global optimality and equality characterization. Exporting just a
conditional lower-bound theorem would not suffice. Pinned `Main.lean` sends
the named root to `dumpConstant`; `Export.lean` recursively exports both type
and proof dependencies. Importing `Solution` only supplies the environment;
the root selects its complete dependency closure.

Require exit zero, a final `Checked ... declarations with no errors` line,
the expected full theorem type and all five requested pretty-printed
declarations, no checker error/panic, and exactly the allowed axiom policy.
Compare the printed target with the separately audited `Challenge.lean`,
not merely its name. Preserve export metadata, declaration counts, stdout,
stderr, configuration, source/object manifests and SHA-256 hashes.

Before claiming a new-platform checker run, repeat genuine good/bad proof
controls and distinguish malformed input, configuration errors, timeouts,
out-of-memory and unsupported formats from semantic proof rejection.
An unclassified panic is an error, not a successful negative control. The
Windows audit used eight controls and an exact source-site whitelist; its
record is `c2ee08adb397c1495ff406f2ba122f8a6e00e6371ac3b57b0ce032f18e3ef9e9`.

This reduces reliance on Lean's kernel implementation but still relies on
the stated exporter/checker implementations, compiler toolchains, OS and
the link between the rebuilt source, exported statement and proof terms.
It does not replace human statement review or the primary clean Lean proof.

## Observed Evidence

The source-only clean freeze is
`22bb7406fef5a4379c856c8dbca26c8f964685e2bd036f24bdb45e0f5af3d10e`;
its successful RESULT SHA-256 is
`1e10416d6f0e6abfd4c60dc12acf3fc8ba1d97c73c12d3078bcbe7076b25214f`.
The separate metadata finalization after the interrupted original driver is
disclosed in [BUILD_FINALIZATION.md](../BUILD_FINALIZATION.md). This did not
replace or recompile the completed proof objects.

The root `ThomsonN9.thomson_nine_complete` was exported from `Solution` into
514,465,728 bytes, 9,727,409 NDJSON lines and 55,248 declarations. The export
SHA-256 is
`6ea32a64e1aabdfbf06dc731537de0083f7e60e5eb76b408e5c418ccf1a93b3c`.
Its [statistics](export/export.stats.json),
[run manifest](export/RUN_MANIFEST.json) and
[export result](export/RESULT.json) are retained. The large export
is deliberately not included in the source archive; regenerate it from the
pinned, locally rebuilt sources. Its observed hash does not promise
cross-platform byte identity.

The successful Windows retry is `check-20261006-102019`, supervised as
`n9-complete-v4-20261006-check-02`. Nanoda used 1128.72 seconds and a reported
2.849 GiB peak Job commit; it exited zero. Its stdout printed the complete
global optimality and equality-characterization targets, the three permitted
axioms, and the final acceptance line. Stderr is empty.

| Evidence | Bytes | SHA-256 |
| --- | ---: | --- |
| [Checker stdout](check/nanoda.out) | 1,357 | `ffb9b96aa21dcf464f04b440bccb03630787d74de42674dc6242ab5f7c5ceec3` |
| [Checker stderr](check/nanoda.err) | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| [Checker result](check/nanoda.result.json) | 430 | `613e6426a6c942c732faa9924f921704cd949affe49e6cdcd9909458b977023d` |
| [Exact configuration](check/nanoda.config.json) | 725 | `95392725424189d9a706753101b7d0e291919e606563758485149c0df5cfc6be` |
| [Final pipeline verdict](check/VERDICT.json) | 1,959 | `edb08cd643012dab1d45da556ac59ac3274ed58df4fe40c249290407a99e94bc` |
| [Independent outcome audit](independent-check-audit.json) | 12,924 | `e305f1e6fc5884fa6bdf13285edcffb32fabb7bd62ae837f21ced35ac859bac7` |

The beginning and ending object manifests are both 37,819 bytes with SHA-256
`8b134d0d775af5ed4b892afcb92b3a8b2903244f5823a2164255951fc9f696a1`:
[before](check/OLEAN_SHA256.txt),
[after](check/OLEAN_SHA256.end.txt).
The [supervision result](supervision/check/process/result.json)
confirms owned-process cleanup, and the
[summary](supervision/check/summary.json) records no changed
prebound input. The outer supervisor itself makes no mathematical verdict;
acceptance is grounded in the raw checker output, exact configuration,
bound export and independent outcome audit.

The earlier `check-20261006-095413` hit its 1200-second outer timeout without
checker stdout, stderr or acceptance. Its complete small evidence and the
owned stale-slot preservation receipt remain under
[history/check01](history/check01/supervision/summary.json).
It remains `INCONCLUSIVE_TIMEOUT`, neither proof acceptance nor rejection.
The successful retry reused the same export under a 3600-second outer bound.

The [bundle manifest](BUNDLE_MANIFEST.json) records every included
evidence byte/hash and the explicitly omitted large export. Machine-local
paths in original records are preserved for provenance, not silently
rewritten into new-run paths. No Windows binary or cache is bundled, and the
unexecuted source-based recipe above is distinct from the observed Windows
verification.
