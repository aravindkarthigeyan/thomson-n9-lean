# Version 0.1.0: Research Release

Global optimality and uniqueness for the classical nine-point Coulomb Thomson
problem, formalized in Lean 4.34.1 with pinned Mathlib. External review and
fresh-machine reproduction are requested.

## Included

- The independent statement, exact candidate, unconditional final theorem,
  numerical discovery code, and exact certificate checking data.
- The selected D60/Bernstein/Gram-rigidity/ambient-Hessian proof guide.
- Historical source-only build evidence and successful nanoda result.
- A new, separately checked bridge to the actual N9 target in the N7 project.
- An AI-assisted review-paper draft, not an externally reviewed article.
- Privacy-redaction provenance, release inventory, attribution, and licenses.

## Verification Scope

Original source verification: 181 Lean modules and 23 audit/control steps;
complete theorem export: 55,248 declarations accepted by nanoda. Only
`propext`, `Classical.choice`, and `Quot.sound` occur in final theorem closures.
The supplemental upstream-statement bridge has its own Lean/type/axiom check;
it has not received a separate nanoda or Lean Comparator application run.

The public copy's exact rational arithmetic replay passed. A publication hash
audit establishes unchanged original Lean sources and certificate data, not a
second new full Lean build. See `VERIFY.md` for reproduction and limitations.

Private paths and coordination messages in historical evidence have been
redacted. The public archive therefore has a different hash from the original
local source archive; `PUBLICATION_DERIVATION.json` records the mapping.

No claim is made of peer-review acceptance, an independently reproduced build
by another operator, or established first-priority. The known incomplete
ancillary N8 reproductions are disclosed and are not premises of the proof.
