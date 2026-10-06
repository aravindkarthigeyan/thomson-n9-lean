# Exact and quantitative Gram-pattern rigidity

These are mathematical proofs with reproducible exact finite checks. The
checkers use only Python's standard-library integers and `Fraction`; they are
not Lean proofs. This component does not by itself prove that an arbitrary
low-energy configuration has the spectrum-window property assumed below.
That implication is supplied by the separate Hermite/SOS certificate in
`../GLOBAL_PROOF.md`.

## Palette and exact theorem

Let `I=[L,U]` be the width-`10^(-40)` candidate-radius interval already proved
inhabited in Lean, where

```text
L = 7105483340929538113277041792727912437680 / 10^40
U = 7105483340929538113277041792727912437681 / 10^40.
```

For `r in I`, give the following six values the indicated color indices:

| Color | Inner product `s_c(r)` | Candidate pair type |
| --- | --- | --- |
| 0 | `-1/2` | two caps |
| 1 | `-r` | cap and opposite-azimuth prism vertex |
| 2 | `r/2` | cap and other prism vertex |
| 3 | `2*r^2-1` | vertical prism pair |
| 4 | `1-3*r^2/2` | same-level prism pair |
| 5 | `r^2/2-1` | different-level, different-azimuth prism pair |

The checker proves these values are distinct and strictly between `-1` and
`1/2` throughout `I`. The palette is denoted `S(r)`.

**Exact rigidity theorem.** For every `r in I`, any nine distinct unit vectors
whose 36 distinct-pair inner products belong to `S(r)` are congruent, up to
orthogonal transformation and permutation, to `candidateAt(r)`.

There is no energy hypothesis in this theorem. To exclude span dimension at
most 2, first note that a one-dimensional subspace contains at most two unit
vectors. In dimension 2 the nine points lie on a unit great circle. One cyclic
angular gap is at most `2*pi/9 < pi/3`, so its endpoints have inner product
greater than `1/2`. This contradicts the palette bound. Consequently some three
points are linearly independent.

## Three-anchor reduction

Choose an independent anchor triple. Its Gram matrix `A` is positive definite.
Let `B=2*A`; its diagonal entries are 2 and its three off-diagonal entries are
chosen from the integer-polynomial palette

```text
-1, -2*r, r, 4*r^2-2, 2-3*r^2, r^2-2.
```

Every permutation of the three edges of a triangle is induced by a permutation
of its vertices. Thus its three color indices may be sorted. There are exactly
`C(6+3-1,3)=56` anchor color multisets. The exact checker also explicitly
verifies the six induced edge permutations.

For an additional point `x`, let `v` be its three **doubled** inner products
with the anchors. There are `6^3=216` possible color triples. Since the anchors
span R^3, `v` determines the point uniquely. Writing `D=det B`, unit norm is
equivalent to

\[
 v^T\operatorname{adj}(B)v-2D=0. \tag{1}
\]

Indeed, with ordinary anchor-product vector `v/2`, its squared norm is
`(v/2)^T A^(-1)(v/2)=v^T adj(B)v/(2D)`. This also checks the factor of two in
the normalization.

For two extensions with doubled vectors `v,w`, their inner product equals
`s_c(r)` exactly when

\[
 v^T\operatorname{adj}(B)w-(2s_c(r))D=0. \tag{2}
\]

Both residuals are integer polynomials in `r` of degree at most 8. For every
tested polynomial, the checker either verifies that every coefficient is zero,
or obtains a strictly positive or strictly negative rational enclosure on all
of `I`. A nonzero polynomial is never accepted as zero merely because a decimal
evaluation is small. No claim about the degree-104 minimal polynomial is needed.

Three anchors themselves cannot occur among extension nodes: an anchor's own
inner product would be 1, outside the palette. Two distinct extension color
triples determine different anchor-product vectors, since the colors are
distinct. Equal triples determine the same point, so distinctness excludes
repetition of an extension node.

## Exact exhaustive check

The generator uses SymPy polynomial algebra and explicit adjugate formulas.
The separate checker rederives determinants and adjugates by permutation and
cofactor expansion, using its own integer-polynomial arithmetic. Its interval
enclosures sum signed coefficient bounds using powers of `[L,U]`; discovery
instead uses Horner interval evaluation.

The independently reproduced results are:

```text
56 anchor types: 42 positive determinants, 3 identically zero, 11 negative.
42 * 216 = 9072 norm polynomials checked.
810 extension-pair/color polynomials checked.
54 extension nodes in total.
Exactly 9 six-extension cliques, all candidate Gram patterns.
```

The only positive anchor types with any possible extension are

```text
(0,1,2), (0,2,2), (1,2,4), (1,2,5), (2,2,3),
(2,2,4), (3,4,5), (4,4,4), (4,5,5).
```

Each has exactly six extensions, all mutually compatible. Every other positive
anchor has no possible fourth point. For each surviving nine-point pattern,
the certificate supplies a permutation, and the checker verifies all 81
entries of its colored Gram matrix against the coordinate-derived candidate
Gram matrix. It enumerates all six-node subsets independently of the
generator's recursive clique search, so no clique is omitted.

Equal Gram matrices of spanning configurations imply congruence: map an anchor
basis of one configuration to the corresponding anchor basis of the other.
Gram equality makes this linear map an isometry on the basis and hence on all
of R^3. The other points are determined by their three inner products with that
basis. This proves the exact rigidity theorem.

## Quantitative theorem with six true windows

Set `epsilon=1/10000`.

**Window rigidity theorem.** Fix `r in I`. Suppose nine distinct unit vectors have an
anchor triple with Gram determinant strictly greater than `125/672`, and every
distinct-pair inner product belongs to

\[
 \bigcup_{c=0}^5 [s_c(r)-\epsilon,s_c(r)+\epsilon]. \tag{3}
\]

Then some permutation `p` satisfies

\[
 |x_i\cdot x_j-\operatorname{candidateAt}(r)_{p(i)}
                    \cdot\operatorname{candidateAt}(r)_{p(j)}|
 \le\epsilon\quad\text{for all }i,j. \tag{4}
\]

The determinant assumption is independently available for every competitor
with `E(X)<=E(P9)`: `GLOBAL_CONSTRAINTS.md` proves
`M=sum_i x_i x_i^T > (5/2) I`. Cauchy-Binet gives
`sum_(i<j<k) det Gram(x_i,x_j,x_k)=det M>125/8`.
There are 84 triples, so one determinant exceeds `125/672`.

### Exact interval filter

The checker replaces the six **true** windows in (3) by rational
overenclosures obtained from `s_c(I)+[-epsilon,epsilon]`. These six enclosing
intervals are pairwise disjoint and lie in `(-1,1/2)`. This replacement is used
only to discard impossible color patterns.

For doubled inner products, the selected anchor has
`det B>8*(125/672)=125/84`. Anchor color boxes with determinant upper bound at
most `125/84` may therefore be discarded. All remaining color assignments for
an extension are tested using the necessary rank condition

\[
 \det\begin{pmatrix}B&v\\v^T&2\end{pmatrix}=0. \tag{5}
\]

For two extensions and a proposed doubled mutual product `t`, the necessary
condition is

\[
 \det\begin{pmatrix}B&w\\v^T&t\end{pmatrix}=0. \tag{6}
\]

The latter is a cross-Gram matrix of four row vectors and four column vectors
in R^3, so its rank is at most 3. Equivalently, its determinant is
`t*det B-v^T adj(B)w`. The checker constructs both generic four-by-four
determinant polynomials by permutation expansion, collects integer coefficients,
and encloses each monomial with exact rational interval arithmetic. A type or
color is excluded only when the resulting closed interval omits zero.

Crucially, the entries of `v` and `w` in (6) are independent variables even when
the two extensions have the same color triple. All six proposed mutual colors
are excluded in that situation. Thus two actual points cannot share one
extension type; the finite graph uses ordinary distinct-node cliques soundly.

The independently checked finite results are:

```text
56 anchor color types; 36 survive the determinant threshold.
93 possible extension types in total.
7683 omitted extension types rigorously excluded.
1832 omitted pair colors rigorously excluded, including every self-type color.
9515 exact rational determinant exclusions altogether.
Exactly 8 six-extension cliques remain, all candidate colored Gram patterns.
```

Each retained pair edge has only one allowed color. Every omitted pair/color
is checked, not merely the advertised retained edges. All six-node subsets are
enumerated, and every retained nine-point pattern has its permutation witness
checked against every candidate Gram entry.

### Why the conclusion is exactly epsilon

The original hypothesis (3) refers to the fixed, true values `s_c(r)`, not to
the wider rational filter intervals. Since the filter intervals are disjoint,
the uniquely identified color is the same color from the original hypothesis.
That original hypothesis therefore supplies the bound exactly `epsilon` in
(4). We do **not** infer an `epsilon` bound from an enclosing interval whose
width has an additional radius-isolation error. The diagonal Gram entries
coincide exactly because all vectors have norm 1.

## The antipodal seventh contact

The pair potential minorants can also touch at `-1`. This contact cannot be
silently omitted. In fact, it can be excluded even if the spectrum hypothesis
allows the additional window

\[
 W_{-1}=[-1,-1+1/10000].
\]

Suppose a pair has inner product `t=-1+delta` in this window, and select any
third point. Let its inner products with the pair be `u,v`. The Gram determinant
identity is

\[
 \det\operatorname{Gram}(x_i,x_j,x_k)
 =2\delta(1+uv)-\delta^2-(u+v)^2. \tag{7}
\]

For each of the `7*7=49` possibilities for the windows of `u,v`, let `Q` be the
maximum of `uv` over their rational boxes and `B` the minimum of `(u+v)^2`.
All values lie in `[-1,1]`, so `1+Q>=0`. Equation (7) gives the exact upper bound

\[
 \det\operatorname{Gram}\le2\epsilon(1+Q)-B<-1/6000<0.
\]

The last inequality is checked separately for all 49 cases by
`check_antipodal_window.py`, with full rational bounds in its report. It
contradicts positive semidefiniteness of a Gram matrix. Thus no pair can belong
to the antipodal window. In particular, exact spectra in `S(r) union {-1}`
reduce to `S(r)`, and a seven-window hypothesis reduces to (3).

## Global Localization Supplied Separately

Together with the already established covariance and local-rigidity results,
the unrestricted problem is reduced to the following explicit statement:

> For every nine-point unit-sphere configuration with `E(X)<=E(P9)`, each
> distinct-pair inner product belongs to one of the six true windows
> `[s_c(r_*)-1/10000,s_c(r_*)+1/10000]`, or to `[-1,-1+1/10000]`.

This statement is now proved by the exact Hermite/SOS argument in
`../GLOBAL_PROOF.md`, not assumed from numerical evidence.
The seventh window is then impossible by (7); the finite window theorem yields
the labeled Gram window (4); the quantitative Gram-to-coordinate and local
energy theorem in `LOCAL_PROOF.md` yields congruence to `P9`. Configurations
with greater energy already satisfy the desired inequality. This remaining
spectrum-localization statement is supplied by that separate certificate,
not by the finite Gram checks alone.
