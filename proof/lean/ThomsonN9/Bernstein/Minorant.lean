import ThomsonN9.Bernstein.MinorantCert
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Data.List.GetD
import Mathlib.Analysis.InnerProductSpace.Basic

/-!
# The N=9 Coulomb minorant: `h ≤ φ` on `[-1,1)` and the exterior gap `10⁻⁴⁶`

`minorant` is the degree-20 rational polynomial `h` of
`outputs/thomson-n9/near_sharp/bernstein-minorant.json`, and `phi t = (2-2t)^(-1/2)` is the
Coulomb potential of two unit vectors with inner product `t`.

Main results (all kernel-checked, standard axioms only):
* `minorant_le_phi : -1 ≤ t → t < 1 → minorant t ≤ phi t`;
* `exterior_gap`: for `r` in the 40-digit radius bracket and `t ∈ [-1+ε, 5593/10000]` at
  distance `≥ ε = 1/10000` from each of the six contact values `sⱼ(r)`,
  `minorant t + 10⁻⁴⁶ ≤ phi t`.

The bridge is the substitution `y = √((1-t)/2)`, i.e. `t = 1 - 2y²`, `phi t = 1/(2y)`:
`D·(1 - 2y·h(1-2y²)) ≥ 0` is checked by the verified Bernstein checker of `Checker.lean`.
-/

namespace ThomsonN9.Bernstein

/-! ### Definitions -/

/-- The minorant `h(t) = ∑ᵢ hᵢ tⁱ`, with `hᵢ = minorantNum[i] / minorantDen`. -/
noncomputable def minorant (t : ℝ) : ℝ := polyEval minorantNum t / minorantDen

theorem getD_map_div (l : List ℤ) (D : ℤ) (i : ℕ) :
    (l.map (fun z : ℤ => (z : ℚ) / D)).getD i 0 = ((l.getD i 0 : ℤ) : ℚ) / D := by
  induction l generalizing i with
  | nil => simp
  | cons a l ih =>
    cases i with
    | zero => simp
    | succ i => simp only [List.map_cons, List.getD_cons_succ, ih]

/-- `h` in coefficient form, with the 21 rational coefficients `minorantRat` of the JSON file. -/
theorem minorant_eq_sum (t : ℝ) :
    minorant t = ∑ i ∈ Finset.range 21, ((minorantRat.getD i 0 : ℚ) : ℝ) * t ^ i := by
  have hlen : minorantNum.length = 21 := by decide +kernel
  rw [minorant, polyEval_eq_sum, hlen, Finset.sum_div]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [minorantRat_eq, getD_map_div, Rat.cast_div, Rat.cast_intCast, Rat.cast_intCast]
  ring

/-- Coulomb pair potential in terms of the inner product: `φ(t) = (2-2t)^(-1/2)`. -/
noncomputable def phi (t : ℝ) : ℝ := (2 - 2 * t) ^ (-(1 / 2 : ℝ))

/-- The six contact inner products of the candidate with radius `r`. -/
noncomputable def contact (r : ℝ) : Fin 6 → ℝ :=
  ![r ^ 2 / 2 - 1, -r, -1 / 2, 2 * r ^ 2 - 1, 1 - 3 * r ^ 2 / 2, r / 2]

/-! ### Real-analysis bridge -/

theorem minorantDen_pos : (0 : ℝ) < minorantDen := by
  norm_num [minorantDen]

theorem phi_eq {t : ℝ} (ht : t < 1) : phi t = (Real.sqrt (2 - 2 * t))⁻¹ := by
  rw [phi, Real.rpow_neg (by linarith), Real.sqrt_eq_rpow]

/-- With `y = √((1-t)/2)`: `y > 0`, `1 - 2y² = t` and `√(2-2t) = 2y`. -/
theorem sqrt_subst {t : ℝ} (ht : t < 1) :
    0 < Real.sqrt ((1 - t) / 2) ∧ 1 - 2 * Real.sqrt ((1 - t) / 2) ^ 2 = t ∧
      Real.sqrt (2 - 2 * t) = 2 * Real.sqrt ((1 - t) / 2) := by
  have hpos : (0 : ℝ) < (1 - t) / 2 := by linarith
  have hsq := Real.sq_sqrt hpos.le
  refine ⟨Real.sqrt_pos.2 hpos, by rw [hsq]; ring, ?_⟩
  rw [show (2 : ℝ) - 2 * t = 2 ^ 2 * ((1 - t) / 2) by ring,
    Real.sqrt_mul (by norm_num), Real.sqrt_sq (by norm_num)]

/-- Core inequality: from `0 ≤ D - 2y·(g + P(1-2y²))` with `y = √((1-t)/2)` we get
`(g + P(t))/D ≤ φ(t)`. -/
theorem le_phi_of_potential {t : ℝ} (ht : t < 1) (P g : ℝ)
    (h : 0 ≤ (minorantDen : ℝ) - 2 * Real.sqrt ((1 - t) / 2) *
      (g + P)) : (g + P) / minorantDen ≤ phi t := by
  obtain ⟨hy, -, hs⟩ := sqrt_subst ht
  rw [phi_eq ht, hs, div_le_iff₀ minorantDen_pos, ← div_eq_inv_mul,
    le_div_iff₀ (by linarith)]
  linarith

/-- `h ≤ φ` on `[-1, 1)`. -/
theorem minorant_le_phi {t : ℝ} (h1 : -1 ≤ t) (h2 : t < 1) : minorant t ≤ phi t := by
  obtain ⟨hy, hyt, -⟩ := sqrt_subst h2
  have hy1 : Real.sqrt ((1 - t) / 2) ≤ 1 :=
    calc Real.sqrt ((1 - t) / 2) ≤ Real.sqrt 1 := Real.sqrt_le_sqrt (by linarith)
      _ = 1 := Real.sqrt_one
  have hM : (0 : ℝ) < globalM := by norm_num [globalM]
  have hlast : globalPts.getLastD globalPt0 = globalM := by decide +kernel
  have h0 : globalPt0 = 0 := rfl
  have key := checkCover_sound globalPt0 globalPts global_cert (Real.sqrt ((1 - t) / 2))
    (by rw [h0]; simpa using mul_nonneg hM.le hy.le) (by rw [hlast]; nlinarith)
  rw [polyEval_potential, hyt] at key
  have := le_phi_of_potential h2 (polyEval minorantNum t) 0 (by simpa using key)
  rw [zero_add] at this
  rw [minorant]; exact this

/-- The `√` substitution lands in the `y`-interval of an exterior interval. -/
theorem extOk_sound {A B M : ℤ} {lo hi : ℚ} (h : extOk A B M lo hi = true) (hM : 0 < M)
    {t : ℝ} (h1 : (lo : ℝ) ≤ t) (h2 : t ≤ hi) :
    t < 1 ∧ (A : ℝ) ≤ M * Real.sqrt ((1 - t) / 2) ∧ (M : ℝ) * Real.sqrt ((1 - t) / 2) ≤ B := by
  simp only [extOk, Bool.and_eq_true, decide_eq_true_eq] at h
  obtain ⟨⟨⟨⟨hA, hB⟩, hhi⟩, hlo2⟩, hhi2⟩ := h
  have hA' : (0 : ℝ) ≤ A := by exact_mod_cast hA
  have hB' : (0 : ℝ) ≤ B := by exact_mod_cast hB
  have hhi' : (hi : ℝ) < 1 := by exact_mod_cast hhi
  have hlo2' : (A : ℝ) * A ≤ (M : ℝ) * M * ((1 - (hi : ℝ)) / 2) := by exact_mod_cast hlo2
  have hhi2' : (M : ℝ) * M * ((1 - (lo : ℝ)) / 2) ≤ (B : ℝ) * B := by exact_mod_cast hhi2
  have ht1 : t < 1 := lt_of_le_of_lt h2 hhi'
  have hM' : (0 : ℝ) < M := by exact_mod_cast hM
  have hpos : (0 : ℝ) ≤ (1 - t) / 2 := by linarith
  have hy0 : 0 ≤ Real.sqrt ((1 - t) / 2) := Real.sqrt_nonneg _
  have hyy : Real.sqrt ((1 - t) / 2) * Real.sqrt ((1 - t) / 2) = (1 - t) / 2 :=
    Real.mul_self_sqrt hpos
  have hMy : (M * Real.sqrt ((1 - t) / 2)) * (M * Real.sqrt ((1 - t) / 2))
      = (M : ℝ) * M * ((1 - t) / 2) :=
    calc (M * Real.sqrt ((1 - t) / 2)) * (M * Real.sqrt ((1 - t) / 2))
        = (M : ℝ) * M * (Real.sqrt ((1 - t) / 2) * Real.sqrt ((1 - t) / 2)) := by ring
      _ = (M : ℝ) * M * ((1 - t) / 2) := by rw [hyy]
  have hMy0 : 0 ≤ (M : ℝ) * Real.sqrt ((1 - t) / 2) := mul_nonneg hM'.le hy0
  have hMM : (0 : ℝ) ≤ (M : ℝ) * M := mul_nonneg hM'.le hM'.le
  refine ⟨ht1, ?_, ?_⟩
  · rw [mul_self_le_mul_self_iff hA' hMy0, hMy]
    calc (A : ℝ) * A ≤ (M : ℝ) * M * ((1 - (hi : ℝ)) / 2) := hlo2'
      _ ≤ (M : ℝ) * M * ((1 - t) / 2) :=
        mul_le_mul_of_nonneg_left (by linarith) hMM
  · rw [mul_self_le_mul_self_iff hMy0 hB', hMy]
    calc (M : ℝ) * M * ((1 - t) / 2) ≤ (M : ℝ) * M * ((1 - (lo : ℝ)) / 2) :=
        mul_le_mul_of_nonneg_left (by linarith) hMM
      _ ≤ (B : ℝ) * B := hhi2'

theorem polyEval_addL_single (g : ℤ) (l : List ℤ) (t : ℝ) :
    polyEval (addL [g] l) t = g + polyEval l t := by
  rw [polyEval_addL]; simp

theorem gapNum_div : (gapNum : ℝ) / minorantDen = 1 / 10 ^ 46 := by
  norm_num [gapNum, minorantDen]

theorem extM_pos : (0 : ℤ) < extM := by norm_num [extM]

/-- One exterior interval: `h + 10⁻⁴⁶ ≤ φ` on `[extLo[j], extHi[j]]`. -/
theorem gap_of_extCheck {j : ℕ} (hj : extCheck j = true) {t : ℝ}
    (h1 : ((extLo.getD j 0 : ℚ) : ℝ) ≤ t) (h2 : t ≤ ((extHi.getD j 0 : ℚ) : ℝ)) :
    minorant t + 1 / 10 ^ 46 ≤ phi t := by
  simp only [extCheck, Bool.and_eq_true] at hj
  obtain ⟨ht1, hA, hB⟩ := extOk_sound hj.2 extM_pos h1 h2
  obtain ⟨-, hyt, -⟩ := sqrt_subst ht1
  have key := checkInterval_sound hj.1 _ hA hB
  rw [polyEval_potential, hyt, polyEval_addL_single] at key
  have := le_phi_of_potential ht1 (polyEval minorantNum t) (gapNum : ℝ) key
  rw [add_div, gapNum_div] at this
  rw [minorant]; linarith

/-! ### Exterior gap outside the seven windows -/

theorem contact_bounds {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) :
    (rLower : ℝ) * rLower ≤ r ^ 2 ∧ r ^ 2 ≤ (rUpper : ℝ) * rUpper := by
  have h0 : (0 : ℝ) < rLower := by norm_num [rLower]
  constructor <;> nlinarith

/-- **Exterior gap.** For `r` in the radius bracket, every `t ∈ [-1+ε, 5593/10000]` with
`|t - sⱼ(r)| ≥ ε` for all six contacts satisfies `φ(t) - h(t) ≥ 10⁻⁴⁶`. -/
theorem exterior_gap {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) {t : ℝ}
    (ht1 : -1 + 1 / 10000 ≤ t) (ht2 : t ≤ 5593 / 10000)
    (hw : ∀ j : Fin 6, 1 / 10000 ≤ |t - contact r j|) :
    minorant t + 1 / 10 ^ 46 ≤ phi t := by
  obtain ⟨hsq1, hsq2⟩ := contact_bounds hr1 hr2
  have side : ∀ j : Fin 6, t ≤ contact r j - 1 / 10000 ∨ contact r j + 1 / 10000 ≤ t := by
    intro j
    rcases le_abs'.1 (hw j) with h | h
    · left; linarith
    · right; linarith
  have c0 : t ≤ r ^ 2 / 2 - 1 - 1 / 10000 ∨ r ^ 2 / 2 - 1 + 1 / 10000 ≤ t := side 0
  have c1 : t ≤ -r - 1 / 10000 ∨ -r + 1 / 10000 ≤ t := side 1
  have c2 : t ≤ -1 / 2 - 1 / 10000 ∨ -1 / 2 + 1 / 10000 ≤ t := side 2
  have c3 : t ≤ 2 * r ^ 2 - 1 - 1 / 10000 ∨ 2 * r ^ 2 - 1 + 1 / 10000 ≤ t := side 3
  have c4 : t ≤ 1 - 3 * r ^ 2 / 2 - 1 / 10000 ∨ 1 - 3 * r ^ 2 / 2 + 1 / 10000 ≤ t := side 4
  have c5 : t ≤ r / 2 - 1 / 10000 ∨ r / 2 + 1 / 10000 ≤ t := side 5
  rcases c0 with h0 | h0
  · refine gap_of_extCheck ext_cert0 ?_ ?_
    · norm_num [extLo, winEps]; linarith
    · norm_num [extHi, winEps]; linarith
  rcases c1 with h1 | h1
  · refine gap_of_extCheck ext_cert1 ?_ ?_
    · norm_num [extLo, winEps]; linarith
    · norm_num [extHi, winEps]; linarith
  rcases c2 with h2 | h2
  · refine gap_of_extCheck ext_cert2 ?_ ?_
    · norm_num [extLo, winEps]; linarith
    · norm_num [extHi, winEps]; linarith
  rcases c3 with h3 | h3
  · refine gap_of_extCheck ext_cert3 ?_ ?_
    · norm_num [extLo, winEps]; linarith
    · norm_num [extHi, winEps]; linarith
  rcases c4 with h4 | h4
  · refine gap_of_extCheck ext_cert4 ?_ ?_
    · norm_num [extLo, winEps]; linarith
    · norm_num [extHi, winEps]; linarith
  rcases c5 with h5 | h5
  · refine gap_of_extCheck ext_cert5 ?_ ?_
    · norm_num [extLo, winEps]; linarith
    · norm_num [extHi, winEps]; linarith
  · refine gap_of_extCheck ext_cert6 ?_ ?_
    · norm_num [extLo, winEps]; linarith
    · norm_num [extHi, winEps]; linarith

/-- The exterior gap in the form `φ(t) - h(t) ≥ 10⁻⁴⁶`. -/
theorem exterior_gap' {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) {t : ℝ}
    (ht1 : -1 + 1 / 10000 ≤ t) (ht2 : t ≤ 5593 / 10000)
    (hw : ∀ j : Fin 6, 1 / 10000 ≤ |t - contact r j|) :
    1 / 10 ^ 46 ≤ phi t - minorant t := by
  have := exterior_gap hr1 hr2 ht1 ht2 hw
  linarith

/-- `h ≤ φ` in the `‖x - y‖⁻¹` form used by the energy: `(√(2-2t))⁻¹`. -/
theorem minorant_le_inv_sqrt {t : ℝ} (h1 : -1 ≤ t) (h2 : t < 1) :
    minorant t ≤ (Real.sqrt (2 - 2 * t))⁻¹ := by
  rw [← phi_eq h2]; exact minorant_le_phi h1 h2

/-! ### Unit-vector form -/

/-- For distinct unit vectors, `‖x - y‖ = √(2 - 2⟪x,y⟫)` and `-1 ≤ ⟪x,y⟫ < 1`. -/
theorem unit_inner_facts {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {x y : E} (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) (hxy : x ≠ y) :
    -1 ≤ inner ℝ x y ∧ inner ℝ x y < 1 ∧ ‖x - y‖ = Real.sqrt (2 - 2 * inner ℝ x y) := by
  have hsq : ‖x - y‖ ^ 2 = 2 - 2 * inner ℝ x y := by
    rw [norm_sub_sq_real, hx, hy]; ring
  have hcs : |inner ℝ x y| ≤ ‖x‖ * ‖y‖ := abs_real_inner_le_norm x y
  rw [hx, hy, mul_one] at hcs
  have hpos : 0 < ‖x - y‖ := norm_pos_iff.2 (sub_ne_zero.2 hxy)
  refine ⟨(abs_le.1 hcs).1, ?_, ?_⟩
  · nlinarith
  · rw [← hsq, Real.sqrt_sq (norm_nonneg _)]

/-- `h(⟪x,y⟫) ≤ ‖x - y‖⁻¹` for distinct unit vectors (the form used for the energy). -/
theorem minorant_le_inv_dist {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {x y : E} (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) (hxy : x ≠ y) :
    minorant (inner ℝ x y) ≤ ‖x - y‖⁻¹ := by
  obtain ⟨h1, h2, h3⟩ := unit_inner_facts hx hy hxy
  rw [h3]; exact minorant_le_inv_sqrt h1 h2

/-- `φ(⟪x,y⟫) = ‖x - y‖⁻¹` for distinct unit vectors. -/
theorem phi_inner {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {x y : E} (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) (hxy : x ≠ y) :
    phi (inner ℝ x y) = ‖x - y‖⁻¹ := by
  obtain ⟨-, h2, h3⟩ := unit_inner_facts hx hy hxy
  rw [h3, phi_eq h2]

end ThomsonN9.Bernstein

#print axioms ThomsonN9.Bernstein.minorant_le_phi
#print axioms ThomsonN9.Bernstein.minorant_le_inv_sqrt
#print axioms ThomsonN9.Bernstein.minorant_le_inv_dist
#print axioms ThomsonN9.Bernstein.exterior_gap
#print axioms ThomsonN9.Bernstein.exterior_gap'
#print axioms ThomsonN9.Bernstein.minorant_eq_sum
#print axioms ThomsonN9.Bernstein.phi_inner
#print axioms ThomsonN9.Bernstein.checkInterval_sound
#print axioms ThomsonN9.Bernstein.checkCover_sound
#print axioms ThomsonN9.Bernstein.runSteps_sound
