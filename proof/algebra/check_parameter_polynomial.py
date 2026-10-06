"""Independent integer/Fraction checker; imports no symbolic algebra solver.

It verifies the universal radical identity by multinomial expansion, the
cleared-denominator substitution by integer polynomial arithmetic, and the
root interval by exact signs and a derivative enclosure.
"""
import argparse
from fractions import Fraction as Q
from functools import reduce
from math import factorial, gcd
import json
from pathlib import Path
import sys

if not __debug__:
    raise RuntimeError('Run without Python -O: assertions enforce checks')
sys.set_int_max_str_digits(100000)
HERE = Path(__file__).resolve().parent


def trim(p):
    while len(p) > 1 and p[-1] == 0:
        p.pop()
    return p


def add(p, q):
    out = [0]*max(len(p), len(q))
    for i, x in enumerate(p):
        out[i] += x
    for i, x in enumerate(q):
        out[i] += x
    return trim(out)


def multiply(p, q):
    out = [0]*(len(p)+len(q)-1)
    for i, x in enumerate(p):
        for j, y in enumerate(q):
            out[i+j] += x*y
    return trim(out)


def power(p, n):
    out = [1]
    for _ in range(n):
        out = multiply(out, p)
    return out


def evaluate(p, value):
    out = Q(0)
    for coefficient in reversed(p):
        out = out*value+coefficient
    return out


def enclose(p, interval):
    lo = hi = Q(0)
    for coefficient in reversed(p):
        products = [x*y for x in (lo, hi) for y in interval]
        lo, hi = min(products)+coefficient, max(products)+coefficient
    return lo, hi


def check(data, local):
    assert data['format'] == 'thomson-n9-parameter-polynomial-v1'
    terms = data['universal_terms']
    assert all(len(e) == 5 and sum(e) == 8 and min(e) >= 0 for e, _ in terms)
    assert len({tuple(e) for e, _ in terms}) == len(terms)
    assert any(c != 0 for _, c in terms)
    # Check P(a^2,b^2,c^2,d^2,(a+b+c+d)^2)=0 exactly, without radicals.
    identity = {}
    for exponent, coefficient in terms:
        n = 2*exponent[4]
        for a in range(n+1):
            for b in range(n-a+1):
                for c in range(n-a-b+1):
                    d = n-a-b-c
                    alpha = (a, b, c, d)
                    key = tuple(2*exponent[i]+alpha[i] for i in range(4))
                    multinomial = factorial(n)//reduce(lambda x, y: x*y,
                                                       (factorial(v) for v in alpha), 1)
                    identity[key] = identity.get(key, 0)+coefficient*multinomial
    assert all(value == 0 for value in identity.values()), 'universal identity fails'

    r2, r4, r6 = [0, 0, 1], [0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1]
    s1, s4 = power([1, 0, -1], 3), power([4, 0, -1], 3)
    scaled = [multiply([96], multiply(s1, s4)),
              multiply([18], multiply(r6, s4)),
              multiply([288], multiply(r6, s1)),
              multiply([36], multiply(r4, multiply(power([1, -1], 3), s4))),
              multiply([288], multiply(r4, multiply(s1, power([2, 1], 3))))]
    assert scaled == data['scaled_squares'], 'scaled-square formulas differ'
    powers = [[power(p, i) for i in range(9)] for p in scaled]
    substituted = [0]
    for exponent, coefficient in terms:
        term = [coefficient]
        for i, e in enumerate(exponent):
            term = multiply(term, powers[i][e])
        substituted = add(substituted, term)
    primitive, content = data['primitive_coefficients'], data['raw_content']
    assert substituted == [content*x for x in primitive], 'substitution fails'
    assert reduce(gcd, map(abs, primitive)) == 1 and primitive[-1] > 0
    product = [data['factorization_constant']]
    for factor in data['factors']:
        assert factor['multiplicity'] >= 1
        product = multiply(product, power(factor['coefficients'], factor['multiplicity']))
    assert product == primitive, 'factor product fails'
    interval = Q(*local['radius_lower']), Q(*local['radius_upper'])
    assert 0 < interval[0] < interval[1] < 1
    derivative = [i*c for i, c in enumerate(primitive)][1:]
    derivative_interval = enclose(derivative, interval)
    left, right = evaluate(primitive, interval[0]), evaluate(primitive, interval[1])
    assert left*right < 0, 'polynomial endpoint signs do not oppose'
    assert derivative_interval[0] > 0 or derivative_interval[1] < 0, 'derivative sign not certified'
    return {'passed': True, 'degree': len(primitive)-1,
            'universal_identity_checked': True, 'integer_substitution_checked': True,
            'primitive_content_checked': True, 'factor_product_checked': True,
            'factor_degrees': [len(f['coefficients'])-1 for f in data['factors']],
            'left_sign': 1 if left > 0 else -1, 'right_sign': 1 if right > 0 else -1,
            'derivative_sign': 1 if derivative_interval[0] > 0 else -1,
            'isolating_interval': list(map(str, interval)),
            'unique_polynomial_root_in_interval': True}


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--certificate', type=Path, default=HERE/'parameter-polynomial.json')
    ap.add_argument('--report', type=Path, default=HERE/'parameter-polynomial.check.json')
    ap.add_argument('--negative-control', action='store_true')
    args = ap.parse_args()
    data = json.loads(args.certificate.read_text())
    local = json.loads((HERE.parent/'certificates/local.json').read_text())
    report = check(data, local)
    if args.negative_control:
        import copy
        bad = copy.deepcopy(data)
        bad['primitive_coefficients'][0] += 1
        try:
            check(bad, local)
        except AssertionError:
            report['negative_control_rejected'] = True
        else:
            raise AssertionError('corrupted polynomial accepted')
    args.report.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))
