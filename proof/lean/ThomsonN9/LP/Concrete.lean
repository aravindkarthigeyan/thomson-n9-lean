import ThomsonN9.LP.Covariance

namespace ThomsonN9.LPConcrete

noncomputable section

def covarianceDegrees : Finset Nat := {1, 2, 3, 7, 12}

def covarianceCoefficient (k : Nat) : Real :=
  match k with
  | 1 => 116052895813/250000000000
  | 2 => 6404422103/31250000000
  | 3 => 8242861449/125000000000
  | 7 => 3167096277/500000000000
  | 12 => 486771579/1000000000000
  | _ => 0

noncomputable def covarianceMinorant (t : Real) : Real :=
  legendreExpansion covarianceDegrees (161484410321/200000000000)
    covarianceCoefficient t

def separationDegrees : Finset Nat := {1, 2, 3, 7, 12, 17, 22, 27}

def separationCoefficient (k : Nat) : Real :=
  match k with
  | 1 => 230016480181/500000000000
  | 2 => 200888085899/1000000000000
  | 3 => 63087598053/1000000000000
  | 7 => 2838858731/500000000000
  | 12 => 490951549/1000000000000
  | 17 => 21702641/40000000000
  | 22 => 17715331/200000000000
  | 27 => 134439481/1000000000000
  | _ => 0

noncomputable def separationMinorant (t : Real) : Real :=
  legendreExpansion separationDegrees (201511290409/250000000000)
    separationCoefficient t

def energyCutoff : Real := 6439996633/250000000
def covarianceBound : Real := 51457135199103/2000000000000
def separationBound : Real := 25728382789209/1000000000000

theorem covarianceCoefficient_nonneg (k : Nat) (hk : k ∈ covarianceDegrees) :
    0 ≤ covarianceCoefficient k := by
  simp only [covarianceDegrees, Finset.mem_insert, Finset.mem_singleton] at hk
  rcases hk with rfl | rfl | rfl | rfl | rfl <;>
    norm_num [covarianceCoefficient]

theorem separationCoefficient_nonneg (k : Nat) (hk : k ∈ separationDegrees) :
    0 ≤ separationCoefficient k := by
  simp only [separationDegrees, Finset.mem_insert, Finset.mem_singleton] at hk
  rcases hk with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;>
    norm_num [separationCoefficient]

theorem covarianceBound_formula :
    (81*(161484410321/200000000000 : Real)-9*covarianceMinorant 1)/2 =
      covarianceBound := by
  rw [covarianceMinorant, legendreExpansion_at_one]
  norm_num [covarianceDegrees, covarianceCoefficient, covarianceBound]

theorem separationBound_formula :
    (81*(201511290409/250000000000 : Real)-9*separationMinorant 1)/2 =
      separationBound := by
  rw [separationMinorant, legendreExpansion_at_one]
  norm_num [separationDegrees, separationCoefficient, separationBound]

theorem covariance_energy_lower (x : Configuration) (hx : IsSphereConfiguration x)
    (hminor : ∀ t : Real, -1 ≤ t → t < 1 →
      covarianceMinorant t ≤ SDP.coulombPotential t) :
    covarianceBound+(3/4 : Real)*(6404422103/31250000000)*covarianceDeviation x ≤
      coulombEnergy x := by
  have h := lp_energy_bound_covariance x hx covarianceDegrees
    (161484410321/200000000000) covarianceCoefficient covarianceCoefficient_nonneg
    (by simp [covarianceDegrees]) hminor
  change (81*(161484410321/200000000000 : Real)-9*covarianceMinorant 1)/2 +
    (3/4 : Real)*covarianceCoefficient 2*covarianceDeviation x ≤ coulombEnergy x at h
  rw [covarianceBound_formula] at h
  simpa [covarianceCoefficient] using h

theorem covariance_lt_quarter (x : Configuration) (hx : IsSphereConfiguration x)
    (henergy : coulombEnergy x ≤ energyCutoff)
    (hminor : ∀ t : Real, -1 ≤ t → t < 1 →
      covarianceMinorant t ≤ SDP.coulombPotential t) :
    covarianceDeviation x < (1/4 : Real) := by
  have h := covariance_energy_lower x hx hminor
  norm_num [covarianceBound, energyCutoff] at h henergy
  linarith

theorem polynomial_pair_sum_lower (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (degrees : Finset Nat) (a0 : Real) (a : Nat → Real)
    (ha : ∀ k ∈ degrees, 0 ≤ a k) :
    (81*a0-9*legendreExpansion degrees a0 a 1)/2 ≤
      pairSum (fun i j => legendreExpansion degrees a0 a (inner Real (x i) (x j))) := by
  have hs := kernel_double_sum_eq_pairs x hx (legendreExpansion degrees a0 a)
  rw [legendreExpansion_double_sum] at hs
  have hn := weightedLegendreMoment_nonneg x hx degrees a ha
  linarith

theorem pair_slack_le_energy_sub_bound (x : Configuration) (hx : IsSphereConfiguration x)
    (degrees : Finset Nat) (a0 : Real) (a : Nat → Real)
    (ha : ∀ k ∈ degrees, 0 ≤ a k)
    (hminor : ∀ t : Real, -1 ≤ t → t < 1 →
      legendreExpansion degrees a0 a t ≤ SDP.coulombPotential t)
    (i j : Fin 9) (hij : i < j) :
    SDP.coulombPotential (inner Real (x i) (x j)) -
      legendreExpansion degrees a0 a (inner Real (x i) (x j)) ≤
      coulombEnergy x-(81*a0-9*legendreExpansion degrees a0 a 1)/2 := by
  let slack (i j : Fin 9) : Real := SDP.coulombPotential (inner Real (x i) (x j)) -
    legendreExpansion degrees a0 a (inner Real (x i) (x j))
  have hn (i j : Fin 9) (hij : i < j) : 0 ≤ slack i j := by
    apply sub_nonneg.mpr
    exact hminor _ (abs_le.mp (SDP.unit_inner_abs_le_one _ _ (hx.1 i) (hx.1 j))).1
      (SDP.distinct_inner_lt_one hx hij.ne)
  have hs : slack i j ≤ pairSum slack := by
    exact (Finset.single_le_sum (fun k hk => hn i k (Finset.mem_Ioi.mp hk))
      (Finset.mem_Ioi.mpr hij)).trans
      (Finset.single_le_sum (fun k _ => Finset.sum_nonneg fun l hl =>
        hn k l (Finset.mem_Ioi.mp hl)) (Finset.mem_univ i))
  have hid : pairSum slack = coulombEnergy x-
      pairSum (fun i j => legendreExpansion degrees a0 a (inner Real (x i) (x j))) := by
    unfold pairSum coulombEnergy
    simp only [slack, Finset.sum_sub_distrib]
    congr 1
    exact Finset.sum_congr rfl fun k _ => Finset.sum_congr rfl fun l _ =>
      (SDP.pair_energy_eq_potential (x k) (x l) (hx.1 k) (hx.1 l)).symm
  rw [hid] at hs
  have hb := polynomial_pair_sum_lower x hx.1 degrees a0 a ha
  exact hs.trans (sub_le_sub_left hb _)

theorem inner_lt_separation (x : Configuration) (hx : IsSphereConfiguration x)
    (henergy : coulombEnergy x ≤ energyCutoff)
    (hminor : ∀ t : Real, -1 ≤ t → t < 1 →
      separationMinorant t ≤ SDP.coulombPotential t)
    (htail : ∀ t : Real, (5593/10000 : Real) ≤ t → t < 1 →
      separationMinorant t+(energyCutoff-separationBound)+(1/100000000 : Real) ≤
        SDP.coulombPotential t)
    (i j : Fin 9) (hij : i ≠ j) :
    inner Real (x i) (x j) < (5593/10000 : Real) := by
  have hord (i j : Fin 9) (hij : i < j) :
      inner Real (x i) (x j) < (5593/10000 : Real) := by
    by_contra h
    have ht := htail _ (le_of_not_gt h) (SDP.distinct_inner_lt_one hx hij.ne)
    have hs := pair_slack_le_energy_sub_bound x hx separationDegrees
      (201511290409/250000000000) separationCoefficient separationCoefficient_nonneg
      hminor i j hij
    change SDP.coulombPotential (inner Real (x i) (x j)) -
      separationMinorant (inner Real (x i) (x j)) ≤
      coulombEnergy x-(81*(201511290409/250000000000 : Real)-9*separationMinorant 1)/2 at hs
    rw [separationBound_formula] at hs
    linarith
  rcases lt_or_gt_of_ne hij with h | h
  · exact hord i j h
  · rw [real_inner_comm]
    exact hord j i h

end
end ThomsonN9.LPConcrete

