import ThomsonN9.ParameterSigns
import Mathlib.Topology.Order.IntermediateValue

namespace ThomsonN9

theorem stationarity_continuousOn : ContinuousOn stationarity (Set.Ioo (0 : ℝ) 1) := by
  intro r hr
  have hr0 : 0 < r := hr.1
  have h1 : 0 < 1 - r ^ 2 := by nlinarith [hr.2]
  have h2 : 0 < 4 - r ^ 2 := by nlinarith [hr.2]
  have h3 : 0 < 2 + 2 * r := by positivity
  have h4 : 0 < 2 - r := by linarith [hr.2]
  apply ContinuousAt.continuousWithinAt
  unfold stationarity
  fun_prop (disch := positivity)

theorem stationarity_strictMonoOn : StrictMonoOn stationarity (Set.Ioo (0 : ℝ) 1) := by
  intro a ha b hb hab
  have ha0 : 0 < a := ha.1
  have hb0 : 0 < b := hb.1
  have ha1 : 0 < 1 - a ^ 2 := by nlinarith [ha.2]
  have hb1 : 0 < 1 - b ^ 2 := by nlinarith [hb.2]
  have ha2 : 0 < 4 - a ^ 2 := by nlinarith [ha.2]
  have hb2 : 0 < 4 - b ^ 2 := by nlinarith [hb.2]
  have ha3 : 0 < 2 + 2 * a := by positivity
  have hb3 : 0 < 2 + 2 * b := by positivity
  have ha4 : 0 < 2 - a := by linarith [ha.2]
  have hb4 : 0 < 2 - b := by linarith [hb.2]
  have h0 : 2 * Real.sqrt 3 / b ^ 2 < 2 * Real.sqrt 3 / a ^ 2 := by
    gcongr
  have h1 : 3 * a / (2 * Real.sqrt (1 - a ^ 2) ^ 3) ≤
      3 * b / (2 * Real.sqrt (1 - b ^ 2) ^ 3) := by
    gcongr
  have h2 : 6 * a / Real.sqrt (4 - a ^ 2) ^ 3 ≤
      6 * b / Real.sqrt (4 - b ^ 2) ^ 3 := by
    gcongr
  have h3 : 6 / Real.sqrt (2 + 2 * b) ^ 3 ≤ 6 / Real.sqrt (2 + 2 * a) ^ 3 := by
    gcongr
  have h4 : 6 / Real.sqrt (2 - a) ^ 3 ≤ 6 / Real.sqrt (2 - b) ^ 3 := by
    gcongr
  unfold stationarity
  simp only [neg_mul, neg_div]
  linarith

theorem parameter_exists_unique :
    ∃! r : ℝ, (radiusLower : ℝ) ≤ r ∧ r ≤ (radiusUpper : ℝ) ∧ stationarity r = 0 := by
  have hbounds : Set.Icc (radiusLower : ℝ) (radiusUpper : ℝ) ⊆ Set.Ioo (0 : ℝ) 1 := by
    intro r hr
    constructor
    · exact lt_of_lt_of_le (by norm_num [radiusLower]) hr.1
    · exact lt_of_le_of_lt hr.2 (by norm_num [radiusUpper])
  have hinterval : (radiusLower : ℝ) ≤ (radiusUpper : ℝ) := by norm_num [radiusLower, radiusUpper]
  obtain ⟨r, hr, hz⟩ := intermediate_value_Icc hinterval
    (stationarity_continuousOn.mono hbounds)
    ⟨stationarity_radiusLower_neg.le, stationarity_radiusUpper_pos.le⟩
  refine ⟨r, ⟨hr.1, hr.2, hz⟩, ?_⟩
  intro s hs
  exact stationarity_strictMonoOn.injOn (hbounds ⟨hs.1, hs.2.1⟩) (hbounds hr)
    (hs.2.2.trans hz.symm)

theorem candidateParameter_nonempty : Nonempty CandidateParameter := by
  obtain ⟨r, hr, _⟩ := parameter_exists_unique
  exact ⟨⟨r, hr⟩⟩

end ThomsonN9
