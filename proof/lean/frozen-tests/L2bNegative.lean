import ClaudeL2b.RefinedWindows
import ClaudeL2b.LPCovers

/-! Negative controls for L2b: each `= false` is evaluated by the kernel (`decide +kernel`).
Predictions: `l2b_negprep.py` (log `logs/negprep.json`). -/

open ThomsonN9.Bernstein ThomsonN9.Claude.L2b

-- constant shift: twice the claimed margin (2·10⁻⁶⁰) is rejected (true margin 1.5585·10⁻⁶⁰)
theorem neg_shift_double :
    decide (2 * hNewScale ≤ deltaNum.headD 0 - absSum deltaNum.tail) = false := by
  decide +kernel

-- constant shift: h_new with its constant raised by 10⁻⁶⁰ is rejected
theorem neg_shift_raised :
    decide (hNewScale ≤ (addL minorantNum (scaleL (-hNewScale) (addL [1] hNewNum))).headD 0 -
      absSum (addL minorantNum (scaleL (-hNewScale) (addL [1] hNewNum))).tail) = false := by
  decide +kernel

-- refined leaf 0 with gap 10⁻³⁰ instead of 10⁻³³ is rejected (largest passing power: 10⁻³¹)
theorem neg_refined_gap :
    checkInterval (potential (addL [10 ^ 150] minorantNum) minorantDen)
      (refA.getD 0 0) (refB.getD 0 0) refM 1 1 1 = false := by decide +kernel

-- refined interval 0 enlarged to start at -4/5: the √-placement check is rejected
theorem neg_refined_domain :
    extOk (refA.getD 0 0) (refB.getD 0 0) refM (-4 / 5) (refHi.getD 0 0) = false := by
  decide +kernel

-- covariance LP: [0,1] as a single unsplit leaf is rejected
theorem neg_cov_unsplit :
    checkInterval (potential covarianceNumerators covarianceDenominator) 0 1 1 1 1 1 = false := by
  decide +kernel

-- covariance LP: the tree with its last token removed (one leaf uncovered) is rejected
theorem neg_cov_truncated :
    checkInterval (potential covarianceNumerators covarianceDenominator) 0 1 1 1
      (covTreeLen - 1) (covTreeBits % 2 ^ (covTreeLen - 1)) = false := by decide +kernel

-- covariance LP: minorant constant raised by 10⁻³ is rejected
theorem neg_cov_raised :
    checkInterval (potential (addL [covarianceDenominator / 1000] covarianceNumerators)
      covarianceDenominator) 0 1 1 1 covTreeLen covTreeBits = false := by decide +kernel

-- separation LP: unsplit root rejected
theorem neg_sep_unsplit :
    checkInterval (potential separationNumerators separationDenominator) 0 1 1 1 1 1 = false := by
  decide +kernel

-- separation tail: gap raised by 10⁻³ is rejected
theorem neg_sep_tail_gap :
    tailCheck separationNumerators separationDenominator
      (sepTailGapNum + separationDenominator / 1000) sepTailB sepTailM sepTailCap = false := by
  decide +kernel

-- separation tail: cap moved inward to 0.55 (y-interval no longer covers) is rejected
theorem neg_sep_tail_cap :
    tailCheck separationNumerators separationDenominator sepTailGapNum sepTailB sepTailM
      (55 / 100) = false := by decide +kernel

-- positive controls (fresh re-evaluation)
theorem pos_ref0 : refCheck 0 = true := by decide +kernel
theorem pos_sep_tail : tailCheck separationNumerators separationDenominator sepTailGapNum
    sepTailB sepTailM sepTailCap = true := by decide +kernel
