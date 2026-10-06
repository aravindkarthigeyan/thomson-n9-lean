import ThomsonN9.SDP.FactoredKernels
import Mathlib.Algebra.MvPolynomial.Eval

namespace ThomsonN9.SDP

abbrev RationalTriplePolynomial := MvPolynomial (Fin 3) ℚ

noncomputable def evaluateTriple (u v t : ℝ) : RationalTriplePolynomial →+* ℝ :=
  MvPolynomial.eval₂Hom (Rat.castHom ℝ) ![u, v, t]

noncomputable def substituteTriple (P A B C : RationalTriplePolynomial) : RationalTriplePolynomial :=
  MvPolynomial.eval₂Hom MvPolynomial.C ![A, B, C] P

theorem evaluateTriple_C (c : ℚ) (u v t : ℝ) :
    evaluateTriple u v t (MvPolynomial.C c) = (c : ℝ) := by
  simp [evaluateTriple]

theorem evaluateTriple_X (i : Fin 3) (u v t : ℝ) :
    evaluateTriple u v t (MvPolynomial.X i) = ![u, v, t] i := by
  simp [evaluateTriple]

theorem evaluateTriple_substitute (P A B C : RationalTriplePolynomial) (u v t : ℝ) :
    evaluateTriple u v t (substituteTriple P A B C) =
      evaluateTriple (evaluateTriple u v t A) (evaluateTriple u v t B)
        (evaluateTriple u v t C) P := by
  simp only [evaluateTriple, substituteTriple, MvPolynomial.coe_eval₂Hom]
  rw [← MvPolynomial.eval₂_assoc]
  congr 1
  funext i
  fin_cases i <;> rfl

noncomputable def qPolynomial : ℕ → RationalTriplePolynomial
  | 0 => 1
  | 1 => MvPolynomial.X 2-MvPolynomial.X 0*MvPolynomial.X 1
  | n+2 => 2*(MvPolynomial.X 2-MvPolynomial.X 0*MvPolynomial.X 1)*qPolynomial (n+1)-
      (1-MvPolynomial.X 0^2)*(1-MvPolynomial.X 1^2)*qPolynomial n

theorem evaluateTriple_qPolynomial (k : ℕ) (u v t : ℝ) :
    evaluateTriple u v t (qPolynomial k) = threePointKernel k u v t := by
  induction k using Nat.twoStepInduction with
  | zero => simp [qPolynomial, threePointKernel, circleKernel]
  | one => simp [qPolynomial, evaluateTriple, threePointKernel, circleKernel]
  | more n h₀ h₁ =>
    change evaluateTriple u v t
      (2*(MvPolynomial.X 2-MvPolynomial.X 0*MvPolynomial.X 1)*qPolynomial (n+1)-
      (1-MvPolynomial.X 0^2)*(1-MvPolynomial.X 1^2)*qPolynomial n) = _
    simp only [map_sub, map_mul, map_ofNat, map_one, map_pow, evaluateTriple_X,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two, h₀, h₁]
    rfl

noncomputable def symmetrizePolynomial (P : RationalTriplePolynomial) : RationalTriplePolynomial :=
  let U := MvPolynomial.X (0 : Fin 3)
  let V := MvPolynomial.X (1 : Fin 3)
  let T := MvPolynomial.X (2 : Fin 3)
  MvPolynomial.C (1/6 : ℚ)*(P+substituteTriple P V U T+substituteTriple P U T V+
    substituteTriple P T U V+substituteTriple P V T U+substituteTriple P T V U)

theorem evaluateTriple_symmetrize (P : RationalTriplePolynomial) (u v t : ℝ) :
    evaluateTriple u v t (symmetrizePolynomial P) =
      edgeSymmetrize (fun a b c => evaluateTriple a b c P) u v t := by
  simp only [symmetrizePolynomial, map_mul, map_add, evaluateTriple_C,
    evaluateTriple_substitute, evaluateTriple_X, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.cons_val_two]
  norm_num only [Rat.cast_div, Rat.cast_one, Rat.cast_ofNat]
  unfold edgeSymmetrize
  simp only [Matrix.vecHead, Matrix.vecTail, Function.comp_apply,
    Matrix.cons_val_succ, Matrix.cons_val_zero]
  ring

noncomputable def correctedPolynomial (P : RationalTriplePolynomial) : RationalTriplePolynomial :=
  let S := symmetrizePolynomial P
  let U := MvPolynomial.X (0 : Fin 3)
  let V := MvPolynomial.X (1 : Fin 3)
  let T := MvPolynomial.X (2 : Fin 3)
  7*S+substituteTriple S U U 1+substituteTriple S V V 1+substituteTriple S T T 1+
    MvPolynomial.C (1/8 : ℚ)*substituteTriple S 1 1 1

theorem evaluateTriple_corrected (P : RationalTriplePolynomial) (u v t : ℝ) :
    evaluateTriple u v t (correctedPolynomial P) =
      let S := edgeSymmetrize (fun a b c => evaluateTriple a b c P)
      7*S u v t+S u u 1+S v v 1+S t t 1+S 1 1 1/8 := by
  simp only [correctedPolynomial, map_add, map_mul, map_ofNat,
    evaluateTriple_substitute, evaluateTriple_C, evaluateTriple_X, map_one,
    Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    evaluateTriple_symmetrize]
  norm_num only [Rat.cast_div, Rat.cast_one, Rat.cast_ofNat]
  simp only [Matrix.vecHead, Matrix.vecTail, Function.comp_apply,
    Matrix.cons_val_succ, Matrix.cons_val_zero]
  ring

noncomputable def rootedMonomialFactorPolynomial {m r : ℕ} (B : Fin m → Fin r → ℚ) (k : ℕ) :
    RationalTriplePolynomial :=
  ∑ b, (∑ i, MvPolynomial.C (B i b)*MvPolynomial.X (0 : Fin 3)^(i : ℕ))*
    (∑ i, MvPolynomial.C (B i b)*MvPolynomial.X (1 : Fin 3)^(i : ℕ))*qPolynomial k

theorem evaluateTriple_rootedMonomialFactor {m r : ℕ}
    (B : Fin m → Fin r → ℚ) (k : ℕ) (u v t : ℝ) :
    evaluateTriple u v t (rootedMonomialFactorPolynomial B k) =
      rootedFactorKernel (fun i b => (B i b : ℝ)) (fun i a => a^(i : ℕ)) k u v t := by
  simp only [rootedMonomialFactorPolynomial, map_sum, map_mul, map_pow,
    evaluateTriple_C, evaluateTriple_X, Matrix.cons_val_zero, Matrix.cons_val_one,
    evaluateTriple_qPolynomial, rootedFactorKernel, factorWeight]

theorem evaluateTriple_correctedMonomialFactor {m r : ℕ}
    (B : Fin m → Fin r → ℚ) (k : ℕ) (u v t : ℝ) :
    evaluateTriple u v t (correctedPolynomial (rootedMonomialFactorPolynomial B k)) =
      correctedFactorKernel (fun i b => (B i b : ℝ)) (fun i a => a^(i : ℕ)) k u v t := by
  simp only [evaluateTriple_corrected, evaluateTriple_rootedMonomialFactor,
    correctedFactorKernel]

theorem rational_polynomial_identity_sound {P Q : RationalTriplePolynomial}
    (h : P = Q) (u v t : ℝ) : evaluateTriple u v t P = evaluateTriple u v t Q :=
  congrArg (evaluateTriple u v t) h

end ThomsonN9.SDP
