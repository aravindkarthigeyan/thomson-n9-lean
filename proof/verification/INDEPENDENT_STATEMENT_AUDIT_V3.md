# Frozen V3 Statement Audit

**Result: no statement weakening or unacknowledged source axiom found.** This is a read-only source review, not a new Lean build or axiom-closure replay. No compiler, checkout mutation, process termination, or N8 operation was performed. Claude's statement audit was not used to reach these conclusions.

## Exact Scope

Snapshot: `work/clean-n9/20261006T0020Z-adaptive-v3`.
Its `FREEZE.json` SHA-256 is `02551b8cf7c98cab139d77e39a3a9a5c102857705c1dec7208360d4d96c35a45`.
The read-only helper `audit_statements_v3.py` checked all 222 frozen file hashes and sizes against this manifest: all match. It enumerated 199 frozen Lean sources and independently traversed 181 local modules reachable from the three default roots. This is not a claim to have manually read all 199 proof bodies.

The complete inspected-file hash inventory, all source hashes, direct external import names, source scans, and pair enumeration are in `independent-statement-audit-v3.json`, SHA-256 `4d6df6c0f3a028767a792615804a49f19407aac6a2c0444114f413fd56752ad2`.

## Mathematical Statement

- `Basic.R3` is Mathlib's `EuclideanSpace Real (Fin 3)`, and `Configuration` is `Fin 9 -> R3`. `IsSphereConfiguration` has exactly two conjuncts: every norm equals one, and the map is injective. It contains no energy, equality, symmetry, Gram-window, separation, rank, or closeness restriction.
- `coulombEnergy` is `sum i, sum j in Finset.Ioi i, (norm (x i - x j))^-1`. Thus it is inverse **distance**, with each unordered pair once: the independent enumeration has 36 pairs. It is neither squared-distance energy nor a doubled ordered sum. Distinctness excludes zero distances; the totalized inverse at zero does not create an admissible exception.
- `Congruent x y` requires a real **linear isometry equivalence** `g : R3 equiv_li[Real] R3` and a permutation of `Fin 9`, with `x i = g (y (p i))` for all indices. In Euclidean real three-space this is precisely an orthogonal transformation, including reflections, followed by relabeling. There is no translation, scaling, arbitrary pointwise isometry, or mere agreement of distance multisets.
- `Challenge.GlobalOptimality` quantifies over every candidate parameter and every admissible configuration, with the inequality in the requested direction. `GlobalUniqueness` is a full equality **iff** this congruence. The challenge imports `Candidate`, not any global proof. `CompleteTarget` also requires existence and uniqueness of the candidate parameter.

## Candidate Is Not Vacuous

`Candidate` defines explicit six prism vertices and three equatorial caps. The only parameter is a real root of the displayed radical stationarity equation in an exact rational interval of width `10^-40`, near `0.710548334092953811327704179272791243768`. These bounds are rational expressions, not floating-point values or assumed equations.

`ParameterSigns` proves strict opposite endpoint signs using exact squared rational bounds for square roots and `norm_num`. `ParameterExists` proves continuity on `(0,1)`, strict monotonicity there, obtains a root by the intermediate-value theorem, and proves uniqueness by injectivity of the strict monotone function. Its `candidateParameter_nonempty` constructs the required subtype inhabitant. `Completion.optimalParameter` uses `Classical.choice` on that theorem, not on an assumed inhabitant.

`Candidate.candidateAt_norm` and `candidateAt_injective` prove admissibility for `0 < r < 1`; `candidate_admissible` and `optimalConfiguration_admissible` instantiate these facts. `CandidateEnergy.candidate_distance` checks the explicit coordinate distances, and `candidateAt_energy` expands the same 36 inverse-distance terms to `symmetricEnergy`. The energy formula is therefore not substituted for an unproved geometric energy.

## Final Dependency Boundary

`GlobalReduction.complete_of_refined_gram_and_hessian` is intentionally conditional on sublevel Gram localization and the augmented-Hessian PSD result. `Completion.thomson_nine_complete` supplies both with `ScalarCertificates.sublevel_refined_gram` and `AmbientKernel.candidate_augmented_hessian_posSemidef`; the final theorem has no remaining certificate, numeric, localization, or equality premise.

`Endgame` correctly turns sublevel congruence into global optimality: either a competitor is above the candidate, or sublevel congruence forces equal energy. Its converse uniqueness implication proves energy invariance under the actual linear isometry and permutation. `LocalTarget` uses a proved minimal alignment and the concrete Hessian premise; the final PSD wrapper identifies circuit entries with the actual candidate augmented Hessian and transports the checked matrix inequality, rather than declaring PSD in the candidate definition.

`Solution` contains only imports, the two public challenge wrappers, and 4056 `#print axioms` commands. Reading these commands is not a replay of their output. The fixed-configuration endpoints `thomson_nine_fixed` and `thomson_nine_fixed_unique` expose exactly the user's theorem without a candidate-parameter argument.

## Axiom And Name Checks

Across all 199 frozen Lean sources, the token scan found no `axiom`, `sorry`, `admit`, `sorryAx`, `admitAx`, `unsafe`, `native_decide`, `implemented_by`, `ofReduceBool`, `ofReduceNat`, or `trustLevel`. No local module claims a `Mathlib`, `Lean`, `Init`, or `Std` module name. No declaration scan hit a replacement `Real`, `EuclideanSpace`, `LinearIsometryEquiv`, norm, square root, or inner product. The additional instance scan found only certificate-decision instances, not replacement real-space norm or arithmetic instances.

The package pins Lean `v4.34.1` and Mathlib `d13f23b723b8a846827a245b89c10fc7d3f11612`. The snapshot package junction targets the external package directory recorded in `FREEZE.json`. The actual Mathlib checkout HEAD equals that commit. Its inspected `PiL2.lean` definition is the standard `PiLp 2` space; `LinearIsometry.lean` defines the linear equivalence plus norm preservation, with no determinant restriction. A read-only `git diff` against the pinned commit found no change in either inspected file; their exact hashes are in the JSON report.

## Limits

No blocking finding emerged in this scoped review. Lexical scans cannot replace Lean's resolved declaration types, kernel checking, or actual transitive `#print axioms` output. I did not re-audit every generated certificate or every external Mathlib source here. The sole ongoing clean replay remains responsible for final build success, actual imported object provenance, and the final standard-axiom closure. This report does not upgrade an incomplete clean run to a successful one.
