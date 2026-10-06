# Architecture / end-to-end completeness audit of the N=9 Thomson proof

Auditor: Claude (architecture critic, wave 2). Date 2026-10-05.
Object audited: Codex's package `outputs/thomson-n9/` as frozen at ~13:06 EDT. This is the moment
`GLOBAL_PROOF.md`, `verify_global.py` and the near-sharp certificate appeared.
Codex's tree was treated as read-only. Every output of this audit is in `claude/audit/architecture/`.

Frozen inputs (SHA-256):

| file | sha256 |
|---|---|
| near_sharp/near-sharp-d10.json | c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9 |
| near_sharp/hermite.json | d894c078b67f70c552efdf9f8f82d2caad93ad5203d92bb9fc537905a8db91f8 |
| rigidity/window_gram.json | 3fcd040eb0b6c538bcdd758a92a343c8801dfbb157019580f30b066ac483fc2a |
| sdp/lp-separation-05593.json | a2cf2d74810490451e3fe2307fcc1277a2c3056604a823375ac350f3d6d11d64 |
| sdp/lp-separation.json | 7acc028acb43eb4fb73ddd86ea10782d8dc2c0e19107c7f64887b80400045aa8 |
| certificates/local.json | 164be4c35511036a908d4e08281aaccf687b67f4c73f0b7ed95604769d841e54 |
| lean/Challenge.lean | ea32b730538646d67c9e4a5ef5efcdc892a75c27b4b3e1b861eaecac68d9fe9f |

**How the audit started.** When it began, the near-sharp SOS certificate did not exist, and STATUS was "D".
During the audit Codex produced the certificate above and moved STATUS to "B". My verdict applies to
these hashes. An earlier certificate (sha a338572c…, 12:51) was superseded and is not what is audited.

## Verdict

**Sound, with minor issues, as a computer-assisted mathematical proof. It is not Lean-verified.**

- The chain runs from "X is any 9 distinct unit vectors" to "E(X) >= E(P9), equality iff X = Q P9∘π
  (Q in O(3), π a permutation)". Every link is present, and no case is missing.
- The constants match across all documents and checkers.
- I re-derived or re-implemented every computational premise independently, without importing Codex code:
  - the SOS residual: full exact reconstruction gives an l1 norm equal to Codex's;
  - the Hermite facts;
  - the finite window classification;
  - both LP links;
  - the interval Hessian;
  - all cross-stage constants.
- Everything agrees.
- I found no CRITICAL or MAJOR defect in the mathematics. The issues are documentation, process and
  integration items, plus the large Lean formalization gap.

## 1. Reconstructed chain of implications

Notation:
- f(t) = (2-2t)^(-1/2) and E(X) = Σ_{i<j} f(x_i·x_j), with unordered pairs.
- E* = E(P9) = Φ(r*) = 25.7599865312698315640757...
- T = 6439996633/250000000 = 25.759986532.
- ε = 1/10000.

| # | Exact statement | Proved where | Evidence | Depends on |
|---|---|---|---|---|
| 0 | r* is the unique zero in (0,1) of the explicit stationarity function and lies in the 1e-40 rational interval. Φ is strictly convex. E(candidateAt r) = Φ(r). | lean/ThomsonN9/{ParameterExists,FamilyMinimum,CandidateEnergy}.lean | **Lean** (standard axioms only) | none |
| 1 | Full constrained stationarity of P9 (gradient tangent part = 0). | LOCAL_PROOF.md §stationarity (D3h fixed-vector argument, F'(r)=6a/h) | paper | 0 |
| 2 | H_t + RRᵀ ⪰ (7/50) I_18 for every r in the 1e-40 interval. Also: min distance − 3/1000 ≥ 1, \|λ_i\| ≤ 4, \|\|B_ij\|\| ≤ 2. | certificates/check_local.py (interval LDL) | exact Python | 0 |
| 3 | (L): ρ ≤ 1/500 ⇒ E(X) − E* ≥ ρ²/50. Here ρ is the O(3)-Procrustes distance with fixed labels. | LOCAL_PROOF.md (Taylor + Procrustes; constants re-derived by me) | paper + exact constant check | 1, 2 |
| 4 | (G): PPᵀ ⪰ 2I and δ = \|\|XᵀX − PᵀP\|\|_F ≤ 1 ⇒ min_Q \|\|X − QP\|\|_F ≤ 2δ. | LOCAL_PROOF.md (polar factor; re-derived by me) | paper | none |
| 5 | E* < T. | check_local energy interval; check_hermite U with U < T in verify_global | exact Python | 0 |
| 6 | E(X) ≤ T ⇒ max_{i≠j} x_i·x_j < 5593/10000. | sdp/lp-separation-05593.json + check_lp.py; Legendre positive-definiteness (addition theorem) | exact Python + classical theorem | none |
| 7 | E(X) ≤ T ⇒ \|\|M − 3I\|\|_F² < 1/4 ⇒ M ≻ (5/2)I ⇒ (Cauchy–Binet) some triple has det Gram > 125/672. | sdp/lp-separation.json + check_lp.py; GLOBAL_CONSTRAINTS.md | exact Python + paper | none |
| 8 | H is the degree-20 Hermite interpolant (order 9 at −1, double at the six true s_c(r*)). Then f − H = f^(21)(ξ)/21!·ω ≥ 0 on [−1,1). Rational h satisfies h ≤ H on [−1,1] and H − h < 1e-130. Outside the seven closed windows, f − h > binom(42,21)/2^64·ε^21 > 1e-92. | near_sharp/check_hermite.py + HERMITE_PROOF.md | exact Python + paper | 0 |
| 9 | Rational U with E* ≤ Φ(rMid) ≤ U < T and U − E* < 1e-130. | check_hermite (U ≥ Φ(rMid)) + Lean family minimum + verify_global (U < T) | exact Python + Lean | 0, 8 |
| 10 | Suppose all pairs lie in [−1, 5593/10000]. Then E_h(X) = Σ_{i<j} h(x_i·x_j) ≥ U − 36L, and 36L < 1e-92 (actual 3.98e-164). | near-sharp-d10.json + check_sos_integer.py; CERTIFICATE_SOUNDNESS.md §1–5 | exact Python + paper | 6 (domain), 8, 9 |
| 11 | Suppose E(X) ≤ E*. Then Σ(f − h)(x_i·x_j) ≤ E* − U + 36L ≤ 36L < 1e-92. Every term is ≥ 0, so every pair lies in the seven closed true windows. | GLOBAL_PROOF.md §4 / NEAR_SHARP_CLOSURE.md | paper | 5, 6, 8, 9, 10 |
| 12 | No pair in [−1, −1+ε]. Proof: det Gram(−1+δ, u, v) < −1/6000 for all 49 window pairs. | rigidity/check_antipodal_window.py | exact Python | 11 |
| 13 | Assume all pairs are in the six true windows and some anchor has det > 125/672. Then a relabelling exists with \|x_i·x_j − p_i·p_j\| ≤ ε for all i, j. | rigidity/check_window_gram.py + rigidity/PROOF.md (9515 exclusions, 8 cliques) | exact Python + paper | 7, 11, 12 |
| 14 | (6) ⇒ δ ≤ √72·ε ≤ 9e-4 ⇒ ρ ≤ 18e-4 < 1/500. With (L): E(X) − E* ≥ ρ²/50, and E(X) ≤ E*, so ρ = 0. Then X = Q P9∘π. Conversely, congruence preserves E. | GLOBAL_PROOF.md §5 | paper | 3, 4, 13 |

Case logic:
- Case A: E(X) > E*. Nothing to prove.
- Case B: E(X) ≤ E*. Links 5–14 apply.

Points I checked specifically:
- **Thresholds are not mixed up.** Every link that needs an energy hypothesis gets it as
  E(X) ≤ E* < T (separation, covariance) or E(X) ≤ E* ≤ U (localization). E* is never confused with T or U.
- **Pairs with t ≥ 0.5593.** These are impossible in case B by link 6. In case A they need no treatment.
- **Coincident points.** These are excluded by hypothesis. In Lean, `IsSphereConfiguration` includes injectivity.
  That is needed there because Lean's ‖0‖⁻¹ = 0 would otherwise make coincident points "cheap".
- **Antipodal pairs.** f(−1) = 1/2 is finite. Pairs near −1 are handled by link 12.
- **Constants.** Radius 1/500 against Gram window 1e-4: 2·9e-4 = 1.8e-3 < 2e-3. The value 2e-4 appears only
  in Codex's negative-control note, where the antipodal exclusion fails. It is never used.
  My check `w2_audit_constants` reproduces that failure at 2ε (det = +3.46e-5).
- **Interval nesting.** The radius interval is the same 1e-40 interval in Lean, local.json, window_gram.json
  and the hard-coded copies in check_hermite/check_exact_gram. The 1e-230 Hermite interval lies strictly inside it.

## 2. Independent checks performed (all PASS)

| script | what it does (no Codex import unless "object under test") | result |
|---|---|---|
| `w2_audit_run_codex_checkers.sh` | Runs Codex checkers as objects under test, outputs to `out/`: check_hermite (+neg. controls), check_sos_integer --hermite --require-localization, check_local (+neg.), check_lp ×2 (+neg.), check_window_gram, check_exact_gram, check_antipodal_window, check_constraints; separately verify_global.py --report out/. Not run because they write into Codex's tree: rigidity/test_rejections.py, certificates/check_geometry.py. | all exit 0. My rerun of check_sos_integer gives 36L = 3.98351e-164 for sha c7cac663… |
| `w2_audit_constants.py` | 47 cross-document linkage checks: Lean radius vs every copy; root r* by 600-digit findroot inside the 1e-230 bracket; E(P9) from 36 coordinate distances (not the 6-term formula) ≤ U, with U − E* = 4.6e-181 and U < T (margin of E* below T: 7.3e-10); near-sharp domain [−1, 5593/10000] equals the separation threshold; minorant equals hermite.json; no determinant-moment term; ε = 1/10000 everywhere; windows disjoint and inside the domain; covariance 4(T−B)/(3a2) = 0.2044 < 1/4; 125/672 matches window_gram.json; PPᵀ eigenvalues 2.9707, 3.0146 > 2; P9 max anchor det 0.852; local constants; binom(42,21)/2^64 equals f^(21)(−1)/21! | 47/47 PASS |
| `w2_audit_hermite_independent.py` | H obtained by solving the confluent Vandermonde system at 600 digits at my own r* (Codex uses interval divided differences). Checks: coefficient dominance (H0−h0 = 5.4e-180 ≥ Σ\|ΔH_k\| = 4.4e-180); 0 ≤ H−h < 1e-130 on a grid; (f−H)/ω ≥ binom(42,21)/2^64 on a grid (min 2.09e-5); f−h > 1e-92 just outside all 13 window boundaries (min 8.0e-44); f−h ≥ 0 on [−1, 0.5593] | PASS |
| `w2_audit_sos_pointwise.py` (+`w2_audit_sos_lib.py`) | My own evaluator of the identity (h(u)+h(v)+h(t))/3 − U/36 − Σ⟨F_k,R_k⟩ − ΣSOS, written from CERTIFICATE_SOUNDNESS.md, with R_k, Chebyshev q_k and symmetry-box bases re-implemented. Exact fmpq evaluation at 10 rational points | \|A\| ≤ 4e-166 ≤ L = 1.1e-165 at all points; a 1e-60 factor mutation is detected |
| `w2_audit_sos_interpolate.py` | **Full independent recomputation of the residual.** A is evaluated exactly at 358 random rational points, the 358×358 exact system is solved in the symmetric-orbit basis (rank 358), and the result is validated on 24 extra points. Then L_full = Σ\|coeff\| is computed | L_full equals Codex's residual_l1 **exactly** (same rational); 36L = 3.983511875e-164 < 1e-92 |
| `w2_audit_rigidity_independent.py` | Own exact window classifier written from rigidity/PROOF.md: Fraction boxes, my own symbolic 4×4 determinants, monomial-wise enclosure, self-type pairs with independent variables, and my own isomorphism test against P9's colored Gram | 56 anchors → 36 eligible; 7683 extension exclusions; 93 types; 1832 pair-color exclusions; 0 multi-color edges; 0 self-compatible; 8 cliques, **all** candidate relabellings. Identical to Codex |
| `w2_audit_lp_independent.py` | Own Legendre→monomial conversion and own Bernstein/de Casteljau prover: h_LP ≤ f on [−1,1) for both LPs; separation f−h ≥ T−B on [0.5593, 1); covariance < 1/4 | PASS. Negative control: widening the separation range to t ≥ 0.55914 fails, so the margin is tight but valid |
| `w2_audit_hessian_arb.py` | Own Arb ball computation of H_t + RRᵀ − (7/50)I over the whole 1e-40 radius interval, with different tangent frames. Ball Cholesky | all 18 pivots > 0 (min 0.0141); \|λ\| ≤ 2.88; \|\|B_ij\|\| ≤ 2; d_min − 3e-3 ≥ 1. Negative control: the bound 0.144 is rejected |
| `w2_audit_local_sanity.py` | Numerical checks (50 digits) of (G) and (L) on 400 random perturbations plus the worst Hessian direction | (G) worst ρ/2δ = 0.20; entrywise 1e-4 gives ρ ≤ 1.6e-4; (L) worst ratio 0.0715 ≥ 0.02; 3 zero modes; λ_min = 0.143935 |
| `w2_audit_falsify.py`, `w2_audit_falsify_targeted.py` | Numerical falsification: min of E_h subject to t ≤ 0.5593 (300 SLSQP starts); Coulomb E minimisation (150 starts); E_h with one pair forced ≥ τ ∈ [0.5593, 0.9999] | min E_h − U = −7e-15 (float roundoff), attained at P9 with all pairs in the windows; Coulomb min = E*; with a pair forced ≥ 0.5593, E_h ≥ U + 0.04. The separation is therefore needed only logically (for the box multipliers), not numerically |

## 3. Gap list, ranked

No CRITICAL or MAJOR mathematical gap was found. Remaining items:

1. **MAJOR (formal status, not a math error): there is no Lean proof of any global link.**
   - Links 1–4 and 6–14 are paper proofs plus Python exact checks.
   - Only link 0 and part of link 9 (the family minimum) are kernel-checked.
   - The status label "B" is appropriate. "Verified" in the Lean sense must not be claimed.
2. **MINOR (process): STATUS.md says "independently audited" before the external Claude audits finished.**
   - `near_sharp/INDEPENDENT_CLOSURE_AUDIT.md` comes from a Codex sub-agent, and its replay
     (`audit_closure.py`) re-uses Codex checkers.
   - This audit now supplies genuinely independent re-implementations, and they agree.
   - STATUS should cite which audits are external.
3. **MINOR (stale documents contradicting status B).**
   - `GLOBAL_CONSTRAINTS.md` l.207: "…is still the unresolved global step".
   - `N9_CANDIDATE.md` l.6: "global optimality remains an explicit separate target".
   - `SYMMETRIC_OPTIMALITY.md` l.~201: "What remains open…".
   - `LOCAL_PROOF.md`, section "Precise remaining global implication" ("No global localization statement… has been proved").
   - `CERTIFICATE_SOUNDNESS.md` §6: "none of the present lower certificates… proves the sharp N=9 optimum".
   - Each should be annotated "superseded by GLOBAL_PROOF.md".
4. **MINOR (integration): constants are duplicated by hard-coding.**
   - Radius interval: Lean, local.json, check_hermite `OLD_LO`, check_exact_gram `LNUM`.
   - ε: check_hermite, antipodal, window_gram.json.
   - 5593/10000: check_sos_integer Hermite branch, separation JSON.
   - T: verify_global, check_constraints, audit_closure.
   - verify_global cross-checks most of these, but **not** the Python radius interval against Lean's
     `radiusLower/radiusUpper`. That linkage was verified only by this audit, by parsing Candidate.lean.
   - Suggest adding that comparison to verify_global.
5. **MINOR (integration): verify_global.py replays no negative controls or mutations.**
   - They live in separate scripts: check_hermite --negative-control, audit_final_certificate.py, check_local --negative-controls, test_rejections.py.
   - The older `verify_exact.py` does not include the near-sharp chain.
   - A single "verify everything + mutations" entry point would help reproduction.
6. **MINOR (presentation): the symbol U is overloaded.**
   - It means four different things: T = 25.759986532 in GLOBAL_CONSTRAINTS.md; the radius upper end in
     rigidity/PROOF.md; the upper box bound in CERTIFICATE_SOUNDNESS.md; and the raw energy in near_sharp.
   - GLOBAL_PROOF.md fixes this with T, but the component documents still clash.
7. **MINOR (premise statement): two documents state U < T as a premise that check_hermite does not check.**
   - NEAR_SHARP_CLOSURE premise 2 and HERMITE_PROOF state "U < 25.759986532".
   - check_hermite itself checks only U ≥ Φ(rMid) and U − Φ(rMid) < 1e-130.
   - U < T is asserted in verify_global and audit_closure. The proof needs only E* < T, which check_local supplies.
8. **MINOR (cited classical theorem): link 6 uses Legendre positive-definiteness on S² via the addition theorem.**
   - That theorem is cited, not proved. This is fine on paper, but it is a real Lean obligation (see below).
9. **INFO: the 1e-92 exterior bound is crude but valid.**
   - The actual exterior slack is at least 8e-44, and the loss is 4e-164.
   - The separation LP margin at 0.5593 is tight: it fails at 0.55914. So the threshold cannot be relaxed with this LP.

## 4. Lean target check (`lean/Challenge.lean`, `ThomsonN9/Basic.lean`, `Candidate.lean`)

The target says exactly the theorem:

- **Configuration.** `Configuration = Fin 9 → EuclideanSpace ℝ (Fin 3)`.
- **Admissibility.** `IsSphereConfiguration` means unit norms **and** `Function.Injective`, i.e. distinct points.
- **Energy.** `coulombEnergy x = Σ_i Σ_{j∈Ioi i} ‖x i − x j‖⁻¹`: unordered pairs, 1/distance.
  Since ‖x−y‖² = 2 − 2x·y for unit vectors, this matches f.
- **Congruence.** `Congruent x y := ∃ g : R3 ≃ₗᵢ[ℝ] R3, ∃ p : Perm (Fin 9), ∀ i, x i = g (y (p i))`.
  That is O(3), including reflections, plus relabelling, exactly as in GLOBAL_PROOF.md.
  (P9 is D3h-symmetric, so O(3) and SO(3) give the same equivalence classes up to relabelling.)
- **GlobalOptimality.** `∀ r : CandidateParameter, ∀ x, IsSphereConfiguration x → E(candidate r) ≤ E x`.
- **GlobalUniqueness.** `… → (E x = E(candidate r) ↔ Congruent x (candidate r))`.
  The ← direction is true and elementary.
- **Non-vacuity.** `CompleteTarget` includes `ParameterExistsUnique`, which is proved.
  That excludes the case where CandidateParameter is empty.
- **Candidate definition.** It is not a decimal: it is the zero of `stationarity`, which matches
  F'(r) in LOCAL_PROOF/check_hermite, and `symmetricEnergy_hasDerivAt` proves it is Φ'.
- **Coordinates.** Caps (−1,0,0), (1/2,−√3/2,0), (1/2,√3/2,0) are −e_0, −e_1, −e_2: the anti-aligned phase, as intended.
- **Source hygiene.** No sorry, axiom or native_decide in the sources (grep). `LocalRigidity.lean` only defines an unproved Prop.

## 5. What remains

### Before the mathematical proof can be called complete (status B)

1. Finish and record the external component audits of check_sos_integer, check_hermite, check_window_gram, check_local and check_lp.
   - My independent re-implementations cover all of them and agree.
   - Line-by-line code audits by the other assigned auditors should be cited.
2. Fix the stale documents (gap 3) and the U overload (gap 6). Add the Lean-interval cross-check to verify_global (gap 4).
3. Freeze a manifest: hashes, plus Python and flint versions for the frozen inputs listed above.

No further mathematics is needed. I found no missing implication.

### Before it is Lean-verified (status A)

Each item below must become a kernel-checked theorem. Python results may not be imported as axioms.

1. Positive-definiteness of the Legendre kernels P_l on S², needed for the separation LP (l ≤ 27) and the covariance LP (l ≤ 2).
   - This requires the addition theorem or explicit harmonic-basis identities.
   - Possibly no Mathlib support exists (not checked against the pinned commit).
   - Alternative: replace the LP links by anchored-Chebyshev kernels, which have elementary proofs.
2. Soundness of Bernstein positivity and de Casteljau subdivision. Then the two LP minorant data checks, by reflection or kernel computation.
3. The covariance → Cauchy–Binet → anchor determinant chain.
   - Cauchy–Binet for 3×9 may not be in the pinned Mathlib. Not verified.
4. The anchored Chebyshev kernel positivity theorem: complex projections, repeated-index counting, normalisation 84/(7/3) = 36.
5. The certificate identity with 36L < 1e-92.
   - The certificate is 31 MB, with 170-digit factors.
   - A verified polynomial checker plus kernel evaluation is needed, without native_decide if only standard axioms are wanted.
   - **Recommendation:** re-round the factors to about 100–110 digits first. The slack (1e-92 needed, 4e-164 achieved) permits this and shrinks the kernel workload a lot.
6. The confluent Hermite remainder (repeated Rolle with multiplicities), the f^(21) formula, and interval divided-difference enclosure with square roots.
7. The antipodal 49-case check and the window classification (7776 extension and 1956 pair-colour interval evaluations, plus clique enumeration and isomorphism witnesses).
8. The local analysis:
   - stationarity from symmetry;
   - the interval LDL for an 18×18 matrix with square-root entries;
   - third-order Taylor along a segment in R^27 with the 6|w|³/|y|⁴ bound;
   - Procrustes existence (compactness of O(3));
   - polar-decomposition estimate (G).
9. Final assembly as `thomson_nine` and `thomson_nine_unique` with exactly the Challenge.lean statements, a clean pinned build, and `#print axioms`.

## Reproduction

From `claude/audit/architecture/`, using the Claude venv:

```bash
bash w2_audit_run_codex_checkers.sh            # Codex checkers as objects under test -> out/  (~5 min)
../../venv/Scripts/python.exe -B w2_audit_constants.py
../../venv/Scripts/python.exe -B w2_audit_hermite_independent.py
../../venv/Scripts/python.exe -B w2_audit_sos_pointwise.py
../../venv/Scripts/python.exe -B w2_audit_sos_interpolate.py      # ~4 min, < 1 GB
../../venv/Scripts/python.exe -B w2_audit_rigidity_independent.py
../../venv/Scripts/python.exe -B w2_audit_lp_independent.py
../../venv/Scripts/python.exe -B w2_audit_hessian_arb.py
../../venv/Scripts/python.exe -B w2_audit_local_sanity.py
../../venv/Scripts/python.exe -B w2_audit_falsify.py
../../venv/Scripts/python.exe -B w2_audit_falsify_targeted.py
# verify_global as object under test (report redirected):
cd ../../../outputs/thomson-n9 && PYTHONDONTWRITEBYTECODE=1 ../../claude/venv/Scripts/python.exe -B verify_global.py --report ../../claude/audit/architecture/out/global-chain.check.json
```

All result JSON and logs are in `out/`. Before the run, `w2_audit_constants.py` and
`w2_audit_sos_*.py` read `out/near-sharp-d10.check.json` from the runner. The interpolation
script uses python-flint, so its arithmetic is independent of Codex's stdlib-Fraction checker.
