# Ambient 27-Dimensional Hessian Certificate

This separate certificate avoids tangent-frame coordinates and avoids proving
that the infinitesimal rotations are exact Hessian zero modes. The original
18-dimensional tangent certificate, its local radius, and its rigidity window
remain unchanged.

## Hessian and Sign Conventions

Points are ordered as in `check_local.py`: three upper prism vertices, three
lower prism vertices, then three caps. Ambient coordinates have index `3*i+a`
for point `i=0,...,8` and Cartesian coordinate `a=0,1,2`.

The energy counts each unordered pair once. For `d_ij=p_i-p_j` and
`rho_ij=norm(d_ij)`, define

\[
K_{ij}=\frac{3d_{ij}d_{ij}^{\mathsf T}}{\rho_{ij}^5}
       -\frac{I_3}{\rho_{ij}^3}.
\]

The ambient Hessian `D^2 E` has diagonal block `sum_(j!=i) K_ij` and
off-diagonal block `-K_ij`. The radial gradient multiplier is

\[
\lambda_i=p_i\mathbin\cdot\nabla_iE
=-\sum_{j\ne i}\frac1{2\rho_{ij}}.
\]

The constrained ambient quadratic form used here is

\[
H_c=D^2E-\operatorname{blockdiag}(\lambda_i I_3).
\]

In particular, the implementation **adds** `sum 1/(2 rho_ij)` to the ambient
diagonal. Reversing this sign would be a different and incorrect quadratic
form for the sphere-constrained second variation.

Let `R` be the `27 x 3` matrix with columns of infinitesimal rotations:

\[
R_{3i+a,k}=(e_k\times p_i)_a.
\]

Let `N` be the `27 x 9` matrix whose column `i` is `p_i` in its own point block
and zero elsewhere. Thus `N N^T=blockdiag(p_i p_i^T)`. The checked matrix is

\[
A=H_c+RR^{\mathsf T}+10^6 NN^{\mathsf T}-\frac7{50}I_{27}.
\]

## Exact Positivity Check

`certificates/ambient-dd.json` supplies a rational unit upper triangular matrix
`C`. The standard-library-only `check_ambient_dd.py` reconstructs the ambient
Hessian over the entire certified rational parameter interval, adds the two
augmentations, subtracts `7/50 I`, and encloses every entry of `C^T A C` by exact
integer dyadic interval arithmetic. It does not call any tangent-frame,
numerical eigenvalue, or LDL calculation.

Every row is strictly diagonally dominant with positive diagonal. The smallest
exact margin is approximately `0.0563395944525465`. The report also verifies
the coarser, simple enclosures

\[
B_{ii}\in[1/20,2000000],\qquad
B_{ij}\in[-1/100000,1/100000]\quad(i\ne j).
\]

The exact coarse row check is `26/100000 < 1/20`. Since `C` is invertible, these
checks establish `A` positive definite, hence the required augmented Hessian
lower bound. The decimal margin is diagnostic, not an input to any check.

The discovery script `generate_ambient_dd.py` uses high-precision Cholesky to
find `C` and then rounds it to rationals. None of that numerical discovery is
trusted by the checker.

## Restricting to the Needed Tangent Directions

Let `v=(v_i)` satisfy `p_i dot v_i=0` for every point, and be orthogonal to every
rotation column. These are precisely

\[
N^{\mathsf T}v=0,\qquad R^{\mathsf T}v=0.
\]

Both augmentation matrices annihilate `v`. The checked positive inequality
therefore gives

\[
v^{\mathsf T}H_cv\ge\frac7{50}\|v\|^2.
\]

No assertion `H_c R=0` is used. Full stationarity is still needed separately
for the local energy expansion and first-order cancellation, exactly as in
`LOCAL_PROOF.md`; this certificate does not bypass that requirement.

## Replay and Negative Controls

```powershell
python certificates/check_ambient_dd.py --negative-controls --report certificates/ambient-dd.check.json
```

The exact run passed, including all 729 entry enclosures and all 27 row checks.
The current checker rejects six controls: a zero diagonal in `C`, an upper
coefficient changed to one million, false Hessian shifts `0.145` and `0.20`, an
omitted rotational augmentation, and a reversed Lagrange-multiplier sign.
The latter four must fail an actual diagonal-dominance arithmetic test, not
only a metadata check. An earlier normal-penalty mutation was rejected merely
by a whitelist; that test was removed rather than counted as arithmetic
falsification. The certificate pins the original `local.json` SHA256. Its own
SHA256 is

```text
768bf0d7901d683e510113aeb3b402a75abb6ca3e3cfafaa82ee6bdf643899be
```

`verification/audit_ambient_dd.py` additionally compares the independent ambient
formula, pulled back through the original tangent frames, against every entry
of the original tangent Hessian. All 324 residual intervals contain zero, with
absolute widths bounded by approximately `8.11e-39`. All 27 point-coordinate
intervals are identical. This is a strong sign/convention cross-check, not a
replacement for the exact block-matrix identity in the proof above.

The Lean interval/DD/congruence soundness bridge, ambient 27-dimensional
specialization, augmentation-annihilation theorem, and normal-column block
identities all built successfully. Actual names and twelve axiom audits are
listed in `verification/LEAN_LOCAL_DD.md`; every printed closure contains only
`propext`, `Classical.choice`, and `Quot.sound`. The actual candidate ambient
Hessian formula and its interval-entry evaluation still require a Lean
connection before this becomes a complete formal local Hessian theorem.

## Smaller Penalty and Direct Chord Argument

A separate preserved certificate `ambient-dd-k10000.json` replaces `10^6` by
`K=10000`. Exact replay passed with all the same coarse entry bounds and a
minimum sharp DD margin of approximately `0.05632640995492613`. Its SHA256 is

```text
5783385547e2bab646a64863257f273cf57661445a98ac02c1b59f40f41ecbee
```

```powershell
python certificates/check_ambient_dd.py certificates/ambient-dd-k10000.json --negative-controls --report certificates/ambient-dd-k10000.check.json
```

This smaller penalty permits using the aligned displacement `b=x-p` directly.
Optimal orthogonal alignment gives `R^T b=0`. Because both endpoints of every
point displacement are unit vectors,

\[
(N^{\mathsf T}b)_i=p_i\cdot b_i=-\frac{\|b_i\|^2}{2}.
\]

Writing `rho^2=sum_i norm(b_i)^2`, the certificate therefore gives

\[
b^{\mathsf T}H_cb\ge\frac7{50}\rho^2-
 \frac{10000}{4}\sum_i\|b_i\|^4
\ge\frac7{50}\rho^2-2500\rho^4.
\]

The proved pair-potential estimate in `LocalPotential.lean` has remainder
`51/50 * norm(b_i-b_j)^3 / norm(p_i-p_j)^4`. Candidate distances exceed one;
`LocalGeometry.displacement_pair_cubic_sum` bounds its sum by
`(51/50)*(27/2)*rho^3 = 1377/100 * rho^3`. The first-order sum is converted into
the radial quadratic correction by `LocalEnergy.lean`. Combining these facts
mathematically gives

\[
E(p+b)-E(p)\ge
\rho^2\left(\frac7{100}-\frac{1377}{100}\rho-1250\rho^2\right)
\ge\frac{1873}{50000}\rho^2>\frac1{50}\rho^2
\]

for `0 < rho <= 1/500`. The bracket is decreasing for nonnegative `rho` and its
value at `1/500` is exactly `1873/50000`. This route removes the tangent
projection, operator-norm bound 22, and tangent-replacement loss from the final
local energy argument. It still needs full stationarity for linear
cancellation and the same alignment hypothesis. No original local certificate
or proof is erased by this alternative.

The generic Lean normal-penalty quadratic lemma is currently preserved as a
draft under `work/n9-lean-drafts/ThomsonN9/Certificates/NormalPenalty.lean`, not
claimed built. The
already-built augmentation-kernel lemmas remain available in the delivered
package.

## Zero Penalty: Simplest Local Route

Following an independent numerical suggestion from Claude, a third exact
certificate `ambient-dd-k0.json` removes the normal penalty entirely. It proves

\[
H_c+RR^{\mathsf T}-\frac7{50}I_{27}\succ0.
\]

Exact interval replay passed. The minimum DD margin is approximately
`0.002748630762078727`, and coarse diagonal intervals `[1/1000,100]` together
with off-diagonal intervals `[-1/100000,1/100000]` suffice, since
`26/100000 < 1/1000`. The certificate SHA256 is

```text
ebe7f302de10f503adce62b92eb9f46cb3090c26684629629eff2dfa3bc957e3
```

```powershell
python certificates/check_ambient_dd.py certificates/ambient-dd-k0.json --negative-controls --report certificates/ambient-dd-k0.check.json
```

The false shifts `0.145` and `0.20` failed the row arithmetic at rows 22 and 19,
respectively. Removing `RR^T` and reversing the Lagrange sign each failed at row
zero. The nonunit and large-coefficient controls also failed as intended.

For an aligned chord `b`, only `R^T b=0` is now needed. The certificate directly
implies `b^T H_c b >= (7/50)*rho^2`. Together with stationarity and the algebraic
pair remainder above,

\[
E(p+b)-E(p)\ge\rho^2\left(\frac7{100}-\frac{1377}{100}\rho\right)
\ge\frac{2123}{50000}\rho^2>\frac1{50}\rho^2
\]

for `0 < rho <= 1/500`. This eliminates all tangent projection, normal matrix,
operator-norm, and quartic-loss steps from this alternative local proof.
The positive-penalty certificates are retained as independent backups.

The delivered `lean/ThomsonN9/Certificates/ZeroPenalty.lean` contains the
compiled specialized row-check and rotation-orthogonality lemmas.
`Certificates/AmbientHessian.lean` supplies the compiled actual candidate
matrix endpoint, including the interval trace, congruence products, and all
729 final entry enclosures. See `FORMAL_PROOF_GUIDE.md` for the selected local
argument and `STATUS.md` for release verification. The positive-penalty
alternatives remain separately identified above.
