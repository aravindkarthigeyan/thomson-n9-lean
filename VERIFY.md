# Verification Quickstart

There are three different checks. A successful Python replay is not a Lean
build, and a stored log is not an independent reproduction.

## 1. Publication Inventory

From the repository root, with Python 3.12 and assertions enabled:

```text
python tools/verify_publication.py
```

This checks the current public inventory, the mapping from original to public
files, and the unchanged Lean sources. `proof/HISTORICAL_SOURCE_MANIFEST.redacted.json`
is historical evidence, not the current manifest. Fresh generated outputs go
under `local-results/` and are not release inputs.

## 2. Exact Finite Arithmetic Replay

From the repository root:

```text
python proof/verify_global.py --reduced --refined --report local-results/exact-replay.json
```

This uses Python's standard library. Do not use `python -O`. It recomputes
finite rational/integer certificate checks and cross-stage constants, without
using stored reports as premises. It is distinct from formal theorem checking.

## 3. Full Lean Proof

Install elan/Lake and PowerShell, use the pinned toolchain, and run:

```powershell
cd proof/lean
lake exe cache get
powershell -NoProfile -ExecutionPolicy Bypass -File verification/Build.ps1 -Clean
if ($LASTEXITCODE -ne 0) { throw 'Lean build failed' }
powershell -NoProfile -ExecutionPolicy Bypass -File verification/CheckSource.ps1
if ($LASTEXITCODE -ne 0) { throw 'Source audit failed' }
powershell -NoProfile -ExecutionPolicy Bypass -File verification/CheckAxioms.ps1
if ($LASTEXITCODE -ne 0) { throw 'Axiom audit failed' }
powershell -NoProfile -ExecutionPolicy Bypass -File verification/RejectCorruptCoefficient.ps1
if ($LASTEXITCODE -ne 0) { throw 'Corruption control failed' }
```

The recorded clean run was on Windows. The serial helper checks the local
modules one at a time; do not start an unrestricted parallel cold `lake build`.
The largest observed step needed approximately 12 GiB of free commit-memory
headroom. This is not a minimum hardware guarantee or a promised runtime.

For the additional final-type ascriptions, source-scanner tests, and 17
supplemental fixtures, run the new public-version wrapper from repository root
after the build and checks above:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/CheckSupplemental.ps1
```

This wrapper verifies the PUBLICATION_MANIFEST and the public FREEZE.json hash
before using its test specifications. `-ValidateOnly` checks inputs without
running Lean. The complete wrapper has not been rerun against a new cold build;
the underlying fixture commands are those in the recorded baseline audit.

The extended audit block in the historical [reproduction guide](proof/REPRODUCE.md)
checks the original, pre-redaction FREEZE.json hash and must not be used
unchanged on this public derivative. The new wrapper replaces that block.
The historical original-machine driver is retained for audit, not as a
portable setup script.

The source archive's clean-build result was finalized separately after the
original driver disappeared without a final receipt. All individual passes
and independent integrity audits were retained. See
[the exact status account](proof/STATUS.md) and
[build finalization](proof/verification/BUILD_FINALIZATION.md).

## Separate Kernel Implementation

[Independent-kernel evidence and instructions](proof/verification/secondary/README.md)
identify the exporter, nanoda version, pins, successful actual run, and the
inconclusive earlier timeout. The complete theorem export was accepted with
55,248 declarations and only the three standard axiom signatures. The POSIX
recipe is explicitly unexecuted; this release does not claim a tested Linux
reproduction. Large reproducible exports and compiled caches are not bundled.

## Reporting A Reproduction

Please report the release/commit, operating system, toolchain, commands, exit
codes, elapsed time, and relevant logs. Do not include private home paths,
credentials, or unrelated files. Report theorem checking separately from
certificate arithmetic and artifact integrity. External human review and a
fresh-machine build remain welcome.

## Upstream N9 Statement Bridge

[bridge/README.md](bridge/README.md) documents the separately checked bridge
to the actual N9 stretch target in Hung Tran's N7 project. Its isolated
upstream-source compilation and bridge compilation passed on October 6, 2026;
the theorem's three axiom dependencies are the standard ones. Upstream
challenge placeholders are not used by the proof.

Obtain the pinned upstream repository separately, build the N9 project above,
then follow `bridge/check.ps1`. Upstream challenge source is not redistributed.
The bridge is not part of the original 181-module or nanoda counts.
