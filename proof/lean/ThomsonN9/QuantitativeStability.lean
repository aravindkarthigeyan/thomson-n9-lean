import ThomsonN9.Completion
import ClaudeL2b.Integration

/-! Quantitative stability from the concrete global and local certificates. -/

set_option autoImplicit false

namespace ThomsonN9

theorem near_optimal_energy_cutoff (r : CandidateParameter) (x : Configuration)
    (he : coulombEnergy x ≤ coulombEnergy (candidate r)+(1/10^47 : Real)) :
    coulombEnergy x ≤ LPConcrete.energyCutoff := by
  have hu := Certificates.ReducedEnergy.candidate_energy_upper r
  have hc : (Certificates.ReducedEnergy.energyUpper : Real)+(1/10^47 : Real) ≤
      LPConcrete.energyCutoff := by
    norm_num [Certificates.ReducedEnergy.energyUpper, LPConcrete.energyCutoff]
  linarith

theorem near_optimal_refined_gram (r : CandidateParameter) (x : Configuration)
    (hx : IsSphereConfiguration x)
    (he : coulombEnergy x ≤ coulombEnergy (candidate r)+(1/10^47 : Real)) :
    ∃ p : Equiv.Perm (Fin 9), ∀ i j,
      |inner Real (x (p i)) (x (p j))-inner Real (candidate r i) (candidate r j)| ≤
        (1/100000000 : Real) := by
  have hs := LPConcrete.inner_lt_separation x hx (near_optimal_energy_cutoff r x he)
    separation_minorant_certified separation_tail_certified
  have hb := Claude.L1.reduced_pair_bound x hx.1 (fun i j hij => (hs i j hij).le)
  simp only [reduced_minorant_identity] at hb
  apply Claude.L2b.refined_relabel x hx r
    (coulombEnergy (candidate r)+(1/10^47 : Real))
    ((Claude.L1.rawEnergyReduced : Real)+(1/10^47 : Real))
    ((Claude.L1.rawEnergyReduced : Real)-(Claude.L1.certifiedEnergyReduced : Real)+
      (1/10^47 : Real))
  · exact he
  · rw [← reduced_upper_identity]
    exact add_le_add (Certificates.ReducedEnergy.candidate_energy_upper r) le_rfl
  · change _ ≤ pairSum (fun i j => Claude.L2b.hNew (inner Real (x i) (x j)))
    linarith
  · norm_num [Claude.L1.rawEnergyReduced, Claude.L1.certifiedEnergyReduced]
  · intro i j hij
    exact hs i j hij.ne

theorem thomson_nine_quantitative_stability (r : CandidateParameter) (x : Configuration)
    (hx : IsSphereConfiguration x)
    (he : coulombEnergy x ≤ coulombEnergy (candidate r)+(1/10^47 : Real)) :
    ∃ (p : Equiv.Perm (Fin 9)) (Q : R3 ≃ₗᵢ[Real] R3),
      (∑ i, ‖Q (x (p i))-candidate r i‖^2) ≤
        50*(coulombEnergy x-coulombEnergy (candidate r)) := by
  obtain ⟨p, hp⟩ := near_optimal_refined_gram r x hx he
  obtain ⟨Q, hbound, hskew⟩ := candidate_refined_gram_alignment r
    (fun i => hx.1 (p i)) hp
  let y : Configuration := fun i => Q (x (p i))
  let rho : Real := Real.sqrt (∑ i, ‖y i-candidate r i‖^2)
  have hy : ∀ i, ‖y i‖=1 := fun i => by
    simpa only [y, Q.norm_map] using hx.1 (p i)
  have hr : 0 ≤ rho := Real.sqrt_nonneg _
  have hrho : (∑ i, ‖y i-candidate r i‖^2) = rho^2 :=
    (Real.sq_sqrt (Finset.sum_nonneg fun _ _ => sq_nonneg _)).symm
  have hsmall : rho ≤ (1/500 : Real) := by
    change (∑ i, ‖y i-candidate r i‖^2) ≤ (1/10000 : Real)^2 at hbound
    rw [hrho] at hbound
    nlinarith
  have hz : ∀ a b : Fin 3,
      (∑ i, ((y i-candidate r i) a*candidate r i b-
        (y i-candidate r i) b*candidate r i a))=0 := by
    simpa only [y, PiLp.sub_apply] using hskew
  have hgap := candidate_local_energy_gap r y hy hr hsmall hrho hz
    (Certificates.AmbientKernel.candidate_augmented_hessian_posSemidef r)
  have henergy : coulombEnergy y = coulombEnergy x :=
    congruent_energy ⟨Q, p, fun _ => rfl⟩
  rw [henergy] at hgap
  refine ⟨p, Q, ?_⟩
  change (∑ i, ‖y i-candidate r i‖^2) ≤ _
  rw [hrho]
  linarith

#print axioms near_optimal_energy_cutoff
#print axioms near_optimal_refined_gram
#print axioms thomson_nine_quantitative_stability

end ThomsonN9
