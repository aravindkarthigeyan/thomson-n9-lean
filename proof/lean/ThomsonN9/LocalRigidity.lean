import ThomsonN9.Candidate

namespace ThomsonN9

-- The local target is proved by LocalTarget using the concrete AmbientHessian certificate.
def QuantitativeLocalTarget : Prop :=
  ∀ r : CandidateParameter, ∀ x : Configuration,
    IsSphereConfiguration x →
    (∃ g : R3 ≃ₗᵢ[ℝ] R3,
      (∑ i, ‖x i - g (candidate r i)‖ ^ 2) ≤ (1 / 500 : ℝ) ^ 2) →
    coulombEnergy (candidate r) ≤ coulombEnergy x ∧
      (coulombEnergy x = coulombEnergy (candidate r) → Congruent x (candidate r))

end ThomsonN9
