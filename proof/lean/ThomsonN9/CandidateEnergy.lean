import ThomsonN9.Candidate

namespace ThomsonN9

noncomputable def candidateDistance (r : ℝ) (i j : Fin 9) : ℝ :=
  if i = j then 0
  else if (i : ℕ) < 6 ∧ (j : ℕ) < 6 then
    if (i : ℕ) % 3 = (j : ℕ) % 3 then 2 * Real.sqrt (1 - r ^ 2)
    else if (i : ℕ) / 3 = (j : ℕ) / 3 then Real.sqrt 3 * r
    else Real.sqrt (4 - r ^ 2)
  else if 6 ≤ (i : ℕ) ∧ 6 ≤ (j : ℕ) then Real.sqrt 3
  else if (i : ℕ) % 3 = (j : ℕ) % 3 then Real.sqrt (2 + 2 * r)
  else Real.sqrt (2 - r)

theorem candidate_distance_nonnegative {r : ℝ} (hr : 0 < r) (i j : Fin 9) :
    0 ≤ candidateDistance r i j := by
  unfold candidateDistance
  split_ifs <;> positivity

theorem vec_sub_norm_sq (a b c d e f : ℝ) :
    ‖vec a b c - vec d e f‖ ^ 2 = (a - d) ^ 2 + (b - e) ^ 2 + (c - f) ^ 2 := by
  simp [EuclideanSpace.norm_sq_eq, vec, Fin.sum_univ_three]

theorem candidate_distance {r : ℝ} (hr : 0 < r) (hr1 : r < 1) (i j : Fin 9) :
    ‖candidateAt r i - candidateAt r j‖ = candidateDistance r i j := by
  have h3 : Real.sqrt (3 : ℝ) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hz : Real.sqrt (1 - r ^ 2) ^ 2 = 1 - r ^ 2 := Real.sq_sqrt (by nlinarith)
  have h4 : Real.sqrt (4 - r ^ 2) ^ 2 = 4 - r ^ 2 := Real.sq_sqrt (by nlinarith)
  have hp : Real.sqrt (2 + 2 * r) ^ 2 = 2 + 2 * r := Real.sq_sqrt (by positivity)
  have hm : Real.sqrt (2 - r) ^ 2 = 2 - r := Real.sq_sqrt (by linarith)
  ring_nf at hp
  have hsq : ‖candidateAt r i - candidateAt r j‖ ^ 2 = candidateDistance r i j ^ 2 := by
    fin_cases i <;> fin_cases j <;>
      norm_num [candidateAt, candidateDistance, vec_sub_norm_sq]
    all_goals ring_nf
    all_goals simp only [h3, hz, h4, hp, hm]
    all_goals ring
  exact (sq_eq_sq₀ (norm_nonneg _) (candidate_distance_nonnegative hr i j)).mp hsq

theorem candidateAt_energy {r : ℝ} (hr : 0 < r) (hr1 : r < 1) :
    coulombEnergy (candidateAt r) = symmetricEnergy r := by
  have hsum (i : Fin 9) : (∑ j ∈ Finset.Ioi i, (candidateDistance r i j)⁻¹) =
      ∑ j : Fin 9, if i < j then (candidateDistance r i j)⁻¹ else 0 := by
    rw [← Finset.sum_filter]
    congr 1
    ext j
    simp
  unfold coulombEnergy
  simp_rw [candidate_distance hr hr1, hsum]
  norm_num [candidateDistance, Fin.sum_univ_succ]
  unfold symmetricEnergy
  have h3 : Real.sqrt (3 : ℝ) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs : Real.sqrt (3 : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (by norm_num)).ne'
  have hz : Real.sqrt (1 - r ^ 2) ≠ 0 := (Real.sqrt_pos.mpr (by nlinarith)).ne'
  have h4 : Real.sqrt (4 - r ^ 2) ≠ 0 := (Real.sqrt_pos.mpr (by nlinarith)).ne'
  have hp : Real.sqrt (2 + 2 * r) ≠ 0 := (Real.sqrt_pos.mpr (by positivity)).ne'
  have hm : Real.sqrt (2 - r) ≠ 0 := (Real.sqrt_pos.mpr (by linarith)).ne'
  field_simp
  ring_nf
  simp only [h3]
  <;> ring

theorem candidate_energy (r : CandidateParameter) :
    coulombEnergy (candidate r) = symmetricEnergy r :=
  candidateAt_energy (radius_bounds r).1 (radius_bounds r).2

end ThomsonN9
