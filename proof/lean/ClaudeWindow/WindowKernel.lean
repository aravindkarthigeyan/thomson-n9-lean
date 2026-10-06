import ClaudeWindow.WindowKernelA
import ClaudeWindow.WindowKernelB

/-! GENERATED: assembles the per-record kernel checks. -/

namespace ThomsonN9.Claude.Window

theorem coverage_ok : coverage records = true := by decide +kernel

theorem forall_mem_of_foldr {α : Type} {p : α → Prop} :
    ∀ l : List α, l.foldr (fun a acc => p a ∧ acc) True → ∀ x ∈ l, p x
  | [], _, x, hx => absurd hx List.not_mem_nil
  | a :: l, ⟨ha, hl⟩, x, hx => by
    rcases List.mem_cons.mp hx with rfl | hx
    · exact ha
    · exact forall_mem_of_foldr l hl x hx

theorem records_ok : ∀ rec ∈ records, checkRec box thetaQ rec = true :=
  forall_mem_of_foldr records
    ⟨check_rec00, check_rec01, check_rec02, check_rec03, check_rec04, check_rec05, check_rec06, check_rec07, check_rec08, check_rec09, check_rec10, check_rec11, check_rec12, check_rec13, check_rec14, check_rec15, check_rec16, check_rec17, check_rec18, check_rec19, check_rec20, check_rec21, check_rec22, check_rec23, check_rec24, check_rec25, check_rec26, check_rec27, check_rec28, check_rec29, check_rec30, check_rec31, check_rec32, check_rec33, check_rec34, check_rec35, check_rec36, check_rec37, check_rec38, check_rec39, check_rec40, check_rec41, check_rec42, check_rec43, check_rec44, check_rec45, check_rec46, check_rec47, check_rec48, check_rec49, check_rec50, check_rec51, check_rec52, check_rec53, check_rec54, check_rec55, trivial⟩

end ThomsonN9.Claude.Window
