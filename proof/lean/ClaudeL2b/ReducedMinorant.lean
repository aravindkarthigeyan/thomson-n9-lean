import ClaudeL2b.ReducedData
import ThomsonN9.Bernstein.Minorant

/-!
# The reduced minorant `h_new` lies below L2's `h` by at least `10⁻⁶⁰` on `[-1,1]`

`hNew t = ∑_{i<21} hNewRat[i] tⁱ`, where `hNewRat` is the list of the 21 rationals of
`near-sharp-d10-reduced-D60.json` verbatim (`ReducedData.lean`).  Equivalent forms:
`hNew_eq_polyEval : hNew t = polyEval hNewNum t / hNewDen` (integer numerators over `10^60`)
and `hNew_eq_sum` (the defining sum, stated as a theorem for `rw`).

Main result (constant-shift argument, REDUCED.md §1):
`hNew_le_minorant_sub : -1 ≤ t → t ≤ 1 → hNew t ≤ minorant t - 1/10^60`.
With `δ = minorantNum - 10^120·hNewNum` (integers over `10^180`), the kernel checks
`δ₀ - ∑_{i≥1} |δᵢ| ≥ 10^120`; on `[-1,1]`, `|∑_{i≥1} δᵢ tⁱ| ≤ ∑_{i≥1} |δᵢ|`.

Corollaries: `hNew_le_phi`, `hNew_add_le_phi`, `hNew_le_inv_sqrt`, `hNew_le_inv_dist`,
`exterior_gap_new` (same hypotheses as L2's `exterior_gap`).
-/

namespace ThomsonN9.Claude.L2b

open ThomsonN9.Bernstein

/-- The reduced minorant `h_new(t) = ∑ᵢ hNewRat[i] tⁱ` (21 coefficients of the reduced JSON). -/
noncomputable def hNew (t : ℝ) : ℝ :=
  ∑ i ∈ Finset.range 21, ((hNewRat.getD i 0 : ℚ) : ℝ) * t ^ i

theorem hNew_eq_sum (t : ℝ) :
    hNew t = ∑ i ∈ Finset.range 21, ((hNewRat.getD i 0 : ℚ) : ℝ) * t ^ i := rfl

/-- The JSON rationals are exactly `hNewNum[i] / 10^60` (kernel check). -/
theorem hNewRat_eq : hNewRat = hNewNum.map (fun z : ℤ => (z : ℚ) / hNewDen) := by
  decide +kernel

theorem hNewNum_length : hNewNum.length = 21 := by decide +kernel

theorem hNewRat_length : hNewRat.length = 21 := by decide +kernel

/-- Integer-numerator (Horner) form of `hNew`. -/
theorem hNew_eq_polyEval (t : ℝ) : hNew t = polyEval hNewNum t / hNewDen := by
  rw [hNew, polyEval_eq_sum, hNewNum_length, Finset.sum_div]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [hNewRat_eq, getD_map_div, Rat.cast_div, Rat.cast_intCast, Rat.cast_intCast]
  ring

/-! ### Constant-shift argument -/

/-- `∑ |xᵢ|` of an integer list. -/
def absSum : List ℤ → ℤ
  | [] => 0
  | x :: l => (x.natAbs : ℤ) + absSum l

theorem abs_cast_eq_natAbs (a : ℤ) : |(a : ℝ)| = (((a.natAbs : ℤ)) : ℝ) := by
  rw [Int.natCast_natAbs, Int.cast_abs]

theorem abs_polyEval_le {t : ℝ} (ht : |t| ≤ 1) :
    ∀ l : List ℤ, |polyEval l t| ≤ ((absSum l : ℤ) : ℝ)
  | [] => by simp [absSum]
  | a :: l => by
    have ih := abs_polyEval_le ht l
    have hP : |t * polyEval l t| ≤ ((absSum l : ℤ) : ℝ) := by
      rw [abs_mul]
      calc |t| * |polyEval l t| ≤ 1 * |polyEval l t| :=
            mul_le_mul_of_nonneg_right ht (abs_nonneg _)
        _ ≤ ((absSum l : ℤ) : ℝ) := by rw [one_mul]; exact ih
    rw [polyEval_cons, absSum, Int.cast_add, ← abs_cast_eq_natAbs]
    exact le_trans (abs_add_le _ _) (add_le_add le_rfl hP)

/-- On `[-1,1]`: `polyEval l t ≥ l₀ - ∑_{i≥1} |lᵢ|`. -/
theorem polyEval_ge_head {t : ℝ} (ht : |t| ≤ 1) :
    ∀ l : List ℤ, ((l.headD 0 : ℤ) : ℝ) - ((absSum l.tail : ℤ) : ℝ) ≤ polyEval l t
  | [] => by simp [absSum]
  | a :: l => by
    have h1 := abs_polyEval_le ht l
    have h2 : |t * polyEval l t| ≤ ((absSum l : ℤ) : ℝ) := by
      rw [abs_mul]
      calc |t| * |polyEval l t| ≤ 1 * |polyEval l t| :=
            mul_le_mul_of_nonneg_right ht (abs_nonneg _)
        _ ≤ ((absSum l : ℤ) : ℝ) := by rw [one_mul]; exact h1
    have h3 := neg_abs_le (t * polyEval l t)
    simp only [List.headD_cons, List.tail_cons, polyEval_cons]
    linarith

/-- `10^180 · (h - h_new)` as an integer coefficient list. -/
def deltaNum : List ℤ := addL minorantNum (scaleL (-hNewScale) hNewNum)

/-- The constant-shift certificate: `δ₀ - ∑_{i≥1} |δᵢ| ≥ 10^120` (exact, kernel). -/
theorem deltaNum_cert :
    decide (hNewScale ≤ deltaNum.headD 0 - absSum deltaNum.tail) = true := by
  decide +kernel

theorem hNewDen_eq : (hNewDen : ℝ) = 10 ^ 60 := by norm_num [hNewDen]
theorem hNewScale_eq : (hNewScale : ℝ) = 10 ^ 120 := by norm_num [hNewScale]
theorem minorantDen_eq : (minorantDen : ℝ) = 10 ^ 180 := by norm_num [minorantDen]

/-- **Constant shift.** `h_new ≤ h - 10⁻⁶⁰` on `[-1,1]`. -/
theorem hNew_le_minorant_sub {t : ℝ} (h1 : -1 ≤ t) (h2 : t ≤ 1) :
    hNew t ≤ minorant t - 1 / 10 ^ 60 := by
  have ht : |t| ≤ 1 := abs_le.2 ⟨h1, h2⟩
  have hc := deltaNum_cert
  rw [decide_eq_true_eq] at hc
  have hc' : ((hNewScale : ℤ) : ℝ) ≤
      ((deltaNum.headD 0 : ℤ) : ℝ) - ((absSum deltaNum.tail : ℤ) : ℝ) := by
    exact_mod_cast hc
  have hlow := polyEval_ge_head ht deltaNum
  have heq : polyEval deltaNum t =
      polyEval minorantNum t - (hNewScale : ℝ) * polyEval hNewNum t := by
    rw [deltaNum, polyEval_addL, polyEval_scaleL]; push_cast; ring
  have key : (10 : ℝ) ^ 120 ≤ polyEval minorantNum t - 10 ^ 120 * polyEval hNewNum t := by
    rw [← hNewScale_eq, ← heq]; linarith
  rw [hNew_eq_polyEval, minorant, hNewDen_eq, minorantDen_eq]
  linarith

/-! ### Corollaries -/

theorem hNew_lt_minorant {t : ℝ} (h1 : -1 ≤ t) (h2 : t ≤ 1) : hNew t < minorant t := by
  have := hNew_le_minorant_sub h1 h2
  have h : (0 : ℝ) < 1 / 10 ^ 60 := by norm_num
  linarith

/-- `h_new + 10⁻⁶⁰ ≤ φ` on `[-1,1)`. -/
theorem hNew_add_le_phi {t : ℝ} (h1 : -1 ≤ t) (h2 : t < 1) : hNew t + 1 / 10 ^ 60 ≤ phi t := by
  have a := hNew_le_minorant_sub h1 h2.le
  have b := minorant_le_phi h1 h2
  linarith

/-- `h_new ≤ φ` on `[-1,1)`. -/
theorem hNew_le_phi {t : ℝ} (h1 : -1 ≤ t) (h2 : t < 1) : hNew t ≤ phi t :=
  le_of_lt (lt_of_lt_of_le (hNew_lt_minorant h1 h2.le) (minorant_le_phi h1 h2))

/-- `h_new ≤ (√(2-2t))⁻¹` on `[-1,1)` (the form of Codex's `SDP.coulombPotential`). -/
theorem hNew_le_inv_sqrt {t : ℝ} (h1 : -1 ≤ t) (h2 : t < 1) :
    hNew t ≤ (Real.sqrt (2 - 2 * t))⁻¹ := by
  rw [← phi_eq h2]; exact hNew_le_phi h1 h2

/-- `h_new(⟪x,y⟫) ≤ ‖x - y‖⁻¹` for distinct unit vectors. -/
theorem hNew_le_inv_dist {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {x y : E} (hx : ‖x‖ = 1) (hy : ‖y‖ = 1) (hxy : x ≠ y) :
    hNew (inner ℝ x y) ≤ ‖x - y‖⁻¹ := by
  obtain ⟨h1, h2, h3⟩ := unit_inner_facts hx hy hxy
  rw [h3]; exact hNew_le_inv_sqrt h1 h2

/-- **Exterior gap for `h_new`** (same hypotheses as L2's `exterior_gap`):
`φ(t) - h_new(t) ≥ 10⁻⁴⁶` outside the seven windows of half width `10⁻⁴`. -/
theorem exterior_gap_new {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) {t : ℝ}
    (ht1 : -1 + 1 / 10000 ≤ t) (ht2 : t ≤ 5593 / 10000)
    (hw : ∀ j : Fin 6, 1 / 10000 ≤ |t - contact r j|) :
    1 / 10 ^ 46 ≤ phi t - hNew t := by
  have a := exterior_gap hr1 hr2 ht1 ht2 hw
  have b := hNew_le_minorant_sub (t := t) (by linarith) (by linarith)
  have c : (0 : ℝ) ≤ 1 / 10 ^ 60 := by norm_num
  linarith

/-- The same in the form `h_new(t) + 10⁻⁴⁶ ≤ φ(t)`. -/
theorem exterior_gap_new' {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) {t : ℝ}
    (ht1 : -1 + 1 / 10000 ≤ t) (ht2 : t ≤ 5593 / 10000)
    (hw : ∀ j : Fin 6, 1 / 10000 ≤ |t - contact r j|) :
    hNew t + 1 / 10 ^ 46 ≤ phi t := by
  have := exterior_gap_new hr1 hr2 ht1 ht2 hw
  linarith

end ThomsonN9.Claude.L2b

#print axioms ThomsonN9.Claude.L2b.hNewRat_eq
#print axioms ThomsonN9.Claude.L2b.hNew_eq_polyEval
#print axioms ThomsonN9.Claude.L2b.deltaNum_cert
#print axioms ThomsonN9.Claude.L2b.hNew_le_minorant_sub
#print axioms ThomsonN9.Claude.L2b.hNew_le_phi
#print axioms ThomsonN9.Claude.L2b.hNew_add_le_phi
#print axioms ThomsonN9.Claude.L2b.hNew_le_inv_sqrt
#print axioms ThomsonN9.Claude.L2b.hNew_le_inv_dist
#print axioms ThomsonN9.Claude.L2b.exterior_gap_new
#print axioms ThomsonN9.Claude.L2b.exterior_gap_new'
