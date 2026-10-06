# Alternate Local Hessian Certificate by Diagonal Dominance

This is an alternate exact positivity certificate for the same augmented
tangent Hessian used in `LOCAL_PROOF.md`. It does not replace or weaken the
original certificate, local radius, or Gram window.

Let `H` be the 18-dimensional tangent Hessian, `R` the three rotational columns,
and

\[
A=H+RR^{\mathsf T}-\frac7{50}I.
\]

The matrix `A` is real symmetric for every actual candidate parameter in the
certified root bracket. The certificate supplies a rational upper triangular
matrix `C` with every diagonal entry exactly one. Hence `det C=1` and `C` is
invertible. It then checks interval enclosures for every entry of

\[
B=C^{\mathsf T}AC.
\]

For each row `i`, the checker establishes

\[
\underline B_{ii}>
\sum_{j\ne i}\max(|\underline B_{ij}|,|\overline B_{ij}|).
\]

Consequently every actual matrix enclosed by these intervals that is symmetric
is positive definite. For example, the elementary estimate
`2 abs(v_i v_j) <= v_i^2+v_j^2` yields

\[
v^{\mathsf T}Bv\ge
\sum_i\left(B_{ii}-\sum_{j\ne i}|B_{ij}|\right)v_i^2>0
\quad(v\ne0).
\]

Invertible congruence gives `A` positive definite, and thus
`H+RR^T > (7/50)I`. The original local proof only needs the corresponding
nonstrict lower bound. No numerical eigenvalues or numerical factorization are
trusted by this argument.

## Data and Replay

`certificates/generate_local_dd.py` uses high-precision Cholesky only to discover
`C`; it rounds its entries to rational numbers. The generator is not used by the
checker.

`certificates/check_local_dd.py` uses only the Python standard library and the
existing exact dyadic arithmetic/Hessian construction in `check_local.py`.
It never calls the LDL routine. In particular, interval matrix multiplication
encloses the algebraic Hessian, not a substituted rational-midpoint matrix.
The original `local.json` SHA256 is pinned inside the new certificate.

```powershell
python certificates/check_local_dd.py --negative-controls --report certificates/local-dd.check.json
```

The run passed. Its smallest exact rational diagonal-dominance margin is
approximately `0.014084931915885666`; the decimal is diagnostic only. All exact
entry enclosures and all 18 exact margins are in the report.

The checker also establishes the simpler uniform enclosures `[1/100,100]` on
the diagonal and `[-1/100000,1/100000]` off the diagonal. These imply the exact
row bound `17/100000 < 1/100` and are the concrete finite bounds used in Lean.

The checker rejected three explicit corruptions: a zero diagonal entry in `C`,
an upper-triangular coefficient changed to one million, and a changed Hessian
shift. These targeted failures do not claim every possible perturbation of a
valid certificate must be rejected.

Certificate SHA256:

```text
af262abaad4f0c85c181907b00d27682399a9c44bcd8c80af00e56c55a6e2887
```

## Formalization Scope

The Lean rational interval layer already proves the relevant arithmetic
soundness. `Certificates/DiagonalDominance.lean` is the separately authored,
successfully built soundness bridge for interval matrix multiplication,
rational row checks, strict diagonal dominance, and invertible
unit-upper-triangular congruence. It also proves the concrete finite uniform
row check. Actual theorem names and axiom audits are recorded in
`verification/LEAN_LOCAL_DD.md`.

This particular 18-dimensional tangent-frame certificate is retained as a
mathematical alternative; the Python replay does not claim a Lean instantiation
of its 324 entry enclosures. The selected 27-dimensional zero-penalty route has
compiled the actual Hessian interpretation and all required entry enclosures
through `Certificates/AmbientHessian.lean`. See `FORMAL_PROOF_GUIDE.md` and
`STATUS.md`; the alternative route's unformalized steps are not current gaps
in the unrestricted theorem.
