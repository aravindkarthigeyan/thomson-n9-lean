"""Exact structural check of the congruence-product part of the ambient circuit.

This proves the shared-node output is C^T A C once the node semantics for A and C
are established. It does not establish that A is the intended geometric Hessian.
"""
import argparse
import hashlib
import json
from pathlib import Path


def check(circuit, recipes):
    assert recipes['format'] == 'thomson-n9-circuit-congruence-recipes-v1'
    nodes = circuit['nodes']

    def constant_at(i, value):
        assert isinstance(i, int) and 0 <= i < len(nodes)
        return nodes[i]['op'] == 'const' and nodes[i]['args'] == [str(value), '1']

    def smart_add(a, b, out):
        return ((constant_at(a, 0) and out == b) or
                (constant_at(b, 0) and out == a) or
                (nodes[out]['op'] == 'add' and nodes[out]['args'] == [a, b]
                 and a < out and b < out))

    def smart_mul(a, b, out):
        return ((constant_at(a, 0) and constant_at(out, 0)) or
                (constant_at(b, 0) and constant_at(out, 0)) or
                (constant_at(a, 1) and out == b) or
                (constant_at(b, 1) and out == a) or
                (nodes[out]['op'] == 'mul' and nodes[out]['args'] == [a, b]
                 and a < out and b < out))

    def product(a, b, result, witnesses):
        assert len(witnesses) == 27 * 27
        for i in range(27):
            for j in range(27):
                w = witnesses[27*i+j]
                assert (w['row'], w['column']) == (i, j)
                assert w['left'] == [a[i][k] for k in range(27)]
                assert w['right'] == [b[k][j] for k in range(27)]
                assert len(w['product']) == 27 and len(w['accumulator']) == 28
                assert all(isinstance(q, int) and 0 <= q < len(nodes)
                           for key in ('left', 'right', 'product', 'accumulator') for q in w[key])
                assert constant_at(w['accumulator'][0], 0)
                assert w['accumulator'][27] == result[i][j]
                for k in range(27):
                    assert smart_mul(w['left'][k], w['right'][k], w['product'][k]), \
                        ('multiplication recipe mismatch', i, j, k)
                    assert smart_add(w['accumulator'][k], w['product'][k],
                                     w['accumulator'][k+1]), \
                        ('addition recipe mismatch', i, j, k)

    a, c = circuit['shifted_hessian_indices'], circuit['congruence_indices']
    ac = recipes['first_product_indices']
    product(a, c, ac, recipes['first_recipes'])
    product(list(map(list, zip(*c))), ac, circuit['output_indices'], recipes['second_recipes'])
    return {'passed': True, 'dot_product_count': 1458,
            'checked_scalar_recipe_count': 1458*27*2,
            'scope': 'congruence matrix products only; geometric Hessian identity separate'}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--circuit', type=Path,
                        default=Path(__file__).with_name('ambient-circuit-k0.json'))
    parser.add_argument('--recipes', type=Path,
                        default=Path(__file__).with_name('congruence-recipes.json'))
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    circuit, recipes = json.loads(args.circuit.read_text()), json.loads(args.recipes.read_text())
    assert recipes['circuit_sha256'] == hashlib.sha256(args.circuit.read_bytes()).hexdigest()
    report = check(circuit, recipes)
    report['recipes_sha256'] = hashlib.sha256(args.recipes.read_bytes()).hexdigest()
    if args.report:
        args.report.write_text(json.dumps(report, indent=2)+'\n')
    print('PASS: all 1458 congruence dot products satisfy the structural recipes')


if __name__ == '__main__':
    main()
