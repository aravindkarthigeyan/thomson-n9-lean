# Independent Source Review of L2b

Root-agent review, 2026-10-05. This records source inspection and the later
independent ordinary Lake rebuild. The nine imported files
are byte-identical to the upstream reviewed files; full hashes are in
`CLAUDE_L2B_IMPORT.json`. No proof objects were copied.

No blocking mathematical or statement mismatch was found.

## Checked Interfaces

- `ReducedMinorant` uses all 21 D60 coefficients. The finite integer check is
  delta_0 minus the sum of the absolute nonconstant coefficients, not a
  floating-point polynomial test. The generic bound uses |t|<=1 and proves
  h_new <= h_old-10^-60. This direction preserves both lower slack bounds.
- Global minorization requires -1<=t<1; the inverse-distance bridge separately
  requires distinct unit points. It does not apply the Coulomb formula at a
  collision or silently divide by zero.
- The coarse exterior gap remains 10^-46. The refined gap is 10^-33 on
  [-3/4,5593/10000], outside the six closed radius-10^-8 windows. The refined
  checker includes the square-root placement inequalities as well as the
  Bernstein positivity check. Its interval endpoints are expressions in the
  exact radius bracket, not unexplained numerical interval labels.
- Both LP covers transform with y=sqrt((1-t)/2), so 2y is the chord distance.
  The denominator is proved positive. Tail placement uses the upper square
  bound in the correct direction to cover every t>=cap, including t tending
  to 1 from below.
- The separation tail gain is exactly energyCutoff-separationBound+10^-8,
  with cutoff 6439996633/250000000 and pair cap 5593/10000. The two Horner
  numerator lists and denominators match the independently compiled root LP
  linkage. The additional `LP/ConcreteLinkage.lean` identities have now
  compiled under the stable namespaces.
- `Integration.refined_relabel` leaves the SDP pair lower bound and energy
  upper bound as explicit premises. It is not an unconditional global theorem.
  Its permutation convention matches the root's final local reduction.

## Independent Build Evidence

The upstream author and separate reviewer report successful ordinary Lean
builds, standard-axiom closures, and exact corrupt-data rejection controls.
Their full reports/logs are retained under `formal_support/bernstein2/`.
The root independently read the source and exact interfaces before importing.
The root's later replay passed all nine ordinary Lake module builds and four
fresh-import fixtures. All 75 printed closures contain only the permitted
standard axioms or no axioms. Twenty deliberate-corruption controls and the
concrete coefficient, normalization, LP, and integration statement pins pass.
The report and complete logs are in `lean/verification/l2b-import/`; the
source/object hashes are pinned in `CLAUDE_L2B_IMPORT.json`.

The first report parser omitted Lean's alternate wording for two axiom-free
declarations. All thirteen compiler invocations had succeeded. Only the
bookkeeping parser was repaired, then `--audit-existing` revalidated every
module source, proof-object, fixture-source, and log hash before re-reading
the 75 closures. The report explicitly records this validated reanalysis;
it does not claim a second complete compiler run. No proof source changed.
