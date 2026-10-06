# Audit: refined six-contact windows (1e-4 to 1e-8) and the Gram-Schmidt alignment constant

Auditor: Claude, wave 2. Date: 2026-10-05.

Object audited: `outputs/thomson-n9/near_sharp/REFINED_WINDOWS.md`, `refined-windows.json`,
`check_refined_windows.py`, `generate_refined_windows.py`, and the `--refined` branch of `verify_global.py`.

How the work was done:
- Every check was re-derived with my own code: exact `Fraction` arithmetic, python-flint `arb`/`fmpq_poly`,
  and sympy. None of it imports a Codex module.
- Codex programs were only *run*, as subprocesses with `python -B`, with every output redirected into `out/`.
- The linkage mutation was run in a temporary private copy of the tree, which was deleted afterwards.
- I hashed the watched Codex files before and after. Nothing under `W/outputs` was modified.

## Verdict

**SOUND. No critical or major issues. Two minor issues and several informational notes.**

What I verified independently:

- **(1) Domain restriction.** It follows exactly from the 1e-4 localization plus the antipodal exclusion.
- **(2) The seven leaves.**
  - All seven single Bernstein leaves are nonnegative. I recomputed them by a third coefficient method.
  - The leaves cover [-3/4, 5593/10000] minus six *open* 1e-8 windows. The windows are centred at the *exact*
    algebraic contacts s_k(r*).
  - The t->y rounding directions are correct.
- **(3) Nesting and colour.** The argument is correct.
- **(4) Gram-Schmidt constant.** My explicit constant is **20.7** rigorously (arb box), or **70.9** by an
  exact-rational hand bound that is easy to formalize. Both are for the Frobenius alignment distance with anchor
  (p0+, p1+, p2+). Any non-degenerate anchor triple gives at most 146.
  - So "constant 10000, radius <= 1e-4 < 1/500" holds with a factor of 48 to 480 to spare.
  - Both local theorems (LOCAL_PROOF.md (L) and LOCAL_ALGEBRAIC_PROOF.md) take as hypothesis the *optimal*
    Procrustes distance rho = min_Q ||X - QP||_F <= 1/500. The value at any explicit Q bounds that minimum, so
    the Gram-Schmidt alignment is admissible.

## Audited inputs (SHA-256)

| file | sha256 |
|---|---|
| near_sharp/refined-windows.json | `936641eb5245068f352dfdd5b0341b49a6605d274cc73c161e4f3019b33aa813` (matches the task and REFINED_WINDOWS.md) |
| near_sharp/near-sharp-d10.json | `c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9` (equals `source_sha256` in the refined file) |
| near_sharp/check_refined_windows.py | `8fff3e2954cf825f6b0ed35df463a4e101af2f07f1cac63ff22916818480a368` |
| near_sharp/generate_refined_windows.py | `9cba283a575a945f9ff80da7b3684ec2cbb2e9ad7ce1e8cea9b185db53b51c6d` |
| near_sharp/check_bernstein.py | `fcd4ab468eac28f22c7ee301e89689d9ff4641cf1165909eb2622e5b659c922d` |
| near_sharp/REFINED_WINDOWS.md | `61f4d21fcadd6ecf7f6ff8d7a595192e474e1125d0783d61e3c90b5457025396` |
| verify_global.py | `f55c4cbdb0053e673f28faee48b0d90ab79d54537171c9041ec05e71338f0c30` |
| LOCAL_PROOF.md / LOCAL_ALGEBRAIC_PROOF.md | `0f62494a...19e19` / `ee1e9dab...392c` |

LOCAL_ALGEBRAIC_PROOF.md was edited by Codex at 14:32, during this audit. The edit appended a "zero normal penalty"
section. Its hypothesis is still "optimal alignment, rho <= 1/500", so section 4 is unaffected.

## 1. Domain restriction to [-3/4, 5593/10000] (script `w2_rw_01_domain_root.py`)

**The root and the candidate.**
- The 40-digit bracket [L, L+1e-40] matches the literals `radiusLower`/`radiusUpper` in
  `lean/ThomsonN9/Candidate.lean`. I parsed them myself.
- sympy confirms two identities:
  - Phi' equals the stated F'.
  - Phi'' equals a sum of five manifestly positive terms on (0,1).
- arb at 600 bits gives F'(L) = -1.49e-39 < 0 and F'(L+1e-40) = +2.88e-39 > 0.
- Hence r* is the unique zero, and it lies in the bracket.
- The candidate inner products come from sympy on the coordinates. The palette is exactly
  {r^2/2-1: 6, -r: 6, -1/2: 3, 2r^2-1: 3, 1-3r^2/2: 6, r/2: 12}, 36 pairs.
- Phi equals the 36-pair Coulomb sum.

**Contact enclosures.** Each s_k is monotone in r > 0, so endpoint evaluation gives rigorous enclosures of width
at most 2.9e-40. The ordering is strict.

**Which pairs could lie below -3/4.**
- The old windows are [s_k - 1e-4, s_k + 1e-4], six windows plus the antipodal window [-1, -1+1e-4].
- The lowest contact is s_1 = r^2/2 - 1 = -0.7475605...
- Its old window is approximately [-0.747661, -0.747461]. Its lower end exceeds -3/4 by 2.34e-3 (exact
  rational check).
- The highest old window ends at 0.355374. That is 0.204 below 5593/10000.
- So the only window not contained in [-3/4, 5593/10000] is the antipodal one, which has already been excluded.
- The upper bound 5593/10000 is not even needed here: it holds automatically from the windows.
- Note: the task text's rounded "[-0.7477,-0.7475]" is *not* literally a superset of that window, because the upper
  end is -0.747461 > -0.7475. This is immaterial.
- The old windows are pairwise disjoint, with minimum separation 0.0368, and disjoint from the antipodal window.

**The energy side.**
- I need E* <= U = `raw_energy`. arb at 3000 bits gives U - Phi(rMid) >= 4.6e-181 > 0, and Phi(r*) <= Phi(rMid)
  by minimality.
- The pair-slack bound is therefore sum(f-h)(u_ij) <= E* - U + 36L <= 36L.
- The full replay R2 gives 36L = 3.9835e-164 < 1e-33. Exact Fraction comparison, script `w2_rw_05_replay.py`.

## 2. The seven leaves (script `w2_rw_02_bernstein.py`)

**The polynomial.**
- I built p(y) = 1 - 2y(h(1-2y^2) + 1e-33) by Horner composition with h taken from near-sharp-d10.json.
- It has degree 41.
- It is identical, coefficient by coefficient, to a FLINT `fmpq_poly` composition.
- It agrees with 2y(f - h - gamma) at four rationals to 1e-200 (mpmath, 250 digits).
- h is in the monomial basis: f(s_k) - h(s_k) is in [5e-180, 7e-88] at r = L, as expected for a minorant that
  touches f at the contacts.

**Bernstein coefficients.** I used the homogenisation identity
sum_i a_i (lo + hi Y)^i (1+Y)^(41-i) = sum_k C(41,k) b_k Y^k.
This involves no Taylor shift and no subdivision. It differs from both Codex programs. They share the same
binomial-shift-and-convert formula, and for one-leaf trees their "different splitting" is never exercised.

**Covering logic.**
- I wrote my own walk over the given `domain_t` intervals.
- It checks that the first interval starts at or below -3/4 and the last ends at or above 5593/10000.
- Every uncovered gap (a, b) must satisfy a >= sup s_k - eps and b <= inf s_k + eps. Then the gap lies inside the
  open window (s_k - eps, s_k + eps) for the exact s_k.
- Result: 6 gaps, one per contact.

**The t->y map.** For each interval I checked:
- 0 < ylo;
- ylo^2 <= (1 - thi)/2, so ylo <= y(thi);
- yhi^2 >= (1 - tlo)/2, so yhi >= y(tlo).

Since y = sqrt((1-t)/2) is decreasing, [ylo, yhi] contains the image. With y > 0,
p(y) = 2y(f - h - gamma) >= 0 gives f - h >= 1e-33 there.

**Results.**

| leaf | t-interval | min b_k (the edge value at a refined window) |
|---|---|---|
| 0 | [-0.75, s1-1e-8] | 1.06e-30 |
| 1 | [s1+1e-8, s2-1e-8] | 1.06e-30 |
| 2 | [s2+1e-8, s3-1e-8] | 2.09e-30 |
| 3 | [s3+1e-8, s4-1e-8] | 2.67e-27 |
| 4 | [s4+1e-8, s5-1e-8] | 3.20e-24 |
| 5 | [s5+1e-8, s6-1e-8] | 1.58e-23 |
| 6 | [s6+1e-8, 0.5593] | 1.68e-22 |

- The true minimum of f - h at the refined window edges is 5.70e-31, which is 570 times the gap.
- Dense sampling of each interval agrees with the edge minima.
- The minimal Bernstein coefficient is always b_0 or b_41, so a single leaf suffices.

## 3. Nesting and colour argument

The chain of reasoning:
1. Every pair has nonnegative slack, because h <= f globally (earlier audits).
2. Every pair's slack is at most 36L < 1e-33.
3. So no pair lies in a closed exterior interval. With (1), every pair lies in an open refined window
   (s_k - 1e-8, s_k + 1e-8).
4. That window sits inside the closed old window [s_k - 1e-4, s_k + 1e-4].
5. I checked exactly that a point within 1e-8 of s_k is more than 1e-4 from every other s_j. So the old
   classification's colour, which is the index of the unique true old window containing the pair, is k.
6. The finite classification returns pi with p_pi(i).p_pi(j) = s_colour(i,j) (rigidity audit).
7. Hence |x_i.x_j - p_pi(i).p_pi(j)| < 1e-8, and the diagonals are exact.

There is no circularity: the antipodal exclusion uses only the 1e-4 windows of the third-point products.
`verify_global.py --refined` asserts 0 < 1e-8 < 1e-4 and uses gram_error = 9e-8. That gives alignment
1.8e-7 by the polar lemma (G), as REFINED_WINDOWS.md states.

## 4. Gram-Schmidt constant (scripts `w2_rw_03_gram_schmidt.py`, `w2_rw_03b_hand_constant.py`)

**The lemma.**
- Take an anchor triple (a,b,c) of P whose Gram matrix A_P is positive definite.
- Run Gram-Schmidt on (x_a, x_b, x_c):
  - e1 = x_a;
  - R22 = sqrt(1 - A12^2), e2 = (x_b - A12 e1)/R22;
  - R23 = (A23 - A12 A13)/R22, R33 = sqrt(1 - A13^2 - R23^2), e3 = (x_c - A13 e1 - R23 e2)/R33.
- Every x_i in R^3 has frame coordinates c1 = g1, c2 = (g2 - A12 g1)/R22, c3 = (g3 - A13 c1 - R23 c2)/R33,
  where g = (x_a.x_i, x_b.x_i, x_c.x_i).
- Set Q = Q_X Q_P^T. Q is in O(3) and may be improper, which (L) allows. Then
  |x_i - Q p_i| = |c_X(i) - c_P(i)|.
- Each c(i) depends only on six Gram entries. Each of them is within delta of P's.

**Rigorous constant (arb box).**
- I enclosed c(i) over the box [v_P - delta, v_P + delta]^6, with r ranging over the whole bracket. Both c_X(i)
  and c_P(i) lie in the enclosure.
- For anchor (p0+, p1+, p2+): det A_P = 0.852 and lambda_min = 0.757. The bounds are
  max_i |x_i - Q p_i| <= 8.83 delta and ||X - QP||_F <= **20.66 delta**.
- The constant is stable for boxes up to delta = 1e-4.
- Of the 84 triples, 10 are degenerate (coplanar with 0) and must not be used. The other 74 give
  C_F in [20.7, 146.0].

**Exact-rational hand bound.** This uses only |inputs| <= 1, |unit-vector coordinates| <= 1, and rational lower
bounds R22 >= 0.970105 and R33 >= 0.951427 over the bracket.
- |dc1| <= delta.
- d22 = 2 delta/R22.
- dc2 = (3 delta + d22)/(R22 - d22), and |dR23| <= dc2.
- d33 = (2 delta + 2 dc2)/R33.
- dc3 = (3 delta + 2 dc2 + d33)/(R33 - d33).
- Result: per point <= 28.4 delta, Frobenius <= **70.9 delta**.
- At delta = 1e-8 this gives rho <= 7.1e-7.

**Monte Carlo.** On 4000 realised configurations the worst ratio is 3.9 (Frobenius). A concrete example shows
rho_opt <= rho_GS, as it must.

**Comparisons.**
- The polar lemma (G) gives 2 sqrt(72) delta = 16.97 delta (the document uses 18 delta).
- At the old radius 1e-4, Gram-Schmidt would *fail*: even the sharp 20.66e-4 = 2.07e-3 exceeds 1/500. That is
  why the refinement is needed on this route.

**Does the local theorem accept it?** Yes.
- (L) in LOCAL_PROOF.md and the algebraic proof are both stated for rho = min over Q in O(3) of ||X - QP||_F
  (Frobenius, labels fixed), with rho <= 1/500.
- min <= ||X - Q_GS P||_F <= 2.1e-7 (or 7.1e-7 by the hand bound), which is at most 1e-4 < 1/500.
- The proofs then switch internally to an optimal alignment. Its existence uses compactness of O(3), and
  R^T b = 0 holds only there.
- A formalization must therefore not run the Taylor argument with b = X - Q_GS P. It must pass to the minimiser.
  That step is already required by the existing proof.

## Mutation tests (script `w2_rw_04_mutations.py`; mutants in `out/mutants/`)

| case | expected | mine | Codex standalone checker |
|---|---|---|---|
| genuine | accept | accept | accept |
| positive control: every leaf split once ("011") | accept | accept | accept |
| drop last interval / drop middle interval | reject | reject | reject |
| left end moved to -0.7476 (y recomputed) | reject | reject | reject |
| interval extended into window up to s_2 (y recomputed) | reject (positivity) | reject | reject |
| endpoint moved inward 1e-6 (opens gap > window) | reject | reject | reject |
| ylo rounded up / yhi rounded down (by 2^-200) | reject | reject | reject |
| gap 1e-30 (> true min slack 5.7e-31) | reject | reject | reject |
| eps 1e-10, consistently rebuilt (slack about 5.7e-35 < gap) | reject (positivity) | reject | reject |
| root bracket shifted 1e-12, consistently rebuilt | reject | reject | reject |
| minorant h0 + 1e-31 | reject (linkage) | reject | **accept** |
| minorant h20 + 1e-200 | reject (linkage) | reject | **accept** |
| tree "0" (unfinished) / "11" (extraneous) | reject | reject | reject |
| INFO: eps 1e-9 rebuilt; gap 5e-31 | (true) | accept | accept |

The two "accept" results are expected given the standalone checker's scope (issue 1). For the h0 mutant, the full
`verify_global.py --bernstein --refined`, run in a private copy, rejects at line 128 (`refined['minorant'] ==
coefficients`). That is replay R4.

## Replays (script `w2_rw_05_replay.py`; reports in `out/`)

- **R1.** Codex `check_refined_windows.py --negative-controls`: PASS. 7 leaves, its 4 mutations rejected, and
  the certificate hash matches.
- **R2.** `verify_global.py --bernstein --refined`: PASS. 36L = 3.98e-164, window 1e-8, alignment 9/50000000.
- **R3.** `verify_global.py --refined` (Hermite route): PASS.
- **R4.** The linkage mutant is rejected by verify_global.
- Codex files were unchanged before and after.

## Issues

1. **MINOR (robustness).** The standalone `check_refined_windows.py` does not tie the minorant to the SOS
   certificate.
   - It verifies only that whatever h is in the file satisfies the gap. It does not check `source_sha256`, or that
     `minorant` equals near-sharp-d10.json.
   - So it accepts a perturbed minorant (h0 + 1e-31, h20 + 1e-200).
   - The linkage is enforced only by `verify_global.py --refined`, and does reject it (R4). REFINED_WINDOWS.md
     says so ("The full replay checks the exact h linkage").
   - Still, the sentence "It uses the same rational h as the original SOS certificate" is a property of the replay,
     not of the standalone checker.
   - Suggested fix: compare against near-sharp-d10.json in the checker.
2. **MINOR (documentation).** "Generator and checker use different coefficient/splitting implementations" adds
   little independence here.
   - All seven trees are single leaves, so no splitting is ever exercised.
   - The initial conversions (the generator's `affine` + `integer_coefficients` versus the checker's
     `initial_coefficients`) are the same binomial-shift-then-convert formula.
   - My homogenisation-identity conversion is genuinely different and agrees.
3. **INFO.** The Gram-Schmidt lemma is not in the checked chain, as REFINED_WINDOWS.md itself says.
   `verify_global` still uses the polar lemma (G), giving 1.8e-7. If the Gram-Schmidt route is formalized:
   - the hypothesis must be the 1e-8 windows (at 1e-4 it fails, 2.07e-3 > 2e-3);
   - a non-degenerate anchor must be chosen (10 of the 84 triples are coplanar with 0);
   - the local theorem must be applied through min-over-Q, not to the Gram-Schmidt alignment directly.
4. **INFO.** The margins are comfortable: true minimum slack / gap = 570; Gram-Schmidt constant 20.7 (rigorous)
   versus 10000 claimed.
5. **INFO.** The task text's rounded first window "[-0.7477,-0.7475]" is not a superset of the true window
   [-0.747661, -0.747461]. This is immaterial. Cosmetic typos in REFINED_WINDOWS.md ("from1/10000",
   "same40-digit").

## Reproduce

From `claude/audit/refined_windows/`, using `W/claude/venv/Scripts/python.exe -B`:

```
w2_rw_01_domain_root.py   # root bracket, palette, E*<=U, domain, nesting
w2_rw_02_bernstein.py     # seven leaves, own covering, own Bernstein conversion
w2_rw_03_gram_schmidt.py  # rigorous GS constants over all 84 anchors, Monte Carlo
w2_rw_03b_hand_constant.py# exact-rational hand constant (Lean-friendly)
w2_rw_04_mutations.py     # 16 cases x {mine, Codex}, 2 informational
w2_rw_05_replay.py        # Codex checker + verify_global (both routes) + linkage mutant
```

Total run time is about 2 minutes. The folder is under 1 MB.
