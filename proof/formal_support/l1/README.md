# L1: kernel-checked certificate step of the N=9 Thomson proof (reduced D60 certificate)

Author: Claude (L1). Date: 2026-10-05. Lean 4.34.1, Mathlib `d13f23b723b8a846827a245b89c10fc7d3f11612`
(read-only cache), Codex's SDP package (read-only `.olean`s). Everything here lives under
`claude/formal/l1/`. Nothing under `outputs/`, `work/` or `claude/formal/lean/` was modified.

## Result

`lean/ClaudeL1/Main.lean`, namespace `ThomsonN9.Claude.L1`:

```lean
theorem reduced_pair_bound (x : Configuration) (hx : ∀ i, ‖x i‖ = 1)
    (hM : ∀ i j, i ≠ j → inner ℝ (x i) (x j) ≤ 5593 / 10000) :
    ((certifiedEnergyReduced : ℚ) : ℝ) ≤ pairSum (fun i j => hNew (inner ℝ (x i) (x j)))
```

* `hNew (t : ℝ) : ℝ := ∑ i : Fin 21, (hNewCoeff i : ℝ) * t ^ (i : ℕ)`. Here `hNewCoeff : Fin 21 → ℚ` lists
  the 21 exact rationals of the JSON field `minorant`, in increasing powers (`lean/ClaudeL1/Numbers.lean`).
* `certifiedEnergyReduced : ℚ` is the JSON field `certified_energy`, and `rawEnergyReduced : ℚ` is
  `raw_energy`. `Configuration`, `pairSum` and `inner` are Codex's / Mathlib's.
* `#print axioms ThomsonN9.Claude.L1.reduced_pair_bound`: `[propext, Classical.choice, Quot.sound]`.

The proof instantiates Codex's frozen `ThomsonN9.SDP.factored_certificate_pair_bound` with
`h := hNew`, `e := rawEnergyReduced`, `M := 5593/10000`, and these families:

| Codex parameter | L1 instance (`ClaudeL1/Identity.lean`) |
|---|---|
| `β, κ, ρ` | `Fin kblocks.length` (= 10: the identically zero kernel block 10 is dropped, which the generator asserts), `Fin 11`, `Fin 11` |
| `B b i r`, `p b i u`, `degree b` | `famB b i r = kblocks[b][r][i] / 10^60`, which is exactly the JSON entry `B_b[i][r]`; `famP b i u = u^i`; `famDeg b = b` |
| `σ`, `weight`, `square` | `Fin 3 × Fin allTerms.length` (copy ρ ∈ {(u,v,t), (v,u,t), (t,u,v)} × the 859 nonzero SOS columns); `weight = gtree(code)(ρ·(u,v,t)) / (3·10^124)`; `square = column(ρ·(u,v,t))` |
| `η`, `coefficient`, `exponent` | `Fin 21 × Fin 21 × Fin 21`; `coeff(R; a,b,d) / (9·10^124)`; `![a, b, d]`. `R` is the uncollected residual polynomial of the assembly check. It is kept abstract and never expanded |
| `hweight` | `sosWeight_nonneg`: `gtree c` evaluates to `10^4 · domainWeight` (`gtree_eval`). Codex's `domainWeight_nonneg` and `TripleDomain.swap_first/swap_last` are reused |
| `hidentity` | `l1_hidentity`. It holds for all real `u v t`, not only on the domain |
| final step | `res_l1_le : Σ |coefficient| ≤ (raw − certified)/36`. Combined with Codex's conclusion `e − 36·Σ|coef| ≤ pairSum` this gives the theorem |

## How the identity is checked

Global scale `S = 9·10^124`, `δ = 10^60`. Every factor entry, minorant coefficient and `e` sits on the
`1/δ` grid, which the generator asserts. The identity multiplied by `S` is an integer polynomial identity:

```
R  =  3·10^64·(H(u)+H(v)+H(t)) + c0  −  1875·PK  −  3·(T(u,v,t) + T(v,u,t) + T(t,u,v))
```

* `H_i = δ·h_i` and `c0 = −S·e/36`.
* `PK = Σ_k exprPoly(B'_k, k)` is the kernel total (786 collected terms). `exprPoly` is
  `56·Sym6(Y) + 8·Sym6(Y)(u,u,1) + 8·Sym6(Y)(v,v,1) + 8·Sym6(Y)(t,t,1) + Sym6(Y)(1,1,1)`, with
  `Y = (Σ_r a_r(u)a_r(v))·q_k`. The generic lemma `expr_eq_corrected` proves that this equals
  `48·δ²·correctedFactorKernel(B_k, x^i, k)` for any integer columns. This is Codex's definition
  exactly: `edgeSymmetrize` (all 6 orders) and `7S + S(u,u,1) + S(v,v,1) + S(t,t,1) + S(1,1,1)/8`, with
  `q_k` by the `circleKernel` recurrence.
* `T` is the final running total of the SOS chain (1771 terms), `T = Σ_columns gtree(code)·c²`, one
  copy per column. `gtree(code) = 10^4 · domainWeight(5593/10000)[code]`, and `code = r div 2` for SOS
  block `r`. The symmetrisation uses the transversal `{id, (u v), (u t)}` of the `(v t)`-stabiliser. It
  is exact because every column has a pure `(v t)`-parity (even and odd bases are separate blocks), so
  `R = S·A`, where `A` is the residual of the Python verifier. The `(v t)` invariance is never used in
  Lean. Every term is just `weight ≥ 0` times a square, and the residual pays for any discrepancy.
* `asm_ok : asm.checkL1 Lres = true` decodes the Kronecker value of `R` into balanced digits.
  `checkL1_sound` gives `boxL1 21 R ≤ Lres` and `R.DegLt 21` (DegLt is now exported).
  `Lres = S·L_new = 10·599032124921544404249140801494646531688115675861170130852381365236493`, which is
  exactly the l1 the Python verifiers report. `Test/Negative.lean` proves that `Lres − 1` is rejected,
  so the bound is tight.
* Regrouping (`eval_eq_box`): `R.eval = Σ_{a,b,d<21} coeff(R;a,b,d)·u^a v^b t^d`, and
  `boxL1_eq_sum` gives `(boxL1 21 R : ℝ) = Σ |coeff|`. These produce Codex's coefficient/exponent family.

Kernel-checked facts (`decide +kernel`, each a separate declaration):

| theorem | content | axioms |
|---|---|---|
| `Data.ktotal_ok` | `Σ_k exprPoly(kblocks[k], k) = PK` (Kronecker zero test, `w = 424`). The `q_k` values come from an integer recurrence at 16 points; the uncollected l1 bound is `486·colL1·qL1` | `propext` |
| `Data.SOS.chunk01_ok … chunk15_ok` | `T_i = T_{i−1} + gtree(code_i)·Σ_{c∈cols_i} c²` (Kronecker zero test, `w ≈ 432`), `T_00 = 0` | none |
| `Data.asm_ok` | residual l1 `≤ Lres` (balanced digits, `w = 436`) | `propext` |

`Data.SOS.sos_total` telescopes the 15 chunks: `T15.eval = Σ_{allTerms} gtree·c²`, on every commutative ring.

## Trust

* Trusted: the Lean kernel, including its GMP `Nat` acceleration, and the frozen statement of
  Codex's theorem.
* There is no `sorry`, `admit`, `axiom`, `native_decide`, `implemented_by`, `Lean.ofReduceBool`, `unsafe`,
  `set_option` or `debug.skipKernelTC` in `lean/ClaudeL1` (grep in `README` reproduction). Options are
  passed on the command line only, and only `-Dprofiler=true`.
* `w2_l1_gen.py` is untrusted. A wrong export makes a kernel check fail; it cannot create a false
  theorem. All data reach the theorems only through `decide +kernel` checks whose soundness is proved
  (`SOSChunk.check_sound`, `KTotal.check_sound`, `Assembly.checkL1_sound`).
* Negative controls (`ClaudeL1/Test/Negative.lean`): the kernel rejects each of these:
  * `asm.checkL1 (Lres−1)`
  * a wrong kernel scale (1874)
  * a wrong kernel total
  * chunk 1 with a different multiplier code

## Files

| path (under `l1/`) | content |
|---|---|
| `lean/ClaudeL1/KC/{Poly,Kronecker,Check}.lean` | copy of `claude/formal/lean/KCert` with the namespace renamed to `ThomsonN9.Claude.L1.KC`; the proofs are unchanged |
| `lean/ClaudeL1/KC/Ops.lean` | term maps (6 argument orders, boundary substitutions, scaling), univariate columns, `qPoly` and the `circ` pair recurrence, `exprPoly`; evaluation in every commutative ring, exact l1 and per-variable degree bounds |
| `lean/ClaudeL1/KC/Kernel.lean` | `KTotal.check` and `check_sound` |
| `lean/ClaudeL1/KC/Assembly.lean` | `Assembly.checkL1` and `checkL1_sound` (l1 and DegLt); `PTree.mapLeaves` for the permuted copies |
| `lean/ClaudeL1/KC/Chain.lean` | `SOSChunk.ofCode` (whitelisted multiplier table), `chunk_step`, `sumVal_append` |
| `lean/ClaudeL1/Data/*` | GENERATED: `Mult` (gtree), `Kernel` (columns, PK, `ktotal_ok`), `SOS/T00..T15`, `SOS/C01..C15`, `SOS/Last`, `SOS/Glue` (`sos_total`), `Assembly` (`asm_ok`) |
| `lean/ClaudeL1/Numbers.lean` | GENERATED: `hNewCoeff`, `hNew`, `rawEnergyReduced`, `certifiedEnergyReduced`, numeric links |
| `lean/ClaudeL1/Bridge.lean` | ℝ bridge: `eval_cons_R` (rfl), `eval_eq_box` (regrouping), `boxL1_eq_sum`, `horner_eq_sum`, verbatim copies of Codex's kernel definitions, `expr_eq_corrected`, `gtree_eval` |
| `lean/ClaudeL1/Identity.lean` | the families and `l1_identity`, `res_l1_le` (no Codex import) |
| `lean/ClaudeL1/Main.lean` | `correctedFactorKernel_eq`, `kernel_block_identity` (per block `k`: `correctedFactorKernel (B_k) x^i k = exprPoly(B'_k,k).eval / (48·10^120)`), `kernel_total_identity` (sum = collected `PK` / (48·10^120)), `sosWeight_nonneg`, `l1_hidentity`, `reduced_pair_bound`, `#print axioms` |
| `lean/ClaudeL1/KC/Extra.lean` | `SOSBlock.checkL1_degLt` and `checkL1_sound'` (DegLt exported from the copied `checkL1`, as REVIEW.md §1.1 asks) |
| `lean/Probe/*.lean` | throwaway probes, not part of the build: Codex interface and import cost, light import cost, axiom listing |

| `lean/ClaudeL1/Test/Negative.lean` | negative controls |
| `w2_l1_model.py` | exact flint model of every polynomial (shared by the generator) |
| `w2_l1_gen.py` | generator: hash-checks the JSON, recomputes everything exactly, asserts `l1(R) = S·L_new`, writes the data modules, `data/manifest.json`, and checks `data/generated_sha256.json` |
| `w2_l1_run.ps1` | one `lean.exe` per module: shared compile slot (`claude/formal/.lean_slot`), free RAM > 6 GB, peak-memory polling, time and memory caps |
| `w2_l1_build.ps1` | full build: generator, then all modules in order, then `w2_l1_costs.py` (writes `data/costs.json`) |

## Reproduce

```
cd claude/formal/l1
powershell -ExecutionPolicy Bypass -File w2_l1_build.ps1 -Clean
```

This regenerates the data modules: the JSON is hash-checked and the generated files are compared byte
for byte with `data/generated_sha256.json`. It then compiles all modules in dependency order into
`out/` and writes `data/costs.json`. To compile a single module:
`powershell -File w2_l1_run.ps1 -Files ClaudeL1\Identity.lean`. Add `-Codex -MaxMB 6500` for `Main`,
which needs Codex's `.olean`s at `outputs/thomson-n9/lean/.lake/build/lib/lean`; they are only read.

Hygiene check: `grep -rnE "sorry|admit|native_decide|implemented_by|ofReduceBool|unsafe|skipKernelTC|set_option|^axiom" lean/ClaudeL1`
should print nothing.

## Costs (clean build, this machine, shared; see `data/costs.json`)

Clean build: 48 modules, all OK. The sum of the `lean.exe` wall times is **309 s**. Kernel type checking
totals **93.2 s**, of which 6.8 s are the negative controls. One `lean.exe` ran at a time. Generated Lean
source is 19.7 MB in total. Peak is the private memory of the job's `lean.exe`, including its imports.

| module(s) | count | wall s (each) | kernel s (each) | peak MB (each) |
|---|---|---|---|---|
| `KC.*` (core library, incl. `Extra`) | 8 | 1.4–2.1 | ≤ 0.4 | 380–535 |
| `Data.Mult`, `Data.SOS.T00..T15`, `Last`, `Glue` | 19 | 1.3–3.0 | ≈ 0 | 360–525 |
| `Data.Kernel` (`ktotal_ok`) | 1 | 4.0 | 2.0 | 1014 |
| `Data.SOS.C01..C15` (`chunkNN_ok`; 9,280–12,840 column leaves, `w` 432–434) | 15 | 8.7–17.6 | 3.4–7.3 (Σ 80.6) | 1265–1613 |
| `Data.Assembly` (`asm_ok`, 9,261-digit decode) | 1 | 3.7 | 2.2 | 1183 |
| `Bridge`, `Numbers`, `Identity` (light Mathlib) | 3 | 7.9–8.1 | ≤ 0.13 | 2184–2303 |
| `Main` (imports Codex `CertificateBound`) | 1 | 12.3 | 0.03 | **4133** |
| `Test.Negative` | 1 | 8.1 | 6.8 | 1240 |

The per-module table is in `data/costs.json`; per-chunk statistics are in `data/manifest.json`. The
chunks were sized at about 11k column leaves (≤ 1.6 GB). About 20k leaves per chunk, i.e. 8 chunks,
would still stay under 2.5 GB.

## Issues and notes

1. **`Main` peaks at 4.13 GB, above the 2.5 GB per-module budget.** Chunking cannot fix this. The bare
   import of Codex's `ThomsonN9.SDP.CertificateBound` already costs 4.06 GB (measured with a file that
   only imports it), because `ThomsonN9.Basic` imports `Mathlib.Tactic`. So `Main` is the only module
   that imports Codex, and it contains only light glue. Every other module is ≤ 2.30 GB.
2. **Codex's `.olean` may be stale.** `CertificateBound.olean` is from 13:36:36, but
   `CertificateBound.lean` was modified at 13:48:10. I did not rebuild it. The olean's
   `#check @factored_certificate_pair_bound` matches the frozen source statement, and the olean
   contains `TripleDomain.swap_first/swap_last`, `domainWeight_nonneg` and
   `edgeSymmetrize_nonneg_on_domain`. If Codex rebuilds it, only `ClaudeL1.Main` needs recompiling;
   expected cost is about 12 s.
3. **Module root.** Lean resolves a top-level module name to the first `LEAN_PATH` root that contains
   it, so a module tree named `ThomsonN9.*` would shadow Codex's package. The module root is therefore
   `ClaudeL1`. All declarations are still in namespace `ThomsonN9.Claude.L1…`. For a lake build, add
   `[[lean_lib]] name = "ClaudeL1"` with `srcDir` pointing at `claude/formal/l1/lean`, or copy the folder.
   Build it sequentially: lake has no `-j`, and each chunk needs about 1.6 GB.
4. **`hNew` and `certifiedEnergyReduced` are defined here** (`ClaudeL1.Numbers`), from the exact JSON
   strings. L2 must prove `hNew ≤ coulombPotential` on `[-1, 5593/10000]` for the same function, or
   prove an equality with its own definition. The reduced certificate needs the 1e-46 Bernstein /
   localization route, not the old 1e-92 route, because 36·L_new ≈ 2.40e-54.
5. Lean prints harmless deprecation warnings: `cond_true`/`cond_false` in the copied KCert code, and the
   import name `Mathlib.Data.Real.Basic`.
6. The kernel-checked data theorems `ktotal_ok` and `asm_ok` depend on `propext` only, and all 15
   `chunkNN_ok` depend on no axioms. Every derived theorem depends on
   `[propext, Classical.choice, Quot.sound]`.

