"""Discover a finite exact Bernstein cover, including ultra-flat contacts."""
import argparse
from fractions import Fraction as F
from functools import reduce
import hashlib
import json
from math import comb, gcd, isqrt, lcm
from pathlib import Path
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(ROOT/'rigidity'))
from check_exact_gram import COLORS, bounds


def potential_polynomial(h):
    p = [F(0)]*(2*len(h))
    p[0] = F(1)
    for j, c in enumerate(h):
        for k in range(j+1):
            p[2*k+1] -= 2*c*comb(j, k)*(-2)**k
    return p


def affine(p, lo, hi):
    n = len(p)
    return [sum(p[j]*comb(j, k)*lo**(j-k)*(hi-lo)**k for j in range(k, n))
            for k in range(n)]


def integer_coefficients(p):
    n = len(p)-1
    b = [sum(p[i]*F(comb(k, i), comb(n, i)) for i in range(k+1)) for k in range(n+1)]
    denominator = lcm(*(x.denominator for x in b))
    return normalize([int(x*denominator) for x in b])


def normalize(row):
    divisor = reduce(gcd, row)
    return [x//divisor for x in row] if divisor else row


def split(row):
    n = len(row)-1
    rows = [row]
    for _ in range(n):
        rows.append([a+b for a, b in zip(rows[-1], rows[-1][1:])])
    return (normalize([r[0] << (n-i) for i, r in enumerate(rows)]),
            normalize([r[-1] << i for i, r in enumerate(reversed(rows))]))


def cover(p, lo, hi, max_depth):
    pending = [(integer_coefficients(affine(p, lo, hi)), 0)]
    bits, leaves, deepest = [], 0, 0
    while pending:
        row, depth = pending.pop()
        deepest = max(deepest, depth)
        if min(row) >= 0:
            bits.append('1')
            leaves += 1
        else:
            assert row[0] >= 0 and row[-1] >= 0, 'negative endpoint'
            assert depth < max_depth and len(bits) < 200000, 'cover budget exhausted'
            bits.append('0')
            left, right = split(row)
            pending.extend([(right, depth+1), (left, depth+1)])
    return {'domain_y': [str(lo), str(hi)], 'tree_preorder': ''.join(bits),
            'leaves': leaves, 'maximum_depth': deepest}


def sqrt_bounds(q, bits=180):
    denominator = 1 << bits
    low = isqrt(q.numerator*denominator**2//q.denominator)
    return F(low, denominator), F(low+(low*low*q.denominator < q.numerator*denominator**2), denominator)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--gap', default='1e-46')
    ap.add_argument('--max-depth', type=int, default=400)
    ap.add_argument('--output', type=Path, default=HERE/'bernstein-minorant.json')
    args = ap.parse_args()
    started = time.monotonic()
    raw = (HERE/'hermite.json').read_bytes()
    hermite = json.loads(raw)
    h = list(map(F, hermite['coefficients_monomial']))
    print('Generating global minorant cover ...', flush=True)
    base = cover(potential_polynomial(h), F(0), F(1), args.max_depth)
    print('Global cover:', base['leaves'], 'leaves, depth', base['maximum_depth'], flush=True)
    epsilon = F(1, 10000)
    contacts = sorted((a/2, b/2) for a, b in map(bounds, COLORS))
    assert all(a[1] < b[0] for a, b in zip(contacts, contacts[1:]))
    endpoints = [(-1+epsilon, contacts[0][1]-epsilon)]
    endpoints += [(a[0]+epsilon, b[1]-epsilon) for a, b in zip(contacts, contacts[1:])]
    endpoints += [(contacts[-1][0]+epsilon, F(5593, 10000))]
    gap = F(args.gap)
    shifted = h.copy()
    shifted[0] += gap
    p = potential_polynomial(shifted)
    exteriors = []
    for index, (lo, hi) in enumerate(endpoints):
        ylo = sqrt_bounds((1-hi)/2)[0]
        yhi = sqrt_bounds((1-lo)/2)[1]
        result = cover(p, ylo, yhi, args.max_depth)
        result['domain_t'] = [str(lo), str(hi)]
        exteriors.append(result)
        print('Exterior', index, ':', result['leaves'], 'leaves, depth', result['maximum_depth'], flush=True)
    result = {'format': 'thomson-n9-bernstein-minorant-v1',
              'minorant': list(map(str, h)), 'window_half_width': str(epsilon),
              'maximum_inner_product': '5593/10000', 'exterior_gap': str(gap),
              'energy_midpoint': hermite['radius_midpoint'],
              'candidate_energy_upper': hermite['energy_upper'],
              'root_contact_enclosures': [[str(a), str(b)] for a, b in contacts],
              'global': base, 'exterior': exteriors,
              'source_hermite_sha256': hashlib.sha256(raw).hexdigest(),
              'generation_seconds': time.monotonic()-started}
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print('Written:', args.output, flush=True)


if __name__ == '__main__':
    main()
