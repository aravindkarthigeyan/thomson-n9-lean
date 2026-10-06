# Exact Bernstein Refinement of SOS Rounding Loss

This optional checker leaves the original SOS checker and certificate format unchanged. It first runs that checker, then reconstructs its rational residual polynomial A independently from the stored minorant, kernel factors, and SOS factors. It verifies that the reconstructed monomial coefficient l1 norm is exactly the value returned by the original checker.

The original certificate identity, with C=36 and raw energy e, is

```
(H(u)+H(v)+H(t))/3 - e/C
 = sum kernel terms + sum nonnegative SOS terms + A(u,v,t).
```

The original implementation uses `A>=-L`, where L is the exact coefficient l1 norm. If instead `A>=beta` throughout the certificate's inner-product box, the same unordered-triple sum proves

```
E(X) >= e + C*beta.
```

No part of the PSD argument, energy normalization, or Coulomb minorant test changes. The new bound is conditional on the original pair-domain hypothesis. Turning it into an unconditional bound requires the separate geometric separation argument and the same energy-threshold dichotomy used in `GLOBAL_CONSTRAINTS.md`.

When a certificate uses the optional globally summed determinant term `mu*(9/28-D)`, with mu nonnegative, it is also subtracted during residual reconstruction. That term is justified only after summing over triples, as explained in `CERTIFICATE_SOUNDNESS.md`; it is not assumed to be pointwise nonnegative during the Bernstein calculation.

## Exact Tensor Transformation

For one coordinate with domain `[l,U]`, substitute `u=l+(U-l)y`, with `0<=y<=1`. If that coordinate's maximum polynomial degree is n, the coefficient of the degree-n Bernstein basis element indexed by k in the monomial u^j is

```
sum_(0<=h<=min(j,k))
  binom(j,h)*l^(j-h)*(U-l)^h * binom(k,h)/binom(n,h).
```

The binomial theorem gives the first factor, and the exact identity

```
y^h = sum_(k=h)^n [binom(k,h)/binom(n,h)] B_(k,n)(y)
```

gives the second. `power_to_bernstein_weights` uses precisely this rational formula. Applying it successively to u,v,t gives a full tensor Bernstein expansion on the box. Every tensor basis element is nonnegative, and their sum is one. Therefore the least coefficient is a valid lower bound for A on the whole box, including every realizable Gram triple. The checker does not need to prove anything about non-realizable points in the box beyond this polynomial bound.

## Finite Subdivision

The midpoint de Casteljau recurrence replaces adjacent coefficients by their exact average. It produces the Bernstein arrays for the two child boxes and preserves their union as the parent box. The algorithm splits a currently least-bounded leaf, cycles coordinate directions by depth, and retains both children. Thus the finite leaf set always covers the original box. The minimum over all leaf minima is a rigorous global lower bound, regardless of whether the chosen refinement strategy is efficient.

Each child coefficient is a convex combination of its parent's coefficients, so each child minimum is at least its parent minimum. The code checks this monotonicity. It also retains the original l1 lower bound: the final beta is the maximum of the subdivided Bernstein lower bound and `-L`. A weak Bernstein enclosure can never weaken the original certified energy bound.

The optional `--gram-domain` mode also transforms the exact determinant `D=1+2uvt-u^2-v^2-t^2` to tensor Bernstein form and subdivides its coefficient array along the same boxes. A box may be discarded only when the largest determinant coefficient is strictly negative. Since D is a convex combination of those coefficients, D is then negative throughout that box, so the box contains no realizable three-point Gram matrix. Discarded boxes are recorded with their paths and exact negative determinant upper bounds. The surviving leaves plus the discarded boxes still cover the original box; hence the surviving leaves cover every realizable triple. A box that merely meets D=0 is never discarded. This extra restriction changes the residual bound's domain from the full box to its Gram-realizable portion, which is sufficient for the energy sum.

## Reproduction and Audit

Run from the project directory:

```powershell
python certificates/check_residual_bernstein.py certificates/sep0560-d8-box.json --splits 7 --negative-control --report results/residual-d8-box-bernstein.check.json
python certificates/check_residual_bernstein.py certificates/sep0560-d8-box.json --splits 15 --gram-domain --negative-control --report results/residual-d8-box-gram-bernstein.check.json
```

The code uses only standard-library exact integer/rational arithmetic and the existing polynomial kernel. It imports no numerical solver. The report hashes the certificate and records the exact initial and refined bounds, residual lower bound, degree tuple, finite leaf paths, and leaf minima. Decimal output is diagnostic only. The routine recalculates every leaf coefficient when run; its report is not blindly trusted as a new certificate input.

Small independent rational examples check the power-to-Bernstein transform and all three coordinate subdivision identities. A deliberately altered tensor coefficient must fail the evaluation identity. These finite regression tests supplement, rather than replace, the transformation and coverage proof above. This remains an exact computational refinement with a written soundness argument, not a Lean-verified theorem.

## Recorded Results

The following runs completed using exact rational arithmetic; decimals are only readable summaries of the full fractions in their reports.

| Certificate and refinement | Certified lower bound |
| --- | --- |
| Degree-7 box certificate, original coefficient l1 loss | 25.759442945322388... |
| Degree-7 tensor Bernstein, seven splits | 25.75945855977548... |
| Degree-8 box certificate, original coefficient l1 loss | 25.7598562776688186793186 |
| Degree-8 full-box Bernstein, seven splits | 25.7598788814880747317918 |
| Degree-8 Gram-domain Bernstein, fifteen splits | 25.75988332067154... |

The last run has eleven retained leaves and five discarded boxes. For example, the discarded path `000000` has determinant upper bound `-285131/500000`; all discarded boxes have strictly negative exact bounds. The best refined energy fraction is

```
119953804280010708359458454884835657004788679
/4656612873077392578125000000000000000000000.
```

The combined checker in `check_constraints.py` reruns this exact refinement and verifies that its pair domain contains the already-proved separation interval and that its bound is below the candidate comparison threshold U. It therefore supplies the same bound unconditionally by the two-case argument in `GLOBAL_CONSTRAINTS.md`. The refined bound is still strictly below the candidate energy; this result neither establishes sharpness nor resolves the missing global localization lemma.
