# Quantitative Stability from the Reduced Certificate

This is a consequence of the existing exact certificate chain, not a new
numerical search. `ThomsonN9.thomson_nine_quantitative_stability` has compiled
in the delivered Lean package, with only the standard three axioms. Current
source-only build receipts and release-verification gates are in `STATUS.md`.

Let P be the exactly defined candidate, and put epsilon = 10^-47. If X is a
configuration of nine distinct unit vectors and

    E(X) <= E(P) + epsilon,

then there are a permutation p and an orthogonal transformation Q such that

    sum_i ||Q x_(p(i)) - P_i||^2 <= 50 (E(X) - E(P)).

In particular the right-hand side is nonnegative, and the same squared
distance is at most 50 epsilon. No pairwise-window assumption is needed in
this final statement.

## Explicit Reduction

Write U and C for `raw_energy` and `certified_energy` in the frozen reduced
D60 certificate (SHA256
`9816ae66f3b68caf4a03d6c6f7c514124c8cd8ba4415497a79443ce64f158781`).
Both are exact rationals. Let ell = U-C. The scalar inequalities needed are

    U + 10^-47 <= 6439996633/250000000,
    ell + 10^-47 < 10^-46 < 10^-33.

These are literal rational comparisons. E(P) <= U is the compiled candidate
energy bound; ell is about 2.39613e-54, a diagnostic value only.

1. The first comparison puts X below the exact LP energy cutoff. The checked
   separation minorant and tail gap imply every off-diagonal product is
   strictly less than 5593/10000.
2. The concrete three-point certificate gives sum_(i<j) h(u_ij) >= C. Since
   h(u_ij) <= ||x_i-x_j||^-1, each nonnegative pair slack is at most
   E(X)-C <= ell+epsilon.
3. The exterior gap 10^-46 forces every pair into a radius-10^-4 contact
   window or the antipodal window. The finite classification excludes the
   antipodal case and gives a coherent candidate labeling. In particular
   all products are at least -3/4.
4. The refined gap 10^-33 forces the true contact windows to radius 10^-8.
   Applying the eta version of the same finite classification yields one
   permutation with entrywise Gram error at most 10^-8.
5. The compiled Gram alignment theorem gives a minimizing Q with squared
   coordinate distance rho^2 <= (10^-4)^2 and zero skew. In particular
   rho <= 1/500, the radius required by the local theorem.
6. The actual augmented-Hessian certificate and the local energy estimate
   give rho^2/50 <= E(QX_p)-E(P). Orthogonal transformations and permutations
   preserve the unordered-pair Coulomb energy, so this is the stated result.

## Formal Verification

The scalar/localization proof is written using Claude's generic
`refined_relabel`, with energy ceiling U+epsilon and slack ell+epsilon.
The local inequality uses `candidate_local_energy_gap`, not an assertion
that Gram closeness alone bounds the energy. All concrete premises are
discharged. The successful three-theorem module run is recorded in
`verification/QuantitativeStability-replay.measured.json`; it took 26.37 seconds.
The first draft failed on an addition-monotonicity lemma's orientation and
was not accepted. After that local proof repair, the source passed and was
promoted unchanged, SHA256
`50590a7d72d458ddebcc442d1b83017a7c1b677bb4e063b42ee18740bea3c8e2`.
