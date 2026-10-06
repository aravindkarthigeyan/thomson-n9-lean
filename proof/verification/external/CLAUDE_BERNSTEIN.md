# Adversarial audit: direct Bernstein minorant and exterior-gap route (N=9)

Auditor: Claude. Date: 2026-10-05. Scope: `outputs/thomson-n9/near_sharp/`
`BERNSTEIN_PROOF.md`, `generate_bernstein.py`, `check_bernstein.py`,
`bernstein-minorant.json`, and `verify_global.py --bernstein`. Everything here
was re-derived with my own code (exact `Fraction`, python-flint `fmpq_poly`/`arb`,
sympy). None of it imports a Codex module. Codex's programs were only *run*:
as subprocesses, with `-B`, and with every output redirected into this folder.
Nothing under `W/outputs` or `W/work` was modified.

## Verdict

**Sound, with minor documentation and robustness issues.** I found no
mathematical or computational defect. Every claim in BERNSTEIN_PROOF.md that
this route uses was reproduced independently:

* The polynomial p(y) = 1 - 2y h(1-2y^2) is nonnegative on [0,1]. This makes h a
  Coulomb minorant on [-1,1).
* f - h >= 10^-46 at every point of [-1, 5593/10000] that lies outside the seven
  true windows.
* Phi(midpoint) <= U < T.

The h and U are exactly the ones used in the three-point certificate.

## Inputs (SHA-256)

| file | SHA-256 |
|---|---|
| bernstein-minorant.json | `caec5ebb88fb8d9cbad8a0c74bb862ee7e448660f8a85b9709b51dfc1193393f` |
| near-sharp-d10.json | `c7cac663dd6f66cd9df65a03b22de27dc81af3149e6520211f97a2d307853ab9` (= GLOBAL_PROOF.md) |
| hermite.json (generator source) | `d894c078b67f70c552efdf9f8f82d2caad93ad5203d92bb9fc537905a8db91f8` (= `source_hermite_sha256`) |

The Bernstein file hash agrees with CODEX_HANDOFF.md and with both Codex check
reports. The prefix "caebc…" in the task text and in `claude/CLAUDE_TO_CODEX.md`
line 875 is a transposition typo; the true prefix is `caec5eb…` (issue 1).

## Independent checks (scripts in this folder, reports in `out/`)

`w2_bern_audit.py` (PASS, about 7 s) → `out/w2_bern_audit.report.json`

1. **Same h, same U.** The 21 coefficients of `minorant` are exactly equal, as
   Fractions, to `near-sharp-d10.json:minorant` and to
   `hermite.json:coefficients_monomial`. `candidate_energy_upper` equals the
   certificate's `raw_energy` and hermite.json's `energy_upper`. The certificate
   domain is [-1, 5593/10000].
2. **y-substitution.** For y > 0, f(1-2y^2) = 1/(2y) (sympy). So
   p_gamma(y) = 1 - 2y(h(1-2y^2)+gamma) >= 0 implies f - h >= gamma for t in [-1,1).
   I built p0 by flint polynomial composition, not by Codex's binomial
   expansion. It has degree 41 and p0(0) = 1. Its values agree exactly with a
   pure-Fraction pointwise evaluation of the defining formula at 23 rationals.
3. **Global tree.** My own preorder parser gives 1655 leaves and depth 286, as
   recorded. The leaves are dyadic and partition [0,1] exactly: the first starts
   at 0, the last ends at 1, consecutive endpoints are equal, and each width is
   2^-depth. Trailing tokens, early termination and unknown tokens are rejected.
4. **Leaf positivity, using a third conversion method.** For each leaf [a,b], the
   degree-41 Bernstein coefficients come straight from the power basis via the
   homogenisation identity
   `sum_i a_i (a + bY)^i (1+Y)^(41-i) = sum_k C(41,k) b_k Y^k`.
   This uses neither a Taylor shift nor subdivision. It differs from Codex's
   generator (de Casteljau) and from Codex's checker (binomial split sums).
   * All 1655 x 42 coefficients are >= 0. None is zero. The smallest is 6.79e-181.
   * Self-test: `sum b_k B_{41,k}(z) = p0(a+(b-a)z)` holds exactly at random
     rational z on the sampled leaves (first 15, every 200th, all deepest).
   * Cross-method check: my own integer de Casteljau run down the tree equals
     the homogenised coefficients exactly at **every** leaf, after the known
     2^(41·depth) scaling.
5. **Radius bracket.** Using arb at 700 bits:
   Phi'(R_LO) = -1.4935e-39 ± 5e-51 < 0 < Phi'(R_HI) = 2.8769e-39 ± 3e-51.
   Phi'' > 0 on (0,1) because each term's second derivative is manifestly
   positive: `4√3/r^3`, `3(2r^2+1)/(2(1-r^2)^{5/2})`, `12(r^2+2)/(4-r^2)^{5/2}`,
   `9√2/(4(r+1)^{5/2})`, `9/(2-r)^{5/2}` (sympy). So the bracket isolates the
   unique critical point r*. A rigorous bisection narrows it to width 7e-201.
   The bracket text is identical in `check_exact_gram.py`, `local.json`,
   `lean/ThomsonN9/Candidate.lean` and `check_bernstein.py` (checked by text parse).
6. **P9 products.** Built from the coordinates in GLOBAL_PROOF / `candidateAt`
   (sympy):
   * The six products are r²/2-1, -r, -1/2, 2r²-1, 1-3r²/2, r/2, with
     multiplicities 6, 6, 3, 3, 6, 12 (36 pairs).
   * The 36-pair energy equals Phi.
   * The hand-derived Phi' equals sympy's derivative and Lean's `stationarity`.
7. **Contact enclosures.** I recomputed them from the bracket using monotonicity
   in r > 0. They equal `root_contact_enclosures` exactly. Arb confirms that each
   s_j(r*) lies inside its enclosure. The order is s1 < … < s6, and consecutive
   true windows are separated (u_j + ε < l_{j+1} - ε).
8. **Exterior t-cover.** This is an interval sweep, not an equality test. Let E'
   be [-1+ε, 5593/10000] with the open inner windows (u_j-ε, l_j+ε) removed.
   Each inner window lies inside the true open window, so E' contains every
   pair value t < 5593/10000 that is outside the seven closed true windows.
   E' is covered by the union of the seven records' `domain_t`; in fact the
   records equal the pieces of E' exactly. [-1, -1+ε] is the seventh (antipodal)
   window. GLOBAL_PROOF §4 / `check_antipodal_window.py` remove it. The
   separation LP removes t >= 5593/10000.
9. **Rounding direction of the y endpoints.** For every record,
   0 <= c < d <= 1, c^2 <= (1-b)/2 and d^2 >= (1-a)/2, all exactly. The slacks
   are 9e-57 to 1.2e-54, consistent with floor and ceiling on the 2^-180 grid.
   Moving c up by a single 2^-180 ulp makes the check fail (mutation below).
10. **Gap polynomial.** With gamma = 10^-46, p_gamma has nonnegative Bernstein
    coefficients on each [c,d], with one leaf each.

    The largest gamma each record's single leaf could certify:

    | record | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
    |---|---|---|---|---|---|---|---|
    | max gamma | 8.05e-44 | 5.69e-23 | 1.14e-22 | 1.55e-19 | 2.27e-16 | 1.29e-15 | 1.49e-14 |

    The binding interval is the one next to the antipodal window, where the
    contact has order 9. Its margin is about 800x.
11. **Energy.** midpoint ∈ (0,1). Phi(midpoint) < U by arb, with
    U - Phi(mid) = 4.602e-181 ± 3e-193. T - U = 7.30e-10. Family minimality
    gives E* <= Phi(mid) <= U.
12. **Sanity.** At the six true contacts, f - h is 5.25e-180 to 5.50e-180 (arb,
    all > 0). At t = -1, f - h = 5e-180. This is consistent with h being H
    lowered by about 5e-180. The global tree depth of 286 matches this flatness.

`w2_bern_identities.py` (PASS) → `out/w2_bern_identities.report.json`.
It contains a sympy proof, for n <= 9, of three things: the conversion
`b_k = Σ_{i<=k} a_i C(k,i)/C(n,i)`, Codex's left/right half-interval formulas,
and my homogenisation identity. It also holds the P9, energy, Phi' and radius
consistency checks above.

`w2_bern_sizes.py` → `out/w2_bern_sizes.report.json` has planning data for the
Lean L2 replay:
* The coefficients of h have at most 598-bit numerators and denominators.
* The integer Bernstein row at the root has at most 646 bits per entry.
* The deepest rows have at most 11764 bits, and gcd normalisation barely helps.
* Exterior rows have at most about 7985 bits.

## Replays of Codex's programs (outputs in `out/`)

* `check_bernstein.py --negative-controls`: PASS. All 5 built-in controls were
  rejected.
* `verify_global.py --bernstein`: PASS in about 20 s. Energy loss
  36L = 3.9835e-164 < 10^-46. The report confirms that the hash of the
  Bernstein file used is `caec5eb…`.
* `generate_bernstein.py --output out/...`: the regenerated certificate is
  identical to the shipped one, except `generation_seconds`.

## Mutation tests (`w2_bern_mutations.py`, 34 cases, `out/w2_bern_mutations.report.json`)

Each mutation was run through four checkers:
* my checker, Bernstein part only;
* my checker with the h/U linkage;
* Codex's `check_bernstein.py`;
* for linkage cases, the full `verify_global.py --bernstein` on a scratch copy
  of the checker tree.

There were **0 unexpected acceptances.**

| Category | Mutations | Result |
|---|---|---|
| Rejected by every checker | Unsplit global leaf; truncated tree; extra token; unknown token; wrong leaf count; wrong depth; global domain [0,1/2]; coarser tree (one sibling pair merged) | Rejected |
| | Raise h0 by 1e-179 or by 6e-180 (makes h > f at t = -1; the chain also rejects) | Rejected |
| | Raise h20 by 1e-170 | Rejected |
| | Exterior gap 1e-43 (above the certifiable 8.05e-44) | Rejected |
| | Exterior y endpoint rounded the wrong way by 1e-50, twice; lower y raised by one 2^-180 ulp | Rejected |
| | Exterior 0 starts at -1+2ε; exterior 1 right end lowered by 1e-60; record 6 dropped | Rejected |
| | Contact enclosure shifted by 1e-30 | Rejected |
| | ε = 1/5000; max inner product 3/5; midpoint 1/2 | Rejected |
| | U lowered by 1e-179 (below Phi(mid)); U = T | Rejected |
| | Float-typed ε; wrong format tag | Rejected |
| Linkage only ("chain") | h0 lowered by 1e-100; U raised by 1e-12; gap 1e-45 | Each passes the Bernstein-only checks, as it should, because it is true. The h/U/gap linkage in `check_sos_integer` / `verify_global` rejects it, and so does my linked checker. |
| Sound refinements | One global leaf refined; one exterior split into two leaves | Accepted by all |
| | Exterior records 2 and 3 swapped | Accepted by my coverage sweep. Rejected by Codex's order-sensitive equality test, which is stricter and harmless. |
| Raising h0 by 1e-181 or 1e-200 | | Accepted by the Bernstein-only checkers. This is correct: the true margin is about 5e-180, so h stays below f. |

## Issues (none affects soundness)

1. **Minor (documentation).** The task text and `claude/CLAUDE_TO_CODEX.md:875`
   quote the hash prefix as "caebc…". The real hash is `caec5ebb…193393f`, and it
   matches Codex's handoff and reports.
2. **Minor (documentation).** In BERNSTEIN_PROOF.md, "Seven Exterior Intervals"
   speaks of "the complement of their interiors on the separated t-domain". It
   never says explicitly that the seventh window is the antipodal window
   [-1,-1+ε], removed by `check_antipodal_window.py`. The cover is correct
   only with that reading, which GLOBAL_PROOF §4 supplies.
3. **Minor (documentation and assembly).** GLOBAL_PROOF.md §2 and §4 still state
   only the Hermite route, with gap (3) = 10^-92, and do not reference
   BERNSTEIN_PROOF.md. The Lean assembly should state which route it formalises.
   On the Bernstein route, (3) becomes "f-h >= 10^-46 outside the seven true
   windows", and §4 needs 36L < 10^-46, which holds with a ratio of about 4e-118.
4. **Minor (robustness).** `check_bernstein.py` hard-codes the 40-digit radius
   bracket. In `--bernstein` mode, `verify_global.py` does not compare that
   bracket with `LOWER/UPPER` (it does in Hermite mode, through
   `radius_interval`). Today all four copies agree, so there is no soundness
   impact. A Lean replay should take the bracket from `radiusLower/radiusUpper`.
5. **Minor (robustness).** On its own, `check_bernstein.py` accepts any
   `exterior_gap > 0` and does not check h/U linkage. Those are enforced only in
   `check_sos_integer.py` and `verify_global.py`. The mutations confirm that the
   full chain rejects every linkage break. Do not run `check_bernstein.py` by
   itself as if it certified the chain.
6. **Information (margins).** The exact checks have small but rigorous margins:
   * smallest global leaf coefficient 6.8e-181;
   * U - Phi(mid) = 4.6e-181;
   * exterior record 0: maximum certifiable gap 8.05e-44, against the 1e-46 used.

   Because of these margins, a Lean formalisation cannot round h, U or the
   midpoint. It must replay the exact rationals, with integer rows of up to
   about 11.8 kbit.
