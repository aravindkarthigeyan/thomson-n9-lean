# Quantitative local optimality and Gram rigidity

This is the original tangent-Hessian mathematical proof with an exact integer-arithmetic computation. The computation is `certificates/check_local.py`, its input is `certificates/local.json`, and its full rational report is `results/local-check.json`. No floating-point computation is used to accept the certificate. This particular checker and analytic route are not claimed as Lean-verified. The selected 27-dimensional zero-penalty/algebraic local proof has compiled; see `LOCAL_ALGEBRAIC_PROOF.md` and `FORMAL_PROOF_GUIDE.md`. Release verification is tracked in `STATUS.md`.

## Candidate and stationarity

Put `u_k=(cos(2*pi*k/3),sin(2*pi*k/3))`, `h=sqrt(1-r^2)`, and

\[
 p_{k,+}=(r u_k,h),\qquad p_{k,-}=(r u_k,-h),\qquad q_k=(-u_k,0),\quad k=0,1,2.
\]

The unordered-pair Coulomb energy is

\[
 F(r)=\frac{2\sqrt3}{r}+\frac3{2\sqrt{1-r^2}}+
 \frac6{\sqrt{4-r^2}}+\sqrt3+
 \frac6{\sqrt{2+2r}}+\frac{12}{\sqrt{2-r}},\qquad 0<r<1.
\]

The six summands count, respectively, 6, 3, 6, 3, 6, and 12 pairs. In particular, no ordered/unordered factor of two is implicit. Direct differentiation gives

\[
 F'(r)=-\frac{2\sqrt3}{r^2}+
 \frac{3r}{2(1-r^2)^{3/2}}+\frac{6r}{(4-r^2)^{3/2}}-
 \frac6{(2+2r)^{3/2}}+\frac6{(2-r)^{3/2}},
\]

\[
 F''(r)=\frac{4\sqrt3}{r^3}+
 \frac{3(1+2r^2)}{2(1-r^2)^{5/2}}+
 \frac{6(4+2r^2)}{(4-r^2)^{5/2}}+
 \frac{18}{(2+2r)^{5/2}}+\frac9{(2-r)^{5/2}}>0.
\]

The limits of `F'` at 0 and 1 are respectively negative and positive infinity. Thus there is exactly one root `r_*` in `(0,1)`. It is the unique minimizer of this family. The exact derivative-sign checks at the two rational endpoints in `local.json` independently isolate that root; the radius is approximately `0.71054833409295381132770417927279`.

Family stationarity implies full constrained stationarity here, for the following reason. Coulomb energy is invariant under all orthogonal transformations and permutations. At this configuration its tangent gradient must therefore be fixed by the configuration's `D_3h` action. Each cap is fixed by both its vertical mirror plane and horizontal reflection. Those two symmetries negate, respectively, its azimuthal and vertical tangent directions, so the tangent gradient at every cap is zero. Each prism vertex is fixed by its vertical mirror plane, so its azimuthal gradient vanishes. The six prism vertices form one orbit, so their remaining meridional tangent components form a one-dimensional invariant space.

More explicitly, use unit meridional vectors `(h u_k,-r)` upstairs and `(-h u_k,-r)` downstairs. If the upstairs coefficient is `a`, horizontal reflection gives downstairs coefficient `-a`. The family derivatives are `1/h` times the upstairs vector and `-1/h` times the downstairs vector. Consequently `F'(r)=6a/h`. At `r_*`, all these coefficients vanish. This proves the full stationarity needed below; it is not inferred merely from numerical optimizer residuals.

## What the exact checker establishes

All interval endpoints in the checker are integers divided by `2^180`. Integer division uses floor and ceiling in the appropriate directions, and square-root endpoints use `isqrt` with an explicit upward correction. Thus arithmetic operations enclose their exact real counterparts. Interval multiplication is permitted to overestimate repeated occurrences of the same variable; that affects sharpness, not validity.

For any radius in the certified rational interval, the checker constructs the nine points and explicit orthonormal tangent frames. The frames are

\[
 (-s,c,0),\ (z c,z s,-r)\quad\text{at }(rc,rs,z),
\]

where `z=+h` or `-h`, and `(s,-c,0),(0,0,-1)` at each cap `(-c,-s,0)`. Let `T` be the resulting `27 by 18` block matrix. These vectors are orthonormal and perpendicular to their point by `c^2+s^2=1` and `r^2+h^2=1`: for a prism vertex, the meridional point-frame dot product is `rz(c^2+s^2)-rz=0`, its squared norm is `z^2(c^2+s^2)+r^2=1`, and its dot product with the azimuthal vector is `z(-sc+cs)=0`. The azimuthal and cap identities follow directly from the same formulas.

The checker additionally verifies that its interval point norms enclose 1, point-frame dot products enclose 0, and each frame Gram matrix encloses the 2-by-2 identity. These are implementation sanity checks, not proofs of exact equality: an interval containing zero alone does not imply that the enclosed expression is identically zero. The displayed algebraic identities supply that mathematical fact. The checks reject the M8 mutation that replaces the meridional coordinate `-r` by `+r` while leaving its other coordinates unchanged.

Writing `d_ij=|p_i-p_j|`, each pair contributes the ambient Hessian block

\[
 B_{ij}=3(p_i-p_j)(p_i-p_j)^T/d_{ij}^5-I_3/d_{ij}^3
\]

on both diagonal blocks and `-B_ij` on both off-diagonal blocks. At stationarity the radial gradient coefficient is

\[
 \lambda_i=p_i\cdot\nabla_i E(P)=-\frac12\sum_{j\ne i}d_{ij}^{-1}.
\]

Set `H_c=D^2E(P)-diag(lambda_i I_3)` and `H_t=T^T H_c T`. Let `R` be the `18 by 3` matrix whose `k`th column is `T^T (e_k cross p_i)_i`. The checker uses exactly these formulas, not finite differences. It proves

\[
 A=H_t+RR^T\succeq \frac7{50}I_{18}.
\]

The proof certificate is the positivity of all interval-enclosed pivots in an LDL decomposition of `A-(7/50)I`. The exact matrix is symmetric by its displayed formula. By induction, interval LDL calculations enclose its exact LDL pivots, every pivot is strictly positive, and the real matrix is positive definite. Hence the displayed non-strict inequality follows. The report records all 18 pivot enclosures.

The rotational columns have rank 3 because the candidate spans `R^3`; invariance of energy at a stationary point gives `H_t R=0`. For every tangent vector orthogonal to rotations, the augmented term vanishes, so

\[
 v^T H_t v\ge (7/50)|v|^2\quad\text{if }R^Tv=0.
\]

This establishes precisely three zero modes and positivity of every other constrained mode. It does not by itself establish global optimality.

## An explicit local energy inequality

For a labeled sphere configuration `X`, define the rotation/reflection distance

\[
 \rho(X,P)=\min_{Q\in O(3)}\left(\sum_i|x_i-Qp_i|^2\right)^{1/2}.
\]

The minimum exists by compactness. The following bound holds:

\[
 0\le\rho(X,P)\le1/500
 \quad\Longrightarrow\quad
 E(X)-E(P)\ge\frac1{50}\rho(X,P)^2. \tag{L}
\]

To prove it, align by a minimizing orthogonal transformation and put `b_i=x_i-p_i`, `rho=|b|`. First-order optimality of this alignment gives
`sum_i b_i dot (omega cross p_i)=0` for every `omega`. Sphere constraints give `p_i dot b_i=-|b_i|^2/2`. The pointwise tangent projection

\[
 t_i=b_i+\tfrac12|b_i|^2p_i
\]

is consequently orthogonal to the three rotational directions. Moreover

\[
 |t|^2=\rho^2-\tfrac14\sum_i|b_i|^4\ge\rho^2-\rho^4/4,
 \qquad |b-t|\le\rho^2/2.
\]

The checker proves every candidate distance exceeds 1, with enough margin that subtracting `(3/2)/500` still leaves at least 1. Since `|b_i-b_j|<=sqrt(2) rho<(3/2)rho`, every distance along the ambient segment `P+s b`, `0<=s<=1`, remains at least 1.

For `g(y)=1/|y|`,

\[
 D^3g(y)[w,w,w]=9(y\cdot w)|w|^2/|y|^5-
 15(y\cdot w)^3/|y|^7,
\]

Writing `c=(y dot w)/(|y||w|)` when `w!=0`, the remaining scalar factor is `9c-15c^3`. On `[-1,1]` its absolute value is at most 6: indeed

```
6 +/- (15c^3-9c) = 3*(1 +/- c)*(5c^2 -/+ 5c + 2),
5c^2 -/+ 5c + 2 = 5*(c -/+ 1/2)^2 + 3/4 > 0.
```

Thus `|D^3g(y)[w,w,w]|<=6|w|^3/|y|^4`. For the edge displacements,

```
sum_(i<j) |b_i-b_j|^3
 <= max_(i<j)|b_i-b_j| * sum_(i<j)|b_i-b_j|^2
 <= sqrt(2)*rho * (9*rho^2-|sum_i b_i|^2)
 <= 9*sqrt(2)*rho^3 < (27/2)*rho^3.
```

The factor 1/6 in Taylor's remainder cancels the third-derivative bound 6, so `|R_3|<=(27/2)rho^3`. This uses the sum of edge cubes, not 36 times its worst individual value.

Also `||B_ij||op<=2` and `|lambda_i|<=4`. The identity
`sum_(i<j)|v_i-v_j|^2=9 sum_i|v_i|^2-|sum_i v_i|^2`
shows `||D^2E(P)||op<=18`, hence `||H_c||op<=22`. Full stationarity and the sphere identity turn the linear Taylor term into the Lagrange correction exactly:

\[
 E(X)-E(P)=\tfrac12 b^T H_c b+R_3.
\]

Since `|b-t|<=rho^2/2` and `|t|<=rho`, replacing `b` by `t` costs at most `11rho^3+(11/4)rho^4` in this half-quadratic form. The tangent Hessian bound now gives

\[
 E(X)-E(P)\ge\frac7{100}\rho^2-\frac{49}{2}\rho^3-
 \left(\frac7{400}+\frac{11}{4}\right)\rho^4
 =\frac7{100}\rho^2-\frac{49}{2}\rho^3-\frac{1107}{400}\rho^4.
\]

The coefficient `7/100-(49/2)rho-(1107/400)rho^2` is decreasing for `rho>=0`, since its derivative is `-49/2-(1107/200)rho<0`. Therefore, for `rho<=1/500`, checking the endpoint suffices: the coefficient is at least `0.02098893>1/50`. The checker verifies this final rational comparison. This proves (L), including strictness whenever `rho>0`.

## Quantitative Gram rigidity

The following matrix lemma is independent of the energy. Regard `P,X` as `3 by 9` matrices whose columns are the points. Suppose `M=PP^T>=2I`, and set `Delta=X^TX-P^TP`, `delta=||Delta||F<=1`. Then

\[
 \min_{Q\in O(3)}||X-QP||_F\le2\delta. \tag{G}
\]

Proof: let `Pi=P^T M^-1 P`, `A=XP^T M^-1`, `Z=X(I-Pi)`. Then `Pi` is an orthogonal projection, `X=AP+Z`, and `ZP^T=0`. Direct calculation gives

\[
 A^TA-I=M^{-1}P\Delta P^TM^{-1},\qquad
 A^TZ=M^{-1}P\Delta(I-\Pi).
\]

Since `||M^-1 P||op<=1/sqrt(2)`, the first identity implies
`||A^TA-I||op<=delta/2` and `sigma_min(A)>=sqrt(1-delta/2)>0`. Its polar factor `Q` is orthogonal. The singular-value identity
`|sigma-1|=|sigma^2-1|/(sigma+1)` gives `||A-Q||op<=delta/2`.
The second identity gives
`||Z||F<=delta/sqrt(2-delta)<=delta`.
Because `||P||F=3` and the two summands `(A-Q)P` and `Z` are Frobenius-orthogonal,

\[
 ||X-QP||_F^2=||(A-Q)P||_F^2+||Z||_F^2
 \le\tfrac94\delta^2+\delta^2<4\delta^2.
\]

For the candidate, `PP^T=diag(3r_*^2+3/2,3r_*^2+3/2,6(1-r_*^2))`. The checker explicitly requires the entire certified root interval to lie inside `(7/10,18/25)`, on which all three diagonal values exceed 2. Thus (G) applies.

Consequently, if a relabeling satisfies

\[
 \max_{i,j}|x_i\cdot x_j-p_i\cdot p_j|\le1/10000, \tag{C}
\]

then `delta<=9/10000`, `rho<=18/10000=0.0018`, and (L) applies. Within this explicitly defined Gram neighborhood the candidate is the unique energy minimizer up to orthogonal transformation and permutation. Furthermore, if `E(X)<=E(P)+eta` in that neighborhood, (L) gives `rho<=sqrt(50eta)`.

## Global Implication

Every distinct nine-point sphere configuration with `E(X)<=E(P)` admits a permutation satisfying (C), by the exact Hermite/SOS localization and finite Gram-window classification assembled in `GLOBAL_PROOF.md`. Local inequality (L) then forces `rho=0`, giving both the global lower bound and its equality case. The local certificate alone does not prove that global hypothesis; the separate complete chain supplies it.

## Audit and reproduction

Run `python certificates/check_local.py --negative-controls --report results/local-check.json` from this output directory using ordinary Python without `-O`. The checker accepts the genuine data and rejects a false Hessian lower bound, a displaced root interval, an interval outside the Gram-rigidity radius bounds, and the M8 tangent-frame sign mutation. Numerical generation is separate in `generate_local.py`; importing the checker does not import any numerical solver.

The checker was inspected independently for pair counting, Hessian signs, tangent-frame orientation, rotational augmentation, outward rounding, and the local Taylor constants. Python integer arithmetic and the written analytic bridges remain in the trust base of this historical alternative. The selected compiled Lean proof instead uses the actual ambient matrix certificate, algebraic pair-potential bound, and checked alignment described in `FORMAL_PROOF_GUIDE.md`. It does not import this document, the Python result, or the original Taylor/polar argument as an axiom.
