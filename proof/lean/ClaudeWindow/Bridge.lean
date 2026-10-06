import ClaudeWindow.CandidateGram
import ClaudeWindow.Main

/-!
# L3 deliverable in the vocabulary of Codex's `ThomsonN9` package

`window_rigidity_candidateAt`: for every real `r ∈ [radiusLower, radiusUpper]` and unit
vectors `x : Configuration` whose distinct-pair inner products each lie within `1/10000` of
an off-diagonal Gram entry of `candidateAt r`, or in `[-1, -1 + 1/10000]`, there is a
permutation `σ` with
`|⟪x i, x j⟫ - ⟪candidateAt r (σ i), candidateAt r (σ j)⟫| ≤ 1/10000` for ALL `i, j`
(this is `LOCAL_PROOF.md` (C)).

No anchor / covariance hypothesis is needed: a triple with Gram determinant `> 1/100` is
produced inside the proof (`exists_anchor`).  Corollaries: the `CandidateParameter` version
and the relabeled-`x` form consumed by the local theorem.
-/

namespace ThomsonN9.Claude.Window

open ThomsonN9

theorem window_rigidity_candidateAt {r : ℝ} (hlo : (radiusLower : ℝ) ≤ r)
    (hhi : r ≤ (radiusUpper : ℝ)) (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i ≠ j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidateAt r a) (candidateAt r b)| ≤ 1 / 10000) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x i) (x j) - inner ℝ (candidateAt r (σ i)) (candidateAt r (σ j))| ≤ 1 / 10000 := by
  have hL : (0 : ℝ) < (radiusLower : ℝ) := by norm_num [radiusLower]
  have hU : (radiusUpper : ℝ) < 1 := by norm_num [radiusUpper]
  have hr : 0 < r := lt_of_lt_of_le hL hlo
  have hr1 : r < 1 := lt_of_le_of_lt hhi hU
  have hlo' : (rLo : ℝ) ≤ r := by rw [rLo_eq]; exact hlo
  have hhi' : r ≤ (rHi : ℝ) := by rw [rHi_eq]; exact hhi
  have hwin' : ∀ i j, i ≠ j →
      (∃ c : ℕ, c < 6 ∧ |inner ℝ (x i) (x j) - palette r c| ≤ 1 / 10000) ∨
        inner ℝ (x i) (x j) ≤ -1 + 1 / 10000 := by
    intro i j hij
    rcases hwin i j hij with ⟨a, b, hab, h⟩ | h
    · left
      refine ⟨refColor a b, refColor_lt6 a a.isLt b b.isLt (fun e => hab (Fin.ext e)), ?_⟩
      rwa [← candidateAt_inner hr hr1 a b hab]
    · exact Or.inr h
  obtain ⟨σ, hσ⟩ := window_rigidity_free hlo' hhi' x hx hwin'
  refine ⟨σ, fun i j => ?_⟩
  by_cases hij : i = j
  · subst hij
    rw [real_inner_self_eq_norm_sq, hx i, candidateAt_inner_self hr hr1, one_pow, sub_self,
      abs_zero]
    norm_num
  · rw [candidateAt_inner hr hr1 _ _ (fun e => hij (σ.injective e))]
    exact hσ i j hij

/-- The same for the candidate parameter (the true radius `r*`). -/
theorem window_rigidity_candidate (r : CandidateParameter) (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i ≠ j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidate r a) (candidate r b)| ≤ 1 / 10000) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x i) (x j) - inner ℝ (candidate r (σ i)) (candidate r (σ j))| ≤ 1 / 10000 :=
  window_rigidity_candidateAt r.property.1 r.property.2.1 x hx hwin

/-- Relabeled form: `x ∘ p` has Gram matrix within `1/10000` of the candidate's. -/
theorem window_rigidity_candidate_relabel (r : CandidateParameter) (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i ≠ j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidate r a) (candidate r b)| ≤ 1 / 10000) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ p : Equiv.Perm (Fin 9), ∀ a b,
      |inner ℝ (x (p a)) (x (p b)) - inner ℝ (candidate r a) (candidate r b)| ≤ 1 / 10000 := by
  obtain ⟨σ, hσ⟩ := window_rigidity_candidate r x hx hwin
  refine ⟨σ.symm, fun a b => ?_⟩
  have := hσ (σ.symm a) (σ.symm b)
  simpa using this

theorem boxes_above_antipodal : ∀ c, c < 6 → (-1 + 1 / 10000 : ℚ) < (box c).lo := by
  decide +kernel

/-- **Refined windows.**  If every distinct-pair inner product is within `η ≤ 1/10000` of an
off-diagonal Gram entry of `candidateAt r` (or in `[-1, -1 + 1/10000]`), then the labeled Gram
error is at most `η`.  (E.g. Codex's refined windows, `η = 10⁻⁸`.)  The labeling is the one of
the `1/10000` classification; the windows of radius `1/10000` are disjoint. -/
theorem window_rigidity_candidateAt_eta {r : ℝ} (hlo : (radiusLower : ℝ) ≤ r)
    (hhi : r ≤ (radiusUpper : ℝ)) {η : ℝ} (hη : η ≤ 1 / 10000) (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i ≠ j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidateAt r a) (candidateAt r b)| ≤ η) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x i) (x j) - inner ℝ (candidateAt r (σ i)) (candidateAt r (σ j))| ≤ η := by
  have hL : (0 : ℝ) < (radiusLower : ℝ) := by norm_num [radiusLower]
  have hU : (radiusUpper : ℝ) < 1 := by norm_num [radiusUpper]
  have hr : 0 < r := lt_of_lt_of_le hL hlo
  have hr1 : r < 1 := lt_of_le_of_lt hhi hU
  have hlo' : (rLo : ℝ) ≤ r := by rw [rLo_eq]; exact hlo
  have hhi' : r ≤ (rHi : ℝ) := by rw [rHi_eq]; exact hhi
  have hwin4 : ∀ i j, i ≠ j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidateAt r a) (candidateAt r b)| ≤ 1 / 10000) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000 := by
    intro i j hij
    rcases hwin i j hij with ⟨a, b, hab, h⟩ | h
    · exact Or.inl ⟨a, b, hab, le_trans h hη⟩
    · exact Or.inr h
  obtain ⟨σ, hσ⟩ := window_rigidity_candidateAt hlo hhi x hx hwin4
  refine ⟨σ, fun i j => ?_⟩
  by_cases hij : i = j
  · subst hij
    rw [real_inner_self_eq_norm_sq, hx i, candidateAt_inner_self hr hr1, one_pow, sub_self,
      abs_zero]
    have hη0 : 0 ≤ η := by
      obtain ⟨k, hk, -⟩ := exists_third i i
      rcases hwin i k (Ne.symm hk) with ⟨a, b, -, h⟩ | h
      · exact le_trans (abs_nonneg _) h
      · -- impossible: the antipodal window is empty (classification of the pair (i,k))
        exfalso
        have h1 := hσ i k
        rw [candidateAt_inner hr hr1 _ _ (fun e => hk (σ.injective e).symm)] at h1
        have hlt := refColor_lt6 _ (σ i).isLt _ (σ k).isLt
          (fun e => hk (σ.injective (Fin.ext e)).symm)
        have hm := window_mem_box hlo' hhi' hlt h1
        have hb : (((-1 + 1 / 10000 : ℚ)) : ℝ) < ((box (refColor (σ i) (σ k))).lo : ℝ) := by
          exact_mod_cast boxes_above_antipodal _ hlt
        push_cast at hb
        linarith [hm.1]
    exact hη0
  · have hne : σ i ≠ σ j := fun e => hij (σ.injective e)
    have hlt := refColor_lt6 _ (σ i).isLt _ (σ j).isLt (fun e => hne (Fin.ext e))
    have h1 := hσ i j
    rw [candidateAt_inner hr hr1 _ _ hne] at h1 ⊢
    rcases hwin i j hij with ⟨a, b, hab, h⟩ | h
    · rw [candidateAt_inner hr hr1 _ _ hab] at h
      have hlt' := refColor_lt6 _ a.isLt _ b.isLt (fun e => hab (Fin.ext e))
      have := window_unique hlo' hhi' hlt hlt' h1 (le_trans h hη)
      rw [this]; exact h
    · exfalso
      have hm := window_mem_box hlo' hhi' hlt h1
      have hb : (((-1 + 1 / 10000 : ℚ)) : ℝ) < ((box (refColor (σ i) (σ j))).lo : ℝ) := by
        exact_mod_cast boxes_above_antipodal _ hlt
      push_cast at hb
      linarith [hm.1]

end ThomsonN9.Claude.Window
