# Reproducible Worker Configuration

The verification helpers distinguish serialized module scheduling from the
worker pool inside each process. They now use both controls below:

- `LEAN_NUM_THREADS=1` for Lake and ordinary Lean-runtime child executables.
- Explicit compiler `-j1`, through package `moreLeanArgs = ["-j1"]` for all
  local libraries and directly on axiom/mutation/final-fixture invocations.

Setting only the environment variable is insufficient for this compiler
version. The local pinned `Lean/Shell.lean`, lines 219-224 and 300-307, sets
the shell default from hardware concurrency and accepts `-j` as an override.
The [v4.34.1 compiler entry point](https://github.com/leanprover/lean4/blob/v4.34.1/src/util/shell.cpp#L332)
constructs its task manager using that shell option. In contrast, the
[v4.34.1 ordinary runtime initializer](https://github.com/leanprover/lean4/blob/v4.34.1/src/runtime/object.cpp#L1052)
reads `LEAN_NUM_THREADS`. Both files were downloaded and read; the bundled
runtime binaries also contain the environment-variable name.

The local pinned `Lake/Config/LeanLib.lean`, lines 198-204, defines a library's
compiler arguments as the build-type arguments followed by the package and
library arguments. Thus the package-level setting reaches ThomsonN9,
Challenge, Solution, Delsarte, ClaudeWindow, ClaudeL1, and ClaudeL2b. It does
not claim to rewrite independently pinned external packages' configurations.

`Build.ps1`, `CheckAxioms.ps1`, and `RejectCorruptCoefficient.ps1` preserve
the caller's environment value and restore it in `finally`, including after
failure. The fresh-run helper does the same, records effective settings in
toolchain/step reports, and verifies the value seen through `lake env`.
`Build.ps1 -ListTargets` remains compiler-free and changes no thread setting.

The new lakefile setting changes build metadata, not any theorem or proof
body. It is included in the final source freeze and may invalidate existing
Lake traces; no rebuild was launched merely to apply it. No fixed `-M` limit
was added. Memory gating and the per-module peak/exit reports remain separate.
A configured single worker is not a claim of exactly one operating-system
thread: the runtime has management and blocking-task behavior of its own.

## Source Evidence

SHA256 values of the inspected bytes:

| Source | SHA256 |
| --- | --- |
| bundled `Lean/Shell.lean` | `4f584ae4d4cc859f39cdbb550df8e09417d1fd8e95046829ef821c2c95e2f940` |
| bundled `Lake/Config/LeanLib.lean` | `cf2fa832d3d0994131f3a6372c721d72cc5d55e1ac02f21a1f897df77743e09b` |
| downloaded v4.34.1 `src/runtime/object.cpp` | `e5c14603e2f547e6b631e682b6f5c6f7b25e7c0cccc43e620fc7ec56f2001e6b` |
| downloaded v4.34.1 `src/util/shell.cpp` | `502eaa752396cdff5bb448833a63be54cbbcbb3d36881eb10e235c04c64c0832` |
| resource-configured `lakefile.toml` | `a5dd209e28bf76a39ef3f3e77e17443d96446d576d91dee0b767e9775a6d5f90` |

The C++ originals are retained in the workspace's work-only
`verification/runtime-source/` preparation directory. This note records
source inspection and helper configuration, not a newly completed Lean build
or a measured memory reduction.

All five modified PowerShell helpers passed static parsing. A non-compiler
mock of Build.ps1's first child observed `LEAN_NUM_THREADS=1`, deliberately
threw, and the caller's sentinel value was restored. This was an environment
control test, not a successful Lean module build. Structured TOML parsing
confirmed the new argument and unchanged Mathlib revision.
