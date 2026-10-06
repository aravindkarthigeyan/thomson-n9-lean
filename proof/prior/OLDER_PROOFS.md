# Earlier rigorous Thomson proofs and reusable estimates

Sources were downloaded on 2026-10-05, including original TeX where available. This note records actual mathematical inputs inspected, not just abstracts. `N7_AUDIT.md` and the N8 audit cover the two recent Lean projects separately. All energies below count unordered pairs.

## Exact solved configurations

| N | Minimizer, unique up to orthogonal transformation and relabeling | Exact energy | Method and inspected source |
|---|---|---|---|
| 2 | Antipodal pair | `1/2` | Diameter bound; also simplex case of Cohn-Kumar |
| 3 | Great-circle equilateral triangle | `sqrt(3)` | Centroid/Jensen bound below; also simplex case of Cohn-Kumar in its linear span |
| 4 | Regular tetrahedron | `3 sqrt(3/2)` | Centroid/Jensen; Yudin Theorem 2; Cohn-Kumar Theorem 1.2 |
| 5 | Triangular bipyramid | `1/2+sqrt(3)+3sqrt(2)` | Schwartz Theorems 1.1 and 1.2, branch and bound plus positive local Hessian |
| 6 | Regular octahedron | `3/2+6sqrt(2)` | Yudin Theorem 3; Cohn-Kumar Theorem 1.2 |
| 12 | Regular icosahedron | `3+30/sqrt(2-2/sqrt(5))+30/sqrt(2+2/sqrt(5))` | Cohn-Kumar Theorem 1.2; earlier Andreev result located bibliographically |

For N=2,3,4 the elementary proof is particularly reusable. Write `M=N(N-1)/2` and `u_ij=x_i dot x_j`. The identity `sum_(i<j) u_ij=(|sum x_i|^2-N)/2` gives average inner product at least `-1/(N-1)`. Since `(2-2u)^(-1/2)` is strictly increasing and strictly convex,

\[
 E(X)\ge\binom N2\sqrt{\frac{N-1}{2N}}.
\]

Equality forces zero centroid and every off-diagonal inner product equal to `-1/(N-1)`. Equality of Gram matrices yields orthogonal congruence. These Gram matrices have rank `N-1`, so they are realizable in R3 precisely for these three cases. The same bound for N=9 is merely 24, and its equality matrix has rank 8. This demonstrates concretely why ignoring rank is expensive.

## Schwartz N5 source and algorithm

Paper: Richard Evan Schwartz, [The 5 Electron Case of Thomson's Problem](https://arxiv.org/abs/1001.3702), Experimental Mathematics 22 (2013), 157-186. Downloaded PDF: `work/prior/schwartz-1001.3702.pdf`; complete original TeX extracted to `work/prior/schwartz/`.

The [author's companion page](https://www.math.brown.edu/reschwar/Electron/index.html) identifies Electron Champ as the original proof program. Its downloaded archive `ELECTRON.tar` is extracted to `work/prior/Electron/`. The archive README is dated 10 January 2010. The later `TBP.tar`, downloaded from the author's publications page and extracted to `work/prior/TBP/`, has README dated 15 September 2026 and accompanies the seven-part "Divide and Conquer" monograph. These are distinct code packages. No license authorizing redistribution or adaptation was found in their inspected README files; source was retained locally for inspection and its algorithm rederived rather than copied into the N9 checker.

The stereographic map used by Schwartz is

\[
 \sigma^{-1}(x,y)=\frac{(2x,2y,x^2+y^2-1)}{1+x^2+y^2},
\]

with infinity mapping to the north pole. Its exact squared-distance formula is

\[
 |\sigma^{-1}(z)-\sigma^{-1}(w)|^2=
 \frac{4|z-w|^2}{(1+|z|^2)(1+|w|^2)},\qquad
 |\sigma^{-1}(z)-\sigma^{-1}(\infty)|^2=\frac4{1+|z|^2}.
\]

One point is fixed at infinity and another on the positive real axis, removing all three rotational degrees of freedom. Bounds from the tetrahedral four-point minimum confine possible N5 minimizers to a seven-dimensional box `[0,4] x [-2,2]^6`. Dyadic subdivision stores one segment and three squares. The search discards a box if it is inside the local neighborhood, redundant under a proved symmetry/relabeling rule, excluded by a four-point-deletion bound, or excluded by the energy estimator. Otherwise it subdivides the coordinate patch contributing most to the estimator's error.

Theorem 5.1 is explicitly stated for an arbitrary number of points, with one point at infinity. Its patches are dyadic objects: finite segments on the nonnegative real axis or axis-aligned squares that do not cross the coordinate axes. These patch restrictions must be preserved when adapting the estimate. For a block of patches `Q_i`, let `E_vertex` be the minimum energy over all choices of patch vertices. Let `delta_i=2s_i/(1+x_min_i^2+y_min_i^2)` for patch side `s_i`, and let `R_ij` be the lower separation of the convex spherical patches. For positive `R_ij` (otherwise the error bound is infinite),

\[
 \inf_{X\in\prod Q_i}E(X)\ge E_{\rm vertex}
 -\sum_{i\text{ finite}}\sum_{j\ne i}\epsilon_{ij}\delta_i^2.
\]

For Coulomb energy `epsilon=max(0,Lambda1)+Lambda2`. For a segment,
`Lambda1=1/(4R^3)-3/(32R)` and `Lambda2=1/(8R^2)`.
For a square,
`Lambda1=1/(2R^3)-3/(16R)` and
`Lambda2=(sqrt(1+x_max^2)+sqrt(1+y_max^2))/((399/50)R^2)`.
The decimal `7.98` in the source is thus an exact rational constant in the mathematical estimate. These inequalities, not raw interval evaluation of energy alone, recover a quadratic-in-side-length error and make the computation feasible.

The pair-separation bound uses patch centers at distance `D` and
`delta=(delta_i sqrt(dim Q_i)+delta_j sqrt(dim Q_j))/4`:

\[
 R_{ij}\ge D(1-\delta^2/2)-\sqrt{4-D^2}\,\delta,
\quad
 d_{ij}^{\max}\le D+\sqrt{4-D^2}\,\delta.
\]

The full N9 normalization would have dimension 15 and `2*4^7=32768` vertex configurations per box. The energy estimator transfers, but the N5 domain bounds, redundancy rules, and manageable box count do not transfer automatically. A useful hybrid should first shrink the domain using SDP and apply this estimator only to the residual regions.

The confinement computation is combined with a local Hessian certificate: at the triangular bipyramid an exact LDL decomposition proves `H-(1/10)I` positive definite; third-derivative bounds control Hessian variation throughout the local box. `9energy.tex` contains the formulas and `Electron/Math1/` the Mathematica calculations. The present N9 local argument adopts the mathematical pattern with new formulas and exact integer interval arithmetic.

| Original source file | Inspected role |
|---|---|
| `Proof.java` | Search loop; chooses floating prefilters, then confirms each elimination by the interval counterpart |
| `IntervalEnergyEstimator.java` | Minimum of 128 vertex-energy lower endpoints, minus the interval error; elimination only if lower bound exceeds target upper bound |
| `IntervalSeparation.java`, `IntervalStereo.java` | Separation and stereographic interval computations |
| `IntervalTetrahedralEliminator.java` | Four-point lower bound plus deleted point's interactions |
| `IntervalRedundancyEliminator.java` | Symmetry exclusions |
| `Interval.java` | Outward-rounded arithmetic based on adjacent IEEE-754 doubles |
| `Math1/cholesky`, `Math1/variation_bound` | Exact symbolic local calculations |

This session inspected the mathematical estimator and implementation, but did not run the six-hour original N5 confinement computation or compile its legacy Java GUI. It is a rigorous computer-assisted proof in the literature, not a Lean formalization.

## Cohn-Kumar and the two-point bound

Paper: Henry Cohn and Abhinav Kumar, [Universally optimal distribution of points on spheres](https://arxiv.org/abs/math/0607446), JAMS 20 (2007), 99-148. Original TeX: `work/prior/cohn-kumar/potential.tex`. Inspected in particular Theorem 1.2, Proposition 4.1, Sections 2, 5, 6, and Appendix A.

For unit vectors in R3, let `P_k` be the Legendre polynomials normalized by `P_k(1)=1`. If `h(t)=sum_(k=0)^d a_k P_k(t)` satisfies `h(t)<=f(t)=(2-2t)^(-1/2)` for `-1<=t<1` and `a_k>=0` for `k>0`, Schoenberg positivity yields

\[
 E(X)\ge\frac{N^2a_0-Nh(1)}2.
\]

The paper counts ordered pairs; this formula has explicitly divided its bound by two. Equality requires BOTH `h(u_ij)=f(u_ij)` at every realized off-diagonal inner product and `sum_ij P_k(u_ij)=0` whenever `a_k>0`. Vanishing pairwise polynomial slack alone does not establish equality or rigidity.

The tetrahedron has one inner product and is a spherical 2-design; the octahedron has two and is a 3-design; the icosahedron has three and is a 5-design. Hence all are sharp in the paper's sense: at least a `(2m-1)`-design with `m` distinct inner products. Hermite interpolation of the absolutely monotonic function `f` at those inner products gives a minorant; the remainder is a positive derivative times a product of squares. The main additional argument proves nonnegative Gegenbauer coefficients. Strict complete monotonicity and the equality conditions reduce uniqueness to the respective Gram/spherical-code classifications. The Coulomb function as a function of squared distance is `s^(-1/2)`, whose alternating derivatives are all strictly positive, so it meets the theorem's hypotheses.

Yudin's [original 1992 paper](https://www.mathnet.ru/eng/dm737) was downloaded and its full seven-page text inspected. Theorem 1 already proves the weighted energy LP bound. Theorems 2 and 3 give the simplex and cross-polytope harmonic-energy optima. The cross-polytope minorant for R3 can be written directly as

\[
 h(t)=\frac1{\sqrt2}+\frac{t}{2\sqrt2}
 +\left(\frac12-\frac1{2\sqrt2}\right)t^2.
\]

It agrees with `f` at -1 and agrees with both `f,f'` at 0. The Hermite remainder has factor `(t+1)t^2` and positive third derivative, so `h<=f`. Its three Legendre coefficients are positive. This proves the exact N6 minimum and, at N9, gives the valid but nonsharp bound `9/2+117/(4sqrt(2))=25.1828733497...`.

Andreev's "An extremal property of the icosahedron", East J. Approx. 2 (1996), 459-462, is identified in Cohn-Kumar's actual reference list and the author's publication record. A full original copy was not obtained in this session. Its proof is not claimed to have been independently ingested; the N12 conclusion here relies on the downloaded complete Cohn-Kumar proof.

## Concrete obstructions for the N9 LP route

For the reconstructed N9 family, put `S_k=sum_ij P_k(p_i dot p_j)`, including the diagonal. Direct tensor-moment calculations give

\[
 S_1=0,\qquad S_2=81(h^2-1/2)^2,
 \qquad S_3=\frac{45}{8}(2r^3-1)^2.
\]

For `S_2`, use `sum_i p_i p_i^T=diag(3r^2+3/2,3r^2+3/2,6h^2)` and `P_2(t)=(3t^2-1)/2`. For `S_3`, the third moment has planar components `T_xxx=-T_xyy=3(2r^3-1)/4`, their permutations, and all other components zero; combine its squared tensor norm with `P_3(t)=(5t^3-3t)/2`.

Both expressions are strictly positive on the certified candidate interval. Thus a sharp ordinary two-point LP at this candidate MUST have `a_2=a_3=0`. This does not rule out every possible higher-degree LP; it rules out blindly transplanting the standard positive-coefficient sharp-design interpolant. There are six distinct interior inner products, so touching all of them requires six tangencies. A polynomial minorant of degree at most 10 cannot do this by Rolle's theorem and strict positivity of the eleventh derivative of `f`. These are exact obstructions to low-degree sharpness, not just solver failures.

## Deletion identities and their actual strength

If every k-point configuration has energy at least `L_k`, double counting pairs among all k-subsets gives

\[
 \binom{7}{k-2}E(X)=\sum_{|S|=k}E(X_S)
 \ge\binom9k L_k,
 \qquad E(X)\ge\frac{72}{k(k-1)}L_k.
\]

| k | Resulting N9 bound, diagnostic decimal |
|---|---:|
| 4 | 22.0454076850 |
| 5 | 23.3088893809 |
| 6 | 23.9646752982 |
| 7 | 24.7765327101 |
| 8 | 25.2967986787 |

The k=7,8 numbers use the candidate energies whose rigorous proofs are audited separately, rather than treating tabulated decimals as exact constants. Even the best deletion bound leaves about 0.46319 to the N9 candidate.

For an assumed competitor with `E(X)<=U`, each star `s_i=sum_(j!=i) 1/d_ij` obeys `s_i<=U-L_8`. This gives a real geometric exclusion: `1/d_ij<=U-L_8-7/2`, since the other seven star terms are at least 1/2. The identity `sum_i(E(X\{i})-L_8)=7E(X)-9L_8` shows why near-optimality of N9 does not force all eight-point subsets to be nearly optimal: at the N9 candidate this nonnegative total is approximately 3.242315. A strengthened deletion proof must quantify incompatibility among overlapping subsets; simply averaging uniqueness of the N8 optimum does not provide it.

## Frozen download hashes

All SHA256 values refer to the retained bytes under `work/prior/`.

| File | SHA256 |
|---|---|
| `schwartz-1001.3702.pdf` | `8e2118c1f2b4161a24fc442c493a8a282527f879cbdf91fc6e9d527be4afdafc` |
| `schwartz-1001.3702-source.tar` | `1076f87fd3670ab5e9f9d56f468edf63150267673ac91dcaf90d39982b165870` |
| `cohn-kumar-math0607446.pdf` | `b0d9edd5fe997faecee9d6624ed278e01efaafa51314f2d20419ca03bc27f289` |
| `cohn-kumar-math0607446-source.tar` | `d1fc994711879356742888c8dabf0777aca58e1f723a5c31c0394752fced0d13` |
| `yudin-1992-dm737.pdf` | `9ada4bcdc614644603b56b9271776446a749f36867b2a1b2e491243fc56ab485` |
| `ELECTRON.tar` | `36b2ab122a49d28247a2f38c2e846c700ca914e7f4270dd1283de9598170a1bb` |
| `TBP.tar` | `7ca9d66d94b034e467ce5182d4a91df9e843d62ba1664bf70c2691f330785953` |

Archive URLs: `https://arxiv.org/src/1001.3702`, `https://arxiv.org/src/math/0607446`, `https://www.math.brown.edu/reschwar/Electron/ELECTRON.tar`, and `https://www.math.brown.edu/reschwar/Papers/TBP.tar`. No repository commits or Lean versions apply to these original paper and Java artifacts.
