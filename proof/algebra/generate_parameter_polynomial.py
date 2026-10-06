"""Generate a univariate integer polynomial necessary for N9 stationarity."""
from functools import reduce
from math import gcd
import json
from pathlib import Path
import time

import sympy as sp

HERE = Path(__file__).resolve().parent
t, A, B, C, D, E, r = sp.symbols('t A B C D E r')


def adjoin_square_root(polynomial, square):
    even, odd = 0, 0
    for (degree,), coefficient in sp.Poly(polynomial, t).terms():
        for j in range(degree+1):
            term = coefficient*sp.binomial(degree, j)*t**(degree-j)*square**(j//2)
            if j % 2:
                odd += term
            else:
                even += term
    return sp.expand(even*even-square*odd*odd)


def main():
    start = time.time()
    p = (t*t-A-B)**2-4*A*B
    p = adjoin_square_root(p, C)
    p = adjoin_square_root(p, D)
    universal = 0
    for (degree,), coefficient in sp.Poly(p, t).terms():
        assert degree % 2 == 0
        universal += coefficient*E**(degree//2)
    universal = sp.Poly(sp.expand(universal), A, B, C, D, E, domain=sp.ZZ)
    assert all(sum(exponent) == 8 for exponent, _ in universal.terms())

    # L=8r^4(1-r^2)^3(4-r^2)^3 is positive for 0<r<1.
    scaled = [96*(1-r*r)**3*(4-r*r)**3,
              18*r**6*(4-r*r)**3,
              288*r**6*(1-r*r)**3,
              36*r**4*(1-r)**3*(4-r*r)**3,
              288*r**4*(1-r*r)**3*(2+r)**3]
    scaled = [sp.Poly(v, r, domain=sp.ZZ) for v in scaled]
    powers = [[p**j for j in range(9)] for p in scaled]
    result = sp.Poly(0, r, domain=sp.ZZ)
    for exponent, coefficient in universal.terms():
        term = sp.Poly(coefficient, r, domain=sp.ZZ)
        for i, power in enumerate(exponent):
            term *= powers[i][power]
        result += term
    coefficients = [int(result.nth(i)) for i in range(result.degree()+1)]
    content = reduce(gcd, map(abs, coefficients))
    if coefficients[-1] < 0:
        content = -content
    primitive = [c//content for c in coefficients]
    factors = sp.factor_list(sp.Poly.from_list(list(reversed(primitive)), r))
    record = {
        'format': 'thomson-n9-parameter-polynomial-v1',
        'status': 'GENERATED INTEGER DATA; run the independent checker',
        'coefficient_order': 'increasing powers of r',
        'universal_variables': ['A', 'B', 'C', 'D', 'E'],
        'universal_terms': [[list(exponent), int(coefficient)]
                            for exponent, coefficient in universal.terms()],
        'scaled_squares': [[int(p.nth(i)) for i in range(p.degree()+1)] for p in scaled],
        'raw_content': content,
        'primitive_coefficients': primitive,
        'primitive_degree': len(primitive)-1,
        'factorization_constant': int(factors[0]),
        'factors': [{'multiplicity': multiplicity,
                     'coefficients': [int(factor.nth(i)) for i in range(factor.degree()+1)]}
                    for factor, multiplicity in factors[1]],
    }
    (HERE/'parameter-polynomial.json').write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps({'degree': len(primitive)-1,
                      'universal_terms': len(universal.terms()),
                      'factor_degrees': [(f.degree(), m) for f, m in factors[1]],
                      'seconds': time.time()-start}))


if __name__ == '__main__':
    main()
