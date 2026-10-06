# N=7 source and build audit

Audit date: 2026-10-05. This report separates inspected source, upstream evidence, and independently reproduced checks.

## Frozen source

- Repository: https://github.com/huwngtran/thomson-n7-lean
- Inspected commit: `25f2fa53119273458cfbb3c4230904bffdd61e53`.
- Local clean clone: `work/prior/thomson-n7-lean`.
- Lean: `leanprover/lean4:v4.34.1`.
- Mathlib: https://github.com/leanprover-community/mathlib4.git at `d13f23b723b8a846827a245b89c10fc7d3f11612`.
- All transitive dependency pins are in the checked-in `formal/lean/lake-manifest.json`; `lake update` was not used.
- Lean Windows distribution SHA256: `457698d4e2132243e899ff32178d7ae63c16431d09ed9ad524d859c3581992af`.
- `Solution.lean` SHA256 independently recomputed: `6545e982abaeb4cae0a906c74ca51cc502621aa2a05783bb8da35d96493cc9ce`.
- Comparator challenge SHA256 independently recomputed: `2cf12e8ca6bd6ebfb31ae7343ca87ed75a3ba37cbe3d6eb5abbfae483dafbaae`.
- Paper PDF SHA256 independently recomputed: `9ccefe235312032effa07f8536a135b7d6b18ad3e427715453ef6d536fd6d91d`.
- No LICENSE/COPYING file or license grant was found in the source tree. The GitHub repository API also reports `license: null`. Direct source redistribution/adaptation must not be described as licensed. This project can independently implement the mathematical arguments.

Opened and read: `REPRODUCE.md`, `info/CLAIM.md`, `info/THEOREM_MAP.md`, the complete `paper/PAPER.md`, challenge definitions and statements, final proof terms, the generic three-point bound, typed bound, certificate checker, cap/slab interfaces, and local-minimum argument in `Solution.lean`. The accompanying PDF is present in the clone; the Markdown paper is its auditable source. Large certificate numeral blocks were inspected structurally, not read digit by digit.

## What the theorem actually says

`ThomsonN7.SphereConfig n` requires both unit norm and injectivity. Injectivity matters because Lean defines the inverse of zero to be zero. `coulombEnergy` sums `norm(x_i-x_j)^(-1)` over `j` in `Finset.Ioi i`, so it counts each unordered pair exactly once.

`ThomsonN7.thomson_seven` proves the regular pentagonal bipyramid minimizes that energy among all seven-point sphere configurations. `thomson_seven_unique` characterizes equality by a `R3` linear isometry equivalence and a permutation of `Fin 7`; reflections are permitted. Both final terms project `Glue.seven_of_specs Final.a Final.K Final.hK Final.hcap Final.hslab`.

The challenge file deliberately contains three `sorry` declarations: N=7 optimality, N=7 uniqueness, and a separate N=9 stretch target. The solution proves only the first two and does not contain the N=9 theorem. Its N=9 helper `triCapPrism_mem` only proves that the parametrized family consists of nine distinct unit points for `0 < z < 1`. It is not evidence of N=9 optimality, parameter stationarity, or uniqueness.

## Technical map

All line numbers below refer to `formal/lean/ThomsonN7/Solution.lean` at the frozen hash.

| Lines / declaration | Mathematical function | N=9 reuse |
|---|---|---|
| 21-40, `SphereConfig`, `coulombEnergy` | Native Euclidean-space model and unordered energy | Recreate directly with independent names |
| 44-50, 126-187, `triCapPrism`, `triCapPrism_mem` | Top/bottom triangular rings plus equatorial caps; admissibility only | Mathematical reference, not an optimum |
| 312-398, `Base` | Norm/inner-product conversion, energy invariance under permutations and isometries | Generic in `n` |
| 515-731, `ThreePoint` | `Q3`, `Y3`, `S3`, tangent-frame positivity | Generic in `n`, specialized to ambient dimension three |
| 737-1155, `dsum`, `Rs`, `three_point_bound` | Exact ordered-triple combinatorics and energy lower bound | Explicit arbitrary `n >= 3` |
| 1228-1582 | Polynomial energy minimizers, first variation, zero-at-critical-point correction | Generic portions reusable; not needed by final basic bound |
| 1597-1945, `Kron.Ex.ev_eq_zero_of_kev` | Integer-polynomial identity by bounded Kronecker substitution | Independent of point count |
| 2096-2230, `Cert.Blk` | PSD from nonnegative outer-product pivots plus diagonally dominant residual | Independent of point count |
| 2640-2820, `Cert.Cert3` | Certificate containing `n`, scale, cut, minorant, PSD and SOS blocks | Arbitrary `n` field |
| 3886 onward, `T4`, later 11547-11993 | Exact interval exclusion of impossible four-point Gram patterns and K5 two-color rigidity | Checker idea general; pentagon classification specific to N=7 |
| 4838, `Reg.exists_gauge` | Orthogonal Procrustes alignment with symmetric cross-moment matrix | Generic `Fin n` tuples |
| 5814, `localGram_of_localMinAt` | Converts Gram windows to coordinate neighborhoods | Constants/reference configuration specific |
| 5942, `ThreePoint.three_point_bound_cut` | Bound assuming every off-diagonal inner product is at least `a` | Generic in `n` |
| 6703, 9010-9117 | Coulomb Taylor remainder, penalized Hessian, strict local minimum | Framework useful; Hessian and constants must be recomputed |
| 9588-10584, `Case1Data`, `Case1` | Degree-5 untyped SOS certificate on `m >= -9/10` | Data specific to N=7 |
| 10588-10977, `matDot_root_nonneg`, `typed_bound_comb2` | Root-dependent kernels and freely allocated pair shares | Generic in `n`; promising N=9 infrastructure |
| 11016-11200, `Typed7` | Two designated poles and five remaining vertices, three pair classes | Must rederive counts and classes for N=9 |
| 12058, `Glue1.exists_minpair_perm` | Relabel a pair attaining the smallest inner product | Mathematical reduction generic; current theorem N=7 |
| 12717-12816, `CapSpec`, `SlabSpec`, `seven_of_specs` | Precise obligations for global assembly and equality | N=7-specific target and local rigidity |
| 12905-15885 | Flat exact certificate evaluator, minorant/coercivity bridges | Several generic checkers, mixed with N=7 identities |
| 15887-17842 | Cap and five slab certificates | N=7 numerical data only |
| 17850-17893, `Final`, final theorems | Exhaustive scalar cover and theorem assembly | Architecture only |

## Three-point inequality, with normalizations checked

Let `Q_0=1`, `Q_1=t-uv`, and

`Q_(k+2)=2(t-uv)Q_(k+1)-(1-u^2)(1-v^2)Q_k`.

The matrix `Y_k(u,v,t)[a,b]=u^a v^b Q_k(u,v,t)` is paired with a PSD coefficient matrix, and `S_k` averages its six argument permutations. At a fixed root, the perpendicular components of the other vectors are represented in a complex plane. The recurrence equals the real part of `(z_j conj(z_l))^k`, and the kernel sum is the sum of two PSD quadratic forms. This establishes positivity without a numerical eigensolver.

For `s=sum_k <F_k,S_k>`, define

`R_s=(n-2)s(u,v,t)+s(u,u,1)+s(v,v,1)+s(t,t,1)+s(1,1,1)/(n-1)`.

If `H <= phi` on the pair domain and

`(H(u)+H(v)+H(t))/3-e/binomial(n,2)-R_s >= 0`

on all feasible Gram triples, then `E >= e`. Here feasibility is `u^2,v^2,t^2 <= 1` and `1+2uvt-u^2-v^2-t^2 >= 0`. The exact identity is

`sum_distinct_ordered slack + (n-2)sum_all_ordered s = 2(n-2)(sum_unordered H-e)`.

Thus N=9 requires `7s`, the boundary denominator `8`, energy divisor `36`, and final factor `14`. Merely changing the final energy target while retaining N=7 counts would be unsound.

The typed form permits a different PSD kernel `s_i` at each root and different minorants `H_ij` for each pair. Pair shares `W_ijl` must sum over eligible third vertices to `H_ij-mrg_i-mrg_j`, where `mrg_i(t)=s_i(1,t,t)+s_i(t,1,t)+s_i(t,t,1)`. The triple constants must sum, over distinct ordered triples, to `6(e+sum_i s_i(1,1,1))`. Nonnegative six-ordering triple slacks then give the lower bound. These identities are generic in `n`; the later reduction to PPR/PRR/RRR types is not.

## Why the N=7 partition closes

Write `m=min_(i<j) <x_i,x_j>`. The untyped bound excludes `m >= -9/10` by a strict margin at least `3/10000`. The remaining configurations have a designated smallest pair. Five exact typed certificates cover `[-99/100,-49/50]`, `[-49/50,-24/25]`, `[-24/25,-47/50]`, `[-47/50,-93/100]`, and `[-93/100,-9/10]`, each at the exact target near `14.45298` and hence strictly above the candidate energy.

The cap `m <= -99/100` is different: its lower bound is approximately `2.27e-16` below the optimum. This is not treated as global optimality. A certified enclosure of the candidate energy gives slack budget `511168595372501/10^30`. Nonnegative pairwise minorant gaps force each pair into a window of radius at most `1/165000` around the appropriate node: pole-pole `-1`, pole-ring `0`, ring-ring one of `(sqrt(5)-1)/4` and `-(1+sqrt(5))/4`.

Four-point Gram determinant/minor exclusion rules out a monochromatic triangle among the ring points. Exhaustive checking of the `2^10` two-colorings of K5 identifies a pentagon/pentagram labeling. A Gram-to-coordinate result then gives radius `1/30000`. Procrustes gauge removes rotations; a penalized quadratic-form bound `449/100000 sum norm(h_i)^2 <= Qhess(h)+2 Pen(h)` and an exact cubic-remainder estimate yield

`E(y)-E(P) >= (1/1000)sum_i norm(y_i-P_i)^2`

for gauge-fixed configurations within `1/10000`. Equality therefore forces congruence. These are actual inequalities in the source, not an assertion based on positive numerical Hessian eigenvalues.

For N=9 the smallest candidate inner product is not at an antipodal endpoint, so this exact cap design cannot simply be copied. A band around the candidate minimum, or several designated-pair types, needs new certificates and a new Gram-pattern classification.

## Exact arithmetic and discovery provenance

A PSD block is stored as `M=sum_q d_q l_q l_q^T + Delta`, all integral, with `d_q >= 0` and `Delta` symmetric diagonally dominant with nonnegative diagonal. The checker verifies these sufficient conditions and proves PSD. Consequently near-zero floating eigenvalues are not accepted as evidence.

Polynomial identities are checked by evaluating at `u=2^w`, `v=2^(wD)`, `t=2^(wD^2)` after proving each variable degree `< D` and an uncollected coefficient l1 bound `<2^w`. The source proves that a zero integer evaluation with these bounds forces every coefficient to vanish. The Boolean computation is closed using `decide +kernel`, not `native_decide`.

For a one-dimensional minorant `H=Q/Lambda`, put `y=sqrt(2-2t)/2`. The comparison becomes `Lambda-2y Q(1-2y^2)>=0`. Integer weighted SOS representations use interval multipliers, including `y` and `19-20y^2` on the first cut. The signs and positive denominators are separately proved.

The repository contains no SDP discovery/rounding program. It contains the final exact data, checkers, numerical sanity script, and proof-reproduction scripts. Rounding/LDL repair is therefore an inferred description of the data format, not a fully reproduced generator pipeline.

## Build and trust status

The clean clone and source hashes were independently checked. The pinned Lean binary was downloaded and locally extracted under `work/toolchains`, without changing the user's global environment. `lake --version` independently returned `Lake version 5.0.0-src+5045d00 (Lean version 4.34.1)`. The command `lake exe cache get` completed with exit code 0 and downloaded/decompressed all 8,908 requested files. The source preamble comparison passed for 310 lines; the original forbidden-token pattern matched zero lines; there were 71 textual `decide +kernel` occurrences (including the documented comment). The original `scripts/check_claims.py` independently checked all 76 map rows and printed `CLAIMS CHECK: OK`.

Independent full-build result: **PASS, exit code 0, 8,928 jobs**. The command was `lake build ThomsonN7 ComparatorChallenges`. The main solution module reported 1,363 seconds and the umbrella module 70 seconds. The three expected `sorry` warnings belong exclusively to the independent Comparator challenge; no solution declaration has a `sorry` warning. Other warnings are unused arguments/tactics and deprecated tactic syntax. The actual full transcript is `N7_BUILD.log`.

The clean compilation produced `Solution.olean` (159,115,448 bytes). An independent `lake env lean scripts/CheckAxioms.lean` completed with exit code 0 and printed the exact final statements and `[propext, Classical.choice, Quot.sound]` for both `ThomsonN7.thomson_seven` and `ThomsonN7.thomson_seven_unique`. The actual transcript is `N7_AXIOMS.log`. Comparator and nanoda were not independently rerun during this audit; their upstream logs are distinguished below.

Upstream records, read but not counted as independent reproduction, report that both final theorems have exactly `[propext, Classical.choice, Quot.sound]`, Lean Comparator accepts the challenge, and nanoda independently accepts 47,854 declarations. The script also corrupts a certificate integer and requires nanoda rejection. External checker pins: Comparator `fd5d5bcf14177b187f66d4502071268d877887c3`, lean4export `076e8e57707e813375e8f9da8bf989799ace9680`, nanoda `3a2407216ee84a75f9e1aead6803d0578be06ae7`.

Reproduction commands in a shell with the pinned Lean and Python available:

```sh
git clone https://github.com/huwngtran/thomson-n7-lean
git -C thomson-n7-lean checkout 25f2fa53119273458cfbb3c4230904bffdd61e53
cd thomson-n7-lean
bash formal/check.sh
bash formal/lean/ComparatorChallenges/run_comparator.sh
bash formal/lean/scripts/second-kernel.sh
```

The complete package's documented memory requirement is about 14 GB for the main build. This Windows host has 32 GB physical RAM but approximately 7 GB free during initial inspection, so simultaneous N=7 and N=8 heavy compilations should be avoided.

## Direct comparison with the N=8 machinery

The N=8 source was checked at `50d14bc06bd41f61573eb6a36eedb8d00759af8f` of `lukasliehr/Energy-Minimization-8-Points`. In its shared `LeanCode/Logarithmic/Thomson8/Kernels.lean`, `kernelQ` has precisely the same recurrence as N=7's `Q3`; `kernelQ_complex` proves the same complex-power interpretation. This common geometry applies to all point counts on S2. In `RCounting.lean`, however, `repeated_triple_count` is specialized to eight points: its coefficients are `6`, `1/7`, and the diagonal count `8`. The N=7 `Rs` abstraction exposes these as `n-2`, `1/(n-1)`, and `n`.

N=8's `Coulomb8.VerifiedCAP.verified_CAP` produces an existential real coefficient vector `w : Fin 192 -> Real`, constrained near a rational center, whose certificate identity equals `(H(u)+H(v)+H(t))/3-G(a)/28`. The exact certificate is not simply the rounded center. `FullSolution` supplies corrected coefficients, `CertificateColumns` proves the exact identity, and `CertificatePositivity` proves total nonnegativity for the corrected vector. The N=8 audit agent independently checked the accompanying rational residual/inverse and PSD verification pipeline; see `N8_AUDIT.md` for its exact details and build status.

The key engineering difference is that N=7's published final certificate has already absorbed all repairs into explicit integer data, including diagonal-dominance residuals, and checks a zero integer identity. N=8 proves existence of a nearby exact coefficient solution using a bounded correction operator at its algebraic parameter. Both separate numerical discovery from soundness, but N=8's correction approach is particularly relevant when N=9's optimal radius is algebraic and a sharp identity must hold at that radius. N=7's typed kernels and slab strategy are particularly relevant when one untyped certificate has a gap.
