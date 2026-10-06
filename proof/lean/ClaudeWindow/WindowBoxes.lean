import ClaudeWindow.WindowData
import Mathlib.Data.Rat.Cast.Lemmas
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.IntervalCases

/-!
# The six true windows and their rational filter boxes

`palette r c` is the `c`-th P9 inner product at radius `r`.  For every real `r` in the
certified radius interval `[rLo, rHi]` (the same rationals as `ThomsonN9.radiusLower`,
`ThomsonN9.radiusUpper`), each true closed window `[palette r c - 1/10000, palette r c + 1/10000]`
is contained in the generated rational box `box c`, and the six boxes are pairwise disjoint.
-/

namespace ThomsonN9.Claude.Window

def rLo : ℚ := 7105483340929538113277041792727912437680 / 10000000000000000000000000000000000000000
def rHi : ℚ := 7105483340929538113277041792727912437681 / 10000000000000000000000000000000000000000

/-- The six P9 inner products (color order of the checker). -/
noncomputable def palette (r : ℝ) : ℕ → ℝ
  | 0 => -1 / 2
  | 1 => -r
  | 2 => r / 2
  | 3 => 2 * r ^ 2 - 1
  | 4 => 1 - 3 * r ^ 2 / 2
  | 5 => r ^ 2 / 2 - 1
  | _ => 0

/-- Exact rational lower/upper bounds of `palette r c` over `r ∈ [rLo, rHi]`. -/
def plo : ℕ → ℚ
  | 0 => -1 / 2
  | 1 => -rHi
  | 2 => rLo / 2
  | 3 => 2 * rLo ^ 2 - 1
  | 4 => 1 - 3 * rHi ^ 2 / 2
  | 5 => rLo ^ 2 / 2 - 1
  | _ => 0

def phi : ℕ → ℚ
  | 0 => -1 / 2
  | 1 => -rLo
  | 2 => rHi / 2
  | 3 => 2 * rHi ^ 2 - 1
  | 4 => 1 - 3 * rLo ^ 2 / 2
  | 5 => rHi ^ 2 / 2 - 1
  | _ => 0

theorem boxes_cover : ∀ c, c < 6 →
    (box c).lo ≤ plo c - 1 / 10000 ∧ phi c + 1 / 10000 ≤ (box c).hi := by
  decide +kernel

theorem boxes_disjoint : ∀ c, c < 6 → ∀ d, d < 6 → c ≠ d →
    (box c).hi < (box d).lo ∨ (box d).hi < (box c).lo := by
  decide +kernel

theorem palette_bounds {r : ℝ} (hlo : (rLo : ℝ) ≤ r) (hhi : r ≤ (rHi : ℝ)) {c : ℕ} (hc : c < 6) :
    (plo c : ℝ) ≤ palette r c ∧ palette r c ≤ (phi c : ℝ) := by
  have hL : (0 : ℝ) < (rLo : ℝ) := by norm_num [rLo]
  have hr : 0 < r := lt_of_lt_of_le hL hlo
  have h2lo : (rLo : ℝ) ^ 2 ≤ r ^ 2 := by nlinarith
  have h2hi : r ^ 2 ≤ (rHi : ℝ) ^ 2 := by nlinarith
  interval_cases c <;>
    simp only [palette, plo, phi, Rat.cast_sub, Rat.cast_add, Rat.cast_mul, Rat.cast_pow,
      Rat.cast_div, Rat.cast_neg, Rat.cast_one, Rat.cast_ofNat] <;>
    constructor <;> nlinarith

theorem window_mem_box {r : ℝ} (hlo : (rLo : ℝ) ≤ r) (hhi : r ≤ (rHi : ℝ)) {c : ℕ} (hc : c < 6)
    {t : ℝ} (ht : |t - palette r c| ≤ 1 / 10000) : (box c).Mem t := by
  obtain ⟨hp1, hp2⟩ := palette_bounds hlo hhi hc
  obtain ⟨hb1, hb2⟩ := boxes_cover c hc
  have hb1' : ((box c).lo : ℝ) ≤ ((plo c - 1 / 10000 : ℚ) : ℝ) := by exact_mod_cast hb1
  have hb2' : ((phi c + 1 / 10000 : ℚ) : ℝ) ≤ ((box c).hi : ℝ) := by exact_mod_cast hb2
  push_cast at hb1' hb2'
  rw [abs_le] at ht
  exact ⟨by linarith [ht.1], by linarith [ht.2]⟩

theorem box_unique {c d : ℕ} (hc : c < 6) (hd : d < 6) {t : ℝ} (h1 : (box c).Mem t)
    (h2 : (box d).Mem t) : c = d := by
  by_contra hne
  rcases boxes_disjoint c hc d hd hne with h | h
  · have : ((box c).hi : ℝ) < (box d).lo := by exact_mod_cast h
    linarith [h1.2, h2.1]
  · have : ((box d).hi : ℝ) < (box c).lo := by exact_mod_cast h
    linarith [h1.1, h2.2]

theorem window_unique {r : ℝ} (hlo : (rLo : ℝ) ≤ r) (hhi : r ≤ (rHi : ℝ)) {c d : ℕ} (hc : c < 6)
    (hd : d < 6) {t : ℝ} (h1 : |t - palette r c| ≤ 1 / 10000) (h2 : |t - palette r d| ≤ 1 / 10000) :
    c = d :=
  box_unique hc hd (window_mem_box hlo hhi hc h1) (window_mem_box hlo hhi hd h2)

end ThomsonN9.Claude.Window
