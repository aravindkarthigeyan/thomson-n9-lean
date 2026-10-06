"""Exact SOS residual replay with common-denominator integer arithmetic.

Symmetric polynomials are stored by sums of coefficients in each exponent
orbit. All coefficients in an orbit are equal, so the compressed coefficient
l1 norm equals the full coefficient l1 norm. This is a different arithmetic
implementation from check_sos.py, with the same written soundness theorem.
"""
import argparse
from fractions import Fraction as F
import hashlib
import json
from math import lcm
from pathlib import Path
import sys
import time

from polynomial import ZERO, sosblocks, qkernels, compress, check_minorant

if not __debug__:
    raise RuntimeError('Exact checking requires assertions; do not use python -O')


def rational(value):
    assert type(value) in (str, int, F), 'Rational data must be strings or integers, never JSON floats'
    return F(value)


def add_term(p, exponent, coefficient):
    p[exponent] = p.get(exponent, 0)+coefficient


def multiply(p, q):
    out = {}
    for e, c in p.items():
        for f, d in q.items():
            exponent = tuple(a+b for a, b in zip(e, f))
            add_term(out, exponent, c*d)
    return {e: c for e, c in out.items() if c}


def orbit_sum(p):
    out = {}
    for e, c in p.items():
        add_term(out, tuple(sorted(e, reverse=True)), c)
    return {e: c for e, c in out.items() if c}


def integer_polynomial(p):
    denominator = lcm(*(c.denominator for c in p.values())) if p else 1
    return {e: int(c*denominator) for e, c in p.items()}, denominator


def kernel_entry(q, i, j, n):
    """Return (n-1) times compressed R_k[i,j], directly before symmetrizing."""
    assert all(v.denominator == 1 for v in q.values())
    p = {(a+i, b+j, c): int(v) for (a, b, c), v in q.items()}
    out = {e: (n-1)*(n-2)*v for e, v in orbit_sum(p).items()}
    for (a, b, c), value in p.items():
        for degree in (a+b, a+c, b+c):
            add_term(out, (degree, 0, 0), (n-1)*value)
    add_term(out, ZERO, sum(p.values()))
    return {e: c for e, c in out.items() if c}


def integer_gram(factor, size):
    values = [[rational(value) for value in row] for row in factor]
    assert len(values) == size and all(len(row) == size for row in values)
    denominator = lcm(*(x.denominator for row in values for x in row))
    b = [[int(x*denominator) for x in row] for row in values]
    gram = [[0]*size for _ in range(size)]
    for i in range(size):
        for j in range(i, size):
            value = sum(x*y for x, y in zip(b[i], b[j]))
            gram[i][j] = gram[j][i] = value
    return gram, denominator*denominator


def weighted_integer(size, gram, entry):
    out = {}
    for i in range(size):
        for j in range(i, size):
            weight = gram[i][j]*(1 if i == j else 2)
            if not weight:
                continue
            for exponent, coefficient in entry(i, j).items():
                add_term(out, exponent, coefficient*weight)
    return out


def check(data, hermite_data=None, progress=False, require_localization=False, bernstein_data=None):
    started = time.monotonic()
    assert hermite_data is None or bernstein_data is None
    assert not require_localization or hermite_data is not None or bernstein_data is not None
    assert data['format'] == 'thomson-threepoint-sos-v1'
    n, degree = data['n'], data['degree']
    assert type(n) is int and n == 9 and type(degree) is int and degree >= 0
    lower, upper = rational(data['minimum_inner_product']), rational(data['maximum_inner_product'])
    assert -1 <= lower < upper <= 1
    h = list(map(rational, data['minorant']))
    assert len(h) <= 2*degree+1
    raw = rational(data['raw_energy'])
    hermite_report = None
    bernstein_report = None
    if bernstein_data is not None:
        sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'near_sharp'))
        from check_bernstein import check as check_bernstein
        bernstein_report = check_bernstein(bernstein_data)
        assert h == list(map(F, bernstein_report['minorant']))
        assert raw == F(bernstein_report['energy_upper'])
        assert degree == 10 and lower == -1 and upper == F(5593, 10000)
        minorant_leaves = bernstein_report['global']['leaves']
    elif hermite_data is None:
        minorant_leaves = check_minorant(h)
    else:
        sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'near_sharp'))
        from check_hermite import check as check_hermite
        hermite_report = check_hermite(hermite_data)
        assert h == list(map(F, hermite_report['coefficients_monomial']))
        assert raw == F(hermite_report['energy_upper'])
        assert degree == 10 and lower == -1 and upper == F(5593, 10000)
        minorant_leaves = None
    residual = {(i, 0, 0): coefficient for i, coefficient in enumerate(h)}
    residual[ZERO] = residual.get(ZERO, F(0))-raw/36
    multiplier = rational(data.get('determinant_coefficient', '0'))
    assert multiplier >= 0
    if multiplier:
        from polynomial import DETERMINANT_MOMENT
        for exponent, coefficient in compress(DETERMINANT_MOMENT).items():
            residual[exponent] = residual.get(exponent, F(0))-multiplier*coefficient

    def subtract(values, denominator):
        for exponent, numerator in values.items():
            residual[exponent] = residual.get(exponent, F(0))-F(numerator, denominator)

    assert len(data['kernel_factors']) == degree+1
    for k, (q, factor) in enumerate(zip(qkernels(degree), data['kernel_factors'])):
        size = degree-k+1
        gram, denominator = integer_gram(factor, size)
        values = weighted_integer(size, gram, lambda i, j: kernel_entry(q, i, j, n))
        subtract(values, denominator*(n-1))
        if progress:
            print(f'Kernel {k}/{degree} exact', flush=True)
    specs = sosblocks(degree, lower, upper, data.get('sos_basis', 'monomial'))
    assert len(specs) == len(data['sos_factors'])
    for index, ((g, basis), factor) in enumerate(zip(specs, data['sos_factors'])):
        polynomials = [p if isinstance(p, dict) else {p: F(1)} for p in basis]
        integers = []
        for p in polynomials:
            integer, denominator = integer_polynomial(p)
            assert denominator == 1
            integers.append(integer)
        multiplier_poly, multiplier_denominator = integer_polynomial(g)
        size = len(basis)
        gram, denominator = integer_gram(factor, size)
        def entry(i, j):
            return orbit_sum(multiply(multiply(integers[i], integers[j]), multiplier_poly))
        values = weighted_integer(size, gram, entry)
        subtract(values, denominator*multiplier_denominator)
        if progress:
            print(f'SOS {index+1}/{len(specs)} exact', flush=True)
    loss = sum(abs(c) for c in residual.values())
    bound = raw-36*loss
    assert rational(data['certified_energy']) <= bound
    report = {'passed': True, 'n': n, 'degree': degree,
              'minimum_inner_product': str(lower), 'maximum_inner_product': str(upper),
              'sos_basis': data.get('sos_basis', 'monomial'),
              'determinant_coefficient': str(multiplier),
              'bound': str(bound), 'bound_decimal': float(bound),
              'residual_l1': str(loss), 'energy_loss': str(36*loss),
              'minorant_bernstein_leaves': minorant_leaves,
              'compressed_coefficients': len(residual),
              'seconds': time.monotonic()-started,
              'arithmetic': 'stdlib common-denominator integers and Fraction'}
    if hermite_report is not None:
        slack = F(hermite_report['exterior_slack_lower'])
        report['exterior_slack_lower'] = str(slack)
        report['spectrum_localization_threshold_met'] = 36*loss < slack
        report['hermite_report'] = hermite_report
    if bernstein_report is not None:
        slack = F(bernstein_report['exterior_slack_lower'])
        report['exterior_slack_lower'] = str(slack)
        report['spectrum_localization_threshold_met'] = 36*loss < slack
        report['bernstein_report'] = bernstein_report
    if require_localization:
        assert report.get('spectrum_localization_threshold_met') is True
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('certificate', type=Path)
    parser.add_argument('--hermite-certificate', type=Path)
    parser.add_argument('--bernstein-certificate', type=Path)
    parser.add_argument('--report', type=Path)
    parser.add_argument('--progress', action='store_true')
    parser.add_argument('--require-localization', action='store_true')
    args = parser.parse_args()
    raw = args.certificate.read_bytes()
    hermite = json.loads(args.hermite_certificate.read_text()) if args.hermite_certificate else None
    bernstein = json.loads(args.bernstein_certificate.read_text()) if args.bernstein_certificate else None
    report = check(json.loads(raw), hermite, args.progress, args.require_localization, bernstein)
    report['certificate_sha256'] = hashlib.sha256(raw).hexdigest()
    rendered = json.dumps(report, indent=2)+'\n'
    if args.report:
        args.report.write_text(rendered)
    print(rendered, end='')
