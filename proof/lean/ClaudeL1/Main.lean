/-
ClaudeL1.Main : the L1 theorem.  Instantiates Codex's frozen interface
`ThomsonN9.SDP.factored_certificate_pair_bound` with the kernel-checked reduced certificate
(`near-sharp-d10-reduced-D60.json`, SHA-256 9816ae66…8781) and concludes

  certifiedEnergyReduced ≤ pairSum (fun i j => hNew ⟪x i, x j⟫)

for every configuration of 9 unit vectors whose off-diagonal inner products are ≤ 5593/10000.

This is the only L1 module that imports Codex's package (its import alone costs ≈4.1 GB because
`ThomsonN9.Basic` imports `Mathlib.Tactic`); all heavy work is done in core / light modules.

Claude, L1.
-/
import ThomsonN9.SDP.CertificateBound
import ClaudeL1.Identity

namespace ThomsonN9.Claude.L1
open ThomsonN9 ThomsonN9.SDP ThomsonN9.Claude.L1.KC ThomsonN9.Claude.L1.Data
  ThomsonN9.Claude.L1.Data.SOS

theorem circleKernel_eq_myCircle (a b : ℝ) (n : ℕ) : circleKernel a b n = myCircle a b n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n, ih with
    | 0, _ => simp [circleKernel, myCircle]
    | 1, _ => simp [circleKernel, myCircle]
    | n + 2, ih => rw [circleKernel, myCircle, ih (n + 1) (by omega), ih n (by omega)]

/-- Codex's `correctedFactorKernel` is the copy `myCorrected` used in `ClaudeL1.Identity`. -/
theorem correctedFactorKernel_eq {κ ρ : Type*} [Fintype κ] [Fintype ρ]
    (B : κ → ρ → ℝ) (p : κ → ℝ → ℝ) (k : ℕ) (u v t : ℝ) :
    correctedFactorKernel B p k u v t = myCorrected B p k u v t := by
  simp only [correctedFactorKernel, myCorrected, edgeSymmetrize, myEdgeSym, rootedFactorKernel,
    myRooted, factorWeight, myFactorWeight, threePointKernel, myThreePoint,
    circleKernel_eq_myCircle]

/-- the identically zero kernel block 10 is dropped: 10 blocks `k = 0..9` remain -/
theorem kblocks_length : kblocks.length = 10 := rfl

/-- **Literal kernel-block identity** (for each block `k = 0..9`): Codex's corrected kernel with the
exact real factor matrix `B_k` of the JSON (`famB k i r = B_k[i][r]`) and features `x^i` equals the
explicit checker polynomial `exprPoly (kblocks[k]) k` (built from `q_k` by the `circleKernel`
recurrence, the six argument orders and the `56/8/8/8/1` boundary correction) divided by `48·10^120`. -/
theorem kernel_block_identity (b : KIdx) (u v t : ℝ) :
    correctedFactorKernel (famB b) (famP b) (famDeg b) u v t =
      (exprPoly (kblocks.getD b.1 []) b.1).eval u v t / (48 * 10 ^ 120) := by
  have hs := kblocks_shape' b.1
  rw [correctedFactorKernel_eq, expr_eq_corrected _ hs.1 hs.2]
  simp only [famB, famP, famDeg]
  field_simp

/-- the sum of all kernel blocks is the explicit collected polynomial `PK` (786 terms, kernel-checked
by `ktotal_ok`) divided by `48·10^120` -/
theorem kernel_total_identity (u v t : ℝ) :
    ∑ b, correctedFactorKernel (famB b) (famP b) (famDeg b) u v t =
      PK.toPoly.eval u v t / (48 * 10 ^ 120) := by
  simp only [correctedFactorKernel_eq]
  exact kernel_sum_eq u v t

/-- the multiplier table is nonnegative on the capped Gram domain (Codex's `domainWeight_nonneg`) -/
theorem w6_nonneg {M u v t : ℝ} (h : TripleDomain M u v t) (c : ℕ) : 0 ≤ w6 M u v t c := by
  rcases c with _ | _ | _ | _ | _ | _ | c
  · exact domainWeight_nonneg h 0
  · exact domainWeight_nonneg h 1
  · exact domainWeight_nonneg h 2
  · exact domainWeight_nonneg h 3
  · exact domainWeight_nonneg h 4
  · exact domainWeight_nonneg h 5
  · exact le_refl 0

theorem pargs_domain {u v t : ℝ} (h : TripleDomain (5593 / 10000) u v t) (ρ : Fin 3) :
    TripleDomain (5593 / 10000) (pargs ρ u v t).1 (pargs ρ u v t).2.1 (pargs ρ u v t).2.2 := by
  unfold pargs
  split_ifs
  · exact h
  · exact h.swap_first
  · exact h.swap_last.swap_first

/-- `hweight` -/
theorem sosWeight_nonneg {u v t : ℝ} (h : TripleDomain (5593 / 10000) u v t) (s : SIdx) :
    0 ≤ sosWeight s u v t := by
  unfold sosWeight
  rw [gtree_eval]
  exact div_nonneg (mul_nonneg (by norm_num) (w6_nonneg (pargs_domain h s.1) _)) (by norm_num)

/-- `hidentity`, in the exact form required by `factored_certificate_pair_bound` -/
theorem l1_hidentity : ∀ u v t : ℝ, TripleDomain (5593 / 10000) u v t →
    (hNew u + hNew v + hNew t) / 3 - (rawEnergyReduced : ℝ) / 36 =
      (∑ b, correctedFactorKernel (famB b) (famP b) (famDeg b) u v t) +
      (∑ s, sosWeight s u v t * (sosSquare s u v t) ^ 2) +
      ∑ η, resCoeff η * (u ^ (resExp η 0) * v ^ (resExp η 1) * t ^ (resExp η 2)) := by
  intro u v t _
  simp only [correctedFactorKernel_eq]
  exact l1_identity u v t

/-- **L1 theorem.**  For every configuration of nine unit vectors in `ℝ³` whose off-diagonal inner
products are at most `5593/10000`, the pair sum of the reduced minorant `hNew` is at least the
certified energy of the reduced certificate (exact rational from the JSON). -/
theorem reduced_pair_bound (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hM : ∀ i j, i ≠ j → inner ℝ (x i) (x j) ≤ 5593 / 10000) :
    ((certifiedEnergyReduced : ℚ) : ℝ) ≤ pairSum (fun i j => hNew (inner ℝ (x i) (x j))) := by
  have h := factored_certificate_pair_bound famB famP famDeg sosWeight sosSquare resCoeff resExp
    hNew (rawEnergyReduced : ℝ) (5593 / 10000)
    (fun u v t hd s => sosWeight_nonneg hd s) l1_hidentity x hx hM
  have hl := res_l1_le
  linarith

end ThomsonN9.Claude.L1

#print axioms ThomsonN9.Claude.L1.reduced_pair_bound
#print axioms ThomsonN9.Claude.L1.l1_hidentity
#print axioms ThomsonN9.Claude.L1.kernel_block_identity
#print axioms ThomsonN9.Claude.L1.kernel_total_identity
#print axioms ThomsonN9.Claude.L1.sosWeight_nonneg

#print axioms ThomsonN9.Claude.L1.l1_identity
#print axioms ThomsonN9.Claude.L1.res_l1_le
#print axioms ThomsonN9.Claude.L1.expr_eq_corrected
#print axioms ThomsonN9.Claude.L1.eval_eq_box
#print axioms ThomsonN9.Claude.L1.Data.ktotal_ok
#print axioms ThomsonN9.Claude.L1.Data.asm_ok
#print axioms ThomsonN9.Claude.L1.Data.SOS.chunk01_ok
#print axioms ThomsonN9.Claude.L1.Data.SOS.sos_total
