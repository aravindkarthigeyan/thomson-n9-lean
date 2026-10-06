"""Recover explicit geometric recipes from the frozen ambient K=0 trace.

These are witness data for the independently authored Lean semantics. Recovering
the graph is not itself a Lean proof that it computes the intended matrix.
"""
from fractions import Fraction
import hashlib
import json
from pathlib import Path


def main():
    source = Path(__file__).with_name('ambient-circuit-k0.json')
    data = json.loads(source.read_text())
    nodes = data['nodes']
    lookup = {(n['op'], *n['args']): i for i, n in enumerate(nodes)}
    constants = {i: Fraction(int(n['args'][0]), int(n['args'][1]))
                 for i, n in enumerate(nodes) if n['op'] == 'const'}
    calls = []

    def constant(c):
        c = Fraction(c)
        return lookup['const', str(c.numerator), str(c.denominator)]

    zero, one, two, three, minus_one = map(constant, [0,1,2,3,-1])

    def binary(op, a, b):
        ca, cb = constants.get(a), constants.get(b)
        if op == 'add' and ca == 0:
            out = b
        elif op == 'add' and cb == 0:
            out = a
        elif op == 'mul' and (ca == 0 or cb == 0):
            out = zero
        elif op == 'mul' and ca == 1:
            out = b
        elif op == 'mul' and cb == 1:
            out = a
        elif ca is not None and cb is not None:
            out = constant(ca+cb if op == 'add' else ca*cb)
        else:
            out = lookup[op,a,b]
        calls.append([op,a,b,out])
        return out

    def neg(a):
        out = constant(-constants[a]) if a in constants else lookup['neg',a]
        calls.append(['neg',a,out])
        return out

    def add(a,b):
        return binary('add',a,b)

    def mul(a,b):
        return binary('mul',a,b)

    def dot(left,right):
        products = [mul(a,b) for a,b in zip(left,right)]
        accumulator = [zero]
        for value in products:
            accumulator.append(add(accumulator[-1],value))
        return {'left':left,'right':right,'product':products,'accumulator':accumulator}

    p = data['point_indices']
    h = [[zero for _ in range(27)] for _ in range(27)]
    lambdas = [[zero] for _ in range(9)]
    pairs = []
    updates = []
    for i in range(9):
        for j in range(i):
            negatives = [neg(a) for a in p[j]]
            d = [add(a,b) for a,b in zip(p[i],negatives)]
            norm_recipe = dot(d,d)
            distance = lookup['sqrt',norm_recipe['accumulator'][-1]]
            reciprocal = lookup['inv',distance]
            powers = [one]
            for _ in range(5):
                powers.append(mul(powers[-1],reciprocal))
            three_fifths = mul(powers[5],three)
            first, second, diagonal, negatives_diagonal, block = [], [], [], [], []
            for a in range(3):
                first.append([])
                second.append([])
                diagonal.append([])
                negatives_diagonal.append([])
                block.append([])
                for b in range(3):
                    q = mul(three_fifths,d[a])
                    s = mul(q,d[b])
                    t = mul(powers[3],one if a == b else zero)
                    nt = neg(t)
                    v = add(s,nt)
                    first[a].append(q)
                    second[a].append(s)
                    diagonal[a].append(t)
                    negatives_diagonal[a].append(nt)
                    block[a].append(v)
                    for u,w,sign in ((i,i,1),(j,j,1),(i,j,-1),(j,i,-1)):
                        signed = mul(v,one if sign == 1 else minus_one)
                        old = h[3*u+a][3*w+b]
                        new = add(old,signed)
                        updates.append([3*u+a,3*w+b,old,signed,new])
                        h[3*u+a][3*w+b] = new
            twice_distance = mul(distance,two)
            half_reciprocal = lookup['inv',twice_distance]
            minus_half = neg(half_reciprocal)
            lambdas[i].append(add(lambdas[i][-1],minus_half))
            lambdas[j].append(add(lambdas[j][-1],minus_half))
            pairs.append({'i':i,'j':j,'negative_second_point':negatives,
                          'difference':d,'squared_norm':norm_recipe,'distance':distance,
                          'reciprocal':reciprocal,'inverse_powers':powers,
                          'three':three,'three_fifths':three_fifths,
                          'first_product':first,'second_product':second,
                          'diagonal_term':diagonal,'negative_diagonal_term':negatives_diagonal,
                          'block':block,'twice_distance':twice_distance,
                          'half_reciprocal':half_reciprocal,'negative_half_reciprocal':minus_half})
    h0 = [row.copy() for row in h]
    lagrange_corrections = []
    for i in range(9):
        correction = mul(lambdas[i][-1],minus_one)
        lagrange_corrections.append(correction)
        for a in range(3):
            h[3*i+a][3*i+a] = add(h[3*i+a][3*i+a],correction)

    def cross(a,b):
        return [add(mul(a[1],b[2]),neg(mul(a[2],b[1]))),
                add(mul(a[2],b[0]),neg(mul(a[0],b[2]))),
                add(mul(a[0],b[1]),neg(mul(a[1],b[0])))]

    axes = [[one if k == a else zero for a in range(3)] for k in range(3)]
    rotations = [[cross(axis,p[i])[a] for axis in axes] for i in range(9) for a in range(3)]
    rr_recipes = [[dot(rotations[i],rotations[j]) for j in range(27)] for i in range(27)]
    augmented = [[add(h[i][j],rr_recipes[i][j]['accumulator'][-1])
                  for j in range(27)] for i in range(27)]
    negative_shift = constant(Fraction(-7,50))
    shifted = [row.copy() for row in augmented]
    for i in range(27):
        shifted[i][i] = add(shifted[i][i],negative_shift)
    assert shifted == data['shifted_hessian_indices']
    result = {'format':'thomson-n9-circuit-geometric-recipes-v1',
              'circuit_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
              'zero':zero,'one':one,'two':two,'three':three,'minus_one':minus_one,
              'point_indices':p,'pairs':pairs,'block_laplacian_updates':updates,
              'block_laplacian_indices':h0,'lambda_accumulators':lambdas,
              'lagrange_corrections':lagrange_corrections,'constrained_hessian_indices':h,
              'rotation_indices':rotations,'rotation_dot_recipes':rr_recipes,
              'augmented_indices':augmented,'negative_shift':negative_shift,
              'shifted_hessian_indices':shifted,'smart_operation_calls':calls}
    output = Path(__file__).with_name('geometry-recipes.json')
    output.write_text(json.dumps(result,separators=(',',':'))+'\n')
    print('Recovered 36 pair recipes and every shifted Hessian output:',len(calls),'scalar calls')


if __name__ == '__main__':
    main()
