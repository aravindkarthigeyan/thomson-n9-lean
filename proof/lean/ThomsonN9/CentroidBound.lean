import ThomsonN9.Energy

namespace ThomsonN9

open scoped RealInnerProductSpace

noncomputable def pairSum (f : Fin 9 → Fin 9 → ℝ) : ℝ :=
  ∑ i : Fin 9, ∑ j ∈ Finset.Ioi i, f i j

theorem twice_pairSum (f : Fin 9 → Fin 9 → ℝ)
    (hs : ∀ i j, f i j = f j i) (hd : ∀ i, f i i = 0) :
    2 * pairSum f = ∑ i, ∑ j, f i j := by
  classical
  have hterm (i j : Fin 9) : f i j =
      (if i < j then f i j else 0) + (if j < i then f i j else 0) := by
    rcases lt_trichotomy i j with h | h | h
    · simp [h, not_lt_of_ge h.le]
    · subst j; simp [hd]
    · simp [h, not_lt_of_ge h.le]
  have hup : (∑ i : Fin 9, ∑ j : Fin 9, if i < j then f i j else 0) = pairSum f := by
    unfold pairSum
    apply Finset.sum_congr rfl
    intro i _
    rw [← Finset.sum_filter]
    congr 1
    ext j
    simp
  have hlo : (∑ i : Fin 9, ∑ j : Fin 9, if j < i then f i j else 0) = pairSum f := by
    rw [Finset.sum_comm]
    convert hup using 1
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    rw [hs j i]
  have hh : (∑ i, ∑ j, f i j) = pairSum f + pairSum f := by
    calc
      (∑ i, ∑ j, f i j) =
          ∑ i, ∑ j, ((if i < j then f i j else 0) + (if j < i then f i j else 0)) := by
        exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => hterm i j
      _ = pairSum f + pairSum f := by simp only [Finset.sum_add_distrib, hup, hlo]
  linarith

theorem pair_squared_distance_sum {x : Configuration} (hx : IsSphereConfiguration x) :
    pairSum (fun i j => ‖x i - x j‖ ^ 2) = 81 - ‖∑ i, x i‖ ^ 2 := by
  have ht := twice_pairSum (fun i j => ‖x i - x j‖ ^ 2)
    (fun i j => by rw [norm_sub_rev]) (fun i => by simp)
  have hi (i j : Fin 9) : ‖x i - x j‖ ^ 2 = 2 - 2 * inner ℝ (x i) (x j) := by
    rw [norm_sub_sq_real, hx.1 i, hx.1 j]
    ring
  have hs : (∑ i, ∑ j, ‖x i - x j‖ ^ 2) = 162 - 2 * ‖∑ i, x i‖ ^ 2 := by
    simp_rw [hi]
    simp only [Finset.sum_sub_distrib, ← Finset.mul_sum, ← inner_sum, ← sum_inner,
      real_inner_self_eq_norm_sq, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]
    ring
  linarith

theorem reciprocal_tangent_minorant {d : ℝ} (hd : 0 < d) :
    1 - (4 / 27 : ℝ) * d ^ 2 ≤ d⁻¹ := by
  rw [inv_eq_one_div, le_div_iff₀ hd]
  have h : 0 ≤ (2 * d - 3) ^ 2 * (d + 3) :=
    mul_nonneg (sq_nonneg _) (by linarith)
  nlinarith

theorem energy_ge_twenty_four {x : Configuration} (hx : IsSphereConfiguration x) :
    (24 : ℝ) ≤ coulombEnergy x := by
  have hsum : pairSum (fun i j => 1 - (4 / 27 : ℝ) * ‖x i - x j‖ ^ 2) ≤
      coulombEnergy x := by
    apply Finset.sum_le_sum
    intro i _
    apply Finset.sum_le_sum
    intro j hj
    exact reciprocal_tangent_minorant (pair_distance_pos hx (Finset.mem_Ioi.mp hj).ne)
  have hcount : pairSum (fun _ _ => (1 : ℝ)) = 36 := by
    norm_num [pairSum, Fin.sum_univ_succ]
  have hexp : pairSum (fun i j => 1 - (4 / 27 : ℝ) * ‖x i - x j‖ ^ 2) =
      36 - (4 / 27 : ℝ) * pairSum (fun i j => ‖x i - x j‖ ^ 2) := by
    simpa only [pairSum, Finset.sum_sub_distrib, ← Finset.mul_sum] using
      congrArg (fun a => a - (4 / 27 : ℝ) * pairSum (fun i j => ‖x i - x j‖ ^ 2)) hcount
  rw [hexp, pair_squared_distance_sum hx] at hsum
  nlinarith [sq_nonneg ‖∑ i, x i‖]

end ThomsonN9
