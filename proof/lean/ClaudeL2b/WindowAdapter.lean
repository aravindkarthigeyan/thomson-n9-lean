import ClaudeWindow.Bridge

/-!
# L3 window rigidity from hypotheses on ordered pairs `i < j`

Codex's `ThomsonN9.pair_slack_localization` concludes `∀ i j, i < j → inside i j`.  L3's
`window_rigidity_*` theorems take the window hypothesis for all `i ≠ j`.  This file closes the
gap by symmetry of the inner product (this is the reviewer's `u3_relabel_of_lt`, moved here
and generalised).  It also accepts the windows in L2's contact form
`contactL3 r j` (`= ThomsonN9.Bernstein.contact r j` by `rfl`; L2 is not imported here because
its module root `ThomsonN9` would clash with Codex's on the search path), which is the form
of the exterior-gap theorems `exterior_gap_new` / `refined_gap_new`.

Main statements (namespace `ThomsonN9.Claude.L2b`):
* `window_rigidity_candidateAt_of_lt`, `window_rigidity_candidate_of_lt`,
  `window_rigidity_candidate_relabel_of_lt` (half width `1/10000`);
* `window_rigidity_candidateAt_eta_of_lt` (refined, any `η ≤ 1/10000`, e.g. `10⁻⁸`);
* `window_rigidity_contact_of_lt` / `window_rigidity_contact_relabel_of_lt`: windows given as
  `|⟪x i, x j⟫ - contactL3 r c| ≤ η` for some `c : Fin 6`.
-/

namespace ThomsonN9.Claude.L2b

open ThomsonN9 ThomsonN9.Claude.Window

/-- Symmetrisation of an ordered-pair window hypothesis (candidate Gram form). -/
theorem hwin_of_lt {r η : ℝ} {x : Configuration}
    (hwin : ∀ i j, i < j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidateAt r a) (candidateAt r b)| ≤ η) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∀ i j, i ≠ j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidateAt r a) (candidateAt r b)| ≤ η) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000 := by
  intro i j hij
  rcases lt_or_gt_of_ne hij with h | h
  · exact hwin i j h
  · rcases hwin j i h with ⟨a, b, hab, hh⟩ | hh
    · left
      refine ⟨b, a, hab.symm, ?_⟩
      rw [real_inner_comm (x j) (x i), real_inner_comm (candidateAt r a) (candidateAt r b)]
      exact hh
    · right
      rw [real_inner_comm (x j) (x i)]
      exact hh

/-- `window_rigidity_candidateAt` from ordered-pair hypotheses. -/
theorem window_rigidity_candidateAt_of_lt {r : ℝ} (hlo : (radiusLower : ℝ) ≤ r)
    (hhi : r ≤ (radiusUpper : ℝ)) (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i < j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidateAt r a) (candidateAt r b)| ≤ 1 / 10000) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x i) (x j) - inner ℝ (candidateAt r (σ i)) (candidateAt r (σ j))| ≤ 1 / 10000 :=
  window_rigidity_candidateAt hlo hhi x hx (hwin_of_lt hwin)

/-- Refined version (`η ≤ 1/10000`, e.g. `η = 10⁻⁸`) from ordered-pair hypotheses. -/
theorem window_rigidity_candidateAt_eta_of_lt {r : ℝ} (hlo : (radiusLower : ℝ) ≤ r)
    (hhi : r ≤ (radiusUpper : ℝ)) {η : ℝ} (hη : η ≤ 1 / 10000) (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i < j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidateAt r a) (candidateAt r b)| ≤ η) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x i) (x j) - inner ℝ (candidateAt r (σ i)) (candidateAt r (σ j))| ≤ η :=
  window_rigidity_candidateAt_eta hlo hhi hη x hx (hwin_of_lt hwin)

/-- `CandidateParameter` version from ordered-pair hypotheses. -/
theorem window_rigidity_candidate_of_lt (r : CandidateParameter) (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i < j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidate r a) (candidate r b)| ≤ 1 / 10000) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x i) (x j) - inner ℝ (candidate r (σ i)) (candidate r (σ j))| ≤ 1 / 10000 :=
  window_rigidity_candidate r x hx (hwin_of_lt (r := (r : ℝ)) hwin)

/-- Relabeled form (reviewer's `u3_relabel_of_lt`), with `IsSphereConfiguration`. -/
theorem window_rigidity_candidate_relabel_of_lt (r : CandidateParameter) (x : Configuration)
    (hx : IsSphereConfiguration x)
    (hwin : ∀ i j, i < j →
      (∃ a b : Fin 9, a ≠ b ∧
        |inner ℝ (x i) (x j) - inner ℝ (candidate r a) (candidate r b)| ≤ 1 / 10000) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ p : Equiv.Perm (Fin 9), ∀ a b,
      |inner ℝ (x (p a)) (x (p b)) - inner ℝ (candidate r a) (candidate r b)| ≤ 1 / 10000 :=
  window_rigidity_candidate_relabel r x hx.1 (hwin_of_lt (r := (r : ℝ)) hwin)

/-! ### Windows in L2's contact form -/

/-- The six contact inner products, literally L2's `ThomsonN9.Bernstein.contact`. -/
noncomputable def contactL3 (r : ℝ) : Fin 6 → ℝ :=
  ![r ^ 2 / 2 - 1, -r, -1 / 2, 2 * r ^ 2 - 1, 1 - 3 * r ^ 2 / 2, r / 2]

/-- Every contact value is an off-diagonal Gram entry of `candidateAt r`. -/
theorem contactL3_eq_inner {r : ℝ} (hr : 0 < r) (hr1 : r < 1) (c : Fin 6) :
    ∃ a b : Fin 9, a ≠ b ∧ inner ℝ (candidateAt r a) (candidateAt r b) = contactL3 r c := by
  fin_cases c
  · refine ⟨0, 4, by decide, ?_⟩
    rw [candidateAt_inner hr hr1 _ _ (by decide)]
    simp [contactL3, palette, refColor]
  · refine ⟨0, 6, by decide, ?_⟩
    rw [candidateAt_inner hr hr1 _ _ (by decide)]
    simp [contactL3, palette, refColor]
  · refine ⟨6, 7, by decide, ?_⟩
    rw [candidateAt_inner hr hr1 _ _ (by decide)]
    simp [contactL3, palette, refColor]
  · refine ⟨0, 3, by decide, ?_⟩
    rw [candidateAt_inner hr hr1 _ _ (by decide)]
    simp [contactL3, palette, refColor]
  · refine ⟨0, 1, by decide, ?_⟩
    rw [candidateAt_inner hr hr1 _ _ (by decide)]
    simp [contactL3, palette, refColor]
  · refine ⟨0, 7, by decide, ?_⟩
    rw [candidateAt_inner hr hr1 _ _ (by decide)]
    simp [contactL3, palette, refColor]

/-- Window rigidity with windows in contact form, ordered pairs, any `η ≤ 1/10000`. -/
theorem window_rigidity_contact_of_lt {r : ℝ} (hlo : (radiusLower : ℝ) ≤ r)
    (hhi : r ≤ (radiusUpper : ℝ)) {η : ℝ} (hη : η ≤ 1 / 10000) (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i < j →
      (∃ c : Fin 6, |inner ℝ (x i) (x j) - contactL3 r c| ≤ η) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j,
      |inner ℝ (x i) (x j) - inner ℝ (candidateAt r (σ i)) (candidateAt r (σ j))| ≤ η := by
  have hL : (0 : ℝ) < (radiusLower : ℝ) := by norm_num [radiusLower]
  have hU : (radiusUpper : ℝ) < 1 := by norm_num [radiusUpper]
  have hr : 0 < r := lt_of_lt_of_le hL hlo
  have hr1 : r < 1 := lt_of_le_of_lt hhi hU
  refine window_rigidity_candidateAt_eta_of_lt hlo hhi hη x hx ?_
  intro i j hij
  rcases hwin i j hij with ⟨c, hc⟩ | h
  · obtain ⟨a, b, hab, he⟩ := contactL3_eq_inner hr hr1 c
    exact Or.inl ⟨a, b, hab, by rw [he]; exact hc⟩
  · exact Or.inr h

/-- Relabeled contact form for the candidate parameter (input of the local theorem). -/
theorem window_rigidity_contact_relabel_of_lt (r : CandidateParameter) {η : ℝ}
    (hη : η ≤ 1 / 10000) (x : Configuration) (hx : IsSphereConfiguration x)
    (hwin : ∀ i j, i < j →
      (∃ c : Fin 6, |inner ℝ (x i) (x j) - contactL3 r c| ≤ η) ∨
      inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ p : Equiv.Perm (Fin 9), ∀ a b,
      |inner ℝ (x (p a)) (x (p b)) - inner ℝ (candidate r a) (candidate r b)| ≤ η := by
  obtain ⟨σ, hσ⟩ := window_rigidity_contact_of_lt r.property.1 r.property.2.1 hη x hx.1 hwin
  refine ⟨σ.symm, fun a b => ?_⟩
  have := hσ (σ.symm a) (σ.symm b)
  simpa [candidate] using this

end ThomsonN9.Claude.L2b

#print axioms ThomsonN9.Claude.L2b.window_rigidity_candidateAt_of_lt
#print axioms ThomsonN9.Claude.L2b.window_rigidity_candidateAt_eta_of_lt
#print axioms ThomsonN9.Claude.L2b.window_rigidity_candidate_of_lt
#print axioms ThomsonN9.Claude.L2b.window_rigidity_candidate_relabel_of_lt
#print axioms ThomsonN9.Claude.L2b.contactL3_eq_inner
#print axioms ThomsonN9.Claude.L2b.window_rigidity_contact_of_lt
#print axioms ThomsonN9.Claude.L2b.window_rigidity_contact_relabel_of_lt
