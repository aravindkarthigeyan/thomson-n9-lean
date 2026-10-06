# Version 0.1.1: Attribution Correction

This attribution-only release removes Aravind Karthigeyan from the proof and
paper author byline at his request. He directed and published the project,
but does not claim to have written the proof or manuscript.

The artifact now prominently credits **Claude Opus 5.5** and **Codex using
GPT-6 Astra with Ultra reasoning effort** as the generating systems. Separate
imported Astra Pro contributions are disclosed without inventing their backend
model. These are AI generation credits, not human academic authors or provider
endorsements. See `ATTRIBUTION_CORRECTION.md` and `CONTRIBUTIONS.md`.

The Lean proof, exact certificates, and prior verification evidence are
unchanged. The regenerated paper and attribution documents have a new release
inventory and checksums. No new full Lean build or new independent-kernel run
is claimed for this attribution update.

The v0.1.0 tag remains unchanged. Its Zenodo DOI
`10.5281/zenodo.23192843` identifies the older files, not v0.1.1. Current
v0.1.1 is a GitHub release; no new Zenodo DOI or arXiv submission is claimed.

## Included

- The independent statement, exact candidate, unconditional final theorem,
  numerical discovery code, and exact certificate checking data.
- The selected D60/Bernstein/Gram-rigidity/ambient-Hessian proof guide.
- Historical source-only build evidence and successful nanoda result.
- The separately checked bridge to the actual N9 target in the N7 project.
- An AI-generated review-paper draft, not an externally reviewed article.
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
