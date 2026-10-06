import ThomsonN9.Basic
import Delsarte.Sphere.Schoenberg

namespace ThomsonN9

noncomputable def legendreKernel (k : Nat) (t : Real) : Real :=
  Delsarte.Sphere.gegenbauerReal 3 k t

noncomputable def legendreMoment (x : Configuration) (k : Nat) : Real :=
  ∑ i : Fin 9, ∑ j : Fin 9, legendreKernel k (inner Real (x i) (x j))

def unitPointsOfSphere (x : Configuration) (hx : IsSphereConfiguration x) :
    Delsarte.Sphere.UnitPoints 3 9 := ⟨x, hx.1⟩

theorem legendreMoment_nonneg (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1) (k : Nat) : 0 <= legendreMoment x k := by
  have h := Delsarte.Sphere.schoenbergPos_all (d := 3) (by decide) k 9
    (⟨x, hx⟩ : Delsarte.Sphere.UnitPoints 3 9)
  simpa only [legendreMoment, legendreKernel, Delsarte.Sphere.UnitPoints.gram] using h

theorem legendreMoment_nonneg_of_sphere (x : Configuration)
    (hx : IsSphereConfiguration x) (k : Nat) : 0 <= legendreMoment x k :=
  legendreMoment_nonneg x hx.1 k

theorem legendreKernel_zero (t : Real) : legendreKernel 0 t = 1 := by
  simp [legendreKernel]

theorem legendreKernel_one (t : Real) : legendreKernel 1 t = t := by
  simp [legendreKernel]

theorem legendreKernel_two (t : Real) : legendreKernel 2 t = (3*t^2-1)/2 := by
  rw [legendreKernel, Delsarte.Sphere.gegenbauerReal_deg_two]
  norm_num

theorem legendreKernel_at_one (k : Nat) : legendreKernel k 1 = 1 :=
  Delsarte.Sphere.gegenbauerReal_eval_one (by decide) k

theorem legendreMoment_zero (x : Configuration) : legendreMoment x 0 = 81 := by
  norm_num [legendreMoment, legendreKernel]

theorem legendreMoment_one (x : Configuration) :
    legendreMoment x 1 = ‖∑ i, x i‖^2 := by
  simp only [legendreMoment, legendreKernel, Delsarte.Sphere.gegenbauerReal_one]
  rw [← real_inner_self_eq_norm_sq, sum_inner]
  exact Finset.sum_congr rfl fun i _ => (inner_sum _ _ _).symm

theorem weightedLegendreMoment_nonneg (x : Configuration)
    (hx : ∀ i, ‖x i‖ = 1) (degrees : Finset Nat) (weights : Nat → Real)
    (hw : ∀ k ∈ degrees, 0 <= weights k) :
    0 <= ∑ k ∈ degrees, weights k * legendreMoment x k := by
  exact Finset.sum_nonneg fun k hk =>
    mul_nonneg (hw k hk) (legendreMoment_nonneg x hx k)

end ThomsonN9
