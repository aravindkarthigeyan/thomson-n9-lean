# Astra Pro Delivery Review

Inspected 2026-10-05, including the Lean ZIP added at 15:07 EDT.

## Inputs and Integrity

User-provided files in Downloads:

- `thomson-n9-lean-extension.zip`, 942879 bytes; SHA-256
  `0f8662d5a4726bad1b1024811e6b9b6d67fc1ca7e594752470e3b7414970e8b0`.
- `thomson-n9-formalization-report.md`.
- `thomson-n9-verification-status.json`.

The ZIP was extracted into an isolated working directory, not over the active
package. All 140 manifest hashes passed before running any generators. The
delivery includes 25 new Lean modules, with approximately 241 theorem scripts.
Its own report correctly states that these new modules were NOT compiled.
Source inspection or a Python pass does not change that status.

## Replayed Tests

The supplied `scripts/verify_extension.py --python-only` suite passed locally
at 19:11:04 UTC. On Windows it requires `PYTHONUTF8=1` for its child Python
processes. The first attempt without that environment setting failed while
writing a Unicode rational-type symbol; that failure was not a mathematical
test failure. The successful replay covered seven generation/check scripts,
the 1655-leaf global Bernstein tree and seven exterior intervals, LP data,
38 energy-enclosure nodes, and symbolic anchor checks.

An independent exact comparison found that its Legendre polynomials through
degree 27, LP weights, and expanded monomial coefficients agree with our
current covariance and separation certificates. No decimal matching was used.

## Contribution Now Kernel Checked

The explicit energy-upper-bound construction was adapted into
`lean/ThomsonN9/Certificates/ReducedEnergy.lean`. It proves

`candidate_energy_upper (r : CandidateParameter) :`
`  coulombEnergy (candidate r) <= (energyUpper : Real)`.

Here `energyUpper` is exactly the rational upper bound in the reduced D60
certificate. The proof encloses the symmetric-family energy at an explicit
rational comparison radius, then applies the already-proved family minimum.
It does not assume global optimality.

The 38 interval nodes, including five square roots, compiled with Lean 4.34.1
and the project's pinned Mathlib. The final theorem's printed axiom closure
is exactly `propext`, `Classical.choice`, and `Quot.sound`. Two rational
comparisons in the incoming proof pattern required explicit constant unfolding
with `norm_num`; after repair the compiler exited successfully.

Adaptation source: `certificates/generate_energy_upper.py`. Changes from the
incoming generator are explicit source/output paths, a standalone namespace
and constants, use of the current checked interval API, 256-bit fixed-point
precision appropriate to D60, an exact per-node generation replay, and
`autoImplicit false`. Generated source SHA-256:
`a39d9ffd65721967b938c9c8505e0b3b556f79f91cd12ce3bc38e1399ba5c3e4`.
Generation evidence is in `near_sharp/reduced/energy-upper-generation.json`;
its `kernel_checked: false` records the generator's scope, not the later
successful Lean invocation. The next consolidated package audit will include
this module; it was individually compiled at this checkpoint.

Follow-up: an ordinary Lake build of the normalized, on-disk source completed
successfully (3251 jobs, mostly cached dependencies). The generated source
uses fixed LF line endings so its byte hash is portable. Two exact Lean
negative controls also passed in `Certificates/EnergyControls.lean`: collapsing
the square-root enclosure to its lower endpoint is rejected, and lowering the
final energy ceiling by `10^-50` is rejected. Both rejection theorems have
only the standard three axioms. These test arithmetic failure, not missing
imports or parser failure.

Integration follow-up at 20:55 UTC: the bound is now used by the compiled
`ScalarCertificates.lean` module. Together with the concrete SDP, LP, and
finite-window certificates, it yields unconditional refined Gram localization
for every admissible configuration whose energy is at most the candidate's.
Thus this contribution is in the checked global reduction, not just a
standalone diagnostic. The final actual-Hessian/global assembly and clean
consolidated replay are still separate remaining tasks at this checkpoint.

## Other Components

- Bernstein checking and exact LP data are useful independent constructions.
  Claude's corresponding checker has already compiled, so we are retaining
  that checked route rather than replacing it with the uncompiled duplicate.
- The elementary covariance-to-anchor argument agrees with our separately
  developed and now compiled `LP/Anchor.lean` proof.
- `GramError.lean` assumes a quantitative alignment estimate. It does not
  discharge the actual Gram-to-coordinate alignment obligation.
- `Remaining.lean` is an honest conditional assembly with four unresolved
  fields, not an unconditional global-optimality theorem.
- Its localization loss `10^-100` belongs to the original high-precision
  certificate. It is NOT valid for D60, whose total residual loss is about
  `2.4e-54`. D60 uses the separately checked `10^-46` exterior gap instead.

No wholesale merge was performed. Inherited files were preserved, and no
claim is made that all 241 incoming theorem scripts compile. This delivery
is helpful: one concrete missing energy bound is now kernel checked, and
its other exact constructions provide independent cross-checks. It does not
by itself complete the global Lean proof.

## Later Integrated Checkpoint

The actual Hessian positivity proof and unconditional
`ThomsonN9.thomson_nine_complete` have since compiled. The adapted energy bound
is a dependency of that complete theorem. The assembled package's independent
4056-declaration axiom-log audit also passed, using only the standard three
axioms (or no axioms). This is stronger integration evidence than the earlier
individual-module checkpoint above. It does not upgrade the uncompiled parts
of the incoming ZIP, and the fresh source-only release rebuild and independent
final verification remain pending.
