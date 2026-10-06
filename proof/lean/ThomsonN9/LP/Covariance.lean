import ThomsonN9.LP.EnergyBound

namespace ThomsonN9

noncomputable def covarianceEntry (x : Configuration) (a b : Fin 3) : Real :=
  ∑ i : Fin 9, x i a * x i b

noncomputable def covarianceDeviation (x : Configuration) : Real :=
  ∑ a : Fin 3, ∑ b : Fin 3,
    (covarianceEntry x a b - if a = b then 3 else 0)^2

theorem inner_eq_coordinate_sum (x y : R3) :
    inner Real x y = ∑ a : Fin 3, x a * y a := by
  simp only [PiLp.inner_apply, RCLike.inner_apply, conj_trivial]
  exact Finset.sum_congr rfl fun a _ => by ring

theorem gram_squared_sum_eq_covariance (x : Configuration) :
    (∑ i : Fin 9, ∑ j : Fin 9, (inner Real (x i) (x j))^2) =
      ∑ a : Fin 3, ∑ b : Fin 3, (covarianceEntry x a b)^2 := by
  have h1 (i j : Fin 9) : (inner Real (x i) (x j))^2 =
      ∑ a : Fin 3, ∑ b : Fin 3, (x i a*x i b)*(x j a*x j b) := by
    rw [inner_eq_coordinate_sum, sq, Finset.sum_mul_sum]
    exact Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun b _ => by ring
  have h2 (a b : Fin 3) : (covarianceEntry x a b)^2 =
      ∑ i : Fin 9, ∑ j : Fin 9, (x i a*x i b)*(x j a*x j b) := by
    rw [covarianceEntry, sq, Finset.sum_mul_sum]
  simp only [h1, h2]
  exact Delsarte.Sphere.sum_comm_pairs _

theorem legendreMoment_two_covariance (x : Configuration) :
    legendreMoment x 2 =
      (3*(∑ a : Fin 3, ∑ b : Fin 3, (covarianceEntry x a b)^2) - 81)/2 := by
  simp only [legendreMoment, legendreKernel_two, ← Finset.sum_div,
    Finset.sum_sub_distrib, ← Finset.mul_sum]
  rw [gram_squared_sum_eq_covariance]
  norm_num

theorem covariance_trace (x : Configuration) (hx : ∀ i, ‖x i‖ = 1) :
    (∑ a : Fin 3, covarianceEntry x a a) = 9 := by
  unfold covarianceEntry
  rw [Finset.sum_comm]
  have hi (i : Fin 9) : (∑ a : Fin 3, x i a * x i a) = 1 := by
    rw [← inner_eq_coordinate_sum, real_inner_self_eq_norm_sq, hx i]
    norm_num
  simp [hi]

theorem covariance_deviation_identity (x : Configuration) (hx : ∀ i, ‖x i‖ = 1) :
    covarianceDeviation x =
      (∑ a : Fin 3, ∑ b : Fin 3, (covarianceEntry x a b)^2) - 27 := by
  have ht := covariance_trace x hx
  simp only [Fin.sum_univ_three] at ht
  simp only [covarianceDeviation, Fin.sum_univ_three]
  norm_num
  nlinarith

theorem legendreMoment_two_deviation (x : Configuration) (hx : ∀ i, ‖x i‖ = 1) :
    legendreMoment x 2 = (3/2 : Real)*covarianceDeviation x := by
  rw [legendreMoment_two_covariance, covariance_deviation_identity x hx]
  ring

theorem lp_energy_bound_covariance (x : Configuration) (hx : IsSphereConfiguration x)
    (degrees : Finset Nat) (a0 : Real) (a : Nat → Real)
    (ha : ∀ k ∈ degrees, 0 ≤ a k) (h2 : 2 ∈ degrees)
    (hminor : ∀ t : Real, -1 ≤ t → t < 1 →
      legendreExpansion degrees a0 a t ≤ SDP.coulombPotential t) :
    (81*a0 - 9*legendreExpansion degrees a0 a 1)/2 +
      (3/4 : Real)*a 2*covarianceDeviation x ≤ coulombEnergy x := by
  have h := lp_energy_bound_retaining_degree x hx degrees a0 a ha 2 h2 hminor
  rw [legendreMoment_two_deviation x hx.1] at h
  linarith

end ThomsonN9
