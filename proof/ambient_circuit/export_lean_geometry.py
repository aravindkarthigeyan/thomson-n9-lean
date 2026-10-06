"""Instantiate all 36 Coulomb pair-block recipes against the frozen literal trace.

Generated sources remain work drafts until Lean checks them. Difference-vector
semantics and full Hessian assembly are not assumed or asserted by these checks.
"""
import argparse
import hashlib
import json
from pathlib import Path

from export_lean_trial import WORK


def vector(values):
    return '!['+','.join(map(str,values))+']'


def matrix(values):
    return '!['+','.join(vector(row) for row in values)+']'


def nat_function(values):
    return 'fun i => #['+','.join(map(str,values))+'][i]?.getD 0'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--directory', type=Path, default=WORK)
    args = parser.parse_args()
    source = Path(__file__).with_name('geometry-recipes.json')
    data = json.loads(source.read_text())
    lines = ['import ThomsonN9.Certificates.AmbientKernelData',
             'import ThomsonN9.Certificates.CircuitRadial',
             'import ThomsonN9.Certificates.CircuitMatrices',
             'set_option maxRecDepth 200000','set_option maxHeartbeats 0',
             'namespace ThomsonN9.Certificates.AmbientKernel','open IntervalCircuit',
             '-- Witness JSON SHA256: '+hashlib.sha256(source.read_bytes()).hexdigest()]
    names = []
    difference_names = []
    half_names = []
    for p in data['pairs']:
        name = 'pairBlock_'+str(p['i'])+'_'+str(p['j'])
        names.append(name)
        diff_name = 'difference_'+str(p['i'])+'_'+str(p['j'])
        difference_names.append(diff_name)
        half_name = 'halfInverse_'+str(p['i'])+'_'+str(p['j'])
        half_names.append(half_name)
        s = p['squared_norm']
        assert all(len(set(row)) == 1 for row in p['first_product'])
        lines += [
            'def '+name+' : PairBlockRecipe where',
            '  distance := {',
            '    difference := '+vector(p['difference']),
            '    squares := {',
            '      left := '+nat_function(s['left']),
            '      right := '+nat_function(s['right']),
            '      product := '+nat_function(s['product']),
            '      accumulator := '+nat_function(s['accumulator'])+' }',
            '    root := '+str(p['distance']),
            '    inverse := '+str(p['reciprocal'])+' }',
            '  powers := { base := '+str(p['reciprocal'])+', accumulator := '+
                nat_function(p['inverse_powers'])+' }',
            '  three := '+str(p['three']),
            '  scaledFifth := '+str(p['three_fifths']),
            '  timesFirst := '+vector([row[0] for row in p['first_product']]),
            '  numerator := '+matrix(p['second_product']),
            '  delta := '+matrix([[data['one'] if a == b else data['zero'] for b in range(3)] for a in range(3)]),
            '  diagonalTerm := '+matrix(p['diagonal_term']),
            '  negativeDiagonal := '+matrix(p['negative_diagonal_term']),
            '  block := '+matrix(p['block']),
            'theorem '+name+'_check : '+name+'.Check nodes := by',
            '  constructor <;> decide',
            '#print axioms '+name+'_check',
            'def '+diff_name+' : DifferenceRecipe where',
            '  left := '+vector(data['point_indices'][p['i']]),
            '  right := '+vector(data['point_indices'][p['j']]),
            '  negative := '+vector(p['negative_second_point']),
            '  output := '+vector(p['difference']),
            'theorem '+diff_name+'_check : '+diff_name+'.Check nodes := by decide',
            'def '+half_name+' : HalfInverseRecipe where',
            '  distance := '+name+'.distance',
            '  two := '+str(data['two']),
            '  twice := '+str(p['twice_distance']),
            '  inverse := '+str(p['half_reciprocal']),
            '  negative := '+str(p['negative_half_reciprocal']),
            'theorem '+half_name+'_check : '+half_name+'.Check nodes := by',
            '  constructor',
            '  · exact '+name+'_check.distance',
            '  all_goals decide',
        ]
    lines += ['def pairRecipes : Fin 36 → PairBlockRecipe := !['+', '.join(names)+']',
              'theorem pair_recipes_checked (k : Fin 36) : (pairRecipes k).Check nodes := by',
              '  fin_cases k']
    lines += ['  · exact '+name+'_check' for name in names]
    lines += ['theorem pair_blocks_sound (values : ℕ → ℝ) (k : Fin 36) (p q : R3)',
              '    (hdiff : ∀ a : Fin 3, IntervalCircuit.value values nodes',
              '      ((pairRecipes k).distance.difference a) = p a-q a) (a b : Fin 3) :',
              '    IntervalCircuit.value values nodes ((pairRecipes k).block a b) =',
              '      coulombPairBlock (p-q) a b :=',
              '  (pairRecipes k).sound values nodes (pair_recipes_checked k) p q hdiff a b',
              '#print axioms pair_recipes_checked','#print axioms pair_blocks_sound',
              'def pairDifferences : Fin 36 → DifferenceRecipe := !['+', '.join(difference_names)+']',
              'def pairFirst : Fin 36 → Fin 9 := '+vector([p['i'] for p in data['pairs']]),
              'def pairSecond : Fin 36 → Fin 9 := '+vector([p['j'] for p in data['pairs']]),
              'theorem difference_recipes_checked (k : Fin 36) : (pairDifferences k).Check nodes := by',
              '  fin_cases k']
    lines += ['  · exact '+name+'_check' for name in difference_names]
    lines += [
        'theorem coordinate_prefix_checked : CoordinateCheck nodes := by decide',
        'theorem difference_left (k : Fin 36) (a : Fin 3) :',
        '    (pairDifferences k).left a = pointIndices (pairFirst k) a := by',
        '  fin_cases k <;> fin_cases a <;> rfl',
        'theorem difference_right (k : Fin 36) (a : Fin 3) :',
        '    (pairDifferences k).right a = pointIndices (pairSecond k) a := by',
        '  fin_cases k <;> fin_cases a <;> rfl',
        'theorem difference_output (k : Fin 36) (a : Fin 3) :',
        '    (pairDifferences k).output a = (pairRecipes k).distance.difference a := by',
        '  fin_cases k <;> fin_cases a <;> rfl',
        'theorem pair_differences_candidate_sound (r : ℝ) (k : Fin 36) (a : Fin 3) :',
        '    IntervalCircuit.value (parameterInputs r) nodes ((pairRecipes k).distance.difference a) =',
        '      candidateAt r (pairFirst k) a-candidateAt r (pairSecond k) a := by',
        '  rw [← difference_output]',
        '  exact (pairDifferences k).candidate_sound r nodes coordinate_prefix_checked',
        '    (difference_recipes_checked k) (pairFirst k) (pairSecond k)',
        '    (difference_left k) (difference_right k) a',
        'theorem pair_blocks_candidate_sound (r : ℝ) (k : Fin 36) (a b : Fin 3) :',
        '    IntervalCircuit.value (parameterInputs r) nodes ((pairRecipes k).block a b) =',
        '      coulombPairBlock (candidateAt r (pairFirst k)-candidateAt r (pairSecond k)) a b :=',
        '  pair_blocks_sound _ k _ _ (pair_differences_candidate_sound r k) a b',
        '#print axioms pair_blocks_candidate_sound',
        'def halfInverseRecipes : Fin 36 → HalfInverseRecipe := !['+', '.join(half_names)+']',
        'theorem half_inverse_recipes_checked (k : Fin 36) : (halfInverseRecipes k).Check nodes := by',
        '  fin_cases k']
    lines += ['  · exact '+name+'_check' for name in half_names]
    lines += [
        'theorem half_inverse_distance (k : Fin 36) :',
        '    (halfInverseRecipes k).distance = (pairRecipes k).distance := by fin_cases k <;> rfl',
        'theorem half_inverse_candidate_sound (r : ℝ) (k : Fin 36) :',
        '    IntervalCircuit.value (parameterInputs r) nodes (halfInverseRecipes k).negative =',
        '      -(‖candidateAt r (pairFirst k)-candidateAt r (pairSecond k)‖⁻¹/2) := by',
        '  apply (halfInverseRecipes k).sound _ _ (half_inverse_recipes_checked k)',
        '  intro a',
        '  rw [half_inverse_distance]',
        '  exact pair_differences_candidate_sound r k a',
    ]
    pair_index = {(p['i'],p['j']): k for k,p in enumerate(data['pairs'])}
    pairs_table = [[0 if i == j else pair_index[max(i,j),min(i,j)] for j in range(9)] for i in range(9)]
    lines += [
        'def pairIndex : Fin 9 → Fin 9 → Fin 36 := '+matrix(pairs_table),
        'theorem pair_endpoints (i j : Fin 9) (h : i ≠ j) :',
        '    (pairFirst (pairIndex i j) = i ∧ pairSecond (pairIndex i j) = j) ∨',
        '    (pairFirst (pairIndex i j) = j ∧ pairSecond (pairIndex i j) = i) := by',
        '  revert i j',
        '  decide',
        'theorem unordered_pair_block_sound (r : ℝ) (i j : Fin 9) (h : i ≠ j) (a b : Fin 3) :',
        '    IntervalCircuit.value (parameterInputs r) nodes ((pairRecipes (pairIndex i j)).block a b) =',
        '      coulombPairBlock (candidateAt r i-candidateAt r j) a b := by',
        '  rw [pair_blocks_candidate_sound]',
        '  rcases pair_endpoints i j h with h | h',
        '  · rw [h.1,h.2]',
        '  · rw [h.1,h.2]',
        '    have heq : candidateAt r j-candidateAt r i = -(candidateAt r i-candidateAt r j) := by abel',
        '    rw [heq,coulombPairBlock_neg]',
        'theorem unordered_half_inverse_sound (r : ℝ) (i j : Fin 9) (h : i ≠ j) :',
        '    IntervalCircuit.value (parameterInputs r) nodes (halfInverseRecipes (pairIndex i j)).negative =',
        '      -(‖candidateAt r i-candidateAt r j‖⁻¹/2) := by',
        '  rw [half_inverse_candidate_sound]',
        '  rcases pair_endpoints i j h with h | h',
        '  · rw [h.1,h.2]',
        '  · rw [h.1,h.2,norm_sub_rev]',
        '#print axioms unordered_pair_block_sound',
        '#print axioms unordered_half_inverse_sound',
        'end ThomsonN9.Certificates.AmbientKernel']
    output = args.directory/'ThomsonN9/Certificates/AmbientKernelGeometry.lean'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('Generated all 36 literal PairBlockRecipe checks:',output.stat().st_size,'bytes')


if __name__ == '__main__':
    main()
