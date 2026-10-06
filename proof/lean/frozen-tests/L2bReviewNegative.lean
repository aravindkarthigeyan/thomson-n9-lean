import ClaudeL2b.RefinedWindows
import ClaudeL2b.LPCovers

/-! Reviewer's additional negative controls for L2b (each `= false` evaluated by the kernel).
Predictions from review/rv_check.py (exact rational arithmetic). -/

open ThomsonN9.Bernstein ThomsonN9.Claude.L2b

/-- `hNewRat` with ONE coefficient (index 7) moved by `10⁻⁶⁰`: the JSON ↔ integer link fails. -/
theorem rv_neg_rat_coeff :
    decide ((hNewRat.set 7 (hNewRat.getD 7 0 + 1 / 10 ^ 60)) =
      hNewNum.map (fun z : ℤ => (z : ℚ) / hNewDen)) = false := by decide +kernel

/-- ONE middle coefficient of `h_new` (index 5) raised by `2·10⁻⁶⁰`: the shift certificate fails
(predicted margin −4.4·10⁻⁶¹). -/
theorem rv_neg_shift_coeff5 :
    decide (hNewScale ≤
      (addL minorantNum (scaleL (-hNewScale) (hNewNum.set 5 (hNewNum.getD 5 0 + 2)))).headD 0 -
      absSum (addL minorantNum (scaleL (-hNewScale) (hNewNum.set 5 (hNewNum.getD 5 0 + 2)))).tail)
      = false := by decide +kernel

/-- Same with index 13. -/
theorem rv_neg_shift_coeff13 :
    decide (hNewScale ≤
      (addL minorantNum (scaleL (-hNewScale) (hNewNum.set 13 (hNewNum.getD 13 0 + 2)))).headD 0 -
      absSum (addL minorantNum (scaleL (-hNewScale) (hNewNum.set 13 (hNewNum.getD 13 0 + 2)))).tail)
      = false := by decide +kernel

/-- Positive twin: the unmodified shift certificate passes (same expression shape). -/
theorem rv_pos_shift :
    decide (hNewScale ≤
      (addL minorantNum (scaleL (-hNewScale) (hNewNum.set 5 (hNewNum.getD 5 0 + 0)))).headD 0 -
      absSum (addL minorantNum (scaleL (-hNewScale) (hNewNum.set 5 (hNewNum.getD 5 0 + 0)))).tail)
      = true := by decide +kernel

/-- Refined windows are needed: the leaf for `h + 10⁻³³` on the merged `y`-interval of refined
intervals 1 and 2 (which contains the contact `s₁ = -r`) is rejected. -/
theorem rv_neg_refined_no_window :
    checkInterval (potential (addL [refGapNum] minorantNum) minorantDen)
      (refA.getD 2 0) (refB.getD 1 0) refM 1 1 1 = false := by decide +kernel

/-- Refined window half width shrunk to `10⁻⁸ - 10⁻⁹` on interval 1: √-placement rejected. -/
theorem rv_neg_refined_eps1 :
    extOk (refA.getD 1 0) (refB.getD 1 0) refM (refLo.getD 1 0 - 1 / 10 ^ 9) (refHi.getD 1 0)
      = false := by decide +kernel

/-- The same for interval 6 (upper side of the last contact `r/2`). -/
theorem rv_neg_refined_eps6 :
    extOk (refA.getD 6 0) (refB.getD 6 0) refM (refLo.getD 6 0 - 1 / 10 ^ 9) (refHi.getD 6 0)
      = false := by decide +kernel

/-- Refined interval 6 extended past the LP cap (to `5594/10000`): rejected. -/
theorem rv_neg_refined_cap :
    extOk (refA.getD 6 0) (refB.getD 6 0) refM (refLo.getD 6 0) (5594 / 10000) = false := by
  decide +kernel

/-- Separation LP: minorant constant raised by `10⁻³` on Codex's tree: rejected. -/
theorem rv_neg_sep_raised :
    checkInterval (potential (addL [separationDenominator / 1000] separationNumerators)
      separationDenominator) 0 1 1 1 sepTreeLen sepTreeBits = false := by decide +kernel

/-- Separation tail: cap moved to `5592/10000` (tail `y`-interval no longer covers): rejected. -/
theorem rv_neg_sep_tail_cap5592 :
    tailCheck separationNumerators separationDenominator sepTailGapNum sepTailB sepTailM
      (5592 / 10000) = false := by decide +kernel

/-- Separation tail: gap doubled (2·(U − B_sep + 10⁻⁸) ≈ 0.063): rejected. -/
theorem rv_neg_sep_tail_double :
    tailCheck separationNumerators separationDenominator (2 * sepTailGapNum) sepTailB sepTailM
      sepTailCap = false := by decide +kernel
