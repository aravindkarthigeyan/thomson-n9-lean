"""Small exact polynomial kernel for independently reproducible certificates."""
from fractions import Fraction as F
from itertools import permutations
from math import comb

ZERO=(0,0,0)
ONE={ZERO:F(1)}
U={(1,0,0):F(1)}
V={(0,1,0):F(1)}
T={(0,0,1):F(1)}


def add(*ps):
    r={}
    for p in ps:
        for e,c in p.items():
            r[e]=r.get(e,0)+c
    return {e:c for e,c in r.items() if c}


def scale(p,c):
    return {e:v*c for e,v in p.items() if v*c}


def mul(p,q):
    r={}
    for e,c in p.items():
        for f,d in q.items():
            g=tuple(x+y for x,y in zip(e,f))
            r[g]=r.get(g,0)+c*d
    return {e:c for e,c in r.items() if c}


def sym(p):
    return add(*[{tuple(e[k] for k in perm):c/F(6) for e,c in p.items()}
                 for perm in permutations(range(3))])


def monomials(d):
    return [(i,j,k) for i in range(d+1) for j in range(d+1-i) for k in range(d+1-i-j)]


def compress(p):
    r={}
    for e,c in p.items():
        s=tuple(sorted(e,reverse=True))
        r[s]=r.get(s,0)+c
    return {e:c for e,c in r.items() if c}


def qkernels(d):
    q=[ONE,add(T,scale(mul(U,V),-1))]
    w=mul(add(ONE,scale(mul(U,U),-1)),add(ONE,scale(mul(V,V),-1)))
    for k in range(d-1):
        q.append(add(scale(mul(q[1],q[-1]),2),scale(mul(w,q[-2]),-1)))
    return q[:d+1]


def rblock(k,d,n=9):
    q=qkernels(d)[k]
    out=[]
    for i in range(d-k+1):
        row=[]
        for j in range(d-k+1):
            s=sym(mul({(i,j,0):F(1)},q))
            boundary={}
            for (a,b,c),v in s.items():
                boundary=add(boundary,{(a+b,0,0):v,(0,a+b,0):v,(0,0,a+b):v}) if a+b else add(boundary,{ZERO:3*v})
            # The three entries above coincide at exponent zero, handled separately.
            row.append(add(scale(s,n-2),boundary,{ZERO:sum(s.values())/F(n-1)}))
        out.append(row)
    return out


GRAM=add(ONE,{(1,1,1):F(2),(2,0,0):F(-1),(0,2,0):F(-1),(0,0,2):F(-1)})
DETERMINANT_MOMENT=add(scale(ONE,F(9,28)),scale(GRAM,-1))


def invariant_bases(d,full_group):
    exponents=monomials(d)
    if full_group:
        representatives=sorted({tuple(sorted(e,reverse=True)) for e in exponents})
        even=[{p:F(1) for p in set(permutations(e))} for e in representatives]
    else:
        even=[]
        for e in exponents:
            f=(e[0],e[2],e[1])
            if e<f:
                even.append({e:F(1),f:F(1)})
            elif e==f:
                even.append({e:F(1)})
    odd=[{e:F(1),(e[0],e[2],e[1]):F(-1)} for e in exponents if e<(e[0],e[2],e[1])]
    return even,odd


def sosblocks(d,lower=F(-1),upper=F(1),mode='monomial'):
    specs=[(ONE,d,True),(add(U,scale(ONE,-lower)),d-1,False),
           (add(scale(ONE,upper),scale(U,-1)),d-1,False),(GRAM,d-2,True)]
    if mode=='monomial':
        return [(g,monomials(q)) for g,q,_ in specs]
    assert mode in {'symmetry-v1','symmetry-box-v1'}
    if mode=='symmetry-box-v1':
        box=mul(add(U,scale(ONE,-lower)),add(scale(ONE,upper),scale(U,-1)))
        specs.extend([(box,d-1,False)])
        if d>=3:
            specs.append((mul(GRAM,box),d-3,False))
    return [(g,b) for g,q,full in specs for b in invariant_bases(q,full) if b]


def sosblock(g,basis):
    polys=[e if isinstance(e,dict) else {e:F(1)} for e in basis]
    return [[sym(mul(mul(e,f),g)) for f in polys] for e in polys]


def weighted_block(block,matrix):
    out={}
    for i,row in enumerate(block):
        for j,p in enumerate(row):
            out=add(out,scale(p,matrix[i][j]))
    return out


def gram_factor(b):
    return [[sum(x*y for x,y in zip(row,col)) for col in b] for row in b]


def hermite_y_polynomial(h):
    # 1-2y H(1-2y^2), nonnegative implies H(t)<=1/sqrt(2-2t).
    p=[F(0)]*(2*len(h))
    p[0]=F(1)
    for j,c in enumerate(h):
        for k in range(j+1):
            p[2*k+1]-=2*c*comb(j,k)*(-2)**k
    return p


def bernstein_coefficients(p):
    n=len(p)-1
    return [sum(p[i]*F(comb(k,i),comb(n,i)) for i in range(k+1)) for k in range(n+1)]


def bernstein_split(b):
    rows=[b]
    for _ in range(len(b)-1):
        rows.append([(x+y)/2 for x,y in zip(rows[-1],rows[-1][1:])])
    return [r[0] for r in rows],[r[-1] for r in rows[::-1]]


def check_minorant(h,max_depth=24,y_upper=F(1)):
    assert 0<y_upper<=1
    p=hermite_y_polynomial(h)
    p=[c*y_upper**j for j,c in enumerate(p)]
    pending=[(bernstein_coefficients(p),0)]
    leaves=0
    while pending:
        b,depth=pending.pop()
        if min(b)>=0:
            leaves+=1
            continue
        assert b[0]>=0 and b[-1]>=0, 'minorant fails at dyadic point'
        assert depth<max_depth, 'minorant positivity not certified before depth limit'
        left,right=bernstein_split(b)
        pending.extend([(left,depth+1),(right,depth+1)])
    return leaves
