"""Unrestricted 15-variable stationary refinement from unrelated random starts.

The gauge fixes point 0 at the north pole and point 1 in the xz meridian.
No D3h coordinates, radius, stationarity equation, or energy is used here.
"""
import argparse
import json
from pathlib import Path
import mpmath as mp
import numpy as np
from scipy.optimize import minimize
from reconstruct import energy_gradient


def gauge(x):
    ez=x[0]
    ex=x[1]-(x[1]@ez)*ez
    ex/=np.linalg.norm(ex)
    ey=np.cross(ez,ex)
    y=x@np.stack((ex,ey,ez),axis=1)
    v=[np.arccos(np.clip(y[1,2],-1,1))]
    for p in y[2:]:
        v.extend([np.arccos(np.clip(p[2],-1,1)),np.arctan2(p[1],p[0])])
    return list(map(lambda a:mp.mpf(str(a)),v))


def coordinates(v):
    angles=[(mp.mpf(0),mp.mpf(0)),(v[0],mp.mpf(0))]
    angles.extend(zip(v[1::2],v[2::2]))
    return [mp.matrix([mp.sin(t)*mp.cos(p),mp.sin(t)*mp.sin(p),mp.cos(t)]) for t,p in angles],angles


def gradient(*v):
    x,angles=coordinates(v)
    grad=[mp.matrix([0,0,0]) for _ in range(9)]
    for i in range(9):
        for j in range(i):
            d=x[i]-x[j]
            w=d/mp.norm(d)**3
            grad[i]-=w
            grad[j]+=w
    out=[]
    for i,(t,p) in enumerate(angles[1:],1):
        dt=mp.matrix([mp.cos(t)*mp.cos(p),mp.cos(t)*mp.sin(p),-mp.sin(t)])
        out.append(mp.fdot(grad[i],dt))
        if i>=2:
            dp=mp.matrix([-mp.sin(t)*mp.sin(p),mp.sin(t)*mp.cos(p),0])
            out.append(mp.fdot(grad[i],dp))
    return mp.matrix(out)


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--starts',type=int,default=8)
    ap.add_argument('--seed',type=int,default=91052026)
    ap.add_argument('--output',type=Path,default=Path(__file__).parents[1]/'results'/'high-precision.json')
    args=ap.parse_args()
    mp.mp.dps=80
    rng=np.random.default_rng(args.seed)
    results=[]
    for k in range(args.starts):
        x=rng.normal(size=(9,3))
        opt=minimize(energy_gradient,x.ravel(),jac=True,method='BFGS',options={'gtol':1e-9,'maxiter':2000})
        x=opt.x.reshape(9,3)
        x/=np.linalg.norm(x,axis=1)[:,None]
        v=mp.findroot(gradient,gauge(x),tol=mp.mpf('1e-65'),maxsteps=20)
        pts,_=coordinates(v)
        energy=sum(1/mp.norm(pts[i]-pts[j]) for i in range(9) for j in range(i))
        residual=max(abs(t) for t in gradient(*v))
        print(f'run {k+1}: E={mp.nstr(energy,55)}, gradient_inf={mp.nstr(residual,4)}',flush=True)
        results.append({'energy':str(energy),'gradient_inf':str(residual),
                        'coordinates':[[str(c) for c in p] for p in pts]})
    args.output.write_text(json.dumps({'evidence':'numerical only','seed':args.seed,'digits':80,
                                      'parameterization':'north-pole plus meridian gauge, 15 free variables',
                                      'runs':results},indent=2)+'\n')


if __name__=='__main__':
    main()
