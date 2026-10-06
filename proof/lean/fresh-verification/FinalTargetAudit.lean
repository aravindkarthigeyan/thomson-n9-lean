import Solution

set_option autoImplicit false
set_option pp.universes true

namespace ThomsonN9.FreshAudit

example : Challenge.CompleteTarget := thomson_nine_complete

example : ∀ r : CandidateParameter, ∀ x : Configuration,
    IsSphereConfiguration x → coulombEnergy (candidate r) ≤ coulombEnergy x :=
  thomson_nine

example : ∀ r : CandidateParameter, ∀ x : Configuration,
    IsSphereConfiguration x →
      (coulombEnergy x = coulombEnergy (candidate r) ↔ Congruent x (candidate r)) :=
  thomson_nine_unique

example : IsSphereConfiguration optimalConfiguration := optimalConfiguration_admissible

example : ∀ x : Configuration, IsSphereConfiguration x →
    coulombEnergy optimalConfiguration ≤ coulombEnergy x := thomson_nine_fixed

example : ∀ x : Configuration, IsSphereConfiguration x →
    (coulombEnergy x = coulombEnergy optimalConfiguration ↔ Congruent x optimalConfiguration) :=
  thomson_nine_fixed_unique

end ThomsonN9.FreshAudit

#check @ThomsonN9.thomson_nine_complete
#check @ThomsonN9.thomson_nine
#check @ThomsonN9.thomson_nine_unique
#check @ThomsonN9.optimalConfiguration_admissible
#check @ThomsonN9.thomson_nine_fixed
#check @ThomsonN9.thomson_nine_fixed_unique
#print axioms ThomsonN9.thomson_nine_complete
#print axioms ThomsonN9.thomson_nine
#print axioms ThomsonN9.thomson_nine_unique
#print axioms ThomsonN9.optimalConfiguration_admissible
#print axioms ThomsonN9.thomson_nine_fixed
#print axioms ThomsonN9.thomson_nine_fixed_unique
