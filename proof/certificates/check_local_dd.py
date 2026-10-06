"""Exact rational interval congruence and strict diagonal-dominance checker.

This is an alternate Hessian positivity check, not a full Lean replay. It uses
the existing independently documented exact dyadic Hessian formula, never LDL.
"""
import argparse
from fractions import Fraction
import hashlib
import json
from pathlib import Path

import check_local as local

if not __debug__:
    raise RuntimeError('Do not disable certificate assertions with Python -O')


def multiply(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(len(b)))
             for j in range(len(b[0]))] for i in range(len(a))]


def check(certificate):
    assert certificate['format'] == 'thomson-n9-local-congruence-dd-v1'
    assert certificate['arithmetic_bits'] == local.BITS
    source = Path(__file__).with_name('local.json')
    assert hashlib.sha256(source.read_bytes()).hexdigest() == certificate['source_sha256']
    data = json.loads(source.read_text())
    c = [[Fraction(value) for value in row] for row in certificate['unit_upper']]
    assert len(c) == 18 and all(len(row) == 18 for row in c)
    assert all(c[i][j] == int(i == j) for i in range(18) for j in range(i + 1)), \
        'congruence must be unit upper triangular'
    lo, hi = Fraction(*data['radius_lower']), Fraction(*data['radius_upper'])
    assert Fraction(7, 10) < lo < hi < Fraction(18, 25)
    a, _ = local.tangent_hessian(local.I(lo, hi))
    shift = Fraction(certificate['hessian_shift'])
    assert shift == Fraction(*data['hessian_lower']) and shift > 0
    for i in range(18):
        a[i][i] -= shift
    ci = [[local.I(value) for value in row] for row in c]
    b = multiply(list(map(list, zip(*ci))), multiply(a, ci))
    # Small universal endpoints keep the corresponding finite Lean check compact.
    coarse_diagonal = (Fraction(1, 100), Fraction(100))
    coarse_off_diagonal = (Fraction(-1, 100000), Fraction(1, 100000))
    for i in range(18):
        for j in range(18):
            lower, upper = coarse_diagonal if i == j else coarse_off_diagonal
            assert lower <= Fraction(b[i][j].lo, local.S)
            assert Fraction(b[i][j].hi, local.S) <= upper
    margins = []
    for i in range(18):
        radius = sum(max(abs(b[i][j].lo), abs(b[i][j].hi)) for j in range(18) if j != i)
        margin = b[i][i].lo - radius
        assert margin > 0, f'nonpositive strict diagonal-dominance margin at row {i}'
        margins.append(Fraction(margin, local.S))
    return {
        'passed': True,
        'source_sha256': certificate['source_sha256'],
        'hessian_shift': str(shift),
        'unit_upper_verified': True,
        'congruence_intervals': [[value.exact() for value in row] for row in b],
        'strict_dd_margins': list(map(str, margins)),
        'minimum_margin': str(min(margins)),
        'coarse_diagonal_interval': list(map(str, coarse_diagonal)),
        'coarse_off_diagonal_interval': list(map(str, coarse_off_diagonal)),
        'coarse_enclosures_verified': True,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('certificate', nargs='?', type=Path,
                        default=Path(__file__).with_name('local-dd.json'))
    parser.add_argument('--report', type=Path)
    parser.add_argument('--negative-controls', action='store_true')
    args = parser.parse_args()
    data = json.loads(args.certificate.read_text())
    result = check(data)
    result['certificate_sha256'] = hashlib.sha256(args.certificate.read_bytes()).hexdigest()
    if args.negative_controls:
        rejected = []
        for name in ('nonunit diagonal', 'large upper coefficient', 'wrong Hessian shift'):
            mutant = json.loads(json.dumps(data))
            if name == 'nonunit diagonal':
                mutant['unit_upper'][0][0] = '0'
            elif name == 'large upper coefficient':
                mutant['unit_upper'][0][1] = '1000000'
            else:
                mutant['hessian_shift'] = '1'
            try:
                check(mutant)
            except AssertionError:
                rejected.append(name)
            else:
                raise AssertionError('Corrupted certificate accepted: ' + name)
        result['rejected_controls'] = rejected
    if args.report:
        args.report.write_text(json.dumps(result, indent=2) + '\n')
    print('PASS: interval congruence is strictly diagonally dominant')
    print('Minimum exact margin (decimal diagnostic):', float(Fraction(result['minimum_margin'])))


if __name__ == '__main__':
    main()
