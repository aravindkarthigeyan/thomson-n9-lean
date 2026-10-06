# Audit W2: `check_sos_integer.py` (the exact three-point SOS checker), N=9

Auditor: Claude (W2, sos-integer-checker). Date: 2026-10-05. Folder: `claude/audit/sos_integer/`.
Nothing under `outputs/` or `work/` was modified. Codex modules were imported only as the object under
test, with bytecode writing disabled (`-B` and `sys.dont_write_bytecode`). Every report goes to this folder.

**Verdict: SOUND, WITH MINOR ISSUES.** No CRITICAL or MAJOR finding.

The checker verifies a correct sufficient condition. My separate implementation, which shares no Codex
code, reproduces every bound it reports exactly, including the frozen near-sharp degree-10 certificate.
That certificate gives `36L ≈ 3.98e-164 < 1e-92`.

## 0. Objects audited (frozen copies in `frozen/`)

| file | sha256 |
|---|---|
| `outputs/thomson-n9/near_sharp/near-sharp-d10.json` | `c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9` |
| `outputs/thomson-n9/near_sharp/hermite.json` | `d894c078b67f70c552efdf9f8f82d2caad93ad5203d92bb9fc537905a8db91f8` |
| `certificates/sep0560-d8-box.json` | `36537af4…7bc27`, the legacy degree-8 certificate |
| `certificates/near-sharp-d10-rounded.json` | rounded non-Hermite degree-10 certificate, bound 25.758005798786304 |

I also read `check_sos_integer.py`, `polynomial.py`, `check_sos.py`, `test_sos_integer.py`,
`check_residual_bernstein.py`, `near_sharp/check_hermite.py`, `exact_interval.py`, `correct_matrices.py`,
`audit_final_certificate.py`, `audit_closure.py`, `CERTIFICATE_SOUNDNESS.md`, `RESIDUAL_BERNSTEIN.md`,
`NEAR_SHARP_CLOSURE.md`, `EXACTIFICATION.md`, and section 5 of `work/prior/thomson-n7-lean/paper/PAPER.md`.

## 1. Re-derivation: the sufficient condition the checker must verify

Let x_1..x_9 be distinct unit vectors and t_ab = x_a·x_b. For each triple (a,b,c), put u = t_ab, v = t_ac and t = t_bc.

1. **Kernel positivity.** Q_0 = 1, Q_1 = t-uv and Q_{k+1} = 2(t-uv)Q_k - (1-u^2)(1-v^2)Q_{k-1}.
   Fix an anchor a and write z_b for the projection of x_b to x_a^⊥, viewed as a complex number. Then
   Re(z_b conj z_c) = t-uv and |z_b conj z_c|^2 = (1-u^2)(1-v^2). The Chebyshev recursion of Re(w^k) gives
   Q_k = Re(z_b^k conj z_c^k). Hence sum_{b,c} sum_{i,j} F_ij u_b^i u_c^j Q_k = Re of a Hermitian form, which is >= 0 when F >= 0.
   This holds with repeated indices too: z = 0 at the anchor and at its antipode.
2. **Symmetrisation.** Vertex permutations act on the three edge variables as the full S3. Therefore
   Σ_all S_k = Σ_all Y_k, where S_k = Sym(Y_k).
3. **Repeated indices.** Σ_all = 6Σ_{a<b<c} S + 6Σ_{a<b} S(t,t,1) + N·S(1,1,1). Each pair lies in N-2 triples,
   and C(N,3)/(N-1) = N(N-2)/6. So with R = (N-2)S + S(u,u,1) + S(v,v,1) + S(t,t,1) + S(1,1,1)/(N-1):
   **Σ_{a<b<c} R = (N-2)/6 · Σ_all ≥ 0.** This is identity (2) of PAPER.md, with dsum = 6Σ_{a<b<c}.
4. **Domain multipliers.** On distinct triples whose pairs lie in [l,U], each of 1, u-l, U-u, D,
   (u-l)(U-u) and D(u-l)(U-u) is ≥ 0 under every permutation, where D = 1+2uvt-u^2-v^2-t^2. So
   Sym(g·||B^T b||^2) ≥ 0.
5. **Determinant moment.** Σ_{a<b<c} D = det(Σ x x^T) ≤ 27 by Cauchy–Binet and AM–GM with trace 9.
   So μ(9/28 - D) has nonnegative sum over the 84 triples. It holds only in sum, and the checker treats it that way.
6. **Identity and bound.** Suppose (H(u)+H(v)+H(t))/3 - e/36 = Σ⟨F_k,R_k⟩ + ΣSOS + μQ + A, with A ≥ -L on
   [-1,1]^3 ⊇ [l,U]^3 and L the l1 norm of the coefficients. Summing over the 84 unordered triples gives
   (7/3)Σ_{a<b} H(t_ab) ≥ 84(e/36 - L), that is, **E_H ≥ e - 36L**. If H ≤ φ on the pair domain, then E ≥ e - 36L.
7. **Localization (Hermite branch).** Take h ≤ H_exact ≤ φ on [-1,1). Then
   φ - H_exact = φ^(21)(ξ)/21!·(t+1)^9 Π(t-s_j)^2, and φ^(21)/21! ≥ C(42,21)/2^64 at ξ ≥ -1. Every factor exceeds ε
   outside the 7 closed windows, so φ - h > C(42,21)/2^64·ε^21 ≈ 2.918e-92 > 1e-92 there. Now let E(X) ≤ E(P9) ≤ U < 25.759986532.
   LP separation puts all pairs in [-1, 0.5593). Then Σ_pairs(φ - h)(t_ab) ≤ E(P9) - U + 36L ≤ 36L, and each
   term is ≥ 0. So 36L < 1e-92 places every pair inside a window.

## 2. Code-level findings for `check_sos_integer.py`

| claim to check | result |
|---|---|
| F_k PSD | `integer_gram` forms B·B^T from a **square** rational factor (shape asserted). It is PSD by construction, and no eigenvalue routine is used. |
| SOS blocks PSD | Same B·B^T construction. Each entry is `orbit_sum(b_i b_j g)`, which is symmetric in i,j, so the `2×` off-diagonal pairing in `weighted_integer` is valid. |
| kernel entry | `kernel_entry` = (n-1)·orbit-compressed R_k[i,j]. I re-derived it: the boundary term S(w,w,1) gives one unit at each of the degrees (a+b), (a+c), (b+c), and S(1,1,1) is the coefficient sum. It is divided by D²(n-1) afterwards. Correct. |
| multipliers and domain | Built from the declared (l,U) by `polynomial.sosblocks`: 1, u-l, U-u, D, box and D·box, with v/t-even and v/t-odd bases. All are nonnegative on the declared domain. The Hermite branch pins the domain to exactly [-1, 5593/10000]. |
| orbit compression | Valid. Every contribution is a symmetrised polynomial (the LHS term {(i,0,0): h_i} is the orbit sum of (H(u)+H(v)+H(t))/3), and orbit sums are a bijection on symmetric polynomials. For symmetric polynomials, |orbit sum| equals the l1 norm within the orbit. My full expansion confirmed a **symmetric residual, with full l1 = compressed l1** on every certificate tested. |
| residual bound and normalisation | `bound = raw - 36·loss`, with C = 36 hard-wired and n == 9 asserted. This matches step 6. The l1 bound is valid on [-1,1]^3 ⊇ domain. |
| determinant term | μ ≥ 0 is asserted, and μ·compress(9/28-D) is subtracted as a global term. Correct. |
| H ≤ φ | Non-Hermite: Bernstein subdivision of p(y) = 1-2yH(1-2y²) on [0,1], via exact de Casteljau, rejecting at depth 24. I confirmed it with an independent exact Sturm count (`count_roots(0,1) = 0`, p(0) = 1) for d8 and d10-rounded. Hermite branch: `check_minorant` is skipped, and the result rests on check_hermite plus the analytic remainder argument (see MINOR-6). |
| exactness | Python bigints and Fraction throughout. Floats appear only in diagnostics (`bound_decimal`, `seconds`). There is no `round`/`Decimal`/float in the decision path, and Python ints cannot overflow. There is a `-O` guard (tested: RuntimeError). |

## 3. Independent recomputation (`w2_audit_ref.py`, no Codex imports)

The route is deliberately different from Codex's. It uses full uncompressed flint `fmpq_mpoly`. The contraction is
⟨BB^T,Y_k⟩ = Σ_c f_c(u)f_c(v)Q_k. Symmetrisation uses genuine variable composition, R_s is formed by genuine substitution,
SOS blocks are computed as g·Σ_c(Σ_i B_ic b_i)², and the multiplier and basis specification is my own implementation
of the written spec. Floats in the data are refused.

| certificate | auditor bound | Codex bound | exact match |
|---|---|---|---|
| sep0560-d8-box (l1) | 128799281388344093396593/5·10^21 = 25.7598562776688187 | same | yes, L identical |
| d8 tensor-Bernstein, full box, 7 splits (`w2_audit_bernstein.py`) | 25.759878881488074 | same | yes |
| d8 Gram-domain Bernstein, 15 splits | **25.75988332067154…** | same | yes: identical 11 leaves and 5 excluded boxes |
| near-sharp-d10-rounded | 25.758005798786304 | same | yes |
| **near-sharp-d10 (frozen)** | U - 36L with 36L = 3.9835e-164 (bound 25.75998653126983…) | same | **yes**, L identical, residual symmetric, 1771 terms |

For the near-sharp certificate (`w2_audit_nearsharp.py`):
- h equals the hermite.json coefficients exactly, and raw equals energy_upper exactly.
- The domain is exactly [-1, 5593/10000], the mode is symmetry-box-v1, μ is absent, and every entry is a string (denominators ≤ 171 digits).
- **36L < 1e-92** holds exactly.
- U < 25.759986532 holds, with margin 7.3e-10.
- C(42,21)/2^64·1e-84 = 2.918e-92 > 1e-92.
- My 450-digit mpmath cross-checks (`w2_audit_hermite_path.py`; not rigorous) agree:
  - r* lies inside the radius bracket;
  - 0 ≤ U - E(P9) = 4.6e-181;
  - max |H_exact - h| per coefficient is 5.4e-180;
  - φ - h ≥ 0 at the nodes;
  - (φ-h)/(C(42,21)/2^64·ω) ≥ 717 on 401 samples;
  - φ - h at the window edges is ≥ 8e-44 > 1e-92;
  - E(P9) = 25.75998653126983156407570227…;
  - the bound is 3.98e-164 below E_h(P9) (`w2_audit_tightness.py`).

Exact end-to-end test on rational 9-point configurations (`w2_audit_identity.py`, d8 factors) checks:
- Lemma 4.1 per anchor, including a repeated point;
- the R_s normalisation;
- the full decomposition and the pair/triple counting;
- Σ Q ≥ 0;
- that on in-domain near-P9 configurations every SOS block is ≥ 0, A ≥ -L, and E_H ≥ e - 36L.

All pass exactly.

## 4. Mutation and differential tests (object under test: Codex `check`)

- `w2_audit_mutations.py` was run on d8 (57 cases) and on d10-rounded (45 cases). Mutations covered:
  - one kernel-factor entry and one SOS Gram-factor entry (including the last D·box block);
  - one H coefficient: small changes, and changes that violate H ≤ φ;
  - the domain: U set to 5593/10000, 3/5, 1/2 and 1.01; l set to -0.99 and -1.01;
  - raw energy (±); the claim raised by 1e-40; μ = -1/100 and μ = 1/1000;
  - n = 8 and n = 9.0; degree; basis mode; format;
  - a non-square factor, dropped blocks, a JSON float;
  - 36 random single-entry perturbations.

  Results:
  - **Every** accepted claim is ≤ the auditor's exact bound.
  - **Every** minorant that Sturm shows violates H ≤ φ was rejected.
  - **All 68 differential bound comparisons agree exactly** (40 on d8, 28 on d10-rounded). These include changed domains and μ > 0.
  - Counting the 30 random certificates, the synthetic Hermite case and the 4 near-sharp threshold cases below, that makes 103 exact agreements and 0 mismatches.
  - Accepted mutations are exactly those whose new exact bound is ≥ the claim. They are sound, because the claim never exceeds the bound.
- `w2_audit_random_certs.py`: 30 random certificates covering degrees 1..5, all three basis modes, random [l,U] and random μ. Codex and reference agree exactly 30/30, and every residual is symmetric.
- Hermite branch (`w2_audit_hermite_path.py`):
  - A synthetic certificate passes with `spectrum_localization_threshold_met = False`, the bound matches the reference exactly, and the CLI `--require-localization` exits with code 1.
  - All of these are rejected: h[5] ± 1e-150; raw - 1e-150; U = 14/25; l = -0.99; h0 raised by 1e-120 in both files; Hermite window 1/1000.
- Threshold sensitivity on the frozen near-sharp certificate:
  - Factor perturbations of 1e-120 keep 36L ≈ 1e-116 < 1e-92, and the threshold stays met. This is correct, because the certificate is still valid.
  - Perturbations of 1e-60 give 36L ≈ 1e-56, and the threshold fails.
  - Codex's decision equals the decision from my exact L in all 4 cases.

## 5. Findings

**CRITICAL:** none. **MAJOR:** none.

**MINOR**
1. The report omits the domain [l,U], `sos_basis` and μ. In non-Hermite mode it therefore prints a conditional bound without its hypothesis; `check_sos.py` does include the domain. *Fix:* add those fields to the report.
2. Numeric fields go through `Fraction(x)`, which silently accepts JSON floats as exact binary values. For example, F(0.5593) is about 1.9e-17 above 5593/10000, and a float lower cut such as F(-0.73) would leave a gap of about 1e-17 in coverage. The Hermite branch pins the domain exactly, so the final result is unaffected. *Fix:* accept only str or int values.
3. `n` is not type-checked: n = 9.0 crashes with TypeError instead of a clean rejection. This is harmless. *Fix:* `type(n) is int`.
4. `--require-localization` is enforced only in `__main__`. `check()` returns `passed: True` even when localization fails (`audit_closure.py` does assert it). *Fix:* move the requirement into `check()`.
5. The independence claim is overstated. `check_sos_integer.py` and `audit_final_certificate.py` both import `qkernels`/`sosblocks`/`compress`/`check_minorant`/`DETERMINANT_MOMENT` from `polynomial.py`, so a specification error would pass every Codex checker. My from-scratch implementation agrees exactly, so no defect results.
6. Trust boundary. In the Hermite branch, H ≤ φ is not checked computationally. It rests on interval dominance in `check_hermite.py` plus the written repeated-Rolle remainder argument. E(P9) ≤ U rests on the Lean family-minimum result. I confirmed both numerically only; this audit did not cover the 1024-bit interval code.
7. U < 25.759986532, which the LP separation threshold requires, is asserted in `audit_closure.py`, not in the integer checker or `check_hermite.py`.
8. `test_sos_integer.py` writes into `results/` and has only 3 negative controls: no kernel-factor, domain, μ or Hermite-branch controls. Section 4 fills that gap.
9. Stale documentation. `NEAR_SHARP_CLOSURE.md` says the tiny residual "has not yet been produced", and `STATUS.md`/`PROOF_ARCHITECTURE.md` still describe localization as open. `near-sharp-d10.json` now exists.

## 6. Reproduction (from the workspace root W)

```
PY=claude/venv/Scripts/python.exe; A=claude/audit/sos_integer
$PY -B $A/w2_audit_ref.py outputs/thomson-n9/certificates/sep0560-d8-box.json
$PY -B $A/w2_audit_ref.py outputs/thomson-n9/certificates/near-sharp-d10-rounded.json
$PY -B $A/w2_audit_nearsharp.py --mutations          > $A/w2_audit_nearsharp.json
$PY -B $A/w2_audit_bernstein.py                      > $A/w2_audit_bernstein.json
$PY -B $A/w2_audit_identity.py outputs/thomson-n9/certificates/sep0560-d8-box.json > $A/w2_audit_identity_d8.json
$PY -B $A/w2_audit_mutations.py sep0560-d8-box.json 24        > $A/w2_audit_mutations_d8.json
$PY -B $A/w2_audit_mutations.py near-sharp-d10-rounded.json 12 > $A/w2_audit_mutations_d10rounded.json
$PY -B $A/w2_audit_random_certs.py                   > $A/w2_audit_random_certs.json
$PY -B $A/w2_audit_hermite_path.py                   > $A/w2_audit_hermite_path.json
$PY -B $A/w2_audit_tightness.py                      > $A/w2_audit_tightness.json
$PY -B outputs/thomson-n9/certificates/check_sos_integer.py $A/frozen/near-sharp-d10.json --hermite-certificate $A/frozen/hermite.json --require-localization --report $A/w2_audit_codex_cli_nearsharp.report.json
```

Run times on this machine: about 2 s for the reference on d8, about 90 s for the near-sharp audit with mutations,
2.4 min for the identity test, and 2 to 6 min for each mutation run. Peak memory is under 1 GB.

## 7. Not covered by this audit

- The LP separation certificate (step 1 of the endgame).
- The rigor of the 1024-bit interval implementation in `check_hermite.py`.
- The family-minimum Lean proof.
- The Gram-window classification and the local theorem.
- Any Lean formalization of sections 1 to 7 above.
