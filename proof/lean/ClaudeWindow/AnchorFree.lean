import ClaudeWindow.WindowBoxes
import ClaudeWindow.FormulaSound
import ClaudeWindow.Geometry

/-!
# A nondegenerate anchor always exists (no covariance hypothesis needed)

Any four unit vectors in `ℝ³` whose six pair products lie in the six palette windows contain
a triple with Gram determinant `> 1/100`.

Proof: otherwise each of the four triangles has real Gram determinant in `[0, 1/100]`
(`gram3_nonneg`), so its color type passes the interval filter `smallTri` (only the types
`(0,0,0)`, `(1,1,3)`, `(2,2,5)` do).  The kernel-checked `anchorFreeCheck` shows that for every
such colored `K₄` the 4×4 Gram determinant interval omits `0`, contradicting `normR_eq_zero`.
-/

namespace ThomsonN9.Claude.Window

open Iv

/-- The interval of the triangle Gram determinant meets `[0, θ]`. -/
def smallTri (θ : ℚ) (x y z : ℕ) : Bool :=
  decide ((d3Iv (box x) (box y) (box z)).lo ≤ θ) && decide (0 ≤ (d3Iv (box x) (box y) (box z)).hi)

def anchorFreeCheck (θ : ℚ) : Bool :=
  (List.range 6).all fun c01 => (List.range 6).all fun c02 => (List.range 6).all fun c12 =>
    !(smallTri θ c01 c02 c12) ||
      (List.range 6).all fun c03 => (List.range 6).all fun c13 => (List.range 6).all fun c23 =>
        !(smallTri θ c01 c03 c13 && smallTri θ c02 c03 c23 && smallTri θ c12 c13 c23) ||
          (normIv (d3Iv (box c01) (box c02) (box c12)) (adjIv (box c01) (box c02) (box c12))
            (box c03) (box c13) (box c23)).excl

theorem anchorFreeCheck_ok : anchorFreeCheck (1 / 100) = true := by decide +kernel

theorem smallTri_of {x y z : ℕ} {a b c : ℝ} (ha : (box x).Mem a) (hb : (box y).Mem b)
    (hc : (box z).Mem c) (h0 : 0 ≤ d3R a b c) (h1 : d3R a b c ≤ 1 / 100) :
    smallTri (1 / 100) x y z = true := by
  have hm := mem_d3 ha hb hc
  unfold smallTri
  rw [Bool.and_eq_true, decide_eq_true_eq, decide_eq_true_eq]
  constructor
  · have : ((d3Iv (box x) (box y) (box z)).lo : ℝ) ≤ ((1 / 100 : ℚ) : ℝ) := by
      push_cast; linarith [hm.1]
    exact_mod_cast this
  · have : ((0 : ℚ) : ℝ) ≤ ((d3Iv (box x) (box y) (box z)).hi : ℝ) := by
      push_cast; linarith [hm.2]
    exact_mod_cast this

/-- Four unit vectors with pair products in the boxes `box (col i j)` (colors `< 6`) have a
triangle with Gram determinant `> 1/100`. -/
theorem exists_big_triangle (y : Fin 4 → E3) (hy : ∀ i, ‖y i‖ = 1) (col : Fin 4 → Fin 4 → ℕ)
    (hlt : ∀ i j, col i j < 6) (hmem : ∀ i j, i ≠ j → (box (col i j)).Mem (inner ℝ (y i) (y j))) :
    (1 / 100 : ℝ) < d3R (inner ℝ (y 0) (y 1)) (inner ℝ (y 0) (y 2)) (inner ℝ (y 1) (y 2)) ∨
    (1 / 100 : ℝ) < d3R (inner ℝ (y 0) (y 1)) (inner ℝ (y 0) (y 3)) (inner ℝ (y 1) (y 3)) ∨
    (1 / 100 : ℝ) < d3R (inner ℝ (y 0) (y 2)) (inner ℝ (y 0) (y 3)) (inner ℝ (y 2) (y 3)) ∨
    (1 / 100 : ℝ) < d3R (inner ℝ (y 1) (y 2)) (inner ℝ (y 1) (y 3)) (inner ℝ (y 2) (y 3)) := by
  by_contra hno
  simp only [not_or, not_lt] at hno
  obtain ⟨t012, t013, t023, t123⟩ := hno
  have m01 := hmem 0 1 (by decide)
  have m02 := hmem 0 2 (by decide)
  have m12 := hmem 1 2 (by decide)
  have m03 := hmem 0 3 (by decide)
  have m13 := hmem 1 3 (by decide)
  have m23 := hmem 2 3 (by decide)
  have s012 := smallTri_of m01 m02 m12 (gram3_nonneg _ _ _ (hy 0) (hy 1) (hy 2)) t012
  have s013 := smallTri_of m01 m03 m13 (gram3_nonneg _ _ _ (hy 0) (hy 1) (hy 3)) t013
  have s023 := smallTri_of m02 m03 m23 (gram3_nonneg _ _ _ (hy 0) (hy 2) (hy 3)) t023
  have s123 := smallTri_of m12 m13 m23 (gram3_nonneg _ _ _ (hy 1) (hy 2) (hy 3)) t123
  -- the 4×4 Gram determinant vanishes, so its interval contains 0
  have v0 : (box (col 0 3)).Mem (inner ℝ (y 3) (y 0)) := by rw [real_inner_comm]; exact m03
  have v1 : (box (col 1 3)).Mem (inner ℝ (y 3) (y 1)) := by rw [real_inner_comm]; exact m13
  have v2 : (box (col 2 3)).Mem (inner ℝ (y 3) (y 2)) := by rw [real_inner_comm]; exact m23
  have hn := mem_norm m01 m02 m12 v0 v1 v2
  rw [normR_eq_zero (y 0) (y 1) (y 2) (y 3) (hy 0) (hy 1) (hy 2) (hy 3)] at hn
  have hne := Iv.not_excl_of_mem_zero hn
  -- but the checker excludes it
  have hA := anchorFreeCheck_ok
  unfold anchorFreeCheck at hA
  have c1 := List.all_eq_true.mp hA (col 0 1) (List.mem_range.mpr (hlt 0 1))
  have c2 := List.all_eq_true.mp c1 (col 0 2) (List.mem_range.mpr (hlt 0 2))
  have c3 := List.all_eq_true.mp c2 (col 1 2) (List.mem_range.mpr (hlt 1 2))
  simp only [s012, Bool.not_true, Bool.false_or] at c3
  have c4 := List.all_eq_true.mp c3 (col 0 3) (List.mem_range.mpr (hlt 0 3))
  have c5 := List.all_eq_true.mp c4 (col 1 3) (List.mem_range.mpr (hlt 1 3))
  have c6 := List.all_eq_true.mp c5 (col 2 3) (List.mem_range.mpr (hlt 2 3))
  simp only [s013, s023, s123, Bool.and_self, Bool.not_true, Bool.false_or, hne,
    Bool.false_eq_true] at c6

end ThomsonN9.Claude.Window
