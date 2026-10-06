# A Strict All-Degree Ceiling for Ordinary Two-Point LP

For the nine-point Coulomb problem, every finite-degree ordinary Legendre linear-programming lower bound is at most

```
25729492377/1000000000 = 25.729492377 < 25.73.
```

This is a rigorous ceiling on a proof method, not an upper bound on the Thomson minimum. In particular, it is below the already certified global energy lower bound in `GLOBAL_CONSTRAINTS.md`. Unlike the nonattainment result in `ALL_DEGREE_LP_OBSTRUCTION.md`, it rules out even a sequence of ordinary finite-degree LP certificates approaching the candidate energy. It does not apply to three-point SDP, additional geometric constraints, conditional domain bounds, or Gram-rank methods.

## Exact Dual Pair Measure

Write `f(t)=1/sqrt(2-2t)`. An ordinary LP polynomial has the form

```
H(t)=sum_(l=0)^d a_l P_l(t),
a_l>=0 for l>=1,   H(t)<=f(t) for -1<=t<1,
P_l(1)=1.
```

Its energy lower bound, with unordered pairs counted once, is

```
L_H = (81*a0-9*H(1))/2 = 36*a0-(9/2)*sum_(l>=1) a_l.
```

Consider any positive measure nu on [-1,1] of mass 36 satisfying

```
9 + 2*integral P_l(t) dnu(t) >= 0 for every l>=1.
```

Then, by summing finitely many inequalities with the nonnegative coefficients a_l,

```
integral H dnu >= 36*a0-(9/2)*sum_(l>=1) a_l = L_H.
```

If nu has no atom at 1 and f is integrable against nu, the minorant inequality gives `L_H<=integral f dnu`. Thus an explicit such measure with energy below 25.73 proves the asserted ceiling. The measure need not be a pair distribution of actual sphere points; the purpose is precisely to exhibit information that ordinary two-point LP cannot distinguish from a true pair distribution.

Our measure is

```
nu = (1-lambda)*sum_j q_j delta_(t_j) + 36*lambda*dt/2,
lambda = 1/500000000000.
```

The exact positive atoms and weights are:

| t_j | q_j |
| --- | --- |
| -1501/2000 | 251722946289/62500000000 |
| -3/4 | 765068624781/125000000000 |
| -1273/2000 | 730247570293/500000000000 |
| -1073/2000 | 267487245943/1000000000000 |
| -67/125 | 70704253363/50000000000 |
| -359/1000 | 103189534139/62500000000 |
| -717/2000 | 165373111747/125000000000 |
| 609/2000 | 16490736372503/1000000000000 |
| 61/200 | 811265648659/250000000000 |

Their mass is exactly 36 and every atom satisfies `|t_j|<=9/10`. These facts are recomputed from the rational data, not assumed from the numerical solver output.

## Degrees 1 Through 800

Put `A_l=9+2*sum_j q_j P_l(t_j)`. Orthogonality of Legendre polynomials to the constant gives `integral_(-1)^1 P_l(t)dt/2=0` for l>=1. Therefore the moment of nu is

```
9+2*integral P_l dnu = (1-lambda)*A_l+9*lambda.
```

Only this elementary orthogonality case is needed: integrating the generating function derived below gives `integral_(-1)^1 (1-2tz+z^2)^(-1/2)dt=2` for sufficiently small real z. Indeed its antiderivative in t is `-sqrt(1-2tz+z^2)/z`; the endpoint difference is `[(1+z)-(1-z)]/z=2`. Comparing coefficients proves the claimed zero means for l>=1.

The checker computes P_l(t_j) as exact rational numbers using

```
P_0(t)=1, P_1(t)=t,
(l+1)P_(l+1)(t)=(2l+1)t P_l(t)-l P_(l-1)(t).
```

For every l=1,...,800, the repaired moment is nonnegative. The smallest is at degree 1 and equals

```
4125500000000749/250000000000000000000000000 > 0.
```

The small uniform component repairs the tiny moment violations caused by rounding numerical weights. The repair is part of the exact measure and its energy is included; no solver feasibility tolerance is promoted into a proof. The report hashes the complete ordered list of exact finite moments.

## Every Degree At Least 801

The classical Laplace representation is

```
P_l(t) = (1/pi)*integral_0^pi (t+i*s*cos(phi))^l dphi,
s=sqrt(1-t^2),  -1<t<1.
```

The precise normalization was verified in [NIST DLMF, equation 18.10.5](https://dlmf.nist.gov/18.10.E5), whose notes refer to Szego, *Orthogonal Polynomials*, formula (4.8.10). Its TeX was downloaded as `work/prior/dlmf-18.10.E5.tex`, SHA256 `6ecf0dec907708fc58823549c50f026839557c44d7a1c8d89e37809acbc6dd3b`.

For completeness, the representation can also be derived directly from the Legendre generating function. For real z sufficiently close to zero, expand the geometric series under the integral. Odd powers of cos(phi) integrate to zero, while its average 2k-th power is `binom(2k,k)/4^k`. Hence the generating function of the displayed integrals equals

```
1/(1-t*z) * sum_(k>=0) binom(2k,k)/4^k *[-z^2*s^2/(1-t*z)^2]^k
 = 1/sqrt((1-t*z)^2+z^2*s^2)
 = 1/sqrt(1-2*t*z+z^2).
```

Uniform convergence for sufficiently small |z| justifies integration of the geometric series. Differentiating the final expression G gives `(1-2tz+z^2)G'=(t-z)G`; comparison of powers, with initial coefficients 1 and t, gives exactly the displayed Legendre recurrence. Thus comparison of coefficients proves the formula without changing its normalization.

The modulus of the integrand is controlled without cancellation:

```
|t+i*s*cos(phi)|^2 = 1-s^2*sin(phi)^2,
(1-s^2*sin(phi)^2)^(l/2) <= exp[-l*s^2*sin(phi)^2/2].
```

The second inequality follows from `1-y<=exp(-y)` for 0<=y<=1. On `[0,pi/2]`, concavity of sine gives `sin(phi)>=2*phi/pi`. Symmetry about pi/2 and the Gaussian integral therefore imply, for l>=1,

```
|P_l(t)|
 <= (2/pi)*integral_0^(pi/2) exp[-l*s^2*sin(phi)^2/2] dphi
 <= (2/pi)*integral_0^infinity exp[-2*l*s^2*phi^2/pi^2] dphi
 = sqrt(pi/(2*l))/s.
```

Here the Gaussian evaluation follows by squaring `integral_0^infinity exp(-y^2)dy` and integrating over the first quadrant in polar coordinates: its square is `(pi/2)*integral_0^infinity exp(-r^2)r dr=pi/4`. Positivity fixes the positive square root.

For our atoms, `s^2>=1-(9/10)^2=19/100>(2/5)^2`. Using pi<4, it follows that

```
|P_l(t_j)| < sqrt(25/(2*l)) <= sqrt(25/1602) < 1/8
for every l>=801.
```

The last rational comparison is exactly `25*64<1602`. Since the positive atomic weights sum to 36, every tail moment of nu satisfies

```
9+2*integral P_l dnu
 >= 9-2*(1-lambda)*36/8
 = 9*lambda >= 0.
```

This is an all-degree argument, not extrapolation from the 800 finite checks.

## Exact Energy Ceiling

The uniform component has average Coulomb energy 1 because

```
(1/2)*integral_(-1)^1 (2-2t)^(-1/2) dt = 1.
```

For each atom the JSON certificate supplies a positive rational b_j. The checker verifies `(2-2*t_j)*b_j^2>=1`, which proves `f(t_j)<=b_j`. Consequently

```
integral f dnu
 <= (1-lambda)*sum_j q_j*b_j + 36*lambda
 = 6432373094022177937629826011132364279807
   /250000000000000000000000000000000000000
 <= 25729492377/1000000000 < 2573/100.
```

Together with the dual inequality, this proves the claimed universal ceiling on every finite-degree ordinary LP polynomial, regardless of how its coefficients were discovered.

## Reproduction and Trust Boundary

The generator uses a grid with denominator 2000 on [-0.9,0.8], 160 numerical Legendre constraints, and SciPy HiGHS. It rationalizes the nonzero weights, enforces exact mass 36, selects a rational uniform repair from all 800 exact moments, and exports rational upper enclosures for the atomic energies. Numerical optimization is discovery only.

```powershell
python certificates/generate_lp_ceiling.py --output certificates/ordinary-lp-ceiling.json
python certificates/check_lp_ceiling.py certificates/ordinary-lp-ceiling.json --negative-control --report results/ordinary-lp-ceiling.check.json
```

The separate checker uses only standard-library integer/rational arithmetic. It verifies all finite conditions and the numerical constants of the written analytic tail proof. Deliberate changes to total mass, a radical enclosure, uniform positivity, the claimed ceiling, and a Legendre moment with mass preserved are rejected. The latter control specifically fails the moment check rather than an unrelated data-shape test.

The Gaussian integral, Laplace representation, Legendre orthogonality, and dual summation argument are supplied above as mathematical proofs, not claimed as Lean-verified facts. This is an exact computational certificate with an explicit all-degree analytic argument; a Lean formalization of this additional obstruction remains future work.
