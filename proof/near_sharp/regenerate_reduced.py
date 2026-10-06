"""Reconstruct the reduced certificate's mathematical data from the frozen input.

Discovery/reproduction only. The separate integer and Bernstein checkers remain
the validators. This uses the documented Codex/Claude rounding recipe, with a
fixed-point interval energy bound instead of Claude's Arb energy computation.
"""
import argparse
from fractions import Fraction as Q
import hashlib
import json
from pathlib import Path

from audit_final_certificate import replay
from check_bernstein import contact_enclosures, radius_interval
from exact_interval import I, S
from generate_bernstein import cover, potential_polynomial, sqrt_bounds

HERE = Path(__file__).resolve().parent
FROZEN_SHA = 'c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, default=HERE/'reduced/regeneration.check.json')
    args = parser.parse_args()
    raw = (HERE/'near-sharp-d10.json').read_bytes()
    assert hashlib.sha256(raw).hexdigest() == FROZEN_SHA
    data = json.loads(raw)
    scale = 10**60
    original = list(map(Q, data['minorant']))
    h = [Q(round(c*scale), scale) for c in original]
    error = sum(abs(a-b) for a, b in zip(original[1:], h[1:]))
    h[0] = Q((original[0]-error-Q(1, scale))*scale // 1, scale)
    assert original[0]-h[0]-error >= Q(1, scale)
    data['minorant'] = list(map(str, h))
    for key in ('kernel_factors', 'sos_factors'):
        data[key] = [[[str(Q(round(Q(c)*scale), scale)) for c in row]
                      for row in block] for block in data[key]]
    midpoint = radius_interval()[0]
    r = I(midpoint)
    energy = (2*I(3).sqrt()/r+3/(2*(1-r*r).sqrt())+6/(4-r*r).sqrt()+
              I(3).sqrt()+6/(2+2*r).sqrt()+12/(2-r).sqrt())
    upper = Q(energy.hi, S)
    energy_upper = Q(-((-upper.numerator*scale)//upper.denominator), scale)
    data['raw_energy'] = str(energy_upper)
    loss = Q(replay(data)['full_residual_l1'])
    data['certified_energy'] = str(energy_upper-36*loss)
    assert 36*loss < Q(1, 10**46)

    expected_raw = (HERE/'reduced/near-sharp-d10-reduced-D60.json').read_bytes()
    expected = json.loads(expected_raw)
    mathematical_keys = set(data)-{'discovery'}
    assert mathematical_keys == set(expected)-{'discovery'}
    assert all(data[k] == expected[k] for k in mathematical_keys)

    bernstein_raw = (HERE/'reduced/bernstein-reduced.json').read_bytes()
    bernstein = json.loads(bernstein_raw)
    assert bernstein['minorant'] == data['minorant']
    assert Q(bernstein['energy_midpoint']) == midpoint
    assert Q(bernstein['candidate_energy_upper']) == energy_upper
    assert cover(potential_polynomial(h), Q(0), Q(1), 400) == bernstein['global']
    epsilon, gap = Q(1, 10000), Q(1, 10**46)
    contacts = contact_enclosures()
    assert bernstein['root_contact_enclosures'] == [list(map(str, c)) for c in contacts]
    endpoints = [(-1+epsilon, contacts[0][1]-epsilon)]
    endpoints += [(a[0]+epsilon, b[1]-epsilon) for a, b in zip(contacts, contacts[1:])]
    endpoints += [(contacts[-1][0]+epsilon, Q(5593, 10000))]
    shifted = h.copy()
    shifted[0] += gap
    exterior = []
    for lo, hi in endpoints:
        ylo, yhi = sqrt_bounds((1-hi)/2, 32)[0], sqrt_bounds((1-lo)/2, 32)[1]
        record = cover(potential_polynomial(shifted), ylo, yhi, 400)
        record['domain_t'] = list(map(str, (lo, hi)))
        exterior.append(record)
    assert exterior == bernstein['exterior']
    report = {'result': 'PASS', 'scope': 'Every mathematical datum regenerated; discovery metadata excluded',
              'source_sha256': FROZEN_SHA,
              'certificate_sha256': hashlib.sha256(expected_raw).hexdigest(),
              'bernstein_sha256': hashlib.sha256(bernstein_raw).hexdigest(),
              'energy_loss': str(36*loss), 'global_leaves': bernstein['global']['leaves']}
    args.report.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
