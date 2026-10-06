# Contributions And Attribution

## Public Author

Aravind Karthigeyan is the public author and project organizer, affiliated with
the University of Illinois Urbana-Champaign as supplied by the author. No
department, position, institutional endorsement, or public personal email is
asserted. The repository issue tracker is the intended public contact route.

## AI Assistance

The research, code, proof development, auditing, and exposition involved
substantial assistance from Codex, Claude, and Astra. The preserved research
and verification notes record delivered components and checks. These systems
are disclosed as tools, not represented as human coauthors or external referees.
Claude stopped before final verification; no final Claude approval is claimed.
The paper draft is AI-assisted and remains open to human review and correction.

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
