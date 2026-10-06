# Original Rational Tiny-Gap Closure

All premises of this sufficient-certificate theorem have now been supplied and
checked. The complete argument is assembled in `GLOBAL_PROOF.md`; its finite
arithmetic premises are replayed by `verify_global.py`. This is the original
Hermite-based mathematical route. The selected unrestricted Lean proof has
compiled using D60 rounding and direct Bernstein slack instead; see
`FORMAL_PROOF_GUIDE.md` and `STATUS.md` for its route and release boundary.

## Certificate Premises

Fix the exact candidate radius r* and its six inner products s_1,...,s_6.
Let epsilon=1/10000 and define the seven closed windows

```
[-1,-1+epsilon],  [s_j-epsilon,s_j+epsilon] for j=1,...,6.
```

Let H be the degree-at-most20 Hermite interpolant of the Coulomb potential
f(t)=(2-2t)^(-1/2): it matches derivatives of orders0 through8 at -1 and
values and first derivatives at each of the six candidate products. These
are21 interpolation conditions at distinct nodes.

It suffices to provide the following exact rational objects and checks:

1. A rational polynomial h with h(t)<=H(t) for every -1<=t<=1.
2. A rational U with E(P9)<=U<25.759986532.
3. Rational Gram factors for the three-point kernel/SOS identity, on the
   justified domain [-1,5593/10000], such that the **entire** coefficient
   residual has l1 norm L and 36L<10^(-92).

The residual is that of `(h(u)+h(v)+h(t))/3-U/36` minus all certified positive
kernel and domain-SOS terms. All coefficients, including the two rows omitted
from a numerical solve, must be counted. There is no assumption of an exact
zero residual or of exact algebraic contact equations in this route.

The existing three-point summation theorem then yields

```
E_h(X) >= U-36L,
E_h(X)=sum_(i<j) h(x_i dot x_j),
```

whenever all pair products lie in that separated domain. Rational factors
guarantee PSD by construction; their numerical origin is irrelevant to this
inequality after the full rational residual is checked.

## Explicit Exterior Slack

Put omega(t)=(t+1)^9 product_j(t-s_j)^2. For a point t not equal to any
interpolation node, apply repeated Rolle's theorem to

```
g(z)=f(z)-H(z)-[(f(t)-H(t))/omega(t)]*omega(z).
```

It has the21 interpolation zeros counted with multiplicity, plus its zero
at t. Hence g^(21)(xi)=0 for a point xi in the interval spanning t and the
nodes. Since H has degree at most20 and omega is monic of degree21,

```
f(t)-H(t) = [f^(21)(xi)/21!]*(t+1)^9*product_j(t-s_j)^2.
```

All arguments are at least -1 and strictly below1. The derivative is positive
and increasing, and its explicit lower bound is

```
f^(21)(xi)/21! >= f^(21)(-1)/21!
                   = binom(42,21)/2^64 > 1/10^8.
```

Thus H<=f on [-1,1), including nodes by interpolation. Outside the seven
closed windows, t+1>epsilon and all six distances |t-s_j|>epsilon. Consequently

```
f(t)-h(t) >= f(t)-H(t)
           > (1/10^8)*epsilon^(9+12) = 1/10^92.
```

This deliberately crude bound is uniform. It does not use numerical curvature,
sampled slack, or a decimal approximation to a contact point.

## Global Localization and Equality

Suppose X is any competitor with E(X)<=E(P9). The independently certified
LP separation theorem applies because E(P9)<=U<25.759986532; hence every pair
product is below5593/10000. The rational SOS bound applies. Since h<=H<=f,
all36 individual pair slacks are nonnegative, and

```
sum_(i<j) [f(u_ij)-h(u_ij)] = E(X)-E_h(X)
                         <= E(P9)-U+36L <= 36L < 1/10^92.
```

One pair outside the seven windows would contribute more than1/10^92 by the
preceding estimate, a contradiction. Thus every pair lies in the seven true
windows. The exact antipodal exclusion in `rigidity/PROOF.md` removes the
seventh window. The covariance bound supplies a nondegenerate anchor, and the
finite window classifier supplies a permutation matching the candidate Gram
matrix entrywise within1/10000.

The proved Gram-to-coordinate estimate gives optimal orthogonal alignment
distance rho<=18/10000<1/500. The local theorem then yields

```
E(X)-E(P9) >= rho^2/50.
```

Its left side is nonpositive, so rho=0. Therefore every competitor at or below
the candidate energy is an orthogonal image and relabeling of the candidate.
This excludes lower energy and proves the equality characterization. Conversely,
orthogonal transformations and relabeling preserve all distances and energy.

## Current Verification Boundary

`near_sharp/check_hermite.py` proves the finite arithmetic premises behind1
and2: a width10^(-230) radius bracket with exact stationarity endpoint signs,
interval divided differences for H, a rational h below every enclosed H, and
a rational upper enclosure for Phi(rMid). The already-proved family minimum
gives E(P9)<=Phi(rMid). Its returned h differs from H by less than10^(-130).

`certificates/check_sos_integer.py` separately checks rational factors and
every residual coefficient. With `--hermite-certificate` it requires exactly
the h and U returned by the Hermite checker. `--require-localization` rejects
unless36L is strictly below the verified exterior-slack constant.

The rational export `near_sharp/near-sharp-d10.json` passes the full exact check,
with energy loss approximately `3.983511875174096e-164 < 1e-92`. An independent
FLINT expansion of all 1771 full coefficients matches the integer checker's
residual exactly. Five targeted corruptions were rejected. The complete-chain
replay and independent analytic audit also passed. These particular Hermite
analytic bridges are retained as mathematical proofs, not claimed as the
formal dependency chain of the later compiled unrestricted theorem.
