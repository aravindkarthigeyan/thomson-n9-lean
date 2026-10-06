"""Untrusted discovery of a rational ambient27 Hessian congruence."""
import argparse
from fractions import Fraction
import hashlib
import json
from pathlib import Path

import mpmath as mp

import check_ambient_dd as checker


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output',type=Path,default=Path(__file__).with_name('ambient-dd.json'))
    parser.add_argument('--penalty',type=int,default=1000000)
    args = parser.parse_args()
    source = Path(__file__).with_name('local.json')
    data = json.loads(source.read_text())
    local = checker.local
    r = local.I(Fraction(*data['radius_lower']),Fraction(*data['radius_upper']))
    penalty = Fraction(args.penalty)
    shift = Fraction(*data['hessian_lower'])
    a = checker.augmented_hessian(r,penalty)
    for i in range(27):
        a[i][i] -= shift
    mp.mp.dps = 110
    midpoint = mp.matrix([[mp.mpf(v.lo+v.hi)/(2*local.S) for v in row] for row in a])
    chol = mp.cholesky(midpoint)
    lower = mp.matrix([[chol[i,j]/chol[j,j] for j in range(27)] for i in range(27)])
    upper = lower.T**-1
    denominator = 10**75
    rational = [[str(Fraction(int(mp.nint(upper[i,j]*denominator)),denominator))
                 if i < j else str(int(i == j)) for j in range(27)] for i in range(27)]
    result = {
        'format': 'thomson-n9-ambient-congruence-dd-v1',
        'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'arithmetic_bits': local.BITS,
        'unit_upper': rational,
        'hessian_shift': str(shift),
        'normal_penalty': str(penalty),
    }
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print('Wrote untrusted ambient27 congruence:',args.output)


if __name__ == '__main__':
    main()
