import ThomsonN9.Basic

namespace ThomsonN9

theorem pair_distance_pos {x : Configuration} (hx : IsSphereConfiguration x)
    {i j : Fin 9} (hij : i ≠ j) : 0 < ‖x i - x j‖ := by
  exact norm_pos_iff.mpr (sub_ne_zero.mpr (fun h => hij (hx.2 h)))

theorem pair_distance_le_two {x : Configuration} (hx : IsSphereConfiguration x)
    (i j : Fin 9) : ‖x i - x j‖ ≤ 2 := by
  calc
    ‖x i - x j‖ ≤ ‖x i‖ + ‖x j‖ := norm_sub_le _ _
    _ = 2 := by rw [hx.1 i, hx.1 j]; norm_num

theorem pair_energy_ge_half {x : Configuration} (hx : IsSphereConfiguration x)
    {i j : Fin 9} (hij : i ≠ j) : (1 / 2 : ℝ) ≤ (‖x i - x j‖)⁻¹ := by
  have hp := pair_distance_pos hx hij
  have hb := pair_distance_le_two hx i j
  rw [inv_eq_one_div, div_le_div_iff₀ (by norm_num : (0 : ℝ) < 2) hp]
  nlinarith

theorem energy_nonnegative (x : Configuration) : 0 ≤ coulombEnergy x := by
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => inv_nonneg.mpr (norm_nonneg _)

theorem energy_ge_eighteen {x : Configuration} (hx : IsSphereConfiguration x) :
    (18 : ℝ) ≤ coulombEnergy x := by
  have h : (∑ i : Fin 9, ∑ j ∈ Finset.Ioi i, (1 / 2 : ℝ)) ≤ coulombEnergy x := by
    exact Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j hj =>
      pair_energy_ge_half hx (Finset.mem_Ioi.mp hj).ne
  norm_num [Fin.sum_univ_succ] at h
  exact h

end ThomsonN9
