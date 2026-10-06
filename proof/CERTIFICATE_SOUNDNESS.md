# Exact Three-Point Certificate Soundness

This gives the mathematical implication checked by `certificates/check_sos.py`, with all summation constants explicit. It does not assert that the resulting bound equals the N=9 candidate energy. Numerical discovery and exact verification are separate programs.

## 1. Spherical Kernel Positivity

Let N >= 3 and let x_1,...,x_N be unit vectors in R^3. For a triple (x,y,z) write

```
u = x dot y,   v = x dot z,   t = y dot z.
```

Define polynomials

```
q_0(u,v,t) = 1,
q_1(u,v,t) = t-u*v,
q_(k+1) = 2*(t-u*v)*q_k - (1-u^2)*(1-v^2)*q_(k-1).
```

These are the scaled Chebyshev kernels appropriate to the two-dimensional plane perpendicular to an anchor on S^2. They are not the ordinary Legendre kernels on S^2.

For each fixed anchor x choose an orthonormal basis of x-perp and encode the projection of y_b as a complex number z_b. Put u_b=x dot y_b. Then

```
Re(z_b * conjugate(z_c)) = y_b dot y_c - u_b*u_c,
|z_b * conjugate(z_c)|^2 = (1-u_b^2)*(1-u_c^2),
q_k(u_b,u_c,y_b dot y_c) = Re(z_b^k * conjugate(z_c^k)).
```

The last identity follows from the displayed recurrence for real parts of complex powers. It remains valid when a projection vanishes, using z^0=1 for k=0.

For a fixed truncation d >= k define the matrix

```
Y_k(u,v,t)[i,j] = u^i * v^j * q_k(u,v,t),
0 <= i,j <= d-k.
```

For any real coefficients a_i, summing over the two non-anchor indices gives

```
sum_(b,c) sum_(i,j) a_i*a_j*Y_k(u_b,u_c,y_b dot y_c)[i,j]
  = |sum_b (sum_i a_i*u_b^i) * z_b^k|^2 >= 0.
```

Consequently `sum_(a,b,c) Y_k(x_a dot x_b,x_a dot x_c,x_b dot x_c)` is positive semidefinite, with all ordered indices allowed, including repeated indices.

Let S_k be Y_k averaged over all six permutations of (u,v,t). A permutation of the three vertices induces exactly a permutation of the three edge variables. Relabeling the ordered triple sum therefore gives

```
sum_(a,b,c) S_k = sum_(a,b,c) Y_k >= 0.
```

Also S_k is a symmetric matrix because swapping u and v interchanges i and j.

## 2. Removing Repeated Indices

Set

```
R_k(u,v,t) = (N-2)*S_k(u,v,t)
          + S_k(u,u,1) + S_k(v,v,1) + S_k(t,t,1)
          + S_k(1,1,1)/(N-1).
```

Separating all ordered triples into distinct, exactly-two-equal, and all-equal indices gives

```
sum_(a,b,c) S_k
  = 6*sum_(a<b<c) S_k(u_ab,u_ac,u_bc)
    + 6*sum_(a<b) S_k(u_ab,u_ab,1)
    + N*S_k(1,1,1).
```

Each pair belongs to N-2 unordered triples, so the exact normalization is

```
sum_(a<b<c) R_k(u_ab,u_ac,u_bc)
  = (N-2)/6 * sum_(a,b,c) S_k >= 0.
```

This is precisely `rblock` in `polynomial.py`. For a monomial u^a*v^b*t^c, substitution `(w,w,1)` gives w^(a+b), not w^(a+b+c). The explicit zero-exponent branch prevents three constant terms from being overwritten in a Python dictionary.

If F_k=B_k*B_k^T for a rational matrix B_k, positivity yields

```
sum_(a<b<c) <F_k,R_k(u_ab,u_ac,u_bc)> >= 0,
```

because the matrix inner product equals `trace(B_k^T * sum R_k * B_k)`. Rationalization of B_k cannot destroy PSD. No floating-point eigenvalue claim is trusted by the checker.

## 3. The Triple Domain and SOS Terms

Suppose all distinct pairwise inner products lie in [l,U], with -1 <= l < U <= 1. A distinct triple satisfies

```
l <= u,v,t <= U,
D(u,v,t) = 1 + 2*u*v*t - u^2-v^2-t^2 >= 0.
```

The last inequality is the determinant of the Gram matrix of three real vectors. It follows from Gram positive semidefiniteness and is not a relaxation assumed without proof.

The certificate uses the nonnegative multipliers

```
1,  u-l,  U-u,  D(u,v,t).
```

For each multiplier g and a listed monomial basis m, its block is the symmetric-variable average of `g*m*m^T`. Contracting this matrix with Q=C*C^T produces the symmetric-variable average of `g*|C^T*m|^2`. Every term is nonnegative on the triple domain, including every permuted term, since the domain is permutation invariant. These are sufficient SOS identities, not a claim that every nonnegative polynomial admits this particular representation.

The code's default l=-1,U=1 gives an unconditional spherical bound. A file with l>-1 or U<1 gives a conditional bound until a separate theorem establishes those geometric restrictions. A conditional certificate must never be reported as global by itself.

## 4. Coulomb Minorant Verification

Let H(t) be the rational polynomial stored in `minorant`. The exact substitution

```
t = 1-2*y^2,   0 < y <= 1,
f(t) = 1/sqrt(2-2*t) = 1/(2*y)
```

shows that

```
p(y) := 1-2*y*H(1-2*y^2) >= 0  on [0,1]
```

implies H(t)<=f(t) on [-1,1). Distinct unit points ensure that t=1 does not occur. The endpoint y=0 is harmless and is included in the polynomial verification.

`hermite_y_polynomial` expands p exactly by the binomial theorem. If `p(y)=sum a_i*y^i` has degree at most m, its Bernstein coefficients on [0,1] are

```
b_k = sum_(i<=k) a_i * binom(k,i)/binom(m,i).
```

Nonnegative b_k imply p>=0 because the Bernstein basis `binom(m,k)*y^k*(1-y)^(m-k)` is nonnegative and sums to one. Midpoint subdivision uses the exact de Casteljau averaging algorithm. Its left and right coefficient lists represent p(y/2) and p((1+y)/2). A finite successful covering therefore proves the minorant inequality without sampling assumptions. Failure to certify before the depth limit rejects the certificate; it does not imply the polynomial is negative.

The numerical generator initially imposes sampled inequalities and then lowers the constant coefficient until this exact Bernstein test succeeds. Only the final exact test is used in the proof.

## 5. Residual and Energy Bound

Put C=N*(N-1)/2 and let e denote `raw_energy`. The checker constructs the exact rational residual polynomial A from

```
(H(u)+H(v)+H(t))/3 - e/C
  = sum_k <F_k,R_k(u,v,t)> + sum SOS terms + A(u,v,t).
```

Let L be the sum of the absolute values of every monomial coefficient of A. Since |u|,|v|,|t|<=1, the triangle inequality gives A>=-L. There is no assumption that the numerical coefficient equations were solved exactly.

Summing over unordered distinct triples, using the kernel and SOS nonnegativity above, gives

```
(N-2)/3 * sum_(a<b) H(u_ab)
  >= binom(N,3)*(e/C-L).
```

Since `3*binom(N,3)/(N-2)=C`, and H<=f,

```
E(X) >= e-C*L.
```

The checker accepts a claimed bound only if it is at most this exact rational number. In the current implementation N is explicitly restricted to 9, so C=36. The proof above applies to arbitrary N>=3 if the implementation's N guard and generator normalization are correspondingly generalized.

## 6. Audit and Trust Boundary

`certificates/audit_sos.py` is a second, exact regression audit. It independently evaluates the Chebyshev recurrence and symmetrized boundary formula, tests the full ordered/unordered sum identity on nine rational unit vectors, checks the Bernstein conversion and subdivision identities at rational arguments, and reruns the checker after four deliberate changes: a minorant coefficient, a kernel factor coefficient, an SOS factor coefficient, and the claimed energy. The selected corruptions must all be rejected. Not every arbitrary coefficient change should be rejected: a change may describe a different valid certificate with a still-valid weaker bound.

The audit report is `results/sos-independent-audit.json`. It records exact bounds and the corruption results for the files explicitly passed to the audit. This is a regression test plus the mathematical soundness argument above, not Lean kernel verification.

Reproduction, from the project directory with the documented Python interpreter:

```powershell
python certificates/check_sos.py certificates/global-d6.json --negative-control
python certificates/audit_sos.py certificates/global-d3.json certificates/global-d4.json certificates/global-d5.json certificates/global-d6.json certificates/min070-d5.json certificates/sep0567-d5.json --report results/sos-independent-audit.json
```

Use ordinary Python with assertions enabled, not `python -O`. Exact verification uses Python arbitrary-precision integers and `fractions.Fraction`, polynomial dictionary arithmetic, JSON parsing, and the source code that implements the formulas above. It does not import NumPy, CVXPY, a floating SDP solver, or a floating eigenvalue routine. Floats in the returned report are diagnostics only; `bound` is the exact rational result. The scientific discovery program imports numerical packages, but these are outside the checking path.

These dependencies are a materially larger trust base than a Lean theorem. This exact Python checker is independently inspectable mathematical software, not a substitute for a `#print axioms` audit. The generic positivity/summation argument and selected D60 data now have compiled Lean proofs, mapped in `FORMAL_PROOF_GUIDE.md`; optional checker extensions below are not thereby all formalized. An energy lower certificate alone does not supply equality rigidity. The original Hermite-based mathematical chain is preserved in `GLOBAL_PROOF.md`; the selected formal route uses direct Bernstein slack, finite Gram windows, and the compiled local theorem. Current release audits are tracked in `STATUS.md`.

## Addendum: Symmetry Basis Version 1

The later `sos_basis="symmetry-v1"` format changes only the polynomials used in the SOS bases, not the spherical kernels, multipliers, residual calculation, or energy normalization. Its implementation is `invariant_bases` in the independently authored `polynomial.py`; it is not imported proof code from N=7/N=8. The mathematical operation is the same explicit six-permutation averaging already audited above. Numerical solver output remains outside the trusted checking path.

For the fully symmetric multipliers 1 and D, the first basis consists of the distinct monomial-orbit sums

```
sum_(distinct permutations p of exponent e) u^p0*v^p1*t^p2.
```

The second consists of monomial differences

```
u^i*v^j*t^k - u^i*v^k*t^j,  (i,j,k)<(i,k,j)
```

in lexicographic order. The first polynomials are S3-invariant and the second are odd under exchanging v and t. For a multiplier depending on u, namely `u-l` or `U-u`, the first basis instead consists of the sums of v/t-swapped monomials, with each fixed monomial listed once. The second basis is the same odd-difference construction. Each basis entry is an explicit rational polynomial.

For any such basis vector b, any exact factor C, and any nonnegative domain multiplier g, the checked block still has value

```
<C*C^T, Sym(g*b*b^T)> = Sym(g*||C^T*b||^2) >= 0.
```

This proves soundness directly. It requires no assertion that these bases are complete, minimal, orthogonal, or an entire irreducible-representation decomposition. In particular, the full-group odd block is only described as a transposition-odd polynomial basis; its contents are not falsely labeled all S3-invariant. Discarding other basis directions could weaken a search but cannot invalidate a certificate that passes the displayed identity and positivity checks.

At truncation degree 6 the SOS block sizes are `23,34,34,22,34,22,11,13`; at degree 7 they are `31,50,50,34,50,34,16,22`. All PSD matrices are still exported as exact rational factors. The scalar polynomial residual is expanded completely, so no unsound coefficient cancellation is introduced by using symmetry for numerical discovery.

The extended `audit_sos.py` independently tests the orbit/parity properties, directly evaluates each selected symmetrized basis-product entry, and runs the four corruption controls on the new certificates. The report is `results/sos-symmetry-independent-audit.json`; it covers `global-d6-symmetry.json` and `sep0560-d7-symmetry.json`. The latter is conditional on maximum inner product at most 0.5600. Its validity does not itself establish that geometric restriction.

## Addendum: Box-Product Multipliers

The mode `sos_basis="symmetry-box-v1"` retains all the preceding blocks and appends blocks with the two multipliers

```
b(u) = (u-l)*(U-u),
D(u,v,t)*b(u).
```

Here D is the determinant of the three-point Gram matrix. On the actual domain, every pair variable is in `[l,U]` and D is nonnegative. Thus both multipliers are nonnegative, including after any permutation of u,v,t. Each uses the same even/odd basis under exchanging v and t as the other u-anchored multipliers. Consequently the exact identity `Sym(g*||C^T*basis||^2)>=0` proves positivity of each added block. This does not assert that a product of arbitrary nonnegative polynomials has an SOS representation; their nonnegativity is separately established from the domain constraints, and each product is multiplied by an explicitly factored sum of squares.

For b(u), the multiplier degree is 2 and basis degree is at most `d-1`, so the total degree is at most `2d`. For D*b(u), the multiplier degree is 5 and basis degree is at most `d-3`, giving degree at most `2d-1`; the latter is included only for `d>=3`. No additional degree or sign assumption is hidden in the mode name. The six-permutation averaging, exact residual l1 bound, Coulomb minorant verification, and unordered-pair energy normalization are unchanged.

The degree-7 file `certificates/sep0560-d7-box.json` has block sizes

```
31,50,50,34,50,34,16,22,50,34,22,13.
```

The first eight are the unchanged symmetry-v1 blocks; the last four are the even/odd box and Gram-times-box blocks. Its exact claimed bound is

```
64398607363305970497207 / 2500000000000000000000
```

on `-1<=u_ij<=14/25`. As before, the SOS file alone proves a conditional bound; an unconditional consequence additionally needs the geometric exclusion/dichotomy in `GLOBAL_CONSTRAINTS.md` and its combined checker.

The independent audit now compares the new block lists to their explicit multiplier formulas, checks all extra block degrees, and evaluates selected entries by direct permutation averaging. It rechecks the actual certificate and adds a deliberate coefficient corruption in the final Gram-times-box factor to the four earlier controls. The recorded result is `results/sos-box-independent-audit.json`, reproducible with

```powershell
python certificates/audit_sos.py certificates/sep0560-d7-box.json --report results/sos-box-independent-audit.json
```

These are independently authored extensions of the exact polynomial checker. No upstream implementation or unlicensed source was copied. These optional additions remain mathematical software plus the displayed proof; they are not all claimed as Lean-formalized. The selected certificate and its formal SDP bound are separately identified in `FORMAL_PROOF_GUIDE.md`.

The same independent audit was also completed for `sep0560-d8-box.json`; `results/sos-d8-box-independent-audit.json` records the exact base bound `128799281388344093396593/5000000000000000000000` and rejection of all five selected corruptions. Its stronger residual-refined bound is checked separately by the procedure in `RESIDUAL_BERNSTEIN.md`.

## Addendum: Globally Summed Determinant Moment

The optional rational field `determinant_coefficient` supplies a scalar `mu>=0` multiplying `Q(u,v,t)=9/28-D(u,v,t)`. Unlike the SOS domain multipliers, Q need not be nonnegative at each triple. Its validity is exclusively a sum identity for nine unit vectors. With `M=sum_i x_i*x_i^T`, Cauchy--Binet gives `sum_(i<j<k) D(gij,gik,gjk)=det M`. Because M is positive semidefinite and has trace 9, arithmetic-geometric mean applied to its three nonnegative eigenvalues gives `det M<=27`. There are 84 unordered triples, so

```
sum_(i<j<k) Q(gij,gik,gjk) = 84*(9/28)-det M = 27-det M >= 0.
```

The sum over ordered distinct triples is six times this identity, namely `162-6*det M`. Therefore adding `mu*Q` to the certificate identity preserves the summed energy lower bound. It would be incorrect to treat this term as pointwise nonnegative; the checker subtracts it from the residual as a separate global term, explicitly checks `mu>=0`, and still restricts N to 9. The normalization `9/28` is specific to N=9. Missing fields mean mu=0, preserving all earlier certificates. The Bernstein residual reconstruction also subtracts this optional term. For the present candidate, M has positive unequal eigenvalues and trace 9, so `det M<27`; a strictly positive mu would create positive slack at the candidate and thus cannot occur in an attained sharp certificate of this form.
