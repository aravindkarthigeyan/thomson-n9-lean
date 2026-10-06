import ThomsonN9.ParameterExists
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.Deriv.Add

namespace ThomsonN9

theorem symmetricEnergy_hasDerivAt {r : ℝ} (hr : 0 < r) (hr1 : r < 1) :
    HasDerivAt symmetricEnergy (stationarity r) r := by
  have h1 : 0 < 1 - r ^ 2 := by nlinarith
  have h2 : 0 < 4 - r ^ 2 := by nlinarith
  have h3 : 0 < 2 + 2 * r := by positivity
  have h4 : 0 < 2 - r := by linarith
  have hs1 : Real.sqrt (1 - r ^ 2) ≠ 0 := (Real.sqrt_pos.mpr h1).ne'
  have hs2 : Real.sqrt (4 - r ^ 2) ≠ 0 := (Real.sqrt_pos.mpr h2).ne'
  have hs3 : Real.sqrt (2 + 2 * r) ≠ 0 := (Real.sqrt_pos.mpr h3).ne'
  have hs4 : Real.sqrt (2 - r) ≠ 0 := (Real.sqrt_pos.mpr h4).ne'
  have q1 : HasDerivAt (fun t : ℝ => 1 - t ^ 2) (-2 * r) r := by
    convert! HasDerivAt.sub (hasDerivAt_const r (1 : ℝ)) ((hasDerivAt_id r).pow 2) using 1 <;> norm_num
  have q2 : HasDerivAt (fun t : ℝ => 4 - t ^ 2) (-2 * r) r := by
    convert! HasDerivAt.sub (hasDerivAt_const r (4 : ℝ)) ((hasDerivAt_id r).pow 2) using 1 <;> norm_num
  have q3 : HasDerivAt (fun t : ℝ => 2 + 2 * t) 2 r := by
    convert! HasDerivAt.add (hasDerivAt_const r (2 : ℝ)) ((hasDerivAt_id r).const_mul 2) using 1 <;> norm_num
  have q4 : HasDerivAt (fun t : ℝ => 2 - t) (-1) r := by
    convert! HasDerivAt.sub (hasDerivAt_const r (2 : ℝ)) (hasDerivAt_id r) using 1 <;> norm_num
  have d0 := ((hasDerivAt_id r).inv hr.ne').const_mul (2 * Real.sqrt 3)
  have d1 := ((q1.sqrt h1.ne').const_mul 2).inv
    (mul_ne_zero (by norm_num) hs1)
  have d2 := (q2.sqrt h2.ne').inv hs2
  have d3 := (q3.sqrt h3.ne').inv hs3
  have d4 := (q4.sqrt h4.ne').inv hs4
  have dt := HasDerivAt.add (HasDerivAt.add (HasDerivAt.add (HasDerivAt.add
    (HasDerivAt.add (hasDerivAt_const r (Real.sqrt 3)) d0) (d1.const_mul 3))
    (d2.const_mul 6)) (d3.const_mul 6)) (d4.const_mul 12)
  simp only [Pi.inv_apply, id_eq] at dt
  convert dt using 1
  · funext t
    simp [symmetricEnergy, div_eq_mul_inv]
  · unfold stationarity
    field_simp
    <;> ring

theorem candidate_symmetric_stationary (r : CandidateParameter) :
    HasDerivAt symmetricEnergy 0 r := by
  obtain ⟨hr, hr1⟩ := radius_bounds r
  simpa only [r.property.2.2] using symmetricEnergy_hasDerivAt hr hr1

end ThomsonN9
