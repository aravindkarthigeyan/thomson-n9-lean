# Vendored Schoenberg Positivity

Source: https://github.com/specialjcg/delsarte

Inspected commit: `f0724e16b01d4561ee6cda8cd56db4db03de0496`.
License: Apache 2.0, included as `DELSARTE_LICENSE`.
Upstream Lean: `leanprover/lean4:v4.33.1`.
Upstream Mathlib: `0df444a360eaa60ab8c11dca51a86af692955474`.
This package retains its own existing Lean 4.34.1 and Mathlib
`d13f23b723b8a846827a245b89c10fc7d3f11612` pins.

Only the eight-file transitive local dependency closure of
`Delsarte.Sphere.Schoenberg` was copied. Every initial copy was checked
byte-for-byte against the following Git blob at the inspected commit:

| File | Git Blob |
| --- | --- |
| `Harmonic/Fischer.lean` | `d010718611b779ba1507908cba1234c1ac23a9e2` |
| `Gegenbauer/Basic.lean` | `8c9bea000d3dd7d88f1142ec3a3abff64e9d090a` |
| `Certificate/Interval.lean` | `93218c289106adb302b99a5cca4f2eda7975d671` |
| `Sphere/LP.lean` | `c8ec6e1f281709e4797b18ae2c1667bdb2526ce7` |
| `Harmonic/Zonal.lean` | `04e08e3996314608415689cec91e80b656de6748` |
| `Sphere/DegreeTwo.lean` | `28e8d45bf8e20b21d7db33c39b15ad90561aa2aa` |
| `Sphere/DegreeThree.lean` | `9979f80e7b0d8b92f5c377ca1e2ff3e7f821310e` |
| `Sphere/Schoenberg.lean` | `174ce970664b84140ecddff0a360717fc81569dc` |

Compatibility edits for the package's newer Mathlib coefficient API:

- `Harmonic/Fischer.lean`: replace old index-first `coeff alpha p` terms by
  `p.coeff alpha`, and qualify the existing rewrite as
  `MvPolynomial.coeff_add` because the declaration is now protected.
- `Harmonic/Zonal.lean`: replace the old partially applied coefficient function
  in one `congrArg` by a typed lambda using `p.coeff alpha`.

These edits do not change any theorem statement's mathematical meaning,
proof architecture, or trust settings. The other six files remain untouched.
The ordinary serial Lake build succeeded for all eight vendored modules and
the adapter. Logs: `verification/delsarte-build.log` and its JSONL hash journal.
A fresh ordinary import checked `verification/DelsarteAxioms.lean`; all six
printed dependency closures are exactly `[propext, Classical.choice, Quot.sound]`.
There is no native-computation axiom or added axiom. The audit log is
`verification/delsarte-axioms.log`.

Reproduce from this package with the pinned Lean runtime:

```text
lake build ThomsonN9.LP.Schoenberg
lake env lean verification/DelsarteAxioms.lean
```

The independent adapter is `ThomsonN9/LP/Schoenberg.lean`. It identifies the
dimension-three normalized Gegenbauer kernel with the Legendre kernel used
by this project, wraps the native `Configuration` in upstream `UnitPoints`,
and specializes `schoenbergPos_all` to nine sphere points at every degree.
It also states the degree-zero and degree-one moment identities and the
degree-two scalar polynomial formula. These are prerequisites for formal LP
separation and covariance bounds; they do not themselves assert either bound
or global optimality.
