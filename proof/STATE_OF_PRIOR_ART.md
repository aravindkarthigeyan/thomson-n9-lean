# State of rigorous Thomson proofs and reusable formal infrastructure

Audit date: 2026-10-05. Energies here count unordered pairs. The source audits
linked below distinguish source inspection, exact certificate execution, and
local Lean builds. The mathematical N9 work is independent of tabulated
coordinates or an assumed optimum.

| N | Rigorous minimum and equality type | Main proof and source | Formal proof inspected | Reusable part |
| --- | --- | --- | --- | --- |
| 2 | `1/2`, antipodal pair | Diameter bound; simplex case of Cohn-Kumar | No complete case formalization located in this search | Distances at most 2; equality gives antipodality |
| 3 | `sqrt(3)`, equilateral great-circle triangle | Centroid identity plus strict convexity; simplex case | No complete case formalization located | Gram equality and centroid moment |
| 4 | `3 sqrt(3/2)`, regular tetrahedron | Yudin 1992; Cohn-Kumar universal optimality | No complete case formalization located | Simplex LP and deletion bounds |
| 5 | `1/2+sqrt(3)+3sqrt(2)`, triangular bipyramid | Schwartz, arXiv:1001.3702 / Experimental Mathematics 22 (2013) | Original computer-assisted Java/interval proof downloaded; no Lean version located | General-N stereographic box estimator, second-order interpolation error, local Hessian closure |
| 6 | `3/2+6sqrt(2)`, octahedron | Yudin 1992; Cohn-Kumar Theorem 1.2 | No complete case formalization located | Quadratic Hermite minorant and positive Legendre coefficients |
| 7 | Pentagonal bipyramid, unique modulo O(3) and labels | Tran repository paper and `thomson_seven`, `thomson_seven_unique` | Actual final Lean theorem bodies inspected and rebuilt axiom audit recorded separately | Arbitrary-N three-point/typed positivity, minimum-pair slabs, exact PSD and polynomial checkers, local rigidity |
| 8 | Optimized square antiprism, unique modulo O(3) and labels | Kryvonos-Liehr-Taylor, arXiv:2609.22077 | Primary proved showcase and independent Warrant Complete theorem bodies inspected; build status below | Algebraic-parameter certificate correction, generic moment positivity, exact dyadic checks, contact classification |
| 12 | Regular icosahedron, unique modulo O(3) and labels | Cohn-Kumar, arXiv:math/0607446; earlier Andreev antecedent | No complete case formalization located | Sharp spherical-design Hermite LP and equality analysis |

All uniqueness claims in this table are claims of the cited mathematical
proofs. A failed search for a formal proof is not a nonexistence result.

## Repositories and pinned versions

| Repository | Exact commit inspected | Lean | Mathlib commit |
| --- | --- | --- | --- |
| [huwngtran/thomson-n7-lean](https://github.com/huwngtran/thomson-n7-lean) | `25f2fa53119273458cfbb3c4230904bffdd61e53` | 4.34.1 | `d13f23b723b8a846827a245b89c10fc7d3f11612` |
| [lukasliehr/Energy-Minimization-8-Points](https://github.com/lukasliehr/Energy-Minimization-8-Points) | `50d14bc06bd41f61573eb6a36eedb8d00759af8f` | 4.33.0 | `db584cd6d46c92f209a44c0f1c829460d327499d` |
| [jstoobysmith/Thomson-N-8-Warrant](https://github.com/jstoobysmith/Thomson-N-8-Warrant) | `2c35d62e07d72686931da4bc3e062d668e858eda` | 4.33.0 | `db584cd6d46c92f209a44c0f1c829460d327499d` |
| [specialjcg/delsarte](https://github.com/specialjcg/delsarte) | `f0724e16b01d4561ee6cda8cd56db4db03de0496` | 4.33.1 | `0df444a360eaa60ab8c11dca51a86af692955474` |
| [openai/ten-proofs](https://github.com/openai/ten-proofs) | `94bc0feb6a9ff12c7d31d6de640a725c9d43d2b6` | 4.32.0 | `81a5d257c8e410db227a6665ed08f64fea08e997` |
| [math-inc/Sphere-Packing-Lean](https://github.com/math-inc/Sphere-Packing-Lean) | `1e98fb493088948ca7bbf47d7faed49cc5b39fc4` | 4.28.0 | `8f9d9cff6bd728b17a24e163c9402775d9e6a365` |
| [leanprover/sos](https://github.com/leanprover/sos) | `fb7ae417609093f04cf0608dc92e9343550c2ae4` | 4.33.1 | `0df444a360eaa60ab8c11dca51a86af692955474` |
| [validsdp/validsdp](https://github.com/validsdp/validsdp) | `083e96683cf7087492d4d57e87c546264c2170c1` | Rocq, not Lean | N/A |

Mathlib URL: <https://github.com/leanprover-community/mathlib4>. Full transitive
pins are preserved in the cloned manifests. The original paper PDFs and source
archives are retained under `../../work/prior/`; their SHA256 hashes and download
URLs are in the detailed audits.

## What was actually ingested

- [N7 audit](prior/N7_AUDIT.md): theorem statements, proof architecture, exact
  kernel/certificate formulas, source-line map, cap/slab constants, axiom audit,
  and independent build details. The N9 stretch target in its challenge is
  not a proved theorem.
- [N8 audit](prior/N8_AUDIT.md): both repositories, paper, full Coulomb proof
  chain, exact correction of floating centers, checker negative control, and
  build details. `Showcase.lean` and Warrant's default target are insufficient
  evidence; the proved showcase and Complete target matter.
- [Older proofs](prior/OLDER_PROOFS.md): downloaded original Schwartz and
  Cohn-Kumar PDFs/TeX, original Electron Champ and later TBP source archives,
  Yudin's original paper, detailed estimator equations, and deletion bounds.
  Andreev's paper was located bibliographically but not obtained in full.
- [Formalization search](prior/FORMALIZATION_SEARCH.md): actual opened theorem
  declarations for general Schoenberg positivity, spherical-code LP, higher
  code hierarchies, Gram PSD, and Lean/Rocq SOS certificate soundness. These are
  not represented as pre-existing N9 proofs.

The N7 and primary N8 repositories contain no license grant found in the
inspected commits. Their mathematical arguments informed independent code;
their source was not copied into the N9 package. Warrant's README declares
Apache 2.0. Licenses and auxiliary build limitations are recorded individually
in the source audits.

The N9 package now vendors the eight-file Schoenberg dependency closure from
the pinned `specialjcg/delsarte` commit, under its Apache2.0 license. Six files
are unchanged. `Fischer.lean` and `Zonal.lean` have only the minimal coefficient
API compatibility edits needed by the pinned N9 Lean/Mathlib version. Original
Git blob hashes and the precise changes are in
`lean/vendor/DELSARTE_PROVENANCE.md`. The closure and the N9 all-degree LP and
covariance adapters passed ordinary Lake builds and axiom audits, using only
`propext`, `Classical.choice`, and `Quot.sound`.

## Comparison of the certificate machinery

Both proofs use the same three-dimensional Chebyshev recurrence
`Q0=1`, `Q1=t-uv`, `Q(k+2)=2(t-uv)Q(k+1)-(1-u^2)(1-v^2)Qk` and symmetrized
moment matrices. Repeated-index terms must change with N. For N9 the kernel
is `7S+S(u,u,1)+S(v,v,1)+S(t,t,1)+S(1,1,1)/8`, and the energy divisor is 36.

N8 constructs a sharp identity at an algebraic parameter. Positive definite
blocks at a rational center survive an exactly bounded linear correction;
two omitted coefficient equations follow from candidate evaluation and
stationarity. Its contact rigidity finishes global uniqueness.

N7 uses strict rational bounds on a minimum-pair cover, leaving a nearly sharp
cap whose small slack forces class-specific Gram windows. Integer Kronecker
identity checks and explicit PSD decompositions verify its finite certificates.
Combinatorial classification and a quantitative local Hessian estimate finish
the cap. Its generic typed theorem supports nonuniform root kernels and pair
shares, which informed the joint Codex/Claude N9 investigation.

The independent N9 checker takes a different exactification route: rational
Gram factors guarantee PSD and every coefficient residual is paid explicitly.
For the final degree-20 certificate, interval Hermite interpolation proves the
minorant and its exterior slack. The exact energy loss below `10^-92`, combined
with seven-window Gram rigidity and a quantitative local theorem, closes the
global mathematical proof. It needs neither an exactly sharp algebraic identity
nor unproved numerical row dependencies. The Lean route now uses a reduced
rational certificate and direct Bernstein minorants. Its concrete global
certificate, finite Gram classification, refined sublevel localization, and
quantitative alignment have compiled; the full ambient interval trace and
actual Hessian-entry interpretation have also passed. The final congruence
arithmetic/PSD closure and unconditional global theorem assembly have since
compiled, with an independent 4056-declaration standard-axiom audit. The frozen
v4 source-only run records passes for all 181 modules and 23 final audit/control
steps; `STATUS.md` tracks its separately recorded metadata completion and
remaining release checks. None of
this completes the separately unfinished N8 primary or Warrant builds.

## Current N8 Reproduction Scope

The latest fresh ordinary-Lake plan selects 1,443 modules in the primary
package and 834 in Warrant, including its genuine `Thomson.Complete` and
public `Solution` endpoints. Warrant's core closure alone is 832; an optional
generator and an unimported experimental module would make a broader 836-file
inventory but are not part of the selected proof closure.

The new runner has passed 34 pure/synthetic checks and nine tiny-process
guard tests. These test orchestration, not any N8 theorem. Fresh pinned
checkouts, an explicit single-worker overlay, ordinary source compilation,
original external-cache binding across resumes, and final type/axiom checks
are still required. No old experimental local proof objects will be reused.
Codex and Claude agreed that these runs follow the final N9 verification
window, with bounded resource attempts and no automatic escalation. The
historical primary checkpoint remains a mixed-mode partial Coulomb build
through 232 of 1,193 modules; neither full N8 package is newly reproduced.
