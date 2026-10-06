# The independently reconstructed nine point candidate

The exact candidate is the unique stationary member of the one-parameter family
below. This section establishes the family and parameter, not its global
optimality among all configurations. The original local and global mathematical
arguments are in `LOCAL_PROOF.md` and `GLOBAL_PROOF.md`. The unrestricted Lean
theorem has compiled through `Completion.lean`; `FORMAL_PROOF_GUIDE.md` describes
its selected route, and `STATUS.md` records the release-verification boundary.

## Coordinates and symmetry

Let

\[
 e_0=(1,0),\quad e_1=(-1/2,\sqrt3/2),\quad e_2=(-1/2,-\sqrt3/2).
\]

For `0<r<1`, set `z=sqrt(1-r^2)`. The points are

\[
 p_{k,+}=(r e_k,z),\quad p_{k,-}=(r e_k,-z),\quad c_k=(-e_k,0).
\]

The points are distinct and lie on the unit sphere. Rotations by `2*pi/3` about
the vertical axis, reflection in a vertical plane through `e_0`, and reflection
in the equatorial plane preserve the set. They generate `D_3h` of order 12.
There are two orbits under the full group: six prism vertices and three caps.
Under the cyclic rotation subgroup there are three orbits of size three.
After fixing scale and rotation, this family has one geometric parameter.

The exact isolating interval below excludes coincidences among its six inner
products. The three caps have the pair-type signature distinct from the six
prism points, so every orthogonal symmetry preserves the cap set. Its plane
must be preserved; restriction to that plane permutes an equilateral triangle,
giving at most six choices, with at most two choices on the perpendicular
line. Hence the orthogonal symmetry group has exactly 12 elements and is
exactly `D_3h`.

## Inner products and energy

| Pair type | Inner product | Number of unordered pairs |
| --- | --- | ---: |
| Within upper or lower triangle | `1-3r^2/2` | 6 |
| Vertically opposite prism vertices | `2r^2-1` | 3 |
| Other upper/lower prism pairs | `r^2/2-1` | 6 |
| Between caps | `-1/2` | 3 |
| Cap and opposite prism direction | `-r` | 6 |
| Remaining cap/prism pairs | `r/2` | 12 |

The multiplicities sum to 36, so the unordered-pair Coulomb energy is

\[
 F(r)=\frac{2\sqrt3}{r}+\frac3{2\sqrt{1-r^2}}+
 \frac6{\sqrt{4-r^2}}+\sqrt3+
 \frac6{\sqrt{2+2r}}+\frac{12}{\sqrt{2-r}}.
\]

## Exact parameter

Define `r_*` as the unique root in `(0,1)` of

\[
 -\frac{2\sqrt3}{r^2}+\frac{3r}{2(1-r^2)^{3/2}}+
 \frac{6r}{(4-r^2)^{3/2}}-\frac6{(2+2r)^{3/2}}+
 \frac6{(2-r)^{3/2}}=0. \tag{1}
\]

Every radical denotes the positive square root. The certified rational
isolating interval is

\[
 \frac{7105483340929538113277041792727912437680}{10^{40}}
 <r_*<
 \frac{7105483340929538113277041792727912437681}{10^{40}}.
\]

Existence and uniqueness follow from `F''>0`, `F'(0+)=-infinity`, and
`F'(1-)=+infinity`. Exact endpoint derivative signs are independently checked
in `certificates/check_local.py`. The full derivative formula and its strictly
positive derivative are written out in `LOCAL_PROOF.md`. Thus this is an exact
characterization with a proved unique root, not a decimal definition.

An equivalent polynomial system, useful for elimination without spurious sign
choices, introduces positive `a,b,c,d,e` satisfying

\[
 a^2=3,\ b^2=1-r^2,\ c^2=4-r^2,\ d^2=2+2r,\ e^2=2-r,
\]

\[
 -4ab^3c^3d^3e^3+3r^3c^3d^3e^3+12r^3b^3d^3e^3
 -12r^2b^3c^3e^3+12r^2b^3c^3d^3=0.
\]

Together with the isolating interval and positivity constraints this system
defines the same parameter. `algebra/parameter-polynomial.json` now supplies
the complete coefficient list of an exact degree-104 integer polynomial.
The separate standard-library checker verifies the radical elimination
identity, integer substitution, primitive content, and factor multiplication.
Exact endpoint signs and a strictly negative derivative on the isolating
interval prove that this polynomial has exactly one root there. A deliberately
corrupted constant coefficient is rejected. No irreducibility is claimed, and
the original radical sign conditions remain the candidate's definition.

## Numerical diagnostics

Independent unrestricted optimization from 256 Gaussian random configurations
identified the family; subsequent unrelated starts and unrestricted 80-digit
refinement gave the following diagnostic values:

\[
 r_*=0.710548334092953811327704179272791243768034172409764\ldots,
\]
\[
 z_*=0.703648395804131775777752332462816121248942055304304\ldots,
\]
\[
 E(P_9)=25.759986531269831564075702273760494028641913636477\ldots.
\]

The symmetry axis was recovered from the covariance eigenvectors of an
unrestricted optimizer, then the heights and inner-product spectrum were
compared to the derived family. The unordered spectrum at the candidate is

| Inner product approximately | Multiplicity |
| --- | ---: |
| -0.747560532458864 | 6 |
| -0.710548334092954 | 6 |
| -0.500000000000000 | 3 |
| 0.009757870164544 | 3 |
| 0.242681597376592 | 6 |
| 0.355274167046477 | 12 |

The hull has 14 triangular faces, 21 edges, six degree-five vertices,
and three degree-four vertices: the tricapped trigonal prism combinatorics.
`certificates/check_geometry.py` checks all 84 triples with exact interval
determinant signs: 14 are strictly supporting, and every other triple has
vertices strictly on both sides. It also checks covariance greater than `2I`.
The hull result is not used in either energy certificate.

The constrained tangent Hessian has 18 dimensions, exactly three rotational
zero modes, and fifteen positive modes. Its smallest positive eigenvalue is
numerically `0.14393500515549...`; the exact certificate proves the uniform
lower bound `7/50=0.14` transverse to rotations. Full coordinate, Hessian,
random-start, and perturbation diagnostics are in `results/candidate.json`.
The unrestricted high-precision refinement script uses a separate 15-variable
rotation gauge and does not impose the symmetry family.

## Tangent Representation

There is also a direct representation-theoretic explanation of the repeated
Hessian eigenvalues. Take generators `R` (rotation by `2*pi/3` about the
vertical axis), `J=diag(1,-1,-1)`, and `H=diag(1,1,-1)`. In prism labels
`(ell,j)` with `ell=0,1` and `j=0,1,2`, the element `R^k J^b H^h` acts as
`(ell xor b xor h, k+(-1)^b*j mod 3)`. It sends cap `6+j` to the cap with
the same transformed `j`. These give the actual twelve candidate symmetries.

For class order `(E,2C3,3C2,sigma_h,2S3,3sigma_v)`, the numbers of fixed
vertices are `(9,0,1,3,0,3)`. Each fixed vertex contributes `trace(g)-1`
to the tangent character, since its normal line is fixed pointwise. Hence
the 18-dimensional tangent character is `(18,0,-2,0,0,0)`, and its exact
real representation decomposition is

```text
Tangent:      A1' + 2 A2' + 3 E' + A1'' + 2 A2'' + 3 E''.
Rotations:           A2'                           +   E''.
Nonrotation:  A1' +   A2' + 3 E' + A1'' + 2 A2'' + 2 E''.
```

The rotational representation is the axial-vector action `det(g)*g`.
After removing it, an invariant symmetric Hessian has multiplicity-space
blocks of sizes `(1,1,3,1,2,2)`. Each eigenvalue in either E-type block
occurs twice. The soft numerical doublet `0.143935005155...` belongs to
`E'`; the invariant family direction belongs to `A1'`, with eigenvalue
`F''(r_*) / (6/(1-r_*^2))`, numerically `3.606431653152...`.

An independent symbolic cross-check verified all 108 vertex actions and
144 group products. A fresh tangent-frame calculation matched the saved
numerical spectrum to `3.56e-15`. The character calculation is an exact
mathematical derivation, not an additional Lean theorem; the numerical
block values are diagnostics, not certified intervals. Symmetry alone
does not prove positivity. The formal proof instead uses the independently
checked full augmented-Hessian certificate and its exact `7/50` bound.
