import ThomsonN9.FamilyEnergy
import Mathlib.Analysis.Convex.Deriv

namespace ThomsonN9

theorem symmetricEnergy_strictConvexOn :
    StrictConvexOn ℝ (Set.Ioo (0 : ℝ) 1) symmetricEnergy := by
  have hc : ContinuousOn symmetricEnergy (Set.Ioo (0 : ℝ) 1) := by
    intro r hr
    exact (symmetricEnergy_hasDerivAt hr.1 hr.2).continuousAt.continuousWithinAt
  apply StrictMonoOn.strictConvexOn_of_deriv (convex_Ioo (0 : ℝ) 1) hc
  simp only [interior_Ioo]
  intro a ha b hb hab
  rw [(symmetricEnergy_hasDerivAt ha.1 ha.2).deriv,
    (symmetricEnergy_hasDerivAt hb.1 hb.2).deriv]
  exact stationarity_strictMonoOn ha hb hab

theorem symmetricEnergy_strict_min (r : CandidateParameter) {s : ℝ}
    (hs0 : 0 < s) (hs1 : s < 1) (hne : s ≠ (r : ℝ)) :
    symmetricEnergy r < symmetricEnergy s := by
  have hr := radius_bounds r
  rcases lt_or_gt_of_ne hne with hsr | hrs
  · have h := symmetricEnergy_strictConvexOn.slope_lt_of_hasDerivAt
      ⟨hs0, hs1⟩ hr hsr (candidate_symmetric_stationary r)
    rw [slope_def_field] at h
    have hn := (div_neg_iff).mp h
    rcases hn with hn | hn
    · linarith [sub_pos.mpr hsr]
    · linarith [sub_pos.mpr hsr]
  · have h := symmetricEnergy_strictConvexOn.lt_slope_of_hasDerivAt
      hr ⟨hs0, hs1⟩ hrs (candidate_symmetric_stationary r)
    rw [slope_def_field] at h
    have hn := (div_pos_iff).mp h
    rcases hn with hn | hn
    · linarith
    · linarith [sub_pos.mpr hrs]

theorem symmetricEnergy_unique_min (r : CandidateParameter) {s : ℝ}
    (hs0 : 0 < s) (hs1 : s < 1) :
    symmetricEnergy r ≤ symmetricEnergy s ∧
      (symmetricEnergy r = symmetricEnergy s ↔ (r : ℝ) = s) := by
  by_cases he : s = (r : ℝ)
  · subst s
    exact ⟨le_refl _, by simp⟩
  · have h := symmetricEnergy_strict_min r hs0 hs1 he
    exact ⟨h.le, ⟨fun heq => False.elim (h.ne heq), fun heq => False.elim (he heq.symm)⟩⟩

end ThomsonN9
