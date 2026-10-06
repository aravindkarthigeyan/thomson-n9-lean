"""Numerical N9 three-point SDP discovery with adversarial cutting planes.

The mathematical lambda-form follows the Apache-2.0 declaration in the README
of jstoobysmith/Thomson-N-8-Warrant, commit 2c35d62e07d72686931da4bc3e062d668e858eda.
This implementation is independent and vectorized, with N-dependent counting.
Output is discovery evidence only: finite sampling proves no global inequality.
"""
from __future__ import annotations

import argparse
import itertools
import json
import os
from pathlib import Path
import time

os.environ['OPENBLAS_NUM_THREADS'] = '1'
os.environ['OMP_NUM_THREADS'] = '1'
os.environ['MKL_NUM_THREADS'] = '1'

import cvxpy as cp
import numpy as np
from numpy.polynomial.legendre import legvander
from scipy.optimize import minimize, minimize_scalar

HERE = Path(__file__).resolve().parent
N = 9
COUNT = 3 * (N - 2)
PERMS = list(itertools.permutations(range(3)))
BASIS = 'monomial'


def potential(t):
    return 1 / np.sqrt(2 - 2 * np.asarray(t))


def kernels(triples, d):
    """Batch symmetrized polynomial spherical kernels, no square-root divisions."""
    tri = np.asarray(triples).reshape(-1, 3)
    dtype = np.result_type(tri.dtype, float)
    tri = tri.astype(dtype)
    result = [np.zeros((len(tri), d-k+1, d-k+1), dtype=dtype)
              for k in range(d+1)]
    for perm in PERMS:
        u, v, t = tri[:, perm].T
        qprev = np.ones(len(tri))
        q = t-u*v
        determinant_factor = (1-u*u)*(1-v*v)
        for k in range(d+1):
            qk = qprev if k == 0 else q
            m = d-k+1
            if BASIS == 'legendre':
                upow, vpow = legvander(u, m-1), legvander(v, m-1)
            else:
                upow = u[:, None] ** np.arange(m)
                vpow = v[:, None] ** np.arange(m)
            result[k] += qk[:, None, None]*upow[:, :, None]*vpow[:, None, :]/6
            if k >= 1:
                qprev, q = q, 2*(t-u*v)*q-determinant_factor*qprev
    return result


def gram(tri):
    u, v, t = np.asarray(tri).T
    return 1+2*u*v*t-u*u-v*v-t*t


def unique_rows(rows):
    return np.unique(np.round(np.sort(np.asarray(rows).reshape(-1, 3), axis=1), 14), axis=0)


def candidate():
    data = json.loads((HERE.parent/'results/candidate.json').read_text())
    points = np.asarray(data['coordinates'], float)
    dots = points@points.T
    pairs = np.unique(np.round(dots[np.triu_indices(N, 1)], 14))
    triangles = unique_rows([[dots[i, j], dots[i, k], dots[j, k]]
                            for i, j, k in itertools.combinations(range(N), 3)])
    return float(data['energy']), pairs, triangles


def triangle_samples(lo, hi, ngrid, nrandom, rng):
    grid = np.linspace(lo, hi, ngrid)
    tri = np.array(list(itertools.combinations_with_replacement(grid, 3)))
    tri = tri[gram(tri) >= -1e-12]
    u = rng.uniform(lo, hi, nrandom)
    v = rng.uniform(lo, hi, nrandom)
    root = np.sqrt(np.maximum(0, (1-u*u)*(1-v*v)))
    lower = np.maximum(lo, u*v-root)
    upper = np.minimum(hi, u*v+root)
    valid = lower <= upper
    u, v, lower, upper = u[valid], v[valid], lower[valid], upper[valid]
    random_tri = np.column_stack([u, v, rng.uniform(lower, upper)])
    # Include the rank-two Gram boundary, where a rectangular grid undersamples.
    boundary = np.vstack([np.column_stack([u, v, lower]),
                          np.column_stack([u, v, upper])])
    return unique_rows(np.vstack([tri, random_tri, boundary]))


def linear_expression(tensors, matrices):
    return sum(t.reshape(len(t), -1) @ cp.reshape(f, (f.shape[0]**2,), order='C')
               for t, f in zip(tensors, matrices))


def evaluate_F(tri, matrices, d):
    result = np.zeros(len(np.asarray(tri).reshape(-1, 3)))
    for tensor, matrix in zip(kernels(tri, d), matrices):
        result += np.einsum('nij,ij->n', tensor, matrix)
    return result


def adversary(a, matrices, lam, d, lo, hi, rng, samples):
    def pair_slack(t):
        ts = np.atleast_1d(t)
        f = evaluate_F(np.column_stack([np.ones(len(ts)), ts, ts]), matrices, d)
        return (1-COUNT*lam)*potential(ts)-legvander(ts, len(a)-1)@a-3*f

    def tri_slack(tri):
        tri = np.asarray(tri).reshape(-1, 3)
        return lam*np.sum(potential(tri), axis=1)-evaluate_F(tri, matrices, d)

    pair_grid = np.linspace(lo, hi, samples)
    pair_scores = pair_slack(pair_grid)
    minima = np.where((pair_scores[1:-1] <= pair_scores[:-2]) &
                      (pair_scores[1:-1] <= pair_scores[2:]))[0]+1
    pair_cuts = [float(lo), float(hi)]
    for index in minima[np.argsort(pair_scores[minima])[:16]]:
        fit = minimize_scalar(lambda t: float(pair_slack(t)[0]),
                              bounds=(pair_grid[index-1], pair_grid[index+1]),
                              method='bounded', options={'xatol': 1e-13})
        pair_cuts.append(float(fit.x))
    pair_cuts = np.array(pair_cuts)
    pair_cut_scores = pair_slack(pair_cuts)
    tri_grid = triangle_samples(lo, hi, 23, samples//3, rng)
    tri_scores = tri_slack(tri_grid)
    worst_indices = np.argsort(tri_scores)[:24]
    optimized = []
    for index in worst_indices[:8]:
        fit = minimize(lambda x: float(tri_slack(x)[0]), tri_grid[index],
                       method='SLSQP', bounds=[(lo, hi)]*3,
                       constraints=[{'type': 'ineq', 'fun': lambda x: float(gram(x))}],
                       options={'ftol': 1e-12, 'maxiter': 100})
        if np.isfinite(fit.fun) and gram(fit.x) >= -1e-9:
            optimized.append(fit.x)
    tri_cuts = unique_rows(np.vstack([tri_grid[worst_indices], optimized])
                          if optimized else tri_grid[worst_indices])
    tri_cut_scores = tri_slack(tri_cuts)
    return {
        'pair_minimum': float(np.min(pair_cut_scores)),
        'pair_argmin': float(pair_cuts[np.argmin(pair_cut_scores)]),
        'triangle_minimum': float(np.min(tri_cut_scores)),
        'triangle_argmin': tri_cuts[np.argmin(tri_cut_scores)].tolist(),
        'triangle_samples': len(tri_grid),
        'pair_samples': len(pair_grid),
    }, pair_cuts[pair_cut_scores < -1e-9], tri_cuts[tri_cut_scores < -1e-9]


def solve(d, D, lo, hi, rounds, tag, seed, samples, uncapped_lambda=False):
    started = time.time()
    rng = np.random.default_rng(seed)
    target, contacts, touches = candidate()
    contacts = contacts[(contacts >= lo) & (contacts <= hi)]
    touches = touches[np.all((touches >= lo) & (touches <= hi), axis=1)]
    pair_grid = np.unique(np.concatenate([np.linspace(lo, hi, 321), contacts,
                                          1-2.**(-np.arange(2, 23))]))
    pair_grid = pair_grid[(pair_grid >= lo) & (pair_grid <= hi)]
    triangles = unique_rows(np.vstack([triangle_samples(lo, hi, 15, 350, rng), touches]))
    a = cp.Variable(D+1)
    Fs = [cp.Variable((d-k+1, d-k+1), PSD=True) for k in range(d+1)]
    lam = cp.Variable()
    F111 = linear_expression(kernels([[1, 1, 1]], d), Fs)[0]
    bound = (N*N*a[0]-N*cp.sum(a)-N*F111)/2
    constraints = [a[1:] >= 0, lam >= 0]
    if not uncapped_lambda:
        constraints.append(lam <= 1/COUNT)
    history = []
    record = {'status': 'NUMERICAL DISCOVERY ONLY; NOT A CERTIFICATE', 'N': N,
              'd': d, 'D': D, 'domain': [lo, hi], 'target': target, 'kernel_basis': BASIS,
              'seed': seed, 'counting_factor': COUNT, 'history': history,
              'lambda_upper_cap': None if uncapped_lambda else 1/COUNT,
              'candidate_contacts_in_domain': contacts.tolist(),
              'candidate_triangle_types_in_domain': touches.tolist(),
              'limitations': ['Finite sampling never proves universal inequalities.',
                              'The endpoint 1 is singular and excluded from sampling.',
                              'A cut-domain bound is conditional on every pair >= its lower endpoint.',
                              'PSD and all residuals here use floating point.']}
    out = HERE/(tag+'.json')
    for iteration in range(rounds):
        if len(pair_grid):
            ptri = np.column_stack([np.ones(len(pair_grid)), pair_grid, pair_grid])
            constraints += [legvander(pair_grid, D)@a+3*linear_expression(kernels(ptri, d), Fs)
                            <= (1-COUNT*lam)*potential(pair_grid)]
        if len(triangles):
            constraints += [linear_expression(kernels(triangles, d), Fs)
                            <= lam*np.sum(potential(triangles), axis=1)]
        problem = cp.Problem(cp.Maximize(bound), constraints)
        iter_start = time.time()
        try:
            problem.solve(solver=cp.CLARABEL, tol_gap_abs=2e-9, tol_gap_rel=2e-9,
                          tol_feas=2e-9, max_iter=150, max_threads=1)
        except Exception as exc:
            record['solver_error'] = repr(exc)
            break
        if a.value is None:
            record['solver_status'] = problem.status
            break
        matrices = [f.value for f in Fs]
        attack, pair_grid, triangles = adversary(a.value, matrices, float(lam.value),
                                                 d, lo, hi, rng, samples)
        entry = {'iteration': iteration, 'solver_status': problem.status,
                 'sample_objective': float(problem.value),
                 'gap_to_candidate': target-float(problem.value),
                 'lambda': float(lam.value), 'new_pair_cuts': len(pair_grid),
                 'new_triangle_cuts': len(triangles),
                 'solver_seconds': time.time()-iter_start, **attack}
        history.append(entry)
        record.update({'coefficients_legendre': a.value.tolist(),
                       'PSD_matrices': [m.tolist() for m in matrices],
                       'lambda': float(lam.value), 'sample_objective': float(problem.value),
                       'minimum_PSD_eigenvalue': min(float(np.linalg.eigvalsh(m).min()) for m in matrices),
                       'elapsed_seconds': time.time()-started})
        out.write_text(json.dumps(record, indent=2)+'\n')
        print(json.dumps({'tag': tag, **entry}), flush=True)
        if not len(pair_grid) and not len(triangles):
            break
    record['elapsed_seconds'] = time.time()-started
    out.write_text(json.dumps(record, indent=2)+'\n')
    return record


def main():
    global BASIS
    parser = argparse.ArgumentParser()
    parser.add_argument('--d', type=int, default=4)
    parser.add_argument('--D', type=int, default=12)
    parser.add_argument('--lo', type=float, default=-1)
    parser.add_argument('--hi', type=float, default=1-2**-22)
    parser.add_argument('--rounds', type=int, default=6)
    parser.add_argument('--samples', type=int, default=12001)
    parser.add_argument('--seed', type=int, default=20261005)
    parser.add_argument('--basis', choices=['monomial', 'legendre'], default='monomial')
    parser.add_argument('--uncapped-lambda', action='store_true')
    parser.add_argument('--tag', default='lambda_d4_full')
    args = parser.parse_args()
    BASIS = args.basis
    solve(args.d, args.D, args.lo, args.hi, args.rounds, args.tag, args.seed, args.samples,
          args.uncapped_lambda)


if __name__ == '__main__':
    main()
