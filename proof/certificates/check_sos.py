"""Exact rational verification of polynomial three-point lower certificates.

No numerical solver is imported. PSD matrices are explicitly rational B B^T.
Coefficient residual is bounded by its exact l1 norm on [-1,1]^3.
"""
import argparse
from fractions import Fraction as F
import json
from pathlib import Path

from polynomial import (ZERO,add,scale,sym,rblock,sosblocks,sosblock,
                        weighted_block,gram_factor,check_minorant,DETERMINANT_MOMENT)

if not __debug__:
    raise RuntimeError('Run the exact checker without Python -O: assertions enforce certificate checks')


def check(data):
    assert data['format']=='thomson-threepoint-sos-v1'
    n=data['n']
    d=data['degree']
    assert n==9 and 1<=d<=10
    lower=F(data['minimum_inner_product'])
    upper=F(data.get('maximum_inner_product','1'))
    assert -1<=lower<upper<=1
    h=list(map(F,data['minorant']))
    assert len(h)<=2*d+1
    leaves=check_minorant(h)
    pairs=F(n*(n-1),2)
    raw=F(data['raw_energy'])
    residual=add(sym({(i,0,0):c for i,c in enumerate(h)}),{ZERO:-raw/pairs})
    determinant_coefficient=F(data.get('determinant_coefficient','0'))
    assert determinant_coefficient>=0
    residual=add(residual,scale(DETERMINANT_MOMENT,-determinant_coefficient))
    assert len(data['kernel_factors'])==d+1
    for k,factor in enumerate(data['kernel_factors']):
        b=[list(map(F,row)) for row in factor]
        assert len(b)==d-k+1 and all(len(row)==len(b) for row in b)
        residual=add(residual,scale(weighted_block(rblock(k,d,n),gram_factor(b)),-1))
    specs=sosblocks(d,lower,upper,data.get('sos_basis','monomial'))
    assert len(data['sos_factors'])==len(specs)
    for factor,(g,basis) in zip(data['sos_factors'],specs):
        b=[list(map(F,row)) for row in factor]
        assert len(b)==len(basis) and all(len(row)==len(b) for row in b)
        residual=add(residual,scale(weighted_block(sosblock(g,basis),gram_factor(b)),-1))
    loss=sum(abs(c) for c in residual.values())
    bound=raw-pairs*loss
    assert F(data['certified_energy'])<=bound, 'claimed bound exceeds exact residual-adjusted bound'
    return {'passed':True,'n':n,'degree':d,'minimum_inner_product':str(lower),
            'maximum_inner_product':str(upper),
            'bound':str(bound),'bound_decimal':float(bound),'raw_energy':str(raw),
            'residual_l1':str(loss),'minorant_bernstein_leaves':leaves}


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('certificate',type=Path)
    ap.add_argument('--report',type=Path)
    ap.add_argument('--negative-control',action='store_true')
    args=ap.parse_args()
    data=json.loads(args.certificate.read_text())
    report=check(data)
    if args.negative_control:
        import copy
        corrupted=[]
        corrupt=copy.deepcopy(data)
        corrupt['certified_energy']=str(F(corrupt['certified_energy'])+1)
        corrupted.append(('energy bound',corrupt))
        corrupt=copy.deepcopy(data)
        corrupt['minorant'][0]=str(F(corrupt['minorant'][0])+1)
        corrupted.append(('minorant coefficient',corrupt))
        corrupt=copy.deepcopy(data)
        corrupt['kernel_factors'][0][0][0]=str(F(corrupt['kernel_factors'][0][0][0])+1)
        corrupted.append(('PSD factor coefficient',corrupt))
        for label,corrupt in corrupted:
            try:
                check(corrupt)
            except AssertionError:
                pass
            else:
                raise AssertionError('corrupted certificate accepted: '+label)
        report['negative_controls_rejected']=[label for label,_ in corrupted]
    if args.report:
        args.report.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__=='__main__':
    main()
