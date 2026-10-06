"""Independent Fraction crosschecks of projected FLINT coefficient columns."""
from fractions import Fraction as Q
import json

from flint import fmpq, fmpq_mat
import correct_matrices as correction
from polynomial import add, mul, scale, sym, compress, rblock, sosblocks


def main():
    degree = 10
    specs = sosblocks(degree,Q(-1),Q(5593,10000),'symmetry-box-v1')
    checked = 0
    for index in range(degree+1+len(specs)):
        size = degree-index+1 if index <= degree else len(specs[index-degree-1][1])
        N = fmpq_mat(size,2)
        for i in range(min(3,size)):
            N[i,0],N[i,1] = fmpq(i+1,7),fmpq((-1)**i,11)
        if index <= degree:
            block = rblock(index,degree)
        else:
            multiplier,basis = specs[index-degree-1]
            block = [[sym(mul(mul(p,q),multiplier)) for q in basis[:3]] for p in basis[:3]]
        for left,right in ((0,0),(0,1),(1,1)):
            expected = {}
            for i in range(min(3,size)):
                for j in range(min(3,size)):
                    weight = Q(str(N[i,left]))*Q(str(N[j,right]))
                    if left != right:
                        weight += Q(str(N[i,right]))*Q(str(N[j,left]))
                    expected = add(expected,scale(block[i][j],weight))
            got = correction.projected_column(index,left,right,N,degree,specs,{})
            got = {e:Q(str(c)) for e,c in got.items() if c}
            assert got == compress(expected), (index,left,right)
            checked += 1
    report = {'passed':True,'independent_fraction_columns_checked':checked,
              'includes_diagonal_and_offdiagonal_multiplicity':True}
    (correction.HERE/'coefficient-crosscheck.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
