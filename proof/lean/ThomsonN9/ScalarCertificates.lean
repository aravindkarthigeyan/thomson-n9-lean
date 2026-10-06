import ClaudeL1.Main
import ClaudeL2b.RefinedWindows
import ClaudeL2b.LPAdapterCodex
import ThomsonN9.GlobalReduction
import ThomsonN9.LP.ConcreteLinkage
import ThomsonN9.Certificates.ReducedEnergy

/-! Concrete certificate identities and unconditional sublevel Gram localization. -/

set_option autoImplicit false

namespace ThomsonN9

theorem reduced_coefficient_identity (i : Fin 21) :
    Claude.L1.hNewCoeff i = Claude.L2b.hNewRat.getD i.val 0 := by
  fin_cases i <;> rfl

theorem reduced_minorant_identity (t : Real) :
    Claude.L1.hNew t = Claude.L2b.hNew t := by
  unfold Claude.L1.hNew Claude.L2b.hNew
  rw [Finset.sum_range (fun i : Nat =>
    ((Claude.L2b.hNewRat.getD i 0 : Rat) : Real)*t^i)]
  apply Finset.sum_congr rfl
  intro i _
  rw [reduced_coefficient_identity]

theorem reduced_upper_identity :
    Certificates.ReducedEnergy.energyUpper = Claude.L1.rawEnergyReduced := rfl

theorem reduced_loss_small :
    (Claude.L1.rawEnergyReduced : Real) - (Claude.L1.certifiedEnergyReduced : Real) <
      (1/10^46 : Real) := by
  norm_num [Claude.L1.rawEnergyReduced, Claude.L1.certifiedEnergyReduced]

theorem separation_minorant_certified :
    ∀ t : Real, -1 ≤ t → t < 1 →
      LPConcrete.separationMinorant t ≤ SDP.coulombPotential t := by
  apply Claude.L2b.hminor_sep
  intro t
  exact LPConcrete.separation_horner_minorant t

theorem separation_tail_certified :
    ∀ t : Real, (5593/10000 : Real) ≤ t → t < 1 →
      LPConcrete.separationMinorant t +
        (LPConcrete.energyCutoff-LPConcrete.separationBound) + (1/100000000 : Real) ≤
          SDP.coulombPotential t := by
  apply Claude.L2b.htail_sep _ _ _ rfl rfl
  intro t
  exact LPConcrete.separation_horner_minorant t

theorem candidate_below_energy_cutoff (r : CandidateParameter) :
    coulombEnergy (candidate r) ≤ LPConcrete.energyCutoff := by
  refine (Certificates.ReducedEnergy.candidate_energy_upper r).trans ?_
  norm_num [Certificates.ReducedEnergy.energyUpper, LPConcrete.energyCutoff]

theorem sublevel_separation (r : CandidateParameter) (x : Configuration)
    (hx : IsSphereConfiguration x)
    (he : coulombEnergy x ≤ coulombEnergy (candidate r)) :
    ∀ i j, i ≠ j → inner Real (x i) (x j) < (5593/10000 : Real) := by
  exact LPConcrete.inner_lt_separation x hx (he.trans (candidate_below_energy_cutoff r))
    separation_minorant_certified separation_tail_certified

theorem sublevel_refined_gram (r : CandidateParameter) (x : Configuration)
    (hx : IsSphereConfiguration x)
    (he : coulombEnergy x ≤ coulombEnergy (candidate r)) :
    ∃ p : Equiv.Perm (Fin 9), ∀ i j,
      |inner Real (x (p i)) (x (p j))-inner Real (candidate r i) (candidate r j)| ≤
        (1/100000000 : Real) := by
  have hs := sublevel_separation r x hx he
  have hb := Claude.L1.reduced_pair_bound x hx.1 (fun i j hij => (hs i j hij).le)
  simp only [reduced_minorant_identity] at hb
  apply refined_gram_of_scalar_bounds r x hx he Claude.L2b.hNew
    (Claude.L1.rawEnergyReduced : Real)
    ((Claude.L1.rawEnergyReduced : Real)-(Claude.L1.certifiedEnergyReduced : Real))
  · rw [← reduced_upper_identity]
    exact Certificates.ReducedEnergy.candidate_energy_upper r
  · intro i j hij
    exact Claude.L2b.hNew_le_inv_dist (hx.1 i) (hx.1 j) (fun h => hij.ne (hx.2 h))
  · simpa only [sub_sub_cancel] using hb
  · exact reduced_loss_small
  · intro i j hij
    exact (hs i j hij.ne).le
  · intro t ht1 ht2 hc
    exact Claude.L2b.exterior_gap_new r.property.1 r.property.2.1 ht1 ht2 hc
  · intro t ht1 ht2 hc
    exact Claude.L2b.refined_gap_new r.property.1 r.property.2.1 ht1 ht2 hc

#print axioms reduced_coefficient_identity
#print axioms reduced_minorant_identity
#print axioms reduced_upper_identity
#print axioms reduced_loss_small
#print axioms separation_minorant_certified
#print axioms separation_tail_certified
#print axioms candidate_below_energy_cutoff
#print axioms sublevel_separation
#print axioms sublevel_refined_gram

end ThomsonN9
