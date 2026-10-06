# Independent audit: finite Gram-window rigidity (N=9 Thomson endgame, step 4)

Auditor: Claude (adversarial, independent re-implementation). Object under test:
`W/outputs/thomson-n9/rigidity/` (read-only; every Codex program was run only on a
byte-identical copy in `./codex_copy`, with output redirected into `./out`).

Audited versions (sha256): `window_gram.json 3fcd040e...2fc2a`, `exact_gram.json efd47aef...62350`,
`check_window_gram.py`, `check_exact_gram.py`, `check_antipodal_window.py`, `test_rejections.py` as of
11:44-11:59 (unchanged during the audit). `PROOF.md` was edited by Codex at 13:07 during the audit.
Only the wording about global localization changed ("not proved" became "supplied by
`../GLOBAL_PROOF.md`"). The rigidity mathematics did not change. Both versions are kept in
`codex_copy/` (`PROOF.md` is the original, `PROOF.live.md` the edited one).

## Verdict

**Sound, with minor issues only. No CRITICAL or MAJOR finding.** My independent arb re-implementation
gives exactly Codex's classification at eps = 1/10000 with theta = 125/672: the same 36 eligible
anchor types, the same 93 extension types, the same pair colours and the same 8 cliques. It shares
no code with Codex's checker. All 8 cliques are relabelled P9 patterns. On top of that, I prove and
check a strengthening: **the anchor-determinant hypothesis can be removed.** Any nine unit vectors
with all pairs in the seven windows already contain a triple with Gram det > 1/100. The
classification closes at theta = 1/100 (42 eligible types, 111 nodes, 9 cliques, all P9).
So step (4) holds exactly as the task states it ("any 9-point configuration with all pairs in the
windows"). It does not need the LP covariance certificate behind `M > (5/2)I`.

## 1. Re-derivation of the argument (checked line by line)

* Palette (ordinary inner products, Codex colour order): c0 = -1/2 (cap-cap, x3), c1 = -r (cap-opposite, x6),
  c2 = r/2 (cap-adjacent, x12), c3 = 2r^2-1 (vertical, x3), c4 = 1-3r^2/2 (same level, x6),
  c5 = r^2/2-1 (diagonal, x6). I re-derived this with sympy from coordinates. Multiplicities are
  [3,6,12,3,6,6] (36 pairs). Codex's hand-coded `reference_colors()` equals the symbolic pattern
  entry for entry.
* Doubling: the checker works with B = 2*Gram. Palette polynomials are 2*s_c. Window half-width is 2*eps.
  Threshold det B > 8*(125/672) = 125/84. All of these are correct. The agreement is not vacuous:
  at eps = 1/20000 my code keeps 80 nodes, not 93, so the doubled width is visible in the data.
* Anchor reduction: the vertex permutations of a triangle induce all 6 edge permutations, so sorting
  the anchor colours loses nothing. That gives C(8,3) = 56 multisets. The anchor box is discarded only
  if the rigorous upper bound of det B is <= 125/84. The hypothesis is strict (>), so the actual anchor
  is never discarded.
* Extension (norm) condition: the 4x4 Gram determinant of (x0,x1,x2,y) is 0 (rank <= 3). Excluded only
  if the closed interval omits 0. Count: 36*216 - 93 = 7683.
* Pair condition: the cross-Gram [[B,w],[v^T,t]] = 2 [x0 x1 x2 y]^T [x0 x1 x2 z] has rank <= 3. v and w
  are independent variables even for the same type, so all 6 colours are excluded for i = j. That is
  why distinct points have distinct types. I checked the polynomial with sympy: it depends on all six
  v, w variables separately. Codex checks only i <= j. This suffices because the determinant is
  invariant under transposition (v and w swap). Count: sum over anchors of 3n(n+1) - #edges = 1832.
  Total 9515. My recount matches.
* Completeness: all 36 pairs are covered (3 anchor-anchor, 18 anchor-extension through the type,
  15 extension-extension through edges). All 6-subsets are enumerated with
  `itertools.combinations`, independently of the certificate. The clique list must equal the
  certificate's list. Every clique's 9x9 colour matrix (all 81 entries, diagonal sentinel included)
  is compared with the permuted reference, and the witness is checked to be a permutation of
  range(9).
* From windows to Gram error: the filter boxes are pairwise disjoint over-enclosures of the true
  windows [s_c(r)-eps, s_c(r)+eps], so the filter colour is the true-window colour. A matched
  pattern then gives |x_i.x_j - P_{p(i)}.P_{p(j)}| <= eps exactly. Diagonals are exact. This matches
  LOCAL_PROOF (C) (P at r*, assuming r* is in I; the radius interval is identical to
  `lean/ThomsonN9/Candidate.lean`).
* Antipodal window: identity det = 2d(1+uv) - d^2 - (u+v)^2 (checked with sympy). The 49 cases are
  re-checked in arb by evaluating the full determinant over the boxes. The maximum upper bound is
  -1.7299e-4 < -1/6000 (Codex: -1.7308e-4). Tightest case: u, v both in the vertical window.
  There is no float in any acceptance decision. The checkers use only `int` and `Fraction`. Their
  generic ANCHOR, NORM and PAIR polynomials equal the sympy determinants (maximum exponent 2, and
  the power table covers up to 4).
* Exact theorem (not used by the endgame chain): reproduced. 42 positive types, 3 zero-ball types,
  54 nodes, 9 cliques, all P9. The 3 zero types (0,0,0), (1,1,3) and (2,2,5) are identically 0 in r
  (sympy).

## 2. Independent re-implementation (python-flint arb, 256-bit)

`w2_audit_window_classify.py`: ordinary (undoubled) Gram entries and arb balls. r is the ball
covering [L,U]. Windows are palette + [-eps,eps]. Determinants are evaluated directly by Leibniz
expansion over balls, not through monomial expansion. Optional bisection with a budget (not needed:
everything closed at depth 0). Multiple colours per pair and self-compatible types are handled
generically, without assuming uniqueness. The P9 reference comes from mpmath coordinates, and a
backtracking isomorphism search matches patterns against it.

| run | eligible | ext types | self-compat | multi-colour pairs | cliques/patterns | non-P9 |
|---|---|---|---|---|---|---|
| eps=1e-4, theta=125/672 | 36 | 93 | 0 | 0 | 8 | 0, **identical to Codex JSON (no diffs)** |
| eps=1e-4, theta=1/100 (no covariance hypothesis) | 42 | 111 | 0 | 0 | 9 | 0 |
| eps=0 (exact palette) | 42 | 54 | 0 | 0 | 9 | 0 |
| eps=5e-5 (doubling-sensitivity control) | 36 | 80 | 0 | 0 | 8 | 0 |
| eps=2e-4 | 36 / 42 | 109 / 131 | 0 | 0 | 8 / 9 | 0 |
| eps=5e-4 (depth 0) | 36 | 150 | 0 | 12 | 40 patterns | 32 (enclosures too loose: margin about 2-4x) |

Controls:
* Positive: the planted P9 palette at r = 3/5 and at r = 4/5 gives 9 cliques, all P9. Every anchoring
  of the real P9 coordinates (96 at theta = 125/672, 108 at theta = 1/100) shows up in both my output
  and Codex's JSON, including all compatible vertex orders for repeated colours
  (`w2_audit_p9_capture.py`).
* Negative: shifting c3 by +1/100 gives 0 cliques. (Shifts of 1e-3 or 5e-4 still leave
  P9-isomorphic patterns. That is expected: a necessary-condition filter keeps patterns without
  claiming they can be realised, and only pattern identity is used.)

## 3. Strengthening: the anchor hypothesis is not needed

**Lemma.** Let x_1..x_9 be unit vectors in R^3 with all x_i.x_j <= m = r/2 + eps (< 0.355375). Let
M = sum x_i x_i^T. Then lambda_min(M) > 8/25.

Proof: let e be the lowest eigenvector and h_i = x_i.e, so sum h_i^2 = lambda. If lambda <= 8/25,
each projection p_i onto the plane e-perp is nonzero, and some cyclic angular gap is <= 2pi/9.
For that pair, x_i.x_j >= |p_i||p_j| cos(2pi/9) - |h_i h_j| >= (1-lambda) cos(2pi/9) - lambda/2.
This is >= 0.3609 > m, a contradiction.

Consequences: det M >= min over {lambda_k >= c, sum = 9} of the eigenvalue product. The product is
Schur-concave, so the minimum sits at the vertex (9-2c, c, c), giving c^2(9-2c) = 0.856064.
By Cauchy-Binet, some triple has det Gram >= 0.856064/84 = 0.010191 > 1/100. The constants are
checked in arb in `w2_audit_identities.py`. The theta = 1/100 classification above then closes.
Recommendation: adopt this, so that step (4) no longer depends on `sdp/lp-separation.json` or the
covariance bound.

## 4. Mutation tests on Codex's checker (all behaved correctly)

`w2_audit_mutations.py` ran 17 extra mutations plus 2 unmodified controls. Rejected as required:
* marking (4,4,4), (1,2,4) or (1,2,5) "determinant_too_small" (the last two sit near the threshold:
  det in [0.1871, 0.1881] vs 0.18601);
* dropping a retained non-clique node;
* emptying (0,0,3);
* deleting a clique edge together with its clique;
* a permutation witness with two images swapped;
* changing the radius numerator, eps or the threshold;
* tampering with totals;
* swapping anchor records;
* a self-loop edge;
* a duplicated extension type;
* exact-certificate edits.

A benign over-approximation (an extra impossible node) is accepted, which is correct. Codex's own
`test_rejections.py` also passes on the copy.

## 5. Findings

* **MINOR-1 (dependency / statement scope).** PROOF.md's window theorem assumes an anchor with
  det > 125/672, which comes from the LP covariance certificate (`GLOBAL_CONSTRAINTS.md` /
  `GLOBAL_PROOF.md` (2)). The endgame summary states step (4) without it. The chain is valid as
  written, because E <= E(P9) < T gives the hypothesis. But the summary overstates the finite
  theorem, and the step carries an avoidable upstream dependency. Fix: section 3 above (theta = 1/100
  run plus the lemma).
* **MINOR-2 (hard-coded data).** LNUM/DEN are hard-coded in `check_exact_gram.py` and asserted only
  against the JSON. They are not checked mechanically against the Lean interval. They do match
  `lean/ThomsonN9/Candidate.lean` by inspection. The step relies on r* being in I, which is proved
  elsewhere.
* **MINOR-3 (hygiene).** `check_antipodal_window.py` writes into `rigidity/` by default, and
  `test_rejections.py` always rewrites `rigidity/mutation.check.json`. So the README replay commands
  overwrite committed reports (the output is deterministic, so the hashes stay the same).
* **MINOR-4 (thin margins, documented).** The antipodal bound has a margin of about 1.7e-4 vs 2e-4
  (it fails at eps = 2e-4, as Codex's own double-width audit notes). The depth-0 window
  classification fails between 2e-4 and 5e-4. The delivered eps = 1e-4 is inside both margins.
  Upstream, the Hermite step must deliver exactly the closed windows of half-width <= 1e-4 at
  r = r*, which matches HERMITE_PROOF.md.

## Reproduction (from `W/claude/audit/rigidity`, PYTHONDONTWRITEBYTECODE=1)

```
PY=../../venv/Scripts/python.exe
$PY w2_audit_window_classify.py --eps 1/10000 --theta 125/672 --codex-json codex_copy/window_gram.json --out out/mine_eps1e-4_theta125_672_d0.json
$PY w2_audit_window_classify.py --eps 1/10000 --theta 1/100 --out out/mine_eps1e-4_theta1_100_d0.json
$PY w2_audit_window_classify.py --eps 0 --out out/mine_exact.json     # exit 1 = 3 zero-ball types, discharged next
$PY w2_audit_identities.py         # palette/sympy identities, zero types, antipodal arb, lambda_min lemma
$PY w2_audit_polycheck.py          # Codex NORM/PAIR/ANCHOR == sympy determinants
$PY w2_audit_p9_capture.py         # positive control on real P9 anchorings
$PY w2_audit_mutations.py          # 17 mutations + 2 controls vs Codex checkers (copy)
$PY w2_audit_window_classify.py --eps 1/10000 --theta 1/100 --radius 3/5          # planted positive
$PY w2_audit_window_classify.py --eps 1/10000 --theta 1/100 --shift 3:1/100       # planted negative
cd codex_copy && $PY check_window_gram.py --output ../out/window_gram.check.json && $PY check_exact_gram.py --output ../out/exact_gram.check.json && $PY check_antipodal_window.py --output ../out/antipodal_window.check.json && $PY test_rejections.py
```
Each run is a few seconds, except the mutations, which take about 2 minutes.
