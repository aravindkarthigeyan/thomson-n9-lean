# Formalization Search and Source Audit

Search date: 2026-10-05. This is a source-inspection report, not a claim that every inspected repository was independently rebuilt. The N=7/N=8 projects have separate build reports. The auxiliary repositories below were downloaded and their actual declarations/proofs opened. No theorem is inferred merely from a repository title or search snippet.

## Results by Requested Case

| Case/topic | Result of this search |
| --- | --- |
| Thomson N=2,3,4,5,6,12 | No complete Lean/Coq/Isabelle formalization of the Coulomb optimum and equality case was located. This is a search result, not a nonexistence theorem. |
| Thomson N=7,8 | Genuine Lean projects, inspected separately in this project. |
| Cohn--Kumar universal optimality on spheres | No complete formalization located. The Fourier-interpolation challenge at lean-lang.org/eval is a different statement and contains proof holes; it is not a solution to the requested spherical theorem. |
| Delsarte spherical LP and Schoenberg positivity | Genuine generic Lean proofs found in specialjcg/delsarte. |
| Higher spherical-code hierarchy | Genuine Lean source found in openai/ten-proofs, MetricCodes.lean. Its displayed results concern asymptotic code rates, not finite Thomson energies. |
| Sharp 24-dimensional spherical code bound | Genuine Lean source found in math-inc/Sphere-Packing-Lean. This is not a Coulomb energy theorem. |
| Gram positivity | Mathlib has a native theorem that every finite Gram matrix is positive semidefinite. |
| SOS/semialgebraic inequalities | Genuine general-purpose Lean certificate soundness in leanprover/sos and Coq/Rocq soundness in validsdp/validsdp. No N=9 certificate was found there. |

## Actual Inspected Formal Statements

### Generic spherical Delsarte library

Repository: <https://github.com/specialjcg/delsarte>

- Commit: `f0724e16b01d4561ee6cda8cd56db4db03de0496`.
- Lean: `leanprover/lean4:v4.33.1`.
- Mathlib: <https://github.com/leanprover-community/mathlib4>, commit `0df444a360eaa60ab8c11dca51a86af692955474`.
- License: Apache-2.0. Download: `work/prior/delsarte`.

`Delsarte/Sphere/Schoenberg.lean` proves

```lean
schoenbergPos_all (hd : 2 <= d) (k : Nat) : SchoenbergPos d k
```

Here `SchoenbergPos d k`, defined in `Delsarte/Sphere/LP.lean`, says that for every finite family of unit vectors in `EuclideanSpace R (Fin d)`, the double sum of the degree-k Gegenbauer kernel on its Gram entries is nonnegative. This is an unconditional spherical positivity result, not an assumed analytic axiom. Its proof expresses the kernel as the Fischer inner product of zonal harmonic polynomials and applies nonnegativity to the sum of those polynomials. The key actual identity is `fischer_zonal_zonal`; `Delsarte/Harmonic/Zonal.lean` implements the zonal polynomial and evaluation identity.

`card_le_of_sphereCert` proves a finite spherical-code cardinality bound from rational Gegenbauer coefficients, positive constant coefficient, nonnegative remaining coefficients, and nonpositivity of the polynomial on `[-1,1/2]`. Although that declaration takes Schoenberg positivity as an input, the file above supplies it for all degrees and dimensions at least two.

`Delsarte/Certificate/Interval.lean` contains `IntervalCert a b f`, an exact rational polynomial identity

```
-f = sigma0 + (X-a)*sigmaA + (b-X)*sigmaB
     + (X-a)*(b-X)*sigmaAB,
```

where each sigma is an explicit sum of squares. The opened theorem `aeval_nonpos_of_intervalCert` proves the desired real interval inequality. This is directly useful for a Coulomb polynomial minorant after the radical has been handled algebraically. The integer certificate layer has additional exact checkers for Hamming LP; it is not automatically a spherical-energy checker.

A source scan of this checkout found no Lean declarations using `sorry`, `admit`, a new `axiom`, or `unsafe`. This scan is weaker than a successful build and dependency-closure axiom audit. This auxiliary project was not rebuilt in this run.

### Higher spherical-code hierarchy

Repository: <https://github.com/openai/ten-proofs>

- Commit: `94bc0feb6a9ff12c7d31d6de640a725c9d43d2b6`.
- Lean: `leanprover/lean4:v4.32.0`.
- Mathlib commit: `81a5d257c8e410db227a6665ed08f64fea08e997` at the same Mathlib URL.
- License: Apache-2.0. Download: `work/prior/ten-proofs`.

Opened the actual closing declarations of `MetricCodes.lean`, including `MetricCodes.Spherical.HigherHierarchy.main_general`, `strict_hierarchy`, and `eventually_kissingNumber_lt_published`. `main_general` bounds sufficiently high-dimensional spherical codes using interlacing characteristic-minor data and bounds the asymptotic spherical-code rate. The kissing-number theorem is an eventual high-dimensional exponential bound. These are genuine proved statements in the inspected source, but neither is a finite nine-point Coulomb inequality. No independent build was attempted for this very large auxiliary file.

### Sphere-packing and equality infrastructure

Repository: <https://github.com/math-inc/Sphere-Packing-Lean>

- Commit: `1e98fb493088948ca7bbf47d7faed49cc5b39fc4`.
- Lean: `leanprover/lean4:v4.28.0`.
- Mathlib: <https://github.com/leanprover-community/mathlib4.git>, commit `8f9d9cff6bd728b17a24e163c9402775d9e6a365`.
- License: Apache-2.0. Git object database: `work/prior/sphere-packing-lean`.

Checkout failed on Windows because an upstream file is named `Aux.lean`, a reserved Windows device name. The Git object database was downloaded successfully; the following files were opened with `git show`, without claiming a successful checkout/build.

`SpherePacking/Dim24/Uniqueness/BS81/Thm13/LPBound.lean` proves `thm13_card_le_196560`: a 24-dimensional spherical code with maximum distinct inner product 1/2 has at most 196560 points. The supporting `LP/Delsarte.lean` proves the finite diagonal/off-diagonal LP argument, and `sharp_bound_forces_inner_in_rootSet` converts equality into roots of the auxiliary polynomial. The certificate uses

```
(t+1)*(t+1/2)^2*(t+1/4)^2*t^2*(t-1/4)^2*(t-1/2).
```

The abstract definition `IsDelsarteDual24` packages the double-sum positivity inequality. The root-set equality argument is reusable, but its input is not automatically a proof of arbitrary spherical kernel positivity. This is a spherical-code result, not universal Coulomb optimality.

### Mathlib primitives

Inspected Mathlib in the N=8 checkout, commit `db584cd6d46c92f209a44c0f1c829460d327499d`, Lean `v4.33.0`:

- `Mathlib/Analysis/InnerProductSpace/GramMatrix.lean`: `Matrix.posSemidef_gram` proves that a finite Gram matrix is positive semidefinite; `star_dotProduct_gram_mulVec` gives the weighted-vector-sum identity behind it. Also inspected `linearIndependent_of_det_gram_ne_zero`.
- `Mathlib/LinearAlgebra/Matrix/PosDef.lean`: native PSD definitions and matrix APIs.
- `Mathlib/Algebra/Ring/SumsOfSquares.lean`: algebraic `IsSumSq` predicate and elementary closure lemmas. This file alone is not an SOS optimizer or exact SDP certificate parser.

Repository-wide searches for Thomson/Coulomb/Delsarte/Yudin/Gegenbauer/spherical-code/universal-optimality terms did not identify a matching Thomson optimum theorem in that Mathlib revision. Author-name matches for Thomson were not mathematical matches.

### Lean SOS checker

Repository: <https://github.com/leanprover/sos>

- Commit: `fb7ae417609093f04cf0608dc92e9343550c2ae4`.
- Lean: `leanprover/lean4:v4.33.1`.
- Mathlib: commit `0df444a360eaa60ab8c11dca51a86af692955474` at the Mathlib URL above.
- License: Apache-2.0; the CSDP dependency is EPL-1.0. Download: `work/prior/lean-sos`.
- Direct solver/representation pins from `lake-manifest.json`: `leanprover/csdp-ffi` at `eb41f276101847dd799c703e2378a544591aebf4`; `leanprover/hex-mv-poly.git` at `e25a580e1c8ee59d66408031bcb74ed5aca05b95`; `leanprover/hex-poly.git` at `1ca97f372946ecc430fe4f3961ec4220f9bc7706`; `leanprover/hex-basic.git` at `591c146eeee0ef301a110cd33c19cc0cf1e07352`. The downloaded manifest retains all transitive pins.

Opened `SOS/Mathlib/Verifier.lean`. Its actual `SOS.sos_sound` theorem says that a Boolean-checked exact rational certificate proves polynomial nonnegativity at every real assignment satisfying the supplied polynomial inequalities and equalities. The proof evaluates explicit nonnegative weighted square decompositions, multiplies by nonnegative constraint products, and adds unrestricted equality cofactors. The soundness theorem is independent of whether the numerical solver successfully discovers such a certificate.

Opened `SOSTest/Axioms.lean`: guarded `#print axioms` expectations for `sos_sound`, strict/refutation variants, and the polynomial multiplication bridge are exactly `[propext, Classical.choice, Quot.sound]`. This is the repository's checked expectation in source; this run did not independently rebuild those guards.

Opened `SOSTest/Showcase.lean`, including a sphere constraint `x^2+y^2+z^2=1` proving `0 <= 3-(x+y+z)^2`, Cauchy--Schwarz, Motzkin-related examples, and the interval inequality `-1 <= t <= 1 -> 0 <= 1+r^2-2*r*t`. The Windows solver build requires extra BLAS setup; it was not attempted. This is a promising exact checker for future polynomial certificates, but no part of the present N=9 result relies on an unbuilt `sos` tactic invocation.

### Coq/Rocq validated SDP

Repository: <https://github.com/validsdp/validsdp>

- Commit: `083e96683cf7087492d4d57e87c546264c2170c1`.
- License: LGPL-2.1-or-later. Download: `work/prior/validsdp`.
- This is not Lean and has no Mathlib dependency. The opened opam file specifies compatible dependency ranges, not a complete lock: Rocq 9.0+, mathcomp-field 2.4--2.5 (or development), CoqEAL >=2.1, multinomials >=2.0, and OSDP >=1.1.1. An independently reproducible build would require additionally locking those choices.

Opened `theories/validsdp.v` around the actual proofs `soscheck_correct` and `soscheck_hyps_correct`. The first proves nonnegativity of a multivariate polynomial from the Boolean checker, with strict positivity when a constant monomial is present. Its proof distributes coefficient residuals into a Gram-matrix perturbation, bounds that perturbation entrywise, and invokes interval-validated positive definiteness. The second incorporates polynomial inequality hypotheses. This is relevant exact/validated SDP technology, not an already-existing Thomson proof. No Coq/Rocq build was performed here.

## Search Coverage and Limits

Searches used actual GitHub repository search as well as web indexes for Thomson plus Lean/Coq/Isabelle, spherical codes, Delsarte, universal optimality, semialgebraic optimization, and Lean Zulip archive pages. Representative GitHub queries were `thomson lean`, `Delsarte language:Lean`, and `spherical language:Lean/Coq/Isabelle`. The indexed Lean Zulip search for `Thomson problem` yielded no additional inspected formal proof. Results for the Feit--Thompson theorem were discarded as unrelated.

Some search leads were not inspected (for example, repositories mentioning proximity soundness or isolated spherical harmonic identities), and no result is claimed from them. Search indexes can miss repositories and private work. Therefore the negative entries in the table mean only that this documented search did not locate a complete formal proof.

The N=9 package subsequently vendored the eight-file Schoenberg dependency closure from the pinned `specialjcg/delsarte` repository under Apache-2.0. Six files are unchanged; `Fischer.lean` and `Zonal.lean` have the documented minimal coefficient-API compatibility edits for Lean 4.34.1 and the N9 Mathlib pin. The retained license, original Git blob hashes, and exact changes are in `lean/vendor/DELSARTE_LICENSE` and `lean/vendor/DELSARTE_PROVENANCE.md`. That selected closure and the N9 adapters passed ordinary Lake builds and standard-axiom audits; this is not a claim that the entire auxiliary Delsarte project was rebuilt. None of the other auxiliary proof sources described above was vendored. Source inspection, a selected dependency-closure build, a complete package build, and a final-theorem axiom audit remain distinct levels of assurance.
