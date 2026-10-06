# Hermite-localization audit (Claude, wave 2)

Scope: `outputs/thomson-n9/near_sharp/` (check_hermite.py, exact_interval.py,
generate_hermite.py, generate_root.py, hermite.json, hermite.check.json,
radius-proposal.json, HERMITE_PROOF.md) and the localization implication
"exact SOS certificate with energy loss 36L < 1e-92 => every pair of every
E <= E(P9) configuration lies in one of the 7 windows". While this audit was
running, Codex added the final certificate `near_sharp/near-sharp-d10.json`.
I therefore also replayed its residual independently, but only as far as the
implication needs it.

Everything Codex claims was treated as unverified. No file under W/outputs or
W/work was modified. Codex modules were imported only as objects under test,
with bytecode writing disabled. Checked afterwards: no new `.pyc` appeared.

## Verdict

**The Hermite/localization step holds. I found no critical or major issues.
There are five minor issues.** Given the step-1 separation lemma
(E <= 6439996633/250000000 implies max t < 5593/10000), which I did not audit,
here is what was checked. The data, the arithmetic and the written analytic
argument together prove that every pair product of a configuration with
E <= E(P9) lies in [-1,-1+1e-4] or in [s-1e-4, s+1e-4] for some
s in S(r*). These are the true algebraic values. The final certificate's
energy loss is 36L = 3.98e-164, below the threshold 1e-92.

## Audited file hashes (sha256)

| file | sha256 |
|---|---|
| near_sharp/check_hermite.py | f4a59a5f60e1f725…f9a4 |
| near_sharp/exact_interval.py | 9bea42107634…323e |
| near_sharp/hermite.json | d894c078b67f…91f8 |
| near_sharp/hermite.check.json | 573e715dc933…bf93cbf |
| near_sharp/radius-proposal.json | a42822635b41…6c6fa |
| near_sharp/near-sharp-d10.json | c7cac663dd6f…53ab9 |
| near_sharp/near-sharp-d10.check.json | 70d6eb2918bc…b4c3 |
| certificates/check_sos_integer.py | 68cd42e0acd7…94a5 |
| certificates/polynomial.py | b488513d0248…281a |

## (a) Exact Hermite data — independently re-derived

* **How the algebraic nodes are handled.** The nodes are never represented
  exactly. Every Hermite coefficient is computed in outward-rounded interval
  arithmetic with r ranging over the whole bracket [lo,hi], which has width
  exactly 1e-230. Each resulting interval therefore contains the exact
  coefficient of H at r*, provided r* is in [lo,hi]. The rational h is then
  shown to lie below every polynomial in the coefficient box on [-1,1]. The
  windows are centred on the exact s_i(r*). No rational node approximation
  enters the windows. The rigidity checker separately over-encloses
  s_c(I)+[-eps,eps].
* **Root.** Using Arb (a different implementation from Codex's dyadic class):
  F'(lo) = -2.0116e-230 < 0 and F'(hi) = +4.1692e-229 > 0. The bracket lies
  strictly inside the Lean 40-digit interval, which I parsed from
  `lean/ThomsonN9/Candidate.lean`, and its width is exactly 1e-230.
  * I checked symbolically that F'' is a sum of seven manifestly positive terms
    on (0,1): 4√3/r³ + (3/2)(1−r²)^{-3/2} + (9/2)r²(1−r²)^{-5/2} +
    6(4−r²)^{-3/2} + 18r²(4−r²)^{-5/2} + 18(2+2r)^{-5/2} + 9(2−r)^{-5/2}.
  * So the root is unique without appealing to Lean, and r* ∈ [lo,hi].
  * An independent mpmath root gives r* − lo = 4.6e-232.
* **Contacts.** I rebuilt the 9 points from explicit coordinates and
  classified all 36 Gram entries.
  * The counts are 6/6/3/3/6/12 for r²/2−1, −r, −1/2, 2r²−1, 1−3r²/2, r/2.
  * The family formula Φ equals the coordinate energy, the contacts are
    strictly ordered in (−1,1), and the minimum node gap of 0.037 is far
    larger than 2·eps.
* **Coefficients.** I solved the 21×21 confluent Vandermonde system with
  Arb's `arb_mat.solve`. This is a different algorithm from Codex's Newton
  divided differences. The system encodes value and derivative at the six
  contacts, and derivatives 0..8 at −1.
  * My enclosures, of width ≤ 3.9e-185, intersect Codex's for all 21
    coefficients.
  * The identity φ^(m)(−1)/m! = binom(2m,m)/2^(3m+1) holds for m ≤ 21.
* **h ≤ H with H − h < 1e-130.** Re-proved with my own enclosures: the
  dominance margin is 9.699e-181 ≥ 0 and the uniform error is 9.86e-180,
  both on [−1,1].
  * The mp interpolant matches h to 5.4e-180, and h meets all 21
    interpolation conditions to 4.9e-172.
* **U ≥ E(P9).** Proved directly: U ≥ sup Φ([lo,hi]), using an Arb
  enclosure over the whole bracket, with margin 4.6e-181. This does not need
  the family-minimum lemma.
  * U − inf Φ([lo,hi]) = 4.6e-181, and the 54-digit E(P9) decimal stated in
    the task is consistent.
  * U < 6439996633/250000000 = 25.759986532 by 7.30e-10, so the separation
    lemma applies.
* **Reproducibility.** `hermite.check.json` reproduces bit-for-bit; its
  certificate_sha256 equals sha256(hermite.json).

## (b) Remainder formula and exterior bound

* φ^(n)(t) = (2n−1)!!(2−2t)^{-n-1/2}, checked by sympy for n ≤ 22. It is
  positive, and since φ^(22) > 0, φ^(21) is increasing on (−∞,1).
* φ^(21)(−1)/21! = binom(42,21)/2^64 = 67282234305/2305843009213693952, exact.
* Remainder: φ − H = φ^(21)(ξ)/21! · (t+1)^9 ∏(t−s_i)², with ξ in the hull
  of {t, −1, s_i}, which lies in [−1,1).
  * The Rolle proof in HERMITE_PROOF.md is correct.
  * Validation on a 4000-point grid over [−1,1): (φ−H)/w always lies in
    [φ^(21)(−1)/21!, φ^(21)(max(t,s6))/21!].
* **Range.** The bound holds on all of [−1,1), not only on [−1,0.5593].
  * w ≥ ε^21 outside the closed windows, so φ − h ≥ φ − H > 2.918e-92 > 1e-92.
    The Fraction check passes.
  * Negative controls: with ε = 0.8e-4 the constant falls below 1e-92, and at
    the exact contacts φ − h ≈ 5e-180. So the windows are necessary.
* **Diagnostic.** The true exterior minimum of φ − h is about 8.05e-44, at
  t = −1+ε. At the contact-window edges it is at least 5.7e-23. The 1e-92
  threshold is about 48 orders of magnitude conservative.

## (c) The implication

From Σ_{i<j} h(t_ij) ≥ U − 36L, E(X) ≤ E(P9) ≤ U, and 0 ≤ φ − h on [−1,1),
we get Σ(φ − h)(t_ij) ≤ 36L < 1e-92. Each term is therefore below 1e-92, so
every t_ij lies in a closed window.

* **Same h, same U.** Verified on the final certificate: the minorant is
  *exactly* the h in hermite.json, and raw_energy is *exactly* U. The domain
  is [−1, 5593/10000], with n = 9, degree 10, and no determinant term.
* **Linkage enforced in code.** `check_sos_integer.check(data, hermite)`
  rejects every linkage mutation:
  * h changed by 1e-200;
  * U changed;
  * the domain changed to 0.5594 or to −0.9999;
  * a truncated h;
  * corrupted hermite data.

  A zero-factor certificate passes the replay but correctly reports
  `spectrum_localization_threshold_met = False`.
* **L accounts for every residual.** I wrote a third exact replay,
  `w2_audit_replay.py`, independent of both Codex replays.
  * It derives the Chebyshev kernels itself and applies the repeated-index
    operator R by genuine polynomial composition.
  * It computes the full, uncompressed residual l1 norm over all 1771
    monomials, so no symmetry assumption is needed.
  * Result: L is *identical* to Codex's residual_l1 (log10 L = −164.956), and
    36L = 3.98e-164 < 1e-92. The residual is fully symmetric, so compressed
    and full l1 agree.
* **Multipliers.** The six multipliers that sosblocks returns equal the
  spelled-out valid multipliers 1, u+1, 0.5593−u, D, (u+1)(0.5593−u) and
  D(u+1)(0.5593−u). All are nonnegative on the domain.
* **Kernel normalisation.** I re-derived the counting
  Σ_{a<b<c} R_k = (N−2)/6 · Σ_{ordered} S_k myself.
* **Semantic tests of the replayed polynomials.**
  * Each kernel block's triple sum is ≥ 0 on an unrestricted random
    configuration.
  * Each SOS block's triple sum is ≥ 0 on six in-domain configurations.
  * target − A = Σ blocks holds numerically.
  * At P9 all blocks vanish to 1e-14, which is consistent with a sharp
    certificate.
* **Falsification attempts.**
  * Riemannian Hessian of G = Σh at P9: tangent minimum 0.1439343, against
    0.1439350 for E. There are exactly 3 rotation zero modes, and the matrix
    is PSD.
  * 400 constrained SLSQP multistarts (max t ≤ 0.5593) all give
    min(G − U) ≥ −7e-15, which is float noise.
  * At 260 digits, G(P9(rMid)) − U = −1.95e-178. This is consistent with
    36L = 4e-164 and close to the predicted −36(H−h) − (U−Φ).

## Findings

All five are MINOR. None invalidates a proof step.

1. **Separation threshold not checked in code.** No checker in the
   near_sharp / check_sos_integer chain asserts U < 6439996633/250000000,
   the energy threshold of `sdp/lp-separation-05593.check.json`. The
   implication needs this to restrict pairs to [−1, 0.5593]. It is true, with
   margin 7.30e-10 (verified here), but it is not enforced.
   *Fix:* assert it in the Hermite path of check_sos_integer.py, reading the
   threshold from the separation report.
2. **Avoidable external dependencies.**
   * HERMITE_PROOF.md identifies the root through "Lean stationarity
     uniqueness". F'' is visibly a sum of positive terms, so the root is
     unique without that.
   * It gets E(P9) ≤ Φ(rMid) from the family-minimum theorem. Evaluating Φ
     on intervals over all of [lo,hi] already gives U ≥ Φ(r*) (margin
     4.6e-181).

   Neither is an error. Stating these would shrink the trust base.
3. **Analytic steps are not machine-checked.** The Hermite remainder theorem,
   the sign and monotonicity of φ^(21), and the bound w ≥ ε^21 are all
   analytic. `check_hermite` checks only the final constant comparison, and
   with Hermite data `check_sos_integer` skips the Bernstein minorant test.
   So h ≤ φ rests on the written proof. That proof is correct, and the scope
   strings say this honestly. It remains an obligation for any Lean
   formalization.
4. **Few built-in negative controls.** check_hermite has only three. It also
   rejects some sound but loose data, because of its accuracy and tightness
   assertions; that is conservative, not unsound. My 25 mutations all behave
   correctly. One mutation I expected to fail was accepted (c20 += 1e-180),
   and I independently confirmed it is sound.
5. **Very conservative threshold (informational).** The exterior slack 1e-92
   is about 48 orders of magnitude below the true exterior minimum of
   about 8e-44. No action is needed, since 36L ≈ 4e-164.

## Reproduction

From `W/claude/audit/hermite`, with `PY=../../venv/Scripts/python.exe` and
`-B` so that no bytecode is written:

```
$PY -B w2_audit_hermite_exact.py   # (a): Arb root/contacts/Vandermonde/dominance/U, sympy derivative identities  (~2 s)
$PY -B w2_audit_remainder.py       # (b): mp 300-digit remainder validation, exterior bound, diagnostics (~3 min)
$PY -B w2_audit_mutations.py       # 25 mutations of Codex check_hermite + -O refusal + bit-exact rerun (needs claude_hermite_enclosures.json from the first script)
$PY -B w2_audit_interval_fuzz.py   # containment fuzz of exact_interval.I + broken-mutant detection
$PY -B w2_audit_linkage.py         # (c): final-certificate field linkage + check_sos_integer linkage mutations
$PY -B w2_audit_replay.py          # (c): third independent exact residual replay (~15 s) + semantic tests
$PY -B w2_audit_falsify.py         # Hessian of sum h at P9, 400 constrained multistarts, mp perturbations (~45 s)
```

Each script writes `<name>.result.json` here and exits non-zero on failure.
Final state: all seven exit 0.

## Not covered by this audit

* Step 1, the separation LP certificate.
* Step 4, the rigidity classification.
* Step 5, LOCAL_PROOF.
* Correctness of `polynomial.sosblocks` bases beyond their multipliers (any
  basis is sound).
* Lean formalization.
