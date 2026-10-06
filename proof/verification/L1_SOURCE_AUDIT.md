# Independent L1 Source Audit

Verdict: **no blocking mathematical or statement defect found** in the inspected
Claude L1 source snapshot. This is a source-level and exact-arithmetic audit;
the independent root Lean rebuild subsequently **PASSED**. Claude's completed review
reports a separate successful 49-module rebuild and standard axiom closures;
those reports are evidence from that reviewer, not a substitute for our rebuild.

## Actual Statement

`ThomsonN9.Claude.L1.reduced_pair_bound` assumes exactly nine unit vectors and
that every off-diagonal inner product is at most `5593/10000`. It proves the
unordered pair sum of the actual rational polynomial `hNew` is at least
`certifiedEnergyReduced`. It does not assume candidate symmetry, a local
neighborhood, stationarity, the desired energy conclusion, or a free positive
semidefiniteness assertion. It is not itself a Coulomb global-minimum theorem;
the cap and polynomial-minorant/localization bridges belong to final assembly.

`Main.lean:100` applies the existing, frozen
`ThomsonN9.SDP.factored_certificate_pair_bound`. Its types use the real existing
`Configuration`, `pairSum`, `TripleDomain`, and `correctedFactorKernel`, not
shadow definitions. `Main.lean:31` proves equality of the lightweight copied
kernel and the existing kernel; `Main.lean:88` exposes the actual pointwise
identity required by that existing theorem. No extra premise is hidden in the
literal certificate facts.

## Normalization Audit

- The circle recurrence is `Q0=1`, `Q1=t-uv`, and
  `Q(k+2)=2(t-uv)Q(k+1)-(1-u^2)(1-v^2)Qk`, exactly the frozen sphere kernel.
- The root is the sum of products of factor-column evaluations. Factors are
  the JSON entries divided by `10^60`, with columns correctly transposed into
  `B i r`. Zero-padding to `Fin 11` is covered by actual list-length proofs.
  JSON block 10 is exactly zero; only that block is dropped.
- Symmetrization sums all six argument orders and divides by six. The corrected
  kernel is `7S + S(u,u,1)+S(v,v,1)+S(t,t,1)+S(1,1,1)/8`.
  Consequently the integer expression has coefficients `56,8,8,8,1` on the
  sixfold plain sums, and equals `48*10^120` times the corrected kernel.
- The SOS multiplier trees are exactly `10000` times the six allowed domain
  weights. Their weights in `Identity.lean` divide by `3*10^124`, while their
  squared columns have scale `10^120`. The three argument copies thus give
  the intended average. Positivity does not require assuming a column's
  symmetry: each copy has a nonnegative allowed multiplier on the permuted
  capped Gram domain.
- The complete integer identity scale is `S=9*10^124`.
  `1875*(48*10^120)=S`; the minorant numerator multiplier is `3*10^64`;
  `c0=-S*rawEnergyReduced/36`; and the SOS multiplier is `3`.
  `Numbers.lean` proves these rational bridges, rather than declaring them.
- For nine points there are 504 ordered distinct triples. Summing the averaged
  three-edge potential counts each unordered pair 14 times; the constant term
  gives `504/36=14`. A uniform residual bound `L` therefore costs exactly
  `504/14=36` in the final pair-energy bound. There is no missing factor two.

## Full Residual Coverage

The residual is not checked only in a symmetry-reduced coefficient list.
`KC.Assembly.checkL1_sound` proves both its collected coefficient l1 bound
and `DegLt 21`. `Bridge.eval_eq_box` then regroups the actual entire residual
over `Fin 21 x Fin 21 x Fin 21`, and `Identity.res_sum_eq` uses that result.
All 9,261 box coordinates are included; the current residual has 1,771
nonzero coefficients. Coefficients outside the box are excluded by a proved
degree bound, not ignored by the numerical generator.

Kronecker substitution uses `a+21*(b+21*d)`. Degree guards ensure injectivity;
the uncollected l1 bound guarantees both exact zero-test uniqueness and safe
balanced-digit decoding. The strict half-base bound and `w>=1` condition in
the l1 check imply the shifted packed integer is nonnegative, so the use of
`Int.toNat` cannot silently truncate a negative value. Relative-exponent tree
packing is proved for arbitrary tree order. Repeated monomials are collected
in the decoder and can cancel legitimately before absolute values are taken.

The final exact bound is

```text
Lres = 5990321249215444042491408014946465316881156758611701308523813652364930
L = Lres / (9*10^124)
certifiedEnergyReduced = rawEnergyReduced - 36*L
```

The numerical loss is about `2.3961284996861775e-54`; this decimal is diagnostic
only. The theorem uses the exact rational subtraction.

## Independent Arithmetic Replay

The new `verification/l1/audit_l1_expansion.py` does not import Claude's model
or generator. A restricted parser reads the actual `L`/`N` tree grammar and
literal integer constructors. FLINT expands the resulting integer polynomials.
It checks:

- All kernel factor entries against the frozen reduced JSON, then reconstructs
  the 786-term kernel polynomial independently from the recurrence, six
  permutations, and repeated-index substitutions.
- All 15 actual cumulative SOS identities, using all 859 nonzero columns and
  each recorded multiplier. Counts per code are `162,176,176,86,176,83`.
- All 1,771 nonzero coefficients of the full residual, its exact l1, the
  `10^60` minorant numerator conversion, and the raw/certified energy relation.
- Rejection of kernel scale `1874`, SOS scale `2`, an l1 budget one smaller,
  and an exponent `21` outside the checked box.

This replay passed. Its machine-readable report hashes every one of the 49
inspected Lean source files. The existing reviewer's separate data-multiset
checker was also opened and rerun successfully; it confirms all 859 columns
match the JSON factors, with 224 exactly zero columns omitted. The new replay
additionally checks the actual parsed tree structure and every intermediate
polynomial identity, not only extracted leaf multisets.

The certificate is
`near_sharp/reduced/near-sharp-d10-reduced-D60.json`, SHA256
`9816ae66f3b68caf4a03d6c6f7c514124c8cd8ba4415497a79443ce64f158781`.

## Trust And Rebuild Tests

A direct scan of all L1 source files found no `sorry`, `admit`, new `axiom`,
`unsafe`, native computation shortcut, reduction override, elaborator, syntax
extension, partial definition, or opaque replacement. Exact data checks use
`decide +kernel`; the core checker soundness is proved in Lean, not imported
as an axiom. The standard imported Lean/Mathlib proof-object trust remains.

All 49 `.lean` files have now been copied unchanged into the root package,
including unused `KC.Extra` and `Test.Negative`. No author or reviewer objects
were copied, and the independent polynomial replay passed again against the
delivered sources. `verification/CLAUDE_L1_IMPORT.json` records the full source
and support inventory. Its original, preserved SHA256 is
`cee83e01984711947be8452a80cf5aa676f791a7d59f01971874de2580b45ecb`.
The package maintainer owns library registration and complete source/axiom
coverage. The frozen serial topological queue identifies all 49 modules.

Fresh tests must include:

1. The original four Boolean controls: exact l1 budget minus one, kernel scale
   1874, wrong zero kernel total, and a wrong SOS multiplier code.
2. The independent additional controls: SOS scale 2, an exponent 21 in each
   variable separately, and digit widths zero and one. These are prepared as
   successful proofs that actual checker predicates evaluate to false.
3. The reviewer's actual-data one-coefficient mutations in a SOS column, a
   kernel factor, a minorant numerator, and the rational minorant bridge.
   First compile each genuine counterpart, and require rejection at the
   intended declaration; import/parser/resource failures do not count.
4. An exact final theorem-type restatement against
   JSON constants, and full axiom reports for the bound, identity, residual,
   kernel bridge and actual data checks.

The measured serial runner under `lean/verification/l1-import/` completed
successfully after the source audit and import. Its preparation pass verified
every copied hash and found no local L1 proof objects; all 49 modules then
built ordinarily without source edits. Seven fresh test processes audited
32 unique axiom closures, accepted the genuine checks and the exact JSON
restatement, proved all ten Boolean corruption controls false, and rejected
the four actual coefficient mutations at their intended declarations.
Only the three standard axioms were reported. The exact final theorem remains
the conditional polynomial pair bound stated above, not global optimality.

The accepted report SHA256 is
`a3f10ddbb5db8cf291c27feda3c0f9f30a056d47f2da214cfdd8c7b9cec0089e`.
The updated import manifest SHA256 is
`7c08efd0749e6c368393ddc66cf2baec8dcafd114a9cedfaee7ef27ecd8b74cc`;
the original copied-source hashes and timestamp are preserved.
Final ScalarCertificates glue was not duplicated or changed, and the
Claude-owned files were not edited.
