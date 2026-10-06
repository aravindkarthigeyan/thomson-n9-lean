# Proof Architecture and Release Verification

The original mathematical global proof is in `GLOBAL_PROOF.md`, with exact
finite premises replayed by `verify_global.py`. The selected unconditional Lean
theorem has also compiled; its route is mapped in `FORMAL_PROOF_GUIDE.md`.
The current source-only build receipts and independent release checks are
tracked in `STATUS.md`, separately from the mathematical theorem. No unproved
spectrum-localization assumption remains in that theorem.

## Independent Target

`lean/Challenge.lean` imports candidate infrastructure, not the proposed proof.
It defines global optimality and equality up to a linear isometry equivalence
and a permutation as propositions, without adding axioms. The candidate radius
is the unique zero of an explicit radical derivative in a rational isolating
interval, not an unexplained decimal. The candidate and family minimum have
actual Lean proofs. `ThomsonN9.thomson_nine_complete` (in module
`ThomsonN9.Completion`) supplies a compiled witness of the
complete target, including parameter existence and uniqueness. The challenge
does not import that module.

## Original Mathematical Chain

This is the first complete mathematical route. The selected formal route
below replaces its very high precision Hermite step and polar alignment.

1. Exact LP minorants show that every competitor with `E(X)<=E(P)` has all
   pair products below `5593/10000` and covariance `M>(5/2)I`. Cauchy-Binet
   supplies an anchor Gram determinant greater than `125/672`.
2. A degree-20 Hermite polynomial touches Coulomb at the six true candidate
   products and to order nine at -1. Exact interval divided differences
   produce a rational minorant h below it and a rational U above E(P).
3. Exact rational Gram factors give `E_h(X)>=U-36L`, with the **full**
   coefficient residual satisfying `36L<10^-92`. No omitted numerical row
   is assumed exact, and no floating PSD test is trusted.
4. The explicit Hermite remainder proves `f-h>10^-92` outside seven contact
   windows of half-width `1/10000`. Since every pair slack is nonnegative,
   any hypothetical competitor must have all pair products in these windows.
5. Forty-nine exact Gram determinant checks exclude the antipodal window.
   A finite anchor/extension classification checks 9515 determinant exclusions;
   all eight surviving nine-point patterns are candidate colorings.
6. The true window hypothesis gives a labeling with Gram error at most
   `1/10000` entrywise. Quantitative polar alignment gives `rho<=0.0018`.
   The exact tangent Hessian certificate and Taylor estimates give
   `E(X)-E(P)>=rho^2/50` for `rho<=0.002`, forcing rho=0.

The exact energy formula counts 36 unordered pairs. There are 84 unordered
triples and each pair belongs to seven, giving the factor
`84/(7/3)=36` in the residual loss. Equality is completed by local rigidity,
not by asserting that equality in a numerical SDP means congruence.

## Why the Tiny-Gap Route Works

A direct sharp algebraic identity would need exact contact-nullspace and row
dependency proofs. The successful route instead refines a positive numerical
face at high precision, rounds every full Gram factor to a rational matrix,
and pays every resulting coefficient error. The observed exact loss is about
`4e-164`, over 71 orders of magnitude below the deliberately crude exterior
gap. This converts an almost sharp certificate into an exact global proof
through quantitative localization and local uniqueness.

Discovery uses 356 independent coefficient rows; checking uses all 358
symmetric coefficient rows, equivalently all 1771 full monomial coefficients.
This distinction is essential. Numerical rank choices, condition numbers,
and reduced-block positivity are not accepted as proof obligations.

## Selected Formal Route

**Simplification after the first complete proof:** `near_sharp/BERNSTEIN_PROOF.md`
and its exact checker now replace the Hermite/remainder portion by a finite
polynomial certificate:1655 global leaves and7 exterior leaves prove h<=f and
an exterior gap of `10^-46`. This alternative requires no formalized Hermite
remainder theorem or230-digit root refinement. The candidate family minimum
already proved in Lean supplies E(P)<=Phi(rMid) at any rational midpoint.

The generic Chebyshev anchored-kernel positivity, repeated-index counting,
residual-to-energy normalization, all-degree LP positivity and covariance
identity now have Lean proofs. So do actual candidate force balance, the
algebraic pair-potential estimate, complete-graph displacement sums, and
generic interval/congruence/diagonal-dominance soundness.

At the 20:55 UTC checkpoint, the following parts are checked:

1. The exact D60 degree-20 polynomial reconstruction, rational Gram factors,
   every residual coefficient, and the pair-energy lower bound. All 49 L1
   source modules passed an independent ordinary Lake rebuild, axiom audit,
   statement pins, and genuine corrupt-coefficient rejection tests.
2. D60 minorization, the coarse and refined Bernstein gaps, and the LP tail
   separation bound. All nine L2b source modules passed the corresponding
   independent rebuild and twenty deliberate-corruption controls.
3. The finite Gram-window classification, free-anchor construction, contact
   order conversion, permutation direction, and refined-window linkage.
   All 19 original imported Claude modules were independently rebuilt. This
   route does not need the separately proved covariance-to-anchor theorem.
4. Unconditional sublevel localization. `ScalarCertificates.lean` connects
   the SDP, exact candidate-energy upper bound, LP, and finite classification:
   every admissible X with E(X)<=E(P) has a relabeling with all Gram errors
   at most `10^-8`. All five alignment modules and `GlobalReduction.lean`
   compile. This Gram bound gives coordinate distance at most `10^-4` and
   an exact zero-skew gauge at an optimal alignment.
5. All 37815 ambient Hessian interval nodes, 36 actual pair interpretations,
   and generic arithmetic, pair-block, finite-sum, rotation, radial,
   matrix-product, congruence, and index-transport soundness. The full trace
   and false-square-root rejection control passed Lean checking.

The actual augmented-Hessian PSD bound has since compiled, connecting the
checked trace to the concrete matrix and its unit-upper-triangular congruence.
All 1458 congruence products and all 729 final enclosures passed Lean.
`LocalTarget.lean` derives the quantitative local target from this bound.
`GlobalReduction.lean` derives the independent complete challenge from it and
the checked sublevel localization.

`Completion.lean` has now compiled the unconditional complete challenge,
global optimality, equality iff congruence, and fixed-candidate versions.
`QuantitativeStability.lean` also compiled the explicit near-minimum distance
bound. Their axiom closures use only the standard three axioms. No substantive
mathematical premise remains in the public theorem. The pinned source-only
build, expanded statement/axiom/control audits, reproducible archive, and
independent verification have distinct release receipts; their current status
is in `STATUS.md`. The exact selected formal route is mapped in
`FORMAL_PROOF_GUIDE.md`.

The original 35-theorem clean Lean baseline covers the candidate and symmetric
family. The earlier expanded 198-theorem audit is historical. The current
assembled `Solution.lean` audit checks 4056 unique public declarations: 1996
are axiom-free and the remaining closures use only `propext`,
`Classical.choice`, and `Quot.sound`. The frozen v4 source-only run records
passes for all 181 modules and 23 final audit/control steps. Its separately
recorded metadata completion and release checks are tracked in `STATUS.md`.
No missing obligation is disguised as a theorem assumption in a claimed
global Lean proof, and Python results are not introduced as axioms.

The exact D60 candidate-energy upper bound is also individually compiled in
`Certificates/ReducedEnergy.lean`, adapted from the user's Astra Pro delivery.
It evaluates the energy at a fixed rational comparison radius and invokes the
proved family minimum. It does not interval-evaluate the energy over the
whole 40-digit parameter bracket, which would be too imprecise for the
`10^-46` localization gap. New individual modules and imported Claude proofs
are not included in the historical 198-theorem consolidated count.

The refinement in `near_sharp/REFINED_WINDOWS.md` adds seven checked Bernstein
leaves after antipodal exclusion and sharpens the true Gram windows to 1e-8.
The full global arithmetic replay passes with this refinement. It permits
a crude Gram-Schmidt alignment estimate in place of the sharp polar bound;
the explicit frame estimate is now compiled without changing the already
complete mathematical proof. This was an optional strengthening of the original
mathematical route and is used by the selected Lean alignment route.

## Investigated Alternatives

Ordinary two-point polynomial LP cannot be sharp here: an exact all-degree
dual witness proves a ceiling below `25.73`. Lower-order three-point bounds,
minimum-pair exclusions, deletion bounds, far-neighbor graph constraints,
typed kernels, rank-based interval trees, and a lambda-contact formulation
were explored and retained in the research log. A sampled-feasible lambda
iterate failed an adversarial contact-Hessian test. None of these incomplete
routes is needed by the final global chain.

The N7/N8 papers and code informed the architecture. The independently authored
N9 code uses rational factors and a completely paid residual, rather than
copying their unlicensed implementation or assuming their case-specific
certificates apply to nine points.
