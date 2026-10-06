# Reproduction

Current release status and verification receipts are in `STATUS.md`. The
unconditional Lean theorem has compiled; its selected dependency route is
described in `FORMAL_PROOF_GUIDE.md`. `GLOBAL_PROOF.md` preserves the original
computer-assisted mathematical alternative. Numerical discovery is separate
and is not a formal proof premise.

The source release retains the complete global proof route and its exact
inputs. Sections explicitly labeled **full workspace only** describe older
exploratory checks whose additional data are not required by, or bundled with,
that release. The final source/archive manifest is authoritative about scope.

## Complete Global Chain

The selected formal-proof route uses the reduced D60 certificate and the
refined Bernstein windows. From this directory, with Python 3.12 and assertions
enabled:

```text
python verify_global.py --reduced --refined --report verification/global-reduced-replay.check.json
```

This is exact finite arithmetic checking, separate from the Lean kernel build
below. It recomputes the certificate premises rather than trusting saved
reports. The source release retains this route's complete checking inputs.

The original higher-precision mathematical route, whose SOS and Hermite data
are also retained for certificate regeneration, can be checked separately.
From this directory, with Python 3.12 and assertions enabled:

```text
python verify_global.py
```

This standard-library-only command recomputes the local certificate, both LP
minorants, Hermite enclosure, full rational SOS residual, finite Gram-window
classification, antipodal exclusion, and all cross-stage constants. It does
not read saved reports as evidence. The result and source/data hashes are in
`verification/global-chain.check.json`. The observed run took under a minute.

Independent polynomial reconstruction and five deliberate corruptions:

```text
python near_sharp/audit_final_certificate.py
```

That second audit uses pinned python-flint 0.9.0; the first needs no external
Python packages. The final SOS input is `near_sharp/near-sharp-d10.json`, SHA256
`c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9`.
Generation details and commands are in `near_sharp/EXACTIFICATION.md`.

An older alternative exact path avoids the high-order Hermite remainder
entirely (**full workspace only**; its unreduced cover is not in the selected
source release):

```text
python near_sharp/check_bernstein.py --negative-controls
python verify_global.py --bernstein --report verification/global-bernstein-chain.check.json
```

It proves the rational minorant directly with a finite Bernstein cover and
checks an exterior gap of `10^-46`. Its soundness argument is in
`near_sharp/BERNSTEIN_PROOF.md`; only the existing40-digit root definition is
needed, not the refined230-digit stationarity bracket.

The original complete chain plus nine adversarial/reconstruction suites is
one command (**full workspace only**; this optional mode also requires pinned
python-flint):

```text
python verify_global.py --bernstein --mutations --report verification/global-bernstein-adversarial.check.json
```

It checks both minorant routes, both LP certificates, local corruption controls,
integer SOS arithmetic, finite-rigidity mutations, and the independent full
polynomial reconstruction. Subprocess logs and their hashes are retained in
`verification/mutations/`. The runner checks that all eight certificate inputs
remain byte-for-byte unchanged. Some individual audit scripts refresh their
own report files; certificate data are never modified.

The older unreduced second localization step proves true six-contact windows
of radius 1e-8 after the antipodal window is excluded (**full workspace only**;
the selected release uses the reduced refined cover in the first command):

```text
python near_sharp/check_refined_windows.py --negative-controls
python verify_global.py --bernstein --refined --report verification/global-refined.check.json
```

It adds only seven single-leaf Bernstein checks. The exact conditional-to-global
link is documented in `near_sharp/REFINED_WINDOWS.md`.

## Exploratory Checks (Full Workspace Only)

This section is for the complete research workspace, not the source release.
It requires additional exploratory certificates and `verify_exact.py`, which
are intentionally outside the release's retained proof-checking closure.

From this directory, with Python 3.12 and assertions enabled:

```text
python verify_exact.py
python verify_exact.py --all-sos
```

The default checks need only the Python standard library. They replay the
local Hessian/root interval check, frame sanity checks, exact hull geometry,
LP separation, three-point identities/PSD/minorants, combined global
constraints, and interval-tree checks. Deliberate coefficient, bound, frame,
and false-exclusion corruptions must be rejected. Logs and their hashes go
to `verification/`. An incomplete tree is reported as incomplete; passing
its checker does not mean the global search is complete.

Do not use `python -O`: the checkers intentionally use exact assertions.

The latest finite rigidity and all-degree ordinary-LP obstruction can also be
replayed separately:

```text
python rigidity/check_exact_gram.py
python rigidity/check_window_gram.py
python rigidity/check_antipodal_window.py
python rigidity/test_rejections.py
python certificates/check_lp_ceiling.py certificates/ordinary-lp-ceiling.json --negative-control
```

The spectrum-window component is conditional when run by itself. Its energy
hypothesis is now supplied by the complete global chain. Its soundness proof
distinguishes true algebraic contact windows from the wider rational enclosures
used only for exclusion.

## Numerical Discovery

Python used for discovery: 3.12.14. Create an isolated environment and install
the fully pinned `requirements.txt`. No paid solver is required.

```text
python -m venv .venv
.venv/Scripts/python -m pip install -r requirements.txt
.venv/Scripts/python numerics/reconstruct.py --starts 256 --seed 20261005
.venv/Scripts/python numerics/high_precision.py --starts 8 --seed 91052026
.venv/Scripts/python certificates/generate_sos.py --degree 7 --upper 14/25 --output certificates/reproduced-d7.json
.venv/Scripts/python certificates/discover_sharp.py --degree 8 --output certificates/reproduced-sharp-d8.json
.venv/Scripts/python certificates/discover_sharp.py --degree 8 --basis symmetry-box-v1 --row-basis chebyshev --upper 5593/10000 --solver CVXOPT_DUAL --output certificates/reproduced-sharp-d8-dual.json
```

On Unix replace `.venv/Scripts/python` with `.venv/bin/python`. Floating solver
outputs may differ across machines; a newly generated certificate must be
passed through the exact checker, and its certified bound may differ slightly.
`discover_sharp.py` is an experimental feasibility search, not a decision
procedure. A negative numerical margin is not a proof of impossibility.
The explicit CVXOPT dual uses one variable per independent polynomial
coefficient row, reducing memory compared with the primal cone formulation.
Its numerical residuals are still checked and recorded. The first order10
Clarabel attempt was terminated after reaching approximately13.5GB private
memory; it yielded no certificate or conclusion.

The `sdp/README.md` documents the independent lambda-form and typed-kernel
preparation searches. `hybrid/README.md` gives finite interval-tree generation
and checking commands, all current unresolved frontiers, and remaining gaps.
Those two exploratory directories and `verify_exact.py --symbolic` belong to
the full workspace; they are not prerequisites for the retained global proof.
The source release includes the candidate reconstruction and LP/SDP discovery
entry points above, as well as the exactification and reduced-data generators.

The retained `formal_support/l1/` contributor files are historical provenance,
not a portable regeneration entry point. Their unchanged README refers to the
original `claude/formal/l1` workspace and scripts not included in the release;
`w2_l1_model.py` also retains that workspace's absolute path. Do not run those
historical commands from an extracted package. The generated `lean/ClaudeL1/`
sources are complete and are rebuilt by the ordinary package build below.
The portable certificate-data regeneration route is documented in
`near_sharp/reduced/INTEGRATION.md`; it is separate from Lean source generation.

## Lean

The separately frozen 60-digit certificate is replayed with
`python verify_global.py --reduced --refined`. It uses the Bernstein route;
its loss is too large for the original Hermite gap. Full regeneration and
negative-control commands are in `near_sharp/reduced/INTEGRATION.md`.

Regenerate the explicit Lean candidate-energy upper-bound proof separately
from checking it:

```text
python certificates/generate_energy_upper.py --source near_sharp/reduced/bernstein-reduced.json --output reproduced/ReducedEnergy.lean --report reproduced/energy-generation.json
```

The generator uses only exact standard-library integer/rational arithmetic.
Its report is not a kernel-check claim. The expected generated-source SHA256
is `a39d9ffd65721967b938c9c8505e0b3b556f79f91cd12ce3bc38e1399ba5c3e4`;
the checked copy is `lean/ThomsonN9/Certificates/ReducedEnergy.lean`.
Provenance and the scope of the incoming Astra Pro tests are documented in
`verification/ASTRA_PRO_REVIEW.md`.

The independent package is under `lean/`. Its pinned toolchain is Lean4.34.1,
and its pinned Mathlib revision is
`d13f23b723b8a846827a245b89c10fc7d3f11612`. With elan/Lake and PowerShell
available, use the serialized build:

```text
cd lean
lake exe cache get
powershell -NoProfile -ExecutionPolicy Bypass -File verification/Build.ps1 -Clean
powershell -NoProfile -ExecutionPolicy Bypass -File verification/CheckSource.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File verification/CheckAxioms.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File verification/RejectCorruptCoefficient.ps1
```

Do not start with unrestricted `lake build` on a cold project cache: parallel
certificate checking can exceed available memory. The helper builds all local
modules in topological order, one at a time. A later `lake build` may check the
default targets after that serial build has completed. Keep assertions enabled
in Python and allow enough free commit memory for the largest module.

`Challenge.lean` independently defines the full target; it never imports the
proposed proof. The concrete SDP, minorants, global sublevel localization, all
37815 Hessian interval nodes, actual matrix entry identity, congruence/PSD
closure, and unconditional global assembly have now compiled. The integrated
Solution also compiled and all 4056 requested axiom reports passed an exact
log audit. The current source-only release receipts are tracked separately in
`STATUS.md`. No Python result is imported as an axiom. `lean/README.md` and
`lean/verification/` distinguish historical builds, individual module checks,
and the required final source-only clean replay. The development dependency
junction is not packaged and is unnecessary for a fresh checkout.

The short build block above is not by itself a replay of every recorded
204-step audit: the latter also includes source-scanner tests, six final-type
ascriptions, and 17 supplemental fixtures. From `lean/`, after the serial
build, run the following. The four `Mut*.lean` fixtures are deliberately false
proof attempts: only their exact expected kernel diagnostics count as rejection.
The other fixtures must compile, including those proving that corrupted
certificate predicates evaluate to `false`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File verification/TestSourceScanner.ps1
if ($LASTEXITCODE -ne 0) { throw 'Source scanner tests failed' }
lake env lean -j1 fresh-verification/FinalTargetAudit.lean
if ($LASTEXITCODE -ne 0) { throw 'Final theorem type audit failed' }
$freezePath = '../evidence/clean/FREEZE.json'
if ((Get-FileHash -LiteralPath $freezePath -Algorithm SHA256).Hash.ToLowerInvariant() -cne '22bb7406fef5a4379c856c8dbca26c8f964685e2bd036f24bdb45e0f5af3d10e') {
    throw 'Unexpected frozen audit specification'
}
$freeze = Get-Content -Raw -LiteralPath $freezePath | ConvertFrom-Json
foreach ($test in $freeze.tests) {
    $lines = @(& lake env lean -j1 $test.path 2>&1)
    $code = $LASTEXITCODE
    $text = ($lines | ForEach-Object { $_.ToString() }) -join "`n"
    $text
    if ($test.expectation -eq 'pass') {
        if ($code -ne 0) { throw ('Fixture failed: ' + $test.path) }
    } else {
        $errors = [regex]::Matches($text, '(?m)^([^\r\n]+):(\d+):(\d+): error:')
        $errorLines = @($errors | ForEach-Object { [int]$_.Groups[2].Value } |
            Sort-Object -Unique)
        $wrongFile = @($errors | Where-Object {
            [IO.Path]::GetFileName($_.Groups[1].Value) -cne [IO.Path]::GetFileName($test.path)
        }).Count -ne 0
        if ($null -eq $code -or $code -isnot [int] -or $code -eq 0 -or
            $errors.Count -eq 0 -or $wrongFile -or
            $text -notmatch $test.expectedDiagnostic -or
            $text -match 'unknown module|unknown package|object file.*does not exist|out of memory|stack overflow|failed to create|maximum recursion depth' -or
            @(Compare-Object @($test.expectedErrorLines) $errorLines).Count -ne 0) {
            throw ('Expected exact kernel rejection missing: ' + $test.path)
        }
    }
}
```

This portable command block is a new transcription of commands already run in
the recorded clean build, not a claim that the transcription itself was run on
another platform. Its printed axiom reports must contain only `propext`,
`Classical.choice`, and `Quot.sound` (or no axioms). The retained original
`fresh-verification/FreezeRebuild.ps1` shows the exact report parser and count
checks used for the recorded run; its original-machine setup paths are history,
not required paths for the package build. Keep fresh local logs separately from
the immutable `evidence/clean/` receipts.

## Prior Proofs

Exact URLs, commit hashes, Lean versions, and Mathlib hashes are in
`STATE_OF_PRIOR_ART.md`; file-level architecture and reproduction status are
in `prior/N7_AUDIT.md` and `prior/N8_AUDIT.md`. To recreate the source checkouts,
clone each named repository and check out the listed full commit. Keep each
repository's original `lean-toolchain` and `lake-manifest.json`.

For N7 run `lake exe cache get` and `lake build ThomsonN7 ComparatorChallenges`
from `formal/lean`. Its independent challenge intentionally contains open
challenge holes; the proved N7 solution has no such dependency. The completed
N7 build and final-theorem axiom audit are retained in `prior/`.

For the primary N8 repository, `Coulomb8.UniqueMinimum:olean` is the actual
Coulomb theorem target, whereas a showcase containing assumptions is not a
proof. The independent Warrant requires `Complete`, not just its conditional
default target. These are large builds: the Warrant cover alone is documented
upstream at roughly30CPU-hours and one stage needs25GB. At the current checkpoint
the primary Coulomb build is incomplete and held while N9 verification uses
the compiler; neither complete N8 package has a
claimed successful local build. The exact Python checker of the primary N8
certificate did pass, including a corruption test.

The accelerated serial N8 build additionally experiments with Lean4.33's
header-only incremental snapshots. Only imports are cached; the leaf source
is elaborated each time and genuine `.olean` outputs are produced. This is
distinct from an ordinary clean Lake build and is reported as experimental,
including the Lean frontend's initializer caveat. The audit and JSONL logs
identify cache use per leaf. Neither mode is misreported as a completed build.

## Integrity and Provenance

The final source release is gated on the successful source-only clean build,
exact final theorem types, axiom closures, and negative controls. Its archive
manifest binds each retained file to its hash and rejects proof objects,
dependency caches, unpromoted drafts, and path traversal. The older workspace
`freeze_artifacts.py` inventory is not a substitute for this release gate.
Source and certificate hashes are integrity records, not replacements for
theorem checking. Upstream papers
and clones are retained outside the deliverable under the workspace's
`work/prior/`; no license-uncertain source has been copied into this package.

Claude's complementary research remains under the workspace's `claude/`
folder, with two append-only handoff files. Our deliverable records and verifies
the conclusions it uses; merely receiving another agent's result is not proof.
