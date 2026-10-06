import ClaudeL1.Test.Negative

/-! Independent additional real-data controls. All rejections are proved Boolean
equalities; a parser/import/runtime failure is not a passing test. -/

namespace ThomsonN9.Claude.L1.IndependentMutations
open KC Data

theorem genuine_assembly : asm.checkL1 Lres = true := asm_ok
theorem genuine_kernel_total : ktotal.check = true := ktotal_ok

theorem reject_sos_scale_two :
    ({ asm with sscale := 2 } : Assembly).checkL1 Lres = false := by
  decide +kernel

theorem reject_u_exponent_outside_box :
    ({ asm with K := .node asm.K (.leaf ⟨1,21,0,0⟩) } : Assembly).checkL1 Lres = false := by
  decide +kernel

theorem reject_v_exponent_outside_box :
    ({ asm with K := .node asm.K (.leaf ⟨1,0,21,0⟩) } : Assembly).checkL1 Lres = false := by
  decide +kernel

theorem reject_t_exponent_outside_box :
    ({ asm with K := .node asm.K (.leaf ⟨1,0,0,21⟩) } : Assembly).checkL1 Lres = false := by
  decide +kernel

theorem reject_zero_digit_width :
    ({ asm with w := 0 } : Assembly).checkL1 Lres = false := by
  decide +kernel

theorem reject_insufficient_digit_width :
    ({ asm with w := 1 } : Assembly).checkL1 Lres = false := by
  decide +kernel

#print axioms ThomsonN9.Claude.L1.IndependentMutations.genuine_assembly
#print axioms ThomsonN9.Claude.L1.IndependentMutations.genuine_kernel_total
#print axioms ThomsonN9.Claude.L1.IndependentMutations.reject_sos_scale_two
#print axioms ThomsonN9.Claude.L1.IndependentMutations.reject_u_exponent_outside_box
#print axioms ThomsonN9.Claude.L1.IndependentMutations.reject_v_exponent_outside_box
#print axioms ThomsonN9.Claude.L1.IndependentMutations.reject_t_exponent_outside_box
#print axioms ThomsonN9.Claude.L1.IndependentMutations.reject_zero_digit_width
#print axioms ThomsonN9.Claude.L1.IndependentMutations.reject_insufficient_digit_width

end ThomsonN9.Claude.L1.IndependentMutations
