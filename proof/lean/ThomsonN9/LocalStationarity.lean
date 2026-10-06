import ThomsonN9.CandidateEnergy

/-! Algebraic force balance, without assuming the full configuration stationary. -/

namespace ThomsonN9

def orbitWeight (a b c d e f : ℝ) (i j : Fin 9) : ℝ :=
  if i = j then 0
  else if (i : ℕ) < 6 ∧ (j : ℕ) < 6 then
    if (i : ℕ) % 3 = (j : ℕ) % 3 then b
    else if (i : ℕ) / 3 = (j : ℕ) / 3 then a
    else c
  else if 6 ≤ (i : ℕ) ∧ 6 ≤ (j : ℕ) then f
  else if (i : ℕ) % 3 = (j : ℕ) % 3 then d
  else e

set_option maxHeartbeats 1200000 in
theorem orbit_force_balance (r a b c d e f : ℝ)
    (h : -3*r*a+r*c-d+e+2*r*b = 0) (i : Fin 9) :
    (∑ j, orbitWeight a b c d e f i j • (candidateAt r j-candidateAt r i)) =
      (if (i : ℕ) < 6 then -2*b-4*c-d-2*e
       else -3*f-2*(1+r)*d-(4-2*r)*e) • candidateAt r i := by
  have hs : (Real.sqrt 3 / 2)*(-3*r*a+r*c-d+e+2*r*b) = 0 := by rw [h]; ring
  fin_cases i <;> ext k <;> fin_cases k <;>
    norm_num [orbitWeight, candidateAt, vec, Fin.sum_univ_succ] <;>
    nlinarith

theorem candidate_force_relation (r : CandidateParameter) :
    -3*(r : ℝ)*(Real.sqrt 3*(r : ℝ))⁻¹^3
      +(r : ℝ)*(Real.sqrt (4-(r : ℝ)^2))⁻¹^3
      -(Real.sqrt (2+2*(r : ℝ)))⁻¹^3
      +(Real.sqrt (2-(r : ℝ)))⁻¹^3
      +2*(r : ℝ)*(2*Real.sqrt (1-(r : ℝ)^2))⁻¹^3 = 0 := by
  obtain ⟨hr, hr1⟩ := radius_bounds r
  have h3 : Real.sqrt (3 : ℝ)^2 = 3 := Real.sq_sqrt (by norm_num)
  have hs : Real.sqrt (3 : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (by norm_num)).ne'
  have hz : Real.sqrt (1-(r : ℝ)^2) ≠ 0 :=
    (Real.sqrt_pos.mpr (by nlinarith)).ne'
  have h4 : Real.sqrt (4-(r : ℝ)^2) ≠ 0 :=
    (Real.sqrt_pos.mpr (by nlinarith)).ne'
  have hp : Real.sqrt (2+2*(r : ℝ)) ≠ 0 :=
    (Real.sqrt_pos.mpr (by positivity)).ne'
  have hm : Real.sqrt (2-(r : ℝ)) ≠ 0 :=
    (Real.sqrt_pos.mpr (by linarith)).ne'
  have hfirst : -3*(r : ℝ)*(Real.sqrt 3*(r : ℝ))⁻¹^3 =
      (-2*Real.sqrt 3/(r : ℝ)^2)/6 := by
    field_simp
    nlinarith [h3]
  rw [hfirst]
  have h := r.property.2.2
  unfold stationarity at h
  convert congrArg (fun x : ℝ => x/6) h using 1 <;>
    field_simp <;> ring

noncomputable def coulombForce (x : Configuration) (i : Fin 9) : R3 :=
  ∑ j, (‖x i-x j‖)⁻¹^3 • (x j-x i)

theorem candidate_force_radial (r : CandidateParameter) (i : Fin 9) :
    ∃ lambda : ℝ, coulombForce (candidate r) i = lambda • candidate r i := by
  let a := (Real.sqrt 3*(r : ℝ))⁻¹^3
  let b := (2*Real.sqrt (1-(r : ℝ)^2))⁻¹^3
  let c := (Real.sqrt (4-(r : ℝ)^2))⁻¹^3
  let d := (Real.sqrt (2+2*(r : ℝ)))⁻¹^3
  let e := (Real.sqrt (2-(r : ℝ)))⁻¹^3
  let f := (Real.sqrt 3)⁻¹^3
  have hweight (i j : Fin 9) : (‖candidate r i-candidate r j‖)⁻¹^3 =
      orbitWeight a b c d e f i j := by
    change (‖candidateAt r i-candidateAt r j‖)⁻¹^3 = _
    rw [candidate_distance (radius_bounds r).1 (radius_bounds r).2]
    unfold candidateDistance orbitWeight
    split_ifs <;> simp_all [a, b, c, d, e, f, mul_pow, mul_inv]
  refine ⟨if (i : ℕ) < 6 then -2*b-4*c-d-2*e
    else -3*f-2*(1+(r : ℝ))*d-(4-2*(r : ℝ))*e, ?_⟩
  unfold coulombForce
  simp_rw [hweight]
  exact orbit_force_balance r a b c d e f (candidate_force_relation r) i

end ThomsonN9
