import ClaudeWindow.WindowBoxes
import ClaudeWindow.FormulaSound

/-!
# The 49-case antipodal exclusion

If `t = ⟪xᵢ,xⱼ⟫ = -1 + δ` with `0 ≤ δ ≤ 1/10000`, then for any third unit vector `x_k`, with
`u = ⟪xᵢ,x_k⟫`, `v = ⟪xⱼ,x_k⟫`, the Gram determinant is
`d3R t u v = 2δ(1+uv) - δ² - (u+v)²`.
For each of the `7 × 7` window pairs of `(u, v)` (six palette boxes and the antipodal
window `[-1, -1 + 1/10000]`) the interval evaluation of the right side is strictly negative
(kernel-checked), contradicting `gram3_nonneg`.
-/

namespace ThomsonN9.Claude.Window

open Iv

def epsQ : ℚ := 1 / 10000

/-- The seven filter boxes: the six palette boxes and the antipodal window. -/
def box7 (c : ℕ) : Iv := if c < 6 then box c else ⟨-1, -1 + epsQ⟩

def deltaIv : Iv := ⟨0, epsQ⟩

/-- Interval form of `2δ(1+uv) - δ² - (u+v)²`. -/
def antiIv (U V : Iv) : Iv :=
  sub (sub (mul (const 2) (mul deltaIv (add (const 1) (mul U V)))) (sq deltaIv)) (sq (add U V))

def antiCheck : Bool :=
  (List.range 7).all fun a => (List.range 7).all fun b =>
    decide ((antiIv (box7 a) (box7 b)).hi < 0)

theorem antiCheck_ok : antiCheck = true := by decide +kernel

theorem anti_identity (δ u v : ℝ) :
    d3R (-1 + δ) u v = 2 * δ * (1 + u * v) - δ ^ 2 - (u + v) ^ 2 := by
  unfold d3R; ring

theorem anti_neg {a b : ℕ} (ha : a < 7) (hb : b < 7) {u v δ : ℝ} (hu : (box7 a).Mem u)
    (hv : (box7 b).Mem v) (hδ0 : 0 ≤ δ) (hδ : δ ≤ 1 / 10000) : d3R (-1 + δ) u v < 0 := by
  have hd : deltaIv.Mem δ := by
    constructor
    · simp only [deltaIv, Rat.cast_zero]; exact hδ0
    · simp only [deltaIv, epsQ]; push_cast; linarith
  have hm : (antiIv (box7 a) (box7 b)).Mem (2 * δ * (1 + u * v) - δ ^ 2 - (u + v) ^ 2) := by
    have h := mem_sub (mem_sub (mem_mul (mem_const 2)
      (mem_mul hd (mem_add (mem_const 1) (mem_mul hu hv)))) (mem_sq hd)) (mem_sq (mem_add hu hv))
    unfold antiIv
    convert h using 1
    push_cast; ring
  have hA := antiCheck_ok
  unfold antiCheck at hA
  have hc := List.all_eq_true.mp (List.all_eq_true.mp hA a (List.mem_range.mpr ha))
    b (List.mem_range.mpr hb)
  have hc' : decide ((antiIv (box7 a) (box7 b)).hi < 0) = true := hc
  have hneg : ((antiIv (box7 a) (box7 b)).hi : ℝ) < 0 := by exact_mod_cast of_decide_eq_true hc'
  rw [anti_identity]
  linarith [hm.2]

end ThomsonN9.Claude.Window
