# Direct Polynomial Minorant and Exterior-Gap Proof

This is an alternative to `HERMITE_PROOF.md`. It proves the same rational h is
a Coulomb minorant and proves a stronger exterior gap, using finite polynomial
identities and sign checks only. It does **not** require a generalized Hermite
remainder theorem, divided differences, or the refined 230-digit root theorem.
The older Hermite proof remains valid and independently audited.

## Potential Substitution

For `-1<=t<1`, put `y=sqrt((1-t)/2)`. Then `0<y<=1`, `t=1-2y^2`, and
`f(t)=1/(2y)`. Consequently, for any rational polynomial h and rational gamma,

```
p_gamma(y)=1-2y*(h(1-2y^2)+gamma)>=0
  ==> f(t)-h(t)>=gamma.
```

Both p_0 and p_gamma have degree at most41. The checker expands them exactly
by the binomial theorem. At y=0 the polynomial is1; including that endpoint in
the verification is harmless even though distinct sphere points exclude t=1.

## Bernstein Positivity and Subdivision

For a power-basis polynomial `p(z)=sum_(i=0)^n a_i*z^i`, define

```
b_k=sum_(i=0)^k a_i*binom(k,i)/binom(n,i).
B_(n,k)(z)=binom(n,k)*z^k*(1-z)^(n-k).
```

The identity `p=sum_k b_k*B_(n,k)` follows by substituting the b_k and using
`binom(n,k)binom(k,i)=binom(n,i)binom(n-i,k-i)`. The inner sum reduces by the
binomial theorem to `z^i*(z+1-z)^(n-i)=z^i`. Each B_(n,k) is nonnegative on
`[0,1]`; thus nonnegative b_k prove p nonnegative there. An affine substitution
`y=a+(b-a)z` proves the corresponding assertion on `[a,b]`.

The left and right half-interval Bernstein coefficients are exactly

```
left_k = 2^(-k) sum_(j=0)^k binom(k,j)*b_j,
right_k = 2^(-(n-k)) sum_(j=k)^n binom(n-k,j-k)*b_j.
```

These follow by substituting `z/2` and `(1+z)/2` in the Bernstein expansion and
collecting terms by the same binomial identity. The generator computes them
with the triangular de Casteljau algorithm. The separate checker uses these
direct binomial formulas, so it does not reuse the generator's split code.

The checker clears the positive common denominator, multiplies both split
coefficient arrays by `2^n`, and may divide an array by its positive integer
coefficient gcd. These operations preserve signs and represent positive
scalar multiples of the appropriate restricted polynomial. All-zero arrays
need no normalization. No floating-point sign decision occurs.

A certificate is a preorder binary tree: `0` splits an interval into both
halves and `1` accepts a leaf after checking every coefficient is nonnegative.
The checker maintains all pending intervals and rejects premature termination,
extra nodes, unknown tokens, or any negative coefficient at an accepted leaf.
Thus every point of the root interval is covered. The advertised leaf count
and maximum depth are checked, not trusted.

The global p_0 certificate covers `[0,1]` with1655 leaves, maximum depth286.
The depth is needed near the extremely flat contacts. It is not a numerical
tolerance: all comparisons use exact integers.

## Seven Exterior Intervals

Let r be the already defined candidate radius in its40-digit rational bracket.
The checker independently computes exact rational enclosures
`[l_j,u_j]` for the six ordered products s_j(r). Put epsilon=`1/10000`.
Every **inner** interval

```
[u_j-epsilon, l_j+epsilon]
```

lies inside the true contact window `[s_j(r)-epsilon,s_j(r)+epsilon]`.
These inner intervals are nonempty and ordered, as checked by rational
comparisons. The seventh true window is the antipodal interval
`[-1,-1+epsilon]`. Remove its interior as well. The complement of all seven
interiors on the separated t-domain is covered by the following seven closed
rational intervals:

```
[-1+epsilon, u_1-epsilon],
[l_j+epsilon, u_(j+1)-epsilon] for j=1,...,5,
[l_6+epsilon, 5593/10000].
```

In particular, every point outside the seven **true** windows belongs to this
cover. Enlarging the exterior domain this way strengthens the certificate's
obligation; it does not discard any potential counterexample.
The separate49-case Gram determinant certificate subsequently excludes the
antipodal window; the Bernstein checker does not assert that exclusion itself.

For each t-interval `[a,b]`, the supplied y-interval `[c,d]` satisfies

```
0<=c<d<=1, c^2<=(1-b)/2, d^2>=(1-a)/2.
```

Monotonicity of the nonnegative square root therefore places every corresponding
y in `[c,d]`. The checker verifies all these rational comparisons and verifies
p_gamma has nonnegative Bernstein coefficients on each such interval, with
`gamma=10^-46`. In fact each of the seven intervals needs only one leaf.
It follows that

```
t outside the seven true windows ==> f(t)-h(t)>=10^-46.
```

The final SOS energy loss is strictly below this gap, so a low-energy competitor
cannot have an exterior pair. All later antipodal, finite Gram, and local
arguments of `../GLOBAL_PROOF.md` apply without change.

## Energy Upper Bound Without a Refined Root

The certificate includes a rational `energy_midpoint` in `(0,1)` and a rational
U. Exact outward interval evaluation proves `Phi(energy_midpoint)<=U<T`.
The already Lean-proved minimum of the candidate family gives
`E(P)<=Phi(energy_midpoint)`. No assertion that this midpoint approximates the
root to a specified accuracy is needed. Its many digits are helpful for a
tight bound, not an unverified mathematical premise.

This leaves only the existing40-digit root definition, the exact energy
formula/family minimum, finite rational polynomial verification, and interval
evaluation of square roots. The 230-digit stationarity refinement and the
Hermite construction are no longer required for this alternative proof path.

## Replay and Trust

```
python near_sharp/check_bernstein.py --negative-controls
python verify_global.py --bernstein --report verification/global-bernstein-chain.check.json
```

Generation, which is not trusted by the checker:

```
python near_sharp/generate_bernstein.py --output near_sharp/regenerated-bernstein.json
```

The independent checker rejected an unsplit false global leaf, an incomplete
cover, a raised minorant coefficient, an exterior gap of1, and a lowered energy
upper bound. It uses only standard-library integer/rational operations and the
project's exact interval arithmetic. This is still mathematical software plus
the displayed soundness proof, not yet a Lean-checked large certificate.
