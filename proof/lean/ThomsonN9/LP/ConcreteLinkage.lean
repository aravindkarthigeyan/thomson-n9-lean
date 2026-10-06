import ThomsonN9.LP.Concrete
import ThomsonN9.LP.PolynomialLinkage

/-! Checked identification of the exact Horner polynomials with the LP expansions. -/

set_option autoImplicit false

namespace ThomsonN9.LPConcrete

theorem covariance_horner_minorant (t : Real) :
    Bernstein.polyEval LPLinkage.covarianceNumerators t / LPLinkage.covarianceDenominator =
      covarianceMinorant t := by
  rw [LPLinkage.covariance_horner_eq]
  norm_num [covarianceMinorant, legendreExpansion, covarianceDegrees, covarianceCoefficient]
  ring

theorem separation_horner_minorant (t : Real) :
    Bernstein.polyEval LPLinkage.separationNumerators t / LPLinkage.separationDenominator =
      separationMinorant t := by
  rw [LPLinkage.separation_horner_eq]
  norm_num [separationMinorant, legendreExpansion, separationDegrees, separationCoefficient]
  ring

#print axioms covariance_horner_minorant
#print axioms separation_horner_minorant

end ThomsonN9.LPConcrete
