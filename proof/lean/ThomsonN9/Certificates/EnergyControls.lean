import ThomsonN9.Certificates.ReducedEnergy

/-! Exact negative controls for the imported comparison-energy certificate. -/

set_option autoImplicit false

namespace ThomsonN9.Certificates.ReducedEnergy

theorem rejected_square_root_collapse :
    ¬ RatInterval.SqrtBounds b3 (⟨b7.lo, b7.lo⟩ : RatInterval) := by
  norm_num [RatInterval.SqrtBounds, b3, b7]

theorem rejected_lowered_energy_ceiling :
    ¬ b37.hi ≤ energyUpper-(1/10^50 : ℚ) := by
  norm_num [b37, energyUpper]

#print axioms rejected_square_root_collapse
#print axioms rejected_lowered_energy_ceiling

end ThomsonN9.Certificates.ReducedEnergy
