import ClaudeWindow.WindowKernel
import ClaudeWindow.Soundness
import ClaudeWindow.Geometry
import ClaudeWindow.Antipodal
import ClaudeWindow.AnchorFree

/-!
# Quantitative Gram-window rigidity for nine points (L3 main theorem, Mathlib-only form)

Let `r ∈ [rLo, rHi]` (any real in the certified radius interval).  Let `x : Fin 9 → ℝ³` be
unit vectors such that every distinct-pair inner product lies in one of the seven closed
windows `[palette r c - 1/10000, palette r c + 1/10000]` (`c < 6`) or `[-1, -1 + 1/10000]`.
Then (`window_rigidity_free`) there is a permutation `σ` with
`|⟪xᵢ,xⱼ⟫ - palette r (refColor (σ i) (σ j))| ≤ 1/10000` for all `i ≠ j`, i.e. the Gram
matrix is within `1/10000` of a relabeled P9 Gram matrix (see `Bridge.lean` for the form with
`ThomsonN9.candidateAt`).

Steps: `antipodal_exclusion` (49 cases), `exists_anchor` (some triple has Gram determinant
`> 1/100`; 7 colored `K₄` cases), `window_rigidity` (anchored classification via
`finite_classification` and the kernel-checked certificate).
-/

namespace ThomsonN9.Claude.Window

open Iv

theorem exists_third : ∀ i j : Fin 9, ∃ k : Fin 9, k ≠ i ∧ k ≠ j := by decide

theorem d3R_1uu (u : ℝ) : d3R 1 u u = 0 := by unfold d3R; ring
theorem d3R_u1u (u : ℝ) : d3R u 1 u = 0 := by unfold d3R; ring
theorem d3R_uu1 (u : ℝ) : d3R u u 1 = 0 := by unfold d3R; ring

theorem d3R_perm (u v w : ℝ) :
    d3R v u w = d3R u v w ∧ d3R u w v = d3R u v w ∧ d3R w u v = d3R u v w ∧
      d3R v w u = d3R u v w ∧ d3R w v u = d3R u v w := by
  unfold d3R; exact ⟨by ring, by ring, by ring, by ring, by ring⟩

/-- Reordering an anchor triple so that its three pair colors are sorted. -/
theorem sort3 (col : Fin 9 → Fin 9 → ℕ) (hs : ∀ i j, col i j = col j i) (a b c : Fin 9) :
    ∃ p : Fin 9 × Fin 9 × Fin 9,
      (p = (a, b, c) ∨ p = (a, c, b) ∨ p = (b, a, c) ∨ p = (b, c, a) ∨ p = (c, a, b) ∨
        p = (c, b, a)) ∧
      col p.1 p.2.1 ≤ col p.1 p.2.2 ∧ col p.1 p.2.2 ≤ col p.2.1 p.2.2 := by
  have e1 := hs b a
  have e2 := hs c a
  have e3 := hs c b
  rcases le_total (col a b) (col a c) with h1 | h1 <;>
    rcases le_total (col a c) (col b c) with h2 | h2 <;>
    rcases le_total (col a b) (col b c) with h3 | h3
  all_goals first
    | exact ⟨(a, b, c), Or.inl rfl, by simp only; omega⟩
    | exact ⟨(a, c, b), Or.inr (Or.inl rfl), by simp only [e3]; omega⟩
    | exact ⟨(b, a, c), Or.inr (Or.inr (Or.inl rfl)), by simp only [e1]; omega⟩
    | exact ⟨(b, c, a), Or.inr (Or.inr (Or.inr (Or.inl rfl))), by simp only [e1, e2]; omega⟩
    | exact ⟨(c, a, b), Or.inr (Or.inr (Or.inr (Or.inr (Or.inl rfl)))), by simp only [e2, e3]; omega⟩
    | exact ⟨(c, b, a), Or.inr (Or.inr (Or.inr (Or.inr (Or.inr rfl)))),
        by simp only [e1, e2, e3]; omega⟩

/-- Antipodal exclusion: under the seven-window hypothesis every pair lies in one of the six
palette windows (the window `[-1, -1 + 1/10000]` is empty for pairs). -/
theorem antipodal_exclusion {r : ℝ} (hlo : (rLo : ℝ) ≤ r) (hhi : r ≤ (rHi : ℝ))
    (x : Fin 9 → E3) (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i ≠ j →
      (∃ c : ℕ, c < 6 ∧ |inner ℝ (x i) (x j) - palette r c| ≤ 1 / 10000) ∨
        inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∀ i j, i ≠ j → ∃ c : ℕ, c < 6 ∧ |inner ℝ (x i) (x j) - palette r c| ≤ 1 / 10000 := by
  classical
  -- inner products of unit vectors are ≥ -1
  have hge : ∀ i j, -1 ≤ inner ℝ (x i) (x j) := by
    intro i j
    have h := abs_real_inner_le_norm (x i) (x j)
    rw [hx i, hx j, one_mul] at h
    linarith [(abs_le.mp h).1]
  -- every pair lies in one of the seven boxes
  have hbox7 : ∀ i j, i ≠ j → ∃ c, c < 7 ∧ (box7 c).Mem (inner ℝ (x i) (x j)) := by
    intro i j hij
    rcases hwin i j hij with ⟨c, hc, ht⟩ | ht
    · refine ⟨c, by omega, ?_⟩
      rw [box7, if_pos hc]
      exact window_mem_box hlo hhi hc ht
    · refine ⟨6, by omega, ?_⟩
      rw [box7, if_neg (by norm_num)]
      constructor
      · push_cast; linarith [hge i j]
      · simp only [epsQ]; push_cast; linarith
  -- antipodal exclusion: every pair lies in one of the six palette windows
  intro i j hij
  rcases hwin i j hij with h | ht
  · exact h
  · exfalso
    obtain ⟨k, hki, hkj⟩ := exists_third i j
    obtain ⟨a, ha, hua⟩ := hbox7 i k (Ne.symm hki)
    obtain ⟨b, hb, hvb⟩ := hbox7 j k (Ne.symm hkj)
    have hneg := anti_neg ha hb hua hvb (δ := inner ℝ (x i) (x j) + 1)
      (by linarith [hge i j]) (by linarith)
    rw [show -1 + (inner ℝ (x i) (x j) + 1) = inner ℝ (x i) (x j) by ring] at hneg
    have hpos := gram3_nonneg (x i) (x j) (x k) (hx i) (hx j) (hx k)
    linarith

/-- A triple with Gram determinant `> 1/100` exists among the first four points. -/
theorem exists_anchor {r : ℝ} (hlo : (rLo : ℝ) ≤ r) (hhi : r ≤ (rHi : ℝ))
    (x : Fin 9 → E3) (hx : ∀ i, ‖x i‖ = 1)
    (h6 : ∀ i j, i ≠ j → ∃ c : ℕ, c < 6 ∧ |inner ℝ (x i) (x j) - palette r c| ≤ 1 / 10000) :
    ∃ a b c : Fin 9,
      (1 / 100 : ℝ) < d3R (inner ℝ (x a) (x b)) (inner ℝ (x a) (x c)) (inner ℝ (x b) (x c)) := by
  classical
  let e : Fin 4 → Fin 9 := ![0, 1, 2, 3]
  have he : ∀ i j : Fin 4, i ≠ j → e i ≠ e j := by decide
  let y : Fin 4 → E3 := fun k => x (e k)
  let col : Fin 4 → Fin 4 → ℕ := fun i j =>
    if h : i ≠ j then Classical.choose (h6 (e i) (e j) (he i j h)) else 0
  have hlt : ∀ i j, col i j < 6 := by
    intro i j
    by_cases h : i ≠ j
    · simp only [col, dif_pos h]; exact (Classical.choose_spec (h6 (e i) (e j) (he i j h))).1
    · simp only [col, dif_neg h]; norm_num
  have hmem : ∀ i j, i ≠ j → (box (col i j)).Mem (inner ℝ (y i) (y j)) := by
    intro i j h
    simp only [col, dif_pos h]
    have hs := Classical.choose_spec (h6 (e i) (e j) (he i j h))
    exact window_mem_box hlo hhi hs.1 hs.2
  rcases exists_big_triangle y (fun k => hx (e k)) col hlt hmem with h | h | h | h
  · exact ⟨0, 1, 2, h⟩
  · exact ⟨0, 1, 3, h⟩
  · exact ⟨0, 2, 3, h⟩
  · exact ⟨1, 2, 3, h⟩

theorem window_rigidity {r : ℝ} (hlo : (rLo : ℝ) ≤ r) (hhi : r ≤ (rHi : ℝ))
    (x : Fin 9 → E3) (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i ≠ j →
      (∃ c : ℕ, c < 6 ∧ |inner ℝ (x i) (x j) - palette r c| ≤ 1 / 10000) ∨
        inner ℝ (x i) (x j) ≤ -1 + 1 / 10000)
    (hanchor : ∃ a b c : Fin 9,
      (1 / 100 : ℝ) < d3R (inner ℝ (x a) (x b)) (inner ℝ (x a) (x c)) (inner ℝ (x b) (x c))) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j, i ≠ j →
      |inner ℝ (x i) (x j) - palette r (refColor (σ i) (σ j))| ≤ 1 / 10000 := by
  classical
  have h6 := antipodal_exclusion hlo hhi x hx hwin
  -- 2. the coloring
  let col : Fin 9 → Fin 9 → ℕ := fun i j => if h : i ≠ j then Classical.choose (h6 i j h) else 0
  have hcol : ∀ i j (h : i ≠ j),
      col i j < 6 ∧ |inner ℝ (x i) (x j) - palette r (col i j)| ≤ 1 / 10000 := by
    intro i j h
    simp only [col, dif_pos h]
    exact Classical.choose_spec (h6 i j h)
  have hsymm : ∀ i j, col i j = col j i := by
    intro i j
    by_cases h : i = j
    · subst h; rfl
    · obtain ⟨h1, h2⟩ := hcol i j h
      obtain ⟨h3, h4⟩ := hcol j i (Ne.symm h)
      rw [real_inner_comm] at h4
      exact window_unique hlo hhi h1 h3 h2 h4
  have hmem : ∀ i j, i ≠ j → (box (col i j)).Mem (inner ℝ (x i) (x j)) :=
    fun i j h => window_mem_box hlo hhi (hcol i j h).1 (hcol i j h).2
  -- 3. the anchor, distinct and with sorted colors
  obtain ⟨a, b, c, hd⟩ := hanchor
  have hθ : (0 : ℝ) < 1 / 100 := by norm_num
  have hab : a ≠ b := by
    rintro rfl
    rw [real_inner_self_eq_norm_sq, hx, one_pow, d3R_1uu] at hd
    linarith
  have hac : a ≠ c := by
    rintro rfl
    rw [real_inner_self_eq_norm_sq, hx, one_pow, real_inner_comm, d3R_u1u] at hd
    linarith
  have hbc : b ≠ c := by
    rintro rfl
    rw [real_inner_self_eq_norm_sq, hx, one_pow, d3R_uu1] at hd
    linarith
  obtain ⟨⟨a0, a1, a2⟩, hp, hs1, hs2⟩ := sort3 col hsymm a b c
  have eab := real_inner_comm (x a) (x b)
  have eac := real_inner_comm (x a) (x c)
  have ebc := real_inner_comm (x b) (x c)
  have hperm := d3R_perm (inner ℝ (x a) (x b)) (inner ℝ (x a) (x c)) (inner ℝ (x b) (x c))
  have hA : (1 / 100 : ℝ) <
        d3R (inner ℝ (x a0) (x a1)) (inner ℝ (x a0) (x a2)) (inner ℝ (x a1) (x a2)) ∧
      a0 ≠ a1 ∧ a0 ≠ a2 ∧ a1 ≠ a2 := by
    rcases hp with h | h | h | h | h | h <;> simp only [Prod.mk.injEq] at h <;>
      obtain ⟨rfl, rfl, rfl⟩ := h <;> refine ⟨?_, ?_, ?_, ?_⟩ <;>
      first
      | exact hab | exact hac | exact hbc | exact hab.symm | exact hac.symm | exact hbc.symm
      | exact hd
      | (simp only [eab, eac, ebc, hperm.1, hperm.2.1, hperm.2.2.1, hperm.2.2.2.1,
          hperm.2.2.2.2]; exact hd)
  obtain ⟨hdA, d01, d02, d12⟩ := hA
  -- 4. the hypotheses of the finite theorem
  have hH : ColHyp box thetaQ col a0 a1 a2 := by
    refine ⟨hsymm, fun i j h => (hcol i j h).1, d01, d02, d12, hs1, hs2, ?_, ?_, ?_⟩
    · have hm := mem_d3 (hmem a0 a1 d01) (hmem a0 a2 d02) (hmem a1 a2 d12)
      have h' : ((thetaQ : ℚ) : ℝ) < ((aD box (col a0 a1) (col a0 a2) (col a1 a2)).hi : ℝ) := by
        have : ((thetaQ : ℚ) : ℝ) = 1 / 100 := by simp only [thetaQ]; push_cast; ring
        rw [this]
        exact lt_of_lt_of_le hdA hm.2
      exact_mod_cast h'
    · intro k k0 k1 k2
      apply Iv.not_excl_of_mem_zero
      have hm := mem_norm (hmem a0 a1 d01) (hmem a0 a2 d02) (hmem a1 a2 d12)
        (hmem k a0 k0) (hmem k a1 k1) (hmem k a2 k2)
      rw [normR_eq_zero (x a0) (x a1) (x a2) (x k) (hx a0) (hx a1) (hx a2) (hx k)] at hm
      exact hm
    · intro k l k0 k1 k2 l0 l1 l2 hkl
      apply Iv.not_excl_of_mem_zero
      have hw0 : (box (col l a0)).Mem (inner ℝ (x a0) (x l)) := by
        rw [real_inner_comm]; exact hmem l a0 l0
      have hw1 : (box (col l a1)).Mem (inner ℝ (x a1) (x l)) := by
        rw [real_inner_comm]; exact hmem l a1 l1
      have hw2 : (box (col l a2)).Mem (inner ℝ (x a2) (x l)) := by
        rw [real_inner_comm]; exact hmem l a2 l2
      have hm := mem_pair (hmem a0 a1 d01) (hmem a0 a2 d02) (hmem a1 a2 d12)
        (hmem k a0 k0) (hmem k a1 k1) (hmem k a2 k2) hw0 hw1 hw2 (hmem k l hkl)
      rw [pairR_eq_zero (x a0) (x a1) (x a2) (x k) (x l) (hx a0) (hx a1) (hx a2)] at hm
      exact hm
  -- 5. the finite classification
  obtain ⟨σ, hσ⟩ := finite_classification coverage_ok records_ok hH
  refine ⟨σ, fun i j hij => ?_⟩
  rw [← hσ i j hij]
  exact (hcol i j hij).2

/-- **Main theorem (anchor-free).**  Nine unit vectors in `ℝ³` whose 36 pair inner products
each lie in one of the seven closed windows (half-width `1/10000` around the six P9 values at
radius `r`, or `[-1, -1 + 1/10000]`) have the P9 Gram pattern up to relabeling, within
`1/10000` entrywise. -/
theorem window_rigidity_free {r : ℝ} (hlo : (rLo : ℝ) ≤ r) (hhi : r ≤ (rHi : ℝ))
    (x : Fin 9 → E3) (hx : ∀ i, ‖x i‖ = 1)
    (hwin : ∀ i j, i ≠ j →
      (∃ c : ℕ, c < 6 ∧ |inner ℝ (x i) (x j) - palette r c| ≤ 1 / 10000) ∨
        inner ℝ (x i) (x j) ≤ -1 + 1 / 10000) :
    ∃ σ : Equiv.Perm (Fin 9), ∀ i j, i ≠ j →
      |inner ℝ (x i) (x j) - palette r (refColor (σ i) (σ j))| ≤ 1 / 10000 :=
  window_rigidity hlo hhi x hx hwin
    (exists_anchor hlo hhi x hx (antipodal_exclusion hlo hhi x hx hwin))

end ThomsonN9.Claude.Window
