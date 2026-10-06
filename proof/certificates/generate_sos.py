"""Discover numerical three-point SOS bounds, then export exact certificates.

Mathematical formulas are independently implemented from the Bachoc-Vallentin
framework used by the audited N7/N8 papers. No upstream source is copied.
"""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
os.environ.setdefault('OMP_NUM_THREADS','1')
import argparse
from fractions import Fraction as F
import json
from pathlib import Path
import time

import cvxpy as cp
import numpy as np
from scipy.sparse import coo_matrix
from numpy.polynomial import legendre as leg

from polynomial import (compress,monomials,rblock,sosblocks,sosblock,check_minorant,
                        DETERMINANT_MOMENT)
from check_sos import check


def operator(block,rows):
    ri=[]
    ci=[]
    values=[]
    m=len(block)
    for i,row in enumerate(block):
        for j,p in enumerate(row):
            for e,c in compress(p).items():
                ri.append(rows[e])
                ci.append(i*m+j)
                values.append(float(c))
    return coo_matrix((values,(ri,ci)),shape=(len(rows),m*m)).tocsr()


def rational(x,den=10**10):
    return F(int(round(float(x)*den)),den)


def psd_factor(a):
    w,v=np.linalg.eigh((a+a.T)/2)
    b=v*np.sqrt(np.maximum(w,0))[None,:]
    return [[str(rational(x)) for x in row] for row in b]


def run(d,lower,upper,output,solver,basis_mode,determinant_moment=False):
    start=time.time()
    rows={e:i for i,e in enumerate(sorted({tuple(sorted(e,reverse=True)) for e in monomials(2*d)}))}
    kernels=[rblock(k,d) for k in range(d+1)]
    sos=[sosblock(g,b) for g,b in sosblocks(d,F(lower),F(upper),basis_mode)]
    polys=kernels+sos
    ops=[operator(block,rows) for block in polys]
    matrices=[cp.Variable((len(block),len(block)),PSD=True) for block in polys]
    h=cp.Variable(2*d+1)
    e=cp.Variable()
    transform=np.zeros((2*d+1,2*d+1))
    for j in range(2*d+1):
        coeff=leg.leg2poly([0]*j+[1])
        transform[:len(coeff),j]=coeff
    hmono=transform@h
    hop=np.zeros((len(rows),2*d+1))
    for j in range(2*d+1):
        hop[rows[(j,0,0)],j]=1
    const=np.zeros(len(rows)); const[rows[(0,0,0)]]=1/36
    lhs=hop@hmono-const*e
    rhs=sum(op@cp.vec(a,order='C') for op,a in zip(ops,matrices))
    mu=cp.Variable(nonneg=True) if determinant_moment else None
    if determinant_moment:
        moment=np.zeros(len(rows))
        for exponent,coefficient in compress(DETERMINANT_MOMENT).items():
            moment[rows[exponent]]=float(coefficient)
        rhs+=mu*moment
    constraints=[lhs==rhs]
    # Include endpoint-sensitive points and six candidate contacts.
    r=.7105483340929538113
    nodes=np.array([r*r/2-1,-r,-.5,2*r*r-1,1-1.5*r*r,r/2])
    ts=np.unique(np.concatenate([np.linspace(-1,.999,1001),-np.cos(np.linspace(0,np.pi,1001))[:-1],nodes]))
    pv=leg.legvander(ts,2*d)
    constraints.append(pv@h<=1/np.sqrt(2-2*ts))
    problem=cp.Problem(cp.Maximize(e),constraints)
    print(f'd={d} inner_product=[{lower},{upper}]: {len(rows)} identities, PSD sizes {[len(b) for b in polys]}',flush=True)
    if solver=='CLARABEL':
        problem.solve(solver=cp.CLARABEL,max_iter=150,max_threads=1,tol_gap_abs=1e-9,tol_gap_rel=1e-9,tol_feas=1e-9)
    else:
        problem.solve(solver=cp.SCS,max_iters=100000,eps=1e-7)
    print(f'numerical status {problem.status}, objective {problem.value}, seconds {time.time()-start:.1f}',flush=True)
    if h.value is None:
        raise RuntimeError('No numerical solution')
    dual=np.asarray(constraints[0].dual_value)
    output.parent.mkdir(parents=True,exist_ok=True)
    dual_report={'evidence':'numerical pseudo-moments, not a realizable configuration',
                 'coefficient_duals':{','.join(map(str,k)):float(dual[i]) for k,i in rows.items()},
                 'normalized_moments':{','.join(map(str,k)):float(dual[i]/dual[rows[(0,0,0)]]) for k,i in rows.items()},
                 'pair_grid':ts.tolist(),'pair_grid_duals':np.asarray(constraints[1].dual_value).tolist()}
    output.with_suffix('.dual.json').write_text(json.dumps(dual_report,indent=2)+'\n')
    coeff=[rational(c) for c in transform@h.value]
    adjustment=F(1,10**10)
    for _ in range(12):
        trial=coeff.copy();trial[0]-=adjustment
        try:
            leaves=check_minorant(trial)
            break
        except AssertionError:
            adjustment*=10
    else:
        raise RuntimeError('Could not certify the minorant')
    factors=[psd_factor(a.value) for a in matrices]
    data={'format':'thomson-threepoint-sos-v1','n':9,'degree':d,
          'sos_basis':basis_mode,
          'minimum_inner_product':str(F(lower)),'minorant':list(map(str,trial)),
          'maximum_inner_product':str(F(upper)),
          'raw_energy':str(rational(e.value)),
          'kernel_factors':factors[:d+1],'sos_factors':factors[d+1:],
          'determinant_coefficient':str(max(F(0),rational(mu.value))) if determinant_moment else '0',
          'certified_energy':str(-10**100),
          'discovery':{'solver':solver,'status':problem.status,'numeric_objective':float(problem.value),
                       'minorant_adjustment':str(adjustment),'seconds':time.time()-start}}
    report=check(data)
    data['certified_energy']=report['bound']
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(data,indent=2)+'\n')
    output.with_suffix('.check.json').write_text(json.dumps(report,indent=2)+'\n')
    print(f'EXACT bound {report["bound_decimal"]:.12f}, coefficient residual {float(F(report["residual_l1"])):.3e}, minorant leaves {leaves}',flush=True)


if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('--degree',type=int,default=3)
    ap.add_argument('--lower',default='-1')
    ap.add_argument('--upper',default='1')
    ap.add_argument('--output',type=Path,required=True)
    ap.add_argument('--solver',default='CLARABEL',choices=['CLARABEL','SCS'])
    ap.add_argument('--basis',default='symmetry-v1',choices=['monomial','symmetry-v1','symmetry-box-v1'])
    ap.add_argument('--determinant-moment',action='store_true')
    args=ap.parse_args()
    run(args.degree,args.lower,args.upper,args.output,args.solver,args.basis,args.determinant_moment)
