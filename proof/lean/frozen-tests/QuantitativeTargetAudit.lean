import ThomsonN9.QuantitativeStability

/-! Exact public type pin for the quantitative stability theorem. -/

set_option autoImplicit false

namespace ThomsonN9.FreshAudit

example : ∀ (r : CandidateParameter) (x : Configuration),
    IsSphereConfiguration x →
    coulombEnergy x ≤ coulombEnergy (candidate r) + (1 / 10^47 : ℝ) →
    ∃ (p : Equiv.Perm (Fin 9)) (Q : R3 ≃ₗᵢ[ℝ] R3),
      (∑ i, ‖Q (x (p i)) - candidate r i‖^2) ≤
        50 * (coulombEnergy x - coulombEnergy (candidate r)) :=
  thomson_nine_quantitative_stability

end ThomsonN9.FreshAudit

#check @ThomsonN9.thomson_nine_quantitative_stability
#print axioms ThomsonN9.thomson_nine_quantitative_stability
