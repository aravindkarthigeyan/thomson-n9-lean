# Exact Global Constraints on Every Possible Competitor

Let X be nine distinct unit vectors in R3 and suppose `E(X)<=E(P9)`. The exact candidate interval is checked by `certificates/check_local.py`. Put

```
U = 6439996633/250000000 = 25.759986532.
```

The certified candidate energy upper endpoint is strictly below U. The following conclusions therefore hold for every possible competitor. They are mathematical consequences of exact rational certificates, but have not yet been formalized in Lean.

## Unconditional Energy Bound

The exact conditional certificate `certificates/sep0560-d8-box.json` has domain `[-1,0.5600]`. The exact Bernstein residual refinement in `RESIDUAL_BERNSTEIN.md` improves its l1 rounding-loss bound and proves

```
E(X) >= L = 119953804280010708359458454884835657004788679
             /4656612873077392578125000000000000000000000
             = 25.75988332067154... .
```

This is also an unconditional bound for all nine-point configurations. If `E(X)>U`, then `E(X)>U>=L`. If `E(X)<=U`, the separation argument below, which needs only that energy hypothesis, proves all pair inner products are below 0.5593 and hence inside the conditional certificate's domain. That certificate therefore gives `E(X)>=L` in the second case as well. The combined checker verifies the interval containment and rational inequality `L<=U` explicitly. This dichotomy does not establish sharpness or equality rigidity.

## Strict Pair Bounds

Every distinct inner product is strictly less than

```
5593/10000 = 0.5593.
```

The input is `sdp/lp-separation-05593.json`, rechecked by `check_lp.py`. Its global rational polynomial minorant H has nonnegative nonconstant Legendre coefficients and LP bound

```
B_sep = 25728382789209/1000000000000.
```

The exact Bernstein test also proves

```
f(t)-H(t) >= U-B_sep+1/100000000
for 5593/10000 <= t < 1.
```

Indeed it checks `H+(U-B_sep)+1/100000000` as a Coulomb minorant on that subinterval. The LP energy decomposition is

```
E(X) = B_sep + (1/2)*sum_(k>=1) a_k*S_k
       + sum_(i<j) (f(gij)-H(gij)),
S_k = sum_(i,j) P_k(gij) >= 0.
```

All terms after B_sep are nonnegative. A single pair at or above 0.5593 would force energy greater than U, a contradiction. This is a strict maximum bound, not merely a sampled exclusion.

The minimum distinct inner product is strictly less than

```
-73/100 = -0.73.
```

Suppose instead every pair were at least -0.73. The just-proved maximum bound places all pairs in `[-0.73,0.567]`. The exact three-point certificate `certificates/min073-sep0567-d6.json` then gives

```
E(X) >= 40251056167184550238233/1562500000000000000000
      = 25.760675946998... > U,
```

again a contradiction. This conclusion uses the conditional certificate only after its maximum-inner-product hypothesis has been established.

## Covariance and Centroid

A separate global LP input, `sdp/lp-separation.json`, has bound and two positive coefficients

```
B = 51457135199103/2000000000000,
a1 = 116052895813/250000000000,
a2 = 6404422103/31250000000.
```

Define `s=sum_i x_i` and `M=sum_i x_i*x_i^T`, so `trace M=9`. The first two kernel sums are

```
S1 = ||s||^2,
S2 = (3/2)*trace(M^2)-81/2 = (3/2)*||M-3I||_F^2.
```

The same exact LP decomposition yields both

```
||s||^2 <= 2*(U-B)/a1 < 9/64,
||M-3I||_F^2 <= 4*(U-B)/(3*a2) < 1/4.
```

Each final comparison is checked as a rational inequality by `check_constraints.py`. Since the operator norm is at most the Frobenius norm, every covariance eigenvalue is strictly between 5/2 and 7/2. In particular,

```
M > (5/2)*I,       ||s|| < 3/8.
```

Every Gram row sum consequently lies in `(-3/8,3/8)`, since `sum_j gij=xi dot s` and `||xi||=1`. These are useful affine constraints in anchor-Gram coordinates; the current hybrid prototype does not yet use the centroid row constraints.

## Far-Negative Graph Degree

Under the same energy hypothesis `E(X)<=U`, form the graph with an edge whenever a distinct inner product is at most `-7/10`. This graph has maximum degree at most three. Every graph formed by using a more negative threshold, such as -0.71, -0.72 or -0.73, is a subgraph and inherits the conclusion.

The same rational squared-norm bounds used above give the slightly sharper comparisons

```
||M-3I||_F^2 <= 62837864897/307412260944 < (453/1000)^2,
||s||^2 <= 62837864897/464211583252 < (46/125)^2.
```

Both strict rational comparisons are checked directly. Consequently `M<(3453/1000)I` and `||s||<46/125`.

Suppose instead a vertex x has four such neighbors, with inner products `t1,...,t4`, and write `T=-(t1+...+t4)`. Then `T>=4a` for `a=7/10`. The other four inner products have sum S. Since the Gram row includes the diagonal entry 1 and its total is greater than `-46/125`,

```
1-T+S > -46/125, hence S > T-171/125 > 0.
```

Apply Cauchy--Schwarz separately to the two groups of four. The covariance identity and its strict upper bound give

```
3453/1000 > x^T*M*x
    = 1 + sum_(j != i) (x dot x_j)^2
    >= 1 + T^2/4 + S^2/4
    >= 1 + (T^2+(T-171/125)^2)/4.
```

The final expression has derivative `T-171/250`, which is positive for `T>=4a`. Therefore it is at least its value at `T=4a`, namely

```
1 + 4a^2 + (4a-171/125)^2/4
 = 217041/62500
 = 3.472656
 = 3453/1000 + 2457/125000.
```

This contradicts the strict upper covariance bound. The argument selects any four far-negative neighbors; it does not assume that the remaining four inner products are individually positive, only that their sum S is positive. The exact rational constants and monotonicity domain are checked by `check_constraints.py`. This degree bound is a new combinatorial restriction, not a classification of the possible threshold graphs and not a proof of global localization.

## Additional Far-Pair Count

An additional piecewise degree9 LP witness sharpens the edge-count information:
every configuration at or below the same energy cutoff has at most12 unordered
pairs with inner product at most `-293/400=-0.7325`. Its exact signed-count lower
bound is `-1624795545219670258831/125000000000000000000`, strictly greater than
`-13`; integrality gives the claim. The witness uses nonnegative Legendre
coefficients, a nonnegative energy multiplier, and separately checked polynomial
inequalities on each side of the threshold. See `combinatorics/README.md` and
its independent exact Bernstein checker. This does not force the candidate's
six edges below that threshold.

## Uniform Nondegenerate Anchors

The trace-zero part of the covariance estimate gives a stronger determinant bound than simply multiplying the three eigenvalue lower bounds. Set `A=M-3I` and `q=trace(A^2)=||A||_F^2<1/4`. Since `trace A=0`, the three-dimensional determinant identity gives

```
det M = 27-(3/2)*q+trace(A^3)/3.
```

The eigenvalues of A have absolute value less than 1/2. Thus `|trace(A^3)|<=||A||_op*q<1/8`, and

```
det M > 27-3/8-1/24 = 319/12.
```

Let P be the 3-by-9 matrix of configuration columns. Cauchy--Binet applied to `M=P*P^T` now gives

```
sum_(i<j<k) det Gram(x_i,x_j,x_k) = det M > 319/12.
```

There are 84 triples, so some triple has Gram determinant strictly greater than

```
319/1008.
```

Choosing a globally maximal determinant triple gives a uniformly nonsingular Gram chart. This strengthens the earlier coarse `125/672` bound, which the current hybrid prototype conservatively retains. It provides a concrete way to avoid all singular-chart cases, at the price of no longer forcing the globally minimum pair to be two of those three anchors.

Alternatively, fix a globally minimum pair with inner product m and choose a third point maximizing its triple determinant D. With `w=x0 cross x1`,

```
sum_(k != 0,1) det Gram(x0,x1,xk) = w^T*M*w,
||w||^2 = 1-m^2.
```

For `-1<m<1`, the covariance lower bound gives

```
D > 5*(1-m^2)/14.
```

The non-strict version `D>=5*(1-m^2)/14` holds also at m=-1 and is sufficient for safe interval division on boxes bounded away from that endpoint. It does not remove the exact antipodal stratum in the minimum-pair chart; either a different anchor chart or a separate argument is still needed there.

## Reproduction and Scope

Run from the project output directory:

```powershell
python certificates/check_constraints.py --report results/global-constraints.check.json
```

This reruns the local candidate-energy interval check, both LP certificate checks, the minimum-slab three-point certificate, and the degree-eight conditional certificate with its finite Bernstein residual refinement, then checks all rational comparisons and the dichotomy giving the unconditional bound. No saved refinement report is trusted as input: all coefficients and 15 subdivisions are recomputed. Its report hashes the exact five certificate inputs and includes the complete refinement result. The polynomial/SOS soundness is explained in `CERTIFICATE_SOUNDNESS.md`; the local candidate characterization is in `LOCAL_PROOF.md`.

The current hybrid experiment deliberately uses the looser energy cutoff 25.76, maximum inner product 0.567, and minimum-pair cutoff -0.7. Every competitor satisfying the sharper theorem above lies in that enlarged domain. Its own `preconditions.py` separately verifies that the covariance estimate remains below 1/4 even at 25.76, so its `M>(5/2)I` and anchor-determinant interval contractions are valid at that looser threshold. It does not silently substitute the stronger candidate-energy cutoff into its calculations.

These intermediate constraints alone do not imply the Gram localization window from `LOCAL_PROOF.md`. The missing localization has since been supplied by the degree-20 tiny-residual certificate, as assembled in `GLOBAL_PROOF.md`. The older hybrid experiment is retained as research history, not used to close the final proof.
