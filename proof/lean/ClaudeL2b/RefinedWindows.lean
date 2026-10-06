import ClaudeL2b.ReducedMinorant
import ClaudeL2b.RefinedData

/-!
# Refined windows: gap `10⁻³³` outside the six true windows of half width `10⁻⁸`

Codex's `near_sharp/refined-windows.json` (REFINED_WINDOWS.md), for the ORIGINAL minorant
`h = ThomsonN9.Bernstein.minorant`: seven single Bernstein leaves of `h + 10⁻³³` on the
`y`-intervals of the seven complementary `t`-intervals of `[-3/4, 5593/10000]`.

As in L2 (`MinorantCert.lean` / `exterior_gap`):
* the `t`-intervals `refLo/refHi` are defined here from `rLower`, `rUpper`, `ε = 10⁻⁸`,
  `-3/4` and `5593/10000` (not imported data), exactly as `check_refined_windows.py`;
* each kernel check `refCheck j` contains both the Bernstein leaf and L2's `extOk`
  side conditions (`0 ≤ A`, `0 ≤ B`, `hi < 1`, `(A/M)² ≤ (1-hi)/2`, `(1-lo)/2 ≤ (B/M)²`),
  which place `y = √((1-t)/2)` in `[A/M, B/M]` (`extOk_sound`).

Results: `refined_gap` (for `minorant`), `refined_gap_new` / `refined_gap_new'` (for `hNew`,
transferred by `hNew_le_minorant_sub`).
-/

namespace ThomsonN9.Claude.L2b

open ThomsonN9.Bernstein

/-- Refined window half width `ε = 10⁻⁸`. -/
def refEps : ℚ := 1 / 100000000

/-- The seven closed refined exterior intervals `[refLo j, refHi j]`:
`[-3/4, u₁-ε]`, `[lⱼ+ε, u_{j+1}-ε]` (`j=1..5`), `[l₆+ε, 5593/10000]`, where `[lⱼ,uⱼ]`
encloses `sⱼ(r)` for `r ∈ [rLower, rUpper]`. -/
def refLo : List ℚ :=
  [-3 / 4,
   rLower * rLower / 2 - 1 + refEps,
   -rUpper + refEps,
   -1 / 2 + refEps,
   2 * rLower * rLower - 1 + refEps,
   1 - 3 * rUpper * rUpper / 2 + refEps,
   rLower / 2 + refEps]

def refHi : List ℚ :=
  [rUpper * rUpper / 2 - 1 - refEps,
   -rLower - refEps,
   -1 / 2 - refEps,
   2 * rUpper * rUpper - 1 - refEps,
   1 - 3 * rLower * rLower / 2 - refEps,
   rUpper / 2 - refEps,
   5593 / 10000]

/-- Refined certificate for interval `j`: Bernstein leaf of `h + 10⁻³³` and `√`-placement. -/
def refCheck (j : ℕ) : Bool :=
  checkInterval (potential (addL [refGapNum] minorantNum) minorantDen)
      (refA.getD j 0) (refB.getD j 0) refM 1 1 1 &&
    extOk (refA.getD j 0) (refB.getD j 0) refM (refLo.getD j 0) (refHi.getD j 0)

theorem ref_cert0 : refCheck 0 = true := by decide +kernel
theorem ref_cert1 : refCheck 1 = true := by decide +kernel
theorem ref_cert2 : refCheck 2 = true := by decide +kernel
theorem ref_cert3 : refCheck 3 = true := by decide +kernel
theorem ref_cert4 : refCheck 4 = true := by decide +kernel
theorem ref_cert5 : refCheck 5 = true := by decide +kernel
theorem ref_cert6 : refCheck 6 = true := by decide +kernel

theorem refGapNum_div : (refGapNum : ℝ) / minorantDen = 1 / 10 ^ 33 := by
  norm_num [refGapNum, minorantDen]

theorem refM_pos : (0 : ℤ) < refM := by norm_num [refM]

/-- One refined interval: `h + 10⁻³³ ≤ φ` on `[refLo j, refHi j]`. -/
theorem gap_of_refCheck {j : ℕ} (hj : refCheck j = true) {t : ℝ}
    (h1 : ((refLo.getD j 0 : ℚ) : ℝ) ≤ t) (h2 : t ≤ ((refHi.getD j 0 : ℚ) : ℝ)) :
    minorant t + 1 / 10 ^ 33 ≤ phi t := by
  simp only [refCheck, Bool.and_eq_true] at hj
  obtain ⟨ht1, hA, hB⟩ := extOk_sound hj.2 refM_pos h1 h2
  obtain ⟨-, hyt, -⟩ := sqrt_subst ht1
  have key := checkInterval_sound hj.1 _ hA hB
  rw [polyEval_potential, hyt, polyEval_addL_single] at key
  have := le_phi_of_potential ht1 (polyEval minorantNum t) (refGapNum : ℝ) key
  rw [add_div, refGapNum_div] at this
  rw [minorant]; linarith

/-- **Refined gap (original `h`).** For `r` in the radius bracket and
`t ∈ [-3/4, 5593/10000]` with `|t - sⱼ(r)| ≥ 10⁻⁸` for all six contacts:
`h(t) + 10⁻³³ ≤ φ(t)`. -/
theorem refined_gap {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) {t : ℝ}
    (ht1 : -3 / 4 ≤ t) (ht2 : t ≤ 5593 / 10000)
    (hw : ∀ j : Fin 6, 1 / 100000000 ≤ |t - contact r j|) :
    minorant t + 1 / 10 ^ 33 ≤ phi t := by
  obtain ⟨hsq1, hsq2⟩ := contact_bounds hr1 hr2
  have side : ∀ j : Fin 6,
      t ≤ contact r j - 1 / 100000000 ∨ contact r j + 1 / 100000000 ≤ t := by
    intro j
    rcases le_abs'.1 (hw j) with h | h
    · left; linarith
    · right; linarith
  have c0 : t ≤ r ^ 2 / 2 - 1 - 1 / 100000000 ∨ r ^ 2 / 2 - 1 + 1 / 100000000 ≤ t := side 0
  have c1 : t ≤ -r - 1 / 100000000 ∨ -r + 1 / 100000000 ≤ t := side 1
  have c2 : t ≤ -1 / 2 - 1 / 100000000 ∨ -1 / 2 + 1 / 100000000 ≤ t := side 2
  have c3 : t ≤ 2 * r ^ 2 - 1 - 1 / 100000000 ∨ 2 * r ^ 2 - 1 + 1 / 100000000 ≤ t := side 3
  have c4 : t ≤ 1 - 3 * r ^ 2 / 2 - 1 / 100000000 ∨
      1 - 3 * r ^ 2 / 2 + 1 / 100000000 ≤ t := side 4
  have c5 : t ≤ r / 2 - 1 / 100000000 ∨ r / 2 + 1 / 100000000 ≤ t := side 5
  rcases c0 with h0 | h0
  · refine gap_of_refCheck ref_cert0 ?_ ?_
    · norm_num [refLo, refEps]; linarith
    · norm_num [refHi, refEps]; linarith
  rcases c1 with h1 | h1
  · refine gap_of_refCheck ref_cert1 ?_ ?_
    · norm_num [refLo, refEps]; linarith
    · norm_num [refHi, refEps]; linarith
  rcases c2 with h2 | h2
  · refine gap_of_refCheck ref_cert2 ?_ ?_
    · norm_num [refLo, refEps]; linarith
    · norm_num [refHi, refEps]; linarith
  rcases c3 with h3 | h3
  · refine gap_of_refCheck ref_cert3 ?_ ?_
    · norm_num [refLo, refEps]; linarith
    · norm_num [refHi, refEps]; linarith
  rcases c4 with h4 | h4
  · refine gap_of_refCheck ref_cert4 ?_ ?_
    · norm_num [refLo, refEps]; linarith
    · norm_num [refHi, refEps]; linarith
  rcases c5 with h5 | h5
  · refine gap_of_refCheck ref_cert5 ?_ ?_
    · norm_num [refLo, refEps]; linarith
    · norm_num [refHi, refEps]; linarith
  · refine gap_of_refCheck ref_cert6 ?_ ?_
    · norm_num [refLo, refEps]; linarith
    · norm_num [refHi, refEps]; linarith

/-- The refined gap in the form `φ(t) - h(t) ≥ 10⁻³³`. -/
theorem refined_gap' {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) {t : ℝ}
    (ht1 : -3 / 4 ≤ t) (ht2 : t ≤ 5593 / 10000)
    (hw : ∀ j : Fin 6, 1 / 100000000 ≤ |t - contact r j|) :
    1 / 10 ^ 33 ≤ phi t - minorant t := by
  have := refined_gap hr1 hr2 ht1 ht2 hw
  linarith

/-- **Refined gap for `h_new`.** Same hypotheses: `φ(t) - h_new(t) ≥ 10⁻³³`. -/
theorem refined_gap_new {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) {t : ℝ}
    (ht1 : -3 / 4 ≤ t) (ht2 : t ≤ 5593 / 10000)
    (hw : ∀ j : Fin 6, 1 / 100000000 ≤ |t - contact r j|) :
    1 / 10 ^ 33 ≤ phi t - hNew t := by
  have a := refined_gap hr1 hr2 ht1 ht2 hw
  have b := hNew_le_minorant_sub (t := t) (by linarith) (by linarith)
  have c : (0 : ℝ) ≤ 1 / 10 ^ 60 := by norm_num
  linarith

theorem refined_gap_new' {r : ℝ} (hr1 : (rLower : ℝ) ≤ r) (hr2 : r ≤ rUpper) {t : ℝ}
    (ht1 : -3 / 4 ≤ t) (ht2 : t ≤ 5593 / 10000)
    (hw : ∀ j : Fin 6, 1 / 100000000 ≤ |t - contact r j|) :
    hNew t + 1 / 10 ^ 33 ≤ phi t := by
  have := refined_gap_new hr1 hr2 ht1 ht2 hw
  linarith

end ThomsonN9.Claude.L2b

#print axioms ThomsonN9.Claude.L2b.ref_cert0
#print axioms ThomsonN9.Claude.L2b.refined_gap
#print axioms ThomsonN9.Claude.L2b.refined_gap'
#print axioms ThomsonN9.Claude.L2b.refined_gap_new
#print axioms ThomsonN9.Claude.L2b.refined_gap_new'
