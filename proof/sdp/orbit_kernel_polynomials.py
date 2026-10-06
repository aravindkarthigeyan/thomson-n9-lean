"""Exact polynomial orbit vectors for the N9 three-point moment kernels.

Rational coefficients are generated symbolically. The final numerical
cross-check is diagnostic; the accompanying derivation is in ORBIT_KERNELS.md.
"""
import argparse
import itertools
import json
from math import comb
from pathlib import Path

import numpy as np
import sympy as sp

import discover_threepoint as model

HERE = Path(__file__).resolve().parent
r = sp.Symbol('r')
Q = sp.Rational


def paired(real_square, imaginary_coefficient, k):
    parity = k % 2
    return sum(2*comb(k, 2*h)*real_square**h *
               (-1)**((k-2*h-parity)//2) * imaginary_coefficient**(k-2*h) *
               (1-r*r)**((k-2*h-parity)//2)
               for h in range(k//2+1))


def pure(imaginary_coefficient, k):
    exponent = (k-k%2)//2
    return (-1)**exponent*imaginary_coefficient**k*(1-r*r)**exponent


def vectors(k, d):
    prism, caps = [], []
    a, b, c = 1-Q(3, 2)*r*r, 2*r*r-1, r*r/2-1
    for j in range(d-k+1):
        p = ((1 if k == 0 else 0) +
             a**j*paired(Q(3, 4)*r*r, Q(3, 2)*r, k) +
             b**j*pure(-2*r, k) +
             c**j*paired(Q(3, 4)*r*r, -r/2, k) +
             (-r)**j*pure(1, k) +
             (r/2)**j*paired(Q(3, 4), -Q(1, 2), k))
        cap = 0 if k % 2 else (
            (1 if k == 0 else 0) +
            (-Q(1, 2))**j*2*Q(3, 4)**(k//2) +
            (-r)**j*2*pure(1, k) +
            (r/2)**j*2*paired(Q(3, 4)*r*r, 1, k))
        prism.append(sp.Poly(sp.expand(p), r))
        caps.append(sp.Poly(sp.expand(cap), r))
    return prism, caps


def coefficients(poly):
    return [str(poly.nth(i)) for i in range(max(0, poly.degree())+1)]


def run(d, destination):
    data = json.loads((HERE.parent/'results/candidate.json').read_text())
    points = np.array(data['coordinates'], float)
    gram = points@points.T
    triples = [[gram[i, j], gram[i, k], gram[j, k]]
               for i, j, k in itertools.product(range(9), repeat=3)]
    model.BASIS = 'monomial'
    moments = [np.sum(t, axis=0) for t in model.kernels(triples, d)]
    radius = float(data.get('r', np.linalg.norm(points[0, :2])))
    # The reconstruction lists prism vertices first. Verify the chosen radius
    # directly against the exact family rather than trusting an unknown key.
    if not .7 < radius < .72:
        radius = next(float(np.linalg.norm(p[:2])) for p in points if abs(p[2]) > .1)
    blocks, errors = [], []
    for k in range(d+1):
        p, c = vectors(k, d)
        pv = np.array([float(v.eval(radius)) for v in p])
        cv = np.array([float(v.eval(radius)) for v in c])
        predicted = 6*(1-radius*radius if k % 2 else 1)*np.outer(pv, pv)
        if k % 2 == 0:
            predicted += 3*np.outer(cv, cv)
        error = float(np.max(np.abs(predicted-moments[k])))
        errors.append(error)
        blocks.append({'k': k, 'prism_vector': [coefficients(v) for v in p],
                       'cap_vector': None if k % 2 else [coefficients(v) for v in c],
                       'prism_outer_product_factor': '6*(1-r^2)' if k % 2 else '6',
                       'cap_outer_product_factor': '0' if k % 2 else '3',
                       'numerical_crosscheck_max_error': error})
    assert max(errors) < 2e-9, errors
    record = {'status': 'EXACT POLYNOMIAL DATA WITH NUMERICAL CROSSCHECK; see derivation',
              'basis': 'u^j', 'dimension': 3, 'N': 9, 'd': d,
              'coefficient_order': 'increasing powers of r',
              'blocks': blocks, 'maximum_crosscheck_error': max(errors)}
    destination.write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps({'d': d, 'maximum_crosscheck_error': max(errors),
                      'output': str(destination)}))


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--d', type=int, default=12)
    ap.add_argument('--output', type=Path, default=HERE/'orbit-kernel-polynomials.json')
    args = ap.parse_args()
    run(args.d, args.output)
