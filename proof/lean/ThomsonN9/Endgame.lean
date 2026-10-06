import ThomsonN9.CentroidBound
import ThomsonN9.LocalRigidity
import Challenge

/-! Formal closure lemmas. Their certificate and localization hypotheses are
explicit obligations, not assumed instances or asserted global theorems. -/

namespace ThomsonN9

theorem finite_slack_localization {ι : Type*} [Fintype ι]
    (f h : ι → ℝ) (inside : ι → Prop) (E U loss gap : ℝ)
    (hminorant : ∀ i, h i ≤ f i)
    (hexterior : ∀ i, ¬ inside i → gap ≤ f i - h i)
    (henergy : ∑ i, f i ≤ E) (hupper : E ≤ U)
    (hbound : U - loss ≤ ∑ i, h i) (hgap : loss < gap) :
    ∀ i, inside i := by
  classical
  intro i
  by_contra hout
  have hsingle : f i - h i ≤ ∑ j, (f j - h j) :=
    Finset.single_le_sum (fun j _ => sub_nonneg.mpr (hminorant j)) (Finset.mem_univ i)
  rw [Finset.sum_sub_distrib] at hsingle
  have hbad := hexterior i hout
  linarith

theorem pair_slack_le_total (f h : Fin 9 → Fin 9 → ℝ)
    (hminorant : ∀ i j, i < j → h i j ≤ f i j)
    {i j : Fin 9} (hij : i < j) :
    f i j - h i j ≤ pairSum f - pairSum h := by
  have hrow : f i j - h i j ≤ ∑ k ∈ Finset.Ioi i, (f i k - h i k) :=
    Finset.single_le_sum
      (fun k hk => sub_nonneg.mpr (hminorant i k (Finset.mem_Ioi.mp hk)))
      (Finset.mem_Ioi.mpr hij)
  have htotal : (∑ k ∈ Finset.Ioi i, (f i k - h i k)) ≤
      ∑ l : Fin 9, ∑ k ∈ Finset.Ioi l, (f l k - h l k) :=
    Finset.single_le_sum
      (fun l _ => Finset.sum_nonneg fun k hk =>
        sub_nonneg.mpr (hminorant l k (Finset.mem_Ioi.mp hk)))
      (Finset.mem_univ i)
  have heq : (∑ l : Fin 9, ∑ k ∈ Finset.Ioi l, (f l k - h l k)) =
      pairSum f - pairSum h := by
    simp only [pairSum, Finset.sum_sub_distrib]
  linarith

theorem pair_slack_localization (f h : Fin 9 → Fin 9 → ℝ)
    (inside : Fin 9 → Fin 9 → Prop) (E U loss gap : ℝ)
    (hminorant : ∀ i j, i < j → h i j ≤ f i j)
    (hexterior : ∀ i j, i < j → ¬ inside i j → gap ≤ f i j - h i j)
    (henergy : pairSum f ≤ E) (hupper : E ≤ U)
    (hbound : U - loss ≤ pairSum h) (hgap : loss < gap) :
    ∀ i j, i < j → inside i j := by
  intro i j hij
  by_contra hout
  have hsingle := pair_slack_le_total f h hminorant hij
  have hbad := hexterior i j hij hout
  linarith

theorem coulombEnergy_eq_half_double_sum (x : Configuration) :
    coulombEnergy x = (∑ i, ∑ j, (‖x i - x j‖)⁻¹) / 2 := by
  have h := twice_pairSum (fun i j => (‖x i - x j‖)⁻¹)
    (fun i j => by rw [norm_sub_rev]) (fun i => by simp)
  change 2 * coulombEnergy x = _ at h
  linarith

theorem congruent_energy {x y : Configuration} (h : Congruent x y) :
    coulombEnergy x = coulombEnergy y := by
  rcases h with ⟨g, p, hp⟩
  rw [coulombEnergy_eq_half_double_sum, coulombEnergy_eq_half_double_sum]
  have hd (i j : Fin 9) : ‖x i - x j‖ = ‖y (p i) - y (p j)‖ := by
    rw [hp i, hp j, ← g.map_sub, g.norm_map]
  simp_rw [hd]
  congr 1
  calc
    (∑ i, ∑ j, (‖y (p i) - y (p j)‖)⁻¹) =
        ∑ i, ∑ j, (‖y (p i) - y j‖)⁻¹ := by
      apply Finset.sum_congr rfl
      intro i _
      exact Equiv.sum_comp p (fun j => (‖y (p i) - y j‖)⁻¹)
    _ = ∑ i, ∑ j, (‖y i - y j‖)⁻¹ :=
      Equiv.sum_comp p (fun i => ∑ j, (‖y i - y j‖)⁻¹)

theorem sphere_relabel {x : Configuration} (hx : IsSphereConfiguration x)
    (p : Equiv.Perm (Fin 9)) : IsSphereConfiguration (fun i => x (p i)) :=
  ⟨fun i => hx.1 (p i), hx.2.comp p.injective⟩

theorem relabel_energy (x : Configuration) (p : Equiv.Perm (Fin 9)) :
    coulombEnergy (fun i => x (p i)) = coulombEnergy x :=
  congruent_energy ⟨LinearIsometryEquiv.refl ℝ R3, p, fun _ => rfl⟩

theorem congruent_of_relabel {x y : Configuration} (p : Equiv.Perm (Fin 9))
    (h : Congruent (fun i => x (p i)) y) : Congruent x y := by
  rcases h with ⟨g, q, hq⟩
  refine ⟨g, p.symm.trans q, ?_⟩
  intro i
  simpa using hq (p.symm i)

theorem optimality_of_sublevel_congruent (r : CandidateParameter)
    (hsublevel : ∀ x : Configuration, IsSphereConfiguration x →
      coulombEnergy x ≤ coulombEnergy (candidate r) → Congruent x (candidate r)) :
    ∀ x : Configuration, IsSphereConfiguration x →
      coulombEnergy (candidate r) ≤ coulombEnergy x := by
  intro x hx
  by_cases hle : coulombEnergy x ≤ coulombEnergy (candidate r)
  · exact le_of_eq (congruent_energy (hsublevel x hx hle)).symm
  · exact le_of_lt (lt_of_not_ge hle)

theorem uniqueness_of_sublevel_congruent (r : CandidateParameter)
    (hsublevel : ∀ x : Configuration, IsSphereConfiguration x →
      coulombEnergy x ≤ coulombEnergy (candidate r) → Congruent x (candidate r)) :
    ∀ x : Configuration, IsSphereConfiguration x →
      (coulombEnergy x = coulombEnergy (candidate r) ↔ Congruent x (candidate r)) := by
  intro x hx
  exact ⟨fun h => hsublevel x hx h.le, congruent_energy⟩

theorem sublevel_congruent_of_localization (hlocal : QuantitativeLocalTarget)
    (hlocate : ∀ r : CandidateParameter, ∀ x : Configuration,
      IsSphereConfiguration x → coulombEnergy x ≤ coulombEnergy (candidate r) →
      ∃ (p : Equiv.Perm (Fin 9)) (g : R3 ≃ₗᵢ[ℝ] R3),
        (∑ i, ‖x (p i) - g (candidate r i)‖ ^ 2) ≤ (1 / 500 : ℝ) ^ 2) :
    ∀ r : CandidateParameter, ∀ x : Configuration,
      IsSphereConfiguration x → coulombEnergy x ≤ coulombEnergy (candidate r) →
      Congruent x (candidate r) := by
  intro r x hx he
  obtain ⟨p, g, hg⟩ := hlocate r x hx he
  obtain ⟨hmin, heq⟩ := hlocal r (fun i => x (p i)) (sphere_relabel hx p) ⟨g, hg⟩
  have henergy := relabel_energy x p
  apply congruent_of_relabel p
  apply heq
  linarith

end ThomsonN9
