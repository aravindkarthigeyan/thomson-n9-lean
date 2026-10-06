"""Exact Delsarte LP certificate and pair-separation checker."""
import argparse
from fractions import Fraction as F
import json
from math import isqrt
from pathlib import Path

from polynomial import check_minorant

if not __debug__:
    raise RuntimeError('Run the exact checker without Python -O: assertions enforce certificate checks')


def legendre_monomials(a):
    p0=[F(1)]
    p1=[F(0),F(1)]
    polynomials=[p0,p1]
    for n in range(1,len(a)-1):
        row=[F(0)]*(n+2)
        for i,x in enumerate(polynomials[n]):
            row[i+1]+=(2*n+1)*x/F(n+1)
        for i,x in enumerate(polynomials[n-1]):
            row[i]-=n*x/F(n+1)
        polynomials.append(row)
    h=[F(0)]*len(a)
    for c,row in zip(a,polynomials):
        for j,x in enumerate(row):
            h[j]+=c*x
    return h


def y_upper(t,den=10**12):
    q=(1-t)/2
    low=isqrt((q.numerator*den*den)//q.denominator)
    out=F(low,den)
    if out*out<q:
        out+=F(1,den)
    assert out*out>=q
    return out


def check(data):
    assert data['N']==9
    a=list(map(F,data['coefficients_legendre']))
    assert all(c>=0 for c in a[1:])
    lo,hi=map(F,data['pair_domain'])
    assert -1<=lo<hi==1
    h=legendre_monomials(a)
    leaves=check_minorant(h,y_upper=y_upper(lo))
    bound=(81*a[0]-9*sum(a))/2
    assert bound==F(data['exact_LP_bound'])
    out={'passed':True,'bound':str(bound),'bound_decimal':float(bound),'minimum_inner_product':str(lo),
         'minorant_bernstein_leaves':leaves}
    if 'separation_proposal' in data:
        separation=data['separation_proposal']
        t=F(separation['upper_inner_product'])
        eup=F(data['candidate_energy_upper'])
        gap=eup-bound
        assert gap>0 and lo<=t<1
        hp=h.copy()
        strict_margin=F(1,10**8)
        hp[0]+=gap+strict_margin
        sleaves=check_minorant(hp,y_upper=y_upper(t))
        out.update({'maximum_inner_product_strictly_below':str(t),'energy_threshold':str(eup),
                    'strict_margin':str(strict_margin),'separation_bernstein_leaves':sleaves})
    return out


if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('certificate',type=Path)
    ap.add_argument('--report',type=Path)
    ap.add_argument('--negative-control',action='store_true')
    args=ap.parse_args()
    data=json.loads(args.certificate.read_text())
    report=check(data)
    if args.negative_control:
        import copy
        corrupt=copy.deepcopy(data)
        corrupt['coefficients_legendre'][0]=str(F(corrupt['coefficients_legendre'][0])+1)
        try:
            check(corrupt)
        except AssertionError:
            report['negative_control_rejected']=True
        else:
            raise AssertionError('corrupted minorant accepted')
    if args.report:
        args.report.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))
