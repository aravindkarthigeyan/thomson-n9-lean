# Adversarial review of L1 (`claude/formal/l1`, reduced D60 certificate)

Reviewer: Claude (independent L1 reviewer), 2026-10-05. Lean 4.34.1, Mathlib `d13f23b` (read-only cache), Codex's
`.olean`s (read-only). Everything the review wrote is under `l1/review/` plus this file. Nothing the author wrote
(`l1/lean`, `l1/out`, `l1/data`, scripts) was modified. Nothing under `outputs/`, `work/` or `claude/formal/lean/` was touched.

## Verdict

**PASS.** `ThomsonN9.Claude.L1.reduced_pair_bound` is kernel-checked. Its axioms are `[propext, Classical.choice, Quot.sound]`.

* It states what L1 promised.
* It is a direct instantiation of Codex's frozen `ThomsonN9.SDP.factored_certificate_pair_bound`, with `e` and `h` equal to the
  reduced certificate's `raw_energy` and `minorant`. Both were checked exactly against the JSON strings, independently of the author's generator.
* The checked data are the JSON certificate.
* The Kronecker checks are evaluated. Corrupted data are rejected.
* The proved residual bound is exactly `L_new`.

Section 8 lists six issues. None of them blocks; they are about cost, integration and documentation.

## 1. Independent rebuild

Method: my own runner, `review/rv_run.ps1`.
* It takes the shared slot `claude/formal/.lean_slot` and requires more than 6 GB of free RAM.
* It runs one `lean.exe` at a time and polls that process's peak memory.
* `LEAN_PATH` is the Mathlib cache plus `review/out`. Codex's build directory is added only for `Main` and the probe.
* All 49 modules were compiled from source into `review/out`. The author's `out/` was never on the path.

| result | value |
|---|---|
| modules | **49 / 49 OK**: KC×8 (incl. `Extra`), Data×36, `Bridge`, `Numbers`, `Identity`, `Main`, `Test.Negative` |
| sum of `lean.exe` wall times | 261 s |
| SOS chunks C01–C15 | 8.6–12.0 s each, 1274–1692 MB; kernel type checking 62 s in total |
| `Data.Kernel` / `Data.Assembly` | 3.7 s, 961 MB / 3.4 s, 1457 MB |
| `Bridge` / `Numbers` / `Identity` | 8.0 s, 2273 MB / 7.5 s, 2195 MB / 8.4 s, 2328 MB |
| `Main` (imports Codex) | 11.8 s, **4139 MB** |
| `Test.Negative` | 7.7 s, 1463 MB (kernel 6.6 s) |
| max peak excluding `Main` | 2328 MB (`Identity`) |

Diagnostics: there are no errors. The only messages are deprecation warnings (`cond_true`, `cond_false`, `if_pos`, the `Mathlib.Data.Real.Basic` import name) and
unused-tactic linter notes. Per-run records are in `review/logs/runs.jsonl`.

## 2. Trust hygiene

* `grep -rnE "sorry|admit|native_decide|implemented_by|ofReduceBool|ofReduceNat|unsafe|skipKernelTC|set_option|^\s*axiom|@\[extern|opaque|partial def|debug\." lean/ClaudeL1`
  returns nothing. The whole tree was searched, including the 19.7 MB of generated data.
* There are no `notation`, `macro`, `syntax`, `elab`, `instance`, `export`, `#eval` or `run_cmd` declarations. The only attribute
  is `attribute [local instance] Semiring.natCast Ring.intCast` in five core KC files. It is harmless.
* No ClaudeL1 declaration shadows a Codex name. No ClaudeL1 declaration is named `correctedFactorKernel`, `pairSum`, `TripleDomain`,
  `domainWeight`, `Configuration`, `inner` or similar. All namespaces are `ThomsonN9.Claude.L1.*`.
* `#print axioms`, from my rebuild (`Main` plus the probe `review/src/ReviewL1/StatementCheck.lean`):
  * **`propext`, `Classical.choice`, `Quot.sound`** for each of these:
    * `reduced_pair_bound`, `l1_hidentity`, `kernel_block_identity`, `kernel_total_identity`
    * `sosWeight_nonneg`, `correctedFactorKernel_eq`, `l1_identity`, `res_l1_le`
    * `expr_eq_corrected`, `eval_eq_box`, `Data.SOS.sos_total`
    * Codex's `factored_certificate_pair_bound`
    * my restatements `ReviewL1.review_final`, `review_codex_instance` and `review_l1`
  * **`propext` only:** `Data.ktotal_ok` and `Data.asm_ok`.
  * **No axioms:** `Data.SOS.chunk01_ok`.

## 3. The final statement really is the reduced certificate's

* `#check` with full names (from my rebuild):
  `∀ x : ThomsonN9.Configuration, (∀ i, ‖x i‖ = 1) → (∀ i j, i ≠ j → Inner.inner ℝ (x i) (x j) ≤ 5593/10000) →
  ↑ThomsonN9.Claude.L1.certifiedEnergyReduced ≤ ThomsonN9.pairSum fun i j => ThomsonN9.Claude.L1.hNew (Inner.inner ℝ (x i) (x j))`.
* **Independent restatement** (`StatementCheck.lean`, compiled):
  * The probe defines `revCoeff`, `revRaw`, `revCert` and `revCap` by typing in the JSON strings verbatim. They are generated from the JSON, not from `Numbers.lean`.
  * It proves `revCoeff = hNewCoeff`, `revRaw = rawEnergyReduced` and `revCert = certifiedEnergyReduced` with `norm_num`.
  * It then proves `review_final : ↑revCert ≤ ThomsonN9.pairSum (fun i j => revH ⟪x i, x j⟫)`, assuming the cap `↑revCap`, with `revH t = Σ revCoeff i t^i`.
  * The proof is `reduced_pair_bound`.
* **Direct use of Codex's frozen theorem.** `review_codex_instance` applies the fully qualified `ThomsonN9.SDP.factored_certificate_pair_bound` to `famB famP famDeg sosWeight sosSquare resCoeff resExp hNew ↑rawEnergyReduced (5593/10000)`, `sosWeight_nonneg` and `l1_hidentity`. Its conclusion is `↑revRaw − 36·Σ|resCoeff| ≤ pairSum (revH ∘ Gram)`. It type-checks, so `l1_hidentity` has exactly Codex's `hidentity` shape, with Codex's own `correctedFactorKernel`.
* Python, exact `Fraction` (`review/rv_datacheck.py`, N1). The following are all equal to their JSON or derived values:
  * the 21 minorant coefficients, in increasing powers as SPEC §0 says
  * `raw_energy` and `certified_energy`
  * `hNum = 10^60·h`
  * `c0 = −S·e/36`
  * `M = 5593/10000` is the JSON `maximum_inner_product`.

  The values: `e_new ≈ 25.75998653126983156407570227376049402864191363647675944976` and
  `certified ≈ e_new − 2.396·10⁻⁵⁴`.

## 4. The kernel-block identity uses Codex's definitions

* `#print` from the loaded `.olean`s matches the frozen source text for each of these:
  * `correctedFactorKernel`: `7S + S(u,u,1) + S(v,v,1) + S(t,t,1) + S(1,1,1)/8`
  * `rootedFactorKernel`, `factorWeight`, `threePointKernel`, `circleKernel`
  * `edgeSymmetrize` (6 orders, `/6`)
  * `TripleDomain`, `domainWeight`, `pairSum`, `Configuration`
* `kernel_block_identity`, `kernel_total_identity` and `l1_hidentity` are stated with Codex's `ThomsonN9.SDP.correctedFactorKernel`.
  The light modules use the verbatim copy `myCorrected`, but they are joined to Codex's definition by the proved equation
  `correctedFactorKernel_eq`. Even a wrong copy could not have produced a false theorem.
* The data feeding the families matches the JSON, checked independently by `review/rv_datacheck.py`:
  * **K1:** `famB b i r = kblocks[b][r][i]/10^60` equals the JSON `B_b[i][r]` for every `k ≤ 9`, `i` and `r` (405 nonzero entries).
    JSON block 10 is identically zero, so dropping it is exact.
  * `famP b i x = x^i`, and `famDeg b = b` (so `q_k` is `circleKernel … k`).

## 5. Codex's `.olean` is not content-stale (author's issue 2 resolved)

The author flagged that `CertificateBound.olean` (13:36) is older than its source (13:48).

* I computed Lake's own source hash (`Lake.computeTextFileHash`, probe `review/src/ReviewL1/LakeHash.lean`) for the current sources.
* I compared it with the source hash recorded in each `.lake/build/.../*.trace`.
* All **13** modules in the import closure of `CertificateBound` match: Basic, Energy, CentroidBound, SDP/Summation, CircleKernel,
  ProjectionComplex, Counting, RepeatedIndices, Symmetrization, FactoredKernels, GeometryBounds, ResidualBound and CertificateBound.
  For CertificateBound both hashes are `0af85f41098154e7`.
* Every dependency `.olean` is older than `CertificateBound.olean`.

So the `.olean` was built from the current text, and the newer mtime is cosmetic. `Main` needs recompiling only if Codex actually changes these sources.

## 6. The Kronecker checks are evaluated and not vacuous

* **The data are the JSON's** (`rv_datacheck.py`, `ALL_OK`). The chunks hold **859** SOS columns. The JSON has 859 nonzero columns, plus 224 zero columns that were dropped.
  * Per multiplier code 0–5, the column counts are 162 / 176 / 176 / 86 / 176 / 83 in both.
  * Per code, the multisets of column polynomials are identical. Each JSON column is formed as `10^60·Σ_i C_r[i,m]·b_{r,i}` with the
    reference verifier's symmetry-box-v1 bases.
  * Each `chunkNN_ok` names its own columns, `T(NN−1)`, `TNN` and its code.
  * `Glue.allTerms` lists the 15 chunks in order with matching codes. A probe check, `allTerms.length = 859`, was proved by `decide +kernel`.
  * `gtree c = 10^4·domainWeight(5593/10000)[c]` as polynomials.
  * The current data files match `data/generated_sha256.json` (37/37).
* The 15 chunk checks use `w = 432–434` and take 3–5 s of kernel time each, so they are real evaluation.
* **Mutation tests.** Each mutation is a copy of a module with one datum changed by +1, compiled against my rebuild. Each is rejected, with exactly one error, at the intended declaration:

  | mutation | rejected at |
  |---|---|
  | `MutC07`: first leaf of column `c07_5` | `chunk07_ok` ("`decide` proved that the proposition … is false") |
  | `MutKernel`: one `kblocks` entry | `ktotal_ok` ("(kernel) application type mismatch") |
  | `MutAsm`: `hNum[3]` | `asm_ok` ("(kernel) application type mismatch") |
  | `MutNumbers`: numerator of `hNewCoeff[5]` | `hNewCoeff_eq` (unsolved goals) |

  The author's four negative controls (`asm_tight`, `asm_bad_kscale`, `ktotal_bad_total`, `chunk01_bad_code`) were re-proved `= false` in my rebuild.

## 7. The l1 bound matches L_new

* `L_new = (raw − certified)/36 = 599032124921544404249140801494646531688115675861170130852381365236493 / (9·10^123)`.
  That is about `6.656·10⁻⁵⁶`, and `36·L_new ≈ 2.396·10⁻⁵⁴`.
* This equals `residual_l1_exact` in the reference verifier's report `w2_red_final_verify.report.json`.
* `Lres = 5990321249215444042491408014946465316881156758611701308523813652364930 = 9·10^124·L_new`, exactly.
* In Lean:
  * `Lres_eq` proves `Lres/(9·10^124) = (raw − certified)/36`.
  * `res_l1_le` proves `Σ|resCoeff| ≤ (raw − certified)/36`.
  * My probe `review_l1` restates this with the JSON constants. Another probe example, `(revRaw − revCert)/36 = 599032…493/(9·10^123)`, is proved by `norm_num`.
* `asm_tight` shows the bound is attained: `Lres − 1` is rejected. So the Lean residual has l1 exactly `S·L_new`.

## 8. Issues (ranked; none blocking)

1. **Memory budget.** `Main` peaks at 4.14 GB (my probe reached 4.16 GB), above the 2.5 GB per-module rule.
   * This is inherent: the bare import of `ThomsonN9.SDP.CertificateBound` costs about 4.06 GB, because `ThomsonN9.Basic` imports `Mathlib.Tactic`.
   * The author confined the Codex import to the thin `Main`. All other modules are at most 2.33 GB.
   * Fix on Codex's side, if wanted: slim `ThomsonN9.Basic`'s imports.
2. **The author's issue 2 is a false alarm (§5).** The README and issue text could say that the `.olean` matches the current source by Lake hash.
3. **Integration.** `hNew` and `certifiedEnergyReduced` are new definitions in `ClaudeL1.Numbers`.
   * L2's `bernstein-reduced.json` has the same 21 minorant rationals, checked exactly. Identifying `hNew` with L2's function is therefore a coefficient-equality lemma.
   * Assembly still has to state it. Assembly also has to supply the LP cap `5593/10000` and the 1e-46 localization route, as the author notes.
4. **Packaging.** The module root is `ClaudeL1`, not `ThomsonN9.*`, which is needed to avoid shadowing on `LEAN_PATH`. A lake build needs `[[lean_lib]] name = "ClaudeL1"`.
5. **Documentation.**
   * The README and `w2_l1_build.ps1` count 48 modules. `KC.Extra` makes 49: it is not in the build list and nothing in the pipeline imports it, only `Probe/Axioms.lean` does.
   * Harmless deprecation and linter warnings remain.
6. **Trust base (standard).**
   * The trust base is the Lean kernel, including its GMP `Nat` acceleration for the large `decide +kernel` checks, plus the imported `.olean`s (Mathlib and Codex's SDP).
   * Imported `.olean`s are not re-checked on import. `lean4checker` was not run.

## 9. Process note (transparency)

From 16:00:32 to 16:10:31 my own compile slot was left held for about 10 minutes after my `StatementCheck` run finished.
* Cause: I piped the runner's console output through `Select-Object -First`. That terminated the runner before its `finally` block could release the slot.
* I confirmed that no `lean.exe` was running and that `owner.txt` named my run, then removed the slot by hand. I did the same for one more run of the same kind, `LakeHash`, a few seconds after it finished.
* No other agent's slot or process was touched.
* `rv_run.ps1` now removes the slot only when `owner.txt` names its own run, and later runs send output to files.

## 10. Reproduce

```
# full rebuild into review/out (slot + RAM gated)
powershell -ExecutionPolicy Bypass -File review/rv_run.ps1 -Files (Get-Content review/batch1.txt -Raw).Trim()
powershell -ExecutionPolicy Bypass -File review/rv_run.ps1 -Files ClaudeL1/Main.lean -Codex -MaxMB 6500
powershell -ExecutionPolicy Bypass -File review/rv_run.ps1 -Files ClaudeL1/Test/Negative.lean
# probes and mutations (root review/src)
powershell -ExecutionPolicy Bypass -File review/rv_run.ps1 -Root <l1>\review\src -NoOlean -Codex -MaxMB 6500 -Files ReviewL1/StatementCheck.lean
powershell -ExecutionPolicy Bypass -File review/rv_run.ps1 -Root <l1>\review\src -NoOlean -Files ReviewL1/LakeHash.lean
powershell -ExecutionPolicy Bypass -File review/rv_run.ps1 -Root <l1>\review\src -NoOlean -ExpectFail -Files ReviewL1/MutC07.lean,ReviewL1/MutKernel.lean,ReviewL1/MutAsm.lean,ReviewL1/MutNumbers.lean
# data cross-check (python-flint venv)
claude/venv/Scripts/python.exe review/rv_datacheck.py
```

Files added by this review: `review/rv_run.ps1`, `review/rv_datacheck.py`, `review/mklist.py`, `review/batch1.txt`,
`review/src/ReviewL1/{StatementCheck,LakeHash,MutC07,MutKernel,MutAsm,MutNumbers}.lean`, `review/out/` (rebuilt `.olean`s),
`review/logs/` (per-module logs and `runs.jsonl`), and this `REVIEW.md`.
