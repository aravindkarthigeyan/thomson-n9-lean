# Clean-Build Evidence and Metadata Preservation

The source-only project build used Lean 4.34.1 and pinned cached external
dependencies. All 181 ordinary module builds and 23 final audit/control steps
completed successfully. The original process did not leave a final receipt;
its precise termination cause and normal exit status are unknown. A separate
reviewed finalizer replayed all recorded checks and current source/object hashes,
preserved every original flat evidence file, and completed only the missing
metadata. It did not run a compiler or invent a missing proof check.

- Source FREEZE SHA-256: `22bb7406fef5a4379c856c8dbca26c8f964685e2bd036f24bdb45e0f5af3d10e`.
- Successful RESULT SHA-256: `1e10416d6f0e6abfd4c60dc12acf3fc8ba1d97c73c12d3078bcbe7076b25214f`.
- FINALIZATION SHA-256: `ffb12435e3578597139e8d590ed20f792483b96e0c8ef45e77b57a8fe4f8bcee`.

The source archive's `evidence/clean/` directory contains the actual receipt,
original step logs, copied finalizer/audit sources, and disclosed finalization
provenance. The 632 bound evidence files include all 622 original files and
ten explicitly recorded additions. Source and evidence inventories remain strict.

## Generated Axiom Log

The frozen axiom checker produced an additional non-frozen UTF-16 log inside
the source directory. Its text is exactly the bound axiom-step stdout before
the checker's final PASS line. This leaf was preserved byte-for-byte outside
the source tree; both its original bytes and relocation receipt are included
in the bound clean evidence. No frozen file changed. The original log SHA-256
is `6bdf92a6c0783aecf213cbf3725403c6592a92c13be5d28abba7214e059451d6`.

## Lake Index Hash Sidecars

After finalization, the broader secondary-verifier inventory noticed 181
`.ilean.hash` files, one 16-byte cached-output-hash sidecar per built module.
The original build inventory intentionally recorded the 543 `.olean`,
`.olean.hash`, and `.ilean` files, not those extra index hash caches. These
sidecars are not proof declarations and are not needed by `lean4export`.

Only those exact 181 leaves were preserved outside the consumed object tree.
Every frozen source, all 543 recorded artifacts, the original RESULT and every
bound evidence file were rehashed before and after the operation. No compiler,
proof-object change, consumer-rule change, or evidence rewrite occurred.

`ILEAN_HASH_PRESERVATION.json` contains the complete original 2896 bytes as hex,
individual paths and hashes, and the operation receipt. Its SHA-256 is
`f2cd9587683687940a1b92c0ec08169a7191b266ceec632ab889536d5f60f3d0`.
`ILEAN_HASH_PRESERVATION_SOURCE.txt` is the exact preservation helper, SHA-256
`d9e7ddcf5ce08cdb34838a93893980caf829b35154a37aa7e78b53922c6b73c4`.

These records explain provenance. They are not additional mathematical proof
steps or a claim that the independent kernel has accepted N9. Current release
and secondary-verification results are recorded in `../STATUS.md`.
