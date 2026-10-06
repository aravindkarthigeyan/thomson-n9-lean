# Independent Final Mathematical Scope Review

**No blocking statement or dependency-scope defect found.** This is a fresh
read-only source review of the frozen v4 theorem, not another compilation,
second-kernel verdict, or category-A release decision. No release document,
frozen source, certificate, or build object was changed.

Snapshot: `work/clean-n9/20261006-adaptive-v4`.
FREEZE SHA256:
`22bb7406fef5a4379c856c8dbca26c8f964685e2bd036f24bdb45e0f5af3d10e`.

## Statement And Nonvacuity

- `Basic.lean` defines `R3` as Mathlib's `EuclideanSpace Real (Fin 3)` and a
  configuration as `Fin 9 -> R3`. `IsSphereConfiguration` contains exactly
  unit norm at every index and injectivity. It contains no energy, symmetry,
  localization, certificate, or equality hypothesis.
- `coulombEnergy` sums inverse **distances**, not inverse squared distances,
  over `j` in `Finset.Ioi i`. This is exactly the 36 unordered pairs, once each,
  with no hidden normalization or self-interaction. Real inverse is totalized
  at zero, but injectivity excludes zero distances in the theorem's domain;
  `Energy.lean` explicitly proves positive pair distance from that condition.
- `Congruent` is an actual real linear isometry equivalence and an actual
  permutation of `Fin 9`, with pointwise equality. In finite-dimensional real
  Euclidean space this is precisely O(3) plus relabeling. It includes reflections,
  not only proper rotations; it does not introduce translations or approximate
  equality.
- `Challenge.lean` imports only candidate infrastructure. Its global target
  quantifies over **every** admissible configuration; its uniqueness target is
  a biconditional, not only the easy invariance direction.
- The parameter subtype could in principle be empty, so this was checked
  explicitly. `ParameterSigns.lean` bounds the original radical stationarity
  expression using exact square-root enclosures and proves opposite strict
  endpoint signs. `ParameterExists.lean` uses continuity, the intermediate value
  theorem, and strict monotonicity to prove a unique root and then
  `candidateParameter_nonempty`. No tabulated root or decimal equality is assumed.
- The candidate consists of six upper/lower prism vertices and three equatorial
  caps with explicit square roots. `Candidate.lean` proves unit norm and
  injectivity for every parameter. `Completion.lean` uses the proved nonemptiness
  to define one `optimalParameter`, proves `optimalConfiguration_admissible`,
  and supplies fixed-candidate global/equality theorems. Thus the universal
  subtype theorem is not being used to conceal a vacuous result.

## Concrete Premises Really Supplied

The final proof is not merely the conditional assembly lemma:

`Completion.thomson_nine_complete` applies
`complete_of_refined_gram_and_hessian` to the concrete theorems
`sublevel_refined_gram` and
`Certificates.AmbientKernel.candidate_augmented_hessian_posSemidef`.
The enclosing namespace is `ThomsonN9`; `Completion` is the module name.

The localization chain was traced through `ScalarCertificates`, `GlobalReduction`,
`WindowLocalization`, `ClaudeL1.Main`, and `ClaudeWindow.Bridge/Main`:

1. Candidate energy is bounded above by the exact rational `U`. The proof in
   `Certificates/ReducedEnergy` evaluates a fixed rational comparison radius
   and uses `symmetricEnergy_unique_min` only within the one-parameter family.
   `candidate_energy` identifies this family expression with the original
   36-pair energy. It does not assume the desired global optimum.
2. The capped domain `inner < 5593/10000` is derived by the concrete LP separation
   theorem from `E(X) <= E(P)`. It is not imposed on arbitrary competitors.
3. The SDP polynomial matches the scalar minorant coefficient by coefficient.
   The bound is `U-loss <= pairSum h`, with the full rational loss strictly below
   `10^-46`. The distance minorant uses distinctness, and `phi_inner` identifies
   the inner-product potential with the actual inverse norm. No sign reversal,
   double-counting switch, or different energy convention appears at this link.
4. Nonnegative pair slacks force coarse windows. Their near-antipodal alternative
   is retained until the finite classifier excludes it. `window_rigidity_free`
   derives a nondegenerate anchor from the window hypotheses; it does not leave
   a hidden covariance/anchor premise. Refinement to `10^-8` uses the derived
   lower inner-product bound `-3/4`. Disjoint coarse windows provide a single
   coherent permutation, rather than independent nearest-contact choices.
5. The permutation direction is explicitly inverted at the bridge. The Gram
   estimate supplies an orthogonal alignment with squared displacement at most
   `(1/10000)^2`, hence the required `(1/500)^2` neighborhood.

The local chain was traced through `AmbientHessian`, `LocalCoercivity`,
`LocalTarget`, and `Endgame`:

- `evaluated_hessian_eq` identifies the concrete circuit matrix with the actual
  flattened candidate constrained Hessian plus rotation augmentation minus
  `(7/50) I`. The final PSD theorem has only the candidate parameter argument,
  not a premise asserting a successful numerical or interval check.
- A minimizing orthogonal alignment is proved to exist. Its zero-skew moment
  is derived, so the rotation augmentation vanishes on the aligned displacement.
  This gauge condition is not silently assumed about arbitrary coordinates.
- Actual candidate force balance, candidate distances at least one, and the
  checked algebraic remainder supply the local energy lower bound
  `rho^2/50 <= E(X)-E(P)` for `rho <= 1/500`. Equality forces every displacement
  to vanish. The argument uses the actual ambient matrix, not a midpoint matrix
  or an unproved tangent-basis identification.
- `Endgame` handles all energies: sublevel configurations are congruent and
  hence have equal energy; outside the sublevel, the lower bound is immediate.
  The converse equality direction is proved by orthogonal and permutation
  invariance of the same unordered-pair energy. No assumed existence of an
  arbitrary global minimizer is needed.

## Definitions, Axioms, And Boundaries

The actual `Completion.lean`, `Solution.lean`, and frozen `FinalTargetAudit.lean`
were opened. The latter explicitly ascribes all six final types, including
candidate admissibility and both fixed-candidate statements. Conditional
intermediate lemmas do not remain as implicit final theorem arguments.

A separate textual scan of all frozen project/vendor Lean source, excluding
the dependency cache and deliberate bad fixtures, found no `sorry`, `admit`,
`unsafe`, `native_decide`, `native_eval`, `ofReduceBool`, `ofReduceNat`,
`implemented_by`, `skipKernelTC`, or `byAsSorry`, and no `axiom` or `opaque`
declarations. No alternate definition of the public energy, configuration,
congruence, parameter, or radius names was found. No project namespace named
`Real`, `Mathlib`, or `Matrix` was found. The lakefile's library roots do not
replace Mathlib; its only extra source directory is the licensed `Delsarte`
vendor library. Mathlib is pinned to `d13f23b723b8a846827a245b89c10fc7d3f11612`.

Ordinary `decide +kernel`, proof-producing tactics, and `Classical.choice`
remain visible and appropriate. In particular, choosing the candidate from a
proved nonempty subtype is not an added axiom of its existence. The standard
three-axiom closure is consistent with the previously audited actual printouts;
this review does not purport to replace their kernel/receipt validation.

This is a skeptical boundary and linkage review, not a line-by-line independent
reproof of every large certificate or all Mathlib internals. It found no
vacuous premise, weakened target, unprovided final certificate assumption,
incorrect inequality direction at the reviewed interfaces, or hidden additional
assumption. The full build, independent-kernel, archive, and provenance gates
remain separate evidence, with their current state controlled by the root task.

## Inspected Source Hashes

The paths below are relative to the frozen snapshot. Whole files or the relevant
public theorem/assembly sections were opened; additional supporting files
included `Energy`, `CandidateEnergy`, `FamilyMinimum`, `LocalEstimate`,
`LocalEnergy`, `CandidateAlignment`, Bernstein `Minorant`, and the lakefile.

| Source | SHA256 |
|---|---|
| Challenge.lean | ea32b730538646d67c9e4a5ef5efcdc892a75c27b4b3e1b861eaecac68d9fe9f |
| Solution.lean | 8995b0faf7e2a75c6f838e21c74c19e4e420203f53e00a8f6c3e730baf2386ec |
| ThomsonN9/Basic.lean | 9047b6eb65ff0b86bbc899b6633a2564a400c8681b66267ff9406ca2f0b9a7bb |
| ThomsonN9/Candidate.lean | 6cb03242b8a5a29249ef7cd6128e9cfaa09b8e07e44b4a429246fab5981251ef |
| ThomsonN9/ParameterExists.lean | 3f0cc396e7e62b31f279b7e446e86819bb353c270f5657944f5d10688f22c32e |
| ThomsonN9/ParameterSigns.lean | 59d55421411211cf14ddc97017303203e5139559a74005e9f42e80f54e03e59e |
| ThomsonN9/Completion.lean | c652dc08a7dae24d79dc17f30ee31497cf765a4cfadc146d0bf81983ce77e687 |
| ThomsonN9/ScalarCertificates.lean | 3a0ba171c999b205658a1933138766c7e0b7d15f1bd898d148af13ba33c147fe |
| ThomsonN9/GlobalReduction.lean | b82f77f761fb6b27845499812d86c38259a5ad0a6c6226c63003ad7b02dee3e2 |
| ThomsonN9/Endgame.lean | df04f54fd28a3c6622a46baa85bd558fa07625fd216a5c9229b38baf491815ba |
| ThomsonN9/LocalTarget.lean | ff20c80626145d8a7c73d3193a0219f43606d4099ed653208390a17fef20c831 |
| ThomsonN9/LocalCoercivity.lean | f5420c4d4ca2ef3f2b6451e173e73b94e37357a2d93020584a3d52612ac1972a |
| ThomsonN9/WindowLocalization.lean | cf8cc9f5990ef39e15f3a5b7322ae32f70a12d0964336a71e73177653cc0181b |
| ThomsonN9/Certificates/AmbientHessian.lean | eb16c7556934f39c50d88cbe76dd67b13dfeb2f91fa75f823af2c7b4e3025322 |
| ClaudeWindow/Bridge.lean | 5de430cb3637b43f5a9a3900728bea6b6193586ecf2a57fcb954da856dfe1b9b |
| ClaudeWindow/Main.lean | 3b9bba8cd26d0cec003acc774efe6ebcc07dbe4d5b8f5564c5f6024b87edbeb0 |
| ClaudeL1/Main.lean | 838a15d92e679979d941c525bbfa1bbe04735195ebe2c3b169327ba7a5f7d2e3 |
| ThomsonN9/Certificates/ReducedEnergy.lean | a39d9ffd65721967b938c9c8505e0b3b556f79f91cd12ce3bc38e1399ba5c3e4 |
