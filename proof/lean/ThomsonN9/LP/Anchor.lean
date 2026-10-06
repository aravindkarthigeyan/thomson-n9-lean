import ThomsonN9.LP.Covariance
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic

/-!
A quantitative nondegenerate anchor from the LP covariance estimate.
The proof uses explicit three-dimensional determinants and all ordered triples;
it does not assume a spectral bound or a preselected independent triple.
-/

namespace ThomsonN9.Anchor

noncomputable def tripleSum (F : Fin 9 → Fin 9 → Fin 9 → Real) : Real :=
  ∑ i, ∑ j, ∑ k, F i j k

noncomputable def quad (x : Configuration) (i : Fin 9) (a b : Fin 3) : Real :=
  x i a * x i b

noncomputable def volume (x : Configuration) (i j k : Fin 9) : Real :=
  x i 0*x j 1*x k 2 + x i 1*x j 2*x k 0 + x i 2*x j 0*x k 1 -
  x i 2*x j 1*x k 0 - x i 1*x j 0*x k 2 - x i 0*x j 2*x k 1

noncomputable def covarianceMatrix (x : Configuration) : Matrix (Fin 3) (Fin 3) Real :=
  fun a b => covarianceEntry x a b

@[simp] theorem covarianceMatrix_apply (x : Configuration) (a b : Fin 3) :
    covarianceMatrix x a b = covarianceEntry x a b := rfl

theorem tripleSum_add (F G : Fin 9 → Fin 9 → Fin 9 → Real) :
    tripleSum (fun i j k => F i j k + G i j k) = tripleSum F + tripleSum G := by
  simp only [tripleSum, Finset.sum_add_distrib]

theorem tripleSum_sub (F G : Fin 9 → Fin 9 → Fin 9 → Real) :
    tripleSum (fun i j k => F i j k - G i j k) = tripleSum F - tripleSum G := by
  simp only [tripleSum, Finset.sum_sub_distrib]

theorem tripleSum_smul (c : Real) (F : Fin 9 → Fin 9 → Fin 9 → Real) :
    tripleSum (fun i j k => c * F i j k) = c * tripleSum F := by
  simp only [tripleSum, Finset.mul_sum]

theorem tripleSum_quad (x : Configuration) (a b c d e f : Fin 3) :
    tripleSum (fun i j k => quad x i a b * quad x j c d * quad x k e f) =
      covarianceEntry x a b * covarianceEntry x c d * covarianceEntry x e f := by
  unfold tripleSum
  calc
    _ = ∑ i : Fin 9, ∑ j : Fin 9,
        (quad x i a b * quad x j c d)*(∑ k : Fin 9, quad x k e f) := by
      simp only [Finset.mul_sum]
    _ = (∑ i : Fin 9, ∑ j : Fin 9, quad x i a b * quad x j c d)*
        (∑ k : Fin 9, quad x k e f) := by
      simp only [Finset.sum_mul]
    _ = (∑ i : Fin 9, quad x i a b)*(∑ j : Fin 9, quad x j c d)*
        (∑ k : Fin 9, quad x k e f) := by
      have hq : (∑ i : Fin 9, quad x i a b)*(∑ j : Fin 9, quad x j c d) =
          ∑ i : Fin 9, ∑ j : Fin 9, quad x i a b * quad x j c d := by
        rw [Finset.sum_mul_sum]
      exact congrArg (fun z : Real => z*(∑ k : Fin 9, quad x k e f)) hq.symm
    _ = _ := rfl

theorem volume_sq_expansion (x : Configuration) (i j k : Fin 9) :
    (volume x i j k)^2 =
      (quad x i 0 0 * quad x j 1 1 * quad x k 2 2)
       + 2 * (quad x i 0 1 * quad x j 1 2 * quad x k 0 2)
       + 2 * (quad x i 0 2 * quad x j 0 1 * quad x k 1 2)
       - 2 * (quad x i 0 2 * quad x j 1 1 * quad x k 0 2)
       - 2 * (quad x i 0 1 * quad x j 0 1 * quad x k 2 2)
       - 2 * (quad x i 0 0 * quad x j 1 2 * quad x k 1 2)
       + (quad x i 1 1 * quad x j 2 2 * quad x k 0 0)
       + 2 * (quad x i 1 2 * quad x j 0 2 * quad x k 0 1)
       - 2 * (quad x i 1 2 * quad x j 1 2 * quad x k 0 0)
       - 2 * (quad x i 1 1 * quad x j 0 2 * quad x k 0 2)
       - 2 * (quad x i 0 1 * quad x j 2 2 * quad x k 0 1)
       + (quad x i 2 2 * quad x j 0 0 * quad x k 1 1)
       - 2 * (quad x i 2 2 * quad x j 0 1 * quad x k 0 1)
       - 2 * (quad x i 1 2 * quad x j 0 0 * quad x k 1 2)
       - 2 * (quad x i 0 2 * quad x j 0 2 * quad x k 1 1)
       + (quad x i 2 2 * quad x j 1 1 * quad x k 0 0)
       + 2 * (quad x i 1 2 * quad x j 0 1 * quad x k 0 2)
       + 2 * (quad x i 0 2 * quad x j 1 2 * quad x k 0 1)
       + (quad x i 1 1 * quad x j 0 0 * quad x k 2 2)
       + 2 * (quad x i 0 1 * quad x j 0 2 * quad x k 1 2)
       + (quad x i 0 0 * quad x j 2 2 * quad x k 1 1) := by
  unfold volume quad
  ring

theorem covarianceEntry_symm (x : Configuration) (a b : Fin 3) :
    covarianceEntry x a b = covarianceEntry x b a := by
  unfold covarianceEntry
  exact Finset.sum_congr rfl fun i _ => mul_comm _ _

theorem volume_square_sum (x : Configuration) :
    tripleSum (fun i j k => (volume x i j k)^2) =
      6*Matrix.det (covarianceMatrix x) := by
  simp only [volume_sq_expansion, tripleSum_add, tripleSum_sub, tripleSum_smul,
    tripleSum_quad, Matrix.det_fin_three, covarianceMatrix_apply]
  rw [covarianceEntry_symm x 1 0, covarianceEntry_symm x 2 0,
    covarianceEntry_symm x 2 1]
  ring

theorem covariance_det_gt (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hc : covarianceDeviation x < (1/4 : Real)) :
    (207/8 : Real) < Matrix.det (covarianceMatrix x) := by
  let B : Matrix (Fin 3) (Fin 3) Real :=
    fun a b => covarianceEntry x a b - if a = b then 3 else 0
  have hb (a b : Fin 3) : (B a b)^2 < (1/4 : Real) := by
    apply lt_of_le_of_lt _ hc
    exact (Finset.single_le_sum (fun c _ => sq_nonneg (B a c))
      (Finset.mem_univ b)).trans
      (Finset.single_le_sum (fun a _ => Finset.sum_nonneg fun c _ => sq_nonneg (B a c))
      (Finset.mem_univ a))
  have habs (a b : Fin 3) : |B a b| < (1/2 : Real) := by
    apply abs_lt.mpr
    constructor <;> nlinarith [hb a b, sq_nonneg (B a b - 1/2),
      sq_nonneg (B a b + 1/2)]
  have hp (a b c d e f : Fin 3) : |B a b*B c d*B e f| < (1/8 : Real) := by
    calc
      _ = |B a b| * |B c d| * |B e f| := by simp only [abs_mul]
      _ < (1/2 : Real)*(1/2)*(1/2) := by gcongr <;> exact habs _ _
      _ = _ := by norm_num
  have hd : -(3/4 : Real) < Matrix.det B := by
    rw [Matrix.det_fin_three]
    have h1 := (abs_lt.mp (hp 0 0 1 1 2 2)).1
    have h2 := (abs_lt.mp (hp 0 0 1 2 2 1)).2
    have h3 := (abs_lt.mp (hp 0 1 1 0 2 2)).2
    have h4 := (abs_lt.mp (hp 0 1 1 2 2 0)).1
    have h5 := (abs_lt.mp (hp 0 2 1 0 2 1)).1
    have h6 := (abs_lt.mp (hp 0 2 1 1 2 0)).2
    linarith
  have ht := covariance_trace x hx
  simp only [Fin.sum_univ_three] at ht
  have ht2 : (covarianceEntry x 0 0 + covarianceEntry x 1 1 +
      covarianceEntry x 2 2)^2 = 81 := by
    rw [ht]
    norm_num
  have hid : Matrix.det (covarianceMatrix x) =
      27 - (3/2 : Real)*covarianceDeviation x + Matrix.det B := by
    rw [Matrix.det_fin_three (covarianceMatrix x), Matrix.det_fin_three B]
    simp only [covarianceMatrix_apply, B, covarianceDeviation, Fin.sum_univ_three]
    norm_num
    rw [covarianceEntry_symm x 1 0, covarianceEntry_symm x 2 0,
      covarianceEntry_symm x 2 1]
    nlinarith [ht2]
  rw [hid]
  linarith

theorem exists_large_volume (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hc : covarianceDeviation x < (1/4 : Real)) :
    ∃ i j k : Fin 9, (125/672 : Real) < (volume x i j k)^2 := by
  by_contra h
  push_neg at h
  have hs : tripleSum (fun i j k => (volume x i j k)^2) ≤
      729*(125/672 : Real) := by
    calc
      _ ≤ ∑ _i : Fin 9, ∑ _j : Fin 9, ∑ _k : Fin 9, (125/672 : Real) := by
        exact Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ =>
          Finset.sum_le_sum fun k _ => h i j k
      _ = _ := by norm_num
  rw [volume_square_sum] at hs
  have hd := covariance_det_gt x hx hc
  linarith

theorem volume_square_eq_gram (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (i j k : Fin 9) :
    (volume x i j k)^2 =
      1 + 2*inner Real (x i) (x j)*inner Real (x i) (x k)*inner Real (x j) (x k) -
        (inner Real (x i) (x j))^2 - (inner Real (x i) (x k))^2 -
        (inner Real (x j) (x k))^2 := by
  have hn (a : Fin 9) : (x a 0)^2 + (x a 1)^2 + (x a 2)^2 = 1 := by
    have h := congrArg (fun z : Real => z^2) (hx a)
    simpa [EuclideanSpace.norm_sq_eq, Fin.sum_univ_three] using h
  have hid : (volume x i j k)^2 =
      ((x i 0)^2 + (x i 1)^2 + (x i 2)^2)*
      ((x j 0)^2 + (x j 1)^2 + (x j 2)^2)*
      ((x k 0)^2 + (x k 1)^2 + (x k 2)^2) +
      2*inner Real (x i) (x j)*inner Real (x i) (x k)*inner Real (x j) (x k) -
      ((x k 0)^2 + (x k 1)^2 + (x k 2)^2)*(inner Real (x i) (x j))^2 -
      ((x j 0)^2 + (x j 1)^2 + (x j 2)^2)*(inner Real (x i) (x k))^2 -
      ((x i 0)^2 + (x i 1)^2 + (x i 2)^2)*(inner Real (x j) (x k))^2 := by
    simp only [volume, inner_eq_coordinate_sum, Fin.sum_univ_three]
    ring
  simpa only [hn, one_mul, mul_one] using hid

theorem exists_nondegenerate_anchor (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hc : covarianceDeviation x < (1/4 : Real)) :
    ∃ i j k : Fin 9, i ≠ j ∧ i ≠ k ∧ j ≠ k ∧
      (125/672 : Real) <
      1 + 2*inner Real (x i) (x j)*inner Real (x i) (x k)*inner Real (x j) (x k) -
        (inner Real (x i) (x j))^2 - (inner Real (x i) (x k))^2 -
        (inner Real (x j) (x k))^2 := by
  obtain ⟨i,j,k,h⟩ := exists_large_volume x hx hc
  have hij : i ≠ j := by
    intro he
    subst j
    have hz : volume x i i k = 0 := by unfold volume; ring
    rw [hz] at h
    norm_num at h
  have hik : i ≠ k := by
    intro he
    subst k
    have hz : volume x i j i = 0 := by unfold volume; ring
    rw [hz] at h
    norm_num at h
  have hjk : j ≠ k := by
    intro he
    subst k
    have hz : volume x i j j = 0 := by unfold volume; ring
    rw [hz] at h
    norm_num at h
  exact ⟨i,j,k,hij,hik,hjk, by rwa [volume_square_eq_gram x hx i j k] at h⟩

end ThomsonN9.Anchor

