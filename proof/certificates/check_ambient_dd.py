"""Exact ambient27 Hessian certificate; no tangent frame or zero-mode identity.

The source local bracket and Coulomb Hessian formula are the same mathematical
objects as in LOCAL_PROOF.md. Every numerical matrix operation is interval
arithmetic on integers. This checker does not call the numerical generator.
"""
import argparse
from fractions import Fraction
import hashlib
import json
from pathlib import Path

import check_local as local
from check_local_dd import multiply

if not __debug__:
    raise RuntimeError('Do not disable certificate assertions with Python -O')


def points(r):
    z = (1-r*r).sqrt()
    rt = local.I(3).sqrt()/2
    radial = [(local.I(1), local.I(0)), (local.I(Fraction(-1,2)), rt),
              (local.I(Fraction(-1,2)), -rt)]
    return [[r*c, r*s, h] for h in (z,-z) for c,s in radial] + \
        [[-c,-s,local.I(0)] for c,s in radial]


def augmented_hessian(r, penalty, *, include_rotations=True, lagrange_sign=-1):
    p = points(r)
    h = [[local.I(0) for _ in range(27)] for _ in range(27)]
    lambdas = [local.I(0) for _ in range(9)]
    for i in range(9):
        for j in range(i):
            d = [a-b for a,b in zip(p[i],p[j])]
            distance = local.dot(d,d).sqrt()
            assert distance.lo > local.S, 'candidate distance must exceed one'
            a, b = distance**-3, 3*distance**-5
            for m in range(3):
                for n in range(3):
                    value = b*d[m]*d[n] - a*int(m == n)
                    for u,v,sgn in ((i,i,1),(j,j,1),(i,j,-1),(j,i,-1)):
                        h[3*u+m][3*v+n] += sgn*value
            lambdas[i] -= 1/(2*distance)
            lambdas[j] -= 1/(2*distance)
    for i in range(9):
        for m in range(3):
            h[3*i+m][3*i+m] += lagrange_sign*lambdas[i]
    axes = [[local.I(int(k == j)) for j in range(3)] for k in range(3)]
    rotations = [[local.cross(axis,p[i])[m] for axis in axes]
                 for i in range(9) for m in range(3)]
    result = [[h[i][j] + (local.dot(rotations[i],rotations[j]) if include_rotations else 0)
               for j in range(27)] for i in range(27)]
    for i in range(9):
        for m in range(3):
            for n in range(3):
                result[3*i+m][3*i+n] += penalty*p[i][m]*p[i][n]
    return result


def check(certificate, *, matrix_mutation=None):
    assert certificate['format'] == 'thomson-n9-ambient-congruence-dd-v1'
    assert certificate['arithmetic_bits'] == local.BITS
    source = Path(__file__).with_name('local.json')
    assert hashlib.sha256(source.read_bytes()).hexdigest() == certificate['source_sha256']
    data = json.loads(source.read_text())
    c = [[Fraction(value) for value in row] for row in certificate['unit_upper']]
    assert len(c) == 27 and all(len(row) == 27 for row in c)
    assert all(c[i][j] == int(i == j) for i in range(27) for j in range(i+1)), \
        'congruence must be unit upper triangular'
    lo, hi = Fraction(*data['radius_lower']), Fraction(*data['radius_upper'])
    assert Fraction(7,10) < lo < hi < Fraction(18,25)
    penalty = Fraction(certificate['normal_penalty'])
    assert penalty >= 0
    shift = Fraction(certificate['hessian_shift'])
    assert shift >= Fraction(*data['hessian_lower']) and shift > 0
    assert matrix_mutation in (None,'omit rotations','flip Lagrange sign')
    a = augmented_hessian(local.I(lo,hi), penalty,
                          include_rotations=matrix_mutation != 'omit rotations',
                          lagrange_sign=1 if matrix_mutation == 'flip Lagrange sign' else -1)
    for i in range(27):
        a[i][i] -= shift
    ci = [[local.I(value) for value in row] for row in c]
    b = multiply(list(map(list,zip(*ci))), multiply(a,ci))
    margins = []
    for i in range(27):
        radius = sum(max(abs(b[i][j].lo),abs(b[i][j].hi)) for j in range(27) if j != i)
        margin = b[i][i].lo-radius
        assert margin > 0, f'nonpositive ambient diagonal-dominance margin at row {i}'
        margins.append(Fraction(margin,local.S))
    coarse_diagonal = (Fraction(1,1000), Fraction(100)) if penalty == 0 else \
                      (Fraction(1,20), Fraction(2000000))
    coarse_off_diagonal = (Fraction(-1,100000), Fraction(1,100000))
    for i in range(27):
        for j in range(27):
            lower, upper = coarse_diagonal if i == j else coarse_off_diagonal
            assert lower <= Fraction(b[i][j].lo,local.S), 'coarse lower enclosure failed'
            assert Fraction(b[i][j].hi,local.S) <= upper, 'coarse upper enclosure failed'
    return {
        'passed': True,
        'source_sha256': certificate['source_sha256'],
        'hessian_shift': str(shift),
        'normal_penalty': str(penalty),
        'unit_upper_verified': True,
        'congruence_intervals': [[value.exact() for value in row] for row in b],
        'strict_dd_margins': list(map(str,margins)),
        'minimum_margin': str(min(margins)),
        'coarse_diagonal_interval': list(map(str,coarse_diagonal)),
        'coarse_off_diagonal_interval': list(map(str,coarse_off_diagonal)),
        'coarse_enclosures_verified': True,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('certificate', nargs='?', type=Path,
                        default=Path(__file__).with_name('ambient-dd.json'))
    parser.add_argument('--report', type=Path)
    parser.add_argument('--negative-controls', action='store_true')
    args = parser.parse_args()
    data = json.loads(args.certificate.read_text())
    result = check(data)
    result['certificate_sha256'] = hashlib.sha256(args.certificate.read_bytes()).hexdigest()
    if args.negative_controls:
        rejected = []
        for name in ('nonunit diagonal','large upper coefficient','false shift 0.145',
                     'false shift 0.20','omit rotations','flip Lagrange sign'):
            mutant = json.loads(json.dumps(data))
            if name == 'nonunit diagonal':
                mutant['unit_upper'][0][0] = '0'
            elif name == 'large upper coefficient':
                mutant['unit_upper'][0][1] = '1000000'
            elif name == 'false shift 0.145':
                mutant['hessian_shift'] = '29/200'
            elif name == 'false shift 0.20':
                mutant['hessian_shift'] = '1/5'
            try:
                check(mutant,matrix_mutation=name if name in ('omit rotations','flip Lagrange sign') else None)
            except AssertionError as error:
                if name in ('false shift 0.145','false shift 0.20','omit rotations','flip Lagrange sign'):
                    assert 'nonpositive ambient diagonal-dominance margin' in str(error), \
                        'required arithmetic negative control failed only at metadata: '+str(error)
                rejected.append({'name':name,'reason':str(error)})
            else:
                raise AssertionError('Corrupted certificate accepted: '+name)
        result['rejected_controls'] = rejected
    if args.report:
        args.report.write_text(json.dumps(result,indent=2)+'\n')
    print('PASS: ambient27 interval congruence is strictly diagonally dominant')
    print('Minimum exact margin (decimal diagnostic):',float(Fraction(result['minimum_margin'])))


if __name__ == '__main__':
    main()
