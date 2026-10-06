# Finer Six-Contact Localization

The optional `refined-windows.json` certificate sharpens the true contact
radius from1/10000 to1/100000000. It is not needed for the original complete
mathematical proof. Its purpose is to allow a much less sharp, simpler
Gram-to-coordinate estimate in Lean.

Certificate SHA256:
`936641eb5245068f352dfdd5b0341b49a6605d274cc73c161e4f3019b33aa813`.

First use the existing global chain to put every pair in the seven radius
1/10000 windows and exclude the antipodal window. The six remaining windows
all lie strictly inside `[-3/4,5593/10000]`. This is checked exactly using the
same40-digit candidate bracket, not inferred from a plot.

On that restricted domain, `check_refined_windows.py` proves

```
t outside the six true radius1e-8 windows ==> f(t)-h(t)>=1e-33.
```

It uses the same rational h as the original SOS certificate. Seven enlarged
rational exterior intervals cover the complement, just as in
`BERNSTEIN_PROOF.md`, but the left endpoint is now -3/4 and there is no
antipodal window. All seven intervals have nonnegative Bernstein coefficients
without subdivision: one leaf each. Although the general generator and
checker have different splitting implementations, these seven leaves use
the same binomial-shift coefficient formula. They should not be described
as independent mathematical reconstructions. Claude's separate audit uses
polynomial homogenization and checks all seven leaves independently.
Six deliberately corrupted inputs are rejected by the project checker.

The full SOS bound gives total nonnegative pair slack at most
`36L<4e-164<1e-33`, so every pair lies in a refined window. Each refined
window is contained in the corresponding old window. The old windows are
disjoint, so the labeling furnished by the original finite classification
identifies the same color for each pair. Consequently that labeling satisfies

```
max_(i,j)|x_i dot x_j-p_i dot p_j|<=1e-8.
```

The original proved polar estimate even gives alignment radius<=1.8e-7.
For the developing formal proof, a crude explicit Gram-Schmidt estimate with
constant10000 would already give radius<=1e-4<1/500. That replacement
geometric lemma is still being formalized; it is not assumed here.

## Replay

```text
python near_sharp/generate_refined_windows.py
python near_sharp/check_refined_windows.py --negative-controls
python verify_global.py --bernstein --refined --report verification/global-refined.check.json
```

Both the standalone checker and the full replay verify the exact h linkage
and source certificate hash. The full replay also checks the root interval,
restricted-domain premise, residual loss, and window containment. The
standalone checker does not prove the source SOS certificate valid or its
domain premise; it proves the conditional pairwise gap stated above.
