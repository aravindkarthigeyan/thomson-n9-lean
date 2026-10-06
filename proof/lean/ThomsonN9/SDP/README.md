# Three-point certificate soundness

This directory is independent mathematical proof code. It contains no numerical
solver calls or imported numerical claims. The degree is arbitrary, including
the degree-10 blocks in the exact N=9 certificate.

## Geometric positivity

`Summation.lean` proves finite Gram-square identities and the complex-power
recurrence. `CircleKernel.lean` defines

    Q_0(a,b)=1, Q_1(a,b)=a,
    Q_{k+2}(a,b)=2 a Q_{k+1}(a,b)-b Q_k(a,b),

proves `Q_k(Re z, normSq z)=Re(z^k)`, and proves weighted positive
semidefiniteness of `Q_k` on complex Gram products.

`ProjectionComplex.lean` constructs the orthogonal projection onto the plane
perpendicular to a unit anchor and an isometry of that plane with the complex
numbers. For three unit vectors with pair products `(u,v,t)`, the projected
complex product has real part `t-u*v` and squared modulus
`(1-u^2)*(1-v^2)`. Thus `threePointKernel` is positive semidefinite for every
natural degree, including degenerate projected vectors. No division by the
projected lengths, and no nondegeneracy assumption, is required.

`FactoredKernels.lean` allows arbitrary finite real feature functions and real
factor matrices. A matrix in factor form `B B^T` produces a sum of the preceding
nonnegative quadratic forms. Its six-way edge symmetrization is shown to equal
the six-way vertex symmetrization on actual Gram triples.

## Counting conventions

`Counting.lean` distinguishes the sum over all ordered triples, the sum over
ordered distinct triples, and the unordered pair sum. There are 504 distinct
ordered triples. Each pair expression appears 42 times in the sum of the three
edge expressions. Therefore

    sum_distinct ((h(u)+h(v)+h(t))/3-e/36) = 14*(pairSum(h)-e).

`RepeatedIndices.lean` proves the exact boundary correction for N=9:

    R(u,v,t)=7*S(u,v,t)+S(u,u,1)+S(v,v,1)+S(t,t,1)+S(1,1,1)/8.

The sum of R over distinct ordered triples equals seven times the full ordered
triple sum of S. The repeated-index terms are proved by exhaustive equality
cases and finite-sum identities, not asserted as a numerical convention.

## Residual payment

`GeometryBounds.lean` proves the unit Gram domain bounds and converts actual
Euclidean inverse distance to the Coulomb potential in the pair product.
`ResidualBound.lean` proves that the absolute value of a polynomial on
`[-1,1]^3` is bounded by the l1 norm of its monomial coefficients. Combining
this with the counting identity gives energy loss exactly `36*L`.

`CertificateBound.lean` combines the actual factor-block positivity with a
pointwise polynomial identity, nonnegative weighted squares on the capped Gram
domain, and the residual coefficient bound. Its hypotheses explicitly require
the cap, polynomial identity, and nonnegativity of the chosen multipliers.
It also proves the six domain multipliers used by the current SOS format are
nonnegative and that symmetrization preserves nonnegativity on this domain.

`PolynomialKernel.lean` defines the exact rational q recurrence, substitution,
symmetrization, corrected R polynomial, and monomial-feature factor polynomials
in Mathlib's `MvPolynomial (Fin 3) Rat`. Evaluation is proved to recover the
real kernels above. This is a semantic bridge, not an executable sparse
polynomial checker: Mathlib's generic polynomial operations are noncomputable.
An executable data checker must separately prove that its representation
decodes to these polynomials or otherwise establish the real identity.

## Formalization boundary

These generic results do not assert that a particular rational certificate
has passed inside Lean. The rational factor arrays, polynomial coefficient
identity, scalar minorant partition, Gram-window classification, and local
Hessian certificate still need their own kernel-checked instantiations. The
Python verifiers are separate mathematical evidence, not Lean premises
silently converted to theorems.
