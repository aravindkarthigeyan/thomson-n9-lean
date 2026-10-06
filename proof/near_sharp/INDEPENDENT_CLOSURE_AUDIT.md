# Independent Closure Audit

Verdict: **PASS for the computer-assisted mathematical argument, not a complete
Lean proof.** The N8 audit/certificate-discovery agent independently reviewed
the analytic argument and replayed its finite arithmetic premises after the
final rational certificate was frozen. No mathematical gap was found.

The frozen SOS input is `near-sharp-d10.json`, SHA256
`c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9`.
The replay and all input hashes are in `audit-closure.check.json`. Reproduce
with ordinary Python, with assertions enabled:

```powershell
python near_sharp/audit_closure.py
```

This audit script orchestrates the reviewed exact checkers and independently
checks the connecting rational constants. It does **not** pretend to be a
second implementation of their polynomial expansion. The separate full
1771-coefficient reconstruction and mutation tests provide that additional
implementation diversity.

## Analytic Checks

1. **Candidate and full stationarity.** The energy counts 36 unordered pairs.
   The family derivative has a unique zero because every displayed term of
   its second derivative is positive. The stabilizing mirrors kill both cap
   tangent components and the prism azimuthal components. The remaining
   invariant tangent space is one-dimensional; its derivative is exactly
   `6a/sqrt(1-r^2)`. Thus family stationarity really does imply full constrained
   stationarity, not merely stationarity within an arbitrarily chosen family.

2. **Three-point normalization.** The real-part-of-complex-powers construction
   proves the required kernel moment positivity, including repeated indices.
   Splitting ordered triples gives coefficients 6, 6 and 9 for the distinct,
   two-equal and all-equal cases. With the implemented R kernel,
   `sum_distinct_unordered R=(7/6) sum_all_ordered S`. Each pair appears in seven
   unordered triples. Hence the energy loss is exactly `84/(7/3)*L=36L`, with
   neither a missing nor an extra factor of two.

3. **PSD and residual.** Rational factors give PSD by construction, independently
   of all numerical eigenvalue diagnostics and contact-nullspace calculations.
   SOS multipliers are nonnegative on the justified separated Gram domain,
   also after each of the six variable permutations. The complete scalar
   residual is bounded by its coefficient l1 norm on `[-1,1]^3`. The final
   checker includes every row, including the two rows discarded in numerical
   correction. Symmetry compression sums coefficients over disjoint monomial
   orbits; their absolute sums equal the full l1 norm for a symmetric residual.

4. **Hermite lower polynomial.** Multiplicities are 9 at -1 and 2 at each of six
   distinct candidate contacts, totaling 21. The repeated-Rolle remainder has
   the sign of `(t+1)^9 product_j(t-s_j)^2`, which is nonnegative for `t>=-1`.
   Its derivative coefficient is at least `binom(42,21)/2^64>1e-8`.
   Outside the seven closed windows of radius `1e-4`, its slack is strictly
   greater than `1e-92`. The exact dyadic divided-difference computation
   encloses the true interpolant; constant-coefficient dominance pays every
   nonconstant coefficient error and proves the rational h lies below it.

5. **Energy upper bound and localization.** The rational U upperbounds the
   symmetric-family energy at the rational midpoint. Family minimality gives
   `E(P9)<=Phi(midpoint)<=U`. The audit additionally checks the exact comparison
   `U<6439996633/250000000`, so the prior LP separation theorem applies.
   Its rational certificate forces every pair below `5593/10000`. Then the
   SOS bound gives `E_h>=U-36L`. For any competitor at or below the candidate,
   all 36 pair slacks are nonnegative and their sum is at most `36L<1e-92`.
   A single pair outside all seven true windows is therefore impossible.

6. **Antipodal and finite-pattern exclusions.** The determinant formula for a
   near-antipodal pair is `2delta(1+uv)-delta^2-(u+v)^2`. Every one of the 49
   interval cases has upper bound below `-1/6000`, contradicting Gram
   positivity. The global degree-two LP moment bounds imply `M>(5/2)I`, hence
   Cauchy--Binet supplies an anchor determinant above `125/672`. All anchor
   colors and extension triples are enumerated. Every omitted extension and
   pair color, including same-type extension pairs, is rigorously excluded.
   This last check is essential: it justifies using six *distinct* graph nodes
   for the six non-anchor points. All remaining cliques have candidate Gram
   colors under an explicitly checked permutation.

7. **True versus enclosing windows.** The finite classifier operates on
   rational overenclosures of the true windows, solely to discard colors.
   The overenclosures are disjoint. Consequently the recovered color is the
   color from the original true-window hypothesis, which supplies the final
   entrywise error exactly `1e-4`. No extra radius-bracket error is silently
   dropped, and the conclusion is not weakened to `2e-4`.

8. **Local Hessian and quantitative finish.** The explicit tangent frames are
   exactly orthonormal by their algebraic formulas; mere interval containment
   of zero is not used as proof of these identities. The ambient Hessian sign,
   radial Lagrange correction and rotational augmentation all agree with
   direct differentiation. Positive interval LDL pivots certify
   `H_t+RR^T >= (7/50)I`, hence the lower bound on rotation-orthogonal tangents.
   At optimal orthogonal alignment, projected chord displacements are
   rotation-orthogonal. The edge-cube Taylor bound is `(27/2)rho^3`; the
   Hessian replacement and sphere corrections give the displayed lower
   coefficient `7/100-(49/2)rho-(1107/400)rho^2`. At `rho=1/500` this exceeds
   `1/50`. The polar-decomposition Gram estimate is valid because
   `PP^T>=2I`; its two error terms are Frobenius-orthogonal. Entrywise Gram
   error `1e-4` thus gives `rho<=18/10000<1/500`. The energy inequality forces
   rho=0 for a competitor at or below the candidate. Orthogonal images and
   permutations conversely preserve every distance.

## Replayed Finite Premises

The fresh replay passed in approximately 33 seconds:

- Candidate derivative bracket and all 18 augmented-Hessian LDL pivots.
- Both global LP minorants, exact separation, and covariance comparison.
- All 9515 window determinant exclusions and all 49 antipodal cases.
- The 230-digit root bracket and degree-20 Hermite rational enclosure.
- All 11 kernel blocks and all 12 SOS blocks of the frozen certificate.
- The complete residual, strict localization threshold, and all connecting
  rational constants listed above.

The analytic sources reviewed in full were `CERTIFICATE_SOUNDNESS.md`,
`NEAR_SHARP_CLOSURE.md`, `GLOBAL_CONSTRAINTS.md`, `rigidity/PROOF.md` and
`LOCAL_PROOF.md`, together with the directly used exact checker implementations.

## Remaining Trust Boundary

This supports status **B: complete mathematical proof, formalization
incomplete**, provided the final deliverables consistently identify the exact
frozen inputs and this computer-assisted trust boundary. Python's arbitrary
precision arithmetic, its runtime, the inspected checkers and the written
real-analysis arguments remain outside Lean's kernel. The numerical SDP
solver, approximate nullspaces and numerical optimizer are not proof axioms.
No global `thomson_nine` or uniqueness theorem has been claimed Lean-checked
by this audit. The unfinished N8 package build is a separate prior-art
reproduction limitation and does not enter the independently authored N9
mathematical certificate's logical dependency chain.
