import ThomsonN9.CentroidBound
import ThomsonN9.LocalRigidity
import ThomsonN9.FamilyMinimum
import ThomsonN9.CandidateEnergy
import ThomsonN9.Completion

/-! Public global theorem import and supplementary elementary and family results. -/

namespace ThomsonN9

theorem admissible_candidate_and_elementary_bound (r : CandidateParameter) :
    IsSphereConfiguration (candidate r) ∧ 24 ≤ coulombEnergy (candidate r) :=
  ⟨candidate_admissible r, energy_ge_twenty_four (candidate_admissible r)⟩

theorem candidate_family_minimizer (r : CandidateParameter) {s : ℝ}
    (hs0 : 0 < s) (hs1 : s < 1) :
    coulombEnergy (candidate r) ≤ coulombEnergy (candidateAt s) ∧
      (coulombEnergy (candidate r) = coulombEnergy (candidateAt s) ↔ (r : ℝ) = s) := by
  rw [candidate_energy, candidateAt_energy hs0 hs1]
  exact symmetricEnergy_unique_min r hs0 hs1

end ThomsonN9
