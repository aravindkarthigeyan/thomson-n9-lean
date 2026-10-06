# High-Precision Root, Hermite Minorant, and Exterior Gap

This document proves the mathematical meaning of `hermite.json` and
`check_hermite.py`. All arithmetic premises below are independently
recomputed with exact integer operations and outward 1024-bit dyadic
intervals. No numerical root approximation is accepted without checking
the original radical equation. These additional results are not yet Lean
formalizations.

## Exact Parameter Identification

Let `F(r)` be the exact stationarity expression already used in
`ThomsonN9/Candidate.lean`:

```
F(r) = -2*sqrt(3)/r^2 + 3*r/[2*(1-r^2)^(3/2)]
       +6*r/(4-r^2)^(3/2) -6/(2+2*r)^(3/2) +6/(2-r)^(3/2).
```

The certificate gives rational endpoints `l<h` with `h-l=10^(-230)`.
The checker proves that both are strictly inside the earlier 40-decimal
isolating interval and proves `F(l)<0<F(h)` by outward interval arithmetic.
Continuity and the intermediate value theorem give a root in `(l,h)`;
uniqueness in the older interval, already established by the Lean
stationarity theorem, identifies this root with the same candidate
parameter `r*`. Thus this is a refinement of the existing definition,
not a new numerical definition of the candidate.

The exact rational midpoint `rMid=(l+h)/2` is stored in
`radius_midpoint`. It is the same midpoint used by the other `near_sharp`
certificate-generation components.

## The Exact Interpolant

The sorted six distinct pair products are

```
s1=r*^2/2-1,  s2=-r*,  s3=-1/2,
s4=2*r*^2-1,  s5=1-3*r*^2/2,  s6=r*/2.
```

The checker proves their interval enclosures are strictly ordered and lie
in `(-1,1)`. Let `H` be the unique real polynomial of degree at most 20
that matches `f(t)=(2-2t)^(-1/2)` and its first derivative at all six `s_i`,
and matches derivatives of orders 0 through 8 at -1. There are 21
conditions, counting multiplicities. Distinctness proves unisolvence by
the usual repeated-root argument: the difference of two solutions would
be divisible by `(t+1)^9*product_i(t-s_i)^2`, of degree 21.

The checker constructs enclosing intervals for every monomial coefficient
of `H` by the confluent divided-difference formula. A repeated block uses
the exact derivative divided by its factorial. At -1 these values are

```
f^(j)(-1)/j! = binom(2*j,j)/2^(3*j+1),   0<=j<=8;
```

at each double contact the derivative is `(2-2*s_i)^(-3/2)`. Divided
differences between distinct nodes use intervals with denominators
separated from zero. Expanding the Newton form gives the enclosed
monomial coefficients. Repeated appearances of the same unknown root
may enlarge the intervals, but cannot invalidate containment.

## Rational Minorant and Error

The delivered rational polynomial `h` has 21 monomial coefficients,
in increasing degree order, all with denominators dividing `10^180`.
Its generator rounds centers of the coefficient enclosures, then lowers
the constant coefficient by a rational amount covering the sum of all
rounding and enclosure errors. The checker does not trust that generation
procedure; it verifies the resulting domination directly.

If `[a_i,b_i]` encloses the true coefficient `H_i` and `h_i` is delivered,
put

```
R = sum_(i=1)^20 max(|a_i-h_i|,|b_i-h_i|).
```

The exact checks are

```
a0-h0-R >= 0,
max(|a0-h0|,|b0-h0|)+R < 10^(-130).
```

For every `|t|<=1`, the triangle inequality therefore gives

```
0 <= H(t)-h(t) < 10^(-130).
```

The actual checked uniform upper error is approximately
`9.8624899943*10^(-180)` and the domination margin is approximately
`9.6998155002*10^(-181)`; the exact rational values are in the check report.
No positivity sampling or unresolved near-contact tolerance is used.

## Hermite Remainder and the Exterior Gap

For `-1<=t<1` away from the interpolation nodes, the repeated-node Hermite
remainder theorem gives a point `xi` in the convex hull of `t,-1,s1,...,s6`
such that

```
f(t)-H(t) = [f^(21)(xi)/21!] * (t+1)^9 * product_(i=1)^6(t-s_i)^2.
```

This version follows directly from repeated Rolle's theorem: subtract a
multiple of the degree-21 node polynomial so that the difference also
vanishes at t, then apply Rolle 21 times, counting the repeated zeros.
All required derivatives exist on the compact hull, which lies in
`[-1,1)`. At a node the interpolation equality supplies the same
nonnegativity conclusion without invoking a distinct additional zero.

All factors in the node polynomial are nonnegative on `[-1,1)` and the
derivative is positive. Hence `H<=f`, and therefore `h<=H<=f` throughout
that interval. The normalized derivative is explicitly

```
f^(21)(x)/21! = binom(42,21)/[2^21*(2-2*x)^(43/2)].
```

Since `xi>=-1`,

```
f^(21)(xi)/21! >= binom(42,21)/2^64
  = 67282234305/2305843009213693952 > 10^(-8).
```

Take `epsilon=1/10000`. Outside the seven **true** contact windows

```
[-1,-1+epsilon] and [s_i-epsilon,s_i+epsilon], i=1,...,6,
```

we have `t+1>=epsilon` and `|t-s_i|>=epsilon`. Consequently

```
f(t)-h(t) >= f(t)-H(t)
 >= [binom(42,21)/2^64]*epsilon^(9+12)
 > 10^(-92).
```

This is a statement about the actual `s_i(r*)`, not about substituted
rational midpoint contacts or their slightly enlarged interval enclosures.
The checker verifies the exact constant comparison. The analytic Hermite
remainder argument is written here explicitly, rather than claimed as
an outcome of the arithmetic program alone.

## Certified Energy Upper Bound

Let `Phi(r)` be the six-term exact energy of the candidate family:

```
Phi(r)=2*sqrt(3)/r+3/[2*sqrt(1-r^2)]+6/sqrt(4-r^2)
       +sqrt(3)+6/sqrt(2+2*r)+12/sqrt(2-r).
```

The already proved family-minimum theorem gives
`E(P9)=Phi(r*)<=Phi(rMid)`. The checker encloses `Phi(rMid)` and verifies
the delivered rational `energy_upper=U` is above its upper endpoint,
with upward rounding error less than `10^(-130)`. In fact U was rounded
up on the `10^(-180)` grid. Thus `E(P9)<=U` without identifying a decimal
with the exact optimum. This U can be used as the raw energy level in the
near-sharp polynomial identity.

## API and Reproduction

`check_hermite.check(data)` recomputes everything and returns a dictionary
with these integration keys:

- `coefficients_monomial`: 21 rational strings, increasing powers;
- `energy_upper`: the checked rational U as a string;
- `radius_interval`, `radius_midpoint`: rational strings;
- `hermite_error_upper`: a checked uniform rational upper bound;
- `exterior_slack_lower`: the rational string for `10^(-92)`.

The detailed coefficient enclosures and endpoint derivative signs are
also returned. From `outputs/thomson-n9`:

```powershell
python near_sharp/generate_root.py
python near_sharp/generate_hermite.py
python near_sharp/check_hermite.py near_sharp/hermite.json --negative-control --output near_sharp/hermite.check.json
```

Only the first command uses mpmath, as a proposal generator. The exact
checker uses standard-library integer arithmetic, rational arithmetic,
and integer square roots. Its interval code is an independently scoped
1024-bit adaptation of this project's `certificates/check_local.py`; it
does not change that module's arithmetic precision or global state.

The checker rejected raising `h0` by `10^(-120)`, lowering U by
`10^(-120)`, translating the root bracket by `10^(-200)`, and running
under `python -O`. Certificate SHA256:

```
d894c078b67f70c552efdf9f8f82d2caad93ad5203d92bb9fc537905a8db91f8
```

The Hermite data alone do not prove the global Thomson theorem. The required
global polynomial/SOS energy identity is now provided by `near-sharp-d10.json`,
whose full exact energy loss is less than `10^-92`. The antipodal exclusion,
finite Gram-window rigidity, and local minimality results complete the proof,
as assembled in `../GLOBAL_PROOF.md`.
