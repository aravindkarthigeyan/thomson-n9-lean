"""Independent stdlib-only exact verification of all Gram extension cases."""
from __future__ import annotations

import argparse
from fractions import Fraction as Q
from itertools import combinations, combinations_with_replacement, permutations, product
import hashlib
import json
from pathlib import Path

if not __debug__:
    raise RuntimeError("Certificate verification requires assertions; do not use python -O.")

LNUM = 7105483340929538113277041792727912437680
DEN = 10**40
LOWER, UPPER = Q(LNUM, DEN), Q(LNUM+1, DEN)
assert 0 < LOWER < UPPER < 1
COLORS = [(-1,), (0, -2), (0, 1), (-2, 0, 4), (2, 0, -3), (-2, 0, 1)]
POWERS = [(LOWER**k, UPPER**k) for k in range(17)]


def canonical(p):
    p = list(p)
    while len(p) > 1 and p[-1] == 0:
        p.pop()
    return tuple(p)


def add(a, b):
    out = [0]*max(len(a), len(b))
    for i, c in enumerate(a):
        out[i] += c
    for i, c in enumerate(b):
        out[i] += c
    return canonical(out)


def scale(n, a):
    return canonical([n*c for c in a])


def multiply(a, b):
    out = [0]*(len(a)+len(b)-1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            out[i+j] += x*y
    return canonical(out)


def determinant(matrix):
    n = len(matrix)
    out = (0,)
    for perm in permutations(range(n)):
        sign = (-1)**sum(perm[i] > perm[j] for i in range(n) for j in range(i+1, n))
        term = (sign,)
        for i in range(n):
            term = multiply(term, matrix[i][perm[i]])
        out = add(out, term)
    return out


def adjugate(matrix):
    return [[scale((-1)**(i+j), determinant([
        [matrix[k][l] for l in range(3) if l != i]
        for k in range(3) if k != j])) for j in range(3)] for i in range(3)]


def form(v, matrix, w):
    out = (0,)
    for i in range(3):
        for j in range(3):
            out = add(out, multiply(multiply(v[i], matrix[i][j]), w[j]))
    return out


def bounds(p):
    lower = upper = Q(0)
    for k, coefficient in enumerate(p):
        a, b = POWERS[k]
        lower += coefficient*(a if coefficient >= 0 else b)
        upper += coefficient*(b if coefficient >= 0 else a)
    return lower, upper


def sign(p):
    if p == (0,):
        return "zero"
    a, b = bounds(p)
    if a > 0:
        return "positive"
    if b < 0:
        return "negative"
    raise AssertionError(f"Nonzero polynomial not excluded from zero: {p}")


def reference_colors():
    # Twice the dot products of the actual symbolic coordinate orbits.
    matrix = [[-1]*9 for _ in range(9)]
    for i, j in combinations(range(9), 2):
        twice_angular_dot = 2 if i % 3 == j % 3 else -1
        if i < 6 and j < 6:
            vertical_sign = 1 if i//3 == j//3 else -1
            value = (2*vertical_sign, 0, twice_angular_dot-2*vertical_sign)
        elif i >= 6 and j >= 6:
            value = (twice_angular_dot,)
        else:
            value = (0, -twice_angular_dot)
        matrix[i][j] = matrix[j][i] = COLORS.index(canonical(value))
    return matrix


def verify(data):
    assert data["format"] == "thomson-n9-exact-gram-v1"
    assert int(data["radius_lower_numerator"]) == LNUM
    assert int(data["radius_upper_numerator"]) == LNUM+1
    assert int(data["radius_denominator"]) == DEN
    assert data["twice_inner_product_palette"] == [list(p) for p in COLORS]
    for p in COLORS:
        lo, hi = bounds(p)
        assert -2 < lo <= hi < 1
    for p, q in combinations(COLORS, 2):
        assert sign(add(p, scale(-1, q))) != "zero"
    # All six permutations of three edges are induced by vertex permutations.
    edges = ((0, 1), (0, 2), (1, 2))
    induced = {tuple(edges.index(tuple(sorted((p[i], p[j])))) for i, j in edges)
               for p in permutations(range(3))}
    assert len(induced) == 6
    anchor_types = list(combinations_with_replacement(range(6), 3))
    assert len(data["anchors"]) == len(anchor_types) == 56
    totals = dict(anchors=56, positive_anchors=0, zero_anchors=0, negative_anchors=0,
                  extension_nodes=0, nine_cliques=0)
    tested_norms = tested_edges = 0
    reference = reference_colors()
    for colors, record in zip(anchor_types, data["anchors"]):
        assert record["colors"] == list(colors)
        a, b, c = (COLORS[i] for i in colors)
        matrix = [[(2,), a, b], [a, (2,), c], [b, c, (2,)]]
        det = determinant(matrix)
        status = sign(det)
        assert record["determinant_of_twice_gram"] == list(det)
        assert record["status"] == status
        totals[status+"_anchors"] += 1
        if status != "positive":
            assert "extensions" not in record
            continue
        adj = adjugate(matrix)
        extensions, vectors = [], []
        counts = dict(zero=0, positive=0, negative=0)
        for color_tuple in product(range(6), repeat=3):
            v = [COLORS[i] for i in color_tuple]
            residual = add(form(v, adj, v), scale(-2, det))
            result = sign(residual)
            counts[result] += 1
            tested_norms += 1
            if result == "zero":
                extensions.append(list(color_tuple))
                vectors.append(v)
        assert record["extensions"] == extensions
        assert record["norm_residual_counts"] == counts
        expected_edges, edge_map = [], {}
        for i, j in combinations(range(len(vectors)), 2):
            base = form(vectors[i], adj, vectors[j])
            matching = []
            for color, value in enumerate(COLORS):
                residual = add(base, scale(-1, multiply(value, det)))
                tested_edges += 1
                if sign(residual) == "zero":
                    matching.append(color)
            assert len(matching) <= 1
            if matching:
                expected_edges.append([i, j, matching[0]])
                edge_map[i, j] = matching[0]
        assert record["extension_edges"] == expected_edges
        cliques = [list(nodes) for nodes in combinations(range(len(vectors)), 6)
                   if all((i, j) in edge_map for i, j in combinations(nodes, 2))]
        assert [c["extension_indices"] for c in record["nine_cliques"]] == cliques
        for clique, witness in zip(cliques, record["nine_cliques"]):
            mapping = witness["candidate_permutation"]
            assert sorted(mapping) == list(range(9))
            gram = [[-1]*9 for _ in range(9)]
            for (i, j), color in zip(edges, colors):
                gram[i][j] = gram[j][i] = color
            for i, node in enumerate(clique, 3):
                for j in range(3):
                    gram[i][j] = gram[j][i] = extensions[node][j]
            for i, j in combinations(range(6), 2):
                gram[3+i][3+j] = gram[3+j][3+i] = edge_map[clique[i], clique[j]]
            assert all(gram[i][j] == reference[mapping[i]][mapping[j]]
                       for i in range(9) for j in range(9))
        totals["extension_nodes"] += len(extensions)
        totals["nine_cliques"] += len(cliques)
    assert data["totals"] == totals
    assert totals["nine_cliques"] > 0
    return {"result": "PASS", **totals, "norm_polynomials_checked": tested_norms,
            "pair_color_polynomials_checked": tested_edges,
            "arithmetic": "stdlib integer polynomials and exact rational intervals"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("certificate", nargs="?", type=Path,
                        default=Path(__file__).with_name("exact_gram.json"))
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    raw = args.certificate.read_bytes()
    result = verify(json.loads(raw))
    result["certificate_sha256"] = hashlib.sha256(raw).hexdigest()
    rendered = json.dumps(result, indent=2)+"\n"
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
