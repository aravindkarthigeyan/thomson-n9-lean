# A Derivative-Free Local Energy Proof

This is an alternative proof of the same local theorem as `LOCAL_PROOF.md`.
It uses `certificates/ambient-dd-k10000.json`, checked exactly by
`certificates/check_ambient_dd.py`, and the elementary cubic minorant already
proved in `lean/ThomsonN9/LocalPotential.lean`. This positive-penalty certificate
is an alternative, not the selected Lean instantiation. The zero-penalty route
below is formalized through `Certificates/AmbientHessian.lean`,
`LocalCoercivity.lean`, and `LocalTarget.lean`; see `FORMAL_PROOF_GUIDE.md` and
`STATUS.md`. The earlier tangent/LDL proof remains a mathematical alternative.

Certificate SHA256:
`5783385547e2bab646a64863257f273cf57661445a98ac02c1b59f40f41ecbee`.
Replay from this project directory:

```text
python certificates/check_ambient_dd.py certificates/ambient-dd-k10000.json --negative-controls
```

## Exact Ambient Certificate

Let P be the exact candidate, d_ij=p_i-p_j, D_ij=|d_ij|, and

```
B_ij=3 d_ij d_ij^T/D_ij^5-I/D_ij^3,
lambda_i=-(1/2) sum_(j!=i) 1/D_ij.
```

The symmetric27x27 matrix H has diagonal blocks
`sum_(j!=i) B_ij-lambda_i I` and off-diagonal blocks `-B_ij`.
Let R have columns `(e_k cross p_i)_i`. Let N have one column for each i,
equal to p_i in block i and zero in all other blocks. Exact interval
arithmetic and a rational unit-upper congruence prove

```
H+R R^T+10000 N N^T >= (7/50)I27.                         (A)
```

The proof is strict diagonal dominance after congruence. The smallest
verified dominance margin is approximately0.05632640995; only exact rational
comparisons, not that decimal, are accepted. The generic congruence and
diagonal-dominance implication is already Lean checked. Candidate force
balance and its exact radial coefficient are also Lean checked in
`LocalStationarity.lean` and `LocalEnergy.lean`.

## Pointwise Potential Inequality

For -1<q<=1 set

```
P3(q)=1-q/2+3q^2/8-5q^3/16.
```

The identity

```
1-(1+q)P3(q)^2=q^4(140-56q+35q^2-25q^3)/256
```

and nonnegativity of the last factor give `P3(q)<=1/sqrt(1+q)`.
For |a|<=c<=1/200 and c>=0, exact polynomial inequalities then give

```
1-a-c^2/2+3a^2/2-(51/50)c^3 <= 1/sqrt(1+2a+c^2).
```

These two inequalities, including all interval hypotheses, are proved in
Lean. Applying them with `a=(d dot w)/|d|^2` and `c=|w|/|d|` proves

```
1/|d+w| >= 1/|d|-(d dot w)/|d|^3
  +(3(d dot w)^2-|d|^2|w|^2)/(2|d|^5)
  -(51/50)|w|^3/|d|^4.                                  (B)
```

This vector consequence is also Lean checked. It is not a truncated numerical
series or a remainder estimate assumed without proof.

## Alignment and Sphere Constraints

Choose an optimal orthogonal alignment, put b_i=x_i-p_i and
`rho^2=sum_i |b_i|^2`, and assume rho<=1/500. Compactness of O(3) gives an
attained optimum. Differentiating the squared alignment objective along
each one-parameter rotation gives `R^T b=0`.

Unit norms imply `p_i dot b_i=-|b_i|^2/2`, and hence

```
|N^T b|^2=(1/4) sum_i |b_i|^4 <= rho^4/4.
```

Applying (A) directly to b, without projecting onto a tangent space, yields

```
b^T H b >= (7/50)rho^2-2500rho^4.                       (C)
```

## Sum Over Pairs

Every candidate distance is greater than1. This follows directly from the
six distance formulas and 7/10<r<3/4. For w_ij=b_i-b_j,
`|w_ij|<=sqrt(2)rho<(3/2)rho`, so the hypothesis of (B) holds.

The complete-graph identity and the edgewise bound give

```
sum_(i<j)|w_ij|^3 <= (3/2)rho sum_(i<j)|w_ij|^2
  <= (27/2)rho^3.
```

This bound is already Lean checked in `LocalGeometry.lean`. The summed linear
term in (B) is `sum_i force_i dot b_i`; exact stationarity and the unit-norm
identity turn it into `-(1/2)sum_i lambda_i |b_i|^2`. The unordered-pair
counting and this correction are proved in `LocalEnergy.lean`. Consequently

```
E(X)-E(P) >= (1/2)b^T H b-(1377/100)rho^3.
```

Combining with (C),

```
E(X)-E(P) >= rho^2(7/100-(1377/100)rho-1250rho^2).
```

The parenthesis is decreasing for rho>=0. At rho=1/500 it is exactly
`1873/50000=0.03746>1/50`. Thus

```
rho<=1/500 ==> E(X)-E(P)>=rho^2/50.
```

This proves the same local implication needed by `GLOBAL_PROOF.md`. It avoids
formal third derivatives, an explicit tangent basis, rotational Hessian
zero-mode identities, and the operator-norm22 perturbation bound. The selected
zero-penalty route below now has a compiled concrete ambient interval trace,
actual matrix interpretation, optimal-alignment geometry, and assembled local
theorem. This does not assert that the K10000 alternative itself was instantiated.

## Further Simplification: Zero Normal Penalty

A later exact certificate proves the stronger ambient inequality

```
H+R R^T >= (7/50)I27.
```

Its input is `certificates/ambient-dd-k0.json`, SHA256
`ebe7f302de10f503adce62b92eb9f46cb3090c26684629629eff2dfa3bc957e3`.
The smallest exact diagonal-dominance margin is approximately 0.002748630762.
The same checker accepts it and rejects actual arithmetic mutations with
shifts0.145 and0.20, omitted RR^T, and a flipped Lagrange term. These are
genuinely false matrix inequalities, not just malformed metadata.

This removes N and the normal-component estimate from the local argument.
At optimal alignment `R^T b=0`, so directly `b^T H b>=(7/50)rho^2`. The
pairwise algebra and summed linear correction above are unchanged. Therefore

```
E(X)-E(P) >= rho^2(7/100-(1377/100)rho)
             >= (2123/50000)rho^2 > rho^2/50
```

for 0<rho<=1/500, with the non-strict bound also valid at rho=0.
The rational endpoint coefficient is0.04246. This is the selected, compiled
local formalization route. The K10000 proof is retained above as an independently
audited alternative; no old certificate was replaced.
