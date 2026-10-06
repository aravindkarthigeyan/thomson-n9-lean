"""Independent FLINT full residual replay and five adversarial exact tests.

Does not import the matrix generator. Rooted polynomials are rebuilt before
symmetrizing; SOS polynomials are summed squares of rational factor columns.
"""
import argparse
import copy
from fractions import Fraction as Q
import hashlib
from itertools import permutations
import json
from pathlib import Path
import sys
import time

from flint import fmpq, fmpq_mat, fmpq_mpoly_ctx

HERE = Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'certificates'))
from polynomial import sosblocks
from check_sos_integer import check as integer_check

CTX = fmpq_mpoly_ctx.get(('u','v','t'))


def rat(value):
    if isinstance(value,fmpq):
        return value
    q = Q(value)
    return fmpq(q.numerator,q.denominator)


def polynomial(values):
    return CTX.from_dict({exponent:rat(value) for exponent,value in values.items()})


def symmetrize(poly):
    out = {}
    for exponent,value in poly.to_dict().items():
        for perm in permutations(range(3)):
            e = tuple(exponent[i] for i in perm)
            out[e] = out.get(e,fmpq(0))+value/6
    return CTX.from_dict(out)


def replay(data):
    degree,n = data['degree'],data['n']
    assert n == 9 and degree == 10
    u,v,t = [polynomial({exponent:1}) for exponent in ((1,0,0),(0,1,0),(0,0,1))]
    q = [CTX.constant(1),t-u*v]
    weight = (1-u*u)*(1-v*v)
    for k in range(1,degree):
        q.append(2*(t-u*v)*q[-1]-weight*q[-2])
    target = symmetrize(polynomial({(i,0,0):rat(c) for i,c in enumerate(data['minorant'])}))
    target -= rat(data['raw_energy'])/36
    right = CTX.constant(0)
    assert len(data['kernel_factors']) == degree+1
    for k,factor in enumerate(data['kernel_factors']):
        B = fmpq_mat([[rat(x) for x in row] for row in factor])
        assert B.nrows() == B.ncols() == degree-k+1
        G = B*B.transpose()
        p = CTX.from_dict({(i,j,0):G[i,j] for i in range(G.nrows()) for j in range(G.ncols())})
        S = symmetrize(q[k]*p)
        boundary = {}
        constant = fmpq(0)
        for (a,b,c),value in S.to_dict().items():
            for exponent in ((a+b,0,0),(0,a+b,0),(0,0,a+b)):
                boundary[exponent] = boundary.get(exponent,fmpq(0))+value
            constant += value/(n-1)
        right += (n-2)*S+CTX.from_dict(boundary)+constant
    specs = sosblocks(degree,Q(data['minimum_inner_product']),Q(data['maximum_inner_product']),data['sos_basis'])
    assert len(specs) == len(data['sos_factors'])
    for index,((g,basis),factor) in enumerate(zip(specs,data['sos_factors'])):
        size = len(basis)
        assert len(factor) == size and all(len(row) == size for row in factor)
        b = [[rat(x) for x in row] for row in factor]
        square_sum = CTX.constant(0)
        for column in range(size):
            terms = {}
            for row,p in enumerate(basis):
                coefficient = b[row][column]
                if coefficient:
                    for exponent,value in p.items():
                        terms[exponent] = terms.get(exponent,fmpq(0))+rat(value)*coefficient
            p = CTX.from_dict(terms)
            square_sum += p*p
        right += symmetrize(polynomial(g)*square_sum)
        print(f'Independent FLINT SOS {index+1}/{len(specs)}',flush=True)
    residual = (target-right).to_dict()
    assert all(residual.get(tuple(e[i] for i in perm),fmpq(0)) == c
               for e,c in residual.items() for perm in permutations(range(3)))
    full_loss = sum(map(abs,residual.values()),fmpq(0))
    compressed = {}
    for e,c in residual.items():
        key = tuple(sorted(e,reverse=True))
        compressed[key] = compressed.get(key,fmpq(0))+c
    assert full_loss == sum(map(abs,compressed.values()),fmpq(0))
    return {'full_residual_l1':str(full_loss),'full_nonzero_coefficients':len(residual),
            'compressed_nonzero_coefficients':len(compressed),
            'full_symmetry_checked':True,'compression_l1_equality_checked':True}


def audit(data,hermite,integer_report):
    started = time.time()
    report = replay(data)
    assert Q(report['full_residual_l1']) == Q(integer_report['residual_l1'])
    rejected = []
    for label in ('factor coefficient','claimed energy','minorant coefficient','missing SOS block','domain extension'):
        damaged = copy.deepcopy(data)
        if label == 'factor coefficient':
            damaged['sos_factors'][0][0][0] = str(Q(damaged['sos_factors'][0][0][0])+1)
        elif label == 'claimed energy':
            damaged['certified_energy'] = damaged['raw_energy']
        elif label == 'minorant coefficient':
            damaged['minorant'][0] = str(Q(damaged['minorant'][0])+1)
        elif label == 'missing SOS block':
            damaged['sos_factors'].pop()
        else:
            damaged['maximum_inner_product'] = '1'
        try:
            checked = integer_check(damaged,hermite)
            assert checked['spectrum_localization_threshold_met']
        except AssertionError:
            rejected.append(label)
        else:
            raise AssertionError('damaged certificate accepted: '+label)
        print('Rejected: '+label,flush=True)
    report.update({'passed':True,'integer_and_flint_exact_l1_identical':True,
                   'negative_controls_rejected':rejected,'seconds':time.time()-started})
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--certificate',type=Path,default=HERE/'near-sharp-d10.json')
    parser.add_argument('--hermite',type=Path,default=HERE/'hermite.json')
    parser.add_argument('--integer-report',type=Path,default=HERE/'near-sharp-d10.check.json')
    args = parser.parse_args()
    raw = args.certificate.read_bytes()
    integer_report = json.loads(args.integer_report.read_text())
    assert hashlib.sha256(raw).hexdigest() == integer_report['certificate_sha256']
    report = audit(json.loads(raw),json.loads(args.hermite.read_text()),integer_report)
    report['certificate_sha256'] = hashlib.sha256(raw).hexdigest()
    (HERE/'final-adversarial.check.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))
