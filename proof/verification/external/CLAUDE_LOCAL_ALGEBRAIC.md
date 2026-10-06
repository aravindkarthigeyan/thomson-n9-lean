# Adversarial audit: `LOCAL_ALGEBRAIC_PROOF.md` (N=9, ambient K=10000 route)

Auditor: Claude Code (workflow stream w2_la). Date: 2026-10-05. Python only (`claude/venv`, 3.12.14:
sympy 1.14, mpmath 1.3, python-flint 0.9 Arb, numpy, scipy). Lean was not run because a quiet window
is in effect. I read the Lean files but did not build them. All re-derivations use my own code. Codex
code ran only once, as the object under test (`w2_la_03`).

## Audited inputs (SHA256)

| file | sha256 |
|---|---|
| `outputs/thomson-n9/LOCAL_ALGEBRAIC_PROOF.md` | b1c76351e98e2eb35ece2591b0247a8b926a3de1c6fb0dbcdaaafbc97f6c2ffd |
| `outputs/thomson-n9/certificates/ambient-dd-k10000.json` | **5783385547e2bab646a64863257f273cf57661445a98ac02c1b59f40f41ecbee** (matches the claim) |
| `outputs/thomson-n9/certificates/local.json` (root bracket; pinned by the certificate) | 164be4c35511036a908d4e08281aaccf687b67f4c73f0b7ed95604769d841e54 |
| `outputs/thomson-n9/certificates/check_ambient_dd.py` | 9bfbd0cba3aacbb73e3202a4451b9f7bd4406b9c1bf04800919d6d7279162297 |
| `outputs/thomson-n9/AMBIENT_DD.md` (14:17 version, which includes the K=10000 section) | 11d08586ea6e3f2ed27ff3dc3945c67762ee5b4d1828c4d1db7925a1c00dc1bf |
| `lean/ThomsonN9/LocalPotential.lean`, `LocalEnergy.lean`, `LocalGeometry.lean` | 95a437a7..., 7f4c0be3..., 7ec268df... |

Evidence tags: **EXACT** means a sympy identity or rational arithmetic. **RIGOROUS** means Arb ball
arithmetic at 600 bits. **PROOF** means the argument is written out here. **NUMERICAL** means mpmath at
40-60 digits or float64.

## Verdict: SOUND (minor, non-mathematical remarks only)

Every step of the claimed implication holds:

> rho = min_{Q in O(3)} ||X - QP||_F <= 1/500  ==>  E(X) - E* >= rho^2 (7/100 - 1377/100 rho - 1250 rho^2) >= (1873/50000) rho^2 >= rho^2/50.

Each step checks on independent re-derivation. The DD certificate is valid under my own Arb
implementation, and my minimum margin agrees with Codex's to every printed digit (0.05632640995492613).
The end-to-end numerical stress test found no violation at any intermediate inequality. The route is
compatible with the global Gram window. I found no mathematical error.

## (1) Second-order structure: gradient, Lagrange term, normal components, Procrustes

This proof has **no Taylor remainder**. It sums an exact global pointwise minorant (B) over the 36 pairs.
For d = d_ij (candidate) and w = w_ij = b_i - b_j:

1/|d+w| >= 1/|d| - d.w/|d|^3 + (3(d.w)^2 - |d|^2|w|^2)/(2|d|^5) - (51/50)|w|^3/|d|^4.

* **Quadratic term.** It equals (1/2) w^T B_ij w, where B = 3dd^T/D^5 - I/D^3 = Hess(1/|y|). Summing over
  pairs with blocks +B on the diagonal and -B off the diagonal gives (1/2) b^T D2E b exactly. (EXACT, w2_la_01 S3)
* **Linear term.** The gradient term **does not vanish**: sum_{i<j} -d.w/D^3 = sum_i grad_iE . b_i.
  Full stationarity gives grad_iE = lambda_i p_i. The chord identity p_i.b_i = -|b_i|^2/2 (from
  |p_i| = |p_i+b_i| = 1) then turns it into -(1/2) sum_i lambda_i |b_i|^2. This is O(rho^2), not O(rho^3),
  and it is **absorbed exactly** into the Hessian diagonal: (1/2) b^T (D2E - blockdiag(lambda_i I)) b = (1/2) b^T Hc b.
  On the sphere p_i.d_ij = D_ij^2/2, so lambda_i = -sum_j 1/(2D_ij) < 0. Hc therefore **adds**
  +sum_j 1/(2D_ij) to the diagonal. Codex's checker does the same (`h -= lambdas`), and so does my Arb
  build. (EXACT, S4; NUMERICAL: the identity holds to 1e-39 on 167 test configurations.)
  The sign matters. Mutants with the Lagrange term flipped or omitted give a false matrix inequality
  (lambda_min -5.73 and -2.86 respectively).
* **Stationarity.** The tangent gradient residual at r* is 8.1e-41 (60 digits). This was established
  before: by the D3h argument plus F'(r*) = 0, and in Lean as `candidate_force_radial`.
* **Procrustes.** Pick an optimal Q0 in O(3) (it exists by compactness) and replace X by Q0^T X. Energy
  is invariant, and Q = I is then optimal. Differentiate along exp(t[omega]x), which lies in SO(3):
  sum_i b_i.(omega x p_i) = 0, i.e. R^T b = 0 with R_{3i+a,k} = (e_k x p_i)_a. A reflection in Q0 is
  harmless. (PROOF; NUMERICAL: |R^T b| <= 2.5e-40 after mpmath SVD alignment, including 40 reflected inputs.)
* **Normal components.** (N^T b)_i = p_i.b_i = -|b_i|^2/2, so |N^T b|^2 = (1/4) sum|b_i|^4 <= rho^4/4.
  Then b^T Hc b >= (7/50)rho^2 - |R^T b|^2 - K|N^T b|^2 >= 0.14 rho^2 - 2500 rho^4. (EXACT constants;
  NUMERICAL: the step holds on all tests.)
* The proof uses no Hc R = 0 assertion. Remark: Hc R = 0 does hold in ambient coordinates too. It follows
  from differentiating rotation invariance twice and using stationarity (numerically 5.8e-41). It is
  irrelevant here because R^T b = 0 exactly.

## (2) The DD certificate, rechecked independently (w2_la_02, RIGOROUS)

* The certificate SHA256 matches, and `source_sha256` equals the hash of `local.json`.
  C is 27x27, **unit upper triangular** (exact rationals), so det C = 1.
* Root bracket [lo, hi] (width 1e-40): F'(lo) = -1.4935e-39 < 0 < F'(hi) = 2.8769e-39 (Arb). I
  re-derived F' symbolically from the coordinates and confirmed the six distance classes 3r^2(6),
  4-4r^2(3), 4-r^2(6), 3(3), 2+2r(6), 2-r(12). Minimum distance sqrt(2-r*) = 1.13554 > 1.
* I built A = Hc + RR^T + 10000 NN^T - (7/50)I over the r-ball with my own code, formed B = C^T A C in
  balls, and found every row **strictly diagonally dominant with positive diagonal**. Minimum margin is
  0.05632640995492613, the same as Codex. Off-diagonal |B_ij| <= 1.8e-35, and diag(B) ranges over
  [0.0563, 10003.5].
* **Implication.** The true B is symmetric (A is). Strict DD plus Gershgorin gives B > 0. Since C is
  invertible, A = C^{-T} B C^{-1} > 0, i.e. Hc + RR^T + K NN^T > (7/50) I. This is strict, which is
  stronger than the claimed >=.
* Codex's own checker reproduces PASS, and its rerun report matches the saved `ambient-dd-k10000.check.json`.
* **Sharpness/diagnostics (NUMERICAL).** lambda_min(Hc + RR^T + 1e4 NN^T) = 0.1439341 > 0.14 (margin
  0.0039). The transverse tangent minimum eigenvalue is 0.1439350, matching the earlier audit.
* **Mutation tests** (same C; my checker rejected every one; "forced" means the mutated matrix
  inequality is itself false):

| mutant | DD | forced? (lambda_min of mutated A) |
|---|---|---|
| shift 0.145 / 0.20 | reject | yes (-0.00107 / -0.0561) |
| Lagrange sign flipped / omitted | reject | yes (-5.73 / -2.86) |
| RR^T omitted | reject | yes (-0.14) |
| factor 3 -> 2; off-diagonal +B; pair dropped; lambda with 1/D^2 | reject | yes |
| K = 0, 1000, 5000, 20000, 1e6 | reject | **no**: the inequality is TRUE for every K >= 0 (see remark R2) |
| C[3][10] += 0.01; C = identity | reject | n/a |
| C[0][26] += 1e-6; r = r* + 1e-6 | accept (expected: DD is robust; stationarity is proved separately) | n/a |

  Codex-checker mutants (w2_la_03): penalty 1e6 with this C is rejected by the coarse off-diagonal bound,
  which is a real failure. Three mutants are rejected only by whitelist or format assertions, not by the
  mathematics: penalty 0 and 5000 (`penalty in (10000,1000000)`), shift 3/20 (`shift == hessian_lower`),
  and lower-triangular or diagonal edits (unit-upper assertion). C perturbations of 1e-2 to 1e-1 are
  rejected by the coarse entry bounds.

## (3) Cubic minorant and the 13.77 rho^3 remainder (w2_la_01, EXACT)

* The identity 1-(1+q)P3(q)^2 = q^4(140-56q+35q^2-25q^3)/256 holds. The cubic's only real root is
  1.838, and 140-56-25 > 0, so the factor is positive on [-1,1]. Hence (1+q)P3^2 <= 1 and
  P3 <= |P3| <= 1/sqrt(1+q). No sign assumption on P3 is needed.
* **Scalar minorant.** With a = ct, P3(2a+c^2) - [1 - a - c^2/2 + 3a^2/2 - (51/50)c^3] = c^3 g(t,c), where
  g = 51/50 + (3t - 5t^3)/2 + c(3/8 - 15t^2/4) - (15/8)c^2 t - (5/16)c^3.
  Using (3t-5t^3)/2 + 1 = (1-t)(5t^2+5t+2)/2 >= 0 on t <= 1, g >= 1/50 - (27/8)c - (15/8)c^2 - (5/16)c^3,
  which is >= 78799/25600000 > 0 on 0 <= c <= 1/200. The constant actually needed by the P3 route is
  about 1.01692, so 51/50 has room. A 50-digit grid check against the true 1/sqrt gives a minimum
  (1/sqrt - minorant)/c^3 of 0.0200 > 0.
* The vector form equals (1/|d|) times the scalar form with a = d.w/|d|^2 and c = |w|/|d|, and
  |d+w|^2 = |d|^2(1+2a+c^2). Cauchy-Schwarz gives |a| <= c.
* **Hypothesis of (B).** |w_ij|^2 <= 2(|b_i|^2+|b_j|^2) <= 2rho^2, so |w_ij| <= sqrt2 rho <= 0.00283. Then
  c = |w|/|d| < |w| < 1/200 because every candidate |d| > 1. **No segment argument is needed**: (B) is
  global in w on that ball, and only the candidate distances enter (D^4 > 1).
* **Edge bound.** The complete-graph identity sum_{i<j}|w_ij|^2 = 9 sum|b_i|^2 - |sum b_i|^2 for n = 9 is
  EXACT. So sum|w|^3 <= (3/2)rho * 9rho^2 = (27/2)rho^3, and (51/50)(27/2) = 1377/100.
  sqrt2 instead of 3/2 would give 12.98. Observed sum|w|^3/rho^3 <= 6.27.
* The Lean statements `reciprocalSqrtCubic_le`, `reciprocalSqrt_local_lower`,
  `pair_potential_algebraic_lower`, `displacement_pair_cubic_sum`, `stationary_linear_sphere_correction`
  and `displacement_fourth_sum` have hypotheses and conclusions that match the uses above. No
  `sorry`/`axiom` appears in the four local files (read only, not built).

## (4) Final polynomial and the equality case (EXACT)

* 7/100 - (1377/100)(1/500) - 1250(1/500)^2 = **1873/50000 = 0.03746 > 1/50**. Here 1250 = (1/2)(10000/4).
  The bracket is strictly decreasing on rho >= 0 (derivative -13.77 - 2500 rho < 0). It equals 1/50 at
  rho = 0.0028788 and 0 at rho = 0.0037838.
* **Equality case.** For 0 < rho <= 1/500, E - E* >= 0.03746 rho^2 > 0. Equality forces rho = 0, i.e. X = Q0 P.
* NUMERICAL (w2_la_04, 167 configurations: random including reflections, single-point moves, lowest
  transverse eigenvectors up to rho = 2.2e-3, and a scipy minimisation of (E-E*)/rho^2 at rho = 1/500).
  Every intermediate inequality holds: per-pair (B), linear identity, the (B)-sum, the 13.77 bound,
  (C), and the final bound. The adversarial minimum (E-E*)/rho^2 is 0.07153 against the bound 0.03746.
  The theoretical limit is lambda_min/2 = 0.07197.

## (5) Compatibility with the global chain (w2_la_05)

* PP^T = diag(3.014637, 3.014637, 2.970726) > 2I over the r-ball (Arb).
* Gram window max|Delta_ij| <= 1e-4 gives delta <= 9e-4 (doc). It is sqrt72·1e-4 = 8.49e-4, because
  the diagonal of Delta is 0. (G) then gives rho <= 2delta = **1.8e-3 <= 1/500** (doc). Sharper:
  sqrt(9/4 + 1/(2-delta)) delta gives 1.49e-3 (or 1.41e-3). The adversarial actual value is about 2.1e-4.
  I spot-checked (G) numerically: max rho/delta = 0.41 <= 2.
* rho in the local theorem is the same O(3)-Procrustes quantity used by `GLOBAL_PROOF.md`, applied to the
  relabeled X. `GLOBAL_PROOF.md` §5 still cites the tangent route (`LOCAL_PROOF.md`). Both routes prove
  the same implication (7), so either closes the chain.

## Remarks (no effect on soundness)

* **R1 (Lean status, informational).** The doc labels as Lean-checked only the scalar/vector minorant,
  the pair-sum/cubic bound, and the linear correction, and those statements exist. The final polynomial
  of this route (1377/100, 1250) is **not** in Lean. The present assembly lemma
  `LocalEnergy.local_gap_of_quartic_bound` uses the hybrid constants 2477/100 and 1107/400 (0.0204 > 1/50
  at 1/500). The ambient matrix interpretation is not yet formal, and the normal-penalty lemma is still a
  draft. The doc acknowledges that assembly remains.
* **R2 (normal penalty optional, informational).** lambda_min(Hc + RR^T) = 0.140194 > 7/50 already at
  K = 0. At K = 100 it is 0.14385, at 1e4 it is 0.14393, and at 1e6 it is 0.143935. So (A) is true for
  every K >= 0. The K-mutation "negative controls" (Codex's `wrong normal penalty`, and my K mutants) show
  only that C is tuned to K = 10000. They do not show that the inequality fails for other K. A smaller K
  (for example 100) would shrink 1250 rho^4 to 12.5 rho^4.
* **R3 (weak negative control).** Codex's built-in `wrong normal penalty` control (penalty 0) is rejected
  by the whitelist `assert penalty in (10000,1000000)`, not by arithmetic. The meaningful negative controls
  are shift > lambda_min and formula mutations, and I added those.
* **R4 (naming).** "force_i" in the doc is grad_iE. Lean's `coulombForce` = sum_j (x_j - x_i)/|x_i-x_j|^3,
  which is minus the physical force. The usage is sign-consistent.

## Reproduction

```
cd claude/audit/local_algebraic
../../venv/Scripts/python.exe w2_la_01_symbolic.py      # S1-S7 exact identities/constants
../../venv/Scripts/python.exe w2_la_02_dd_arb.py        # independent Arb DD check + mutations
../../venv/Scripts/python.exe w2_la_03_codex_checker.py # Codex checker replay + JSON mutants (w2_la_mutants/)
../../venv/Scripts/python.exe w2_la_04_endtoend.py      # end-to-end inequality chain, adversarial
../../venv/Scripts/python.exe w2_la_05_gram_chain.py    # Gram window -> rho compatibility
```
Outputs are `w2_la_0*.json`. Each script finishes in seconds, and peak memory is far below 2 GB.
