import ComparatorChallenges.ThomsonN7
import ThomsonN9.Completion

/-!
A bridge to the N=9 stretch-target statement from Hung Tran's N=7 challenge.
The upstream module is imported from its separately obtained repository.
No upstream placeholder theorem is used by this proof.
-/

set_option autoImplicit false

namespace ThomsonN9.UpstreamN7Bridge

def capPermutation : Equiv.Perm (Fin 9) :=
  (Equiv.swap 6 8).trans (Equiv.swap 6 7)

theorem height_bounds (r : CandidateParameter) :
    Real.sqrt (1 - (r : ℝ) ^ 2) ∈ Set.Ioo (0 : ℝ) 1 := by
  obtain ⟨hr, hr1⟩ := radius_bounds r
  constructor
  · exact Real.sqrt_pos.2 (by nlinarith)
  · exact (Real.sqrt_lt' (by norm_num)).2 (by nlinarith)

theorem radius_from_height (r : CandidateParameter) :
    Real.sqrt (1 - Real.sqrt (1 - (r : ℝ) ^ 2) ^ 2) = r := by
  obtain ⟨hr, hr1⟩ := radius_bounds r
  rw [Real.sq_sqrt (by nlinarith), sub_sub_cancel, Real.sqrt_sq (le_of_lt hr)]

theorem candidate_eq_upstream (r : CandidateParameter) (i : Fin 9) :
    ThomsonN7.triCapPrism (Real.sqrt (1 - (r : ℝ) ^ 2)) i =
      candidate r (capPermutation i) := by
  have c2 : Real.cos (2 * Real.pi / 3) = -(1 / 2 : ℝ) := by
    rw [show 2 * Real.pi / 3 = Real.pi - Real.pi / 3 by ring]
    simp [Real.cos_pi_div_three]
  have s2 : Real.sin (2 * Real.pi / 3) = Real.sqrt 3 / 2 := by
    rw [show 2 * Real.pi / 3 = Real.pi - Real.pi / 3 by ring]
    simp [Real.sin_pi_div_three]
  have c4 : Real.cos (2 * Real.pi * 2 / 3) = -(1 / 2 : ℝ) := by
    rw [show 2 * Real.pi * 2 / 3 = Real.pi / 3 + Real.pi by ring]
    simp [Real.cos_pi_div_three]
  have s4 : Real.sin (2 * Real.pi * 2 / 3) = -(Real.sqrt 3 / 2) := by
    rw [show 2 * Real.pi * 2 / 3 = Real.pi / 3 + Real.pi by ring]
    simp [Real.sin_pi_div_three]
  have cp : Real.cos (Real.pi / 3 + 2 * Real.pi / 3) = -1 := by
    rw [show Real.pi / 3 + 2 * Real.pi / 3 = Real.pi by ring]
    exact Real.cos_pi
  have sp : Real.sin (Real.pi / 3 + 2 * Real.pi / 3) = 0 := by
    rw [show Real.pi / 3 + 2 * Real.pi / 3 = Real.pi by ring]
    exact Real.sin_pi
  have c5 : Real.cos (Real.pi / 3 + 2 * Real.pi * 2 / 3) = (1 / 2 : ℝ) := by
    rw [show Real.pi / 3 + 2 * Real.pi * 2 / 3 = -(Real.pi / 3) + 2 * Real.pi by ring]
    simp [Real.cos_pi_div_three]
  have s5 : Real.sin (Real.pi / 3 + 2 * Real.pi * 2 / 3) = -(Real.sqrt 3 / 2) := by
    rw [show Real.pi / 3 + 2 * Real.pi * 2 / 3 = -(Real.pi / 3) + 2 * Real.pi by ring]
    simp [Real.sin_pi_div_three]
  ext j
  fin_cases i <;> fin_cases j <;>
    norm_num [ThomsonN7.triCapPrism, ThomsonN7.cyl, candidate, candidateAt, vec,
      capPermutation, Equiv.swap_apply_def, radius_from_height, c2, s2, c4, s4,
      cp, sp, c5, s5, Real.cos_pi_div_three, Real.sin_pi_div_three] <;> ring

theorem candidate_energy_eq_upstream (r : CandidateParameter) :
    ThomsonN7.coulombEnergy (ThomsonN7.triCapPrism (Real.sqrt (1 - (r : ℝ) ^ 2))) =
      coulombEnergy (candidate r) := by
  change coulombEnergy _ = _
  have h : ThomsonN7.triCapPrism (Real.sqrt (1 - (r : ℝ) ^ 2)) =
      fun i => candidate r (capPermutation i) := funext (candidate_eq_upstream r)
  rw [h]
  exact relabel_energy (candidate r) capPermutation

theorem thomson_nine :
    ∃ z ∈ Set.Ioo (0 : ℝ) 1,
      ∀ x ∈ ThomsonN7.SphereConfig 9,
        ThomsonN7.coulombEnergy (ThomsonN7.triCapPrism z) ≤ ThomsonN7.coulombEnergy x := by
  refine ⟨Real.sqrt (1 - (optimalParameter : ℝ) ^ 2), height_bounds optimalParameter, ?_⟩
  intro x hx
  rw [candidate_energy_eq_upstream]
  exact ThomsonN9.thomson_nine optimalParameter x hx

#print axioms candidate_eq_upstream
#print axioms candidate_energy_eq_upstream
#print axioms thomson_nine

-- This audit inspects declaration types only, never an upstream proof value.
run_cmd Lean.Elab.Command.liftTermElabM do
  let upstream ← Lean.getConstInfo `ThomsonN7.thomson_nine
  let bridge ← Lean.getConstInfo `ThomsonN9.UpstreamN7Bridge.thomson_nine
  unless ← Lean.Meta.isDefEq upstream.type bridge.type do
    throwError "The bridge type does not match the upstream N=9 target."
  Lean.logInfo "PASS: bridge declaration type is definitionally equal to the upstream N=9 target."

end ThomsonN9.UpstreamN7Bridge
