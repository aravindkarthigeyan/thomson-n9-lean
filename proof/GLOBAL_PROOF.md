# Original Mathematical Proof: Hermite Route

This records the first complete computer-assisted mathematical proof, using
high-precision Hermite slack and the original local argument. Its finite
premises are replayed by `python verify_global.py`. The selected Lean proof
instead uses D60 rational certificates, direct Bernstein minorants, refined
Gram windows, and the zero-penalty ambient Hessian certificate; see
`FORMAL_PROOF_GUIDE.md`. That unrestricted global and equality theorem has
compiled. Release verification is tracked separately in `STATUS.md`.
Numerical optimization and floating-point SDP feasibility are not premises.

## Statement and Exact Candidate

Let

```
e0=(1,0), e1=(-1/2,sqrt(3)/2), e2=(-1/2,-sqrt(3)/2).
p_(k,+)=(r*e_k, sqrt(1-r^2)),
p_(k,-)=(r*e_k,-sqrt(1-r^2)), q_k=(-e_k,0),  k=0,1,2.
```

Here `r` is the unique zero in `(0,1)` of the derivative of

```
Phi(r)=2sqrt(3)/r + 3/(2sqrt(1-r^2)) + 6/sqrt(4-r^2)
       +sqrt(3) + 6/sqrt(2+2r) + 12/sqrt(2-r).
```

In particular it belongs to the rational interval

```
[7105483340929538113277041792727912437680/10^40,
 7105483340929538113277041792727912437681/10^40].
```

Existence, uniqueness in this interval, admissibility, the exact 36-pair energy
formula, and minimization of this family have also been proved in the delivered
Lean package. Direct differentiation gives `Phi''>0` on `(0,1)`; the opposite
endpoint derivative signs identify the same unique minimizer. Write `P` for
this configuration and `E*=Phi(r)`.

**Theorem.** For every nine distinct unit vectors `x_i` in `R^3`, with energy
`E(X)=sum_(i<j) 1/|x_i-x_j|`, one has `E(X)>=E*`. Equality holds exactly when
there are an orthogonal map `Q` and a permutation `pi` such that
`x_i=Q p_(pi(i))` for every i.

The argument will prove that every competitor with `E(X)<=E*` is congruent to
`P`. It neither assumes existence of a global minimizer nor minimizes over a
numerical sample of configurations.

## 1. Separation and a Nondegenerate Anchor

Put `u_ij=x_i dot x_j`, `f(t)=(2-2t)^(-1/2)`, and
`T=6439996633/250000000=25.759986532`.
The local root/energy enclosure and the independent refined Hermite energy
enclosure both prove `E*<T`.

The two rational Legendre minorants in `sdp/lp-separation.json` and
`sdp/lp-separation-05593.json` are independently checked by `check_lp.py`.
For each, `h_LP=sum_l a_l P_l`, where `P_l` is the Legendre polynomial
normalized by `P_l(1)=1`, every `a_l>=0` for `l>=1`, and `h_LP<=f` on
`[-1,1)`. The latter is an exact Bernstein subdivision proof after the
substitution `t=1-2y^2`; its finite covering is recomputed, not sampled.

The spherical harmonic addition theorem gives
`sum_(i,j) P_l(u_ij)>=0`. Explicitly, the kernel is a positive constant times
the sum of products of the degree-l real spherical harmonics in an orthonormal
basis. Therefore its double sum is a sum of squares. It follows that

```
E(X) >= B + sum_(i<j)(f-h_LP)(u_ij),
B=(81*a0-9*h_LP(1))/2.
```

For the separation minorant, the checker additionally proves
`f(t)-h_LP(t)>=T-B+10^(-8)` whenever `5593/10000<=t<1`.
One pair in that interval would force `E(X)>T`. Hence for every competitor
under consideration,

```
-1 <= u_ij < 5593/10000  (i != j).                         (1)
```

For the covariance minorant the exact bound is
`B=51457135199103/2000000000000`, and
`a2=6404422103/31250000000>0`.
Retaining its degree-2 term, and putting `M=sum_i x_i x_i^T`, gives

```
sum_(i,j) P2(u_ij)=(3/2)||M-3I||_F^2,
E(X)-B >= (3*a2/4)||M-3I||_F^2.
```

The exact rational comparison `4*(T-B)/(3*a2)<1/4` is checked. Thus
`||M-3I||_op<=||M-3I||_F<1/2`, and all eigenvalues of M exceed `5/2`.
Cauchy-Binet yields

```
sum_(i<j<k) det Gram(x_i,x_j,x_k)=det M>125/8.
```

There are 84 triples. At least one anchor triple consequently has

```
det Gram(x_i,x_j,x_k)>125/672.                              (2)
```

No minimum-pair slab, uncompleted branch-and-bound tree, or conjectural
classification is needed for (1) or (2).

## 2. A Certified Minorant with Quantitative Contact Slack

The six true candidate products are

```
s1=r^2/2-1, s2=-r, s3=-1/2,
s4=2r^2-1, s5=1-3r^2/2, s6=r/2.
```

They are strictly ordered in `(-1,1)`. Let H be the unique polynomial of
degree at most 20 matching f and f' at these six values and the derivatives
of orders 0 through 8 at -1. The 21 conditions determine H: the difference
of two solutions is divisible by the monic degree-21 node polynomial

```
omega(t)=(t+1)^9 product_j(t-s_j)^2.
```

The exact interval divided-difference computation in
`near_sharp/check_hermite.py` encloses all coefficients of **this H at the true
algebraic radius**, not an interpolant at decimal contacts. It checks the
original radical derivative equation at both endpoints of a width-`10^-230`
root bracket strictly inside the earlier bracket. Strict convexity identifies
that root with r. Interval arithmetic encloses the confluent Newton formula.

For the rational polynomial h in `near_sharp/hermite.json`, if `[a_i,b_i]`
encloses coefficient H_i, the checker verifies

```
a0-h0 >= sum_(i=1)^20 max(|a_i-h_i|,|b_i-h_i|).
```

Consequently `h<=H` on `[-1,1]`. It separately checks a rational U enclosing
`Phi(rMid)` from above, where rMid is the rational midpoint of the refined
root interval. Family minimality gives `E*<=Phi(rMid)<=U<T`.

For `-1<=t<1`, the repeated Rolle theorem gives, away from the nodes,

```
f(t)-H(t)=[f^(21)(xi)/21!]*omega(t),
f^(21)(xi)/21! >= binom(42,21)/2^64 > 10^-8.
```

Indeed, subtract from `f-H` its value at t divided by omega(t), times omega.
The resulting function has 22 zeros counted with multiplicity on a compact
interval inside `[-1,1)`, so its 21st derivative has a zero. The derivative
bound follows from
`f^(21)(x)/21!=binom(42,21)/(2^21*(2-2x)^(43/2))`.
At interpolation nodes use equality. Since omega is nonnegative here,
`h<=H<=f` everywhere on the pair domain.

Fix `epsilon=1/10000`. Outside the seven closed windows

```
[-1,-1+epsilon], and [s_j-epsilon,s_j+epsilon] for j=1,...,6,
```

all 21 factors of omega have magnitude greater than epsilon. Therefore

```
f(t)-h(t)>10^-8 * epsilon^21 = 10^-92.                     (3)
```

Full derivation and arithmetic details are in `near_sharp/HERMITE_PROOF.md`.

### Alternative Finite Polynomial Route

The independent proof in `near_sharp/BERNSTEIN_PROOF.md` can replace this
entire interpolation step. It checks `1-2y*h(1-2y^2)>=0` on `[0,1]` by1655
Bernstein leaves, and checks the corresponding polynomial for `h+10^-46`
on seven rational intervals covering the exterior of the true contact
windows. It uses the original40-digit radius bracket, checked against the
Lean definition, and the same exact h and U. Exact interval evaluation at a
rational family member plus family minimality proves `E*<=U<T`.

On this route replace (3) by `f(t)-h(t)>=10^-46` outside the seven windows.
Since `36L<10^-46`, Step4 gives the identical localization conclusion. All
other steps remain unchanged. `verify_global.py --bernstein` replays this
alternative, and it is the preferred route for the developing Lean proof.

## 3. Exact Three-Point Bound

For an anchored triple put `u=x dot y`, `v=x dot z`, `t=y dot z`. Define

```
q0=1, q1=t-u*v,
q_(k+1)=2*(t-u*v)*q_k-(1-u^2)*(1-v^2)*q_(k-1),
Y_k[i,j]=u^i*v^j*q_k, 0<=i,j<=10-k,
S_k=Sym(Y_k),
R_k=7*S_k(u,v,t)+S_k(u,u,1)+S_k(v,v,1)+S_k(t,t,1)+S_k(1,1,1)/8.
```

Here Sym averages over all six variable permutations. For each anchor choose
an orthonormal basis of its perpendicular plane and let z_b be the complex
coordinate of the projection of x_b. The recurrence of real parts of complex
powers proves

```
q_k(u_b,u_c,x_b dot x_c)=Re(z_b^k*conj(z_c^k)).
```

Thus every quadratic form in `sum_(a,b,c)Y_k` is a sum over anchors of squared
complex norms. All ordered indices, including repetitions, are allowed.
Symmetrization preserves this total sum. Separating triples into three
distinct, exactly two equal, and all equal indices proves

```
sum_(a<b<c) R_k = (7/6) sum_(a,b,c) S_k >= 0.              (4)
```

The exact certificate `near_sharp/near-sharp-d10.json` supplies rational
factors for 11 kernel matrices F_k and 12 domain-SOS matrices. All matrices
are defined as `B*B^T`; no numerical eigenvalue is accepted as proof of PSD.
Each SOS block is `Sym(g*||C^T b(u,v,t)||^2)`, where b is an explicit
integer-polynomial basis and g is one of

```
1, u+1, 5593/10000-u, D,
(u+1)*(5593/10000-u), D*(u+1)*(5593/10000-u),
D=1+2*u*v*t-u^2-v^2-t^2.
```

All are nonnegative on the true triple domain by (1) and Gram positivity,
as are all their permutations. Factoring and summing (4) proves positivity
of the kernel terms after summing over triples. Individual R_k need not be
pointwise PSD.

The checker expands the entire identity over the rationals:

```
(h(u)+h(v)+h(t))/3 - U/36
  = sum_k <F_k,R_k> + sum SOS + A(u,v,t).
```

Let L be the sum of absolute values of all monomial coefficients of A.
The integer checker uses symmetry-orbit sums; since A is symmetric, all
coefficients in an orbit are equal and have the same sign, so its compressed
L1 sum is exactly the full L1 sum. Independent FLINT reconstruction of all
1771 full coefficients agrees bit-for-bit. All 358 compressed coefficient
rows are included, even the two omitted in the numerical discovery solve.
The final certificate has no additional determinant-moment term.

Since every variable is in `[-1,1]`, `A>=-L`. Each pair lies in seven
unordered triples. Summing the identity and using (4) gives

```
(7/3) E_h(X) >= 84*(U/36-L),
E_h(X) >= U-36L.                                          (5)
```

The exact check proves

```
36L < 10^-92.
```

For orientation only, `36L` is approximately `3.983511875174096e-164`.
The certificate SHA-256 is
`c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9`.
`CERTIFICATE_SOUNDNESS.md` gives the full arbitrary-N summation derivation;
`near_sharp/EXACTIFICATION.md` separates discovery from checking.

## 4. Localization and Finite Gram Rigidity

Suppose `E(X)<=E*`. Every term of `f-h` is nonnegative, and (5) gives

```
sum_(i<j) (f-h)(u_ij)=E(X)-E_h(X)<=E*-U+36L<=36L<10^-92.
```

By (3), no pair can be outside the seven true windows. The possible window
at -1 is removed as follows. If `t=-1+delta` with `0<=delta<=epsilon`, the
Gram determinant with any third point is

```
D(t,u,v)=2delta*(1+u*v)-delta^2-(u+v)^2.
```

For all 49 choices of the windows of u and v, the rational interval checker
proves the right side less than `-1/6000`. This contradicts Gram positivity.
Hence all pairs lie in the six true candidate windows.

Use the anchor from (2). Sort its three color indices by permuting its three
vertices. There are 56 color multisets; 36 survive the determinant threshold.
An extra point has one of 216 anchor-color triples. The necessary norm
condition is the vanishing determinant of its four-by-four Gram matrix.
For two extra points, the necessary mutual-color condition is the vanishing
four-by-four cross-Gram determinant. These rank constraints hold for arbitrary
vectors in R3, without assuming symmetry.

`rigidity/check_window_gram.py` constructs the generic determinant polynomials
by permutation expansion and checks every excluded color using rational
interval evaluation. It verifies 7683 extension exclusions and 1832
pair-color exclusions, including every self-type color with independent
variables for the two points. Consequently no two points can share one
extension type. Exhaustive enumeration of all six-extension subsets leaves
eight cliques. Every one is verified, entry by entry, to be a relabeling of
the candidate's colored Gram matrix.

The rational interval boxes are only filters for rejecting impossible colors.
The original hypothesis is membership in true windows at s_j(r), so retaining
a color gives the exact epsilon bound, not an epsilon-plus-roundoff estimate.
Thus some relabeling satisfies

```
max_(i,j) |x_i dot x_j - p_i dot p_j| <= 1/10000.           (6)
```

All finite cases and their soundness are specified in `rigidity/PROOF.md`.
No accepted color pattern is claimed geometrically realizable merely because
it survives interval filtering; only the necessary conclusion (6) is used.

## 5. Local Uniqueness Finishes the Proof

The quantitative local theorem proved in `LOCAL_PROOF.md` is

```
rho=min_(Q in O(3)) ||X-QP||_F <= 1/500
  ==> E(X)-E* >= rho^2/50.                                (7)
```

Its exact computational premise is an interval LDL proof
`H_t+RR^T >= (7/50)I18`, where H_t is the constrained tangent Hessian and
R contains the three rotational tangent vectors. Full stationarity follows
from the D3h symmetry action and `Phi'(r)=0`, not just family numerics.

For completeness, optimal orthogonal alignment makes the tangent projection
of `b=X-P` perpendicular to rotations. Sphere constraints give
`p_i dot b_i=-|b_i|^2/2`. The certified minimum distance keeps every pair
distance along the ambient Taylor segment at least one. The third-derivative
bound `|D^3(1/|y|)[w,w,w]|<=6|w|^3/|y|^4`, the complete-graph identity
`sum_(i<j)|b_i-b_j|^2=9||b||^2-|sum b_i|^2`, and `||H_c||<=22` give

```
E(X)-E* >= rho^2*(7/100-(49/2)rho-(1107/400)rho^2).
```

The factor is at least `1/50` on `[0,1/500]`, by an exact rational comparison.

The same document proves the following Gram-to-coordinate bound: if
`PP^T>=2I` and `delta=||X^TX-P^TP||_F<=1`, then
`min_Q ||X-QP||_F<=2delta`. It follows by writing `X=AP+Z`, `ZP^T=0`,
using the polar factor of A, and bounding the two orthogonal summands.
Here `PP^T=diag(3r^2+3/2,3r^2+3/2,6(1-r^2))>2I` by the root bracket.
Equation (6) gives

```
delta<=9/10000, rho<=18/10000=9/5000<1/500.
```

Apply (7). Since `E(X)-E*<=0`, it follows that `rho=0`. Compactness of O(3)
ensures the minimum is attained, so X is an orthogonal image of the relabeled
candidate. This proves both the global lower bound and the forward equality
case. Conversely orthogonal transformations and permutations preserve every
distance, so they preserve energy. The theorem follows.

## Reproduction and Trust Boundary

From this directory, run ordinary Python 3.12 with assertions enabled:

```
python verify_global.py
```

This imports no numerical solver and recomputes all arithmetic premises from
the supplied data, including the two LP minorants, root/Hermite enclosures,
all rational factors and residual coefficients, finite Gram exclusions, and
the Hessian LDL bound. It then checks every cross-stage constant used above.
Its report includes SHA-256 hashes of all inputs and checking code. Saved
reports are outputs, never evidence accepted in place of recomputation.

Independent polynomial reconstruction and mutations are replayed by
`near_sharp/audit_final_certificate.py` with the pinned python-flint version.
The local, Hermite, and rigidity components have their own negative controls.

The alternative proof presented here relies on the displayed analytic
arguments and exact Python computations. These computations are not imported
as Lean axioms. The selected formal proof and its unrestricted global and
equality theorems are mapped in `FORMAL_PROOF_GUIDE.md`; this historical Hermite
exposition is not itself the formal dependency chain. See `STATUS.md` for
the current release-verification boundary.
