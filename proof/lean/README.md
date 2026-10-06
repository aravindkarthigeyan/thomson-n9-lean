# Thomson N=9 Lean Package

This package formalizes global Coulomb-energy optimality and uniqueness for
nine distinct unit vectors in three-dimensional real Euclidean space. The
candidate is an explicitly defined tricapped triangular prism, with its
radius characterized by an exact stationarity equation and rational isolating
interval. No tabulated decimal, numerical solver result, or Python certificate
report is assumed as a theorem premise.

## Public Theorems

`ThomsonN9/Completion.lean` supplies:

- `ThomsonN9.thomson_nine_complete : ThomsonN9.Challenge.CompleteTarget`.
- `ThomsonN9.thomson_nine`: every admissible configuration has energy at least
  that of `candidate r`, for every `r : CandidateParameter`.
- `ThomsonN9.thomson_nine_unique`: equality holds exactly for configurations
  congruent to the candidate by an orthogonal map and a permutation.
- `optimalConfiguration_admissible`, `thomson_nine_fixed`, and
  `thomson_nine_fixed_unique`: the corresponding statements for one canonical
  choice of the uniquely characterized parameter.

`Solution.lean` independently binds `Challenge.CompleteTarget` as
`ThomsonN9.challenge_complete`. The challenge imports only `Candidate.lean`,
not Completion, MainTheorem, Solution, or any global certificate.

`ThomsonN9.thomson_nine_quantitative_stability`, in `QuantitativeStability`,
states that energy excess at most `10^-47` implies the existence
of a permutation and orthogonal alignment whose total squared pointwise
distance to the candidate is at most 50 times that energy excess.

The final theorem closures use only `propext`, `Classical.choice`, and
`Quot.sound`. These are Lean's standard logical principles, not assumptions
about the energy problem. Some finite certificate checks use no axioms.
`Solution.lean` requests an axiom report for every public theorem and lemma
in the project and imported contributor sources.

## Conventions

`Basic.lean` uses `EuclideanSpace ℝ (Fin 3)` and configurations `Fin 9 → R3`.
Admissibility means unit norm at every index and injectivity. Energy sums
inverse Euclidean distances over `Finset.Ioi`, counting each unordered pair
once. `Congruent` uses a real linear isometry equivalence and an arbitrary
permutation, so reflections as well as rotations are included.

The radius subtype uses the exact radical stationarity equation and rational
endpoints separated by `10^-40`. `ParameterSigns` and `ParameterExists` prove
endpoint signs, continuity, strict monotonicity, existence, and uniqueness.
The subtype is inhabited; the global statement is not vacuous. `Candidate`
proves admissibility, `CandidateEnergy` verifies all actual pair distances
and the energy formula, and `FamilyEnergy`/`FamilyMinimum` prove strict
convexity and unique minimization throughout the symmetric family.

## Proof Structure

1. `SDP/` proves all-degree spherical three-point kernel positivity using
   complex anchor projections, factor-matrix positivity, symmetrization,
   repeated-index corrections, N=9 counting, and exact residual bounds.
   `ClaudeL1/` instantiates the concrete reduced rational D60 certificate.
2. `LP/`, `ThomsonN9/Bernstein/`, and `ClaudeL2b/` supply exact minorants,
   covariance/separation bounds, and energy-slack localization.
   `ClaudeWindow/` verifies the finite interval Gram classification.
   `ScalarCertificates.sublevel_refined_gram` forces every sublevel
   configuration, after permutation, within entrywise Gram error `10^-8` of
   the candidate. Symmetry and pairwise-window coverage are conclusions,
   not hypotheses of the final theorem.
3. `Alignment` minimizes over orthogonal transformations and proves the zero
   skew moment. The Gram-Schmidt and stability modules turn labeled Gram error
   `10^-8` into aligned squared coordinate distance at most `(10^-4)^2`.
4. The local potential, geometry, stationarity, energy, and Hessian modules
   prove a quantitative local energy gap. The full ambient interval circuit
   has 37,815 nodes. Exact recipe semantics identify its entries with the
   actual augmented Hessian; rational congruence and strict diagonal
   dominance prove `candidate_augmented_hessian_posSemidef` without any
   remaining computational premise.
5. `GlobalReduction` and `Completion` combine the sublevel localization and
   local uniqueness arguments, giving the independent challenge theorem.

The mathematical account is [GLOBAL_PROOF.md](../GLOBAL_PROOF.md); the local
certificate account is [ambient_circuit/README.md](../ambient_circuit/README.md).
Numerical discovery and exact checking are separate. Lean checks the integer
and rational data through proved soundness interfaces and ordinary kernel
evaluation; there are no native or unsafe proof shortcuts.

## Pins And Provenance

- Lean: `leanprover/lean4:v4.34.1`, recorded in `lean-toolchain`.
- Mathlib: `https://github.com/leanprover-community/mathlib4.git`, commit
  `d13f23b723b8a846827a245b89c10fc7d3f11612`.
- All nine external dependency revisions: `lake-manifest.json`.

No proof source was copied from the N=7 or N=8 repositories whose relevant
licensing was not established. Eight Apache-2.0 Delsarte sources supply
Schoenberg positivity; their upstream revision, compatibility edits, and
license are in `vendor/DELSARTE_PROVENANCE.md` and `vendor/DELSARTE_LICENSE`.
Mathlib retains its own Apache-2.0 license.

User-authorized Claude sources are preserved unchanged under `ClaudeWindow/`,
`ClaudeL1/`, `ClaudeL2b/`, and `ThomsonN9/Bernstein/`. Exact hashes and import
reviews are recorded in `../verification/CLAUDE_FORMAL_IMPORT.json`,
`CLAUDE_L1_IMPORT.json`, and `CLAUDE_L2B_IMPORT.json`.
`Certificates/ReducedEnergy.lean` adapts the user-supplied Astra Pro proof;
see `../verification/ASTRA_PRO_REVIEW.md`. Contributor support material is
under `../formal_support/`. One manually authored helper, `CircuitMatrices`,
retains a historical "Work draft" comment despite its checked promotion;
that comment does not add a hypothesis or change its proof content.

## Serialized Reproduction

Use the pinned toolchain and one coordinated compiler session. From this
directory on Windows:

```powershell
lake exe cache get
powershell -NoProfile -ExecutionPolicy Bypass -File verification/CheckSource.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File verification/Build.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File verification/CheckAxioms.ps1 -LogName LOCAL_AXIOMS.log
powershell -NoProfile -ExecutionPolicy Bypass -File verification/RejectCorruptCoefficient.ps1
```

`Build.ps1` lists all registered local source roots, orders imports, builds
each `+Module` serially, then runs the ordinary default build. **Do not begin
with an unrestricted default build of a cold local proof cache.** Use
`Build.ps1 -ListTargets` to inspect the sequence without compiling. Supply
`-Lake <absolute-pinned-lake.exe>` when Lake is not on PATH.

The package sets `moreLeanArgs = ["-j1"]`. The helpers additionally
save/set/restore `LEAN_NUM_THREADS=1`; direct axiom, mutation, and fresh-fixture
invocations pass `-j1`. Both controls matter because this compiler shell
does not take its thread default from that environment variable. See
`verification/RESOURCE_CONTROLS.md` for pinned source evidence. No exact
operating-system thread count is claimed.

Generated data and aggregate imports require substantial free committed
memory as well as physical memory. The serial helper has no host-memory gate;
the separate source-only verification runner does. A resource failure or
interrupted process is incomplete, never a mathematical rejection control.

For a clean check, use a new source-only copy with no local `.lake` or proof
objects, fetch the pinned external dependencies, and follow the serial
procedure. Do not delete an active workspace cache. Pinned cached Mathlib is
disclosed separately from rebuilding this project's sources; local dependency
junctions and development caches are not distributable proof artifacts.

## Verification Evidence

The source scanner rejects placeholders, added axioms, unsafe/native proof
shortcuts, and explicit kernel-bypass mechanisms. Its parser handles comments,
strings, apostrophe identifiers, and case-sensitive names; see
`verification/SOURCE_AUDIT_REPAIR.md`. The coefficient control changes a real
enclosure integer in a separate file and demands the expected mathematical
failure, not merely an arbitrary nonzero exit or an import failure.

Historical component logs retain their original scope. In particular, the
198-theorem audit covers only an earlier 35-file foundation and eight vendor
files; it is not an audit of the complete current package. Later contributor,
interval, congruence, semantic-mutation, and final-theorem runs have separate
reports. Source coverage and successful closure replay are distinct claims.

Final release verification is recorded outside these frozen sources by the
source-only run's `FREEZE.json` and `fresh-evidence/.../RESULT.json`, including
the exact source, toolchain, local objects, dependency cache, module sequence,
axiom reports, and corruption-control evidence. A successful source-only run
and any independent second-kernel results must be read from those reports;
this README does not substitute a prose assertion for them.
