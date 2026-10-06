import ThomsonN9.SDP.Summation

/-! Ordered distinct triples and the exact nine-point energy normalization. -/

namespace ThomsonN9.SDP

noncomputable def distinctSum (T : Fin 9 → Fin 9 → Fin 9 → ℝ) : ℝ :=
  ∑ i, ∑ j, ∑ k, if i ≠ j ∧ i ≠ k ∧ j ≠ k then T i j k else 0

noncomputable def offDiagonalSum (h : Fin 9 → Fin 9 → ℝ) : ℝ :=
  ∑ i, ∑ j, if i = j then 0 else h i j

theorem distinctSum_add (A B : Fin 9 → Fin 9 → Fin 9 → ℝ) :
    distinctSum (fun i j k => A i j k + B i j k) = distinctSum A + distinctSum B := by
  classical
  simp only [distinctSum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  split_ifs <;> simp

theorem distinctSum_smul (a : ℝ) (T : Fin 9 → Fin 9 → Fin 9 → ℝ) :
    distinctSum (fun i j k => a * T i j k) = a * distinctSum T := by
  classical
  simp only [distinctSum, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  split_ifs <;> simp

theorem distinctSum_mono {A B : Fin 9 → Fin 9 → Fin 9 → ℝ}
    (h : ∀ i j k, i ≠ j → i ≠ k → j ≠ k → A i j k ≤ B i j k) :
    distinctSum A ≤ distinctSum B := by
  classical
  apply Finset.sum_le_sum
  intro i _
  apply Finset.sum_le_sum
  intro j _
  apply Finset.sum_le_sum
  intro k _
  split_ifs with hd
  · exact h i j k hd.1 hd.2.1 hd.2.2
  · exact le_rfl

theorem distinctSum_swap_first (T : Fin 9 → Fin 9 → Fin 9 → ℝ) :
    distinctSum (fun i j k => T j i k) = distinctSum T := by
  classical
  unfold distinctSum
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  have hp : (j ≠ i ∧ j ≠ k ∧ i ≠ k) ↔ (i ≠ j ∧ i ≠ k ∧ j ≠ k) := by
    simp only [ne_comm]
    tauto
  simp only [hp]

theorem distinctSum_swap_last (T : Fin 9 → Fin 9 → Fin 9 → ℝ) :
    distinctSum (fun i j k => T i k j) = distinctSum T := by
  classical
  unfold distinctSum
  apply Finset.sum_congr rfl
  intro i _
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  have hp : (i ≠ k ∧ i ≠ j ∧ k ≠ j) ↔ (i ≠ j ∧ i ≠ k ∧ j ≠ k) := by
    simp only [ne_comm]
    tauto
  simp only [hp]

theorem card_avoiding_two (i j : Fin 9) (hij : i ≠ j) :
    (Finset.univ.filter (fun k : Fin 9 => i ≠ k ∧ j ≠ k)).card = 7 := by
  classical
  have hs : Finset.univ.filter (fun k : Fin 9 => i ≠ k ∧ j ≠ k) =
      (Finset.univ.erase i).erase j := by
    ext k
    simp [ne_comm, and_comm]
  rw [hs, Finset.card_erase_of_mem, Finset.card_erase_of_mem]
  · norm_num
  · simp
  · simp [hij.symm]

theorem distinctSum_pair (h : Fin 9 → Fin 9 → ℝ) :
    distinctSum (fun i j _ => h i j) = 7 * offDiagonalSum h := by
  classical
  unfold distinctSum offDiagonalSum
  simp only [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  by_cases hij : i = j
  · subst j
    simp
  · simp only [hij, ne_eq, not_false_eq_true, true_and, if_false]
    rw [← Finset.sum_filter]
    simp only [Finset.sum_const, nsmul_eq_mul, card_avoiding_two i j hij]
    norm_num

theorem offDiagonalSum_eq_twice_pairSum (h : Fin 9 → Fin 9 → ℝ)
    (hs : ∀ i j, h i j = h j i) : offDiagonalSum h = 2 * pairSum h := by
  classical
  have hh := twice_pairSum (fun i j => if i = j then 0 else h i j)
    (fun i j => by
      by_cases hij : i = j
      · subst j
        rfl
      · simp only [if_neg hij, if_neg (Ne.symm hij)]
        exact hs i j) (fun i => by simp)
  have hp : pairSum (fun i j => if i = j then 0 else h i j) = pairSum h := by
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j hj
    simp [ne_of_lt (Finset.mem_Ioi.mp hj)]
  rw [hp] at hh
  exact hh.symm

theorem distinctSum_three_pairs (h : Fin 9 → Fin 9 → ℝ)
    (hs : ∀ i j, h i j = h j i) :
    distinctSum (fun i j k => h i j + h i k + h j k) = 42 * pairSum h := by
  have h₂ : distinctSum (fun i _ k => h i k) = distinctSum (fun i j _ => h i j) :=
    distinctSum_swap_last (fun i j _ => h i j)
  have h₃ : distinctSum (fun _ j k => h j k) = distinctSum (fun i _ k => h i k) :=
    distinctSum_swap_first (fun i _ k => h i k)
  rw [distinctSum_add, distinctSum_add, h₃, h₂, distinctSum_pair,
    offDiagonalSum_eq_twice_pairSum h hs]
  ring

theorem distinctSum_const (a : ℝ) : distinctSum (fun _ _ _ => a) = 504 * a := by
  rw [distinctSum_pair]
  have ho : offDiagonalSum (fun _ _ => a) = 72 * a := by
    rw [offDiagonalSum_eq_twice_pairSum _ (fun _ _ => rfl)]
    have hp : pairSum (fun _ _ => a) = 36 * a := by
      simp [pairSum, Fin.sum_univ_succ]
      ring
    rw [hp]
    ring
  rw [ho]
  ring

end ThomsonN9.SDP
