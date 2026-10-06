"""Emit exact output-widening checks and the conditional matrix PSD closure.

The final Hermitian/semantic premise is explicit until the Hessian assembly is
proved. No intended-matrix assertion is smuggled into an arithmetic predicate.
"""
import argparse
from pathlib import Path

from export_lean_trial import WORK


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--directory', type=Path, default=WORK)
    args = parser.parse_args()
    lines = [
        'import ThomsonN9.Certificates.AmbientKernelAll',
        'import ThomsonN9.Certificates.AmbientCongruence',
        'import ThomsonN9.Certificates.CircuitCoordinates',
        'import ThomsonN9.Certificates.ZeroPenalty',
        'set_option maxRecDepth 200000', 'set_option maxHeartbeats 0',
        'namespace ThomsonN9.Certificates.AmbientKernel', 'open IntervalCircuit',
        'def OutputIntegerCheck (s : ℤ) (a : ScaledInterval) (i j : Fin 27) : Prop :=',
        '  if i = j then s ≤ 1000*a.lo ∧ a.hi ≤ 100*s',
        '  else -s ≤ 100000*a.lo ∧ 100000*a.hi ≤ s',
        'instance instDecidableOutputIntegerCheck (s : ℤ) (a : ScaledInterval) (i j : Fin 27) :',
        '    Decidable (OutputIntegerCheck s a i j) := by unfold OutputIntegerCheck; infer_instance',
        'theorem outputIntegerCheck_sound {s : ℤ} {a : ScaledInterval} {i j : Fin 27}',
        '    (hs : 0 < s) (h : OutputIntegerCheck s a i j) :',
        '    OutputWithin s a (zeroPenaltyCongruenceBounds i j) := by',
        '  have hsQ : (0 : ℚ) < (s : ℚ) := by exact_mod_cast hs',
        '  unfold OutputIntegerCheck at h',
        '  unfold OutputWithin ScaledInterval.rational zeroPenaltyCongruenceBounds',
        '  by_cases hij : i = j',
        '  · simp only [hij, if_true] at h ⊢',
        '    constructor',
        '    · rw [le_div_iff₀ hsQ]',
        '      have hh : (s : ℚ) ≤ 1000*(a.lo : ℚ) := by exact_mod_cast h.1',
        '      linarith',
        '    · rw [div_le_iff₀ hsQ]',
        '      exact_mod_cast h.2',
        '  · simp only [hij, if_false] at h ⊢',
        '    constructor',
        '    · rw [le_div_iff₀ hsQ]',
        '      have hh : -(s : ℚ) ≤ 100000*(a.lo : ℚ) := by exact_mod_cast h.1',
        '      linarith',
        '    · rw [div_le_iff₀ hsQ]',
        '      have hh : 100000*(a.hi : ℚ) ≤ (s : ℚ) := by exact_mod_cast h.2',
        '      linarith',
        'theorem scale_positive : 0 < scale := by decide',
        'theorem parameter_inputs_enclosed (r : CandidateParameter) :',
        '    ∀ i, ScaledInterval.Contains scale (inputs i) (parameterInputs r i) := by',
        '  intro i', '  by_cases hi : i = 0', '  · subst i',
        '    change (1088912153567137547101881257881020939934625976579651389 : ℝ) ≤',
        '      (scale : ℝ)*(r : ℝ) ∧ (scale : ℝ)*(r : ℝ) ≤',
        '        (1088912153567137547101881257881020939934779226133737979 : ℝ)',
        '    have hs : (0 : ℝ) ≤ (scale : ℝ) := by exact_mod_cast le_of_lt scale_positive',
        '    constructor', '    · calc',
        '        _ ≤ (scale : ℝ)*(radiusLower : ℝ) := by norm_num [scale,radiusLower]',
        '        _ ≤ _ := mul_le_mul_of_nonneg_left r.property.1 hs',
        '    · calc',
        '        _ ≤ (scale : ℝ)*(radiusUpper : ℝ) := mul_le_mul_of_nonneg_left r.property.2.1 hs',
        '        _ ≤ _ := by norm_num [scale,radiusUpper]',
        '  · simp [ScaledInterval.Contains,inputs,parameterInputs,hi]',
    ]
    for i in range(27):
        lines += [
            'theorem output_bounds_'+str(i)+' (j : Fin 27) :',
            '    OutputWithin scale (nodes (outputIndices '+str(i)+' j)).bound',
            '      (zeroPenaltyCongruenceBounds '+str(i)+' j) := by',
            '  apply outputIntegerCheck_sound scale_positive',
            '  revert j', '  decide',
            'theorem output_index_'+str(i)+' (j : Fin 27) :',
            '    outputIndices '+str(i)+' j < 37815 := by revert j; decide',
        ]
    lines += ['theorem output_bounds (i j : Fin 27) :',
              '    OutputWithin scale (nodes (outputIndices i j)).bound',
              '      (zeroPenaltyCongruenceBounds i j) := by', '  fin_cases i']
    lines += ['  · exact output_bounds_'+str(i)+' j' for i in range(27)]
    lines += ['theorem output_index (i j : Fin 27) : outputIndices i j < 37815 := by',
              '  fin_cases i']
    lines += ['  · exact output_index_'+str(i)+' j' for i in range(27)]
    lines += [
        'theorem congruence_upper_checked : ∀ i j : Fin 27, j < i →',
        '    ZeroAt nodes (congruenceIndices i j) := by decide',
        'theorem congruence_diagonal_checked : ∀ i : Fin 27,',
        '    OneAt nodes (congruenceIndices i i) := by decide',
        'theorem output_enclosures (r : CandidateParameter) (i j : Fin 27) :',
        '    (zeroPenaltyCongruenceBounds i j).Contains',
        '      (value (parameterInputs r) nodes (outputIndices i j)) :=',
        '  outputWithin_sound scale_positive',
        '    (all_enclosures _ (parameter_inputs_enclosed r) _ (output_index i j)) (output_bounds i j)',
        'theorem flattened_posDef (r : CandidateParameter)',
        '    (hA : (matrixValues (value (parameterInputs r) nodes) 27 hessianIndices).IsHermitian) :',
        '    (matrixValues (value (parameterInputs r) nodes) 27 hessianIndices).PosDef := by',
        '  let C := matrixValues (value (parameterInputs r) nodes) 27 congruenceIndices',
        '  have hupper : ∀ i j, j < i → C i j = 0 := by',
        '    intro i j hij',
        '    exact zeroAt_sound _ nodes _ (congruence_upper_checked i j hij)',
        '  have hdiag : ∀ i, C i i = 1 := by',
        '    intro i',
        '    exact oneAt_sound _ nodes _ (congruence_diagonal_checked i)',
        '  apply zeroPenalty_posDef_of_congruence_enclosures _ C hA hupper hdiag',
        '  intro i j',
        '  have hstar : star C = C.transpose := by ext a b; simp',
        '  rw [hstar]',
        '  change (zeroPenaltyCongruenceBounds i j).Contains',
        '    (((matrixValues (value (parameterInputs r) nodes) 27 congruenceIndices).transpose *',
        '      matrixValues (value (parameterInputs r) nodes) 27 hessianIndices *',
        '        matrixValues (value (parameterInputs r) nodes) 27 congruenceIndices) i j)',
        '  rw [← congruence_matrix_product]',
        '  exact output_enclosures r i j',
        '#print axioms outputIntegerCheck_sound',
        '#print axioms parameter_inputs_enclosed',
        '#print axioms output_enclosures',
        '#print axioms flattened_posDef',
        'end ThomsonN9.Certificates.AmbientKernel',
    ]
    out = args.directory/'ThomsonN9/Certificates/AmbientKernelBounds.lean'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('Generated output checks and explicit-Hermitian-premise closure; not compiled.')


if __name__ == '__main__':
    main()
