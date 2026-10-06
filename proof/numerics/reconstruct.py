"""Independent random optimization, D3h reconstruction, and Hessian diagnostics.

All results here are numerical evidence, not global or local certificates.
"""
import argparse
import json
from pathlib import Path

import mpmath as mp
import numpy as np
from scipy.linalg import null_space
from scipy.optimize import minimize
from scipy.spatial import ConvexHull


def energy_gradient(raw):
    y = np.asarray(raw).reshape(9, 3)
    lengths = np.linalg.norm(y, axis=1)
    x = y / lengths[:, None]
    d = x[:, None, :] - x[None, :, :]
    d2 = np.sum(d * d, axis=2)
    np.fill_diagonal(d2, np.inf)
    energy = 0.5 * np.sum(d2 ** -0.5)
    g = -np.sum(d * (d2 ** -1.5)[:, :, None], axis=1)
    g -= np.sum(g * x, axis=1)[:, None] * x
    return energy, (g / lengths[:, None]).ravel()


def family(r, backend=np):
    sqrt = backend.sqrt
    z = sqrt(1 - r * r)
    e = [(1, 0), (-backend.mpf(1)/2 if backend is mp else -0.5, sqrt(3)/2),
         (-backend.mpf(1)/2 if backend is mp else -0.5, -sqrt(3)/2)]
    return [[r*a, r*b, h] for h in (z, -z) for a,b in e] + [[-a,-b,0] for a,b in e]


def family_energy(r):
    return (2*mp.sqrt(3)/r + 3/(2*mp.sqrt(1-r*r)) + 6/mp.sqrt(4-r*r)
            + mp.sqrt(3) + 6/mp.sqrt(2+2*r) + 12/mp.sqrt(2-r))


def tangent_basis(x):
    basis = np.zeros((27, 18))
    for i, p in enumerate(x):
        basis[3*i:3*i+3, 2*i:2*i+2] = null_space(p[None, :])
    return basis


def hessian(x):
    h = np.zeros((27,27))
    grad = np.zeros((9,3))
    for i in range(9):
        for j in range(i):
            d = x[i]-x[j]
            q = d@d
            b = 3*np.outer(d,d)*q**-2.5-np.eye(3)*q**-1.5
            si, sj = slice(3*i,3*i+3), slice(3*j,3*j+3)
            h[si,si] += b
            h[sj,sj] += b
            h[si,sj] -= b
            h[sj,si] -= b
            grad[i] -= d*q**-1.5
            grad[j] += d*q**-1.5
    for i in range(9):
        h[3*i:3*i+3,3*i:3*i+3] -= np.eye(3)*(grad[i]@x[i])
    t = tangent_basis(x)
    return t.T@h@t, t


def spectrum(x):
    values = np.sort((x@x.T)[np.triu_indices(9,1)])
    groups = []
    for v in values:
        if groups and abs(v-groups[-1][0]) < 1e-6:
            groups[-1][1] += 1
        else:
            groups.append([float(v),1])
    return groups


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--starts', type=int, default=256)
    ap.add_argument('--seed', type=int, default=20261005)
    ap.add_argument('--output', type=Path, default=Path(__file__).parents[1]/'results'/'candidate.json')
    args = ap.parse_args()
    rng = np.random.default_rng(args.seed)
    trials = []
    best = None
    for k in range(args.starts):
        raw = rng.normal(size=(9,3))
        raw /= np.linalg.norm(raw,axis=1)[:,None]
        result = minimize(energy_gradient, raw.ravel(), jac=True, method='BFGS',
                          options={'gtol':2e-10,'maxiter':1500})
        x = result.x.reshape(9,3)
        x /= np.linalg.norm(x,axis=1)[:,None]
        trials.append({'energy':float(result.fun),'gradient_inf':float(np.max(np.abs(result.jac))),
                       'iterations':int(result.nit),'solver_success':bool(result.success)})
        if best is None or result.fun < best[0]:
            best = (float(result.fun),x.copy())
        if (k+1)%32 == 0:
            print(f'{k+1}/{args.starts}: best {best[0]:.14f}',flush=True)

    x = best[1]
    # Discover the symmetry axis as a simple covariance eigenvector.
    cov_values, cov_vectors = np.linalg.eigh(x.T@x)
    candidates = [(np.max(np.abs(np.sort(x@cov_vectors[:,k])[[3,4,5]])),k) for k in range(3)]
    axis = cov_vectors[:,min(candidates)[1]]
    heights = np.sort(x@axis)
    r_guess = np.sqrt(1-np.mean(heights[-3:])**2)
    mp.mp.dps = 100
    r = mp.findroot(lambda t:mp.diff(family_energy,t), (mp.mpf(str(r_guess))-mp.mpf('.01'),
                                                        mp.mpf(str(r_guess))+mp.mpf('.01')))
    pmp = family(r,mp)
    p = np.array(pmp,dtype=float)
    direct_energy = sum(1/mp.sqrt(sum((pmp[i][k]-pmp[j][k])**2 for k in range(3)))
                        for i in range(9) for j in range(i))
    h,t = hessian(p)
    rotations = np.column_stack([np.cross(np.broadcast_to(a,p.shape),p).ravel() for a in np.eye(3)])
    rot_tangent = t.T@rotations
    quotient = null_space(rot_tangent.T)
    hull = ConvexHull(p)
    edges = sorted({tuple(sorted((int(f[i]),int(f[(i+1)%3])))) for f in hull.simplices for i in range(3)})
    degrees = [sum(i in e for e in edges) for i in range(9)]
    symmetry_residual = float(np.max(np.abs(np.sort((x@x.T)[np.triu_indices(9,1)])-
                                            np.sort((p@p.T)[np.triu_indices(9,1)]))))
    perturbation_tests = []
    for eps in (1e-2,1e-3,1e-4):
        deltas = []
        for _ in range(300):
            v = rng.normal(size=15)
            v /= np.linalg.norm(v)
            y = p+eps*(t@quotient@v).reshape(9,3)
            deltas.append(float(energy_gradient(y.ravel())[0]-float(direct_energy)))
        perturbation_tests.append({'radius':eps,'minimum_energy_increase':min(deltas)})
    out = {'evidence':'numerical only','seed':args.seed,'starts':args.starts,
           'best_random_energy':best[0],'random_best_coordinates':x.tolist(),
           'random_trials':trials,'covariance_eigenvalues':cov_values.tolist(),
           'discovered_heights':heights.tolist(),'r':str(r),'z':str(mp.sqrt(1-r*r)),
           'energy':str(direct_energy),'energy_formula_residual':str(direct_energy-family_energy(r)),
           'family_derivative':str(mp.diff(family_energy,r)),
           'family_second_derivative':str(mp.diff(family_energy,r,2)),
           'coordinates':[[str(y) for y in row] for row in pmp],
           'pair_spectrum':spectrum(p),'random_spectrum_residual':symmetry_residual,
           'hessian_eigenvalues':np.linalg.eigvalsh(h).tolist(),
           'quotient_eigenvalues':np.linalg.eigvalsh(quotient.T@h@quotient).tolist(),
           'rotation_null_residual':float(np.max(np.abs(h@rot_tangent))),
           'hull_faces':hull.simplices.tolist(),'hull_edges':edges,'hull_degrees':degrees,
           'perturbations':perturbation_tests}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:out[k] for k in ['r','z','energy','pair_spectrum','quotient_eigenvalues',
                                      'hull_degrees','random_spectrum_residual']},indent=2))


if __name__ == '__main__':
    main()
