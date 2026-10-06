import ThomsonN9.WindowLocalization
import ThomsonN9.ParameterExists

/-! Checked final assembly with explicit concrete-certificate premises. -/

set_option autoImplicit false

namespace ThomsonN9

theorem refined_gram_of_scalar_bounds (r : CandidateParameter) (x : Configuration)
    (hx : IsSphereConfiguration x) (he : coulombEnergy x ≤ coulombEnergy (candidate r))
    (h : ℝ → ℝ) (U loss : ℝ)
    (hupper : coulombEnergy (candidate r) ≤ U)
    (hminorant : ∀ i j, i < j → h (inner ℝ (x i) (x j)) ≤ ‖x i-x j‖⁻¹)
    (hbound : U-loss ≤ pairSum (fun i j => h (inner ℝ (x i) (x j))))
    (hgap : loss < 1/10^46)
    (hsep : ∀ i j, i < j → inner ℝ (x i) (x j) ≤ 5593/10000)
    (hcoarse : ∀ t : ℝ, -1+1/10000 ≤ t → t ≤ 5593/10000 →
      (∀ c : Fin 6, 1/10000 ≤ |t-Bernstein.contact r c|) →
      1/10^46 ≤ Bernstein.phi t-h t)
    (hrefined : ∀ t : ℝ, -3/4 ≤ t → t ≤ 5593/10000 →
      (∀ c : Fin 6, 1/100000000 ≤ |t-Bernstein.contact r c|) →
      1/10^33 ≤ Bernstein.phi t-h t) :
    ∃ p : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x (p i)) (x (p j))-inner ℝ (candidate r i) (candidate r j)| ≤
        (1/100000000 : ℝ) := by
  have hw := coarse_windows_of_energy_slack x r hx he h U loss (1/10^46)
    hupper hminorant hbound hgap hsep hcoarse
  obtain ⟨p, hp⟩ := gram_localization_of_windows x r hx.1 le_rfl hw
  have hlo := gram_close_lower x r p hp
  have hgap' : loss < (1/10^33 : ℝ) := hgap.trans_le (by norm_num)
  have hf := refined_windows_of_energy_slack x r hx he h U loss (1/10^33)
    hupper hminorant hbound hgap' (fun i j _ => hlo i j) hsep hrefined
  exact gram_localization_of_windows x r hx.1 (by norm_num)
    (fun i j hij => Or.inl (hf i j hij))

theorem complete_of_refined_gram_and_hessian
    (hgram : ∀ r : CandidateParameter, ∀ x : Configuration,
      IsSphereConfiguration x → coulombEnergy x ≤ coulombEnergy (candidate r) →
      ∃ p : Equiv.Perm (Fin 9), ∀ i j,
        |inner ℝ (x (p i)) (x (p j))-inner ℝ (candidate r i) (candidate r j)| ≤
          (1/100000000 : ℝ))
    (hpositive : ∀ r : CandidateParameter,
      (constrainedHessian (candidate r)+
        rotationColumns (candidate r)*(rotationColumns (candidate r)).transpose-
        (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)).PosSemidef) :
    Challenge.CompleteTarget := by
  have hlocal := quantitativeLocalTarget_of_augmentedHessian hpositive
  have hsub : ∀ r : CandidateParameter, ∀ x : Configuration,
      IsSphereConfiguration x → coulombEnergy x ≤ coulombEnergy (candidate r) →
      Congruent x (candidate r) := by
    apply sublevel_congruent_of_localization hlocal
    intro r x hx he
    obtain ⟨p, hp⟩ := hgram r x hx he
    obtain ⟨g, hg⟩ := near_candidate_of_refined_gram r x hx.1 p hp
    exact ⟨p, g, hg⟩
  refine ⟨parameter_exists_unique, ?_, ?_⟩
  · intro r
    exact optimality_of_sublevel_congruent r (hsub r)
  · intro r
    exact uniqueness_of_sublevel_congruent r (hsub r)

#print axioms refined_gram_of_scalar_bounds
#print axioms complete_of_refined_gram_and_hessian

end ThomsonN9
