"""Check finite polynomial positivity covers without a Hermite remainder theorem.

The split uses direct binomial formulas rather than the generator's triangular
de Casteljau construction. Every acceptance decision uses integers/Fraction.
"""
import argparse
from copy import deepcopy
from fractions import Fraction as Q
from functools import reduce
import hashlib
import json
from math import comb, gcd, lcm
from pathlib import Path
import time

from exact_interval import I, S

if not __debug__:
    raise RuntimeError('Exact verification requires assertions')


def q(value):
    assert type(value) in (int, str, Q)
    return Q(value)


def initial_coefficients(h, lower, upper):
    # Expand 1-2y*h(1-2y^2), then substitute y=lower+(upper-lower)*z.
    n = 2*len(h)-1
    coefficients = [Q(0)]*(n+1)
    coefficients[0] = 1
    for j, c in enumerate(h):
        for k in range(j+1):
            coefficients[2*k+1] -= 2*c*comb(j, k)*(-2)**k
    shifted = [sum(coefficients[j]*comb(j, i)*lower**(j-i)*(upper-lower)**i
                   for j in range(i, n+1)) for i in range(n+1)]
    bernstein = [sum(shifted[i]*Q(comb(k, i), comb(n, i)) for i in range(k+1))
                 for k in range(n+1)]
    denominator = lcm(*(b.denominator for b in bernstein))
    return [int(b*denominator) for b in bernstein]


def split_coefficients(b):
    n = len(b)-1
    left = [(1 << (n-k))*sum(comb(k, j)*b[j] for j in range(k+1))
            for k in range(n+1)]
    right = [(1 << k)*sum(comb(n-k, j-k)*b[j] for j in range(k, n+1))
             for k in range(n+1)]
    def reduced(row):
        common = reduce(gcd, row)
        return [x//common for x in row] if common else row
    return reduced(left), reduced(right)


def verify_tree(h, record):
    lower, upper = map(q, record['domain_y'])
    assert 0 <= lower < upper <= 1
    pending = [(initial_coefficients(h, lower, upper), 0)]
    leaves, depth_max = 0, 0
    for character in record['tree_preorder']:
        assert pending, 'extraneous tree node'
        b, depth = pending.pop()
        depth_max = max(depth_max, depth)
        if character == '1':
            assert all(c >= 0 for c in b), 'negative Bernstein coefficient at accepted leaf'
            leaves += 1
        else:
            assert character == '0', 'unknown tree token'
            left, right = split_coefficients(b)
            pending.extend([(right, depth+1), (left, depth+1)])
    assert not pending, 'uncovered interval'
    assert leaves == record['leaves'] and depth_max == record['maximum_depth']
    return {'leaves': leaves, 'maximum_depth': depth_max}


def radius_interval():
    lo = Q(7105483340929538113277041792727912437680, 10**40)
    hi = lo+Q(1, 10**40)
    assert Q(7, 10) < lo < hi < Q(18, 25)
    return lo, hi


def contact_enclosures():
    lo, hi = radius_interval()
    return [(lo*lo/2-1, hi*hi/2-1), (-hi, -lo), (Q(-1, 2), Q(-1, 2)),
            (2*lo*lo-1, 2*hi*hi-1), (1-3*hi*hi/2, 1-3*lo*lo/2), (lo/2, hi/2)]


def check(data):
    started = time.monotonic()
    assert data['format'] == 'thomson-n9-bernstein-minorant-v1'
    h = list(map(q, data['minorant']))
    assert len(h) == 21
    assert list(map(q, data['global']['domain_y'])) == [0, 1]
    base = verify_tree(h, data['global'])
    epsilon = q(data['window_half_width'])
    assert epsilon == Q(1, 10000)
    maximum = q(data['maximum_inner_product'])
    assert maximum == Q(5593, 10000)
    gap = q(data['exterior_gap'])
    assert gap > 0
    contacts = contact_enclosures()
    assert [tuple(map(q, pair)) for pair in data['root_contact_enclosures']] == contacts
    assert all(a[1]+epsilon < b[0]-epsilon for a, b in zip(contacts, contacts[1:]))
    assert all(lo+epsilon >= hi-epsilon for lo, hi in contacts)
    intervals = [(-1+epsilon, contacts[0][1]-epsilon)]
    intervals += [(a[0]+epsilon, b[1]-epsilon) for a, b in zip(contacts, contacts[1:])]
    intervals += [(contacts[-1][0]+epsilon, maximum)]
    assert len(data['exterior']) == len(intervals) == 7
    shifted = h.copy()
    shifted[0] += gap
    reports = []
    for interval, record in zip(intervals, data['exterior']):
        assert tuple(map(q, record['domain_t'])) == interval
        lower, upper = interval
        assert -1 <= lower < upper < 1
        ylo, yhi = map(q, record['domain_y'])
        assert 0 <= ylo < yhi <= 1
        assert ylo*ylo <= (1-upper)/2 and yhi*yhi >= (1-lower)/2
        reports.append(verify_tree(shifted, record))
    # Family minimality applies at any rational midpoint in (0,1), so no
    # refined stationarity/root theorem or Hermite interpolation is needed.
    midpoint = q(data['energy_midpoint'])
    energy_upper = q(data['candidate_energy_upper'])
    assert 0 < midpoint < 1
    r = I(midpoint)
    energy = (2*I(3).sqrt()/r+3/(2*(1-r*r).sqrt())+6/(4-r*r).sqrt()+
              I(3).sqrt()+6/(2+2*r).sqrt()+12/(2-r).sqrt())
    assert Q(energy.hi, S) <= energy_upper < Q(6439996633, 250000000)
    return {'result': 'PASS', 'minorant': list(map(str, h)),
            'radius_interval': list(map(str, radius_interval())),
            'energy_upper': str(energy_upper), 'energy_midpoint': str(midpoint),
            'exterior_slack_lower': str(gap), 'window_half_width': str(epsilon),
            'global': base, 'exterior': reports, 'seconds': time.monotonic()-started,
            'trust': 'Exact Bernstein identities and finite subdivision plus the proved candidate family minimum; no Hermite remainder theorem'}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('certificate', nargs='?', type=Path,
                    default=Path(__file__).with_name('bernstein-minorant.json'))
    ap.add_argument('--negative-controls', action='store_true')
    ap.add_argument('--output', type=Path,
                    default=Path(__file__).with_name('bernstein-minorant.check.json'))
    args = ap.parse_args()
    raw = args.certificate.read_bytes()
    data = json.loads(raw)
    report = check(data)
    if args.negative_controls:
        cases = []
        bad = deepcopy(data)
        bad['global']['tree_preorder'] = '1'
        bad['global']['leaves'], bad['global']['maximum_depth'] = 1, 0
        cases.append(('false unsplit global positivity', bad))
        bad = deepcopy(data)
        bad['global']['tree_preorder'] = bad['global']['tree_preorder'][:-1]
        cases.append(('missing final interval', bad))
        bad = deepcopy(data)
        bad['minorant'][0] = str(q(bad['minorant'][0])+1)
        cases.append(('raised minorant constant', bad))
        bad = deepcopy(data)
        bad['exterior_gap'] = '1'
        cases.append(('false exterior gap', bad))
        bad = deepcopy(data)
        bad['candidate_energy_upper'] = '0'
        cases.append(('false candidate upper bound', bad))
        for label, corrupted in cases:
            try:
                check(corrupted)
            except AssertionError:
                pass
            else:
                raise AssertionError('Corruption accepted: '+label)
        report['rejected_mutations'] = [label for label, _ in cases]
    report['certificate_sha256'] = hashlib.sha256(raw).hexdigest()
    args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'minorant'}, indent=2))


if __name__ == '__main__':
    main()
