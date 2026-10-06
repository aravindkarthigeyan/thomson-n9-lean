# Ambient Hessian Semantic Review

Verdict: **no blocking semantic defect found** in the inspected draft chain.
This is an independent source and exact-integer recipe audit, **not a claim
that the final assembly modules have compiled**. Older-proofs owns those
sources and their subsequent build. No Lean process was launched for this
review and no reviewed proof source was edited.

## Actual Target

`AmbientHessian.candidate_augmented_hessian_posSemidef` takes only
`r : CandidateParameter` and concludes positivity of the actual matrix

```text
constrainedHessian (candidate r)
  + rotationColumns (candidate r) * rotationColumns (candidate r).transpose
  - (7/50) * I
```

The internal `flattened_posDef` theorem has an explicit Hermitian premise;
the final theorem discharges it with the existing analytic Hessian symmetry
theorem. No arbitrary matrix, free enclosure, invertibility, or positivity
hypothesis survives in this final statement. This is precisely the local
coercivity input, not a global-optimality theorem by itself.

## Entries And Signs

The distance recipe derives the actual Euclidean norm from all three squared
coordinate differences. `PairBlockRecipe.sound` produces
`3*d[a]*d[b]/norm(d)^5 - delta[a,b]/norm(d)^3`. Its finite check fixes both
powers, the literal factor 3, and the Kronecker delta. Reversing an unordered
pair is valid because this entire block is even in `d`.

The 81 diagonal sum recipes include all nine point indices. The self term is
a literal zero, with `self_coulombPairBlock_zero` proving that it matches the
total real expression at distance zero. Off-diagonal blocks are negatives of
the pair block. `pair_hessian_of_entries` then identifies the complete block
Laplacian; self-pair subtraction introduces no extra term. The existing
`blockLaplacian_quadratic` identity counts unordered pairs once, so the
matrix is the full second variation rather than twice or half of it.

The nine radial sums use `-(norm(p[i]-p[j])^-1/2)`, hence equal the existing
`radialCoefficient p i = -(sum_j norm(p[i]-p[j])^-1)/2`. Multiplication by the
literal -1 produces the correction added on the matrix diagonal. Thus the
matrix subtracts the negative radial coefficient, as required. The self
inverse term is again exactly zero under Lean's total inverse convention;
the analytic use for distinct configurations is unchanged.

The rotation entries are the checked signed-coordinate matrix

```text
  0   z  -y
 -z   0   x
  y  -x   0
```

All 729 rotation dot products therefore give `R*R.transpose`. The final
literal `-7/50` is added exactly when the complete point-coordinate indices
agree. It is not applied to a whole 3-by-3 point block.

## Index And Congruence Transport

Every flattening uses point-major index `3*i+a`. `pointMajorEquiv` proves
the exact correspondence with `Fin 27`, and its inverse is division/remainder
by 3. The final entry theorem and both reindexing directions are explicit;
there is no coordinate-major permutation silently omitted.

The first 729 dot recipes have left entries `A[i,k]` and right entries
`C[k,j]`, giving `A*C`. The next 729 have left entries `C[k,i]` and right
entries `(A*C)[k,j]`, giving `C.transpose*(A*C)`. The generic matrix-product
soundness theorem sums over every `Fin 27` index. The final identity uses
associativity to obtain `C.transpose*A*C`, not `C*A*C.transpose`.

Every below-diagonal entry of `C` is checked to be literal zero; every
diagonal entry is checked to be literal one. The generic transport theorem
proves its determinant is one using upper-triangularity, then invokes
positivity equivalence under an invertible congruence. No floating-point
determinant or conditioning estimate is used. Reindexing a positive-definite
matrix to point-coordinate indices yields the required positive-semidefinite
matrix. No numerical eigenvalue estimate is substituted for that argument.

## Interval Scales

The literal circuit has 37,815 nodes and common scale
`1532495540865888858358347027150309183618739122183602176 = 2^180`.
`ScaledInterval.Contains` means `lo <= scale*x <= hi`.
`OutputWithin` divides both integer endpoints by this positive scale before
comparing with rational output intervals. It does not compare scaled integers
directly with real matrix entries.

The input interval encloses the entire exact 40-digit `CandidateParameter`
isolating interval. Every requested output index is below 37,815, so every
output is covered by the proved DAG enclosure theorem; no default node or
unchecked tail is used. Inverses require strictly positive lower endpoints,
and square roots require nonnegative inputs and output endpoints.

All 27 diagonal outputs lie in `[1/1000,100]`; all 702 off-diagonal outputs
lie in `[-1/100000,1/100000]`. Their strict diagonal-dominance margin is
exactly `1/1000 - 26/100000 = 37/50000 > 0`. This margin proves positivity of
the congruent matrix. The desired `7/50` is already subtracted from the
original matrix, so no basis-condition factor must be applied to that value.

## Independent Finite Replay

`verification/ambient/audit_ambient_assembly.py` parses the actual Lean node
and recipe arrays, without importing any exporter. It compares literal node
data with the frozen trace, independently repeats every integer interval
check, and checks:

- 81 diagonal sums, nine radial sums, and all 729 rotation dot products;
- all actual Laplacian, radial, augmented, and shifted entry recipes;
- all 1,458 congruence dot recipes and the precise row/column wiring;
- exact unit-upper-triangularity, all 729 output bounds, and the radius bounds;
- rejection of row-for-column substitutions in both congruence products.

The replay **passed**. The smallest output diagonal lower endpoint is

```text
4212264386372459437314407722790475569588588770230857 / 2^180
```

and the largest absolute off-diagonal endpoint is
`889196830932773099 / 2^180`. These exact values are stronger than the coarse
intervals used by the formal positivity theorem.

The machine-readable report hashes all inspected source and data files.
Draft source paths identify the precise pre-compilation snapshot; subsequent
repairs or promotion require a fresh replay and fresh Lean axiom audit.
The original pair-factor, reciprocal-power, coordinate-sign, and diagonal-
shift Lean negative controls remain separately prepared until the real
assembly module has built. Offline recipe acceptance does not upgrade them
to kernel-checked results.

## Scoped Source Delta: Named Decidable Instance

On 2026-10-05 the owner renamed the anonymous `SumRecipe.Check` decidability
instance in `ThomsonN9/Certificates/CircuitSums.lean` to
`instDecidableSumRecipeCheck`, avoiding an imported declaration-name collision.
An independent byte-hash reconstruction confirms that this is the only change:
there is exactly one occurrence of `instance instDecidableSumRecipeCheck (`;
replacing it in memory with `instance (` recovers the exact prior SHA256.
No file was rewritten for that comparison.

- Prior reviewed SHA256:
  `bd1d98a66e4b539d3c1689c524186e4a4aa299b498946d75cf5ef57d5595cf50`.
- Current SHA256:
  `31a981baa9ee9766d6d133cd4b5f3ea8594fcb61307f9418d9f1e706ac2d6833`.
- Reconstructed anonymous-instance SHA256: identical to the prior hash.

The instance type, proof body, finite predicate, mathematical soundness
theorems, imports, and all other source bytes are unchanged. This therefore
does not alter the semantic conclusions of this review. The owner reports a
successful rebuild of this module; no independent compiler was run for this
delta review. The original machine-readable audit remains an immutable record
of the earlier source snapshot rather than being silently relabeled current.

## Versioned Replay After Assembly Compilation

The owner subsequently reran the independent recipe audit after mechanical
assembly proof repairs. The replay script refreshed the unversioned output
report. The original report was still available unchanged in the work
directory and has now been preserved explicitly as
`ambient/ambient-assembly-audit-initial.json`, SHA256
`c96c12088bcd5f8aecfd7b0775ade77f7b39274ac1fb7b06fb8966037561860b`.
The refreshed successful report is preserved separately as
`ambient/ambient-assembly-audit-after-assembly.json`, SHA256
`c5a65c75a83ac007b8936e659e633874e7099eb3d458fe33487bc657b5d4786a`.
The unversioned filename currently contains the refreshed report, not the
original snapshot. No earlier hash has been silently relabeled.

The owner reports that the actual `AmbientKernelAssembly` source compiled,
with SHA256
`d7212e6b5138c2914862514d5e69b2aaf194131cde77d47c726b61020c24942e`
and only the three standard axioms for its semantic entry theorems. The
subsequent congruence and positivity chain remains separate. The first
independent Lean semantic-mutation trial was resource-interrupted before a
proof verdict: the owned-process reserve guard stopped it after 11.23 seconds
when free commit fell below 1.25 GiB. This is neither acceptance nor rejection
of any mutation, and must be rerun after the resource hold is lifted.

After the user resumed work, the fresh ordinary Lean retry **passed** all 19
declarations in 28.765 seconds: seven genuine controls, eleven proved
negations of corrupted acceptance predicates, and one structural-only
sensitivity theorem. Every axiom closure is a subset of the three standard
axioms. See `ambient/SEMANTIC_MUTATIONS.md` and the independently parsed report
`ambient/semantic-mutations-lean.json`, SHA256
`24b04c240e90a591180d4239d11dd732076773ff06129deb4285d326e04c59ef`.
This successful component test does not claim the remaining congruence or
final global theorem has compiled.

## Final Delivered-Source Replay

After the owner reported successful compilation and promotion of the complete
congruence, Bounds, and AmbientHessian modules, this reviewer reran the exact
parsed-source audit using only the delivered package sources. All 37,815
arithmetic nodes, 81 diagonal sums, nine radial sums, 729 rotation dot products,
and 1,458 congruence dot products passed. The matrix order remains exactly
`C.transpose * (Hessian + R*R.transpose - 7/50*I) * C`, with unit-upper
congruence matrix, unchanged output intervals, and strict diagonal-dominance
margin `37/50000`. Both deliberate transpose mistakes were rejected again.

The new report is `ambient/ambient-assembly-audit-final-delivered.json`, SHA256
`ad1856288da2af4865e0f9a5491aa0113bf3c31cff561a3e2aec25de2ddda871`.
All earlier reports are preserved. The helper now accepts `--delivered` and
an explicit new `--report` filename; it refuses to overwrite an existing
explicit report and refuses optimized Python. Helper SHA256:
`1ee80f8dd5280ccb4b35d1058c0f50afc962637728f5c722e6f61807bdb674df`.

The only new Bounds mechanism replaces finite rational comparisons with
integer cross-products plus the proved `outputIntegerCheck_sound` bridge.
Its explicit `0 < scale` premise makes all four division directions valid:
diagonal enclosure `[1/1000, 100]` and off-diagonal enclosure
`[-1/100000, 1/100000]` are unchanged. An additional independent BigInteger
replay checked all 729 output predicates. Node and index source hashes match
the earlier snapshot exactly. Final Bounds SHA256 is
`547476f84fe1dad10c8254dd15d358de31fcea98a80a58efa66d6dc45d47896b`;
final AmbientHessian SHA256 is
`eb16c7556934f39c50d88cbe76dd67b13dfeb2f91fa75f823af2c7b4e3025322`.

This independently executed recipe replay remains distinct from Lean
compilation. The owner's successful `candidate_augmented_hessian_posSemidef`
build and standard-three axiom report are recorded by its compiler evidence;
the final project-source clean rebuild and global-theorem audit are separate
release gates.
