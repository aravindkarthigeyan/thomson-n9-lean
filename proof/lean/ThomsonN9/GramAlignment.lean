import ThomsonN9.Alignment
import ThomsonN9.GramSchmidtFrame
import ThomsonN9.GramStability

/-! From labeled Gram closeness to a nearby minimizing orthogonal alignment. -/

namespace ThomsonN9

set_option autoImplicit false

noncomputable def triangularScalarData (x y z w : R3)
    (hx : ‖x‖=1) (hy : ‖y‖=1) (hz : ‖z‖=1) (hw : ‖w‖=1)
    (hxy : |inner ℝ x y| ≤ (1/3 : ℝ))
    (hxz : |inner ℝ x z| ≤ (1/3 : ℝ))
    (hyz : |inner ℝ y z| ≤ (1/3 : ℝ)) : TriangularScalarData where
  a := inner ℝ x y
  d := inner ℝ x z
  e := inner ℝ y z
  u := inner ℝ x w
  v := inner ℝ y w
  w := inner ℝ z w
  s := gsLength x y
  t := ‖gsFinalResidual x y z‖
  b := inner ℝ (gsUnit x y) z
  y := (gsBasis x y z).repr w 1
  z := (gsBasis x y z).repr w 2
  ha := by simpa [hx, hy] using abs_real_inner_le_norm x y
  hd := by simpa [hx, hz] using abs_real_inner_le_norm x z
  he := by simpa [hy, hz] using abs_real_inner_le_norm y z
  hu := by simpa [hx, hw] using abs_real_inner_le_norm x w
  hv := by simpa [hy, hw] using abs_real_inner_le_norm y w
  hw := by simpa [hz, hw] using abs_real_inner_le_norm z w
  hb := by
    have hs : 0 < gsLength x y := lt_of_lt_of_le (by norm_num) (gsLength_lower hx hy hxy)
    simpa [gsUnit_norm hs, hz] using abs_real_inner_le_norm (gsUnit x y) z
  hy := by
    rw [OrthonormalBasis.repr_apply_apply]
    simpa [hw, (gsBasis x y z).orthonormal.norm_eq_one] using
      abs_real_inner_le_norm (gsBasis x y z 1) w
  hs := le_trans (by norm_num) (gsLength_lower hx hy hxy)
  ht := le_trans (by norm_num) (gsFinalResidual_norm_lower hx hy hz hxy hxz hyz)
  s_sq := gsLength_sq hx hy
  b_eq := gsUnit_inner_formula x y z
  t_sq := gsFinalResidual_norm_sq hx hz
    (lt_of_lt_of_le (by norm_num) (gsLength_lower hx hy hxy))
  y_eq := (gsBasis_coordinates hx hy hz hxy hxz hyz w).2.1
  z_eq := (gsBasis_coordinates hx hy hz hxy hxz hyz w).2.2

theorem gram_close_basis_coordinates {x p : Configuration} {δ : ℝ}
    (hx : ∀ i, ‖x i‖=1) (hp : ∀ i, ‖p i‖=1) (hδ : 0 ≤ δ)
    (hg : ∀ i j, |inner ℝ (x i) (x j)-inner ℝ (p i) (p j)| ≤ δ)
    (hx01 : |inner ℝ (x 0) (x 1)| ≤ (1/3 : ℝ))
    (hx02 : |inner ℝ (x 0) (x 2)| ≤ (1/3 : ℝ))
    (hx12 : |inner ℝ (x 1) (x 2)| ≤ (1/3 : ℝ))
    (hp01 : |inner ℝ (p 0) (p 1)| ≤ (1/3 : ℝ))
    (hp02 : |inner ℝ (p 0) (p 2)| ≤ (1/3 : ℝ))
    (hp12 : |inner ℝ (p 1) (p 2)| ≤ (1/3 : ℝ)) :
    ∀ i j, |((gsBasis (x 0) (x 1) (x 2)).repr (x i)) j-
      ((gsBasis (p 0) (p 1) (p 2)).repr (p i)) j| ≤ 650*δ := by
  intro i j
  let A := triangularScalarData (x 0) (x 1) (x 2) (x i)
    (hx 0) (hx 1) (hx 2) (hx i) hx01 hx02 hx12
  let B := triangularScalarData (p 0) (p 1) (p 2) (p i)
    (hp 0) (hp 1) (hp 2) (hp i) hp01 hp02 hp12
  have hab := triangular_scalar_stability A B (hg 0 1) (hg 0 2) (hg 1 2)
    (hg 0 i) (hg 1 i) (hg 2 i)
  have hA := gsBasis_coordinates (hx 0) (hx 1) (hx 2) hx01 hx02 hx12 (x i)
  have hB := gsBasis_coordinates (hp 0) (hp 1) (hp 2) hp01 hp02 hp12 (p i)
  fin_cases j
  · change |((gsBasis (x 0) (x 1) (x 2)).repr (x i)) 0-
      ((gsBasis (p 0) (p 1) (p 2)).repr (p i)) 0| ≤ 650*δ
    rw [hA.1, hB.1]
    linarith [hg 0 i]
  · change |A.y-B.y| ≤ 650*δ
    linarith [hab.1]
  · change |A.z-B.z| ≤ 650*δ
    linarith [hab.2]

theorem gram_close_exists_alignment {x p : Configuration} {δ : ℝ}
    (hx : ∀ i, ‖x i‖=1) (hp : ∀ i, ‖p i‖=1) (hδ : 0 ≤ δ)
    (hg : ∀ i j, |inner ℝ (x i) (x j)-inner ℝ (p i) (p j)| ≤ δ)
    (hx01 : |inner ℝ (x 0) (x 1)| ≤ (1/3 : ℝ))
    (hx02 : |inner ℝ (x 0) (x 2)| ≤ (1/3 : ℝ))
    (hx12 : |inner ℝ (x 1) (x 2)| ≤ (1/3 : ℝ))
    (hp01 : |inner ℝ (p 0) (p 1)| ≤ (1/3 : ℝ))
    (hp02 : |inner ℝ (p 0) (p 2)| ≤ (1/3 : ℝ))
    (hp12 : |inner ℝ (p 1) (p 2)| ≤ (1/3 : ℝ)) :
    ∃ Q : R3 ≃ₗᵢ[ℝ] R3, (∑ i, ‖Q (x i)-p i‖^2) ≤ (10000*δ)^2 := by
  let X := gsBasis (x 0) (x 1) (x 2)
  let P := gsBasis (p 0) (p 1) (p 2)
  let Q : R3 ≃ₗᵢ[ℝ] R3 := X.repr.trans P.repr.symm
  have hc := gram_close_basis_coordinates hx hp hδ hg hx01 hx02 hx12 hp01 hp02 hp12
  have hh := configuration_difference_from_coordinates hδ hc
  refine ⟨Q, ?_⟩
  calc
    (∑ i, ‖Q (x i)-p i‖^2) = ∑ i, ‖P.repr (Q (x i)-p i)‖^2 := by
      simp only [LinearIsometryEquiv.norm_map]
    _ = ∑ i, ‖X.repr (x i)-P.repr (p i)‖^2 := by
      simp only [map_sub, Q, LinearIsometryEquiv.trans_apply,
        LinearIsometryEquiv.apply_symm_apply]
    _ ≤ (10000*δ)^2 := hh

theorem gram_close_exists_minimal_alignment {x p : Configuration} {δ : ℝ}
    (hx : ∀ i, ‖x i‖=1) (hp : ∀ i, ‖p i‖=1) (hδ : 0 ≤ δ)
    (hg : ∀ i j, |inner ℝ (x i) (x j)-inner ℝ (p i) (p j)| ≤ δ)
    (hx01 : |inner ℝ (x 0) (x 1)| ≤ (1/3 : ℝ))
    (hx02 : |inner ℝ (x 0) (x 2)| ≤ (1/3 : ℝ))
    (hx12 : |inner ℝ (x 1) (x 2)| ≤ (1/3 : ℝ))
    (hp01 : |inner ℝ (p 0) (p 1)| ≤ (1/3 : ℝ))
    (hp02 : |inner ℝ (p 0) (p 2)| ≤ (1/3 : ℝ))
    (hp12 : |inner ℝ (p 1) (p 2)| ≤ (1/3 : ℝ)) :
    ∃ Q : R3 ≃ₗᵢ[ℝ] R3, IsMinimalAlignment (fun i => Q (x i)) p ∧
      (∑ i, ‖Q (x i)-p i‖^2) ≤ (10000*δ)^2 := by
  obtain ⟨T, hT⟩ := gram_close_exists_alignment hx hp hδ hg hx01 hx02 hx12 hp01 hp02 hp12
  obtain ⟨Q, hQ⟩ := exists_minimal_alignment x p
  refine ⟨Q, ?_, (hQ T).trans hT⟩
  intro U
  simpa only [LinearIsometryEquiv.trans_apply] using hQ (Q.trans U)

end ThomsonN9
