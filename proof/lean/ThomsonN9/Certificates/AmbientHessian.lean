import ThomsonN9.Certificates.AmbientKernelAssembly
import ThomsonN9.Certificates.AmbientKernelBounds
import ThomsonN9.Certificates.HessianTransport

/-! Identify the checked arithmetic circuit with the candidate's augmented Hessian. -/

namespace ThomsonN9.Certificates.AmbientKernel

open IntervalCircuit

theorem evaluated_hessian_eq (r : ℝ) :
    matrixValues (value (parameterInputs r) nodes) 27 hessianIndices =
      flatAugmentedHessian (candidateAt r) (7/50) := by
  ext i j
  obtain ⟨⟨pi,a⟩,rfl⟩ := pointMajorEquiv.surjective i
  obtain ⟨⟨pj,b⟩,rfl⟩ := pointMajorEquiv.surjective j
  change value (parameterInputs r) nodes
    (hessianIndices (pointMajorEquiv (pi,a)).val (pointMajorEquiv (pj,b)).val) = _
  rw [pointMajorEquiv_val, pointMajorEquiv_val, flatAugmentedHessian_apply]
  exact shifted_hessian_entry_sound r (pi,a) (pj,b)

theorem candidate_augmented_hessian_posSemidef (r : CandidateParameter) :
    (constrainedHessian (candidate r) +
      rotationColumns (candidate r)*(rotationColumns (candidate r)).transpose -
        (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)).PosSemidef := by
  have hA : (matrixValues (value (parameterInputs r) nodes) 27 hessianIndices).IsHermitian := by
    rw [evaluated_hessian_eq]
    exact flatAugmentedHessian_isHermitian _ _
  apply augmentedHessian_posSemidef_of_flattened_posDef (candidate r) _ (flattened_posDef r hA)
  intro i j a b
  change value (parameterInputs r) nodes
    (hessianIndices (pointMajorEquiv (i,a)).val (pointMajorEquiv (j,b)).val) = _
  rw [pointMajorEquiv_val, pointMajorEquiv_val]
  exact shifted_hessian_entry_sound r (i,a) (j,b)

#print axioms evaluated_hessian_eq
#print axioms candidate_augmented_hessian_posSemidef

end ThomsonN9.Certificates.AmbientKernel
