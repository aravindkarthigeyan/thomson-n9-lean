"""Recover shared-node matrix-product recipes from the frozen K=0 circuit.

The separate finite predicates in check_recipes.py and the draft CircuitAlgebra
Lean module check these witnesses. No real-expression equality is assumed.
"""
import argparse
from fractions import Fraction
import hashlib
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--circuit', type=Path,
                        default=Path(__file__).with_name('ambient-circuit-k0.json'))
    parser.add_argument('--output', type=Path,
                        default=Path(__file__).with_name('congruence-recipes.json'))
    args = parser.parse_args()
    data = json.loads(args.circuit.read_text())
    nodes = data['nodes']
    lookup = {(n['op'], *n['args']): i for i, n in enumerate(nodes)}
    constants = {i: Fraction(int(n['args'][0]), int(n['args'][1]))
                 for i, n in enumerate(nodes) if n['op'] == 'const'}
    zero = lookup['const', '0', '1']

    def operation(op, a, b):
        ca, cb = constants.get(a), constants.get(b)
        if op == 'add':
            if ca == 0:
                return b
            if cb == 0:
                return a
        else:
            if ca == 0 or cb == 0:
                return zero
            if ca == 1:
                return b
            if cb == 1:
                return a
        if ca is not None and cb is not None:
            c = ca + cb if op == 'add' else ca * cb
            return lookup['const', str(c.numerator), str(c.denominator)]
        return lookup[op, a, b]

    def matrix_product(a, b):
        result, recipes = [], []
        for i in range(len(a)):
            row = []
            for j in range(len(b[0])):
                left = [a[i][k] for k in range(len(b))]
                right = [b[k][j] for k in range(len(b))]
                products = [operation('mul', x, y) for x, y in zip(left, right)]
                accumulators = [zero]
                for p in products:
                    accumulators.append(operation('add', accumulators[-1], p))
                row.append(accumulators[-1])
                recipes.append({'row': i, 'column': j, 'left': left, 'right': right,
                                'product': products, 'accumulator': accumulators})
            result.append(row)
        return result, recipes

    a, c = data['shifted_hessian_indices'], data['congruence_indices']
    ac, first = matrix_product(a, c)
    b, second = matrix_product(list(map(list, zip(*c))), ac)
    assert b == data['output_indices']
    result = {'format': 'thomson-n9-circuit-congruence-recipes-v1',
              'circuit_sha256': hashlib.sha256(args.circuit.read_bytes()).hexdigest(),
              'first_product_indices': ac, 'first_recipes': first,
              'second_recipes': second}
    args.output.write_text(json.dumps(result, separators=(',', ':')) + '\n')
    print('Exported', len(first) + len(second), 'shared-node dot-product recipes')


if __name__ == '__main__':
    main()
