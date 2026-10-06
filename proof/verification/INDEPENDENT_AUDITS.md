# Independent Adversarial Audits

The user's requested collaboration with the active Claude agents was conducted
through the shared `claude/` workspace and explicit handoff files. These are
independent AI-agent implementations and reviews, not external human peer review.
They do not replace a Lean kernel proof.

Snapshots below were copied unchanged on2026-10-05 at17:30UTC. Original audit
scripts, reports and reproduction commands remain in the workspace paths
specified inside them. The immutable SOS certificate audited in every case has
SHA256 `c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9`.

- [Complete architecture audit](external/CLAUDE_ARCHITECTURE.md): independently
  reconstructed all computational premises and reviewed every analytic link
  from arbitrary nine-point configurations to optimality and congruence.
- [Hermite and localization audit](external/CLAUDE_HERMITE.md): independent
  interval root, confluent interpolation, energy enclosure, remainder sign,
  and full residual checks.
- [Finite Gram rigidity audit](external/CLAUDE_RIGIDITY.md): independent
  ordinary-Gram/Arb classification matches the original doubled-Gram/Fraction
  classification, including all eight cliques and the antipodal exclusion.
- [Exact SOS checker audit](external/CLAUDE_SOS_INTEGER.md): independent full
  polynomial implementation with no project imports; exact agreement on the
  final residual,103 differential agreements, and extensive mutations.

Each reports no critical or major mathematical defect, with minor findings
recorded explicitly. The architecture report supports status B, not A.

## Responses to Findings

The SOS checker now reports its domain, basis and determinant multiplier;
rejects floating-point or boolean rational inputs; checks integer n/degree;
and enforces optional localization inside its callable API. The global replay
checks U against the LP threshold and all cross-stage constants. Documentation
was updated from the former partial-result status. We clarified that our own
FLINT audit shares basis specifications; Claude's verifier independently
reimplements those specifications.

The independent anchor lemma at threshold1/100 is a useful optional
strengthening, but it has not silently replaced the delivered125/672
classification or the existing covariance proof. Original source pins, Lean
axiom reports, and all remaining formalization obligations stay explicit.

## Later Direct-Polynomial Route

After the first four audits, an additional exact Bernstein route proved the
minorant without Hermite interpolation, using1655 global leaves and seven
exterior leaves with gap1e-46. Its full-chain replay passed. The separate
[Bernstein audit](external/CLAUDE_BERNSTEIN.md), copied unchanged at18:06UTC,
independently reconstructed every leaf using polynomial homogenization,
checked the coverage and endpoint rounding, and ran34 mutations with zero
unexpected acceptances. It found no mathematical or computational defect.

Its minor documentation and robustness findings were addressed: the seventh
true window is explicitly identified as antipodal; `GLOBAL_PROOF.md` now
describes both valid proof paths; and the global replay compares the Bernstein
checker's exact radius bracket with the Lean radius literals. The standalone
minorant checker intentionally proves only its advertised minorant/gap facts;
the full-chain checker additionally enforces the exact h/U/SOS linkage.

## Algebraic Local Route

The separate [ambient local audit](external/CLAUDE_LOCAL_ALGEBRAIC.md) reviewed
`LOCAL_ALGEBRAIC_PROOF.md` and independently rebuilt the K=10000 Hessian
certificate with rigorous Arb arithmetic. It confirmed every algebraic
constant and the direct-chord argument. False Hessian/formula mutations were
rejected, and167 numerical stress configurations showed no violation. These
numerical tests are diagnostics, not proof premises.

The audit found no mathematical error. It correctly noted that one built-in
negative control rejected an altered penalty through a parameter whitelist,
not matrix arithmetic. Its additional false-Hessian controls address that
testing weakness. The audit also suggested testing zero normal penalty.

At 18:33 UTC, Claude's independent 600-bit Arb implementation confirmed the
new zero-penalty certificate, SHA256
`ebe7f302de10f503adce62b92eb9f46cb3090c26684629629eff2dfa3bc957e3`.
It rebuilt the 27 by 27 matrix without importing project code, checked the
radius bracket and unit upper triangular congruence, and found a strict
diagonal-dominance margin of approximately `0.002748630762078727`.
False matrices with shift `0.145` or `0.20`, omitted rotational augmentation,
flipped Lagrange correction, or pair-Hessian factor 2 instead of 3 were all
rejected. The original scripts are
`claude/audit/local_algebraic/w2_la_06_dd_k0.py` and its companion JSON report.
Consequently the zero-penalty local bound is `0.04246*rho^2` at radius `1/500`,
strictly stronger than the required `rho^2/50`.

## Refined Windows

The [refined-window audit](external/CLAUDE_REFINED_WINDOWS.md), copied unchanged
after its 18:39 UTC completion, independently reconstructed all seven leaves
by polynomial homogenization. It verified interval covering, endpoint
rounding, color nesting, and the use of an optimal orthogonal alignment for
the local skew-moment condition. All 16 adversarial mutations behaved as
expected. Its independently derived Gram-Schmidt constant is much sharper
than the deliberately loose 10000 used in the current formalization draft.

Two minor findings were addressed. The standalone refinement checker now
compares its polynomial to the source SOS certificate and validates the
source hash, rather than leaving that linkage solely to the full replay.
Its six built-in negative controls include changed-polynomial and wrong-hash
mutations. Documentation no longer overstates generator/checker independence:
for these seven single leaves both project implementations use the same
binomial-shift conversion, whereas Claude's reconstruction is different.
