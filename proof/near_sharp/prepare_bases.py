"""High-precision projected bases and numerical pivot selection for d10 SOS.

The exported bases are exact rationals. Nullspace residuals and QR selection
are discovery diagnostics; the final polynomial residual is checked elsewhere.
"""
import os
for key in ('OPENBLAS_NUM_THREADS', 'OMP_NUM_THREADS', 'MKL_NUM_THREADS'):
    os.environ[key] = '1'

import argparse
from fractions import Fraction as F
import gc
import hashlib
from itertools import combinations, permutations
import json
from math import comb
from pathlib import Path
import sys
import time

import mpmath as mp
import numpy as np
from scipy.linalg import qr

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent/'certificates'))
from polynomial import monomials, rblock, sosblocks, mul, compress


def mpr(x):
    value = F(x)
    return mp.mpf(value.numerator)/value.denominator


def gram_matrix(r):
    g = [[F(1) for _ in range(9)] for _ in range(9)]
    for i in range(9):
        for j in range(i):
            if i < 6:
                value = (1-F(3, 2)*r*r if i//3 == j//3 else
                         2*r*r-1 if i % 3 == j % 3 else r*r/2-1)
            elif j >= 6:
                value = F(-1, 2)
            else:
                value = -r if i % 3 == j % 3 else r/2
            g[i][j] = g[j][i] = value
    return g


def evaluate_fraction(poly, point):
    return sum(c*point[0]**e[0]*point[1]**e[1]*point[2]**e[2]
               for e, c in poly.items())


def evaluate_mp(poly, powers):
    return sum(mpr(c)*powers[0][e[0]]*powers[1][e[1]]*powers[2][e[2]]
               for e, c in poly.items())


def make_projections(source, radius, places):
    degree = source['degree']
    specs = sosblocks(degree, F(-1), F(source['maximum_inner_product']), source['sos_basis'])
    orbit = json.loads((HERE.parent/'sdp/orbit-kernel-polynomials.json').read_text())
    g = gram_matrix(radius)
    triples = sorted({p for i, j, k in combinations(range(9), 3)
                      for p in permutations((g[i][j], g[i][k], g[j][k]))})
    rm = mpr(radius)
    constraints = []
    for k in range(degree+1):
        block = orbit['blocks'][k]
        rows = []
        for key in ('prism_vector', 'cap_vector'):
            if block[key] is not None:
                rows.append([mp.polyval([mpr(c) for c in reversed(p)], rm)
                             for p in block[key][:degree-k+1]])
        constraints.append(mp.matrix(rows))
    for multiplier, basis in specs:
        rows = []
        for point in triples:
            if evaluate_fraction(multiplier, point) > 0:
                powers = [[mpr(x)**j for j in range(2*degree+1)] for x in point]
                rows.append([evaluate_mp(poly, powers) for poly in basis])
        constraints.append(mp.matrix(rows))
    denominator = 10**places
    projected, diagnostics = [], []
    for index, (raw, v) in enumerate(zip(source['projections'], constraints)):
        saved = np.asarray(raw, float)
        size, dimension = saved.shape
        rank = size-dimension
        vf = np.array(v.tolist(), dtype=float)
        _, _, row_pivots = qr(vf.T, mode='economic', pivoting=True)
        selected_rows = row_pivots[:rank]
        _, _, column_pivots = qr(vf[selected_rows], mode='economic', pivoting=True)
        selected_columns = column_pivots[:rank]
        free = [i for i in range(size) if i not in selected_columns]
        n = mp.matrix([[mp.mpf(str(x)) for x in row] for row in raw])
        if dimension and rank:
            pivot = mp.matrix([[v[int(i), int(j)] for j in selected_columns] for i in selected_rows])
            right = mp.matrix([[sum(v[int(i), j]*n[j, k] for j in free)
                                for k in range(dimension)] for i in selected_rows])
            solved = -(pivot**-1)*right
            for i, j in enumerate(selected_columns):
                for k in range(dimension):
                    n[int(j), k] = solved[i, k]
        rational = [[F(int(mp.nint(n[i, j]*denominator)), denominator)
                     for j in range(dimension)] for i in range(size)]
        rounded = mp.matrix([[mpr(x) for x in row] for row in rational])
        residual = v*rounded if dimension else mp.matrix(v.rows, 0)
        maximum = max([abs(x) for x in residual]+[mp.mpf(0)])
        change = max([abs(rounded[i, j]-mp.mpf(str(raw[i][j])))
                      for i in range(size) for j in range(dimension)]+[mp.mpf(0)])
        if maximum > mp.mpf('1e-170'):
            raise ValueError(f'Block {index} all-row residual {maximum} exceeds threshold')
        projected.append([[str(x) for x in row] for row in rational])
        diagnostics.append({'block': index, 'constraint_rows': v.rows, 'rank': rank,
                            'selected_constraint_rows': selected_rows.tolist(),
                            'selected_constraint_columns': selected_columns.tolist(),
                            'maximum_all_row_residual': mp.nstr(maximum, 30),
                            'maximum_change_from_saved': mp.nstr(change, 30)})
        print(json.dumps(diagnostics[-1]), flush=True)
    return projected, diagnostics


def chebyshev_transform(rows):
    def expansion(n):
        if n == 0:
            return [(0, F(1))]
        values = [(n-2*j, F(comb(n, j), 2**(n-1))) for j in range((n+1)//2)]
        if n % 2 == 0:
            values.append((0, F(comb(n, n//2), 2**n)))
        return values
    transform = np.zeros((len(rows), len(rows)))
    for exponent, column in rows.items():
        for i, a in expansion(exponent[0]):
            for j, b in expansion(exponent[1]):
                for k, c in expansion(exponent[2]):
                    transform[rows[tuple(sorted((i, j, k), reverse=True))], column] += float(a*b*c)
    return transform


def numeric_columns(source, projections):
    degree = source['degree']
    exponents = sorted({tuple(sorted(e, reverse=True)) for e in monomials(2*degree)})
    rows = {e: i for i, e in enumerate(exponents)}
    transform = chebyshev_transform(rows)
    specs = sosblocks(degree, F(-1), F(source['maximum_inner_product']), source['sos_basis'])
    columns, labels = [], []
    for block, rational in enumerate(projections):
        n = np.array([[float(F(x)) for x in row] for row in rational])
        size, dimension = n.shape
        if dimension == 0:
            continue
        tensor = np.zeros((len(rows), size, size))
        if block <= degree:
            polynomials = rblock(block, degree)
            for i in range(size):
                for j in range(size):
                    for e, value in compress(polynomials[i][j]).items():
                        tensor[rows[e], i, j] = float(value)
            del polynomials
        else:
            multiplier, basis = specs[block-degree-1]
            for i in range(size):
                for j in range(i, size):
                    coefficients = compress(mul(mul(basis[i], basis[j]), multiplier))
                    for e, value in coefficients.items():
                        tensor[rows[e], i, j] = tensor[rows[e], j, i] = float(value)
        intermediate = np.einsum('rij,jb->rib', tensor, n, optimize=True)
        projected = np.einsum('ia,rib->rab', n, intermediate, optimize=True)
        ii, jj = np.triu_indices(dimension)
        unique = projected[:, ii, jj]*(np.where(ii == jj, 1., 2.)[None, :])
        columns.append(transform@unique)
        labels.extend([(block, int(i), int(j)) for i, j in zip(ii, jj)])
        del tensor, intermediate, projected, unique
        gc.collect()
        print(f'Coefficient block {block}: {dimension*(dimension+1)//2} symmetric columns', flush=True)
    return np.hstack(columns), labels, exponents, transform


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--source', type=Path, default=HERE.parent/'certificates/sharp-d10-box-cvxopt-calibrated.json')
    ap.add_argument('--radius', type=Path, default=HERE/'radius-proposal.json')
    ap.add_argument('--output', type=Path, default=HERE/'projected-bases.json')
    ap.add_argument('--reuse-bases', action='store_true')
    ap.add_argument('--projections-only', action='store_true')
    ap.add_argument('--places', type=int, default=190)
    args = ap.parse_args()
    start = time.time()
    mp.mp.dps = args.places+80
    source_raw = args.source.read_bytes()
    source = json.loads(source_raw)
    radius = F(json.loads(args.radius.read_text())['radius_midpoint'])
    if args.reuse_bases:
        record = json.loads(args.output.read_text())
        assert F(record['radius_midpoint']) == radius
        assert record['source_sha256'] == hashlib.sha256(source_raw).hexdigest()
    else:
        projections, diagnostics = make_projections(source, radius, args.places)
        record = {'status': 'RATIONAL BASES WITH HIGH-PRECISION DISCOVERY DIAGNOSTICS; NOT A CERTIFICATE',
                  'source_sha256': hashlib.sha256(source_raw).hexdigest(),
                  'degree': source['degree'], 'sos_basis': source['sos_basis'],
                  'maximum_inner_product': source['maximum_inner_product'],
                  'radius_midpoint': str(radius), 'rounding_denominator': str(10**args.places),
                  'arithmetic_decimal_digits': mp.mp.dps,
                  'projections': projections, 'projection_diagnostics': diagnostics}
        args.output.write_text(json.dumps(record, indent=2)+'\n')
        print('Saved rational projections: '+str(args.output), flush=True)
    if args.projections_only:
        return
    combined, labels, exponents, transform = numeric_columns(source, record['projections'])
    scales = 1/np.maximum(np.linalg.norm(combined, axis=1), 1e-12)
    scaled = combined*scales[:, None]
    _, triangular, row_pivots = qr(scaled.T, mode='economic', pivoting=True)
    diagonal = np.abs(np.diag(triangular))
    rank = int(np.sum(diagonal > 1e-9*diagonal[0]))
    assert rank == 356, (rank, diagonal[-5:])
    selected = row_pivots[:rank]
    del triangular
    _, _, column_pivots = qr(scaled[selected], mode='economic', pivoting=True)
    pivots = column_pivots[:rank]
    square = scaled[selected][:, pivots]
    hermite = json.loads((HERE/'hermite.json').read_text())
    target = np.zeros(len(exponents))
    row_index = {e: i for i, e in enumerate(exponents)}
    for j, coefficient in enumerate(hermite['coefficients_monomial']):
        target[row_index[(j, 0, 0)]] = float(F(coefficient))
    target[row_index[(0, 0, 0)]] -= float(F(hermite['energy_upper']))/36
    target = transform@target
    initial = np.array([source['reduced_matrices'][str(block)][i][j] for block, i, j in labels])
    residual = target-combined@initial
    correction = np.linalg.solve(square, scales[selected]*residual[selected])
    corrected = initial.copy()
    corrected[pivots] += correction
    final_residual = target-combined@corrected
    minimum_eigenvalue = float('inf')
    for block, raw in source['reduced_matrices'].items():
        matrix = np.array(raw)
        for column in pivots:
            b, i, j = labels[column]
            if b == int(block):
                matrix[i, j] = matrix[j, i] = corrected[column]
        minimum_eigenvalue = min(minimum_eigenvalue, float(np.linalg.eigvalsh(matrix)[0]))
    record.update({'row_basis': 'chebyshev', 'row_exponents': [list(e) for e in exponents],
                   'row_scales': [str(F(str(x))) for x in scales],
                   'selected_rows': selected.tolist(),
                   'pivot_columns': [list(labels[i]) for i in pivots],
                   'column_convention': 'i<=j; diagonal A_ii, offdiagonal A_ij+A_ji; reduced symmetric entry is one scalar',
                   'numerical_rank': rank, 'symmetric_column_count': len(labels),
                   'numeric_selected_condition': float(np.linalg.cond(square)),
                   'numeric_original_max_scaled_residual': float(max(abs(scales*residual))),
                   'numeric_corrected_max_scaled_residual': float(max(abs(scales*final_residual))),
                   'numeric_correction_maximum': float(max(abs(correction))),
                   'numeric_corrected_minimum_eigenvalue': minimum_eigenvalue,
                   'seconds': time.time()-start})
    args.output.write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps({k: v for k, v in record.items()
                      if k.startswith('numeric') or k in ('symmetric_column_count', 'seconds')}, indent=2), flush=True)


if __name__ == '__main__':
    main()
