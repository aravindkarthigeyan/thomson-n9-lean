"""Numerical sharp polynomial SOS search with candidate contact nullspaces.

This is discovery, not a proof of feasibility or infeasibility. A found solution
is also rounded and passed through the independent nonsharp exact checker.
"""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
os.environ.setdefault('OMP_NUM_THREADS','1')
os.environ.setdefault('MKL_NUM_THREADS','1')
import argparse
from fractions import Fraction as F
from itertools import combinations,permutations
from math import comb
import json
from pathlib import Path
import sys
import time

import cvxpy as cp
import mpmath as mp
import numpy as np
from scipy.linalg import null_space,qr

from polynomial import monomials,rblock,sosblocks,sosblock,check_minorant
from generate_sos import operator,rational,psd_factor
from check_sos import check

sys.path.insert(0,str(Path(__file__).parents[1]/'sdp'))
from orbit_kernel_polynomials import vectors
sys.path.insert(0,str(Path(__file__).parents[1]/'numerics'))
from reconstruct import family_energy,family


def evaluate(p,point):
    return sum(float(c)*np.prod(np.asarray(point)**np.array(e)) for e,c in p.items())


def chebyshev_rows(rows):
    """Exact dyadic change of coefficient basis, converted only for discovery."""
    def expansion(n):
        if n==0:
            return [(0,F(1))]
        values=[(n-2*j,F(comb(n,j),2**(n-1))) for j in range((n+1)//2)]
        if n%2==0:
            values.append((0,F(comb(n,n//2),2**n)))
        return values
    transform=np.zeros((len(rows),len(rows)))
    for (a,b,c),col in rows.items():
        exact={}
        for i,x in expansion(a):
            for j,y in expansion(b):
                for k,z in expansion(c):
                    row=rows[tuple(sorted((i,j,k),reverse=True))]
                    exact[row]=exact.get(row,F(0))+x*y*z
        for row,value in exact.items():
            transform[row,col]=float(value)
    return transform


def hermite(d,r):
    nodes=[r*r/2-1,-r,-mp.mpf(1)/2,2*r*r-1,1-mp.mpf(3)*r*r/2,r/2]
    conditions=[(mp.mpf(-1),j) for j in range(2*d-11)]+[(t,j) for t in nodes for j in range(2)]
    a=[];b=[]
    for t,j in conditions:
        a.append([mp.mpf(0) if i<j else mp.factorial(i)/mp.factorial(i-j)*t**(i-j) for i in range(2*d+1)])
        b.append(mp.diff(lambda x:(2-2*x)**(-mp.mpf(1)/2),t,j))
    return mp.lu_solve(a,b)


def run(d,upper,output,basis_mode='symmetry-v1',row_basis='monomial',solver='CLARABEL',cvxopt_gap=2e-9):
    start=time.time()
    mp.mp.dps=100
    r=mp.findroot(lambda x:mp.diff(family_energy,x),(.70,.72))
    e=family_energy(r)
    hp=hermite(d,r)
    x=np.asarray(family(r,mp),float)
    g=x@x.T
    triples=np.unique(np.round(np.array([list(t) for i,j,k in combinations(range(9),3)
                                         for t in permutations((g[i,j],g[i,k],g[j,k]))]),13),axis=0)
    rows={v:i for i,v in enumerate(sorted({tuple(sorted(e,reverse=True)) for e in monomials(2*d)}))}
    specs=sosblocks(d,F(-1),F(upper),basis_mode)
    blocks=[rblock(k,d) for k in range(d+1)]+[sosblock(a,b) for a,b in specs]
    projections=[]
    svds=[]
    for k in range(d+1):
        pv,cv=vectors(k,d)
        v=np.array([[float(p.eval(float(r))) for p in pv]])
        if k%2==0:
            v=np.vstack([v,[float(c.eval(float(r))) for c in cv]])
        svds.append(np.linalg.svd(v,compute_uv=False).tolist())
        projections.append(null_space(v,rcond=1e-9))
    for multiplier,basis in specs:
        evaluators=[]
        for t in triples:
            if evaluate(multiplier,t)>1e-9:
                evaluators.append([evaluate(p,t) for p in basis])
        v=np.asarray(evaluators)
        svds.append(np.linalg.svd(v,compute_uv=False).tolist())
        projections.append(null_space(v,rcond=1e-9))
    ops=[]
    for block,n in zip(blocks,projections):
        ops.append(operator(block,rows)@np.kron(n,n))
    b=np.zeros(len(rows))
    for j,c in enumerate(hp):
        b[rows[(j,0,0)]]=float(c)
    b[rows[(0,0,0)]]-=float(e)/36
    if row_basis=='chebyshev':
        transform=chebyshev_rows(rows)
        ops=[transform@a for a in ops]
        b=transform@b
    active=[i for i,n in enumerate(projections) if n.shape[1]>0]
    combined=np.hstack([ops[i] for i in active])
    row_scale=1/np.maximum(np.linalg.norm(combined,axis=1),1e-12)
    combined=combined*row_scale[:,None]
    ops=[a*row_scale[:,None] for a in ops]
    b=b*row_scale
    u,s,vh=np.linalg.svd(combined,full_matrices=False)
    rank=int(np.sum(s>1e-9*s[0]))
    _,_,pivots=qr(combined.T,pivoting=True,mode='economic')
    selected=pivots[:rank]
    inconsistency=float(np.linalg.norm(b-u[:,:rank]@(u[:,:rank].T@b)))
    matrices={i:cp.Variable((projections[i].shape[1],projections[i].shape[1]),symmetric=True) for i in active}
    gamma=cp.Variable()
    expr=sum(ops[i]@cp.vec(matrices[i],order='C') for i in active)
    weights=1/np.maximum(np.linalg.norm(combined[selected,:],axis=1),1)
    constraints=[cp.multiply(weights,expr[selected]-b[selected])==0]
    constraints.extend(matrices[i]-gamma*np.eye(matrices[i].shape[0])>>0 for i in active)
    problem=cp.Problem(cp.Maximize(gamma),constraints)
    print(f'SHARP d={d}: PSD sizes {[projections[i].shape[1] for i in active]}, rank {rank}/{len(rows)}, discarded-row residual {inconsistency:.2e}',flush=True)
    solver_diagnostics={}
    if solver=='CVXOPT_DUAL':
        from cvxopt import matrix,solvers
        solvers.options.update({'maxiters':100,'abstol':cvxopt_gap,'reltol':1e-8,
                                'feastol':1e-8,'refinement':2,'show_progress':True})
        gs=[];hs=[]
        trace_column=np.zeros(rank)
        for i in active:
            size=projections[i].shape[1]
            linear=ops[i][selected,:]
            tensor=linear.T.reshape(size,size,rank)
            symmetric=(tensor+tensor.transpose(1,0,2))/2
            gs.append(matrix(-symmetric.reshape(size*size,rank)))
            hs.append(matrix(0.,(size,size)))
            trace_column+=linear@np.eye(size).ravel()
        solution=solvers.sdp(matrix(b[selected]),Gs=gs,hs=hs,
                             A=matrix(trace_column.reshape(1,-1)),b=matrix([1.]))
        solver_status=solution['status']
        gamma.value=-float(solution['y'][0])
        for i,rmat in zip(active,solution['zs']):
            matrices[i].value=np.array(rmat)+float(gamma.value)*np.eye(projections[i].shape[1])
        solver_value=float(gamma.value)
        solver_diagnostics={k:float(solution[k]) for k in
                            ['primal objective','dual objective','gap','primal infeasibility','dual infeasibility']
                            if solution.get(k) is not None}
    else:
        problem.solve(solver=cp.CLARABEL,max_iter=150,max_threads=1,tol_gap_abs=1e-9,tol_gap_rel=1e-9,tol_feas=1e-9)
        solver_status=problem.status
        solver_value=problem.value
    record={'evidence':'NUMERICAL ONLY; not exact feasibility or infeasibility',
            'degree':d,'sos_basis':basis_mode,'row_basis':row_basis,
            'maximum_inner_product':upper,'solver':solver,'status':solver_status,'margin':solver_value,
            'requested_cvxopt_gap':cvxopt_gap,
            'solver_diagnostics':solver_diagnostics,
            'seconds':time.time()-start,'rank':rank,'rows':len(rows),'left_null_residual':inconsistency,
            'projection_singular_values':svds,'reduced_block_sizes':[n.shape[1] for n in projections]}
    output.parent.mkdir(parents=True,exist_ok=True)
    if gamma.value is not None:
        full=[]
        for i,n in enumerate(projections):
            full.append(n@matrices[i].value@n.T if i in active else np.zeros((n.shape[0],n.shape[0])))
        residual=sum(ops[i]@matrices[i].value.ravel() for i in active)-b
        record['max_coefficient_residual']=float(np.max(np.abs(residual)))
        record['reduced_matrices']={str(i):matrices[i].value.tolist() for i in active}
        record['projections']=[n.tolist() for n in projections]
        # Preserve the numerical iterate before the potentially lengthy exact replay.
        output.write_text(json.dumps(record,indent=2)+'\n')
        if (float(gamma.value)>0 and solver_status=='optimal'
                and record['max_coefficient_residual']<1e-6):
            h=[rational(float(c),10**12) for c in hp]
            shift=F(1,10**11)
            for _ in range(12):
                hc=h.copy();hc[0]-=shift
                try:
                    check_minorant(hc)
                    break
                except AssertionError:
                    shift*=10
            factors=[psd_factor(a) for a in full]
            cert={'format':'thomson-threepoint-sos-v1','n':9,'degree':d,'sos_basis':basis_mode,
                  'minimum_inner_product':'-1','maximum_inner_product':upper,
                  'minorant':list(map(str,hc)),'raw_energy':str(rational(float(e))),
                  'kernel_factors':factors[:d+1],'sos_factors':factors[d+1:],
                  'certified_energy':str(-10**100),'discovery':record.copy()}
            verified=check(cert)
            cert['certified_energy']=verified['bound']
            output.with_suffix('.exact.json').write_text(json.dumps(cert,indent=2)+'\n')
            output.with_suffix('.exact.check.json').write_text(json.dumps(verified,indent=2)+'\n')
            record['exact_nonsharp_bound']=verified['bound']
    output.write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({k:v for k,v in record.items() if k not in ['projection_singular_values','reduced_matrices','projections']},indent=2),flush=True)


if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('--degree',type=int,default=8)
    ap.add_argument('--upper',default='14/25')
    ap.add_argument('--basis',default='symmetry-v1',choices=['symmetry-v1','symmetry-box-v1'])
    ap.add_argument('--row-basis',default='monomial',choices=['monomial','chebyshev'])
    ap.add_argument('--solver',default='CLARABEL',choices=['CLARABEL','CVXOPT_DUAL'])
    ap.add_argument('--cvxopt-gap',type=float,default=2e-9)
    ap.add_argument('--output',type=Path,required=True)
    args=ap.parse_args()
    run(args.degree,args.upper,args.output,args.basis,args.row_basis,args.solver,args.cvxopt_gap)
