# Portable Reproduction Instructions Review

Scope: read-only review of instructions, the actual candidate extracted source
tree, and the frozen v4 audit specification. No compiler, numerical solver,
exact certificate replay, archive creation, or promotion was launched.

## Final Reviewed Instructions

- `outputs/thomson-n9/REPRODUCE.md`: `526a6210daa507b535b2ce0f0f5fbce323577ffef8030d95b06d1ba4be4927a8`
- `outputs/thomson-n9/near_sharp/EXACTIFICATION.md`: `cb5a833b02ac48492ee3287d25435821e4165cfbe53a9cf58d35924bead72ea0`
- `outputs/thomson-n9/near_sharp/reduced/INTEGRATION.md`: `e755015e44e71e03b82e54c911966e5bfe0ffe339bead20f7537dd4b09316a5b`
- Frozen audit specification: `22bb7406fef5a4379c856c8dbca26c8f964685e2bd036f24bdb45e0f5af3d10e`.

No remaining blocking instruction or required-input omission was found in this
review's scope. The ordinary package sources are self-contained apart from the
explicitly pinned external Lean dependencies. The main Python exact route's
imports and data are retained. The numerical entry points' local modules and
input data are retained; pinned numerical packages still need installation.

## Inventory And Path Checks

The candidate extraction inspected was
`work/n9-archive-supervision/runs/candidate-v4-20261006-02/extracted/thomson-n9`.
Its `lean/verification/Build.ps1 -ListTargets` ran without any compiler: all 181
module names exactly matched `evidence/clean/targets.txt`, with no difference.
The helper and its source parser, axiom scanner, coefficient rejection helper,
final-type fixture, and 17 supplemental fixtures are present.

The optional exactification commands now use package-root paths whose required
data and code exist in that tree. The reduced integration document now points to
the selected compiled formal route. Original contributor L1 paths and omitted
generator scripts are explicitly identified as historical provenance, not
portable instructions. They are not needed to build the retained generated Lean
sources. No claim of executing these newly transcribed commands on a second
platform has been added.

## Negative-Control Repair And Tests

The first transcription omitted the frozen driver's filename and explicit
resource/import-error checks. Mock logs demonstrated acceptance of a diagnostic
from an unrelated file at the expected line, and of the expected diagnostic
followed by `out of memory`. Root repaired the prose; no proof source changed.

The final transcription was parsed using PowerShell's language parser. Its
actual negative-control `else` branch was extracted from the parsed Markdown
code block and invoked only on strings and exit-code values. No `lake` command
was invoked. For each of the four false proof fixtures, the saved stdout/stderr
provided one genuine expected-rejection control, followed by 15 mutants:

- zero, null, string, and Boolean exit codes;
- wrong filename, wrong error line, no located errors, and an extra error;
- each of the seven resource/import-failure patterns used by the frozen driver.

All 64 checks passed: four genuine rejections were recognized and all 60 bad
conditions were refused. The immediate source-scanner exit guard was also
confirmed. Both PowerShell blocks, in REPRODUCE and EXACTIFICATION, parsed with
no syntax errors. The exactification prose now identifies the actual
`check_sos_integer.py` command correctly.

These are syntax and classifier tests, not a new 204-step build receipt. The
instructions explicitly distinguish the short 181-module build from the extra
statement/fixture checks and leave axiom-report inspection visible. The frozen
driver and immutable recorded receipts remain the evidence for the historical
fully audited run. No immutable evidence or release source was changed by this
review.
