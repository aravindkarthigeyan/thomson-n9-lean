"""Emit concrete pair-Laplacian, radial, rotation, and shifted-Hessian recipes.

All generated finite checks are ordinary Lean kernel reductions. The exporter
is not trusted; semantic equalities are derived from the separately proved
recipe soundness theorems.
"""
import argparse
import json
from pathlib import Path

from export_lean_trial import WORK
from export_lean_geometry import vector, matrix, nat_function
from export_lean_congruence import table, recipe_lines


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--directory', type=Path, default=WORK)
    args = parser.parse_args()
    data = json.loads(Path(__file__).with_name('geometry-recipes.json').read_text())
    zero = data['zero']
    pairs = {(p['i'],p['j']): p for p in data['pairs']}
    updates = data['block_laplacian_updates']
    lines = [
        'import ThomsonN9.Certificates.AmbientKernelGeometry',
        'import ThomsonN9.Certificates.AmbientCongruenceData',
        'import ThomsonN9.Certificates.CircuitSums',
        'import ThomsonN9.Certificates.CircuitRotation',
        'set_option maxRecDepth 200000','set_option maxHeartbeats 0',
        'namespace ThomsonN9.Certificates.AmbientKernel','open IntervalCircuit',
        'open scoped BigOperators',
    ]
    table(lines,'laplacianIndices',data['block_laplacian_indices'])
    table(lines,'constrainedIndices',data['constrained_hessian_indices'])
    table(lines,'augmentedIndices',data['augmented_indices'])
    lines += ['def flatIndex (i : Fin 9 × Fin 3) : ℕ := 3*i.1.val+i.2.val',
              'def negativeShift : ℕ := '+str(data['negative_shift']),
              'def lagrangeCorrections : Fin 9 → ℕ := '+vector(data['lagrange_corrections']),
              'def lambdaIndices : Fin 9 → ℕ := '+vector([r[-1] for r in data['lambda_accumulators']])]
    sum_names = []
    for i in range(9):
        point_names = []
        for a in range(3):
            row_names = []
            for b in range(3):
                name = 'diagonalSum_'+str(i)+'_'+str(a)+'_'+str(b)
                row_names.append(name)
                terms, accum = [], [zero]
                relevant = [u for u in updates if u[0] == 3*i+a and u[1] == 3*i+b]
                assert len(relevant) == 8
                position = 0
                for j in range(9):
                    term = zero if j == i else pairs[max(i,j),min(i,j)]['block'][a][b]
                    terms.append(term)
                    if j == i:
                        accum.append(accum[-1])
                    else:
                        u = relevant[position]
                        position += 1
                        assert u[2] == accum[-1] and u[3] == term
                        accum.append(u[4])
                lines += ['def '+name+' : SumRecipe where',
                          '  term := '+nat_function(terms),
                          '  accumulator := '+nat_function(accum),
                          'theorem '+name+'_checked : '+name+'.Check nodes 9 := by decide']
            point_names.append(vector(row_names))
        sum_names.append('!['+','.join(point_names)+']')
    lines += ['def diagonalSums : Fin 9 → Fin 3 → Fin 3 → SumRecipe := !['+','.join(sum_names)+']',
              'theorem diagonal_sums_checked (i : Fin 9) (a b : Fin 3) :',
              '    (diagonalSums i a b).Check nodes 9 := by',
              '  fin_cases i <;> fin_cases a <;> fin_cases b']
    for i in range(9):
        for a in range(3):
            for b in range(3):
                lines.append('  · exact diagonalSum_'+str(i)+'_'+str(a)+'_'+str(b)+'_checked')
    lines += [
        'theorem diagonal_sum_term (i j : Fin 9) (a b : Fin 3) :',
        '    (diagonalSums i a b).term j =',
        '      if i = j then 11 else (pairRecipes (pairIndex i j)).block a b := by',
        '  revert i j a b; decide',
        'theorem diagonal_sum_output (i : Fin 9) (a b : Fin 3) :',
        '    (diagonalSums i a b).accumulator 9 = laplacianIndices (flatIndex (i,a)) (flatIndex (i,b)) := by',
        '  revert i a b; decide',
        'theorem off_diagonal_checked (i j : Fin 9) (a b : Fin 3) (h : i ≠ j) :',
        '    ExtendedSmartMulCheck nodes ((pairRecipes (pairIndex i j)).block a b) 18',
        '      (laplacianIndices (flatIndex (i,a)) (flatIndex (j,b))) := by',
        '  revert i j a b; decide',
        'theorem literal_zero (values : ℕ → ℝ) : value values nodes 11 = 0 :=',
        '  zeroAt_sound values nodes 11 (by decide)',
        'theorem literal_minus_one (values : ℕ → ℝ) : value values nodes 18 = -1 := by',
        '  simpa using value_constant values nodes 18 (-1) 1 (by decide)',
        'theorem laplacian_entry_sound (r : ℝ) (ia jb : Fin 9 × Fin 3) :',
        '    value (parameterInputs r) nodes (laplacianIndices (flatIndex ia) (flatIndex jb)) =',
        '      blockLaplacian (fun i j => coulombPairBlock (candidateAt r i-candidateAt r j)) ia jb := by',
        '  have heq := pair_hessian_of_entries (candidateAt r)',
        '    (fun ia jb => value (parameterInputs r) nodes (laplacianIndices (flatIndex ia) (flatIndex jb)))',
        '  apply congrFun (congrFun (heq ?_ ?_) ia) jb',
        '  · intro i a b',
        '    rw [← diagonal_sum_output, SumRecipe.sound_fin _ _ _ _ (diagonal_sums_checked i a b)]',
        '    apply Finset.sum_congr rfl',
        '    intro j _',
        '    rw [diagonal_sum_term]',
        '    by_cases hij : i = j',
        '    · subst j',
        '      simp [literal_zero, coulombPairBlock]',
        '    · rw [if_neg hij, unordered_pair_block_sound r i j hij]',
        '  · intro i j a b hij',
        '    rw [extendedSmartMul_sound _ _ _ _ _ (off_diagonal_checked i j a b hij),',
        '      unordered_pair_block_sound r i j hij, literal_minus_one]',
        '    ring',
    ]
    for i in range(9):
        terms, accum = [], [zero]
        position = 0
        for j in range(9):
            terms.append(zero if i == j else pairs[max(i,j),min(i,j)]['negative_half_reciprocal'])
            if i == j:
                accum.append(accum[-1])
            else:
                position += 1
                accum.append(data['lambda_accumulators'][i][position])
        name = 'radialSum_'+str(i)
        lines += ['def '+name+' : SumRecipe where',
                  '  term := '+nat_function(terms),'  accumulator := '+nat_function(accum),
                  'theorem '+name+'_checked : '+name+'.Check nodes 9 := by decide']
    lines += ['def radialSums : Fin 9 → SumRecipe := '+vector(['radialSum_'+str(i) for i in range(9)]),
              'theorem radial_sums_checked (i : Fin 9) : (radialSums i).Check nodes 9 := by',
              '  fin_cases i']
    lines += ['  · exact radialSum_'+str(i)+'_checked' for i in range(9)]
    lines += [
        'theorem radial_sum_term (i j : Fin 9) : (radialSums i).term j =',
        '    if i = j then 11 else (halfInverseRecipes (pairIndex i j)).negative := by',
        '  revert i j; decide',
        'theorem radial_sum_output (i : Fin 9) : (radialSums i).accumulator 9 = lambdaIndices i := by',
        '  revert i; decide',
        'theorem radial_entry_sound (r : ℝ) (i : Fin 9) :',
        '    value (parameterInputs r) nodes (lambdaIndices i) = radialCoefficient (candidateAt r) i := by',
        '  rw [← radial_sum_output, SumRecipe.sound_fin _ _ _ _ (radial_sums_checked i)]',
        '  calc',
        '    _ = ∑ j : Fin 9, -(‖candidateAt r i-candidateAt r j‖⁻¹/2) := by',
        '      apply Finset.sum_congr rfl',
        '      intro j _',
        '      rw [radial_sum_term]',
        '      by_cases hij : i = j',
        '      · subst j; simp [literal_zero]',
        '      · rw [if_neg hij, unordered_half_inverse_sound r i j hij]',
        '    _ = _ := by rw [Finset.sum_neg_distrib, ← Finset.sum_div]; simp [radialCoefficient, neg_div]',
        'theorem lagrange_correction_checked (i : Fin 9) :',
        '    ExtendedSmartMulCheck nodes (lambdaIndices i) 18 (lagrangeCorrections i) := by',
        '  revert i; decide',
        'theorem constrained_checked (ia jb : Fin 9 × Fin 3) :',
        '    ExtendedSmartAddCheck nodes (laplacianIndices (flatIndex ia) (flatIndex jb))',
        '      (if ia = jb then lagrangeCorrections ia.1 else 11)',
        '      (constrainedIndices (flatIndex ia) (flatIndex jb)) := by',
        '  revert ia jb; decide',
        'theorem constrained_entry_sound (r : ℝ) (ia jb : Fin 9 × Fin 3) :',
        '    value (parameterInputs r) nodes (constrainedIndices (flatIndex ia) (flatIndex jb)) =',
        '      constrainedHessian (candidateAt r) ia jb := by',
        '  rw [extendedSmartAdd_sound _ _ _ _ _ (constrained_checked ia jb), laplacian_entry_sound]',
        '  by_cases hij : ia = jb',
        '  · subst jb',
        '    rw [if_pos rfl, extendedSmartMul_sound _ _ _ _ _ (lagrange_correction_checked ia.1),',
        '      radial_entry_sound, literal_minus_one]',
        '    simp [constrainedHessian, Matrix.sub_apply, Matrix.diagonal_apply, sub_eq_add_neg]',
        '  · rw [if_neg hij, literal_zero]',
        '    simp [constrainedHessian, Matrix.sub_apply, Matrix.diagonal_apply, hij]',
    ]
    rotations = [data['rotation_indices'][3*i:3*i+3] for i in range(9)]
    lines += [
        'def rotationIndices : Fin 9 → Fin 3 → Fin 3 → ℕ := !['+','.join(matrix(m) for m in rotations)+']',
        'theorem rotations_checked : RotationCheck nodes pointIndices rotationIndices := by decide',
        'theorem rotation_entry_sound (r : ℝ) (ia : Fin 9 × Fin 3) (k : Fin 3) :',
        '    value (parameterInputs r) nodes (rotationIndices ia.1 ia.2 k) =',
        '      rotationColumns (candidateAt r) ia k :=',
        '  rotation_recipe_sound _ nodes pointIndices rotationIndices rotations_checked _',
        '    (coordinate_recipe_sound r nodes coordinate_prefix_checked) ia.1 ia.2 k',
    ]
    for i in range(27):
        for j in range(27):
            recipe = data['rotation_dot_recipes'][i][j]
            name = 'rotationDot_'+str(i)+'_'+str(j)
            lines += recipe_lines(name,recipe)
            lines += ['theorem '+name+'_checked : '+name+'.ExtendedCheck nodes 3 := by decide']
        lines += ['def rotationDotsRow'+str(i)+' : Array DotRecipe := #['+
                  ','.join('rotationDot_'+str(i)+'_'+str(j) for j in range(27))+']',
                  'theorem rotationDotsRow'+str(i)+'_checked (j : Fin 27) :',
                  '    (rotationDotsRow'+str(i)+'[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by',
                  '  fin_cases j']
        lines += ['  · exact rotationDot_'+str(i)+'_'+str(j)+'_checked' for j in range(27)]
    lines += [
        'def rotationDots (ia jb : Fin 9 × Fin 3) : DotRecipe :=',
        '  (#['+','.join('rotationDotsRow'+str(i) for i in range(27))+'][flatIndex ia]?.getD #[])[flatIndex jb]?.getD rotationDot_0_0',
        'theorem rotation_dots_checked (ia jb : Fin 9 × Fin 3) : (rotationDots ia jb).ExtendedCheck nodes 3 := by',
        '  rcases ia with ⟨i,a⟩',
        '  have hj : flatIndex jb < 27 := by rcases jb with ⟨j,b⟩; simp only [flatIndex]; omega',
        '  fin_cases i <;> fin_cases a',
    ]
    lines += ['  · exact rotationDotsRow'+str(i)+'_checked ⟨flatIndex jb,hj⟩' for i in range(27)]
    lines += [
        'theorem rotation_dot_left (ia jb : Fin 9 × Fin 3) (k : Fin 3) :',
        '    (rotationDots ia jb).left k = rotationIndices ia.1 ia.2 k := by revert ia jb k; decide',
        'theorem rotation_dot_right (ia jb : Fin 9 × Fin 3) (k : Fin 3) :',
        '    (rotationDots ia jb).right k = rotationIndices jb.1 jb.2 k := by revert ia jb k; decide',
        'theorem rotation_product_sound (r : ℝ) (ia jb : Fin 9 × Fin 3) :',
        '    value (parameterInputs r) nodes ((rotationDots ia jb).accumulator 3) =',
        '      (rotationColumns (candidateAt r)*(rotationColumns (candidateAt r)).transpose) ia jb := by',
        '  rw [DotRecipe.extended_sound_fin _ _ _ _ (rotation_dots_checked ia jb)]',
        '  simp only [rotation_dot_left, rotation_dot_right, rotation_entry_sound, Matrix.mul_apply, Matrix.transpose_apply]',
        'theorem augmented_checked (ia jb : Fin 9 × Fin 3) :',
        '    ExtendedSmartAddCheck nodes (constrainedIndices (flatIndex ia) (flatIndex jb))',
        '      ((rotationDots ia jb).accumulator 3)',
        '      (augmentedIndices (flatIndex ia) (flatIndex jb)) := by revert ia jb; decide',
        'theorem shifted_checked (ia jb : Fin 9 × Fin 3) :',
        '    ExtendedSmartAddCheck nodes (augmentedIndices (flatIndex ia) (flatIndex jb))',
        '      (if ia = jb then negativeShift else 11)',
        '      (hessianIndices (flatIndex ia) (flatIndex jb)) := by revert ia jb; decide',
        'theorem negative_shift_sound (values : ℕ → ℝ) : value values nodes negativeShift = -(7/50 : ℝ) := by',
        '  simpa [neg_div] using value_constant values nodes negativeShift (-7) 50 (by decide)',
        'theorem shifted_hessian_entry_sound (r : ℝ) (ia jb : Fin 9 × Fin 3) :',
        '    value (parameterInputs r) nodes (hessianIndices (flatIndex ia) (flatIndex jb)) =',
        '      (constrainedHessian (candidateAt r) +',
        '        rotationColumns (candidateAt r)*(rotationColumns (candidateAt r)).transpose -',
        '          (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)) ia jb := by',
        '  rw [extendedSmartAdd_sound _ _ _ _ _ (shifted_checked ia jb),',
        '    extendedSmartAdd_sound _ _ _ _ _ (augmented_checked ia jb),',
        '    constrained_entry_sound, rotation_product_sound]',
        '  by_cases hij : ia = jb',
        '  · subst jb',
        '    rw [if_pos rfl, negative_shift_sound]',
        '    simp [Matrix.sub_apply, Matrix.add_apply, sub_eq_add_neg]',
        '  · rw [if_neg hij, literal_zero]',
        '    simp [Matrix.sub_apply, Matrix.add_apply, Matrix.one_apply, hij]',
        '#print axioms laplacian_entry_sound',
        '#print axioms radial_entry_sound',
        '#print axioms shifted_hessian_entry_sound',
        'end ThomsonN9.Certificates.AmbientKernel',
    ]
    output = args.directory/'ThomsonN9/Certificates/AmbientKernelAssembly.lean'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('Generated actual shifted-Hessian semantic assembly:',output.stat().st_size,'bytes; uncompiled')


if __name__ == '__main__':
    main()
