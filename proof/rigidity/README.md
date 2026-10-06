# Finite Gram rigidity certificates

Read `PROOF.md` for the mathematical statements and their connection to the
checkers. These results do not establish unrestricted global optimality.

## Results

- Exact six-value spectra force congruence to the candidate. All 56 anchor
  types were checked; nine surviving nine-point Gram patterns are all candidate
  permutations. No energy assumption is needed.
- True half-width `1/10000` spectrum windows, together with an anchor Gram
  determinant greater than `125/672`, force the candidate's labeled Gram pattern
  to that same tolerance. All 9,515 rational determinant exclusions passed;
  eight possible nine-point patterns remain, all candidate permutations.
- The additional antipodal contact window `[-1,-1+1/10000]` is impossible under
  the seven-window spectrum hypothesis. All 49 possible third-point color pairs
  force a Gram determinant strictly less than `-1/6000`.
- Deliberately corrupted determinant data, a clique permutation, an omitted
  actual extension, and a changed actual edge color were all rejected. All
  three checking entry points also reject Python's assertion-disabling `-O`.

The window premise uses the **true algebraic palette at the fixed radius**.
The rational radius-interval overenclosures are only conservative finite-search
filters. `PROOF.md` explains why this distinction preserves exactly the claimed
`1/10000` final Gram error.

## Reproduce checking

From `outputs/thomson-n9`, with ordinary Python and no third-party packages:

```text
python rigidity/check_exact_gram.py --output rigidity/exact_gram.check.json
python rigidity/check_window_gram.py --output rigidity/window_gram.check.json
python rigidity/check_antipodal_window.py
python rigidity/test_rejections.py
```

The checkers do not import the discovery programs. The window checker rederives
generic four-by-four determinant polynomials, whereas discovery uses explicit
three-by-three adjugate formulas. Exact checking uses its own integer polynomial
and cofactor arithmetic rather than SymPy. Every arithmetic acceptance decision
is exact; no floating-point eigensolver or tolerance decides positivity.

`exact_gram.check.json`, `window_gram.check.json`, `antipodal_window.check.json`,
and `mutation.check.json` record completed PASS runs. These are independently
auditable Python checks, not Lean kernel certificates. The existing 35-theorem
Lean package was not modified by this work.

## Reproduce discovery

The discovery environment used Python 3.12.14 and SymPy 1.14.0.

```text
python rigidity/generate_exact_gram.py
python rigidity/generate_window_gram.py --epsilon 1/10000
```

These commands enumerate all anchor multisets, all extension color triples,
all candidate mutual colors, and all six-extension cliques. No random seed is
involved. Candidate isomorphism witnesses are subsequently checked entry by
entry by the independent verifier.

The exact JSON stores all anchor determinant polynomials, surviving extension
types, colored compatibility edges, and complete clique/permutation witnesses.
The window JSON stores a conservative cover by extension types and colored
edges. Its checker explicitly proves every omitted type and omitted color
impossible, including self-type comparisons with independent endpoint variables.

## Certificate SHA-256

```text
efd47aef52c66ef4e48ea0179cbe3834f73c3dd811b9f6d52a0affd0b8362350  exact_gram.json
3fcd040eb0b6c538bcdd758a92a343c8801dfbb157019580f30b066ac483fc2a  window_gram.json
947696ad7ab324ff65032ec44f6dec9c18801c3cc694b734277f3f5488a37afb  exact_gram.check.json
500a5d795367022524ace979f8572ca1657c50b1dd5c694861bce533b2fb3d8e  window_gram.check.json
84f0602868a8ef28eed72a2004e6e9067878940df1df87205611a97932d744bc  antipodal_window.check.json
6f9c74b5adee97526f856707aeebe0a4cc279923d26872aee3b390b82bdae13d  mutation.check.json
```

The remaining global statement is spectrum localization into the seven true
contact windows for every competitor with energy at most the candidate's. The
finite checks do not assume or establish this missing statement.
