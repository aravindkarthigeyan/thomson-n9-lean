import ThomsonN9.LP.Schoenberg
import ThomsonN9.SDP.Counting
import ThomsonN9.SDP.GeometryBounds

namespace ThomsonN9

noncomputable def legendreExpansion (degrees : Finset Nat) (a0 : Real)
    (a : Nat → Real) (t : Real) : Real :=
  a0 + ∑ k ∈ degrees, a k * legendreKernel k t

theorem legendreExpansion_at_one (degrees : Finset Nat) (a0 : Real)
    (a : Nat → Real) :
    legendreExpansion degrees a0 a 1 = a0 + ∑ k ∈ degrees, a k := by
  simp [legendreExpansion, legendreKernel_at_one]

theorem legendreExpansion_double_sum (x : Configuration) (degrees : Finset Nat)
    (a0 : Real) (a : Nat → Real) :
    (∑ i : Fin 9, ∑ j : Fin 9,
      legendreExpansion degrees a0 a (inner Real (x i) (x j))) =
      81*a0 + ∑ k ∈ degrees, a k * legendreMoment x k := by
  simp only [legendreExpansion, Finset.sum_add_distrib]
  have hi (i : Fin 9) :
      (∑ j : Fin 9, ∑ k ∈ degrees, a k * legendreKernel k (inner Real (x i) (x j))) =
      ∑ k ∈ degrees, ∑ j : Fin 9, a k * legendreKernel k (inner Real (x i) (x j)) :=
    Finset.sum_comm
  simp_rw [hi]
  rw [Finset.sum_comm (s := Finset.univ) (t := degrees)]
  simp only [legendreMoment, Finset.mul_sum, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  ring

theorem kernel_double_sum_eq_pairs (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1) (h : Real → Real) :
    (∑ i : Fin 9, ∑ j : Fin 9, h (inner Real (x i) (x j))) =
      2*pairSum (fun i j => h (inner Real (x i) (x j))) + 9*h 1 := by
  classical
  have hpoint (i j : Fin 9) : h (inner Real (x i) (x j)) =
      (if i = j then 0 else h (inner Real (x i) (x j))) +
      (if i = j then h 1 else 0) := by
    by_cases hij : i = j
    · subst j
      simp [real_inner_self_eq_norm_sq, hx i]
    · simp [hij]
  calc
    _ = ∑ i : Fin 9, ∑ j : Fin 9,
        ((if i = j then 0 else h (inner Real (x i) (x j))) +
        (if i = j then h 1 else 0)) := by
      exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => hpoint i j
    _ = SDP.offDiagonalSum (fun i j => h (inner Real (x i) (x j))) + 9*h 1 := by
      simp only [Finset.sum_add_distrib]
      simp [SDP.offDiagonalSum]
    _ = _ := by
      rw [SDP.offDiagonalSum_eq_twice_pairSum _
        (fun i j => by rw [real_inner_comm (x i) (x j)])]

theorem legendreExpansion_pair_sum_le_energy (x : Configuration)
    (hx : IsSphereConfiguration x) (degrees : Finset Nat) (a0 : Real)
    (a : Nat → Real)
    (hminor : ∀ t : Real, -1 ≤ t → t < 1 →
      legendreExpansion degrees a0 a t ≤ SDP.coulombPotential t) :
    pairSum (fun i j => legendreExpansion degrees a0 a (inner Real (x i) (x j))) ≤
      coulombEnergy x := by
  apply Finset.sum_le_sum
  intro i _
  apply Finset.sum_le_sum
  intro j hj
  rw [SDP.pair_energy_eq_potential (x i) (x j) (hx.1 i) (hx.1 j)]
  exact hminor _ (abs_le.mp (SDP.unit_inner_abs_le_one _ _ (hx.1 i) (hx.1 j))).1
    (SDP.distinct_inner_lt_one hx (Finset.mem_Ioi.mp hj).ne)

theorem lp_energy_bound (x : Configuration) (hx : IsSphereConfiguration x)
    (degrees : Finset Nat) (a0 : Real) (a : Nat → Real)
    (ha : ∀ k ∈ degrees, 0 ≤ a k)
    (hminor : ∀ t : Real, -1 ≤ t → t < 1 →
      legendreExpansion degrees a0 a t ≤ SDP.coulombPotential t) :
    (81*a0 - 9*legendreExpansion degrees a0 a 1)/2 ≤ coulombEnergy x := by
  have hp := legendreExpansion_pair_sum_le_energy x hx degrees a0 a hminor
  have hs := kernel_double_sum_eq_pairs x hx.1 (legendreExpansion degrees a0 a)
  rw [legendreExpansion_double_sum] at hs
  have hn := weightedLegendreMoment_nonneg x hx.1 degrees a ha
  linarith

theorem lp_energy_bound_retaining_degree (x : Configuration) (hx : IsSphereConfiguration x)
    (degrees : Finset Nat) (a0 : Real) (a : Nat → Real)
    (ha : ∀ k ∈ degrees, 0 ≤ a k) (k : Nat) (hk : k ∈ degrees)
    (hminor : ∀ t : Real, -1 ≤ t → t < 1 →
      legendreExpansion degrees a0 a t ≤ SDP.coulombPotential t) :
    (81*a0 - 9*legendreExpansion degrees a0 a 1 + a k*legendreMoment x k)/2 ≤
      coulombEnergy x := by
  have hp := legendreExpansion_pair_sum_le_energy x hx degrees a0 a hminor
  have hs := kernel_double_sum_eq_pairs x hx.1 (legendreExpansion degrees a0 a)
  rw [legendreExpansion_double_sum] at hs
  have hn : a k*legendreMoment x k ≤ ∑ j ∈ degrees, a j*legendreMoment x j :=
    Finset.single_le_sum (fun j hj => mul_nonneg (ha j hj)
      (legendreMoment_nonneg x hx.1 j)) hk
  linarith

end ThomsonN9
