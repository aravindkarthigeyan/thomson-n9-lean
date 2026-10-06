# Rational Matrix Correction

`correct_matrices.py` converts the numerical degree-10 iterate to a standard
rational-factor SOS certificate. **The generator is not the verifier.** No
numerical solver, numerical rank decision, discarded equation, or Arb outcome
is trusted by the final certificate checker.

## Data Flow

1. `prepare_bases.py` supplies rational projected bases close to the numerical
   faces. Their exact kernel property is not required by the final bound:
   every resulting factor is allowed, and every coefficient residual is paid.
2. `hermite.json` supplies a separately checked rational degree-20 minorant and
   a rational candidate energy upper bound. The root midpoint must agree with
   the projected-basis data.
3. The numerical reduced matrices are factored with 800-bit Arb ball
   arithmetic. Rationalized triangular factors define exact positive starting
   matrices. This avoids treating saved floating-point matrices as exact PSD
   input.
4. Exact rational polynomial arithmetic constructs the 356 selected reduced
   matrix-entry columns. For an off-diagonal entry the contribution is the sum
   of the two transposed entries. Chebyshev row conversion is performed with
   exact dyadic rational coefficients, not a floating-point transform.
5. A validated 356-by-356 Arb solve supplies corrections. The corrections are
   rounded to rational numbers, added to the reduced matrices, and every one
   of the original 358 monomial coefficient rows is retained for a residual
   calculation. The two unused equations are never assumed to hold.
6. Arb Cholesky must have strictly positive pivot balls for every corrected
   reduced matrix. Full factors are then rounded to rational numbers with
   170 decimal places and padded to square matrices for the standard format.
   The exported PSD matrices are exactly B B^T, independently of the accuracy
   of that final rounding.

Only 358-by-356 selected coefficients are stored. There is no enormous dense
matrix containing all 35,200 unique symmetric unknown columns. FLINT's
`fmpq_mpoly` performs exact rational polynomial multiplication for SOS columns;
the rooted entries use the project's rational polynomial formulas.

## Checked Outcome

The frozen `near-sharp-d10.json` passed the independent integer checker.
Its exact residual l1 is approximately 1.1065310764372488e-165, and its energy
loss is approximately 3.983511875174096e-164. The exact rational comparison
`energy_loss < 10^-92` passed. These decimals are diagnostics only.

`audit_final_certificate.py` then rebuilt all 1771 full coefficients using
different FLINT polynomial operations, checked full permutation symmetry,
and obtained exactly the same rational l1 value as the integer implementation.
It rejected five corruptions: a factor entry increased by one, a claimed bound
raised to U, a minorant constant increased by one, a missing SOS block, and
extension of the domain upper endpoint to one. The exact report is
`final-adversarial.check.json`.

That audit shares the basis specification in `polynomial.py` with the main
checker, so it is not independent of possible specification errors there.
Claude's separate verifier in `claude/audit/sos_integer/w2_audit_ref.py`
reimplements the specification without importing project code and also matches
the full rational residual exactly. Its scope and minor interface findings are
recorded in that folder's `AUDIT.md`.

The final certificate's `certified_energy` was set once to the independently
computed exact bound and frozen with SHA-256:

```
c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9
```

No conclusion here depends on a numerical objective value or on exact
annihilation of the moment kernels by the rounded factors.

## Independent Checking

`audit_correction.py` compares projected columns with a separate standard-
library Fraction implementation. It covers diagonal and off-diagonal entries
in all 23 rooted/SOS blocks, for 69 checks.

The final mathematical certificate is the rational JSON, not the correction
history. `../certificates/check_sos_integer.py` reconstructs all polynomial
coefficients using common-denominator integers. It checks the Hermite proof,
every factor dimension, and every coefficient, and computes

    loss = sum over exponent orbits |compressed residual coefficient|.

All terms are symmetric. Compression sums coefficients within permutation
orbits, so this equals the full coefficient l1 norm and bounds the residual
on [-1,1]^3. The energy loss is exactly 36*loss. No row is ignored, and no
ill-conditioned numerical equality is promoted to an exact identity.

The checker also compares the energy loss to the explicit Hermite exterior
slack 10^-92. Passing that comparison forces a hypothetical energy competitor
into the seven inner-product windows, which are handled separately by the
Gram-window and local-minimality proofs. Matrix correction alone does not
establish that geometric bridge; all its hypotheses must be checked in the
full proof chain.

## Reproduction

From the extracted package root, after installing the pinned generation
dependencies in `requirements.txt`. The projected bases, Hermite data and
numerical source iterate are retained in the source release. `python` below
means that environment's interpreter; these are the portable equivalents of
the original workspace commands:

```powershell
python near_sharp/audit_correction.py
python near_sharp/correct_matrices.py --output near_sharp/regenerated-near-sharp-d10.json
python certificates/check_sos_integer.py near_sharp/near-sharp-d10.json --hermite-certificate near_sharp/hermite.json --require-localization --report near_sharp/near-sharp-d10.check.json
python near_sharp/audit_final_certificate.py
```

The `check_sos_integer.py` command replays the immutable delivered certificate. The
regenerated file can be passed to the same checker; its conservative claimed
bound is initially a placeholder, but `--require-localization` still enforces
the full actual residual threshold. Discovery timing metadata need not match
the frozen certificate byte for byte.

Generation uses python-flint 0.9.0. The independent final checker uses Python's
standard library. Reports record exact source hashes and rational results.
Neither this generator nor its checker is a Lean formalization.
