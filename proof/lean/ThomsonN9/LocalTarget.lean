import ThomsonN9.Alignment
import ThomsonN9.LocalCoercivity
import ThomsonN9.Endgame

/-! The local target follows from the explicit candidate matrix certificate. -/

set_option autoImplicit false

namespace ThomsonN9

theorem inverse_alignment_distance (x p : Configuration) (Q : R3 ≃ₗᵢ[ℝ] R3) :
    (∑ i, ‖Q.symm (x i)-p i‖^2) = ∑ i, ‖x i-Q (p i)‖^2 := by
  apply Finset.sum_congr rfl
  intro i _
  have h : Q.symm (x i-Q (p i)) = Q.symm (x i)-p i := by
    rw [Q.symm.map_sub, Q.symm_apply_apply]
  rw [← h, Q.symm.norm_map]

theorem quantitativeLocalTarget_of_augmentedHessian
    (hpositive : ∀ r : CandidateParameter,
      (constrainedHessian (candidate r)+
        rotationColumns (candidate r)*(rotationColumns (candidate r)).transpose-
        (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)).PosSemidef) :
    QuantitativeLocalTarget := by
  intro r x hx hnear
  obtain ⟨T, hT⟩ := hnear
  obtain ⟨Q, hQ⟩ := exists_minimal_alignment x (candidate r)
  let y : Configuration := fun i => Q (x i)
  have hy : ∀ i, ‖y i‖ = 1 := fun i => by simpa only [y, Q.norm_map] using hx.1 i
  have hmin : IsMinimalAlignment y (candidate r) := by
    intro U
    simpa only [LinearIsometryEquiv.trans_apply, y] using hQ (Q.trans U)
  have hbound : (∑ i, ‖y i-candidate r i‖^2) ≤ (1/500 : ℝ)^2 := by
    have h := hQ T.symm
    rw [inverse_alignment_distance] at h
    exact h.trans hT
  let rho : ℝ := Real.sqrt (∑ i, ‖y i-candidate r i‖^2)
  have hr : 0 ≤ rho := Real.sqrt_nonneg _
  have hs : ∑ i, ‖y i-candidate r i‖^2 = rho^2 :=
    (Real.sq_sqrt (Finset.sum_nonneg fun _ _ => sq_nonneg _)).symm
  have hr1 : rho ≤ 1/500 := by nlinarith
  have hskew : ∀ a b : Fin 3,
      (∑ i, ((y i-candidate r i) a*candidate r i b-
        (y i-candidate r i) b*candidate r i a)) = 0 := by
    intro a b
    simpa only [PiLp.sub_apply] using minimal_alignment_displacement_skew_zero hmin a b
  have he : coulombEnergy y = coulombEnergy x :=
    congruent_energy ⟨Q, Equiv.refl _, fun _ => rfl⟩
  have hgap := candidate_local_energy_gap r y hy hr hr1 hs hskew (hpositive r)
  refine ⟨?_, ?_⟩
  · nlinarith [sq_nonneg rho]
  · intro hequal
    have hyle : coulombEnergy y ≤ coulombEnergy (candidate r) := by rw [he, hequal]
    have hyexact := candidate_local_equality r y hy hr hr1 hs hskew (hpositive r) hyle
    refine ⟨Q.symm, Equiv.refl _, ?_⟩
    intro i
    have hi := congr_fun hyexact i
    have hi' := congrArg Q.symm hi
    simpa only [y, Q.symm_apply_apply, Equiv.refl_apply] using hi'

end ThomsonN9
