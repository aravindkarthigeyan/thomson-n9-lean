/-
ClaudeL1.KC.Extra : the corollaries requested in claude/formal/REVIEW.md §1.1 for the copied
`SOSBlock.checkL1` (the L1 pipeline itself uses `Assembly.checkL1_sound`, which already returns both).

Core Lean only (Claude, L1).
-/
import ClaudeL1.KC.Check

namespace ThomsonN9.Claude.L1.KC
namespace SOSBlock

/-- `checkL1` also certifies that every exponent of the residual is `< D`. -/
theorem checkL1_degLt (B : SOSBlock) (L : Nat) (h : B.checkL1 L = true) : B.residual.DegLt B.D := by
  simp only [checkL1, Bool.and_eq_true] at h
  exact residual_deg B h.1.1.1

/-- `checkL1` in the combined form `boxL1 ≤ L ∧ DegLt`. -/
theorem checkL1_sound' (B : SOSBlock) (L : Nat) (h : B.checkL1 L = true) :
    boxL1 B.D B.residual ≤ L ∧ B.residual.DegLt B.D :=
  ⟨checkL1_sound B L h, checkL1_degLt B L h⟩

end SOSBlock
end ThomsonN9.Claude.L1.KC
