import ThomsonN9.Basic

namespace ThomsonN9

def radiusLower : ℚ :=
  7105483340929538113277041792727912437680 / 10000000000000000000000000000000000000000

def radiusUpper : ℚ :=
  7105483340929538113277041792727912437681 / 10000000000000000000000000000000000000000

noncomputable def stationarity (r : ℝ) : ℝ :=
  -2 * Real.sqrt 3 / r ^ 2
    + 3 * r / (2 * Real.sqrt (1 - r ^ 2) ^ 3)
    + 6 * r / Real.sqrt (4 - r ^ 2) ^ 3
    - 6 / Real.sqrt (2 + 2 * r) ^ 3
    + 6 / Real.sqrt (2 - r) ^ 3

abbrev CandidateParameter :=
  {r : ℝ // (radiusLower : ℝ) ≤ r ∧ r ≤ (radiusUpper : ℝ) ∧ stationarity r = 0}

theorem radius_bounds (r : CandidateParameter) : 0 < (r : ℝ) ∧ (r : ℝ) < 1 := by
  have hl : (0 : ℝ) < (radiusLower : ℝ) := by norm_num [radiusLower]
  have hu : (radiusUpper : ℝ) < (1 : ℝ) := by norm_num [radiusUpper]
  exact ⟨lt_of_lt_of_le hl r.property.1, lt_of_le_of_lt r.property.2.1 hu⟩

noncomputable def candidateAt (r : ℝ) : Configuration :=
  let z := Real.sqrt (1 - r ^ 2)
  let s := Real.sqrt 3 / 2
  ![vec r 0 z, vec (-r / 2) (r * s) z, vec (-r / 2) (-r * s) z,
    vec r 0 (-z), vec (-r / 2) (r * s) (-z), vec (-r / 2) (-r * s) (-z),
    vec (-1) 0 0, vec (1 / 2) (-s) 0, vec (1 / 2) s 0]

noncomputable def candidate (r : CandidateParameter) : Configuration := candidateAt r

noncomputable def symmetricEnergy (r : ℝ) : ℝ :=
  Real.sqrt 3 + 2 * Real.sqrt 3 / r
    + 3 / (2 * Real.sqrt (1 - r ^ 2))
    + 6 / Real.sqrt (4 - r ^ 2)
    + 6 / Real.sqrt (2 + 2 * r)
    + 12 / Real.sqrt (2 - r)

theorem candidateAt_norm {r : ℝ} (hr : 0 < r) (hr1 : r < 1) (i : Fin 9) :
    ‖candidateAt r i‖ = 1 := by
  have hz : 0 ≤ 1 - r ^ 2 := by nlinarith
  have hzsq := Real.sq_sqrt hz
  have h3 := Real.sq_sqrt (show (0 : ℝ) ≤ 3 by norm_num)
  have hn : ‖candidateAt r i‖ ^ 2 = 1 := by
    fin_cases i <;> simp [candidateAt, vec_norm_sq, mul_pow, div_pow, hzsq, h3] <;> nlinarith
  nlinarith [norm_nonneg (candidateAt r i)]

theorem candidateAt_injective {r : ℝ} (hr : 0 < r) (hr1 : r < 1) :
    Function.Injective (candidateAt r) := by
  have hz : 0 < Real.sqrt (1 - r ^ 2) := Real.sqrt_pos.2 (by nlinarith)
  have h3 : 0 < Real.sqrt (3 : ℝ) := Real.sqrt_pos.2 (by norm_num)
  have hp : 0 < r * Real.sqrt 3 := mul_pos hr h3
  intro i j h
  have hx := congrArg (fun v : R3 => v 0) h
  have hy := congrArg (fun v : R3 => v 1) h
  have ht := congrArg (fun v : R3 => v 2) h
  fin_cases i <;> fin_cases j <;> simp [candidateAt, vec] at hx hy ht ⊢ <;> nlinarith

theorem candidate_admissible (r : CandidateParameter) : IsSphereConfiguration (candidate r) := by
  obtain ⟨hr, hr1⟩ := radius_bounds r
  exact ⟨candidateAt_norm hr hr1, candidateAt_injective hr hr1⟩

end ThomsonN9
