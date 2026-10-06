import ThomsonN9.CandidateEnergy
import ThomsonN9.GramAlignment

/-! Quantitative Gram alignment specialized to the exact nine-point candidate. -/

namespace ThomsonN9

set_option autoImplicit false

theorem candidate_top_inner (r : CandidateParameter) (i j : Fin 3) (hij : i ≠ j) :
    inner ℝ (candidate r (i.castLE (by decide))) (candidate r (j.castLE (by decide))) =
      1-3*(r : ℝ)^2/2 := by
  have hn := norm_sub_sq_real
    (candidate r (i.castLE (by decide))) (candidate r (j.castLE (by decide)))
  rw [(candidate_admissible r).1, (candidate_admissible r).1] at hn
  have hd := candidate_distance (radius_bounds r).1 (radius_bounds r).2
    (i.castLE (by decide) : Fin 9) (j.castLE (by decide) : Fin 9)
  change ‖candidate r (i.castLE (by decide))-candidate r (j.castLE (by decide))‖ = _ at hd
  have hs : (Real.sqrt (3 : ℝ))^2=3 := Real.sq_sqrt (by norm_num)
  have hd' : candidateDistance r (i.castLE (by decide)) (j.castLE (by decide)) =
      Real.sqrt 3*(r : ℝ) := by
    fin_cases i <;> fin_cases j <;> norm_num [candidateDistance] at *
  rw [hd'] at hd
  rw [hd, mul_pow, hs] at hn
  nlinarith

theorem candidate_top_inner_bound (r : CandidateParameter) (i j : Fin 3) (hij : i ≠ j) :
    |inner ℝ (candidate r (i.castLE (by decide))) (candidate r (j.castLE (by decide)))| ≤
      (1/4 : ℝ) := by
  have hrl : (71/100 : ℝ) ≤ (r : ℝ) := by
    have h : (71/100 : ℝ) ≤ (radiusLower : ℝ) := by norm_num [radiusLower]
    exact h.trans r.property.1
  have hru : (r : ℝ) ≤ (72/100 : ℝ) := by
    have h : (radiusUpper : ℝ) ≤ (72/100 : ℝ) := by norm_num [radiusUpper]
    exact r.property.2.1.trans h
  have hlo := (sq_le_sq₀ (by norm_num : (0 : ℝ) ≤ 71/100) (radius_bounds r).1.le).mpr hrl
  have hhi := (sq_le_sq₀ (radius_bounds r).1.le (by norm_num : (0 : ℝ) ≤ 72/100)).mpr hru
  rw [candidate_top_inner r i j hij, abs_le]
  constructor <;> nlinarith

theorem abs_le_third_of_close_quarter {a b δ : ℝ} (hb : |b| ≤ (1/4 : ℝ))
    (hδ : δ ≤ (1/12 : ℝ)) (hclose : |a-b| ≤ δ) : |a| ≤ (1/3 : ℝ) := by
  have h : |a| ≤ |a-b|+|b| := by
    calc
      |a| = |(a-b)+b| := by congr 1; ring
      _ ≤ |a-b|+|b| := abs_add_le _ _
  linarith

theorem candidate_gram_close_minimal_alignment (r : CandidateParameter)
    {x : Configuration} {δ : ℝ} (hx : ∀ i, ‖x i‖=1)
    (hδ : 0 ≤ δ) (hδu : δ ≤ (1/12 : ℝ))
    (hg : ∀ i j, |inner ℝ (x i) (x j)-inner ℝ (candidate r i) (candidate r j)| ≤ δ) :
    ∃ Q : R3 ≃ₗᵢ[ℝ] R3, IsMinimalAlignment (fun i => Q (x i)) (candidate r) ∧
      (∑ i, ‖Q (x i)-candidate r i‖^2) ≤ (10000*δ)^2 := by
  have hp01 : |inner ℝ (candidate r 0) (candidate r 1)| ≤ (1/4 : ℝ) :=
    candidate_top_inner_bound r 0 1 (by decide)
  have hp02 : |inner ℝ (candidate r 0) (candidate r 2)| ≤ (1/4 : ℝ) :=
    candidate_top_inner_bound r 0 2 (by decide)
  have hp12 : |inner ℝ (candidate r 1) (candidate r 2)| ≤ (1/4 : ℝ) :=
    candidate_top_inner_bound r 1 2 (by decide)
  exact gram_close_exists_minimal_alignment hx (candidate_admissible r).1 hδ hg
    (abs_le_third_of_close_quarter hp01 hδu (hg 0 1))
    (abs_le_third_of_close_quarter hp02 hδu (hg 0 2))
    (abs_le_third_of_close_quarter hp12 hδu (hg 1 2))
    (hp01.trans (by norm_num)) (hp02.trans (by norm_num)) (hp12.trans (by norm_num))

theorem candidate_refined_gram_alignment (r : CandidateParameter) {x : Configuration}
    (hx : ∀ i, ‖x i‖=1)
    (hg : ∀ i j, |inner ℝ (x i) (x j)-inner ℝ (candidate r i) (candidate r j)| ≤
      (1/100000000 : ℝ)) :
    ∃ Q : R3 ≃ₗᵢ[ℝ] R3,
      (∑ i, ‖Q (x i)-candidate r i‖^2) ≤ (1/10000 : ℝ)^2 ∧
      ∀ a b : Fin 3, (∑ i, (((Q (x i)) a-(candidate r i) a)*(candidate r i) b-
        ((Q (x i)) b-(candidate r i) b)*(candidate r i) a))=0 := by
  obtain ⟨Q,hmin,hbound⟩ := candidate_gram_close_minimal_alignment r hx
    (by norm_num) (by norm_num) hg
  refine ⟨Q, ?_, fun a b => minimal_alignment_displacement_skew_zero hmin a b⟩
  norm_num at hbound ⊢
  exact hbound

end ThomsonN9
