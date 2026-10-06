import ClaudeL2b.LPCovers
import ThomsonN9.SDP.GeometryBounds

/-!
# LP inequalities in the vocabulary of Codex's `N9LPConcrete` draft

Compiled against `combined/` (Codex's compiled oleans, read-only copies, plus L2's oleans).
`ThomsonN9.SDP.coulombPotential t` is `(Real.sqrt (2-2*t))⁻¹` by definition, so the statements
of `LPCovers.lean` are restated here verbatim with `SDP.coulombPotential`.

For Codex's `covariance_lt_quarter` / `inner_lt_separation` (work/N9LPConcrete.lean):
`hminor_cov`, `hminor_sep`, `htail_sep` produce the hypotheses `hminor`, `htail` for any
function `m` with the Horner identity `polyEval Numerators t / Denominator = m t`
(`covariance_horner_eq` / `separation_horner_eq` of `work/N9LPLinkage.lean`, after unfolding
`legendreExpansion`).  The numerator lists here are literally those of the draft
(`lp-horner-interface.json`), so `ThomsonN9.LPLinkageDraft.covarianceNumerators =
ThomsonN9.Claude.L2b.covarianceNumerators` is `rfl` (likewise for the denominators and the
separation lists).
-/

namespace ThomsonN9.Claude.L2b

open ThomsonN9

theorem covariance_le_coulombPotential : ∀ t : Real, -1 ≤ t → t < 1 →
    Bernstein.polyEval covarianceNumerators t / covarianceDenominator ≤ SDP.coulombPotential t :=
  covariance_le_inv_sqrt

theorem separation_le_coulombPotential : ∀ t : Real, -1 ≤ t → t < 1 →
    Bernstein.polyEval separationNumerators t / separationDenominator ≤ SDP.coulombPotential t :=
  separation_le_inv_sqrt

theorem separation_tail_coulombPotential : ∀ t : Real, (5593 / 10000 : Real) ≤ t → t < 1 →
    Bernstein.polyEval separationNumerators t / separationDenominator +
        ((6439996633 / 250000000 : Real) - 25728382789209 / 1000000000000) +
        (1 / 100000000 : Real) ≤ SDP.coulombPotential t :=
  separation_tail

/-- `hminor` of `covariance_lt_quarter`, from the Horner identity of the minorant `m`. -/
theorem hminor_cov (m : Real → Real)
    (hm : ∀ t, Bernstein.polyEval covarianceNumerators t / covarianceDenominator = m t) :
    ∀ t : Real, -1 ≤ t → t < 1 → m t ≤ SDP.coulombPotential t :=
  hminor_of_horner_cov m hm

/-- `hminor` of `inner_lt_separation`. -/
theorem hminor_sep (m : Real → Real)
    (hm : ∀ t, Bernstein.polyEval separationNumerators t / separationDenominator = m t) :
    ∀ t : Real, -1 ≤ t → t < 1 → m t ≤ SDP.coulombPotential t :=
  hminor_of_horner_sep m hm

/-- `htail` of `inner_lt_separation` (`energyCutoff = U`, `separationBound = B`). -/
theorem htail_sep (m : Real → Real) (U B : Real) (hU : U = 6439996633 / 250000000)
    (hB : B = 25728382789209 / 1000000000000)
    (hm : ∀ t, Bernstein.polyEval separationNumerators t / separationDenominator = m t) :
    ∀ t : Real, (5593 / 10000 : Real) ≤ t → t < 1 →
      m t + (U - B) + (1 / 100000000 : Real) ≤ SDP.coulombPotential t :=
  htail_of_horner_sep m U B hU hB hm

end ThomsonN9.Claude.L2b

#print axioms ThomsonN9.Claude.L2b.covariance_le_coulombPotential
#print axioms ThomsonN9.Claude.L2b.separation_le_coulombPotential
#print axioms ThomsonN9.Claude.L2b.separation_tail_coulombPotential
#print axioms ThomsonN9.Claude.L2b.hminor_cov
#print axioms ThomsonN9.Claude.L2b.hminor_sep
#print axioms ThomsonN9.Claude.L2b.htail_sep
