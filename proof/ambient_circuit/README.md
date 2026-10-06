# Ambient Hessian Arithmetic Circuit

The actual ambient Hessian interval computation and its mathematical
interpretation have now been replayed successfully in Lean. This certificate
proves the candidate's augmented-Hessian lower bound; it is one component of
the global proof, not a standalone global optimality theorem.

`ambient-circuit-k0.json` represents the candidate-coordinate construction,
ambient constrained Hessian, rotational/normal augmentations, rational
congruence, and final 729 interval entries as a shared arithmetic DAG.
Every endpoint is an integer divided by `2^180`. Constants are exact integer
numerator/denominator pairs, and there is one real parameter input.

The preferred K=0 circuit has 37,815 nodes and 4,929,510 bytes: 18,765 additions,
18,527 multiplications, 330 constants, 72 positive reciprocals, 38 square roots,
82 negations, and one parameter node. No normal augmentation is needed in that
circuit. The separate K=10000 and K=1000000 circuits are retained as backups;
they each have 37,912 nodes.
The Python generator takes about one second on the current host; this is not
a prediction of Lean checking time.

## Exact Checks Performed

`check.py` independently validates every node by integer inequalities:

- Rational constants use cross-multiplied endpoint comparisons.
- Addition and negation use endpoint order comparisons.
- Multiplication checks all four endpoint products, without numerical rounding.
- Positive reciprocals check signs and the two cross products against `scale^2`.
- Square roots check signs and squared integer endpoint inequalities.
- Every operand reference must point strictly backwards.

Every final entry is then checked against the exact coarse bounds used by the
ambient diagonal-dominance interface. All three circuits passed these
checks. Three mutations were rejected: a false square-root upper bound, a
forward reference, and a false product bound.

```powershell
python ambient_circuit/check.py ambient_circuit/ambient-circuit-k0.json --negative-controls --report ambient_circuit/check-k0.json
```

## Formal Boundary

`lean/ThomsonN9/Certificates/ScaledInterval.lean` and `IntervalCircuit.lean`
have built successfully with the pinned Lean/Mathlib environment. They prove
integer-node soundness and well-founded real DAG semantics. Their printed axiom
closures contain only `propext`, `Classical.choice`, and `Quot.sound`.
`ZeroPenalty.lean` also builds and supplies the coarse 27-dimensional DD
interface for diagonal bounds `[1/1000,100]` and off-diagonal bounds
`[-1/100000,1/100000]`.

The complete finite interval replay has now passed: `AmbientKernelChecks00`
through `09` contain 296 ordinary-kernel arithmetic declarations covering all
37,815 nodes. Each of these declarations, and the genuine false-sqrt rejection
control, depends on no axioms. `AmbientKernelAll.node_checks` uses `propext`
and `Quot.sound`; `AmbientKernelAll.all_enclosures` uses the standard three
axioms and proves real enclosures from the explicitly stated input enclosures.

The actual coordinate prefix, all 36 pair differences, Coulomb pair blocks,
and negative half-inverse-distance terms have also been instantiated in
`AmbientKernelGeometry.lean`. These are proved equalities for `candidateAt r`
for every real `r`, not assumptions about the circuit's meaning.

`AmbientKernelAssembly.shifted_hessian_entry_sound` now also proves the full
matrix identity, including the block-Laplacian, radial Lagrange correction,
rotation columns, and subtraction of `7/50 I`, for every real `r`. Its ordinary
Lean build passed with only the standard three axioms. The successful source
hash is `d7212e6b5138c2914862514d5e69b2aaf194131cde77d47c726b61020c24942e`.

All 1,458 congruence dot products, their table-wiring identities, the candidate
input bounds, and all 729 final-entry widening inequalities have now passed.
`AmbientHessian.candidate_augmented_hessian_posSemidef` proves, for every
`r : CandidateParameter`, the actual statement

```text
(constrainedHessian (candidate r)
 + rotationColumns (candidate r) * (rotationColumns (candidate r)).transpose
 - (7/50) I).PosSemidef
```

There are no remaining circuit-identity or enclosure premises in this theorem.
Its axiom closure is exactly `propext`, `Classical.choice`, and `Quot.sound`.
The final source hash is
`eb16c7556934f39c50d88cbe76dd67b13dfeb2f91fa75f823af2c7b4e3025322`.

The separate `check_ambient_dd.py` independently reconstructs the intended
Hessian and proves interval enclosures with exact arithmetic. It remains a
separate audit, rather than part of Lean's trusted proof path.

## Congruence Recipes

`export_recipes.py` recovers shared-node recipes for both matrix products in
`C^T * (A * C)`. The independent `check_recipes.py` passed all 1,458 dot products,
checking 78,732 scalar smart-add/multiply steps. Each step is either an actual
backward-referencing circuit operation or elimination of an exact zero or one.
The final output indices exactly match the frozen circuit. No arbitrary
constant folding is used by this stage.

`CircuitAlgebra.lean` has built successfully and proves the corresponding
generic real-semantics lemmas and finite-dot-product induction. These recipes
address only the matrix-congruence stage. `AmbientKernelGeometry` and
`AmbientKernelAssembly` provide the separately proved interpretation of the
first 2,588 nodes as candidate coordinates and geometric Hessian entries.

## Kernel Benchmark

The 1,000-node literal-trace test also passed, including a genuine arithmetic
negative control: the first square-root node retains its valid operation and
backward reference, but its enclosure is changed to `[0,0]` despite a strictly
positive radicand interval. Lean proves the corrupted Boolean check is false.
Both finite acceptance and rejection theorems have no axioms.

The profiled import-only baseline took 22.86 seconds and peaked at 1.91 GB
working set / 4.18 GB private commit. The 1,000-node test took 55.79 seconds,
including 16.3 seconds tactic execution and 15.0 seconds kernel checking; its
peaks were 4.00 GB working set / 6.35 GB private commit. These are sampled host
measurements, not portable resource guarantees. Logs and reports are under
`verification/circuit-*-benchmark.json*`.

A monolithic extrapolation to 37,815 nodes was not justified by this result.
The subsequent full replay therefore split check declarations and reduced
literal data-block size.

The controlled chunked trial now also passes: 16-node literal blocks and
128-node proof declarations, using one Lean worker and an 8 GiB Lean heap limit.
It took 24.66 seconds, with 4.11 seconds tactic execution and 3.60 seconds
kernel checking, and peaked at 2.01 GB working set / 4.35 GB private commit.
Import caches were warmer, so direct arithmetic timings are more comparable
than total wall time. The arithmetic rejection theorem also passed.

`CircuitCoordinates.lean` has now built. Its `coordinate_recipe_sound` theorem
proves that the fixed 20-operation prefix evaluates to all 27 coordinates of
`candidateAt r`, for every real parameter `r`. This is a genuine mathematical
interpretation of the coordinate prefix, not an assumed identity. The concrete
literal prefix and all 36 pair-block recipes subsequently passed in
`AmbientKernelGeometry`; the full matrix interpretation subsequently passed
in `AmbientKernelAssembly`.

## Complete Interval Replay

The twelve literal data/check/aggregate modules built in 1,059.71 measured
seconds in total. The data-definition build peaked at 8.90 GB private memory;
later checking modules used about 4.6 GB. The aggregate enclosure proof took
51.25 seconds and 4.85 GB private memory. These are sampled host measurements,
not portable resource guarantees; the heap cap does not include all process
overhead. The runner is serial and gates each module on available memory.

`verification/ambient-lean-trace-audit.json` records the successful builds and
isolated regeneration hash agreement. `audit_lean_trace.py` verifies this
metadata and axiom-print output; it is not a substitute for rerunning Lean.
The final enclosure theorem's source hash is
`cad6b0871f0a0dbc581398e73ecb35a5e557a93c7d1d38c6e2dfcb0bed92d1db`.

## Complete Semantic Replay

The nine literal congruence modules took 239--306 seconds each. The aggregate
table-identity module passed in 428.76 seconds under a 600-second bound, with
4.98 GB sampled private memory. Bounds and the final PSD theorem took 40.03
and 24.44 seconds. The recorded semantic builds total 3,247.05 seconds,
separate from the interval replay above.

The first Bounds attempt encountered a nonreducing rational decidability
instance, not a rejected inequality. The successful version checks integer
cross-products and proves their implication for rational endpoint inclusion,
with positive scale required explicitly. The failed report is preserved;
`verification/circuit-bounds-replay.json` records the successful version.

`audit_lean_semantics.py` checks successful build records, actual axiom-print
output, delivered source hashes, and isolated regeneration. Its report is
`verification/ambient-lean-semantics-audit.json`. It is a metadata audit, not a
replacement for a fresh Lean source build.
