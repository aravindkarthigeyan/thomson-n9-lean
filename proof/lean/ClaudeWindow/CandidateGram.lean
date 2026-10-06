import ThomsonN9.Candidate
import ClaudeWindow.WindowBoxes
import ClaudeWindow.Geometry

/-!
# The Gram matrix of `ThomsonN9.candidateAt r` is the reference coloring

For `0 < r < 1` and `i ≠ j`, `⟪candidateAt r i, candidateAt r j⟫ = palette r (refColor i j)`.
Also: the radius interval `[rLo, rHi]` is Codex's `[radiusLower, radiusUpper]`.
-/

namespace ThomsonN9.Claude.Window

open ThomsonN9

theorem rLo_eq : rLo = radiusLower := rfl
theorem rHi_eq : rHi = radiusUpper := rfl

theorem vec_inner (a b c d e f : ℝ) :
    inner ℝ (vec a b c) (vec d e f) = a * d + b * e + c * f := by
  simp [inner_coord, vec]

theorem refColor_lt6 : ∀ i, i < 9 → ∀ j, j < 9 → i ≠ j → refColor i j < 6 := by decide

theorem candidateAt_inner {r : ℝ} (hr : 0 < r) (hr1 : r < 1) (i j : Fin 9) (hij : i ≠ j) :
    inner ℝ (candidateAt r i) (candidateAt r j) = palette r (refColor i j) := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hz : Real.sqrt (1 - r ^ 2) ^ 2 = 1 - r ^ 2 := Real.sq_sqrt (by nlinarith)
  fin_cases i <;> fin_cases j <;> simp only [ne_eq, not_true_eq_false] at hij <;>
    simp [candidateAt, vec_inner, refColor, palette] <;> ring_nf <;> simp only [h3, hz] <;> ring

theorem candidateAt_inner_self {r : ℝ} (hr : 0 < r) (hr1 : r < 1) (i : Fin 9) :
    inner ℝ (candidateAt r i) (candidateAt r i) = 1 := by
  rw [real_inner_self_eq_norm_sq, candidateAt_norm hr hr1 i, one_pow]

end ThomsonN9.Claude.Window
