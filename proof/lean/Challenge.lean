import ThomsonN9.Candidate

/-! Independent targets. These are propositions, not asserted theorems. -/

namespace ThomsonN9.Challenge

def ParameterExistsUnique : Prop :=
  ∃! r : ℝ, (radiusLower : ℝ) ≤ r ∧ r ≤ (radiusUpper : ℝ) ∧ stationarity r = 0

def GlobalOptimality : Prop :=
  ∀ r : CandidateParameter, ∀ x : Configuration,
    IsSphereConfiguration x → coulombEnergy (candidate r) ≤ coulombEnergy x

def GlobalUniqueness : Prop :=
  ∀ r : CandidateParameter, ∀ x : Configuration,
    IsSphereConfiguration x →
    (coulombEnergy x = coulombEnergy (candidate r) ↔ Congruent x (candidate r))

def CompleteTarget : Prop := ParameterExistsUnique ∧ GlobalOptimality ∧ GlobalUniqueness

end ThomsonN9.Challenge
