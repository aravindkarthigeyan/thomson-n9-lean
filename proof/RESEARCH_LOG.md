# N9 Thomson research log

Current status is recorded in `STATUS.md`. Dated entries below retain their
historical checkpoints, including obligations that were subsequently discharged;
later progress is appended rather than retroactively rewriting those entries.

## 2026-10-05

### 18:00-18:38 UTC: simplified endgame and formal integration

The consolidated Lean package now checks 198 public theorems in 35 authored
files and eight licensed vendor files. A separate invocation prints every
axiom closure; all contain only propext, Classical.choice and Quot.sound.
This snapshot has not yet received a second clean rebuild. Full candidate
stationarity and local displacement/energy identities are among the additions.

Seven additional exact Bernstein leaves localize the six true contacts to
radius 1e-8, after the existing coarse classification and antipodal exclusion.
The complete refined global replay passed. This allows an elementary,
deliberately loose Gram-Schmidt alignment estimate for the formal proof.

Claude's local audit suggested eliminating the normal Hessian penalty. A new
exact rational congruence certificate indeed proves Hc+RR^T >= (7/50)I with
zero penalty; our exact checker and Claude's independently implemented Arb
checker agree. The direct cubic minorant then gives an energy gap at least
0.04246*rho^2 for rho <= 1/500. No third-derivative estimates are needed.

New ambient block-Hessian and algebraic energy assembly modules remain drafts
outside the delivered Lean source until they build. Claude continues the
large SOS identity, Bernstein and finite-window data proofs. Status remains B.
The N8 reproduction advanced through inverse-bound row R96 during a scheduled
memory-isolated window; its complete package is still not reproduced.

### 17:24-18:00 UTC: direct minorant and formal local components

A second exact route now avoids the Hermite remainder altogether. The
degree41 reciprocal-square-root minorant is nonnegative by1655 Bernstein
leaves (maximum depth286); seven exterior intervals each need only one leaf
for a uniform gap1e-46. A separate checker uses direct binomial split formulas
instead of the generator's triangular de Casteljau algorithm. The older
Fraction checker independently reproduced1655 leaves. The complete global
chain passed with either minorant route.

`verify_global.py --bernstein --mutations` passed all arithmetic links plus
nine adversarial/reconstruction suites. All eight certificate inputs retained
their original hashes. The optional mutation mode needs pinned python-flint;
the ordinary global replay remains standard-library only.

New Lean modules built for arbitrary-degree three-point kernel positivity and
the factored certificate summation theorem, the rational-polynomial semantic
bridge, all-degree LP positivity, rational intervals, and strict diagonal
dominance. Six local-potential lemmas avoid a third derivative by an algebraic
cubic minorant; nine geometric lemmas supply tangent projection identities
and the complete-graph edge-cube bound. Three additional force-balance lemmas
now prove actual full candidate stationarity from its scalar radius equation,
without assuming the full gradient vanishes.

An independent ambient27 interval certificate, using normal penalty1000000,
proves the same transverse Hessian constant7/50 without an explicit tangent
frame. The generic augmentation-annihilation and normal-column algebra is
Lean checked; the actual large interval trace is still being formalized.
Claude owns Bernstein soundness/data, exact SOS reflection, and finite window
classification. The final global Lean theorem remains unproved; status stays B.

### 17:00-17:17 UTC: global mathematical closure and adversarial replay

The calibrated degree10 reduced SOS iterate was corrected at 800-bit precision
and exported as full rational Gram factors. The exact checker included all358
symmetric coefficient rows, not only the356 independent rows used for the
correction. The resulting energy loss is about3.983511875174096e-164, strictly
below the proved1e-92 Hermite exterior slack. Final certificate SHA256:
`c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9`.

This closes the former missing spectrum-localization lemma. All pair slacks
are nonnegative; their sum is below the exterior penalty, forcing seven true
contact windows. Antipodal exclusion, finite Gram-window classification and
the quantitative local theorem then give global optimality and uniqueness.
`GLOBAL_PROOF.md` assembles the entire argument and its exact trust boundary.
Status changed from D to B, never A: there is no global Lean theorem yet.

`verify_global.py` replays all finite premises and cross-stage constants from
source data in under a minute. The independent closure auditor rederived the
analytic bridges and repeated the exact checks. A FLINT full-polynomial audit
matched1771 coefficients and rejected five mutations. That implementation
shares basis definitions with the primary checker; Claude's additional
from-scratch verifier imports none of this project's code and independently
matches the same exact residual. Their audit found no major issue and103 exact
differential agreements. Minor parser/report issues were fixed, followed by
another successful complete replay, without changing the certificate data.

Lean development now includes generic complex Gram positivity, arbitrary-degree
Chebyshev recurrence, and actual R3 projection geometry. Root's11 endgame
lemmas built successfully: finite/pair slack localization, energy invariance,
relabeling, and final assembly with explicit unproved local/localization
hypotheses. These are useful formal bridges, not a substituted claim of the
unrestricted theorem. The N8 source build remains separately incomplete.

The earlier entries below preserve discovery history and failed attempts;
their statements of then-open gaps are historical, not the current status.

Started an independent attempt at global optimality and uniqueness for nine
unit-sphere points with unordered-pair Coulomb energy. No tabulated coordinates,
energy, or optimality are assumptions. Three parallel source audits cover N7,
N8, and older proofs/formalizations. Sources live in `../../work/prior`.

An isolated Python environment is being provisioned in `../../work/venv`.
Separate Lean toolchains and pinned Mathlib checkouts are being prepared.
The N7 source contains an N9 family definition, but its N9 optimality is not a
theorem. Candidate discovery below is independent of those coordinates.

Evidence categories used throughout: numerical observation; exact computation
with an independently inspectable checker; mathematical proof; Lean kernel
checked theorem. None implies the next without an explicit soundness argument.

### Source and toolchain preparation

Cloned and pinned the requested N7, N8 primary, and N8 Warrant repositories.
Read their theorem declarations, certificate normalization, exact rounding and
correction machinery, rigidity arguments, and accompanying paper sources.
The N7 complete build passed; final optimality/uniqueness theorems depend only
on `propext`, `Classical.choice`, and `Quot.sound`. The N8 Python exact checker
passed and rejected a corrupted coefficient. Its large Lean Coulomb closure
is building serially because concurrent certificate elaborations exceed RAM.
The Warrant complete cover is not yet built. See the per-source audit logs.

Downloaded and inspected Schwartz's N5 paper and source archives, Cohn-Kumar,
Yudin, and genuine formal spherical-code/SOS repositories. Formalizations are
identified by inspected theorem scope, not by repository titles. No inspected
source is assumed to establish N9. No N7/primary-N8 code is copied because a
source reuse license was not established.

### Independent candidate and local proof

Ran 256 independent random starts without supplied coordinates. Recovered a
one-parameter D3h family, then performed eight further unrelated random starts
and unconstrained 80-digit gauge-fixed refinements. All reached the same
diagnostic energy; this is evidence, not an exhaustive global search.

Derived the 36-pair energy symbolically and a strictly positive second
derivative on the whole family interval. Isolated its unique stationary radius
in a rational interval of width 10^-40. Exact interval checks prove every
nonrotational tangent Hessian eigenvalue exceeds 7/50. Procrustes alignment and
an explicit third-derivative bound prove energy gain at least rho^2/50 for
rho<=1/500. Entrywise Gram matching to 1/10000 suffices for this neighborhood.

The independent Lean package proves the candidate is admissible, the parameter
exists uniquely, the coordinate energy equals the six-term formula, and the
family minimum is unique. Full Hessian/local rigidity is not yet formalized.

### Exact global certificates and diagnosis

Implemented independent numerical polynomial SOS discovery and a separate
rational checker. PSD matrices are exported as rational factor products;
minorants are certified by exact Bernstein subdivision after the square-root
substitution; coefficient errors are subtracted explicitly from the bound.

Successive exact unconditional lower bounds were 25.7085606440 (order3),
25.7530992808 (order5), and 25.7586502537 (order6). An S3/S2 symmetry basis
reduced the largest order7 Gram block from120 to50. With an independently
proved maximum-product cut, order7 gives 25.7594400932758735013712.

Exact LP and slab certificates force max pair product<.5593 and min pair
product<-.73 in the candidate sublevel. Harmonic moments also force covariance
eigenvalues into (2.5,3.5), a centroid norm below3/8, and a uniformly independent
anchor triple. Exact structural tests and deliberately corrupted certificates
validate checker behavior; the written soundness argument remains necessary.

A sharp contact-nullspace order8 search, with a fixed Hermite minorant and
candidate moment/SOS kernels removed, returned negative numerical PSD margin.
This proves neither feasibility nor infeasibility. Higher orders and typed
rooted bounds remain under investigation. Interval Gram branch-and-bound
prototypes retain explicitly listed unresolved boxes; no coverage is claimed.

### Claude collaboration

Found the active Claude session and established two shared-file handoffs under
`../../claude/`. Claude independently reproduced the low-order SDP bounds,
audited the local proof, derived exact D3h Hessian blocks, and explored typed
minimum-pair certificates and alternative stationary configurations. Their
local audit found a missing frame-sanity check, now being added. Their numerical
landscape and SDP discoveries are never promoted to exact global conclusions.

### Later exact and formal milestones

The candidate parameter now has an independently checked degree-104 integer
polynomial, with a unique root in the same rational isolating interval.
The checker verifies the complete radical-elimination identity and rejects
a changed constant coefficient. No irreducibility assertion is needed.

The clean N9 Lean rebuild passed with every project proof object removed
beforehand. All 35 proved declarations print only the standard axioms
`propext`, `Classical.choice`, and `Quot.sound`. An independent axiom invocation
and corrupted-Lean-coefficient test are being recorded separately.

A new all-degree harmonic argument, combined with exact low-degree moment
checks, rules out every finite-degree sharp ordinary two-point Legendre LP
certificate. This is a rigorous obstruction to one route, not to three-point
SDP. It explains why improving the ordinary LP degree cannot yield a finite
sharp certificate for this candidate.

The sharp contact-nullspace order9 experiment improved the numerical margin
to about -1.89e-5, but its coefficient residual was about 1.54e-5. It supplies
no certificate and no rigorous infeasibility conclusion. Interval-product
SOS multipliers are now being tested as an alternative to degree escalation;
order7 gives a small exactly verified improvement to 25.759442945322.

Order8 with the interval-product multipliers produced raw objective
25.759885421536598. Rational factorization, exact minorant verification, and
the explicit coefficient-error deduction yielded the checked unconditional
bound25.7598562776688186793186. The remaining energy gap is about0.000130254.
This is an inequality for all configurations after the proved separation
dichotomy, not merely a sampled SDP objective.

The independent axiom invocation and intentionally corrupted Lean test both
finished as required. All35proved declarations have only the standard three
axioms; the corrupted square-root enclosure fails at its false rational square
comparison. The complete mathematical D3h-class theorem is also written, with
an exhaustive orbit classification and strict exclusion of the other phase
and all planar alternatives.

The exact tensor-Bernstein residual checker improved the order8 bound to
25.7598788814880747317918 without changing its PSD factors. The old l1 bound
is retained as a fallback, and finite box coverage is explicit. Further
Gram-domain pruning is being tested separately.

Tested the valid global moment term `mu*(9/28-detGram)`, whose triple sum is
nonnegative by the covariance determinant AM-GM bound. The order6 trial chose
mu approximately1.1e-9, so this constraint did not materially strengthen that
relaxation. It remains an optional exact-checkable generator feature, not a
claimed missing global ingredient.

### 2026-10-05 12:15 EDT: stronger exact reduction and solver diagnostics

Feasible-Gram Bernstein pruning improves the checked order8 bound to
25.75988332067154, leaving about0.000103211. Every discarded box has an exact
strictly negative Gram determinant upper bound; every other box is retained.

The independent finite Gram classification is complete. Exact six-value
spectra force congruence to the candidate. At true half-width1e-4, 9,515 exact
four-by-four determinant exclusions leave only candidate relabelings. The
covariance bound supplies the necessary positive anchor. All49 checks exclude
an added antipodal contact window, so seven-window localization is now a
sufficient global lemma, without a labeling assumption. Seven corrupted-data
and assertion-disabling tests were rejected. These are exact Python-checked
mathematical results, not yet Lean formalizations.

An independent exact dual measure now proves every ordinary finite-degree
two-point LP bound is <=25.729492377. Its nine rational atoms, uniform repair,
800 exact Legendre moments, and analytic all-degree tail proof are retained.
This is stronger than failure of attainment: even asymptotic convergence of
ordinary LP to the candidate is ruled out. Five corruption tests reject.

The order10 sharp-box Clarabel solve was stopped at13.5GB private memory with
no result. A new explicit CVXOPT dual formulation was independently derived
from max gamma subject to A(Q)=b and Q>=gamma I. Its dual has coefficient-row
variables, PSD adjoints, and one trace normalization. The first run requested
too strict tolerances: after an accurate negative-margin iterate, the solver
lost feasibility and ended unknown. No positive reported margin from that
failed run is accepted. The calibrated order8 rerun finished45.7s, status
optimal, gamma=-0.002770761850323145, coefficient residual7.21e-11. This remains
numerical evidence only, not a rigorous infeasibility theorem. Automatic
rounding now also requires successful status and a small coefficient residual.

Claude received the exact rigidity and hard-LP-ceiling results through the
shared handoff. Their typed degree7 and higher-point searches remain independent
numerical routes; no unverified claim from another agent is incorporated as proof.

### Exact replay and new global constraints

The full 29-command exact replay finished successfully, including every selected
stored SOS certificate, the independent SOS audit, local and geometric checks,
the degree-104 parameter polynomial, finite Gram rigidity, hybrid tree soundness,
and exact orbit-nullspace identities. The replay began 15:49 UTC; its commandwise
logs, durations, exit codes and hashes are in verification/full-replay/. Later
LP-ceiling, antipodal and corruption audits are separately retained under
verification/ and rigidity/ and are included in the updated replay driver.

Piecewise Legendre witnesses now prove at most 12 pairs below or at the threshold
-293/400 and at most 11 pairs below or at the threshold -3/4, for competitors
below the same exact energy cutoff. The independent Bernstein checkers and
corruption tests passed. A row-type refinement trying to exclude 13 edges at
other thresholds remained too weak and is not presented as an exclusion.

The sharp-lambda route has an exact new structural identity: the candidate's
unequal incident energies force lambda=1/9. An exact intervalcheck gives
cap-minus-prism incident energy >1/20. Therefore an affine-p sharp lambda
certificate cannot hold on the full pair domain [-1,1), because its negative
Coulomb coefficient is unbounded at 1 while its polynomial side is bounded.
This reinforces the need for the independently proved separation cutoff.

### Positive order10 numerical SOS lead, not yet a sharp proof

The explicit dual order10 SOS trial reached a positive common PSD margin about
0.00024984, with feasibility residuals around 5e-10 and duality gap 2e-7. The
overly strict stopping tolerance then lost feasibility and the final status was
unknown; no result from that final iterate is accepted. A calibrated rerun now
aims to save the accurate interior iterate. Its 356-row coefficient system has
two dependent rows. Exact algebraic basis construction, coefficient correction,
full-row completion and positive-definiteness verification remain required for
a sharp certificate.

Meanwhile the lambda cutting planes improve global triangle violations, but a
separate local Hessian diagnostic finds negative curvature at prescribed
contacts. This demonstrates why all sampled constraints being feasible is
insufficient. Future lambda searches will need contact-Hessian constraints or
another local repair.

## 2026-10-05, 19:00-19:20 UTC: Reduced Certificates and Astra Contribution

The D60 SOS/Bernstein/refined-window chain passed the full selected exact
replay. Independent regeneration reconstructed all mathematical D60 data from
the original certificate. Two smaller exact LP Bernstein covers and their
integer Horner interfaces were exported for the Lean separation/covariance
specializations. Original data remain immutable.

The newly promoted local modules formalize the block Hessian, its symmetry,
the algebraic local energy estimate, and conditional local coercivity. The
actual ambient interval circuit's generic arithmetic soundness is checked;
its first 1000 real nodes now pass ordinary kernel computation, with a false
square-root enclosure rejected and no axioms in either finite check. The
full 37815-node matrix connection remains unfinished. A 1000-node declaration
used about 6.35 GB private memory, motivating smaller proof/data chunks.

The user supplied the new Astra Pro Lean extension ZIP. All 140 manifest
hashes passed, and its Python suite was independently replayed successfully.
Its report honestly marks its 25 new Lean modules uncompiled. We adapted the
38-node rational comparison-energy proof to the D60 upper bound. After two
explicit rational-unfolding repairs, ReducedEnergy.lean compiled successfully;
candidate_energy_upper has only the standard three axioms. Its generator,
provenance, and review are retained. No wholesale merge was made, and its
original 1e-100 localization loss was not reused for D60.

Claude delivered compiled, adversarially reviewed original Bernstein and
finite-window rigidity modules. The latter derives an anchor directly from
the seven windows, removing covariance-to-anchor from the required global
route. D60/refined/LP adaptation, alignment, concrete Hessian linkage, and
final global theorem assembly are still in progress. Status remains B, not A.

## 2026-10-05, 19:20-20:16 UTC: Checked Geometry and Literal Hessian Bridge

Independently rebuilt all 19 imported Claude Bernstein/window modules from
unchanged source, with no copied object files. Fresh axiom tests report only
the standard three axioms. Eleven negative controls and one genuine-record
control passed. Generators, reviews, manifests, and reproduction logs are
retained under formal_support and lean/verification/claude-import.

All five alignment modules now compile. The explicit Gram-Schmidt estimate
turns entrywise Gram error at most 1e-8 into Euclidean configuration distance
at most 1e-4. Optimal orthogonal alignment supplies the zero-skew condition.
WindowLocalization also compiles, connecting the original contact order to
the finite classification, coarse Gram localization to the lower cutoff
-3/4, and refined windows to the local neighborhood. The conditional final
reduction is drafted and statically reviewed, but not yet compiled.

The actual ambient-circuit semantic layer has advanced substantially: checked
pair-block, finite-sum, constant-folding, coordinate-difference, rotation,
radial, matrix-product and point-major index-transport lemmas now compile.
The full literal data and geometric recipes are being built before the
37815-node arithmetic trace and congruence assembly. A separate semantic
mutation suite replays 11 corruptions against the actual frozen data in
exact Python arithmetic; its Lean tests are prepared, not yet compiled.

The package source inventory currently contains 661 public declarations in
83 local/Claude files, plus 8 Delsarte vendor files. This is NOT a completed
661-theorem consolidated audit. The historical 198-theorem consolidated
audit remains separately identified. Audit parsers were hardened for Lean
apostrophes and case sensitivity, with synthetic coverage/rejection tests.

The new Astra ZIP remains the newest Downloads file. Its adapted exact
candidate-energy upper bound and two arithmetic negative controls have
compiled. The generator's LF output and on-disk hash are now reproducible.
No unconditional global Lean theorem is claimed; status remains B.

## 2026-10-05, 20:16-20:49 UTC: Full Interval Trace and Concrete SDP Rebuilt

The final conditional global reduction and the two exact Horner-to-LP
identifications compiled. All 37815 ambient interval nodes then passed
ordinary Lean kernel checking in 296 bounded arithmetic declarations.
The false-square-root control was rejected, and the aggregate enclosure
theorem compiled. The 36 actual pair-block interpretations also compiled.
Independent regeneration reproduces the checked data and geometry source
byte-for-byte. The full matrix/congruence assembly is still uncompiled;
interval acceptance alone is not claimed as the Hessian PSD theorem.

Both completed Claude certificate deliveries were source-only imported.
The root team independently parsed and expanded L1's literal polynomial
trees: 859 SOS columns, 15 chunks, 786 kernel terms and all 1771 residual
coefficients match the exact certificate. The proved degree bound covers
all 9261 positions of the coefficient box. Four exact perturbations reject.

All 49 unchanged L1 modules then passed an ordinary serialized Lake rebuild
from absent local L1 objects. Fresh tests checked 19 axiom closures, eight
additional controls, the exact JSON statement, and four actual coefficient
mutations. All expected rejections were semantic arithmetic failures, not
missing imports or parser errors. The concrete `reduced_pair_bound` is now
independently kernel checked in the root package. Its full import report is
under `lean/verification/l1-import/`.

L2b's nine unchanged source files have been inspected, hash-checked and
imported. Their independent root rebuild is running. The coefficient bridge
between L1's Fin21 sum and L2b's range21 sum remains a work-only draft until
compiled. The final theorem and a quantitative stability corollary are also
work-only drafts, not asserted proof results.

Source coverage now includes 1417 public theorem declarations, but this is
not the final consolidated axiom audit. The clean source-copy/build runner
is prepared and independently reviewed; it has not yet frozen or built the
final snapshot. Status remains B.

## 2026-10-05, 20:55 UTC: Global Scalar Chain Checked

The independent L2b rebuild passed all nine ordinary Lake module builds and
four fresh-import fixtures: 75 axiom closures, twenty corrupt-data controls,
and concrete statement pins. The first reporting pass missed Lean's wording
for two axiom-free theorems; the repaired parser revalidated all successful
run hashes before recording PASS. No Lean source changed in this repair.

`ScalarCertificates.lean` then compiled all nine theorems with standard
axioms only. Exact finite coefficient identities connect L1 and L2b, the
Astra-adapted energy upper bound is below the LP cutoff, and the complete
scalar/finite-classification chain proves unconditional refined Gram
localization for every hypothetical competitor. This module was promoted
only after the successful compilation and closure check.

The compiler slot was released to the ambient-matrix author for the remaining
congruence, actual-Hessian assembly, bounds, and PSD theorem. An independent
source audit also replayed all 37815 arithmetic nodes, 81 diagonal sums,
nine radial sums, 729 rotation dots, and 1458 congruence dots. Transpose and
matrix-sign controls reject. This is separate evidence from, and not a
substitute for, the pending final matrix proof compilation. Status remains B.

## 2026-10-05, 21:20 UTC: Actual Ambient Matrix Identified

The actual shifted-Hessian entry theorem compiled successfully. It identifies
every circuit output with the explicit candidate's constrained Hessian plus
the rotation-column product minus `7/50 I`. The successful Assembly module
took 292.20 seconds and about 6.30 GB private memory; its three printed final
closures use only the standard axioms. CongruenceData also compiled.

Compilation exposed an autogenerated instance-name collision between two
separately built helper files. Giving the SumRecipe decidability instance an
explicit unique name resolved it; an independent byte comparison verified
that this was the sole helper-source change. Further repairs concerned
zero self-block unfolding, tactic indentation, and algebraic normalization
of the radial half-inverse sum. All literal matrix and arithmetic data stayed
unchanged. Failed runs were retained as failures, not counted as proofs.

The next semantic controls and congruence/PSD checks are currently gated by
memory availability, not by a mathematical counterexample. No unrelated
process was stopped. Final PSD, Completion, and the clean consolidated replay
remain outstanding; status is still B.

## 2026-10-05: Resumed Verification and Independent Numerical Recheck

The user resumed work after freeing memory and requested coordination with
Claude. Both sides agreed on a further independent lean4export/nanoda check,
using an isolated, pinned toolchain and a dedicated compiler window after the
final source freeze. Claude's separate statement audit found the challenge
faithful to the requested problem. This agreement is not a kernel-check result.

The ambient semantic fixture then passed all nineteen Lean checks: seven
genuine recipes, eleven formal rejection propositions for corrupted recipes,
and one sensitivity check showing that wiring alone does not fix the numeric
diagonal shift. The earlier low-memory attempt was interrupted by its reserve
guard and has no proof verdict. Only owned processes were stopped. Final
congruence checking resumed serially; the first of nine row modules passed.

An unrelated seed, `610052159`, was used for 64 fresh asymmetric random starts
and 900 new quotient-tangent perturbations. All search energies agreed with
the candidate at floating-point precision; the maximum final gradient infinity
norm was about `1.31e-8`. Minimum perturbation energy increases at radii
`1e-2`, `1e-3`, and `1e-4` were respectively about `6.06e-5`, `6.16e-7`, and
`5.24e-9`. Direct 100-digit pair summation and the symmetric formula differed
by about `6.86e-100`; the smallest computed nonrotational Hessian eigenvalue
was about `0.1439350052`. These are numerical diagnostics only.

The replay command is `python numerics/reconstruct.py --starts 64 --seed
610052159 --output results/candidate-independent-610052159.json`. Its JSON
SHA256 is `cda24ea9162ccbf235b1f5edf51bfbe2b077768b8668c69552dd510890fe3c81`.
No numerical result is used as a Lean proof premise.

## 2026-10-05, 22:30 UTC: Congruence Arithmetic Complete

All nine congruence row modules passed ordinary Lean checking, covering all
1458 exact 27-term dot products. The aggregate table identities, enclosures,
and final candidate PSD theorem remain in the current serial compiler queue.
The complete challenge and quantitative stability drafts are not yet compiled.

Claude accepted all six independently identified verifier-hardening groups:
semantic failure classification, frozen-source/object binding, resume checks,
scoped aggregate verdicts, immutable final target/axiom settings, and safe
path/dependency validation. Repairs and synthetic adversarial tests are in
progress. Neither agreement nor a prepared runner is treated as proof evidence.

Compiler resource settings are being made explicit: `LEAN_NUM_THREADS=1`
alone does not override the Lean shell's compiler thread count. The root
draft runner now passes `-j1 -M8192`; the delivered Lake configuration and
fresh-build runner are being reviewed for the same single-thread guarantee.
This resource metadata change does not change theorem statements or proofs.

## 2026-10-05: Unconditional Lean Global Theorem Passed

The complete actual candidate PSD theorem compiled with no enclosure or matrix
premises. Its final bounds module replaced noncomputable rational comparisons
with exact integer cross-products and a proved positivity-aware rational bridge.
The original failed decidability attempt remains a failed log. An independent
review replayed all 729 integer widening inequalities and confirmed unchanged
certificate data and interval directions.

`Completion.lean` then compiled all six final declarations: the complete
independent challenge, global optimality, uniqueness iff congruence, fixed
candidate admissibility, and the two fixed-candidate theorems. Each printed
closure contains only `propext`, `Classical.choice`, and `Quot.sound`. After
an evergreen header-only edit, the exact final source was rebuilt again and
promoted byte-for-byte. SHA256:
`c652dc08a7dae24d79dc17f30ee31497cf765a4cfadc146d0bf81983ce77e687`.
The final-source run took 27.32 seconds and 4.556 GiB peak private memory.

The assembled-workspace theorem is now checked. Status remains B until the
fresh source-only package build, complete type/axiom/control audit, archive
replay, and agreed independent verification are finished. No numerical or
Python checker result is an assumption of the compiled theorem.

## 2026-10-05, 22:55 UTC: Integrated Axiom Audit and Source Freeze

The quantitative stability module passed after a local addition-monotonicity
proof repair; its first failed attempt was not promoted. The final source
proves the explicit `10^-47` energy-neighborhood theorem with squared aligned
distance at most fifty times the energy excess, using only standard axioms.

The package entry-point check initially found the auxiliary LP anchor object's
absence. Compiling its unchanged source succeeded; it is not a premise of
Completion's selected global route. The full root and Solution then compiled.
Solution took 30.19 seconds with 4.832 GiB peak private memory. An independent
exact log audit found all 4056 unique requested declarations, 1996 axiom-free,
and all remaining closures subsets of the standard three. No missing,
duplicate, error, or unapproved-axiom report was accepted.

The new source-only snapshot `work/clean-n9/20261005T2253Z` contains 221 files,
199 Lean sources including fixtures, and 17 supplemental test actions. Its
`FREEZE.json` SHA256 is
`dd973d17255dd99ac1b562612f0e2562c2686421e837602464c5a03a9caf9d2e`.
An independent read-only audit checked exact membership, every source hash,
tool binary hashes, and absence of local objects or `.lake`. A separate
preflight matched all nine dependency Git pins and origins and found no
tracked changes or extra Lean sources outside dependency build directories.
No clean build success is claimed by these inventory checks.

Claude acknowledged the exclusive Phase 2 compiler window for its isolated
pinned exporter/checker tool builds and tiny controls. Codex is doing only
light offline work until Claude explicitly releases that slot. Source-only
ordinary Lake replay, final fresh controls, independent verification, and
archive extraction replay remain outstanding. Status remains B.

## 2026-10-05, 23:30 UTC: Resource Profiles Before a New Clean Build

Claude released its isolated tool-build slot after building the pinned
exporter and second kernel and running tiny positive/negative controls.
These are tool tests, not independent verification of the N9 theorem.
The final verifier is still undergoing the agreed source-hardening review.

Codex's first frozen ordinary-Lake attempt completed dependency preflight
and external-cache hashing, then waited below its uniform 11.75 GiB free-commit
gate before any measured target compilation. With Claude's explicit agreement,
only that verified idle parent was stopped; no child or unrelated process was
terminated. The snapshot and its evidence are retained as an inconclusive
resource-scheduling attempt, not a failed proof or a successful clean build.

An exact source-hash audit located prior resource profiles for 115 of 181
targets and none for the remaining 66. The latter are now being measured
serially from unchanged frozen sources, with direct Lean `-j1 -M6144`, an
owned Windows Job Object capped at 8 GiB, and 9.5 GiB commit / 6.5 GiB physical
prelaunch gates. Outputs are isolated and never used as imports. Resource
limits, interruptions, and unexpected exits are inconclusive. The plan binds
its runner, source inventory, tool and authorization; it reuses existing
imports and makes no clean-build claim.

The separately reviewed adaptive driver will retain the large gate for Data
and unrecognized work, use 9.5 GiB for the measured Assembly stage, and use
8.5 GiB only for eligible source-bound smaller profiles. It compares matching
metrics and rejects a resource classification after excessive measured growth.
A new source-only snapshot, full ordinary-Lake build, all 4056 axiom closures,
exact theorem-type pins and corruption controls remain mandatory. No proof
source or certificate changed during this scheduling work.

## October 6, 00:16 UTC: Profiles Complete; Exit-Code Harness Repair

All 66 isolated direct profiles completed with exit 0 and no resource
interruptions. Total child wall time was 1799.616 seconds; largest sampled
individual private memory was 4.21952 GiB, largest kernel Job commit 4.23600
GiB. The independently checked merge gives 181 source-bound profiles.
These runs used existing imports and remain resource measurements only.

The new 222-file source freeze has SHA256
`39bfc2d676c282b26dca0b4ccec8bed8928de1387cfc74ff59c0ba51e856c6c5`.
The independent diff found only the reviewed scheduling driver change and
new profile metadata; all proofs and 17 supplemental tests are byte-identical.
Its first target logged a successful ordinary Lake build of ThomsonN9.Basic,
but the runner recorded a null process exit code and correctly stopped.
The run is INCOMPLETE and preserved. A separate driver copy is being tested
for reliable Windows process exit-code capture before another source-only
freeze. No successful clean rebuild is claimed.

Claude accepted all four follow-up verifier findings: overly broad semantic
panic classification, unbound evidence inventories/configuration, external
cache changes across resumed attempts, and missing effective single-worker
controls. Repairs and an independent follow-up review precede its final slot.

At 00:22 UTC, the minimal exit-code repair passed independent real-process
tests and all 43 resource-policy controls. The new source-only freeze is
`02551b8cf7c98cab139d77e39a3a9a5c102857705c1dec7208360d4d96c35a45`.
An independent pre-build audit found the same 222-file membership as v2,
with only the process-driver bytes changed. All 181 modules, profiles, 17
supplemental tests, tool hashes, and proof sources match. Its fresh ordinary
Lake build has started; no earlier local object is copied into this snapshot.

At 01:06 UTC, the fresh ordinary build had passed 116 modules, including
`Certificates.AmbientKernelData`, the largest-memory interval-trace module.
That step exited 0 after 197.737 seconds. Its sampled largest owned process
used 8.252 GiB private memory; the owned Lake/compiler tree used 9.233 GiB.
These are different metrics and both are recorded. The 37,815-node trace
check is not yet the completed actual-Hessian theorem: its interpretation,
congruence, final assembly, and all end-to-end audits remain in the run.

## October 6, 01:44 UTC: Continuation After Claude Stopped

The user instructed Codex to continue after stopping Claude. The actual
Claude handoff marks its final verifier partial and explicitly says not to
wait for an independent final Claude run. Its delivered proof modules and
completed audits are unchanged. Codex will preserve the interrupted tools,
review their exact stopped state, and complete any remaining preparation in
a separately owned source copy. Results of that continuation are not Claude
verification results. N9 keeps the sole heavy compiler slot and priority
over the outstanding N8 reproductions.

The fresh source-only build has passed eight of nine congruence row blocks.
Its full final theorem, source, axiom, mutation, and archive gates remain
outstanding; there is no status upgrade.

A separate light symbolic calculation verified all twelve D3h matrices,
108 vertex actions and 144 group products. The tangent character is
`(18,0,-2,0,0,0)`; removing the rotational `A2' + E''` leaves multiplicity
blocks `(1,1,3,1,2,2)`, of total real dimension 15. A new numerical Hessian
calculation matched the saved spectrum to `3.56e-15`. This exact character
derivation and clearly labeled numerical check are documented in
`N9_CANDIDATE.md`; they change no Lean source or certificate premise.

At 02:05 UTC, the fresh ordinary build had passed all nine congruence blocks,
all final interval checks, diagonal dominance, zero-penalty transport, and
`Certificates.AmbientHessian`. Thus the actual augmented-Hessian PSD theorem
has now passed in the new source-only build, not only in the earlier assembled
workspace. The remaining global modules and final audit stages are still
running. A separate frozen-source statement audit found no weakening, checked
all 222 file hashes, and confirmed candidate nonvacuity and O(3)-plus-permutation
uniqueness; its unchanged report and hash inventory are retained in
`verification/INDEPENDENT_STATEMENT_AUDIT_V3.md` and the accompanying JSON.
This source review is explicitly separate from kernel/axiom replay evidence.

## October 6, 02:14 UTC: All Modules Pass; Final-Audit Parser Stops

The fresh v3 run compiled all 181 modules, including unconditional global
optimality, equality iff congruence, and quantitative stability. Default
targets, source tests, source audit, and the consolidated 4056-declaration
axiom audit passed. The final six exact theorem-type fixture also exited 0.
Its explicit `pp.universes` option prints `Classical.choice.{u}` and
`Quot.sound.{u}`; the outer audit compared only their undecorated names and
stopped before the final corruption tests. The raw six reports contain just
these standard axioms and `propext`. This is a postprocessing failure, not a
Lean proof rejection. The original RESULT is preserved as INCOMPLETE.

The repair will accept only the two observed annotated spellings in addition
to the three ordinary names, and explicitly check final theorem-name coverage
and duplicate reports. It will not strip arbitrary suffixes or accept unknown
axioms. Real-output and mutation tests, followed by an explicitly non-clean
validation precheck on the existing objects, precede a fresh source-only v4
run. Repeating the frozen pipeline keeps one coherent final provenance chain
instead of adding a new cross-run acceptance protocol. No proof or certificate
is being changed, and no incomplete run is relabeled PASS.

At 02:22 UTC, the separately reviewed Codex-owned independent checker ran its
first real selftest under an 8 GiB aggregate Job cap and 20-minute deadline.
Seven controls passed: a valid 33-declaration export, the genuine invalid
projection at `tc.rs:505`, and five distinct malformed-input/configuration
cases. The forced-memory-failure control did not trigger: the tiny valid
export still completed under the smallest 1 MiB per-process limit. The tool
record is FAIL and the outer stage is INCONCLUSIVE, with all logs preserved;
no final N9 export or second-kernel proof verification was attempted. The
child-specific memory footprint was not recorded, so this observation alone
does not establish that the limit was ineffective. A scoped diagnostic is
being prepared separately from the unchanged semantic checker.

The v4 final-audit precheck subsequently started in a separate staging tree,
using the existing v3 objects only as imports. Its explicit status is NONCLEAN;
its writes cannot overwrite the preserved v3 evidence. It exercises all
remaining release checks before the new fresh build is started.

That precheck stopped after seven successful Lean commands because the window
audit requests short theorem names under an open namespace, whereas Lean
prints fully qualified names. The strict exact-name validator correctly did
not infer a match. An inventory of all 17 supplemental fixtures found 41 such
requests in three positive fixtures (169 requests in total). New Codex-owned
copies will qualify only those print commands, preserving all theorem/proof
bodies and the original contributor files. The next staging and freeze audits
must explicitly account for these three verification-fixture changes; the
mathematical proof sources remain unchanged. The first precheck stays NONCLEAN
and INCOMPLETE, not a successful final run.

## October 6, 02:43 UTC: Qualified Precheck Passes

The second validation-only precheck completed all 20 scheduled checks. An
independent read-only audit verified every ordered report, exit status and
log hash, all 4231 axiom reports (4056 consolidated, six final targets and
169 supplemental requests), four expected Lean rejection fixtures, and the
separate corrupted-coefficient rejection. Original v3 sources and its
INCOMPLETE result were unchanged. The precheck RESULT has SHA-256
`6db1dbdf43d1e185a78a2bf8ab602e9cf09b90f824cb31132be3ded98f4bb5b3`.
It explicitly says `cleanBuild: false`; no reused-object check is counted as
a fresh build.

The new v4 source-only snapshot has manifest SHA-256
`22bb7406fef5a4379c856c8dbca26c8f964685e2bd036f24bdb45e0f5af3d10e`.
Before creation of its local build directory, an independent audit confirmed
222 frozen files, 199 Lean source/fixture files, 181 local modules and 17
supplemental fixtures. Its only four changes from v3 are the narrowly repaired
audit driver and three fixtures' fully qualified print commands. Mathematical
proof sources, certificates, dependency pins and resource profiles are
unchanged. A complete serial source-only rebuild started after the selftest
below released the exclusive compiler slot. No v3 local build objects were
copied into this snapshot.

## October 6, 02:45 UTC: Independent-Checker Selftest Passes

The Codex-owned verifier continuation now has a successful real eight-control
selftest. The revised resource wrapper accepts exact positive byte caps,
reads the assigned limit back before resuming the child, and records the
child's own peak and exit status. The semantic rejection classifier and its
source-checked whitelist are unchanged. The forced-resource control also
requires an explicit memory-failure signal; a generic crash or configuration
error cannot satisfy it. This repair passed independent source review,
tiny-process tests and 110 light tests before the real retry.

The real run accepted the valid 33-declaration export, rejected the invalid
projection at its actual semantic check, classified five malformed inputs as
errors, and obtained `STATUS_NO_MEMORY` at the 524288-byte child limit.
All eight required controls passed. Its TOOL_BUILD_RECORD has SHA-256
`c2ee08adb397c1495ff406f2ba122f8a6e00e6371ac3b57b0ce032f18e3ef9e9`.
The outer 8 GiB aggregate cap and 20-minute deadline were enforced; the
supervisor reported no changed prebound inputs and released its owned slot.
The previous failed run and revision-4 evidence remain preserved. This is
verifier-tool validation, not an independent check of the N9 theorem, which
has not yet been exported. No final Claude verification is claimed.

Independent review of the actual selftest replayed the raw classifications,
four cap receipts, source/tool bindings, authorization, log hashes and cleanup.
The 16, 4 and 1 MiB attempts used child peaks of 937984, 913408 and 929792
bytes and were correctly accepted; the 524288-byte attempt reached that cap
and exited with `0xC0000017`. Thus the earlier non-triggering control was not
evidence of an ineffective cap. The review JSON has SHA-256
`a4c1c308a6a199ea05d61a8a1cf698dc01fad0bab8666eac0cf0ee655e5c10cd`.
This accepts only the verifier selftests, not the final N9 proof export.

## October 6, 12:35 UTC: Resume After All 204 Fresh Checks

The user explicitly requested continuation until formal proof. The former
execution session is no longer available, and no corresponding Lean, Lake or
build-driver process was found. The frozen v4 evidence nevertheless contains
204 completed step reports, all marked passed: all 181 source modules followed
by the package, source, axiom, exact-target and corruption checks. The last
recorded step finished at 06:29 UTC. Local object hashes and the final external
inventory were subsequently written. No final RESULT receipt exists.

The two external object inventories are byte-identical, SHA-256
`4af1f70cbdd2fbd56cf33b9b53dbd24ad1ad26dd821c253efd883c8bf1b721f3`,
with 71336 entries each; their directory manifests are also identical. The
frozen driver's next operation uses repeated linear membership scans over
that inventory, potentially billions of comparisons. This is a plausible
bookkeeping stall, not a proven explanation of how the process terminated.
No compiler failure or final process exit is inferred from the missing receipt.

Independent agents are auditing the completed command/axiom/control evidence
and rehashing frozen sources and current objects. A separately reviewed
finalization may complete the same run's remaining bookkeeping with exact
case-sensitive maps and explicit provenance. It must preserve the original
driver and all existing evidence, never invent a missing compilation or
replace the absent final process status. No new RESULT has yet been created,
and the N9 second-kernel export and final release archive remain unexecuted.

## October 6, 13:06 UTC: Preserve Generated Axiom Log

The first read-only finalizer invocation stopped before any append because
the strict consumer found one unlisted file, `verification/FRESH_AXIOMS.log`.
There were no changed or missing frozen sources. The frozen `CheckAxioms.ps1`
produced this UTF-16 log during the recorded all-axioms step; its normalized
text is the corresponding bound stdout prefix, before the audit's final PASS
line. The problem was an exact-inventory mismatch, not a Lean rejection and
not a misused consumer return value.

After independent review, the root preserved only that generated, non-frozen
leaf outside the source snapshot, without changing any frozen source or old
flat evidence. Its 778516 bytes retain SHA-256
`6bdf92a6c0783aecf213cbf3725403c6592a92c13be5d28abba7214e059451d6`.
The relocation receipt records actual move time, paths, producer and step
hashes, and has SHA-256
`a833309c3947ce6341e89076f8a4ee2d9859bb286674a0d82bc89cc805165bd0`.
Both the original log bytes and this receipt will be included in finalization
evidence. The consumer's strict source-inventory rule is unchanged. Production
validation and final receipt creation have not yet succeeded at this checkpoint.

## October 6, 13:22 UTC: Full Finalizer Validation Passes

The actual read-only validation completed with exit zero. It replayed all 204
step reports, the exact axiom and theorem checks, every frozen source, all 543
recorded local objects, and all 71336 external objects against their original
hashes. The generated log's preservation receipt and exact relationship to the
bound axiom-audit stdout also passed. No metadata was appended by this command.

The reviewed finalizer has SHA-256
`079456c7e769d3a0a99cc29907d66e8c84320608d4a070f3af38c5cbd90a6ca4`.
Its separately authorized append invocation is now repeating the full checks
before exclusively creating the missing metadata and writing RESULT last.
No compiler is involved in this finalization, and no original process exit
status is inferred. The secondary N9 kernel check and archive replay remain
pending at this checkpoint.

## October 6, 13:35 UTC: Successful Clean-Proof Receipt

The append-only finalizer completed with exit zero after repeating every source,
local-object and external-object hash check and all 204 step/audit checks. The
successful RESULT has SHA-256
`1e10416d6f0e6abfd4c60dc12acf3fc8ba1d97c73c12d3078bcbe7076b25214f`.
It binds the original source freeze
`22bb7406fef5a4379c856c8dbca26c8f964685e2bd036f24bdb45e0f5af3d10e`
and explicitly discloses separate later metadata completion. All pre-existing
flat evidence bytes are preserved. No missing compiler execution, normal
original driver exit, or successful secondary-kernel check is inferred.

The receipt covers all 181 ordinary source-module builds, all six final theorem
types, all 4231 requested axiom reports across the consolidated/final/supplemental
checks, and the genuine rejection controls. Only the three standard logical
axioms occur. The current N9 release remains at B until the additional selected
secondary-check and archive gates finish.

## October 6: Preserve Unrecorded Lake Hash Caches

The secondary consumer scans a broader object suffix set than the frozen build
driver. Their exact difference was 181 `.ilean.hash` cached-output-hash sidecars,
each 16 bytes, with one per target and no missing recorded artifact. After the
successful clean RESULT, a separately reviewed operation preserved precisely
those leaves outside the consumed object tree. Its validation and actual apply
both completed successfully. All 222 frozen sources, 543 recorded artifacts,
the RESULT and all 632 bound evidence files remained byte-identical.

The separate receipt has SHA-256
`f2cd9587683687940a1b92c0ec08169a7191b266ceec632ab889536d5f60f3d0`.
It preserves all original 2896 sidecar bytes as hex as well as the original
files, paths, hashes and journal. The receipt and exact helper source are copied
into release provenance. Neither consumer policy nor proof object changed.
This metadata operation is not itself a proof check; the unchanged secondary
binding is being replayed against the actual clean receipt and object inventories.

## October 6, 13:41 UTC: First Archive Attempt Refuses Before Launch

The bounded archive wrapper did not create its staging parent before asking
the guard to exclusively create the child process-report directory. Windows
reported a missing path and the wrapper exited before any archive, extraction,
checker or child process ran. The failed plan and authorization remain preserved.
The one-line repair is in a new versioned wrapper; the original is unchanged.
Eight policy/regression test groups passed, including actual staging-parent
creation and duplicate-directory refusal with a mock guard, not a real process.
The proof receipt and all mathematical artifacts are unaffected.

## October 6, 13:46 UTC: Complete Theorem Export Succeeds

The unchanged full secondary binding accepted the actual finalized proof,
all source and object inventories, and the preserved metadata receipt. The
bounded export then completed its final-preset preflight and actual
`lean4export Solution -- ThomsonN9.thomson_nine_complete` invocation. Its
full dependency closure contains 55248 declarations in 9727409 JSON lines,
514465728 bytes, SHA-256
`6ea32a64e1aabdfbf06dc731537de0083f7e60e5eb76b408e5c418ccf1a93b3c`.

The exporter itself ran for 78.01 seconds; the whole supervised stage took
216.25 seconds and peaked at 5435043840 bytes of Job commit, below its 8 GiB cap.
All prebound inputs remained unchanged and the owned slot was released. The
raw pipeline exit 4 is its documented export-only success code; the supervisor
recorded `EXPORT_ONLY_COMPLETED`, not mathematical acceptance. The independent
kernel has not yet checked this closure. The concrete check plan is being
prepared from the actual export manifest and its full process provenance.

## October 6, 13:53 UTC: Candidate Archive Replay Passes

The repaired, separately authorized archive stage completed successfully.
The 31570299-byte source ZIP has SHA-256
`4091fba227a76fe00096a67600943407cca93e6367b058cc6e4977eee22e63ba`.
All five fresh-extraction checks passed, including the complete reduced/refined
exact chain, ambient interval checks with corruption controls, and matrix
recipes. Independent inspection found all 996 members equal to their manifest
and extraction, with all frozen proof sources and original clean evidence
preserved. No compiler or cached proof objects are bundled. The candidate
archive deliberately retains status B; it is not the final release ZIP.

## October 6, 14:14 UTC: First Independent Check Reaches Time Limit

The first final-preset nanoda check-only stage reached the exact 1200-second
outer wall cap. Its recorded outcome is `INCONCLUSIVE_TIMEOUT`, with owned
cleanup complete and no changed bound inputs. The checker had not emitted an
acceptance, a rejection, or an error; empty output is not a successful proof
check. Peak Job commit was 3103342592 bytes, below the unchanged 8 GiB cap.
Preflight, clean-source binding and export revalidation passed before the
type-checking process ran. This does not invalidate the already completed
ordinary Lean build, and it does not establish independent-kernel acceptance.

The first run, its unchanged export and all logs are preserved. Guard-result
SHA-256: `f809dcdd18b4b13fe41b337a481704b04a06d5fec075dacbade56d7a790fa66f`.
A new one-hour, same-memory-cap check is being prepared under the existing
reviewed supervisor, with a fresh authorization and output directory. No
automatic retry or proof-source modification occurred.

## October 6, 14:20 UTC: Longer Independent Check Starts

The first timeout and all 18 closed pipeline/process artifacts were independently
audited. Its abandoned, owned lease was preserved byte-for-byte before removing
only the owner file and empty directory; no other process or lease was touched.
The preserved 93-byte owner has SHA-256
`ede448301280b34e72fd4f18ba716bd26550c4348436ccbbbc0abead36214ca5`.

The separately reviewed retry plan has SHA-256
`d79119e1be3d15bf3886712a9b5233bed567a4d7b5d9672f8dafbe8265be17b6`.
It preserves all previous bindings, adds the timeout and lease evidence, and
changes only the wall allowance to 3600 seconds, with the same 8 GiB cap,
export, verifier, source closure, configuration and standard-axiom policy.
A fresh root authorization was issued and the retry actually started.
Preflight and saved-export revalidation passed. At this checkpoint the checker
is still running; no independent acceptance or rejection is asserted.

## October 6, 14:42 UTC: Independent Kernel Accepts The Complete Theorem

The separately bounded retry finished with actual exit zero. Nanoda printed
`ThomsonN9.thomson_nine_complete : ThomsonN9.Challenge.CompleteTarget`, all four
target definition bodies, and the final line
`Checked 55248 declarations with no errors`. The printed axiom declarations
are precisely the usual `propext`, `Quot.sound`, and `Classical.choice`,
including their types. The configuration makes every other axiom a hard error.

Actual nanoda time was 1128.72 seconds; the complete supervised stage took
1324.391 seconds. All prebound inputs remained unchanged, its owned processes
exited, and cleanup was confirmed. The successful pipeline verdict has SHA-256
`edb08cd643012dab1d45da556ac59ac3274ed58df4fe40c249290407a99e94bc`;
the outer process receipt has SHA-256
`ff741d2c5719dbd4670f7112a2f67c56de79c2cf8d62933b6ef0b7175b3b24cf`.
The same 514465728-byte export and proof sources were used. No proof, axiom
policy, checker source, or certificate was relaxed for the retry.

The first 1200-second timeout remains an inconclusive recorded attempt, not
a rejection and not an acceptance. The eight actual tool controls and primary
Lean false-certificate controls remain distinct from this successful full
check; no additional full-N9 nanoda mutation test is claimed. Release packaging
now incorporates the actual logs, source/tool pins, and independent audit.
