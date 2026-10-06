"""Exact six-window refinement. Its domain premise is explicit, not global."""
import argparse
from copy import deepcopy
from fractions import Fraction as Q
import hashlib
import json
from pathlib import Path

from check_bernstein import contact_enclosures, q, radius_interval, verify_tree

HERE = Path(__file__).resolve().parent

if not __debug__:
    raise RuntimeError('Exact checks require assertions.')


def check(data, source_raw=None):
    assert data['format'] == 'thomson-n9-refined-windows-v1'
    if source_raw is None:
        source_raw = (HERE/'near-sharp-d10.json').read_bytes()
    assert data['source_sha256'] == hashlib.sha256(source_raw).hexdigest()
    source = json.loads(source_raw)
    h = list(map(q, data['minorant']))
    assert len(h) == 21
    assert h == list(map(q, source['minorant']))
    epsilon, gap = q(data['window_half_width']), q(data['exterior_gap'])
    assert 0 < epsilon < Q(1, 10000) and gap > 0
    assert q(data['previous_window_half_width']) == Q(1, 10000)
    lower, upper = map(q, data['domain_t'])
    assert (lower, upper) == (Q(-3, 4), Q(5593, 10000))
    contacts = contact_enclosures()
    assert [tuple(map(q, pair)) for pair in data['root_contact_enclosures']] == contacts
    # The already established six old windows lie within the new proof domain.
    assert all(lower < lo-Q(1, 10000) and hi+Q(1, 10000) < upper for lo, hi in contacts)
    assert all(lo+epsilon > hi-epsilon for lo, hi in contacts)
    assert all(a[1]+epsilon < b[0]-epsilon for a, b in zip(contacts, contacts[1:]))
    intervals = [(lower, contacts[0][1]-epsilon)]
    intervals += [(a[0]+epsilon, b[1]-epsilon) for a, b in zip(contacts, contacts[1:])]
    intervals += [(contacts[-1][0]+epsilon, upper)]
    assert len(data['exterior']) == len(intervals) == 7
    shifted = h.copy()
    shifted[0] += gap
    reports = []
    for interval, record in zip(intervals, data['exterior']):
        assert tuple(map(q, record['domain_t'])) == interval
        lo, hi = interval
        assert lower <= lo < hi <= upper
        ylo, yhi = map(q, record['domain_y'])
        assert 0 <= ylo < yhi <= 1
        assert ylo*ylo <= (1-hi)/2 and yhi*yhi >= (1-lo)/2
        reports.append(verify_tree(shifted, record))
    return {'result': 'PASS', 'minorant': list(map(str, h)),
            'radius_interval': list(map(str, radius_interval())),
            'domain_t': list(map(str, (lower, upper))),
            'window_half_width': str(epsilon), 'exterior_slack_lower': str(gap),
            'old_six_windows_inside_domain': True, 'exterior': reports,
            'source_sha256': data['source_sha256'], 'source_minorant_matched': True,
            'scope': 'Pairwise gap only on [-3/4,5593/10000], after the original localization and antipodal exclusion'}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('certificate', nargs='?', type=Path, default=HERE/'refined-windows.json')
    parser.add_argument('--output', type=Path, default=HERE/'refined-windows.check.json')
    parser.add_argument('--source', type=Path, default=HERE/'near-sharp-d10.json')
    parser.add_argument('--negative-controls', action='store_true')
    args = parser.parse_args()
    raw = args.certificate.read_bytes()
    data = json.loads(raw)
    source_raw = args.source.read_bytes()
    result = check(data, source_raw)
    if args.negative_controls:
        cases = []
        for label in ('missing interval', 'inward endpoint', 'false gap', 'changed contact',
                      'changed minorant', 'wrong source hash'):
            bad = deepcopy(data)
            if label == 'missing interval':
                bad['exterior'].pop()
            elif label == 'inward endpoint':
                bad['exterior'][0]['domain_t'][0] = '-7/10'
            elif label == 'false gap':
                bad['exterior_gap'] = '1'
            elif label == 'changed contact':
                bad['root_contact_enclosures'][0][0] = '-1/2'
            elif label == 'changed minorant':
                bad['minorant'][0] = str(q(bad['minorant'][0])+Q(1, 10**31))
            else:
                bad['source_sha256'] = '0'*64
            try:
                check(bad, source_raw)
            except AssertionError:
                cases.append(label)
            else:
                raise AssertionError('Accepted mutation '+label)
        result['rejected_mutations'] = cases
    result['certificate_sha256'] = hashlib.sha256(raw).hexdigest()
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print('PASS:', sum(r['leaves'] for r in result['exterior']), 'leaves; epsilon',
          result['window_half_width'], 'gap', result['exterior_slack_lower'])


if __name__ == '__main__':
    main()
