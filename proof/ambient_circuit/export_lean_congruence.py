"""Emit modular ordinary-kernel checks for the two rational congruence products.

This generator is untrusted. Its output uses CircuitMatrices soundness, the
literal trace, and individual arithmetic checks; no matrix identity is assumed.
"""
import argparse
import json
from pathlib import Path

from export_lean_trial import WORK
from export_lean_geometry import nat_function


def table(lines, name, rows):
    for i, row in enumerate(rows):
        lines.append('def '+name+'Row'+str(i)+' : Array ℕ := #['+','.join(map(str,row))+']')
    lines += ['def '+name+' (i j : ℕ) : ℕ :=',
              '  (#['+','.join(name+'Row'+str(i) for i in range(len(rows)))+
              '][i]?.getD #[])[j]?.getD 0']


def recipe_lines(name, recipe):
    return ['def '+name+' : DotRecipe where'] + [
        '  '+field+' := '+nat_function(recipe[field])
        for field in ('left','right','product','accumulator')]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--directory', type=Path, default=WORK)
    args = parser.parse_args()
    root = Path(__file__).parent
    data = json.loads((root/'ambient-circuit-k0.json').read_text())
    witness = json.loads((root/'congruence-recipes.json').read_text())
    directory = args.directory/'ThomsonN9/Certificates'
    directory.mkdir(parents=True, exist_ok=True)
    head = ['import ThomsonN9.Certificates.AmbientKernelData',
            'import ThomsonN9.Certificates.CircuitMatrices',
            'set_option maxRecDepth 200000','set_option maxHeartbeats 0',
            'namespace ThomsonN9.Certificates.AmbientKernel','open IntervalCircuit']
    lines = head.copy()
    lines += ['def emptyDotRecipe : DotRecipe := {',
              '  left := fun _ => 0, right := fun _ => 0,',
              '  product := fun _ => 0, accumulator := fun _ => 0 }']
    table(lines,'hessianIndices',data['shifted_hessian_indices'])
    table(lines,'congruenceIndices',data['congruence_indices'])
    table(lines,'firstProductIndices',witness['first_product_indices'])
    table(lines,'outputIndices',data['output_indices'])
    lines += ['end ThomsonN9.Certificates.AmbientKernel']
    (directory/'AmbientCongruenceData.lean').write_text('\n'.join(lines)+'\n',encoding='utf-8')

    modules = []
    for start in range(0,27,3):
        module = 'AmbientCongruenceChecks'+str(start//3).zfill(2)
        modules.append(module)
        lines = ['import ThomsonN9.Certificates.AmbientCongruenceData']+head[2:]
        for kind in ('first','second'):
            entries = witness[kind+'_recipes']
            for i in range(start,min(start+3,27)):
                for j in range(27):
                    recipe = entries[27*i+j]
                    assert (recipe['row'],recipe['column']) == (i,j)
                    name = kind+'Recipe_'+str(i)+'_'+str(j)
                    lines += recipe_lines(name,recipe)
                    lines += ['theorem '+name+'_checked : '+name+'.checkBool nodes 27 = true := by decide']
                lines += ['def '+kind+'RecipesRow'+str(i)+' : Array DotRecipe := #['+
                          ','.join(kind+'Recipe_'+str(i)+'_'+str(j) for j in range(27))+']']
                lines += ['theorem '+kind+'RecipesRow'+str(i)+'_checked (j : Fin 27) :',
                          '    ('+kind+'RecipesRow'+str(i)+'[j.val]?.getD emptyDotRecipe).Check nodes 27 := by',
                          '  fin_cases j']
                lines += ['  · exact DotRecipe.checkBool_sound nodes 27 _ '+
                          kind+'Recipe_'+str(i)+'_'+str(j)+'_checked' for j in range(27)]
        lines += ['end ThomsonN9.Certificates.AmbientKernel']
        (directory/(module+'.lean')).write_text('\n'.join(lines)+'\n',encoding='utf-8')

    lines = ['import ThomsonN9.Certificates.'+m for m in modules]+head[2:]
    for kind in ('first','second'):
        lines += ['def '+kind+'Recipes (i j : ℕ) : DotRecipe :=',
                  '  (#['+','.join(kind+'RecipesRow'+str(i) for i in range(27))+'][i]?.getD #[])[j]?.getD emptyDotRecipe',
                  'theorem '+kind+'_recipes_checked (i j : Fin 27) : ('+kind+'Recipes i j).Check nodes 27 := by',
                  '  fin_cases i']
        lines += ['  · exact '+kind+'RecipesRow'+str(i)+'_checked j' for i in range(27)]
        for field in ('left','right','accumulator'):
            if field == 'left':
                target = 'hessianIndices i k' if kind == 'first' else 'congruenceIndices k i'
            elif field == 'right':
                target = 'congruenceIndices k j' if kind == 'first' else 'firstProductIndices k j'
            else:
                target = ('firstProductIndices' if kind == 'first' else 'outputIndices')+' i j'
            extra = '' if field == 'accumulator' else ' (k : Fin 27)'
            arg = '27' if field == 'accumulator' else 'k'
            for i in range(27):
                row_target = target.replace(' i ', ' '+str(i)+' ')
                if row_target.endswith(' i'):
                    row_target = row_target[:-2]+' '+str(i)
                lines += ['theorem '+kind+'_'+field+'_row'+str(i)+' (j : Fin 27)'+extra+' :',
                          '    ('+kind+'Recipes '+str(i)+' j).'+field+' '+arg+' = '+row_target+' := by',
                          '  revert j'+('' if field == 'accumulator' else ' k'),
                          '  decide']
            lines += ['theorem '+kind+'_'+field+' (i j : Fin 27)'+extra+' :',
                      '    ('+kind+'Recipes i j).'+field+' '+arg+' = '+target+' := by',
                      '  fin_cases i']
            lines += ['  · exact '+kind+'_'+field+'_row'+str(i)+' j'+
                      ('' if field == 'accumulator' else ' k') for i in range(27)]
        right = 'congruenceIndices' if kind == 'first' else 'firstProductIndices'
        left = 'hessianIndices' if kind == 'first' else '(fun i j => congruenceIndices j i)'
        out = 'firstProductIndices' if kind == 'first' else 'outputIndices'
        lines += ['theorem '+kind+'_matrix_product (values : ℕ → ℝ) :',
                  '    matrixValues (value values nodes) 27 '+out+' =',
                  '      matrixValues (value values nodes) 27 '+left+' *',
                  '        matrixValues (value values nodes) 27 '+right+' :=',
                  '  matrix_product_recipe_sound values nodes 27 _ _ _ _ '+kind+'_recipes_checked',
                  '    '+kind+'_left '+kind+'_right '+kind+'_accumulator']
    lines += ['theorem congruence_matrix_product (values : ℕ → ℝ) :',
              '    matrixValues (value values nodes) 27 outputIndices =',
              '      (matrixValues (value values nodes) 27 congruenceIndices).transpose *',
              '        matrixValues (value values nodes) 27 hessianIndices *',
              '          matrixValues (value values nodes) 27 congruenceIndices := by',
              '  rw [second_matrix_product, first_matrix_product, Matrix.mul_assoc]',
              '  rfl',
              '#print axioms congruence_matrix_product',
              'end ThomsonN9.Certificates.AmbientKernel']
    (directory/'AmbientCongruence.lean').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('Generated 1458 literal dot checks in 9 modules; identities remain uncompiled.')


if __name__ == '__main__':
    main()
