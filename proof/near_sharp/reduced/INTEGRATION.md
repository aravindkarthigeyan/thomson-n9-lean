# Reduced-Certificate Integration

The original 170-digit certificate is unchanged. This directory preserves
Claude's separately generated 60-digit certificate and Bernstein cover,
including its original provenance and independent review reports.

The complete project checker passes with:

```text
python verify_global.py --reduced --refined --report verification/global-reduced-refined.check.json
```

This uses the Bernstein route, not the Hermite `10^-92` gap. Its exact loss
is approximately `2.3961284996861775e-54`, below the proved `10^-46` gap.
The refined six-contact gap is `10^-33` at radius `10^-8`.

Hashes:

- SOS: `9816ae66f3b68caf4a03d6c6f7c514124c8cd8ba4415497a79443ce64f158781`.
- Bernstein: `3fa7f6bd72c81f7baf8f0ffb9ad2a23531b042e9b262cea556b375370d1c72d8`.
- Refined: `64149d3e8c61edee24440259d62daa147aa18c4563865cc76b57ff7dc71aa143`.

`regenerate_reduced.py` independently reproduces every mathematical datum
from the frozen source: coefficient and factor rounding, energy upper bound,
exact residual, all 461 global leaves, and the seven coarse exterior leaves.
It uses the project's fixed-point interval arithmetic for the energy bound,
instead of the original generator's Arb arithmetic. Discovery metadata is
not regenerated. Its proof-data comparison passed exactly.

```text
python near_sharp/regenerate_reduced.py
python near_sharp/check_bernstein.py near_sharp/reduced/bernstein-reduced.json --negative-controls --output near_sharp/reduced/bernstein-reduced.check.json
python near_sharp/check_refined_windows.py near_sharp/reduced/refined-windows-reduced.json --source near_sharp/reduced/near-sharp-d10-reduced-D60.json --negative-controls --output near_sharp/reduced/refined-windows-reduced.check.json
```

The five Bernstein and six refinement negative controls pass. The
energy-upper control now sets the proposed bound to zero, which is false for
both input variants; the earlier tiny decrement was still a valid upper
bound for D60. `verify_global.py --mutations` currently targets only the
original certificate and explicitly rejects combination with `--reduced`.

Regenerate the refined file using `generate_refined_windows.py` with its
`--source` and `--output` arguments pointing to this directory. The generator
and checker are separate programs, but share the binomial conversion for
single leaves; the Claude review uses a different homogenization method.

No unchecked numerical result is imported into Lean. The actual certificate
identity, coefficient bounds and finite coverage are now part of the compiled
unconditional theorem. See `../../FORMAL_PROOF_GUIDE.md` for its selected
dependency chain and `../../STATUS.md` for current verification receipts.
