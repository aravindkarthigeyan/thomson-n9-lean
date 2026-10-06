# Legendre LP Infrastructure

`Schoenberg.lean` adapts the Apache-2.0 Delsarte theorem to the native
`Fin 9 -> EuclideanSpace Real (Fin 3)` configuration. Every-degree positivity
is unconditional apart from the unit-norm hypothesis. Its ordinary Lake build
and ordinary import/axiom audit passed. Provenance and the two Mathlib API
compatibility edits are recorded in `vendor/DELSARTE_PROVENANCE.md`.

The expansion used by `EnergyBound.lean` has a separate unrestricted constant:

`h(t) = a0 + sum(k in degrees) a(k) P_k(t)`.

Normally `degrees` consists of the positive degrees with nonzero coefficients.
Requiring all listed `a(k)` to be nonnegative is enough; no special handling of
zero coefficients is needed. The minorant hypothesis is explicitly quantified
over every real `-1 <= t < 1`, not a sampled grid. The base lower bound is

`E >= (81*a0 - 9*h(1))/2`.

The retained-degree theorem adds `a(k)*M_k/2` for any listed degree. In
`Covariance.lean`,

`M_2 = (3/2) * sum(a,b) (A_ab - 3*delta_ab)^2`,

where `A_ab = sum(i) x_i[a]*x_i[b]`. Thus the retained degree-two energy term
is exactly `(3/4)*a(2)*||A-3I||_F^2`.

Both energy and covariance modules passed an ordinary Lake build, and a fresh
ordinary import printed only `[propext, Classical.choice, Quot.sound]` for all
six audited theorem closures. Logs: `verification/lp-energy-build.log` and
`verification/lp-axioms.log`. Reproduce with:

```text
lake build ThomsonN9.LP.Covariance
lake env lean verification/LPAxioms.lean
```

These general theorems do not certify any particular polynomial minorant or
conclude the numerical separation/covariance constants. Those still require
the separately checked exact certificate data and their Lean integration.

## Nondegenerate Anchor

`Anchor.lean` proves that `||A-3I||_F^2 < 1/4` forces three distinct indices
whose three-point Gram determinant is greater than `125/672`. Writing
`B=A-3I`, each entry of B has absolute value below `1/2`, so the six-term
determinant formula gives `det B > -3/4`. The trace identity then yields
`det A = 27 - (3/2)||B||_F^2 + det B > 207/8`.

The sum of squared oriented volumes over all 729 ordered triples equals
`6*det A`. If every term were at most `125/672`, this would contradict the
last bound. Repeated-index volumes vanish, so the selected triple is
automatically distinct. This deliberately loose averaging argument avoids
spectral decomposition and subset-cardinality bookkeeping.

The full draft passed ordinary Lean with only the standard three axioms;
`verification/anchor-draft-retry2.log` records that check. The promoted module
changes only the namespace/documentation and awaits the next consolidated
package build. The concrete LP minorants are being integrated separately.

## Concrete Data

`Concrete.lean` contains the actual sparse Legendre coefficients from
`sdp/lp-separation.json` and `sdp/lp-separation-05593.json`. It proves their
base-bound formulas and the covariance/separation conclusions conditional on
the explicitly quantified minorant and strict-tail inequalities. In
particular, the latter uses a positive `1/100000000` margin beyond `U-B`.
No sampled inequalities are assumed silently.

`PolynomialLinkage.lean` identifies every Legendre polynomial through degree
27 with an integer-numerator Horner list, then proves the two actual sparse
expansions equal their exported Horner lists. It uses the independently
compiled Claude Bernstein checker's `polyEval` definition. The data interface
is `sdp/lp-horner-interface.json`. Source regeneration is
`python algebra/generate_lp_linkage.py`; all generated equality proofs still
have to pass the pinned ordinary Lean compiler.

Both full drafts passed ordinary Lean with standard axiom closures. Logs are
`verification/lp-concrete-draft-retry.log`,
`verification/lp-linkage-draft-retry.log`, and the ordinary dependency build
`verification/lp-checker-import-build.log`. Their namespace-only promoted
versions await the consolidated package build. The remaining step is to link
Claude L2's checked concrete positivity data and discharge the minorant/tail
premises, then assemble the energy-cutoff hypothesis from the candidate bound.
