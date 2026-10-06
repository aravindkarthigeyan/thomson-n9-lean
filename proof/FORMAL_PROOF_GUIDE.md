# Formal Proof Guide

**Selected formal proof.** This describes the actual
D60 formal route, not the research history. The concrete positivity endpoint,
unconditional complete challenge, and quantitative stability theorem have
compiled with only the standard three axioms. Current source-only build
receipts and independent release-verification gates are tracked in `STATUS.md`.

Paths below are relative to `outputs/thomson-n9/lean/`. Except for root
`Challenge.lean` and the explicit `ClaudeL1/`, `ClaudeL2b/`, and `ClaudeWindow/`
paths, module paths are under `ThomsonN9/`. Unqualified theorem names have namespace
`ThomsonN9` unless another namespace is displayed.

## Statement And Candidate

Start with `Challenge.lean`, which imports only the candidate definition, not
its proposed global proof. `Challenge.CompleteTarget` requires existence and
uniqueness of the exact parameter, global optimality, and the complete
equality classification.

`Basic.lean` defines nine vectors in Euclidean real three-space, requires unit
norm and injectivity, and sums reciprocal distances over `i < j`, exactly 36
pairs. `Congruent x p` means `x i = Q (p (sigma i))` for an orthogonal linear
isometry equivalence `Q` and a permutation `sigma`. Reflections are allowed.

`Candidate.lean` gives two aligned equilateral triangles at heights
`+/-sqrt(1-r^2)`, each of radius `r`, and three equatorial caps, rotated by
60 degrees from the triangles. It has D3h symmetry. The parameter is the
unique zero of the original radical derivative in the exact interval

```text
[7105483340929538113277041792727912437680 / 10^40,
 7105483340929538113277041792727912437681 / 10^40].
```

`ParameterExists.lean: parameter_exists_unique` proves this using continuity,
exact endpoint signs, and strict monotonicity. `candidate_admissible` proves
that the candidate really has nine distinct unit points. Thus quantifying over
`CandidateParameter` is not vacuous.

## Scalar Certificates

Write `P = candidate r`, `f(t) = 1/sqrt(2-2t)`, and assume temporarily that
`E(X) <= E(P)`. This sublevel assumption is removed in the final step.

1. **A rational energy upper bound.**
   `Certificates/ReducedEnergy.lean: candidate_energy_upper` proves
   `E(P) <= U`, where `U = Certificates.ReducedEnergy.energyUpper`. It evaluates the energy
   at an exact rational radius using checked intervals, then uses the already
   proved minimum *within the symmetric family*. It does not assume global
   optimality. `ScalarCertificates.lean: reduced_upper_identity` identifies this
   `U` with the D60 certificate's `Claude.L1.rawEnergyReduced`.

2. **LP separation.**
   `LP/Concrete.lean: LPConcrete.inner_lt_separation`, instantiated in
   `ScalarCertificates.lean: sublevel_separation`, proves
   `inner(X_i,X_j) < M = 5593/10000` for every distinct pair. The proof uses a
   polynomial with nonnegative Legendre coefficients, a global Coulomb
   minorant, and a strict tail excess for `t >= M`. The unordered-pair LP
   normalization is `(81*a0 - 9*h(1))/2`. `ClaudeL2b/LPAdapterCodex.lean`
   provides the exact Bernstein minorant and tail checks; `LP/ConcreteLinkage`
   identifies its literal monomial polynomial with the Legendre polynomial.
   The separate covariance LP/anchor results are not premises of this route.

3. **The reduced degree-20 three-point certificate.**
   `ClaudeL1/Main.lean: Claude.L1.reduced_pair_bound` proves
   `U-L <= sum_(i<j) hNew(inner(X_i,X_j))` on the capped domain, with the exact
   rational `L = rawEnergyReduced - certifiedEnergyReduced`.
   `ScalarCertificates.lean: reduced_loss_small` proves `L < 10^-46`; numerically it
   is approximately `2.396e-54`, not zero. D60 refers to the rational rounding
   scale used for the degree-20 polynomial and factor data.

The third step instantiates
`SDP/CertificateBound.lean: SDP.factored_certificate_pair_bound` with a checked
polynomial identity of the form

```text
(hNew(u)+hNew(v)+hNew(t))/3 - U/36
    = corrected spherical kernels + weighted squares + residual polynomial.
```

The weighted squares are nonnegative on the capped Gram domain
`-1 <= u,v,t <= M`, `1+2uvt-u^2-v^2-t^2 >= 0`. The spherical kernel sum need
not be pointwise nonnegative: its sum over the configuration's ordered
distinct triples is nonnegative by the proved three-point positivity theorem.
The correction accounts for all repeated-index terms. Summing 504 ordered
distinct triples gives `14*(pairSum(hNew)-U)`; a coefficient-L1 residual bound
therefore costs exactly 36 times that residual, not 18 or 72 times it.

`ClaudeL1/Identity.lean` and its finite integer checker verify the entire
identity, including zero coefficients: the degree box has 9261 entries and
covers all 1771 coefficients of total degree at most 20. Rational rectangular
factors prove the kernel-block positivity; no floating-point solver result is
trusted by Lean.
`ScalarCertificates.lean: reduced_minorant_identity` checks all 21 coefficients
against the independently formalized L2b polynomial.

## From Energy Slack To A Single Gram Pattern

`ClaudeL2b/ReducedMinorant.lean: Claude.L2b.hNew_le_inv_dist` proves the actual
distance minorant. Thus each pair slack `f(inner)-hNew(inner)` is nonnegative,
and the preceding inequalities give a total slack at most `L`.

**Coarse windows.** `Claude.L2b.exterior_gap_new` proves a gap at least
`10^-46` outside the six contact windows of radius `10^-4`, on
`[-1+10^-4,M]`. Consequently no pair can lie there. Each pair belongs to one
of the six windows or to the retained near-antipodal interval
`[-1,-1+10^-4]`.
`WindowLocalization.lean: coarse_windows_of_energy_slack` is this argument in Lean.

**Finite classification.** The exact seven-window classification in
`ClaudeWindow/Main.lean` combines exclusion of the near-antipodal possibility
with existence of a three-point anchor of Gram determinant greater than
`1/100`, derived from the windows themselves. Checked interval/Gram-extension
tables force a single relabeling of the candidate's entire Gram pattern. This is not an
independent selection of the nearest contact for each pair.
`ClaudeWindow/Bridge.lean:
ThomsonN9.Claude.Window.window_rigidity_candidateAt_eta` transfers the
classification to any narrower width `eta <= 10^-4` using disjointness of the
coarse windows. `WindowLocalization.lean: gram_localization_of_windows` is the
application-facing bridge.

**Refined windows.** The coarse coherent pattern implies all pair inner
products are at least `-3/4` (`gram_close_lower`). On `[-3/4,M]`,
`ClaudeL2b/RefinedWindows.lean: Claude.L2b.refined_gap_new` supplies a gap of
`10^-33` outside windows of radius `10^-8`. Since `L < 10^-46 < 10^-33`, the
same nonnegative-slack argument forces these narrower windows. The same
finite classification yields a single permutation `p` satisfying

```text
abs(inner(X_(p i),X_(p j)) - inner(P_i,P_j)) <= 10^-8   for all i,j.
```

The complete checked conclusion is
`ScalarCertificates.lean: sublevel_refined_gram`, using
`GlobalReduction.lean: refined_gram_of_scalar_bounds`. No covariance,
unspecified anchor, or pointwise certificate hypothesis remains in this
sublevel theorem.

## Alignment And Local Coercivity

`GramAlignment.lean` constructs orthonormal frames and bounds the propagation
of Gram error into coordinates. `CandidateAlignment.lean:
candidate_refined_gram_alignment` specializes this to the candidate's top
triangle and error `delta = 10^-8`. It gives an orthogonal `Q` such that

```text
rho^2 := sum_i norm(Q(X_(p i))-P_i)^2 <= (10000*delta)^2 = (10^-4)^2,
sum_i (b_i[a]*P_i[c] - b_i[c]*P_i[a]) = 0,
where b_i = Q(X_(p i))-P_i.
```

The second identity is the rotation gauge. `Alignment.lean` obtains it by
minimizing total squared displacement over the compact orthogonal group and
testing planar rotations. It is proved, not imposed on arbitrary coordinates.
`WindowLocalization.lean: near_candidate_of_refined_gram` supplies the weaker
`rho <= 1/500` neighborhood needed by the local theorem.

Let `H = constrainedHessian P` (defined in `BlockHessian.lean`), the actual
27-by-27 ambient Hessian with the radial Lagrange-multiplier correction, and let `R` be its
three rotation columns. The concrete target is

```text
A := H + R*R.transpose - (7/50)*I  is positive semidefinite.
```

The arithmetic circuit encloses every entry for the whole exact parameter
interval, at scale `2^180`; its 37,815 node checks have compiled.
`Certificates/AmbientKernelAssembly.lean: shifted_hessian_entry_sound` has
compiled and identifies the literal circuit with this actual matrix. The
concrete modules form `C.transpose*A*C` using checked dot-product
recipes, prove that the rational `C` is unit upper triangular, and bound its
diagonal below by `1/1000` and every off-diagonal absolute value by `1/100000`.
The strict diagonal-dominance margin is `37/50000`. Invertible congruence
transfers positivity back to `A`; no numerical eigenvalue or condition-number
estimate is a premise.

**Compiled concrete endpoint:**
`Certificates/AmbientHessian.lean:
Certificates.AmbientKernel.candidate_augmented_hessian_posSemidef`.
All 1458 dot products, all 729 final enclosures, and the actual-matrix PSD
closure passed Lean. The integer-to-rational widening bridge proves positive
denominator and inequality directions explicitly. Independent source-level
and exact offline arithmetic audits also passed; they are not proof premises.

The generic consequence is already checked in `LocalCoercivity.lean`.
The gauge gives `R.transpose*b = 0`, so positivity of `A` implies
`b.transpose*H*b >= (7/50)*rho^2`. Exact candidate stationarity is supplied by
`LocalStationarity.lean` and `LocalEnergy.lean: candidate_force_eq_radialCoefficient`.
`LocalEstimate.lean: energy_gap_lower_algebraic` proves, without a floating Taylor
estimate,

```text
E(P+b)-E(P) >= (b.transpose*H*b)/2 - (1377/100)*rho^3.
```

For `0 <= rho <= 1/500`, `zero_penalty_energy_gap` gives
`E(P+b)-E(P) >= rho^2/50`. This is
`LocalCoercivity.lean: candidate_local_energy_gap`; its equality theorem forces
`rho=0`. No auxiliary normal-direction penalty is needed in this route.

## Global Conclusion And Remaining Gates

`LocalTarget.lean: quantitativeLocalTarget_of_augmentedHessian` handles orthogonal
alignment and makes the generic local conclusion usable by
`Endgame.lean: sublevel_congruent_of_localization`. The concrete PSD endpoint
proves that every configuration with `E(X) <= E(P)` is congruent to `P` and
has exactly the same energy. Every configuration outside that sublevel has
strictly larger energy. Congruence preserves the 36-pair energy, giving both
directions of the equality classification.

The checked generic assembly is
`GlobalReduction.lean: complete_of_refined_gram_and_hessian`. The compiled
`Completion.lean` supplies its two premises with `sublevel_refined_gram` and
the concrete PSD endpoint, then exposes `thomson_nine`,
`thomson_nine_unique`, and fixed-candidate versions without certificate
hypotheses. A separate parameter-existence conjunct prevents vacuity.

`QuantitativeStability.lean: thomson_nine_quantitative_stability` additionally
proves that `E(X) <= E(P)+10^-47` implies a squared coordinate distance, after
orthogonal transformation and relabeling, at most `50*(E(X)-E(P))`. It uses
the same exact certificate margins and local bound, without extra geometric
hypotheses. See `QUANTITATIVE_STABILITY.md` for the constants and reduction.

The source-only build, exact statement and axiom audits, mutation checks, and
independent verification must be bound to the same frozen source for release.
Their current receipts are tracked in `STATUS.md`. Claude stopped before its
final verification; no final Claude verdict is implied by the completed
component reviews. These are delivery gates, not additional mathematical
assumptions in the compiled public theorem.

## Alternative Route

The original high-precision Hermite-remainder argument remains a separately
audited mathematical alternative. The Lean path above uses exact Bernstein
certificates for the original rational minorant, a checked downward transfer
to D60 `hNew`, and coarse/refined exterior gaps. It does not import a claim
that the Hermite-remainder proof has been formalized. Numerical SDP discovery,
random optimization, and tabulated energies are likewise not proof premises.
