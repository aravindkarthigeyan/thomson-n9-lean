# Contributions And Attribution

## AI Generation Credits

The generating systems receive the prominent credits in this artifact:

- **Claude Opus 5.5**: task-scoped runtime metadata records `claude-opus-5-5`.
- **Codex using GPT-6 Astra with Ultra reasoning effort**: task-scoped runtime
  metadata records `gpt-6-astra` and effort `ultra`.
- Additional imported **Astra Pro** artifacts contributed to the work. Their
  exact backend model has not been independently verified and is not inferred
  from the verified Codex session metadata.

These are generation credits for an AI-generated research/software artifact,
not assertions that AI tools are human authors, legal persons, independent
referees, or eligible authors at a particular publication venue. The label
"Ultracode" is not established by the inspected metadata. Private runtime
logs are not distributed; this attribution audit does not modify the proof.

## Human Role And Correction

Aravind Karthigeyan directed the task, supplied materials and resources, and
arranged publication. He has clarified that he did not write the proof or
manuscript and does not want a human author byline on this artifact. Version
0.1.1 corrects that attribution. His account ownership, publication actions,
and retained licensing notices are distinct from proof or manuscript authorship.
The repository issue tracker remains the public contact route.

The mathematical exploration, certificate generation, Lean development,
auditing, and exposition were substantially AI-generated, not merely
language-edited. The preserved research and verification notes record the
delivered components and checks. This disclosure does not assign every file
to a particular model without evidence.
Claude stopped before final verification; no final Claude approval is claimed.
The paper remains open to human review and correction. Human accountability
requirements of external hosts are not replaced by AI generation credits.

## Prior Mathematical And Formal Work

- Hung Tran's N7 proof and its SDP-to-local-rigidity architecture:
  https://github.com/huwngtran/thomson-n7-lean
- Liudmyla Kryvonos, Lukas Liehr, and Mitchell A. Taylor's N8 paper and exact
  certificate development: https://arxiv.org/abs/2609.22077 and
  https://github.com/lukasliehr/Energy-Minimization-8-Points
- Joseph Tooby-Smith and Alex Zughaid's N8 formal development:
  https://github.com/jstoobysmith/Thomson-N-8-Warrant
- Richard E. Schwartz's five-point computer-assisted proof:
  https://arxiv.org/abs/1001.3702
- Henry Cohn and Abhinav Kumar's universal-optimality framework:
  https://arxiv.org/abs/math/0607446
- The three-point SDP framework of Bachoc--Vallentin and Cohn--Woo.
- Mathlib, Lean, the exporter, and the independent nanoda kernel implementation.

Detailed inspected commits, theorem scopes, and reuse provenance are recorded
in [STATE_OF_PRIOR_ART](proof/STATE_OF_PRIOR_ART.md). These researchers and
maintainers have not endorsed this N9 release.

## Reused Source

Eight Delsarte source files are retained with their Apache-2.0 notices and
documented compatibility modifications. See
[the source provenance](proof/lean/vendor/DELSARTE_PROVENANCE.md).
Other upstream license notices remain authoritative for their associated
material. A general project license does not replace those notices.
