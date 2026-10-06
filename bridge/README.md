# Bridge to the N7 project's N9 stretch target

`UpstreamN7Bridge.lean` proves the N9 stretch-target statement using the actual
definitions imported from Hung Tran's N7 challenge, rather than paraphrasing
those definitions in a new namespace. It transfers the completed N9 theorem via
the exact height change `z = sqrt(1 - r^2)` and an explicit permutation of the
three equatorial caps (upstream indices `6,7,8` map to candidate indices `8,6,7`).

## Scope of the check

- `ThomsonN9.UpstreamN7Bridge.thomson_nine` has exactly the same declaration type
  as the upstream `ThomsonN7.thomson_nine` stretch target, checked by Lean's
  definitional-equality procedure in an explicit command-level audit.
- This fresh theorem does not invoke any upstream placeholder theorem.
- The three reported proof dependency closures contain only `propext`,
  `Classical.choice`, and `Quot.sound`.
- The upstream challenge file itself contains three unproved target placeholders.
  Its isolated compilation therefore prints three expected warnings. These are
  upstream challenge declarations, not proof premises; the bridge's axiom reports
  contain no placeholder axiom.
- This is not a run of the separate Lean Comparator application. Nor has the
  supplemental bridge been independently rechecked by nanoda. The existing
  independent-kernel report concerns the frozen N9 complete theorem.
- This supplemental bridge does not alter the previously audited source archive.

## Provenance and reproduction

Upstream repository: <https://github.com/huwngtran/thomson-n7-lean>

Inspected commit: `25f2fa53119273458cfbb3c4230904bffdd61e53`

External source: `formal/lean/ComparatorChallenges/ThomsonN7.lean`

Source SHA-256:
`2cf12e8ca6bd6ebfb31ae7343ca87ed75a3ba37cbe3d6eb5abbfae483dafbaae`

Lean: `4.34.1`

Mathlib: `d13f23b723b8a846827a245b89c10fc7d3f11612`

The upstream challenge source is not redistributed here: no repository license
was found in the inspected N7 checkout. Obtain that repository separately and
check out the pinned commit. This bridge's new proof text does not reproduce the
upstream implementation.

First reproduce the N9 Lean project following its `REPRODUCE.md`. Then run this
PowerShell script with the actual locations on your machine:

```powershell
./check.ps1 -LeanExe /path/to/lean.exe `
  -N9Project /path/to/built/thomson-n9/lean `
  -N7Project /path/to/thomson-n7-lean/formal/lean
```

The script first compiles the pinned upstream challenge source into an isolated
local `build` directory using the N9 project's Mathlib dependencies. It does not
rebuild the full N7 package or trust an existing upstream challenge proof object.
It then compiles the bridge, checks its axiom/type output, and writes
`check-result.json`, `upstream-build.log`, and `bridge-build.log`.

No POSIX shell reproduction is claimed here. The tested script uses PowerShell.

## Recorded result

The isolated source compilation and bridge check completed successfully on
2026-10-06 at 15:54:30 UTC, with process exit code 0. The path-free
`bridge-build.log` contains the three standard-axiom reports and the successful
declaration-type identity audit. `check-result.json` records the checked source
hashes and version pins. This is a local check, not an external review.

The raw `upstream-build.log` is retained locally; it contains local filesystem
paths and the three expected upstream placeholder warnings. It need not be
published. The script reproduces that log from the separately obtained source.

Generated and checked through Codex under human direction. The corrected
project credits identify Codex as using GPT-6 Astra with Ultra reasoning
effort. Aravind Karthigeyan arranged the project and publication, not the
authorship of this bridge. See the publication-level CONTRIBUTIONS.md.
