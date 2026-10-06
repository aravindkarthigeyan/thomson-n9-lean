import ThomsonN9.SDP.ProjectionComplex
import ThomsonN9.SDP.Symmetrization

/-! Spherical three-point PSD blocks in factor form, at arbitrary truncation degree. -/

namespace ThomsonN9.SDP

noncomputable def factorWeight {κ ρ : Type*} [Fintype κ]
    (B : κ → ρ → ℝ) (p : κ → ℝ → ℝ) (r : ρ) (u : ℝ) : ℝ :=
  ∑ i, B i r*p i u

noncomputable def rootedFactorKernel {κ ρ : Type*} [Fintype κ] [Fintype ρ]
    (B : κ → ρ → ℝ) (p : κ → ℝ → ℝ) (k : ℕ) (u v t : ℝ) : ℝ :=
  ∑ r, factorWeight B p r u*factorWeight B p r v*threePointKernel k u v t

noncomputable def correctedFactorKernel {κ ρ : Type*} [Fintype κ] [Fintype ρ]
    (B : κ → ρ → ℝ) (p : κ → ℝ → ℝ) (k : ℕ) (u v t : ℝ) : ℝ :=
  let S := edgeSymmetrize (rootedFactorKernel B p k)
  7*S u v t+S u u 1+S v v 1+S t t 1+S 1 1 1/8

theorem rooted_factor_fullSum_nonneg {κ ρ : Type*} [Fintype κ] [Fintype ρ]
    (B : κ → ρ → ℝ) (p : κ → ℝ → ℝ) (k : ℕ)
    (x : Configuration) (hx : ∀ i, ‖x i‖ = 1) :
    0 ≤ fullSum (fun i j l => rootedFactorKernel B p k
      (inner ℝ (x i) (x j)) (inner ℝ (x i) (x l)) (inner ℝ (x j) (x l))) := by
  let term (i j l : Fin 9) (r : ρ) :=
    factorWeight B p r (inner ℝ (x i) (x j))*
    factorWeight B p r (inner ℝ (x i) (x l))*
    threePointKernel k (inner ℝ (x i) (x j)) (inner ℝ (x i) (x l))
      (inner ℝ (x j) (x l))
  have heq : (∑ i, ∑ j, ∑ l, ∑ r, term i j l r) =
      ∑ r, ∑ i, ∑ j, ∑ l, term i j l r := by
    calc
      _ = ∑ i, ∑ r, ∑ j, ∑ l, term i j l r := by
        apply Finset.sum_congr rfl
        intro i _
        calc
          _ = ∑ j, ∑ r, ∑ l, term i j l r := by
            apply Finset.sum_congr rfl
            intro j _
            rw [Finset.sum_comm]
          _ = _ := Finset.sum_comm
      _ = _ := Finset.sum_comm
  change 0 ≤ ∑ i, ∑ j, ∑ l, ∑ r, term i j l r
  rw [heq]
  apply Finset.sum_nonneg
  intro r _
  exact anchored_spherical_kernel_sum_nonneg x hx
    (fun i j => factorWeight B p r (inner ℝ (x i) (x j))) k

theorem edgeSymmetrize_on_gram (F : ℝ → ℝ → ℝ → ℝ) (x : Configuration)
    (i j k : Fin 9) :
    edgeSymmetrize F (inner ℝ (x i) (x j)) (inner ℝ (x i) (x k))
      (inner ℝ (x j) (x k)) =
    vertexSymmetrize (fun a b c => F (inner ℝ (x a) (x b))
      (inner ℝ (x a) (x c)) (inner ℝ (x b) (x c))) i j k := by
  simp only [edgeSymmetrize, vertexSymmetrize, real_inner_comm (x i) (x j),
    real_inner_comm (x i) (x k), real_inner_comm (x j) (x k)]

theorem symmetrized_factor_fullSum_nonneg {κ ρ : Type*} [Fintype κ] [Fintype ρ]
    (B : κ → ρ → ℝ) (p : κ → ℝ → ℝ) (k : ℕ)
    (x : Configuration) (hx : ∀ i, ‖x i‖ = 1) :
    0 ≤ fullSum (fun i j l => edgeSymmetrize (rootedFactorKernel B p k)
      (inner ℝ (x i) (x j)) (inner ℝ (x i) (x l)) (inner ℝ (x j) (x l))) := by
  simp_rw [edgeSymmetrize_on_gram]
  exact fullSum_vertexSymmetrize_nonneg _ (rooted_factor_fullSum_nonneg B p k x hx)

theorem corrected_factor_distinctSum_nonneg {κ ρ : Type*} [Fintype κ] [Fintype ρ]
    (B : κ → ρ → ℝ) (p : κ → ℝ → ℝ) (k : ℕ)
    (x : Configuration) (hx : ∀ i, ‖x i‖ = 1) :
    0 ≤ distinctSum (fun i j l => correctedFactorKernel B p k
      (inner ℝ (x i) (x j)) (inner ℝ (x i) (x l)) (inner ℝ (x j) (x l))) := by
  let S := edgeSymmetrize (rootedFactorKernel B p k)
  let T (i j l : Fin 9) := S (inner ℝ (x i) (x j))
    (inner ℝ (x i) (x l)) (inner ℝ (x j) (x l))
  let boundary (i j : Fin 9) := S (inner ℝ (x i) (x j)) (inner ℝ (x i) (x j)) 1
  have hd (i : Fin 9) : inner ℝ (x i) (x i) = 1 := by simp [hx i]
  have h₁ (i j : Fin 9) : T i i j = boundary i j := by
    simp only [T, boundary, hd]
    exact edgeSymmetrize_cycle _ _ _ _
  have h₂ (i j : Fin 9) : T i j i = boundary i j := by
    simp only [T, boundary, hd, real_inner_comm (x i) (x j)]
    exact edgeSymmetrize_swap_last _ _ _ _
  have h₃ (i j : Fin 9) : T i j j = boundary i j := by simp only [T, boundary, hd]
  have hb (i : Fin 9) : boundary i i = S 1 1 1 := by simp only [boundary, hd]
  have hs (i j : Fin 9) : boundary i j = boundary j i := by
    simp only [boundary, real_inner_comm (x i) (x j)]
  have hT : 0 ≤ fullSum T := symmetrized_factor_fullSum_nonneg B p k x hx
  have result := corrected_kernel_sum_nonneg T boundary (S 1 1 1) h₁ h₂ h₃ hb hs hT
  convert result using 1
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro l _
  split_ifs <;> simp only [correctedFactorKernel, T, boundary, S] <;> ring

end ThomsonN9.SDP
