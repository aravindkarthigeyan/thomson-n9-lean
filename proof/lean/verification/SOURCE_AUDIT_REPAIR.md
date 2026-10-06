# Source-Audit Identifier Repair

During independent review of the newly imported Bernstein modules, the source
coverage scanner was found to truncate the declaration `exterior_gap'` to
`exterior_gap`. Its old identifier expression allowed only ASCII letters,
digits, underscores, and dots. Thus the initial 606-declaration coverage report
for the expanded source tree omitted one distinct new theorem. That report was
only a source-level preflight, not the consolidated kernel replay.

`CheckSource.ps1` now includes apostrophes and Unicode letter/digit categories
in theorem names. `Solution.lean` explicitly prints the axiom closure of
`ThomsonN9.Bernstein.exterior_gap'`. The declaration itself was already present
and proved in the imported source; this repair concerns completeness of the
audit inventory, not a proof alteration.

The closure-log parser in `CheckAxioms.ps1` was also extended to allow internal
apostrophes in the quoted Lean name. Previously it would have reported the
newly requested name as missing, rather than silently accepting an unchecked
closure. Synthetic apostrophe-name reports, with and without axiom lists,
were tested against the repaired expression before the consolidated replay.

Identifier deduplication, coverage comparison, and allowed-axiom comparison
are now explicitly case-sensitive, matching Lean identifiers rather than
PowerShell's default string comparisons. No affected historical name or axiom
was found. In particular, a hypothetical `Propext` is not accepted as the
standard axiom `propext` by the repaired checker.

The forbidden-token preflight was also strengthened to reject local uses of
`debug.skipKernelTC`, `debug.byAsSorry`, `implemented_by`, `ofReduceBool`,
`ofReduceNat`, and `extern`, in addition to the previous unchecked-proof and
native-computation tokens. This deliberately conservative project-source
policy does not scan or rewrite Lean's runtime or Mathlib internals. Harmless
resource settings such as `maxRecDepth` and `maxHeartbeats` remain allowed.

## Historical Snapshot

The preceding 198-theorem audit is not affected by this identifier issue:

- All 32 theorem-bearing `ThomsonN9/` source files in
  `EXTENSION_SOURCE_CHECK.log` still match their recorded SHA-256 hashes.
- A fresh broad-name scan of those exact files found 197 public declarations,
  none containing an apostrophe or any character excluded by the old pattern.
- The remaining declaration is the unchanged short
  `ThomsonN9.challenge_parameter_exists_unique` theorem in `Solution.lean`.
- The historical independent `EXTENSION_AXIOMS.log` has the corresponding
  198 distinct closure reports, including that Solution theorem.

Only the newly imported `ThomsonN9.Bernstein.exterior_gap'` was missed in the
expanded preflight. Historical logs are preserved unchanged. Later source
counts grow as additional checked circuit and localization modules are added;
they must not be confused with the immutable 198-theorem snapshot.

The source scan is a lexical inventory and forbidden-token check. The separate
`CheckAxioms.ps1` runs Lean on `Solution.lean`, requires a closure report for
every requested declaration, and rejects any axiom outside `propext`,
`Classical.choice`, and `Quot.sound`. A package build and this independent
closure replay remain required for each consolidated snapshot.

## Comment Filtering

The later ClaudeL1 import contains a block-comment line beginning `theorem below`
in `ClaudeL1/Test/Negative.lean`. The line-oriented declaration inventory initially
treated `below` as a declaration. No kernel audit was claimed for that intermediate
inventory. `LeanSource.ps1` now removes nested block comments, line comments, and
ordinary/raw string literals while preserving line breaks before declaration and
import inventory. The forbidden-token scan remains conservative over raw source.
`TestSourceScanner.ps1` exercises these cases, apostrophe names, and malformed-input
rejection. The imported proof sources were not modified. The 255 actual public
ClaudeL1 declarations, not the comment fragment, were added to the axiom audit list.
