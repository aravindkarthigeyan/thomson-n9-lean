"""Discover a finer six-contact cover after the antipodal window is excluded."""
import argparse
from fractions import Fraction as Q
import hashlib
import json
from pathlib import Path

from generate_bernstein import cover, potential_polynomial, sqrt_bounds
from check_bernstein import contact_enclosures

HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--epsilon', default='1e-8')
    parser.add_argument('--gap', default='1e-33')
    parser.add_argument('--source', type=Path, default=HERE/'near-sharp-d10.json')
    parser.add_argument('--output', type=Path, default=HERE/'refined-windows.json')
    args = parser.parse_args()
    raw = args.source.read_bytes()
    h = list(map(Q, json.loads(raw)['minorant']))
    epsilon, gap = Q(args.epsilon), Q(args.gap)
    contacts = contact_enclosures()
    endpoints = [(Q(-3, 4), contacts[0][1]-epsilon)]
    endpoints += [(a[0]+epsilon, b[1]-epsilon) for a, b in zip(contacts, contacts[1:])]
    endpoints += [(contacts[-1][0]+epsilon, Q(5593, 10000))]
    shifted = h.copy()
    shifted[0] += gap
    polynomial = potential_polynomial(shifted)
    records = []
    for index, (lo, hi) in enumerate(endpoints):
        ylo, yhi = sqrt_bounds((1-hi)/2)[0], sqrt_bounds((1-lo)/2)[1]
        record = cover(polynomial, ylo, yhi, 400)
        record['domain_t'] = list(map(str, (lo, hi)))
        records.append(record)
        print(index, record['leaves'], record['maximum_depth'], flush=True)
    result = {'format': 'thomson-n9-refined-windows-v1',
              'minorant': list(map(str, h)), 'window_half_width': str(epsilon),
              'exterior_gap': str(gap), 'domain_t': ['-3/4', '5593/10000'],
              'previous_window_half_width': '1/10000',
              'root_contact_enclosures': [list(map(str, interval)) for interval in contacts],
              'exterior': records, 'source_sha256': hashlib.sha256(raw).hexdigest()}
    args.output.write_text(json.dumps(result, indent=2)+'\n')


if __name__ == '__main__':
    main()
