import ThomsonN9.Bernstein.Minorant
import ThomsonN9.SDP.GeometryBounds
import ThomsonN9.Endgame
import ThomsonN9.CandidateAlignment
import ThomsonN9.LocalTarget
import ClaudeWindow.Bridge

/-! Energy slack forces coherent contact windows and a local candidate neighborhood. -/

set_option autoImplicit false

namespace ThomsonN9

def contactPair : Fin 6 → Fin 9 × Fin 9 :=
  ![(0, 4), (0, 6), (6, 7), (0, 3), (0, 1), (0, 7)]

theorem contactPair_ne (c : Fin 6) : (contactPair c).1 ≠ (contactPair c).2 := by
  fin_cases c <;> decide

theorem contact_eq_candidate_inner (r : CandidateParameter) (c : Fin 6) :
    Bernstein.contact r c =
      inner ℝ (candidate r (contactPair c).1) (candidate r (contactPair c).2) := by
  rw [candidate, Claude.Window.candidateAt_inner (radius_bounds r).1
    (radius_bounds r).2 _ _ (contactPair_ne c)]
  fin_cases c <;>
    norm_num [contactPair, Bernstein.contact, Claude.Window.refColor, Claude.Window.palette]

theorem ordered_contact_windows (x : Configuration) (r : CandidateParameter) (eta : ℝ)
    (h : ∀ i j, i < j →
      (∃ c : Fin 6, |inner ℝ (x i) (x j)-Bernstein.contact r c| ≤ eta) ∨
      inner ℝ (x i) (x j) ≤ -1+1/10000) :
    ∀ i j, i ≠ j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j)-inner ℝ (candidate r a) (candidate r b)| ≤ eta) ∨
      inner ℝ (x i) (x j) ≤ -1+1/10000 := by
  intro i j hij
  have hw : (∃ c : Fin 6, |inner ℝ (x i) (x j)-Bernstein.contact r c| ≤ eta) ∨
      inner ℝ (x i) (x j) ≤ -1+1/10000 := by
    rcases lt_or_gt_of_ne hij with hlt | hgt
    · exact h i j hlt
    · simpa only [real_inner_comm (x j) (x i)] using h j i hgt
  rcases hw with ⟨c, hc⟩ | ha
  · exact Or.inl ⟨(contactPair c).1, (contactPair c).2, contactPair_ne c,
      by simpa only [contact_eq_candidate_inner] using hc⟩
  · exact Or.inr ha

theorem gram_localization_of_windows (x : Configuration) (r : CandidateParameter)
    (hx : ∀ i, ‖x i‖ = 1) {eta : ℝ} (heta : eta ≤ 1/10000)
    (hwin : ∀ i j, i < j →
      (∃ c : Fin 6, |inner ℝ (x i) (x j)-Bernstein.contact r c| ≤ eta) ∨
      inner ℝ (x i) (x j) ≤ -1+1/10000) :
    ∃ p : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x (p i)) (x (p j))-inner ℝ (candidate r i) (candidate r j)| ≤ eta := by
  obtain ⟨p, hp⟩ := Claude.Window.window_rigidity_candidateAt_eta
    r.property.1 r.property.2.1 heta x hx (ordered_contact_windows x r eta hwin)
  refine ⟨p.symm, fun i j => ?_⟩
  simpa only [Equiv.apply_symm_apply, candidate] using hp (p.symm i) (p.symm j)

theorem coarse_windows_of_energy_slack (x : Configuration) (r : CandidateParameter)
    (hx : IsSphereConfiguration x) (he : coulombEnergy x ≤ coulombEnergy (candidate r))
    (h : ℝ → ℝ) (U loss gap : ℝ)
    (hupper : coulombEnergy (candidate r) ≤ U)
    (hminorant : ∀ i j, i < j → h (inner ℝ (x i) (x j)) ≤ ‖x i-x j‖⁻¹)
    (hbound : U-loss ≤ pairSum (fun i j => h (inner ℝ (x i) (x j))))
    (hgap : loss < gap)
    (hsep : ∀ i j, i < j → inner ℝ (x i) (x j) ≤ 5593/10000)
    (hexterior : ∀ t : ℝ, -1+1/10000 ≤ t → t ≤ 5593/10000 →
      (∀ c : Fin 6, 1/10000 ≤ |t-Bernstein.contact r c|) → gap ≤ Bernstein.phi t-h t) :
    ∀ i j, i < j →
      (∃ c : Fin 6, |inner ℝ (x i) (x j)-Bernstein.contact r c| ≤ 1/10000) ∨
      inner ℝ (x i) (x j) ≤ -1+1/10000 := by
  refine pair_slack_localization (fun i j => ‖x i-x j‖⁻¹)
    (fun i j => h (inner ℝ (x i) (x j)))
    (fun i j => (∃ c : Fin 6,
      |inner ℝ (x i) (x j)-Bernstein.contact r c| ≤ 1/10000) ∨
      inner ℝ (x i) (x j) ≤ -1+1/10000)
    (coulombEnergy (candidate r)) U loss gap hminorant
    ?_ he hupper hbound hgap
  intro i j hij hout
  have hanti : -1+1/10000 ≤ inner ℝ (x i) (x j) := by
    by_contra ha
    exact hout (Or.inr (le_of_lt (lt_of_not_ge ha)))
  have hc : ∀ c : Fin 6,
      1/10000 ≤ |inner ℝ (x i) (x j)-Bernstein.contact r c| := by
    intro c
    by_contra hh
    exact hout (Or.inl ⟨c, le_of_lt (lt_of_not_ge hh)⟩)
  have hg := hexterior (inner ℝ (x i) (x j)) hanti (hsep i j hij) hc
  rwa [Bernstein.phi_inner (hx.1 i) (hx.1 j) (fun h => hij.ne (hx.2 h))] at hg

theorem candidate_gram_lower (r : CandidateParameter) (i j : Fin 9) :
    (-749/1000 : ℝ) ≤ inner ℝ (candidate r i) (candidate r j) := by
  have hr : (71/100 : ℝ) ≤ r := by
    have hl : (71/100 : ℝ) ≤ (radiusLower : ℝ) := by norm_num [radiusLower]
    exact hl.trans r.property.1
  have hr1 : (r : ℝ) ≤ 711/1000 := by
    have hu : (radiusUpper : ℝ) ≤ (711/1000 : ℝ) := by norm_num [radiusUpper]
    exact r.property.2.1.trans hu
  have hr0 : 0 ≤ (r : ℝ) := le_of_lt (radius_bounds r).1
  have hslo := (sq_le_sq₀ (show (0 : ℝ) ≤ 71/100 by norm_num) hr0).2 hr
  have hshi := (sq_le_sq₀ hr0 (show (0 : ℝ) ≤ 711/1000 by norm_num)).2 hr1
  by_cases hij : i=j
  · subst j
    rw [real_inner_self_eq_norm_sq, (candidate_admissible r).1 i]
    norm_num
  · rw [candidate, Claude.Window.candidateAt_inner (radius_bounds r).1
      (radius_bounds r).2 i j hij]
    have hc := Claude.Window.refColor_lt6 i i.isLt j j.isLt (fun h => hij (Fin.ext h))
    generalize Claude.Window.refColor i j = c at *
    interval_cases c <;> norm_num [Claude.Window.palette] <;> nlinarith

theorem gram_close_lower (x : Configuration) (r : CandidateParameter)
    (p : Equiv.Perm (Fin 9))
    (hp : ∀ i j, |inner ℝ (x (p i)) (x (p j))-
      inner ℝ (candidate r i) (candidate r j)| ≤ 1/10000) :
    ∀ i j, (-3/4 : ℝ) ≤ inner ℝ (x i) (x j) := by
  intro i j
  have h := (abs_le.mp (hp (p.symm i) (p.symm j))).1
  simp only [Equiv.apply_symm_apply] at h
  have hb := candidate_gram_lower r (p.symm i) (p.symm j)
  linarith

theorem refined_windows_of_energy_slack (x : Configuration) (r : CandidateParameter)
    (hx : IsSphereConfiguration x) (he : coulombEnergy x ≤ coulombEnergy (candidate r))
    (h : ℝ → ℝ) (U loss gap : ℝ)
    (hupper : coulombEnergy (candidate r) ≤ U)
    (hminorant : ∀ i j, i < j → h (inner ℝ (x i) (x j)) ≤ ‖x i-x j‖⁻¹)
    (hbound : U-loss ≤ pairSum (fun i j => h (inner ℝ (x i) (x j))))
    (hgap : loss < gap)
    (hlo : ∀ i j, i < j → (-3/4 : ℝ) ≤ inner ℝ (x i) (x j))
    (hsep : ∀ i j, i < j → inner ℝ (x i) (x j) ≤ 5593/10000)
    (hexterior : ∀ t : ℝ, -3/4 ≤ t → t ≤ 5593/10000 →
      (∀ c : Fin 6, 1/100000000 ≤ |t-Bernstein.contact r c|) →
      gap ≤ Bernstein.phi t-h t) :
    ∀ i j, i < j → ∃ c : Fin 6,
      |inner ℝ (x i) (x j)-Bernstein.contact r c| ≤ 1/100000000 := by
  refine pair_slack_localization (fun i j => ‖x i-x j‖⁻¹)
    (fun i j => h (inner ℝ (x i) (x j)))
    (fun i j => ∃ c : Fin 6,
      |inner ℝ (x i) (x j)-Bernstein.contact r c| ≤ 1/100000000)
    (coulombEnergy (candidate r)) U loss gap hminorant
    ?_ he hupper hbound hgap
  intro i j hij hout
  have hc : ∀ c : Fin 6,
      1/100000000 ≤ |inner ℝ (x i) (x j)-Bernstein.contact r c| := by
    intro c
    by_contra hh
    exact hout ⟨c, le_of_lt (lt_of_not_ge hh)⟩
  have hg := hexterior (inner ℝ (x i) (x j)) (hlo i j hij) (hsep i j hij) hc
  rwa [Bernstein.phi_inner (hx.1 i) (hx.1 j) (fun h => hij.ne (hx.2 h))] at hg

theorem near_candidate_of_refined_gram (r : CandidateParameter) (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1) (p : Equiv.Perm (Fin 9))
    (hg : ∀ i j, |inner ℝ (x (p i)) (x (p j))-
      inner ℝ (candidate r i) (candidate r j)| ≤ (1/100000000 : ℝ)) :
    ∃ g : R3 ≃ₗᵢ[ℝ] R3,
      (∑ i, ‖x (p i)-g (candidate r i)‖^2) ≤ (1/500 : ℝ)^2 := by
  obtain ⟨Q, hQ, _⟩ := candidate_refined_gram_alignment r (fun i => hx (p i)) hg
  refine ⟨Q.symm, ?_⟩
  have hid : (∑ i, ‖Q (x (p i))-candidate r i‖^2) =
      ∑ i, ‖x (p i)-Q.symm (candidate r i)‖^2 := by
    simpa only [LinearIsometryEquiv.symm_symm] using
      inverse_alignment_distance (fun i => x (p i)) (candidate r) Q.symm
  rw [hid] at hQ
  exact hQ.trans (by norm_num)

end ThomsonN9
