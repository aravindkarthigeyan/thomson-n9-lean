# Paper Review Checklist

Author: Aravind Karthigeyan. Affiliation: University of Illinois Urbana-Champaign,
as explicitly provided by the author. No department, title, or contact email was
provided or invented. `paper.tex` is a new CC-BY-4.0 review manuscript, not a claim of peer
review. It describes the actual selected D60/Bernstein/ambient-Hessian route.
The paper and this checklist do not alter the frozen proof release.

## Source Inspection

Checked against actual definitions and theorem bodies, not only project prose.
The baseline sources are presented under `proof/` in the publication repository;
the supplemental bridge is at the publication-level `bridge/` path.

| Paper claim | Source under original `outputs/thomson-n9/` | Exact public fact |
| --- | --- | --- |
| 36 inverse Euclidean distances, unit and injective configuration | `lean/ThomsonN9/Basic.lean` | `coulombEnergy`, `IsSphereConfiguration`, `Congruent` |
| Independent complete statement | `lean/Challenge.lean` | `CompleteTarget` has parameter existence/uniqueness, optimality, iff congruence |
| Unconditional endpoint | `lean/ThomsonN9/Completion.lean` | `thomson_nine_complete`, fixed and parameterized variants |
| Exact candidate and interval | `lean/ThomsonN9/Candidate.lean` | `candidateAt`, `stationarity`, `radiusLower`, `radiusUpper` |
| Parameter existence and family minimum | `lean/ThomsonN9/ParameterExists.lean`; family minimum module reference | `parameter_exists_unique`, `FamilyMinimum.lean` |
| Exact rational upper bound | `lean/ThomsonN9/Certificates/ReducedEnergy.lean` | literal `energyUpper`; interval circuit and family-minimum application |
| Separation and localization | `lean/ThomsonN9/ScalarCertificates.lean` | `sublevel_separation`, `sublevel_refined_gram` |
| Three-point summation and residual factor 36 | `lean/ThomsonN9/SDP/CertificateBound.lean` | `factored_certificate_pair_bound` |
| Concrete reduced identity and factor transfer | `lean/ClaudeL1/Main.lean` | `l1_hidentity`, `reduced_pair_bound`, factor/kernel identities |
| Reduced scalar minorant and gaps | `lean/ClaudeL2b/ReducedMinorant.lean`, `Integration.lean`; `RefinedWindows.lean` | nonnegative slack and separate coarse/refined gap endpoints |
| Antipodal exclusion and anchor-free rigidity | `lean/ClaudeWindow/Main.lean`, `Bridge.lean` | `antipodal_exclusion`, `exists_anchor`, `window_rigidity_free`, narrow bridge |
| Actual ambient Hessian semantics | `lean/ThomsonN9/BlockHessian.lean` | `constrainedHessian`, `rotationColumns`, quadratic identity |
| Negative radial multiplier sign | `lean/ThomsonN9/LocalEnergy.lean` | `radialCoefficient`, `candidate_force_eq_radialCoefficient` |
| Algebraic local remainder and constants | `lean/ThomsonN9/LocalEstimate.lean` | `energy_gap_lower_algebraic`, `zero_penalty_energy_gap` |
| Concrete Hessian circuit and final PSD | `FORMAL_PROOF_GUIDE.md`; actual `Certificates/AmbientHessian.lean` theorem body | 37,815 node checks, 1,458 dot products, 729 bounds, actual-matrix linkage |
| Stability | `lean/ThomsonN9/QuantitativeStability.lean` actual theorem body | separate Lean theorem; not claimed as separate-kernel export root |
| Source build and second checker scope | `verification/secondary/README.md`, `STATUS.md` | baseline 181+23 steps, 55,248 declarations, allowed axioms and disclosed finalization |
| Supplemental N7 challenge bridge | publication-level `bridge/README.md` and `bridge/check-result.json` | source compilation PASS, definitionally equal type, three standard axioms; not a Lean Comparator or nanoda check of this bridge |

The source names in the paper are audit pointers; the draft does not pretend to
reprint all certificate coefficients or all formal proof scripts. In particular,
the finite classification, Bernstein cover, and ambient Hessian claims are
explicitly stated as computer-assisted lemmas with finite checking obligations.

## Selected Data Hashes

Recomputed from actual files on October 6, 2026 using SHA-256:

| Data file | SHA-256 |
| --- | --- |
| `near_sharp/reduced/near-sharp-d10-reduced-D60.json` | `9816ae66f3b68caf4a03d6c6f7c514124c8cd8ba4415497a79443ce64f158781` |
| `near_sharp/reduced/bernstein-reduced.json` | `3fa7f6bd72c81f7baf8f0ffb9ad2a23531b042e9b262cea556b375370d1c72d8` |
| `near_sharp/reduced/refined-windows-reduced.json` | `64149d3e8c61edee24440259d62daa147aa18c4563865cc76b57ff7dc71aa143` |
| `certificates/ambient-dd-k0.json` | `ebe7f302de10f503adce62b92eb9f46cb3090c26684629629eff2dfa3bc957e3` |

The interval-circuit Lean proof identifies its literal data with the actual
Hessian; the JSON is not a trusted premise. Publication sanitization should
leave these mathematical inputs unchanged and verify these hashes.

## Mathematical Checks To Request From A Referee

- Compare `Basic.lean` and `Challenge.lean` with the printed main theorem.
- Check that parameter existence prevents a vacuous subtype theorem.
- Audit the repeated-index kernel correction and 504/14 = 36 residual factor.
- Verify the separation argument's tail excess and inequality directions.
- Verify Bernstein cover completeness and the direction of rational window enlargement.
- Inspect finite-classification coverage and the one-permutation conclusion.
- Inspect the interval circuit's semantic linkage to the actual augmented Hessian.
- Check the rotation gauge is obtained by minimization, not assumed.
- Verify the stationary radial correction, remainder coefficient 1377/100,
  and local radius 1/500.
- Rebuild the unconditional root and inspect its type and axiom closure.

## Explicit Publication Limitations

- This is a newly written review draft, not an externally refereed paper.
- The actual GitHub repository is
  `https://github.com/aravindkarthigeyan/thomson-n9-lean`.
  Zenodo reserved `10.5281/zenodo.23192843` for version 0.1.0 during publication
  preparation. The paper links these real identifiers and explicitly distinguishes
  DOI reservation from completed archive deposit and publication. Confirm the
  released record before describing the DOI as published or registered.
- Existing counts and checker evidence refer to the recorded baseline proof.
  A newly added upstream-challenge bridge should receive its own stated checks;
  do not silently extend the baseline nanoda claim to another root.
- The full N8 projects were not independently rebuilt successfully here.
- The explanatory mathematical text is not itself kernel checked.
- No claim of first-ever priority is made.
- Significant Codex, Claude, and Astra assistance is disclosed. Claude stopped
  before final verification; no final Claude approval is claimed.
- No numerical solver or Python certificate check is presented as a substitute
  for the Lean proof build.
- No arXiv submission, journal submission, email, repository upload, or DOI
  deposit is performed by this paper-preparation task.

## Final Preparation Gates

1. The built-in compiler was unavailable on October 6, 2026 before source
   diagnostics, with `Unable to find standard directories for platform`.
   The official portable Tectonic fallback subsequently compiled the standalone
   paper successfully with process exit code 0. The revised document has 11 pages;
   the final log has no overfull/underfull boxes or LaTeX warnings.
2. Poppler rendered all 11 pages at 90 dpi; PyMuPDF rerendered the final
   affiliation-updated PDF at the same resolution. An all-page contact sheet and
   enlarged checks of pages 1, 4, 8, 9, and 10 showed no clipping, overlapping text, or missing
   mathematical glyphs. Long code identifiers wrap within the text columns;
   the reproduction command retains its necessary spaces. Source, PDF, and log
   hashes should be recorded by the final publication packager. The fontconfig
   warning emitted by portable Tectonic did not prevent the PDF from rendering.
   A final extracted-text check found the exact reproduction command and the
   supplied UIUC affiliation; no text span lies outside a PDF page.
3. The actual repository and reserved version-0.1.0 DOI are now cited. Confirm
   the final immutable Git tag and Zenodo publication receipt in release metadata.
4. Have Aravind read and approve the title, attribution, assistance disclosure,
   and public claims before arXiv or journal submission.
5. Consider shortening verification-operation details for a journal version,
   while preserving them in the reproducibility supplement.
