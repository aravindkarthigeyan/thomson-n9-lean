import ClaudeL2b.RefinedWindows
import ClaudeL2b.WindowAdapter
import ThomsonN9.Endgame

/-!
# Localization chain with `h_new`: coarse windows, L3 rigidity, refined windows

Compiled against `combined/` (read-only copies of Codex's compiled `ThomsonN9.*` oleans plus
L2's `ThomsonN9.Bernstein.*` oleans; both live under the module root `ThomsonN9`).

`refined_relabel`: let `x` be a sphere configuration and `r : CandidateParameter`. Assume the
energy chain `pairSum ‖xᵢ-xⱼ‖⁻¹ ≤ E ≤ U`, `U - loss ≤ pairSum (h_new ∘ ⟪xᵢ,xⱼ⟫)` with
`loss < 10⁻⁴⁶` (this is what L1 plus Codex's `coulomb_from_triple_certificate` provide), and
the LP separation `⟪xᵢ,xⱼ⟫ < 5593/10000` for `i < j` (Codex's `inner_lt_separation`).
Then some relabeling `p` gives `|⟪x (p a), x (p b)⟫ - ⟪candidate r a, candidate r b⟫| ≤ 10⁻⁸`
for all `a, b`.

Steps: (1) `pair_slack_localization` with `exterior_gap_new` (gap `10⁻⁴⁶`) puts every pair in
a `10⁻⁴` window or the antipodal window; (2) L3 (`window_rigidity_contact_of_lt`) excludes the
antipodal window and puts every pair within `10⁻⁴` of a candidate Gram entry, hence in
`[-3/4, 5593/10000]`; (3) `pair_slack_localization` with `refined_gap_new` (gap `10⁻³³`)
puts every pair in a `10⁻⁸` window; (4) L3 with `η = 10⁻⁸`.
-/

namespace ThomsonN9.Claude.L2b

open ThomsonN9 ThomsonN9.Bernstein ThomsonN9.Claude.Window

/-- The pair minorant used by the final assembly. -/
noncomputable def hpairNew (x : Configuration) (i j : Fin 9) : ℝ := hNew (inner ℝ (x i) (x j))

theorem hpairNew_le {x : Configuration} (hx : IsSphereConfiguration x) :
    ∀ i j, i ≠ j → hpairNew x i j ≤ (‖x i - x j‖)⁻¹ := fun i j hij =>
  hNew_le_inv_dist (hx.1 i) (hx.1 j) (fun h => hij (hx.2 h))

theorem hpairNew_symm (x : Configuration) : ∀ i j, hpairNew x i j = hpairNew x j i := by
  intro i j; simp only [hpairNew, real_inner_comm]

theorem contact_eq_contactL3 (r : ℝ) : contact r = contactL3 r := rfl

/-- Coarse windows (half width `10⁻⁴`), antipodal window, or above the LP bound. -/
def InWindow (r t : ℝ) : Prop :=
  t < -1 + 1 / 10000 ∨ 5593 / 10000 < t ∨ ∃ j : Fin 6, |t - contact r j| < 1 / 10000

/-- Refined windows (half width `10⁻⁸`), below `-3/4`, or above the LP bound. -/
def InRefined (r t : ℝ) : Prop :=
  t < -3 / 4 ∨ 5593 / 10000 < t ∨ ∃ j : Fin 6, |t - contact r j| < 1 / 100000000

theorem localize_coarse (x : Configuration) (hx : IsSphereConfiguration x)
    (r : CandidateParameter) (E U loss : ℝ)
    (henergy : pairSum (fun i j => (‖x i - x j‖)⁻¹) ≤ E) (hupper : E ≤ U)
    (hbound : U - loss ≤ pairSum (hpairNew x)) (hgap : loss < 1 / 10 ^ 46) :
    ∀ i j, i < j → InWindow r (inner ℝ (x i) (x j)) := by
  refine pair_slack_localization (fun i j => (‖x i - x j‖)⁻¹) (hpairNew x)
    (fun i j => InWindow r (inner ℝ (x i) (x j))) E U loss (1 / 10 ^ 46)
    (fun i j hij => hpairNew_le hx i j (ne_of_lt hij)) ?_ henergy hupper hbound hgap
  intro i j hij hout
  have hxy : x i ≠ x j := fun h => (ne_of_lt hij) (hx.2 h)
  simp only [InWindow, not_or, not_exists, not_lt] at hout
  obtain ⟨h1, h2, h3⟩ := hout
  have e1 : rLower = radiusLower := rfl
  have e2 : rUpper = radiusUpper := rfl
  show 1 / 10 ^ 46 ≤ (‖x i - x j‖)⁻¹ - hNew (inner ℝ (x i) (x j))
  rw [← phi_inner (hx.1 i) (hx.1 j) hxy]
  exact exterior_gap_new (r := (r : ℝ)) (by rw [e1]; exact r.property.1)
    (by rw [e2]; exact r.property.2.1) h1 h2 h3

theorem localize_refined (x : Configuration) (hx : IsSphereConfiguration x)
    (r : CandidateParameter) (E U loss : ℝ)
    (henergy : pairSum (fun i j => (‖x i - x j‖)⁻¹) ≤ E) (hupper : E ≤ U)
    (hbound : U - loss ≤ pairSum (hpairNew x)) (hgap : loss < 1 / 10 ^ 33) :
    ∀ i j, i < j → InRefined r (inner ℝ (x i) (x j)) := by
  refine pair_slack_localization (fun i j => (‖x i - x j‖)⁻¹) (hpairNew x)
    (fun i j => InRefined r (inner ℝ (x i) (x j))) E U loss (1 / 10 ^ 33)
    (fun i j hij => hpairNew_le hx i j (ne_of_lt hij)) ?_ henergy hupper hbound hgap
  intro i j hij hout
  have hxy : x i ≠ x j := fun h => (ne_of_lt hij) (hx.2 h)
  simp only [InRefined, not_or, not_exists, not_lt] at hout
  obtain ⟨h1, h2, h3⟩ := hout
  have e1 : rLower = radiusLower := rfl
  have e2 : rUpper = radiusUpper := rfl
  show 1 / 10 ^ 33 ≤ (‖x i - x j‖)⁻¹ - hNew (inner ℝ (x i) (x j))
  rw [← phi_inner (hx.1 i) (hx.1 j) hxy]
  exact refined_gap_new (r := (r : ℝ)) (by rw [e1]; exact r.property.1)
    (by rw [e2]; exact r.property.2.1) h1 h2 h3

/-- Every P9 inner product is at least `r²/2 - 1` (for `r ∈ [0, 1]`; here `r ≈ 0.7106`). -/
theorem palette_ge {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 72 / 100) :
    ∀ c : ℕ, c < 6 → r ^ 2 / 2 - 1 ≤ palette r c := by
  intro c hc
  interval_cases c <;> simp only [palette] <;> nlinarith

/-- **Refined localization with `h_new`** (relabeled form, error `10⁻⁸`). -/
theorem refined_relabel (x : Configuration) (hx : IsSphereConfiguration x)
    (r : CandidateParameter) (E U loss : ℝ)
    (henergy : pairSum (fun i j => (‖x i - x j‖)⁻¹) ≤ E) (hupper : E ≤ U)
    (hbound : U - loss ≤ pairSum (hpairNew x)) (hgap : loss < 1 / 10 ^ 46)
    (hsep : ∀ i j, i < j → inner ℝ (x i) (x j) < 5593 / 10000) :
    ∃ p : Equiv.Perm (Fin 9), ∀ a b,
      |inner ℝ (x (p a)) (x (p b)) - inner ℝ (candidate r a) (candidate r b)| ≤ 1 / 100000000 := by
  have hlo : (radiusLower : ℝ) ≤ (r : ℝ) := r.property.1
  have hhi : (r : ℝ) ≤ (radiusUpper : ℝ) := r.property.2.1
  have hL : (7 / 10 : ℝ) ≤ (radiusLower : ℝ) := by norm_num [radiusLower]
  have hU : (radiusUpper : ℝ) ≤ 72 / 100 := by norm_num [radiusUpper]
  have hr0 : (0 : ℝ) < r := by linarith
  have hr1 : (r : ℝ) < 1 := by linarith
  -- (1) coarse localization
  have hc := localize_coarse x hx r E U loss henergy hupper hbound hgap
  have hw1 : ∀ i j, i < j →
      (∃ c : Fin 6, |inner ℝ (x i) (x j) - contactL3 r c| ≤ 1 / 10000) ∨
        inner ℝ (x i) (x j) ≤ -1 + 1 / 10000 := by
    intro i j hij
    rcases hc i j hij with h | h | ⟨c, hcj⟩
    · exact Or.inr h.le
    · exact absurd (hsep i j hij) (not_lt.2 h.le)
    · exact Or.inl ⟨c, hcj.le⟩
  -- (2) L3: every pair within 10⁻⁴ of a candidate Gram entry, hence ≥ -3/4
  obtain ⟨σ, hσ⟩ := window_rigidity_contact_of_lt hlo hhi (le_refl _) x hx.1 hw1
  have hrange : ∀ i j, i ≠ j → -3 / 4 ≤ inner ℝ (x i) (x j) := by
    intro i j hij
    have hne : σ i ≠ σ j := fun e => hij (σ.injective e)
    have h1 := hσ i j
    rw [candidateAt_inner hr0 hr1 _ _ hne] at h1
    have hlt := refColor_lt6 _ (σ i).isLt _ (σ j).isLt (fun e => hne (Fin.ext e))
    have hp := palette_ge hr0.le (by linarith) _ hlt
    have hsq : (radiusLower : ℝ) * radiusLower ≤ (r : ℝ) ^ 2 := by nlinarith
    have hL2 : (-3 / 4 : ℝ) + 1 / 10000 ≤ (radiusLower : ℝ) * radiusLower / 2 - 1 := by
      norm_num [radiusLower]
    have := (abs_le.1 h1).1
    linarith
  -- (3) refined localization
  have hr := localize_refined x hx r E U loss henergy hupper hbound
    (lt_trans hgap (by norm_num))
  have hw2 : ∀ i j, i < j →
      (∃ c : Fin 6, |inner ℝ (x i) (x j) - contactL3 r c| ≤ 1 / 100000000) ∨
        inner ℝ (x i) (x j) ≤ -1 + 1 / 10000 := by
    intro i j hij
    rcases hr i j hij with h | h | ⟨c, hcj⟩
    · exact absurd (hrange i j (ne_of_lt hij)) (not_le.2 h)
    · exact absurd (hsep i j hij) (not_lt.2 h.le)
    · exact Or.inl ⟨c, hcj.le⟩
  -- (4) L3 with η = 10⁻⁸
  exact window_rigidity_contact_relabel_of_lt r (by norm_num) x hx hw2

end ThomsonN9.Claude.L2b

#print axioms ThomsonN9.Claude.L2b.localize_coarse
#print axioms ThomsonN9.Claude.L2b.localize_refined
#print axioms ThomsonN9.Claude.L2b.refined_relabel
