# Nine-Point Coulomb Thomson Proof Package

**A. COMPLETE FORMAL PROOF.** The unconditional global-optimality and
uniqueness theorems passed a clean Lean build and a separate nanoda check of
all 55248 declarations in the complete theorem's dependency closure. Only the
standard three axioms occur. See [STATUS.md](STATUS.md) for exact scope,
retained failures, and unfinished ancillary prior-proof reproductions.

Read [the selected formal proof](FORMAL_PROOF_GUIDE.md),
[the original mathematical proof](GLOBAL_PROOF.md), and
[status and trust boundaries](STATUS.md). See
[reproduction instructions](REPRODUCE.md); the selected exact replay command is:

```
python verify_global.py --reduced --refined
```

It uses only Python's standard library and checks all finite arithmetic
premises and cross-stage constants from the certificate data. The concrete
matrix-positivity and global theorem assemblies have compiled. Python results
are not assumptions of the Lean theorem.

## Proof Components

- [Exact candidate and energy](N9_CANDIDATE.md)
- [Proof architecture and release checks](PROOF_ARCHITECTURE.md)
- [Original Hermite minorant and contact-slack argument](near_sharp/HERMITE_PROOF.md)
- [Rational matrix exactification and adversarial checks](near_sharp/EXACTIFICATION.md)
- [Three-point certificate soundness](CERTIFICATE_SOUNDNESS.md)
- [Finite spectrum-to-Gram rigidity](rigidity/PROOF.md)
- [Original tangent-Hessian local proof and Gram alignment](LOCAL_PROOF.md)
- [Selected algebraic local proof and ambient Hessian](LOCAL_ALGEBRAIC_PROOF.md)
- [Independent complete-chain audit](near_sharp/INDEPENDENT_CLOSURE_AUDIT.md)
- [Independent Claude audit reports and responses](verification/INDEPENDENT_AUDITS.md)
- [Simpler direct Bernstein proof path](near_sharp/BERNSTEIN_PROOF.md)
- [Current Lean scope and serialized verification](lean/README.md)
- [Quantitative near-minimum stability](QUANTITATIVE_STABILITY.md)
- [Independent kernel evidence and reproduction](verification/secondary/README.md)

## Research and Provenance

- [Prior proofs, source map, repository commits, and dependency pins](STATE_OF_PRIOR_ART.md)
- [Research log, including failed routes](RESEARCH_LOG.md)
- [Degree-104 parameter equation](algebra/README.md)
- [Entire D3h-symmetric class](SYMMETRIC_OPTIMALITY.md)
- [Strict all-degree ordinary-LP ceiling](ORDINARY_LP_CEILING.md)

`certificates/`, `sdp/`, and `near_sharp/` separate numerical discovery from
exact checking. `hybrid/` and `triangle_cover/` retain unsuccessful or incomplete
alternative searches, which are not used in the completed proof.
`lean/Challenge.lean` states the independent formal targets without importing
the global proof. The unrestricted theorems are in
`lean/ThomsonN9/Completion.lean`; the selected exact dependency chain is
documented in `FORMAL_PROOF_GUIDE.md`.

The unfinished N8 reproduction build is disclosed in the prior audit. Claude
collaboration and independent review are recorded through shared handoffs in
the workspace's `claude/` folder; conclusions are incorporated only after
checking their mathematical and computational premises.

The full workspace also contains exploratory LP/SDP, branch-and-bound, and
prior-build assets that are not part of the selected proof-source release.
`REPRODUCE.md` explicitly labels their commands as workspace-only. The
source archive retains the complete chosen checker route, its exact data,
accepted Lean source, core proof/review notes, and the algebraic-parameter
certificate; current archive and verification gates are recorded in `STATUS.md`. Historical
review notes can cite original workspace paths without promising to bundle
every independent review script or failed numerical experiment.
