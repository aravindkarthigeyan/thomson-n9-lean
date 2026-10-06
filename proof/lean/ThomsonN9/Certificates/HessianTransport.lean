import ThomsonN9.Certificates.ZeroPenalty
import ThomsonN9.HessianSymmetry
import Mathlib.Logic.Equiv.Fin.Basic

/-! Point-major indexing and positivity transport for the actual ambient Hessian. -/

set_option autoImplicit false

namespace ThomsonN9.Certificates

open Matrix

def pointMajorEquiv : (Fin 9 × Fin 3) ≃ Fin 27 := finProdFinEquiv

@[simp] theorem pointMajorEquiv_val (i : Fin 9) (a : Fin 3) :
    (pointMajorEquiv (i, a)).val = 3*i.val+a.val := by
  change a.val+3*i.val = 3*i.val+a.val
  omega

theorem pointMajorEquiv_apply (i : Fin 9) (a : Fin 3) :
    pointMajorEquiv (i, a) = ⟨3*i.val+a.val, by omega⟩ := by
  apply Fin.ext
  exact pointMajorEquiv_val i a

@[simp] theorem pointMajorEquiv_symm_fst (k : Fin 27) :
    (pointMajorEquiv.symm k).1.val = k.val/3 := rfl

@[simp] theorem pointMajorEquiv_symm_snd (k : Fin 27) :
    (pointMajorEquiv.symm k).2.val = k.val%3 := rfl

def unflattenMatrix (A : Matrix (Fin 27) (Fin 27) ℝ) :
    Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ :=
  A.submatrix pointMajorEquiv pointMajorEquiv

def flattenMatrix (H : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ) :
    Matrix (Fin 27) (Fin 27) ℝ :=
  H.submatrix pointMajorEquiv.symm pointMajorEquiv.symm

theorem unflattenMatrix_apply (A : Matrix (Fin 27) (Fin 27) ℝ)
    (i j : Fin 9) (a b : Fin 3) :
    unflattenMatrix A (i, a) (j, b) =
      A ⟨3*i.val+a.val, by omega⟩ ⟨3*j.val+b.val, by omega⟩ := by
  change A (pointMajorEquiv (i, a)) (pointMajorEquiv (j, b)) = _
  rw [pointMajorEquiv_apply, pointMajorEquiv_apply]

@[simp] theorem unflatten_flatten (H : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ) :
    unflattenMatrix (flattenMatrix H) = H := by
  ext i j
  simp [unflattenMatrix, flattenMatrix, Matrix.submatrix]

@[simp] theorem flatten_unflatten (A : Matrix (Fin 27) (Fin 27) ℝ) :
    flattenMatrix (unflattenMatrix A) = A := by
  ext i j
  simp [unflattenMatrix, flattenMatrix, Matrix.submatrix]

theorem unflatten_posSemidef_iff (A : Matrix (Fin 27) (Fin 27) ℝ) :
    (unflattenMatrix A).PosSemidef ↔ A.PosSemidef :=
  Matrix.posSemidef_submatrix_equiv pointMajorEquiv

theorem unflatten_posDef_iff (A : Matrix (Fin 27) (Fin 27) ℝ) :
    (unflattenMatrix A).PosDef ↔ A.PosDef := by
  constructor
  · intro h
    have hh := h.submatrix pointMajorEquiv.symm.injective
    have heq : (unflattenMatrix A).submatrix pointMajorEquiv.symm pointMajorEquiv.symm = A := by
      ext i j
      change A (pointMajorEquiv (pointMajorEquiv.symm i))
        (pointMajorEquiv (pointMajorEquiv.symm j)) = A i j
      rw [pointMajorEquiv.apply_symm_apply, pointMajorEquiv.apply_symm_apply]
    rw [heq] at hh
    exact hh
  · intro h
    exact h.submatrix pointMajorEquiv.injective

noncomputable def flatAugmentedHessian (p : Configuration) (c : ℝ) :
    Matrix (Fin 27) (Fin 27) ℝ :=
  flattenMatrix (constrainedHessian p+rotationColumns p*(rotationColumns p).transpose-
    c • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ))

theorem flatAugmentedHessian_apply (p : Configuration) (c : ℝ)
    (i j : Fin 9) (a b : Fin 3) :
    flatAugmentedHessian p c (pointMajorEquiv (i, a)) (pointMajorEquiv (j, b)) =
      (constrainedHessian p+rotationColumns p*(rotationColumns p).transpose-
        c • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)) (i, a) (j, b) := by
  let H := constrainedHessian p+rotationColumns p*(rotationColumns p).transpose-
    c • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)
  change H (pointMajorEquiv.symm (pointMajorEquiv (i, a)))
    (pointMajorEquiv.symm (pointMajorEquiv (j, b))) = H (i, a) (j, b)
  rw [pointMajorEquiv.symm_apply_apply, pointMajorEquiv.symm_apply_apply]

theorem flatAugmentedHessian_isHermitian (p : Configuration) (c : ℝ) :
    (flatAugmentedHessian p c).IsHermitian :=
  (augmentedHessian_isHermitian p c).submatrix pointMajorEquiv.symm

theorem augmentedHessian_posSemidef_of_flattened_posDef
    (p : Configuration) (A : Matrix (Fin 27) (Fin 27) ℝ) (hA : A.PosDef)
    (hentry : ∀ (i j : Fin 9) (a b : Fin 3),
      A (pointMajorEquiv (i, a)) (pointMajorEquiv (j, b)) =
        (constrainedHessian p+rotationColumns p*(rotationColumns p).transpose-
          (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ))
            (i, a) (j, b)) :
    (constrainedHessian p+rotationColumns p*(rotationColumns p).transpose-
      (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)).PosSemidef := by
  have heq : unflattenMatrix A =
      constrainedHessian p+rotationColumns p*(rotationColumns p).transpose-
        (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ) := by
    ext ⟨i, a⟩ ⟨j, b⟩
    exact hentry i j a b
  rw [← heq]
  exact (unflatten_posSemidef_iff A).2 hA.posSemidef

theorem augmentedHessian_posSemidef_of_congruence_enclosures
    (p : Configuration) (C : Matrix (Fin 27) (Fin 27) ℝ)
    (hupper : ∀ i j, j < i → C i j = 0) (hdiag : ∀ i, C i i = 1)
    (henclose : ∀ i j, (zeroPenaltyCongruenceBounds i j).Contains
      ((star C*flatAugmentedHessian p (7/50)*C) i j)) :
    (constrainedHessian p+rotationColumns p*(rotationColumns p).transpose-
      (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)).PosSemidef := by
  have hA := zeroPenalty_posDef_of_congruence_enclosures
    (flatAugmentedHessian p (7/50)) C (flatAugmentedHessian_isHermitian p (7/50))
    hupper hdiag henclose
  exact augmentedHessian_posSemidef_of_flattened_posDef p _ hA
    (flatAugmentedHessian_apply p (7/50))

end ThomsonN9.Certificates
