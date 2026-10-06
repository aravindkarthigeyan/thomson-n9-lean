"""High-precision correction and rational PSD export for a near-sharp SOS.

Arb validates intermediate linear algebra; the exported certificate consists
only of rational factors. Independent integer replay checks every residual.
No SDP solver is imported or run here.
"""
import argparse
from collections import defaultdict
from fractions import Fraction as Q
import hashlib
import json
from itertools import product
from math import comb
from pathlib import Path
import sys
import time

import flint
from flint import arb, arb_mat, fmpq, fmpq_mat, fmpq_mpoly_ctx

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0,str(ROOT/'certificates'))
from polynomial import monomials, rblock, sosblocks, compress

flint.ctx.prec = 800
POLYS = fmpq_mpoly_ctx.get(('u','v','t'))


def rational(value):
    q = Q(value)
    return fmpq(q.numerator,q.denominator)


def rounding(value, digits=170):
    midpoint,_,exponent = value.mid_rad_10exp()
    q = Q(int(midpoint))*Q(10)**int(exponent)
    denominator = 10**digits
    return fmpq(round(q*denominator),denominator)


def floating(value):
    return float(value.mid())


def cholesky(matrix):
    n = matrix.nrows()
    out = arb_mat(n,n)
    for j in range(n):
        diagonal = matrix[j,j]-sum((out[j,k]*out[j,k] for k in range(j)),arb(0))
        assert diagonal > 0, f'Cholesky pivot {j} is not strictly positive: {diagonal}'
        out[j,j] = diagonal.sqrt()
        for i in range(j+1,n):
            out[i,j] = (matrix[i,j]-sum((out[i,k]*out[j,k] for k in range(j)),arb(0)))/out[j,j]
    return out


def quantize(matrix, digits):
    return fmpq_mat([[rounding(matrix[i,j],digits) for j in range(matrix.ncols())]
                     for i in range(matrix.nrows())])


def compressed(poly):
    result = defaultdict(fmpq)
    for exponent,value in poly.to_dict().items():
        result[tuple(sorted(exponent,reverse=True))] += value
    return dict(result)


def polynomial_linear_combination(basis, coefficients):
    out = defaultdict(fmpq)
    for p,coefficient in zip(basis,coefficients):
        if not coefficient:
            continue
        for exponent,value in p.items():
            out[exponent] += rational(value)*coefficient
    return POLYS.from_dict(dict(out))


def full_factor_polynomial(index,factor,degree,specs):
    if index <= degree:
        block = rblock(index,degree)
        gram = factor*factor.transpose()
        out = defaultdict(fmpq)
        for i in range(len(block)):
            for j in range(i,len(block)):
                coefficient = gram[i,j]*(1 if i == j else 2)
                for exponent,value in compress(block[i][j]).items():
                    out[exponent] += rational(value)*coefficient
        return dict(out)
    multiplier,basis = specs[index-degree-1]
    total = POLYS.constant(0)
    for j in range(factor.ncols()):
        p = polynomial_linear_combination(basis,[factor[i,j] for i in range(factor.nrows())])
        total += p*p
    g = POLYS.from_dict({e:rational(c) for e,c in multiplier.items()})
    return compressed(g*total)


def projected_column(index,i,j,projection,degree,specs,cache):
    if index <= degree:
        if ('root',index) not in cache:
            cache['root',index] = rblock(index,degree)
        block = cache['root',index]
        out = defaultdict(fmpq)
        for a in range(len(block)):
            for b in range(a,len(block)):
                coefficient = projection[a,i]*projection[b,j]
                if i != j:
                    coefficient += projection[a,j]*projection[b,i]
                if a != b:
                    coefficient *= 2
                for exponent,value in compress(block[a][b]).items():
                    out[exponent] += rational(value)*coefficient
        return dict(out)
    multiplier,basis = specs[index-degree-1]
    for col in (i,j):
        if ('basis',index,col) not in cache:
            cache['basis',index,col] = polynomial_linear_combination(
                basis,[projection[a,col] for a in range(projection.nrows())])
    if ('multiplier',index) not in cache:
        cache['multiplier',index] = POLYS.from_dict({e:rational(c) for e,c in multiplier.items()})
    p = cache['multiplier',index]*cache['basis',index,i]*cache['basis',index,j]
    if i != j:
        p *= 2
    return compressed(p)


def chebyshev_transform(rows):
    """Exact compressed monomial-to-Chebyshev coefficient transform."""
    lookup = {e:i for i,e in enumerate(rows)}
    transform = fmpq_mat(len(rows),len(rows))
    def expansion(n):
        if n == 0:
            return [(0,fmpq(1))]
        values = [(n-2*j,fmpq(comb(n,j),2**(n-1))) for j in range((n+1)//2)]
        if n%2 == 0:
            values.append((0,fmpq(comb(n,n//2),2**n)))
        return values
    for col,(a,b,c) in enumerate(rows):
        for (i,x),(j,y),(k,z) in product(expansion(a),expansion(b),expansion(c)):
            row = lookup[tuple(sorted((i,j,k),reverse=True))]
            transform[row,col] += x*y*z
    return transform


def run(basis_path,hermite_path,source_path,output,digits=170):
    started = time.time()
    bases = json.loads(basis_path.read_text())
    hermite = json.loads(hermite_path.read_text())
    source = json.loads(source_path.read_text())
    assert bases['radius_midpoint'] == hermite['radius_midpoint']
    degree = source['degree']
    assert degree == 10 and source['sos_basis'] == 'symmetry-box-v1'
    rows = sorted({tuple(sorted(e,reverse=True)) for e in monomials(2*degree)})
    row_index = {e:i for i,e in enumerate(rows)}
    selected = bases['selected_rows']
    pivots = [tuple(v) for v in bases['pivot_columns']]
    assert len(selected) == len(set(selected)) == len(pivots) == len(set(pivots)) == 356
    if 'row_exponents' in bases:
        assert list(map(tuple,bases['row_exponents'])) == rows
    projections = []
    for raw in bases['projections']:
        if raw and raw[0]:
            projections.append(fmpq_mat([[rational(v) for v in row] for row in raw]))
        else:
            projections.append(fmpq_mat(len(raw),0))
    specs = sosblocks(degree,Q(-1),Q(5593,10000),'symmetry-box-v1')
    assert len(projections) == degree+1+len(specs)
    initial,reduced,full_factors = [],[],[]
    total = defaultdict(fmpq)
    for index,N in enumerate(projections):
        m,n = N.nrows(),N.ncols()
        if n:
            matrix = arb_mat([[arb(str(v)) for v in row] for row in source['reduced_matrices'][str(index)]])
            assert matrix.nrows() == matrix.ncols() == n
            lower = quantize(cholesky(matrix),digits+15)
            B = lower*lower.transpose()
            full = N*lower
            values = full_factor_polynomial(index,full,degree,specs)
            for exponent,value in values.items():
                total[exponent] += value
            initial.append(lower)
            reduced.append(B)
            full_factors.append(full)
        else:
            initial.append(fmpq_mat(0,0))
            reduced.append(fmpq_mat(0,0))
            full_factors.append(fmpq_mat(m,0))
        print(f'Initial exact block {index+1}/{len(projections)}',flush=True)
    target = defaultdict(fmpq)
    for i,coefficient in enumerate(hermite['coefficients_monomial']):
        target[i,0,0] += rational(coefficient)
    target[0,0,0] -= rational(hermite['energy_upper'])/36
    residual = [target[e]-total[e] for e in rows]
    columns,cache = [],{}
    for number,(block,i,j) in enumerate(pivots):
        assert 0 <= i <= j < projections[block].ncols()
        polynomial = projected_column(block,i,j,projections[block],degree,specs,cache)
        columns.append([polynomial.get(e,fmpq(0)) for e in rows])
        if (number+1)%32 == 0:
            print(f'Exact correction columns {number+1}/{len(pivots)}',flush=True)
    all_columns = fmpq_mat([[column[row] for column in columns] for row in range(len(rows))])
    all_right = fmpq_mat([[value] for value in residual])
    if bases.get('row_basis','monomial') == 'chebyshev':
        transform = chebyshev_transform(rows)
        all_columns = transform*all_columns
        all_right = transform*all_right
    else:
        assert bases.get('row_basis','monomial') == 'monomial'
    scales = list(map(rational,bases.get('row_scales',['1']*len(rows))))
    assert len(scales) == len(rows) and all(value > 0 for value in scales)
    matrix = arb_mat([[arb(all_columns[row,col]*scales[row]) for col in range(356)] for row in selected])
    right = arb_mat([[arb(all_right[row,0]*scales[row])] for row in selected])
    print('Solving validated 356 by 356 Arb system',flush=True)
    delta = matrix.solve(right)
    assert delta.nrows() == 356
    rounded_delta = [rounding(delta[i,0],digits+10) for i in range(356)]
    linear_residual = []
    for row,e in enumerate(rows):
        linear_residual.append(residual[row]-sum((columns[j][row]*rounded_delta[j] for j in range(356)),fmpq(0)))
    for (block,i,j),correction in zip(pivots,rounded_delta):
        reduced[block][i,j] += correction
        if i != j:
            reduced[block][j,i] += correction
    print('Factoring corrected exact rational matrices',flush=True)
    factors,minimum_pivots = [],[]
    for index,(N,B) in enumerate(zip(projections,reduced)):
        m,n = N.nrows(),N.ncols()
        if n:
            lower = cholesky(arb_mat(B))
            minimum_pivots.append(min(floating(lower[i,i]) for i in range(n)))
            factor = quantize(arb_mat(N)*lower,digits)
            factors.append([[str(factor[i,j]) if j<n else '0' for j in range(m)] for i in range(m)])
        else:
            minimum_pivots.append(None)
            factors.append([['0']*m for _ in range(m)])
        print(f'Rational factor {index+1}/{len(projections)}',flush=True)
    record = {
        'format':'thomson-threepoint-sos-v1','n':9,'degree':degree,
        'sos_basis':'symmetry-box-v1','minimum_inner_product':'-1',
        'maximum_inner_product':'5593/10000','minorant':hermite['coefficients_monomial'],
        'raw_energy':hermite['energy_upper'],'certified_energy':str(-10**100),
        'kernel_factors':factors[:degree+1],'sos_factors':factors[degree+1:],
        'discovery':{'basis_sha256':hashlib.sha256(basis_path.read_bytes()).hexdigest(),
                     'hermite_sha256':hashlib.sha256(hermite_path.read_bytes()).hexdigest(),
                     'source_sha256':hashlib.sha256(source_path.read_bytes()).hexdigest(),
                     'factor_decimal_places':digits,'arb_precision_bits':flint.ctx.prec,
                     'selected_rows':selected,'pivot_columns':[list(v) for v in pivots],
                     'maximum_correction_diagnostic':max(abs(float(v)) for v in rounded_delta),
                     'prefactor_all_row_residual_l1':str(sum(map(abs,linear_residual),fmpq(0))),
                     'minimum_cholesky_diagonals_diagnostic':minimum_pivots,
                     'seconds':time.time()-started}}
    output.write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(record['discovery']),flush=True)
    print(f'Exported {output}; exact independent integer replay remains required',flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--bases',type=Path,default=HERE/'projected-bases.json')
    parser.add_argument('--hermite',type=Path,default=HERE/'hermite.json')
    parser.add_argument('--source',type=Path,default=ROOT/'certificates/sharp-d10-box-cvxopt-calibrated.json')
    parser.add_argument('--output',type=Path,default=HERE/'near-sharp-d10.json')
    parser.add_argument('--digits',type=int,default=170)
    args = parser.parse_args()
    run(args.bases,args.hermite,args.source,args.output,args.digits)
