import ThomsonN9.Certificates.AmbientKernelAssembly

/-! Actual-data semantic mutation controls. Successful compilation proves each
rejection proposition; no expected compiler/import failures count as evidence. -/

set_option autoImplicit false
set_option maxRecDepth 200000
set_option maxHeartbeats 0

namespace ThomsonN9.Certificates.AmbientKernel.SemanticMutations

open IntervalCircuit

theorem genuine_pair_blocks (k : Fin 36) : (pairRecipes k).Check nodes :=
  pair_recipes_checked k

theorem genuine_coordinates : CoordinateCheck nodes := by decide

theorem genuine_constant_product : ConstantMulCheck nodes 9 18 12 := by decide

theorem genuine_constant_sum : ConstantAddCheck nodes 9 12 11 := by decide

theorem genuine_shift_literal : (nodes negativeShift).op = .constant (-7) 50 := by
  decide

theorem genuine_shift_interval : Node.Check scale inputs nodes negativeShift := by
  decide

theorem genuine_shift_wiring :
    ExtendedSmartAddCheck nodes (augmentedIndices 0 0) negativeShift
      (hessianIndices 0 0) := by decide

def wrongFactor : PairBlockRecipe := { pairBlock_1_0 with three := 8 }

theorem reject_factor_two : Not (wrongFactor.Check nodes) := by
  intro h
  have bad : Not ((nodes wrongFactor.three).op = .constant 3 1) := by decide
  exact bad h.three

def factorTwoNodes (i : Nat) : Node :=
  if i = 6 then { nodes i with op := .constant 2 1 } else nodes i

theorem reject_factor_two_node : Not (pairBlock_1_0.Check factorTwoNodes) := by
  intro h
  have bad : Not ((factorTwoNodes pairBlock_1_0.three).op = .constant 3 1) := by
    decide
  exact bad h.three

def fourthForFifth : PairBlockRecipe :=
  { pairBlock_1_0 with
    powers := { pairBlock_1_0.powers with
      accumulator := fun k => if k = 5 then pairBlock_1_0.powers.accumulator 4
        else pairBlock_1_0.powers.accumulator k } }

theorem reject_fourth_for_fifth : Not (fourthForFifth.Check nodes) := by
  intro h
  have bad : Not (SmartMulCheck nodes (fourthForFifth.powers.accumulator 4)
      fourthForFifth.powers.base (fourthForFifth.powers.accumulator 5)) := by decide
  exact bad (h.powers.2 (4 : Fin 5))

def secondForThirdDiagonal : PairBlockRecipe :=
  { pairBlock_1_0 with
    diagonalTerm := fun a b => if a = 0 /\ b = 0
      then pairBlock_1_0.powers.accumulator 2 else pairBlock_1_0.diagonalTerm a b }

theorem reject_second_for_third_diagonal :
    Not (secondForThirdDiagonal.Check nodes) := by
  intro h
  have bad : Not (SmartMulCheck nodes (secondForThirdDiagonal.powers.accumulator 3)
      (secondForThirdDiagonal.delta 0 0) (secondForThirdDiagonal.diagonalTerm 0 0)) := by
    decide
  exact bad (h.diagonal 0 0)

def positiveCoordinateNodes (i : Nat) : Node :=
  if i = 12 then { nodes i with op := .constant 1 2 } else nodes i

theorem reject_coordinate_sign : Not (CoordinateCheck positiveCoordinateNodes) := by
  decide

theorem reject_coordinate_constant_product :
    Not (ConstantMulCheck positiveCoordinateNodes 9 18 12) := by decide

theorem reject_coordinate_constant_sum :
    Not (ConstantAddCheck positiveCoordinateNodes 9 12 11) := by decide

def missingCoordinateNegation : DifferenceRecipe :=
  { difference_1_0 with negative := ![0,11,14] }

theorem reject_coordinate_difference_sign :
    Not (missingCoordinateNegation.Check nodes) := by decide

def wrongShiftNodes (i : Nat) : Node :=
  if i = negativeShift then { nodes i with op := .constant (-6) 50 } else nodes i

theorem reject_diagonal_shift_literal :
    Not ((wrongShiftNodes negativeShift).op = .constant (-7) 50) := by decide

theorem reject_diagonal_shift_interval :
    Not (Node.Check scale inputs wrongShiftNodes negativeShift) := by decide

/-- Structural addition alone deliberately does not enforce the shift's value. -/
theorem shift_wiring_alone_accepts_wrong_constant :
    ExtendedSmartAddCheck wrongShiftNodes (augmentedIndices 0 0) negativeShift
      (hessianIndices 0 0) := by decide

theorem reject_omitted_diagonal_shift :
    Not (ExtendedSmartAddCheck nodes (augmentedIndices 0 0) 11
      (hessianIndices 0 0)) := by decide

#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.genuine_pair_blocks
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.genuine_coordinates
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.genuine_constant_product
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.genuine_constant_sum
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.genuine_shift_literal
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.genuine_shift_interval
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.genuine_shift_wiring
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_factor_two
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_factor_two_node
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_fourth_for_fifth
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_second_for_third_diagonal
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_coordinate_sign
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_coordinate_constant_product
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_coordinate_constant_sum
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_coordinate_difference_sign
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_diagonal_shift_literal
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_diagonal_shift_interval
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.shift_wiring_alone_accepts_wrong_constant
#print axioms ThomsonN9.Certificates.AmbientKernel.SemanticMutations.reject_omitted_diagonal_shift

end ThomsonN9.Certificates.AmbientKernel.SemanticMutations
