# No Sharp Finite-Degree Ordinary Two-Point LP Certificate

This is a mathematical obstruction to one specific proof method. It does not prove the N=9 optimum, and it does not rule out three-point SDP, typed/rooted bounds, domain partitions, Gram-rank constraints, or arbitrarily accurate nonsharp LP sequences.

A later independent argument in `ORDINARY_LP_CEILING.md` strengthens the conclusion: an exact dual pair measure gives a uniform ceiling of 25.729492377 on all ordinary finite-degree LP bounds, thereby ruling out even convergence of such bounds to the candidate energy. The present document retains the separate candidate-specific harmonic nonattainment proof.

Let P be the reconstructed candidate, and let `P_l` denote the ordinary Legendre polynomial normalized by `P_l(1)=1`. Define the all-pair harmonic moment, including diagonal pairs,

```
A_l(P) = sum_(i,j=1)^9 P_l(p_i dot p_j).
```

We prove

```
A_1(P)=0, and A_l(P)>0 for every integer l>=2.
```

It follows that no finite-degree polynomial `H=sum a_l P_l` with `a_l>=0` for `l>=1` and `H(t)<=1/sqrt(2-2t)` for `-1<=t<1` has an ordinary Delsarte energy bound equal to E(P). Thus increasing the degree of an ordinary sharp two-point LP certificate cannot solve this case.

## Harmonic Moment Criterion

For every degree l, the spherical harmonic reproducing kernel is a positive multiple of `P_l(x dot y)`. Consequently

```
A_l(P)=0
```

if and only if every degree-l spherical harmonic sums to zero on P. This follows by expressing the kernel in an orthonormal harmonic basis: the double sum is a positive constant times the sum of the squares of the individual harmonic sums. A single nonzero harmonic sum therefore implies `A_l(P)>0`.

This exact kernel construction and its equality criterion are given in the subsection "Positive-definite kernels" of the downloaded [Cohn--Kumar paper](https://arxiv.org/abs/math/0607446), source `work/prior/cohn-kumar/potential.tex`. The new ingredient below is an explicit nonvanishing harmonic in every sufficiently high degree for this candidate.

## Degrees 1 Through 32

The pair spectrum gives the exact univariate polynomial

```
A_l(r) = 9 + 2*(6 P_l(1-3r^2/2) + 3 P_l(2r^2-1)
                 +6 P_l(r^2/2-1) + 3 P_l(-1/2)
                 +6 P_l(-r) + 12 P_l(r/2)).
```

The factor two converts the 36 unordered pairs to all ordered off-diagonal pairs; the constant 9 is the diagonal. Exact rational recurrence and Horner interval evaluation on the certified radius interval prove `A_1=0` identically and `A_l>0` for `2<=l<=32`. The checker records every rational enclosure and independently rederives the Legendre polynomials from

```
(l+1)P_(l+1)(t)=(2l+1)t P_l(t)-l P_(l-1)(t).
```

This repeats the earlier SymPy-based finite check using only standard-library rational arithmetic. No numerical eigenvalue or sampled sign is used.

## Explicit High-Degree Harmonics

Write `w=x+iy` and `s=x^2+y^2+z^2`. For every nonnegative integer m, define

```
B0(s,z) = 1,
B2(s,z) = s-(2m+3)z^2,
B4(s,z) = s^2-2(2m+5)s z^2 + ((2m+5)(2m+7)/3)z^4,
H_(m,q)(x,y,z) = w^m Bq(s,z),       q in {0,2,4}.
```

These are complex homogeneous harmonic polynomials of degree `m+q`. Homogeneity is immediate by assigning weight two to s and weight one to z. Harmonicity can be checked without expanding `w^m`: since `Delta(w^m)=0`, the product and chain rules give

```
Delta(w^m B(s,z))
 = w^m [4s B_ss + (4m+6)B_s + 4z B_sz + B_zz].
```

The term `4m B_s` comes from `x*partial_x(w^m)+y*partial_y(w^m)=m w^m`. Substituting B0, B2, and B4 makes the bracket identically zero. The checker verifies all three identities as rational polynomial identities in the formal variables m,s,z; this is not testing a list of numerical m values. The identity also holds at w=0, since it is a polynomial identity and introduces no division by w.

On the unit sphere, put

```
R0(z)=1,
R2(z)=1-(2m+3)z^2,
R4(z)=1-2(2m+5)z^2+((2m+5)(2m+7)/3)z^4.
```

For `0<=z^2<=1` and `m>=0`, triangle inequalities give

```
|Rq(z)| <= Q(m) := (4m^2+36m+68)/3    for q=0,2,4.
```

For q=4, Q is exactly the sum of the absolute coefficients. For q=2 the coefficient sum is `2m+4<=Q(m)`, and for q=0 it is `1<=Q(m)`.

## A Nonzero Sum in Every Degree At Least 33

Given an integer `l>=33`, choose q by its residue modulo three:

| l modulo 3 | q | m=l-q |
| --- | --- | --- |
| 0 | 0 | divisible by 3 |
| 1 | 4 | divisible by 3 |
| 2 | 2 | divisible by 3 |

In every case q is even and `m>=29`. At the three caps, the complex horizontal coordinates are minus the three cube roots of unity and z=0. At the two prism triangles they are r times those cube roots, with heights `+sqrt(1-r^2)` and its negative. Since m is divisible by three and Rq is even,

```
sum_(p in P) H_(m,q)(p)
 = 3*(-1)^m + 6*r^m*Rq(sqrt(1-r^2)).
```

The cap contribution has absolute value 3. The remaining contribution is bounded by `6*r^m*Q(m)`. The exact radius interval gives `r<18/25`, so it suffices to prove

```
2*(18/25)^m*Q(m)<1 for every integer m>=29.
```

At m=29, `Q(29)=1492` and the left side is exactly

```
7545733570554642645649358049911727194112
/34694469519536141888238489627838134765625
< 1.
```

For the induction step, the exact polynomial identity

```
(m+1)^2*Q(m)-m^2*Q(m+1) = (36m^2+172m+68)/3 > 0
```

shows `Q(m+1)/Q(m)<((m+1)/m)^2` for m>0. For m>=29,

```
(18/25)*Q(m+1)/Q(m)
 < (18/25)*(30/29)^2 = 648/841 < 1.
```

Thus the required sequence is decreasing and its base value is below one. The cap contribution cannot be cancelled by the prism contribution, so the harmonic sum is nonzero. Its real part already has nonzero sum, because every term displayed above is real. The harmonic moment criterion gives `A_l(P)>0` for all l>=33. Together with the finite exact check, this proves positivity in every degree l>=2.

## Consequence for Ordinary LP Sharpness

Suppose a finite polynomial minorant H with nonnegative nonconstant Legendre coefficients were sharp at P. Its ordinary two-point bound is

```
L_H = (81*a0-9*H(1))/2.
```

The exact slack identity is

```
E(P)-L_H = sum_(i<j)(f(gij)-H(gij))
          +(1/2)*sum_(l>=1) a_l*A_l(P).
```

Every term is nonnegative. Sharpness forces `a_l=0` for every l>=2, since the corresponding moments have just been proved strictly positive. Therefore H is affine. Sharpness also forces contact at every realized pair value, in particular at the two distinct values `-r` and `-1/2`.

But `f(t)=(2-2t)^(-1/2)` is strictly convex, with `f''(t)=3(2-2t)^(-5/2)>0`. An affine function agreeing with f at two distinct points lies strictly above f at their midpoint. It therefore cannot be a minorant on the interval between those points. This contradiction proves that no such sharp finite-degree ordinary LP certificate exists.

The obstruction concerns an attained sharp polynomial bound, not the supremum of all polynomial bounds. It also does not address LP bounds with additional configuration-dependent constraints or partitions. None of those stronger methods is ruled out here.

## Exact Check and Trust Boundary

From the project output directory:

```powershell
python certificates/check_all_degree_lp.py --negative-control --report results/all-degree-lp.check.json
```

The checker verifies the 31 finite positive moment enclosures, all three formal Laplacian identities, the polynomial ratio identity, the residue choices, and the exact induction constants. It also rejects a deliberately corrupted quadratic-harmonic coefficient. It hashes the local radius certificate used for the enclosures.

The all-degree conclusion additionally uses the explicitly written induction and classical spherical-harmonic kernel theorem. The final contradiction is a strict-convexity argument. These mathematical bridges are not disguised as finite tests and have not been Lean-formalized. The result is a mathematical obstruction with exact computational support, not a claim that a Lean kernel has checked the all-degree theorem.
