import ThomsonN9.Candidate

namespace ThomsonN9

noncomputable def dec50 (n : ℕ) : ℝ := (n : ℝ) / 10 ^ 50

theorem sqrt_enclosure50 (n : ℕ) (q : ℝ)
    (hl : dec50 n ^ 2 ≤ q) (hu : q ≤ dec50 (n + 1) ^ 2) :
    dec50 n ≤ Real.sqrt q ∧ Real.sqrt q ≤ dec50 (n + 1) := by
  have hln : 0 ≤ dec50 n := by unfold dec50; positivity
  have hun : 0 ≤ dec50 (n + 1) := by unfold dec50; positivity
  exact ⟨(Real.le_sqrt hln ((sq_nonneg _).trans hl)).2 hl,
    Real.sqrt_le_iff.mpr ⟨hun, hu⟩⟩

theorem stationarity_radiusLower_neg : stationarity (radiusLower : ℝ) < 0 := by
  let r : ℝ := (radiusLower : ℝ)
  obtain ⟨h0l, h0u⟩ := sqrt_enclosure50 173205080756887729352744634150587236694280525381038 3
    (by norm_num [dec50]) (by norm_num [dec50])
  obtain ⟨h1l, h1u⟩ := sqrt_enclosure50 70364839580413177577775233246281612124897656280687 (1 - r ^ 2)
    (by norm_num [dec50, r, radiusLower]) (by norm_num [dec50, r, radiusLower])
  obtain ⟨h2l, h2u⟩ := sqrt_enclosure50 186952428840005394898501991582762105235753532049530 (4 - r ^ 2)
    (by norm_num [dec50, r, radiusLower]) (by norm_num [dec50, r, radiusLower])
  obtain ⟨h3l, h3u⟩ := sqrt_enclosure50 184962068224431022733225494700822241221422043803667 (2 + 2 * r)
    (by norm_num [dec50, r, radiusLower]) (by norm_num [dec50, r, radiusLower])
  obtain ⟨h4l, h4u⟩ := sqrt_enclosure50 113554025287835842031462496592749817388408564740323 (2 - r)
    (by norm_num [dec50, r, radiusLower]) (by norm_num [dec50, r, radiusLower])
  have hr : 0 < r := by norm_num [r, radiusLower]
  have hs1 : 0 < Real.sqrt (1 - r ^ 2) := Real.sqrt_pos.mpr (by norm_num [r, radiusLower])
  have hs2 : 0 < Real.sqrt (4 - r ^ 2) := Real.sqrt_pos.mpr (by norm_num [r, radiusLower])
  have hs3 : 0 < Real.sqrt (2 + 2 * r) := Real.sqrt_pos.mpr (by norm_num [r, radiusLower])
  have hs4 : 0 < Real.sqrt (2 - r) := Real.sqrt_pos.mpr (by norm_num [r, radiusLower])
  let b : ℝ := -2 * dec50 173205080756887729352744634150587236694280525381038 / r ^ 2
    + 3 * r / (2 * dec50 70364839580413177577775233246281612124897656280687 ^ 3)
    + 6 * r / dec50 186952428840005394898501991582762105235753532049530 ^ 3
    - 6 / dec50 (184962068224431022733225494700822241221422043803667 + 1) ^ 3
    + 6 / dec50 113554025287835842031462496592749817388408564740323 ^ 3
  have hf : stationarity r ≤ b := by
    unfold stationarity b
    simp only [neg_mul, neg_div]
    gcongr <;> first | assumption | positivity | norm_num [dec50]
  have hb : b < 0 := by norm_num [b, dec50, r, radiusLower]
  exact lt_of_le_of_lt hf hb

theorem stationarity_radiusUpper_pos : 0 < stationarity (radiusUpper : ℝ) := by
  let r : ℝ := (radiusUpper : ℝ)
  obtain ⟨h0l, h0u⟩ := sqrt_enclosure50 173205080756887729352744634150587236694280525381038 3
    (by norm_num [dec50]) (by norm_num [dec50])
  obtain ⟨h1l, h1u⟩ := sqrt_enclosure50 70364839580413177577775233246281612124887558221226 (1 - r ^ 2)
    (by norm_num [dec50, r, radiusUpper]) (by norm_num [dec50, r, radiusUpper])
  obtain ⟨h2l, h2u⟩ := sqrt_enclosure50 186952428840005394898501991582762105235749731358956 (4 - r ^ 2)
    (by norm_num [dec50, r, radiusUpper]) (by norm_num [dec50, r, radiusUpper])
  obtain ⟨h3l, h3u⟩ := sqrt_enclosure50 184962068224431022733225494700822241221427450317606 (2 + 2 * r)
    (by norm_num [dec50, r, radiusUpper]) (by norm_num [dec50, r, radiusUpper])
  obtain ⟨h4l, h4u⟩ := sqrt_enclosure50 113554025287835842031462496592749817388404161549870 (2 - r)
    (by norm_num [dec50, r, radiusUpper]) (by norm_num [dec50, r, radiusUpper])
  have hr : 0 < r := by norm_num [r, radiusUpper]
  have hs1 : 0 < Real.sqrt (1 - r ^ 2) := Real.sqrt_pos.mpr (by norm_num [r, radiusUpper])
  have hs2 : 0 < Real.sqrt (4 - r ^ 2) := Real.sqrt_pos.mpr (by norm_num [r, radiusUpper])
  have hs3 : 0 < Real.sqrt (2 + 2 * r) := Real.sqrt_pos.mpr (by norm_num [r, radiusUpper])
  have hs4 : 0 < Real.sqrt (2 - r) := Real.sqrt_pos.mpr (by norm_num [r, radiusUpper])
  let b : ℝ := -2 * dec50 (173205080756887729352744634150587236694280525381038 + 1) / r ^ 2
    + 3 * r / (2 * dec50 (70364839580413177577775233246281612124887558221226 + 1) ^ 3)
    + 6 * r / dec50 (186952428840005394898501991582762105235749731358956 + 1) ^ 3
    - 6 / dec50 184962068224431022733225494700822241221427450317606 ^ 3
    + 6 / dec50 (113554025287835842031462496592749817388404161549870 + 1) ^ 3
  have hf : b ≤ stationarity r := by
    unfold stationarity b
    simp only [neg_mul, neg_div]
    gcongr <;> first | assumption | positivity | norm_num [dec50]
  have hb : 0 < b := by norm_num [b, dec50, r, radiusUpper]
  exact lt_of_lt_of_le hb hf

end ThomsonN9
