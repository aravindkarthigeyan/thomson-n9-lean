import ThomsonN9.ScalarCertificates
import ThomsonN9.Certificates.AmbientHessian

/-! Unconditional global optimality and uniqueness against the independent challenge. -/

set_option autoImplicit false

namespace ThomsonN9

theorem thomson_nine_complete : Challenge.CompleteTarget :=
  complete_of_refined_gram_and_hessian sublevel_refined_gram
    Certificates.AmbientKernel.candidate_augmented_hessian_posSemidef

theorem thomson_nine (r : CandidateParameter) (x : Configuration)
    (hx : IsSphereConfiguration x) :
    coulombEnergy (candidate r) ≤ coulombEnergy x :=
  thomson_nine_complete.2.1 r x hx

theorem thomson_nine_unique (r : CandidateParameter) (x : Configuration)
    (hx : IsSphereConfiguration x) :
    coulombEnergy x = coulombEnergy (candidate r) ↔ Congruent x (candidate r) :=
  thomson_nine_complete.2.2 r x hx

noncomputable def optimalParameter : CandidateParameter :=
  Classical.choice candidateParameter_nonempty

noncomputable def optimalConfiguration : Configuration := candidate optimalParameter

theorem optimalConfiguration_admissible : IsSphereConfiguration optimalConfiguration :=
  candidate_admissible optimalParameter

theorem thomson_nine_fixed (x : Configuration) (hx : IsSphereConfiguration x) :
    coulombEnergy optimalConfiguration ≤ coulombEnergy x :=
  thomson_nine optimalParameter x hx

theorem thomson_nine_fixed_unique (x : Configuration) (hx : IsSphereConfiguration x) :
    coulombEnergy x = coulombEnergy optimalConfiguration ↔ Congruent x optimalConfiguration :=
  thomson_nine_unique optimalParameter x hx

#print axioms thomson_nine_complete
#print axioms thomson_nine
#print axioms thomson_nine_unique
#print axioms optimalConfiguration_admissible
#print axioms thomson_nine_fixed
#print axioms thomson_nine_fixed_unique

end ThomsonN9
