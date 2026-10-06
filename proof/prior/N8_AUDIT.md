# N=8 Source and Certificate Audit

Audit date: 2026-10-05. This records inspected source, independently executed checks, and build status separately. A repository's own build claims are not counted as successful builds here.

## Frozen Sources

| Source | Commit / version | Lean | Mathlib |
|---|---|---|---|
| https://github.com/lukasliehr/Energy-Minimization-8-Points | `50d14bc06bd41f61573eb6a36eedb8d00759af8f` | `leanprover/lean4:v4.33.0` | `db584cd6d46c92f209a44c0f1c829460d327499d` |
| https://github.com/jstoobysmith/Thomson-N-8-Warrant | `2c35d62e07d72686931da4bc3e062d668e858eda` | `leanprover/lean4:v4.33.0` | same |
| Kryvonos--Liehr--Taylor, *Energy minimization for eight points on the sphere* | arXiv:2609.22077v1, 2026-09-18 | N/A | N/A |

Both repositories were cloned, not reconstructed from excerpts. PDF and complete arXiv TeX source were downloaded to `work/prior/n8-paper-2609.22077.pdf` and `work/prior/n8-paper-source/paperThomson__2_.tex`. The mathematical sections on the polynomial certificate, its exact correction, rigidity, and local Hessian were read directly.

Licenses: the Warrant repository README states `License: Apache 2.0`; no standalone license file was found. The primary repository has no license declaration found in the checked commit. Its mathematics can inform independent implementation, but source copying should not be treated as licensed. No primary-repository code has been copied into the N9 package by this audit.

The complete dependency pins are retained in each downloaded `lake-manifest.json`, including Batteries, Aesop, Qq, ProofWidgets, Plausible, importGraph, LeanSearchClient and Cli. Neither repository's pins were changed.

## Actual Public Statements

The primary repository's `Showcase_WithProofs.lean` defines the energy as a sum over `i < j`, so Coulomb means 28 unordered inverse chord distances. Its public `Thomson.coulomb_minimum` proves existence of a unique stationary squared height in `(0,1)`, global optimality of the corresponding square antiprism, and equality exactly up to a linear isometry equivalence and a permutation. It also identifies the exact energy formula. `Showcase.lean` is deliberately a statement-only file containing four `sorry`s; it is not the proved entry point.

The mathematical result underneath is `Coulomb8.coulomb_energy_N8_solution`, in `LeanCode/Coulomb/Coulomb8/UniqueMinimum.lean`. `LeanCode/MainTheorem.lean` imports the Coulomb, logarithmic and sufficiently-large-Riesz results; it is an aggregation file, not the certificate engine.

The independent Warrant development proves `Thomson.thomson_eight`, `Thomson.thomson_eight_unique`, and `Thomson.thomson_eight_minimiser_iff` in `Thomson/Complete.lean`. Its default `Thomson/Main.lean` gives a theorem conditional on three explicitly named certificate tasks. The expensive tasks are discharged only by the `Complete` target. A default `lake build` is therefore insufficient to reproduce its final theorem. Several old README statements still describe tasks as unfinished; `Complete.lean` is the relevant current source.

Both proved developments declare that the final dependency closure contains only `propext`, `Classical.choice`, and `Quot.sound`. This audit has opened their final theorem bodies and dependency interfaces; a completed local Lean build is still required to independently confirm that declaration.

## Primary Polynomial Certificate

Write `f(t) = (2-2t)^(-1/2)`. At the optimal squared height `a`, the four contact inner products are

```
A = a
B = 2a - 1
C = -a + (1-a)/sqrt(2)
D = -a - (1-a)/sqrt(2).
```

Their unordered multiplicities are `8,4,8,8`. The degree-at-most-12 Hermite polynomial `H` interpolates `f` and `f'` at those four nodes and derivatives of orders 0 through 4 at `-1`. The paper proves the minorant by a Hermite remainder. The Lean implementation instead uses an algebraic square-gap factorization followed by a finite Bernstein check:

```
1 - (2-2t) H(t)^2
  = (t+1)^5 [(t-A)(t-B)(t-C)(t-D)]^2 Q(t),
degree(Q) <= 12,
Q(t) > 0 on [-1,1].
```

The factorization is exact, inferred from interpolation and monic polynomial divisibility, rather than a small numerical remainder accepted as zero. Strict positivity of all 13 Bernstein coefficients of `Q(2x-1)` is checked using 128-bit dyadic intervals. The sign logic is that `H <= 0` already implies `H < f`; for positive `H`, the square-gap proves `H <= f`. Equality occurs only at the five interpolation nodes.

For triples of inner products `(u,v,t)`, define

```
Q0 = 1
Q1 = t-uv
Q(k+2) = 2(t-uv) Q(k+1) - (1-u^2)(1-v^2) Qk
Sk[i,j] = Sym(u^i v^j Qk), 0 <= i,j <= 6-k, 0 <= k <= 5.
```

`Sym` is the average of all six permutations, with repetitions included. The all-ordered-triple sum `Mk(X)` of `Sk` is positive semidefinite. This is proved from complex tangent coordinates: the homogenized Chebyshev kernel is the sum of products of real and imaginary parts of kth powers. Each rooted sum is two outer products, and symmetrization preserves the total sum.

Repeated-index correction is essential:

```
Rk = 6 Sk(u,v,t) + Sk(u,u,1) + Sk(v,v,1) + Sk(t,t,1) + delta(k,0) J/7.
sum_distinct Rk = 6 Mk(X).
```

The exact certificate identity is

```
(H(u)+H(v)+H(t))/3 - E*/28
  = sum_k <Nk Bk Nk^T, Rk>
    + Sym(z0^T W0 z0)
    + Sym((1-u^2) ze^T We ze)
    + Sym((1-u^2) zo^T Wo zo).
```

All coefficient blocks are positive definite. The reduced block sizes are `4,5,4,3,2,1,14,8,3`, totaling 192 upper-triangular coordinates. The scalar SOS basis polynomials vanish on the candidate's triple types. The moment bases encode complementary slackness against its moment matrices. Summing the identity over distinct triples gives exactly `12(E_H(X)-E*) >= 0`.

### Conversion to Exact Data

This is more subtle than rounding an SDP output to rational numbers. The parameter is irrational, so the final certificate is implicitly defined over the exact real parameter. A rational center and rational preconditioners are finite data for a rigorously bounded correction.

There are 102 independent symmetric monomial positions of total degree at most 12. Reconstruct the polynomial matrix `A(a)`, of shape `102 x 192`, from moment and SOS bases. Its entries are rational polynomials in `a`. The target coefficient vector `b(a)` also involves the exactly defined Coulomb contact values.

Two row functionals are exact dependencies: evaluation summed over candidate triples (`L0`) and its derivative with respect to family parameter while holding each tested polynomial fixed (`L1`). Both annihilate `A`. The target is annihilated by `L0` because it agrees in energy and by `L1` because the family is stationary. The coefficient row `(1,1,9)` is structurally zero. Delete that row and the constant and `(0,0,2)` rows; 99 rows remain. Select 99 columns and call the square matrix `M`.

For rational center `w0` and rational approximate inverse `C0`, exact dyadic calculations establish

```
||I-C0 M||_infinity <= 1/2
||C0||_infinity <= 2^16
||b_R - A_R w0||_infinity <= 2^-55.
```

Then `M` is invertible. Set `z=M^-1(b_R-A_R w0)`, insert it into the selected coordinates, and leave the others at their center. This gives a real vector `w` with exact selected coefficient equations and `||w-w0||_infinity <= 2^-38`. The two omitted nonzero equations follow from `L0`, `L1`, and `a != 1/3`; no residual is identified with zero. Positive definiteness is established over the entire correction box, including the unmodified coordinates: for rational `P`, every block satisfies `||P B P^T-I||_infinity < 1/2`.

The standalone Python checker repeats all this with rational polynomial arithmetic and integer dyadic endpoints. Lean independently checks the finite data and proves the soundness of the checks. Python output is not imported as a Lean axiom.

## Primary Lean File Map

All paths in this table are beneath `LeanCode/Coulomb/Coulomb8/`, except shared `Thomson8` files beneath the logarithmic development.

| Component | Main files |
|---|---|
| Mathlib-native configuration, candidate and energy | `Definitions.lean`, `Parameter.lean`, `ParameterBounds.lean`, `Candidate.lean`, `EnergyInvariance.lean` |
| Hermite polynomial and exact interpolation | `HermiteConstruction.lean`, `HermiteSemantics.lean`, `HermiteDegree.lean`, `HermiteArithmetic.lean` |
| Coulomb minorant | `SquaredFactorization.lean`, `MonicDivision.lean`, `QuotientModel.lean`, `QuotientArithmetic.lean`, `QuotientPositive.lean`, `MinorantSemantics.lean`, `Minorant.lean` |
| Integer/dyadic arithmetic and semantics | `Interval.lean`, `Dyadic.lean`, `DyadicArithmetic.lean`, `DyadicBox.lean`, `Bernstein13.lean`, `BernsteinSemantics.lean` |
| Polynomial kernel/basis definitions | `Polynomial.lean`, `Certificate.lean`, `Data.lean`, `BlockValue.lean`, `KernelBridge.lean` |
| Generic spherical positivity and counting | `Thomson8/MomentPositivity.lean`, `Thomson8/RCounting.lean`, `Thomson8/MatrixPairing.lean`, `MomentPositivity.lean`, `EnergySums.lean` |
| Reconstruct 102 x 192 coefficient matrix | `CertificateColumns.lean`, `CertificateColumnsData.lean`, `CoefficientBasis.lean`, `Expansion.lean` |
| Exact dependencies and missing-row completion | `Annihilators.lean`, `AnnihilatorSemantics.lean`, `TargetAnnihilators.lean`, `LinearCompletion.lean`, `FullSolution.lean` |
| Invertibility and bounded correction | `Correction.lean`, `CorrectionBounds.lean`, `InverseBounds.lean`, `ResidualBounds.lean`, `ReducedSolution.lean`, generated `InverseBounds/` files |
| Positivity of corrected blocks | `FinitePositivity.lean`, `BlockMatrix.lean`, nine `PSDBounds/*.lean` files, `SOSPositivity.lean`, `CertificatePositivity.lean` |
| Certificate and global lower bound | `VerifiedCAP.lean`, `GlobalMinimum.lean` |
| Strict minorant equality and Gram rigidity | `EqualityContacts.lean`, `ExtensionChecker.lean`, `ExtensionChecks.lean`, `ExtensionSemantics.lean`, `ContactRigidity.lean` |
| Final theorem and uniqueness | `UniqueMinimum.lean` |

The equality proof first forces all inner products into the four contact values; antipodal contacts from the endpoint interpolation are excluded by opposite-node incompatibility. It then checks all 64 ordered anchor Gram types and all 4096 anchor-extension types. Exactly 105 extensions occur in the square antiprism; 3991 are ruled out by a nonzero adjugate Gram residual. A nonsingular three-point anchor gives an orthogonal map, and injectivity exhausts the eight vertices. This is a discrete exact equality argument, not a numerical Hessian test.

## Independent Warrant Architecture

`Thomson/ThreePoint/BachocVallentin.lean` implements the same spherical kernel through degree 5, with block sizes `9-k` (degree parameter 8). Its positivity theorem `bv_positivity` is already generic in the number `n` of points. The addition theorem and tangent-frame construction are explicit Lean proofs. `Thomson/ThreePoint/Certificate.lean` packages a different certificate, with PSD kernel sum `F`, scalar coefficients `a0,a1`, and `0 <= lambda <= 1/18`:

```
a0+a1*t+3F(1,t,t) <= (1-18lambda) f(t)
F(u,v,t) <= lambda[f(u)+f(v)+f(t)]
E(X) >= [64a0 - 8(a0+a1) - 8F(1,1,1)]/2.
```

The inequalities are required only for pair inner products at most `5373/10000`. `Thomson/LP/Separation.lean` proves this restriction for any configuration with energy no greater than `19.6753`, using a two-point minorant and its slack. Triangle feasibility additionally includes `1+2uvt-u^2-v^2-t^2 >= 0`.

Its sharpness constraints use exact kernel bases and 24 pivot entries defined by an inverse matrix, with 95 fixed rational entries. An approximate inverse plus contraction encloses those exact pivots to approximately `2e-21`. Six reduced PSD blocks are checked by rational LDL and perturbation bounds. Pair nonnegativity uses exact double roots and Bernstein/Taylor intervals. Triangle nonnegativity uses two methods: exact vanishing and positive quadratic terms around five touching triangle types, and an exhaustive three-dimensional box covering elsewhere. The production covering is split into 637 Lean files, with four leaves per `decide +kernel` theorem. Repository comments estimate roughly 30 CPU-hours for that part.

The old scripts and README retain rejected approaches. In particular, a chord lower endpoint of `24/25` was false for the certificate, and was tightened to `9619/10000`. A floating-point-generated covering also failed at its first exact leaf; the replacement accepts leaves only using the exact mirrored arithmetic. These are useful warnings for N9, not gaps in the final source.

Useful discovery interfaces are `scripts/threepoint/bv.py:Sk`, `sdp3g.py:gen_bound`, `sharp.py:run`, the `gonogo*.py` family, and `tri5b_boxes.py:run`. They use NumPy/SciPy/CVXPY/Clarabel for discovery. Several paths are hard-coded to an old scratch directory and `N=8` is a module constant, so they require deliberate adaptation before N9 use. The primary repository exposes a cleaner exact checker, but no comparable general discovery front end was found.

## N9 Adaptation, Derived Explicitly

For any `N >= 3`, let `Psi` sum over ordered distinct triples and `M` sum `Sk` over all triples. The general repeated-index correction is

```
Rk,N = (N-2) Sk + Sk(u,u,1)+Sk(v,v,1)+Sk(t,t,1)+delta(k,0) J/(N-1).
Psi Rk,N = (N-2) M.
Psi[(H(u)+H(v)+H(t))/3 - E*/choose(N,2)] = 2(N-2)(E_H-E*).
```

Proof: split all triples into distinct, exactly-two-equal and all-equal cases. Each substituted `Sk(s,s,1)` contributes `(N-2)` times the ordered-pair sum. The constant supplies exactly `N(N-2) delta J`. For N9 the coefficients are therefore `7`, `1/8`, energy divisor `36`, and total energy factor `14`.

In the Warrant inequality form, replace `18` by `3(N-2)=21`, and replace `64,8` by `81,9` in the bound. With a general Legendre minorant `sum_l a_l P_l`, the lower bound is `[N^2 a0-N sum_l a_l-NF(1,1,1)]/2`. Every domain restriction must be established for N9 anew; the N8 separation number does not transfer.

For a six-distance N9 candidate, Hermite value-and-derivative interpolation gives 12 conditions. Adding endpoint multiplicity `m=1,3,5` at `-1` gives degrees `12,14,16` respectively. Since the remainder has a nonnegative factor `(t+1)^m product_alpha(t-alpha)^2`, each is a mathematically valid minorant. Candidate values, moment nullspaces, scalar vanishing ideals, and the exact correction matrix must all be rebuilt. N9 has two vertex orbits, so a rank-one moment formula cannot simply be transferred from a vertex-transitive configuration. The new independent derivation in `sdp/ORBIT_KERNELS.md` proves rank at most two for even kernel degree and at most one for odd degree, with explicit vectors over `Q[r]`.

The N8 finite Gram extension criterion cannot be copied verbatim: the three equatorial N9 vertices have inner products `(-1/2,-1/2,-1/2)`, hence singular Gram determinant. An N9 rigidity argument must select a nonsingular anchor using additional structure, or explicitly treat coplanar anchors. A finite extension classification may still work after such a selection.

## Independently Executed Checks

- The primary Coulomb exact checker passed on 2026-10-05 with FLINT rational polynomials and 128-bit integer dyadic intervals. It checked all nine corrected PSD blocks, all 192 annihilator columns, the 99 x 99 correction inverse, strict Bernstein minorant positivity, and all 4096 Gram-extension cases. Runtime reported by the checker: 4.20 seconds.
- Certificate SHA-256: `9337dcce088dc41acfdebf274330c414b9c690bb7f95c34f95cc7136c0fa6c2e`.
- An adversarial test added exactly `1` to the first matrix coordinate of the rational center. The checker rejected it at `Residual norm <= 2^-55`. Reproduction script: `work/n8_adversarial_check.py`; machine-readable result: `prior/n8_corruption_test.json`.
- Clean Lean dependency retrieval/build attempts are in progress. Final build status will be recorded below; no completed Lean build is claimed here yet.

## Build Status

The records below are chronological. The final section describes the current
fresh ordinary-build plan and supersedes earlier production scheduling or
resume suggestions. Experimental objects are retained as historical evidence,
not inputs to the new reproduction.

Both clean checkouts retain the original pinned toolchain and manifests. The standalone Lean 4.33.0 Windows distribution was downloaded into `work/toolchains` with no global environment changes. `lake exe cache get` completed with exit code 0 for both repositories; 8,690 Mathlib artifacts were decompressed. Their cache tool and its prerequisite Lean modules were locally built.

After the N7 complete build finished successfully, the primary N8 Coulomb theorem build was launched with `work/build_lean_serial.py`, targeting `Coulomb8.UniqueMinimum:olean` and its 1,193-module local dependency closure. The script topologically orders local imports and launches only one Lean proof compilation at a time. At the latest recorded checkpoint the first fifteen modules passed, including the generic spherical kernel PSD theorem and the Coulomb setup and definitions. The ongoing log is `prior/n8-coulomb-build.log`. Individual foundational Lean proofs took approximately 35-83 seconds, in addition to Lake overhead. The actual final N8 theorem has not yet completed, and neither repository has a completed clean full-package build at this checkpoint. This remains an outstanding reproduction requirement, not a claimed successful full build.

After the first 26 modules completed through Lake, the build switched to a direct pinned-Lean mode to avoid repeatedly traversing the entire cached dependency graph. It obtains `LEAN_PATH` from `lake env` once, uses the correct source root with `lean -R`, and creates genuine `.olean` and `.ilean` files by compiling each original source module. It neither creates nor forges Lake trace metadata. The direct log and its per-module source/output SHA-256 journal are `prior/n8-coulomb-direct.log` and `prior/n8-coulomb-direct.jsonl`. Direct compilation passed through module 55, `Coulomb8.CoefficientBounds.B021`, before pausing between modules for the profiling experiment below. This is separately recorded direct kernel-checking progress, not a claim that the original complete `lake build` has finished. The same helper can stop cleanly between modules when `work/STOP_N8_BUILD` exists.

### Experimental Header-Only Snapshot Trial

The pinned Lean 4.33 frontend supplies `--incr-header-save` and `--incr-load`. Inspection of `Lean/Elab/Frontend.lean` confirms that the first option calls `truncateToHeader`, discarding all elaborated source command bodies. Loading patches the source module name and reuses a matching imported environment; the new certificate theorem bodies are still elaborated and kernel checked. Its source explicitly labels initializer replay experimental and warns of theoretical divergence for unusual initializers. This mode is therefore recorded separately, not described as an ordinary clean Lake build or as an independent proof kernel.

The unmodified `Coulomb8.CoefficientBounds.B022` compiled with profiling and header save in 105.42 seconds (exit 0). The profiler reported 40.3 seconds in import and 5.41 seconds in `.olean` serialization. The next unmodified leaf `B023`, with identical imports, compiled using the saved header in 31.27 seconds (exit 0). The snapshot is 186,387,069 bytes; SHA-256 `8e69eab779bbf60dbaaf89c0706e34304dca5d0c10251fd3e4a3c191388be53b`. Its dependency map SHA-256 is `b42eb41937bb6e59c9a5c2d982d4fd1f5d8695be49d19830841ee071b83856cf`. Source and real output `.olean` hashes are in `prior/n8-header-trial.jsonl`; full profiler output is `prior/n8-header-trial.log`. A fresh ordinary-import axiom audit exited 0 and reported exactly `[propext, Classical.choice, Quot.sound]` for `checked1408`, `sound1408`, `checked1472`, and `sound1472`; its output is `prior/n8-header-axioms.log`.

The serial helper has a `--header-cache work/n8-header-cache` option. Cache keys include the ordered imports, Lean path, source root, command-line options (including profiling and extra arguments), and SHA-256 hashes of direct local imported `.olean` files. Only recurring import groups create snapshots; singleton groups compile normally to avoid large unused cache files. The helper does not edit any upstream source, fabricate a theorem, suppress kernel checking, or synthesize Lake trace files. Subsequent experimental progress uses its own `prior/n8-coulomb-header.log` and `.jsonl` journal. The final upstream N8 theorem and full-package builds remain incomplete until their actual successful completion is recorded.

A deliverable copy of the helper is `prior/build_lean_serial.py`. From the workspace root, an ordinary serial direct build can be resumed with:

```powershell
work/venv/Scripts/python.exe outputs/thomson-n9/prior/build_lean_serial.py work/prior/Energy-Minimization-8-Points Coulomb8.UniqueMinimum --lean-bin work/toolchains/lean-4.33.0-windows/bin --log outputs/thomson-n9/prior/n8-coulomb-direct.log --direct
```

Add `--header-cache work/n8-header-cache` and change the log name to `n8-coulomb-header.log` for the separately disclosed experimental mode. Remove `--direct` and omit the header-cache option for the original per-module Lake mode. None of these commands constitutes an assertion that all 1,193 modules have already passed.

### Bounded In-Process Header Reuse

The subsequent direct build passed the complete coefficient matrix, correction data, witness, and `Coulomb8.InverseData`; the latter took 543.5 seconds and peaked above 10 GiB of committed memory. Separate cached inverse-row leaves still briefly committed more than 6 GiB each, so two-to-four-process concurrency was rejected. A licensed Lean frontend driver now retains the imported header in memory between sibling leaves while fully elaborating and checking every new source command. Two fresh upstream leaves passed, a fresh ordinary Lean process audited their actual declarations and axioms, and a false second-file theorem `0=1` was rejected with no output proof object. Five further leaves passed in 62.7 seconds total, with subsequent leaves taking 4.4--5.5 seconds each. Production is capped at five siblings per process and serialized under a memory-availability gate.

This third build mode is documented precisely in `prior/N8_INPROCESS_BUILD.md`, with driver source, Apache license, source/version hash, genuine object hashes, negative-control log and fresh-import audit. Its active log is `prior/n8-inprocess-production.log`. It remains an experimental direct build, not an ordinary complete clean Lake build; the actual `Coulomb8.UniqueMinimum` and final-theorem axiom audit remain the completion targets.

The subsequent quiet-window run checked 67 more original inverse-row modules,
R30 through R96, in 17 successful bounded batches. The selected closure is now
checked through local module 232 of 1193. Peak process commitment was 8.479 GiB;
minimum sampled host commit reserve was 3.923 GiB. The temporary 10.5 GiB launch
gate applied only to these measured sibling batches. The build paused cleanly
at the agreed deadline, before R97/R98 and all unmeasured aggregates. Exact logs
and hashes are in `prior/n8-inprocess-quiet-window.log`, its JSONL journal, and
`prior/n8-quiet-memory.jsonl`. The final N8 theorem remains unbuilt.

The installed Lake 4.33 source has no build-job limit setting, consistent with the Warrant repository's explicit warning. Its supplied `scripts/kernel_build/build_all.sh` schedules some files requiring up to 25 GB alone, and its 637-piece triangle cover is estimated at 30 CPU-hours. Running an unthrottled `lake build Complete` would risk exhausting this host's memory. The serial helper avoids that issue for the primary proof.

Downloaded paper hashes: PDF SHA-256 `77de2b1d9bac877de24f53eb287fdb3749b6223f6777efebf12b46376b37df13`; arXiv TeX source archive SHA-256 `04f78bfb2ad7a72178c08abc33eead20ef6cfb88f68b5fdf3273816ab5d3e9a1`.

## Fresh Ordinary-Build Plan: October 6, 2026 UTC

No new N8 compiler or production checkout has run at this checkpoint. The
independently reviewed scope is 1,443 primary modules and 834 Warrant modules.
The latter includes the 832-module core plus public Challenge/Solution roots,
not the two optional unimported files in a broad 836-module inventory.

New pinned checkouts will be used without any earlier experimental local
objects. The only Lake configuration overlay is `weakLeanArgs = ["-j1"]`;
source proofs and original configuration remain unchanged. The proposed
initial attempts have an 8 GiB owned Job commit cap, 10.5 GiB free-commit
gate, 6.5 GiB physical-memory gate, 2 GiB reserve, and 1800-second module
limit. Resource interruptions are inconclusive. There is no automatic
escalation. Partial artifacts are quarantined only within explicitly owned
work paths after process cleanup.

The dispatcher checks exact compiler arguments, setup options, import paths,
source/tool hashes, all eight required artifacts including sidecars, logs, and the
original external-cache fingerprint before resumed reuse. Its 34
pure/synthetic tests and nine tiny Python-process guard tests pass; none is
an upstream proof build. The upstream 25 GB estimate is an anecdotal resource
guide, not a measured Windows single-worker minimum for every module.

Final checks must use `Showcase_WithProofs`, `Coulomb8.UniqueMinimum`, and
Warrant `Solution`/`Thomson.Complete`. Primary `Showcase` and Warrant
`Challenge` intentionally contain admitted statements; Warrant's default
`Thomson` target exposes conditional `_of_tasks` wrappers. Successful builds
of those alone would not prove the theorem. Explicit statement-ascription
fixtures, currently uncompiled, will check the unconditional global and
uniqueness types in addition to standard-axiom closure audits.

The complete work-only plan is `work/n8_orchestration/N8_FINAL_AUDIT_PLAN.md`;
run authorization remains disabled until the agreed compiler window after
N9 verification. Prior-art reproduction and N9 proof status stay separate.
