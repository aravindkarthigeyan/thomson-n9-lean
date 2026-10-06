import ClaudeL2b.LPData
import ThomsonN9.Bernstein.Minorant

/-!
# The two LP minorant inequalities (Codex's LP covers), kernel-checked

Data: `work/lp-horner-interface.json` (numerator lists and common denominators, verbatim),
trees and tail intervals from `near_sharp/lp-separation{,-05593}-bernstein.json`.

With `y = √((1-t)/2)` (so `t = 1-2y²`, `(√(2-2t))⁻¹ = 1/(2y)`), `P(t)/D ≤ (√(2-2t))⁻¹`
is `0 ≤ D - 2y·P(1-2y²) = polyEval (potential P D) y`; this is checked by L2's verified
`checkInterval` on `y ∈ [0,1]` with Codex's preorder tree (exact arithmetic, `d = 1`).

Results, stated with `(Real.sqrt (2 - 2 * t))⁻¹`, which is Codex's
`ThomsonN9.SDP.coulombPotential t` by definition:
* `covariance_le_inv_sqrt : -1 ≤ t → t < 1 → polyEval covarianceNumerators t / covarianceDenominator ≤ (√(2-2t))⁻¹`
* `separation_le_inv_sqrt`: the same for the separation LP minorant;
* `separation_tail : 5593/10000 ≤ t → t < 1 →
    polyEval separationNumerators t / separationDenominator
      + ((6439996633/250000000 : ℝ) - 25728382789209/1000000000000) + 1/100000000 ≤ (√(2-2t))⁻¹`
* `covariance_tail` (cap `567/1000`, not needed by the final proof).
-/

namespace ThomsonN9.Claude.L2b

open ThomsonN9.Bernstein

/-! ### Generic bridge -/

/-- From `0 ≤ D - 2y·P` with `y = √((1-t)/2)`: `P / D ≤ (√(2-2t))⁻¹`. -/
theorem div_le_inv_sqrt_of_nonneg {t : ℝ} (ht : t < 1) {D : ℤ} (hD : 0 < D) (P : ℝ)
    (h : 0 ≤ (D : ℝ) - 2 * Real.sqrt ((1 - t) / 2) * P) :
    P / D ≤ (Real.sqrt (2 - 2 * t))⁻¹ := by
  obtain ⟨hy, -, hs⟩ := sqrt_subst ht
  have hD' : (0 : ℝ) < D := by exact_mod_cast hD
  rw [hs, div_le_iff₀ hD', ← div_eq_inv_mul, le_div_iff₀ (by linarith)]
  linarith

/-- A global cover on `y ∈ [0,1]` gives `P/D ≤ (√(2-2t))⁻¹` on `[-1,1)`. -/
theorem le_inv_sqrt_of_global {num : List ℤ} {den : ℤ} (hden : 0 < den) {fuel bits : ℕ}
    (hc : checkInterval (potential num den) 0 1 1 1 fuel bits = true) {t : ℝ}
    (h1 : -1 ≤ t) (h2 : t < 1) :
    polyEval num t / den ≤ (Real.sqrt (2 - 2 * t))⁻¹ := by
  obtain ⟨hy, hyt, -⟩ := sqrt_subst h2
  have hy1 : Real.sqrt ((1 - t) / 2) ≤ 1 :=
    calc Real.sqrt ((1 - t) / 2) ≤ Real.sqrt 1 := Real.sqrt_le_sqrt (by linarith)
      _ = 1 := Real.sqrt_one
  have key := checkInterval_sound hc (Real.sqrt ((1 - t) / 2))
    (by push_cast; linarith) (by push_cast; linarith)
  rw [polyEval_potential, hyt] at key
  exact div_le_inv_sqrt_of_nonneg h2 hden _ key

/-- Tail certificate: a leaf of `g + P` on `y ∈ [0, B/M]` with `(1-cap)/2 ≤ (B/M)²`. -/
def tailCheck (num : List ℤ) (den g B M : ℤ) (cap : ℚ) : Bool :=
  checkInterval (potential (addL [g] num) den) 0 B M 1 1 1 &&
    decide (0 ≤ B) && decide ((M : ℚ) * M * ((1 - cap) / 2) ≤ (B : ℚ) * B)

/-- The tail certificate gives `(g + P(t))/D ≤ (√(2-2t))⁻¹` on `[cap, 1)`. -/
theorem le_inv_sqrt_of_tail {num : List ℤ} {den g B M : ℤ} {cap : ℚ} (hden : 0 < den)
    (hM : 0 < M) (hc : tailCheck num den g B M cap = true) {t : ℝ} (h1 : (cap : ℝ) ≤ t) (h2 : t < 1) :
    ((g : ℝ) + polyEval num t) / den ≤ (Real.sqrt (2 - 2 * t))⁻¹ := by
  simp only [tailCheck, Bool.and_eq_true, decide_eq_true_eq] at hc
  obtain ⟨⟨hcert, hB⟩, hcap⟩ := hc
  have hM' : (0 : ℝ) < M := by exact_mod_cast hM
  have hB' : (0 : ℝ) ≤ B := by exact_mod_cast hB
  have hcap' : (M : ℝ) * M * ((1 - (cap : ℝ)) / 2) ≤ (B : ℝ) * B := by exact_mod_cast hcap
  obtain ⟨hy, hyt, -⟩ := sqrt_subst h2
  have hpos : (0 : ℝ) ≤ (1 - t) / 2 := by linarith
  have hyy : Real.sqrt ((1 - t) / 2) * Real.sqrt ((1 - t) / 2) = (1 - t) / 2 :=
    Real.mul_self_sqrt hpos
  have hMy0 : 0 ≤ (M : ℝ) * Real.sqrt ((1 - t) / 2) := mul_nonneg hM'.le hy.le
  have hMM : (0 : ℝ) ≤ (M : ℝ) * M := mul_nonneg hM'.le hM'.le
  have hupper : (M : ℝ) * Real.sqrt ((1 - t) / 2) ≤ B := by
    rw [mul_self_le_mul_self_iff hMy0 hB']
    calc (M * Real.sqrt ((1 - t) / 2)) * (M * Real.sqrt ((1 - t) / 2))
        = (M : ℝ) * M * (Real.sqrt ((1 - t) / 2) * Real.sqrt ((1 - t) / 2)) := by ring
      _ = (M : ℝ) * M * ((1 - t) / 2) := by rw [hyy]
      _ ≤ (M : ℝ) * M * ((1 - (cap : ℝ)) / 2) :=
          mul_le_mul_of_nonneg_left (by linarith) hMM
      _ ≤ (B : ℝ) * B := hcap'
  have key := checkInterval_sound hcert (Real.sqrt ((1 - t) / 2))
    (by push_cast; exact hMy0) hupper
  rw [polyEval_potential, hyt, polyEval_addL_single] at key
  exact div_le_inv_sqrt_of_nonneg h2 hden _ key

/-! ### Kernel certificates -/

theorem cov_global_cert : checkInterval (potential covarianceNumerators covarianceDenominator)
    0 1 1 1 covTreeLen covTreeBits = true := by decide +kernel

theorem sep_global_cert : checkInterval (potential separationNumerators separationDenominator)
    0 1 1 1 sepTreeLen sepTreeBits = true := by decide +kernel

theorem cov_tail_cert : tailCheck covarianceNumerators covarianceDenominator covTailGapNum
    covTailB covTailM covTailCap = true := by decide +kernel

theorem sep_tail_cert : tailCheck separationNumerators separationDenominator sepTailGapNum
    sepTailB sepTailM sepTailCap = true := by decide +kernel

/-! ### The LP minorant inequalities -/

theorem covarianceDenominator_pos : (0 : ℤ) < covarianceDenominator := by
  norm_num [covarianceDenominator]

theorem separationDenominator_pos : (0 : ℤ) < separationDenominator := by
  norm_num [separationDenominator]

/-- **Covariance LP minorant** `h_cov ≤ φ` on `[-1,1)`. -/
theorem covariance_le_inv_sqrt : ∀ t : ℝ, -1 ≤ t → t < 1 →
    polyEval covarianceNumerators t / covarianceDenominator ≤ (Real.sqrt (2 - 2 * t))⁻¹ :=
  fun _ h1 h2 => le_inv_sqrt_of_global covarianceDenominator_pos cov_global_cert h1 h2

/-- **Separation LP minorant** `h_sep ≤ φ` on `[-1,1)`. -/
theorem separation_le_inv_sqrt : ∀ t : ℝ, -1 ≤ t → t < 1 →
    polyEval separationNumerators t / separationDenominator ≤ (Real.sqrt (2 - 2 * t))⁻¹ :=
  fun _ h1 h2 => le_inv_sqrt_of_global separationDenominator_pos sep_global_cert h1 h2

theorem sepTailGap_div : (sepTailGapNum : ℝ) / separationDenominator =
    ((6439996633 / 250000000 : ℝ) - 25728382789209 / 1000000000000) + 1 / 100000000 := by
  norm_num [sepTailGapNum, separationDenominator]

theorem covTailGap_div : (covTailGapNum : ℝ) / covarianceDenominator =
    ((6439996633 / 250000000 : ℝ) - 51457135199103 / 2000000000000) + 1 / 100000000 := by
  norm_num [covTailGapNum, covarianceDenominator]

/-- **Separation tail** `h_sep + (U - B_sep) + 10⁻⁸ ≤ φ` on `[5593/10000, 1)`, with
`U = 6439996633/250000000` and `B_sep = 25728382789209/10^12`. -/
theorem separation_tail : ∀ t : ℝ, (5593 / 10000 : ℝ) ≤ t → t < 1 →
    polyEval separationNumerators t / separationDenominator +
        ((6439996633 / 250000000 : ℝ) - 25728382789209 / 1000000000000) + 1 / 100000000 ≤
      (Real.sqrt (2 - 2 * t))⁻¹ := by
  intro t h1 h2
  have hcap : ((sepTailCap : ℚ) : ℝ) ≤ t := by norm_num [sepTailCap]; linarith
  have key := le_inv_sqrt_of_tail separationDenominator_pos (by norm_num [sepTailM]) sep_tail_cert hcap h2
  rw [add_div, sepTailGap_div] at key
  linarith

/-- Covariance tail `h_cov + (U - B_cov) + 10⁻⁸ ≤ φ` on `[567/1000, 1)` (for completeness;
not needed by the final proof). -/
theorem covariance_tail : ∀ t : ℝ, (567 / 1000 : ℝ) ≤ t → t < 1 →
    polyEval covarianceNumerators t / covarianceDenominator +
        ((6439996633 / 250000000 : ℝ) - 51457135199103 / 2000000000000) + 1 / 100000000 ≤
      (Real.sqrt (2 - 2 * t))⁻¹ := by
  intro t h1 h2
  have hcap : ((covTailCap : ℚ) : ℝ) ≤ t := by norm_num [covTailCap]; linarith
  have key := le_inv_sqrt_of_tail covarianceDenominator_pos (by norm_num [covTailM]) cov_tail_cert hcap h2
  rw [add_div, covTailGap_div] at key
  linarith

/-! ### `phi` forms (L2's `ThomsonN9.Bernstein.phi`) -/

theorem covariance_le_phi {t : ℝ} (h1 : -1 ≤ t) (h2 : t < 1) :
    polyEval covarianceNumerators t / covarianceDenominator ≤ phi t := by
  rw [phi_eq h2]; exact covariance_le_inv_sqrt t h1 h2

theorem separation_le_phi {t : ℝ} (h1 : -1 ≤ t) (h2 : t < 1) :
    polyEval separationNumerators t / separationDenominator ≤ phi t := by
  rw [phi_eq h2]; exact separation_le_inv_sqrt t h1 h2

/-! ### Adapter to Codex's `N9LPConcrete` hypotheses

If Codex's Legendre linkage gives `m t = polyEval Numerators t / Denominator` (this is
`covariance_horner_eq` / `separation_horner_eq` of `work/N9LPLinkage.lean`, read from right
to left, after unfolding `legendreExpansion`), the hypotheses `hminor` / `htail` of
`covariance_lt_quarter` / `inner_lt_separation` follow (`SDP.coulombPotential t` unfolds to
`(Real.sqrt (2-2*t))⁻¹`). -/

theorem hminor_of_horner_cov (m : ℝ → ℝ)
    (hm : ∀ t, polyEval covarianceNumerators t / covarianceDenominator = m t) :
    ∀ t : ℝ, -1 ≤ t → t < 1 → m t ≤ (Real.sqrt (2 - 2 * t))⁻¹ := by
  intro t h1 h2; rw [← hm]; exact covariance_le_inv_sqrt t h1 h2

theorem hminor_of_horner_sep (m : ℝ → ℝ)
    (hm : ∀ t, polyEval separationNumerators t / separationDenominator = m t) :
    ∀ t : ℝ, -1 ≤ t → t < 1 → m t ≤ (Real.sqrt (2 - 2 * t))⁻¹ := by
  intro t h1 h2; rw [← hm]; exact separation_le_inv_sqrt t h1 h2

theorem htail_of_horner_sep (m : ℝ → ℝ) (U B : ℝ) (hU : U = 6439996633 / 250000000)
    (hB : B = 25728382789209 / 1000000000000)
    (hm : ∀ t, polyEval separationNumerators t / separationDenominator = m t) :
    ∀ t : ℝ, (5593 / 10000 : ℝ) ≤ t → t < 1 →
      m t + (U - B) + (1 / 100000000 : ℝ) ≤ (Real.sqrt (2 - 2 * t))⁻¹ := by
  intro t h1 h2; rw [← hm, hU, hB]; exact separation_tail t h1 h2

end ThomsonN9.Claude.L2b

#print axioms ThomsonN9.Claude.L2b.cov_global_cert
#print axioms ThomsonN9.Claude.L2b.sep_global_cert
#print axioms ThomsonN9.Claude.L2b.sep_tail_cert
#print axioms ThomsonN9.Claude.L2b.covariance_le_inv_sqrt
#print axioms ThomsonN9.Claude.L2b.separation_le_inv_sqrt
#print axioms ThomsonN9.Claude.L2b.separation_tail
#print axioms ThomsonN9.Claude.L2b.covariance_tail
#print axioms ThomsonN9.Claude.L2b.hminor_of_horner_cov
#print axioms ThomsonN9.Claude.L2b.hminor_of_horner_sep
#print axioms ThomsonN9.Claude.L2b.htail_of_horner_sep
