"""Stdlib checker: generic bordered determinants, independent of discovery code."""
from __future__ import annotations

import argparse
from fractions import Fraction as Q
from itertools import combinations, combinations_with_replacement, permutations, product
import hashlib
import json
from pathlib import Path

from check_exact_gram import COLORS, DEN, LNUM, bounds, reference_colors

if not __debug__:
    raise RuntimeError("Certificate verification requires assertions; do not use python -O.")


def poly_add(a, b):
    result = a.copy()
    for key, value in b.items():
        result[key] = result.get(key, 0)+value
        if result[key] == 0:
            del result[key]
    return result


def poly_mul(a, b):
    result = {}
    for x, c in a.items():
        for y, d in b.items():
            key = tuple(i+j for i, j in zip(x, y))
            result[key] = result.get(key, 0)+c*d
    return {key: value for key, value in result.items() if value}


def constant(n, value):
    return {(0,)*n: value} if value else {}


def variable(n, k):
    return {tuple(int(i == k) for i in range(n)): 1}


def determinant(matrix, nvars):
    result = {}
    n = len(matrix)
    for perm in permutations(range(n)):
        inversions = sum(perm[i] > perm[j] for i in range(n) for j in range(i+1, n))
        term = constant(nvars, (-1)**inversions)
        for i in range(n):
            term = poly_mul(term, matrix[i][perm[i]])
        result = poly_add(result, term)
    return result


def anchor_matrix(n):
    a, b, c = [variable(n, i) for i in range(3)]
    two = constant(n, 2)
    return [[two, a, b], [a, two, c], [b, c, two]]


def norm_polynomial():
    matrix = anchor_matrix(6)
    for i in range(3):
        matrix[i].append(variable(6, 3+i))
    matrix.append([variable(6, 3+i) for i in range(3)]+[constant(6, 2)])
    return determinant(matrix, 6)


def pair_polynomial():
    matrix = anchor_matrix(10)
    for i in range(3):
        matrix[i].append(variable(10, 6+i))
    matrix.append([variable(10, 3+i) for i in range(3)]+[variable(10, 9)])
    return determinant(matrix, 10)


def interval_mul(a, b):
    corners = (a[0]*b[0], a[0]*b[1], a[1]*b[0], a[1]*b[1])
    return min(corners), max(corners)


def interval_power(box, exponent):
    if exponent == 0:
        return Q(1), Q(1)
    lo, hi = box
    if exponent % 2:
        return lo**exponent, hi**exponent
    return (Q(0) if lo <= 0 <= hi else min(lo**exponent, hi**exponent),
            max(lo**exponent, hi**exponent))


def interval_evaluate(polynomial, box):
    lo = hi = Q(0)
    powers = [[interval_power(b, k) for k in range(5)] for b in box]
    for exponents, coefficient in polynomial.items():
        term = Q(coefficient), Q(coefficient)
        for i, k in enumerate(exponents):
            if k:
                term = interval_mul(term, powers[i][k])
        lo += term[0]
        hi += term[1]
    return lo, hi


ANCHOR = determinant(anchor_matrix(3), 3)
NORM, PAIR = norm_polynomial(), pair_polynomial()


def verify(data):
    assert data["format"] == "thomson-n9-window-gram-v1"
    assert int(data["radius_lower_numerator"]) == LNUM
    assert int(data["radius_upper_numerator"]) == LNUM+1
    assert int(data["radius_denominator"]) == DEN
    epsilon = Q(data["inner_product_half_width"])
    assert epsilon == Q(1, 10000)
    assert Q(data["anchor_gram_determinant_strict_lower_bound"]) == Q(125, 672)
    windows = [(bounds(p)[0]-2*epsilon, bounds(p)[1]+2*epsilon) for p in COLORS]
    assert all(-2 < lo <= hi < 1 for lo, hi in windows)
    assert all(a[1] < b[0] or b[1] < a[0] for a, b in combinations(windows, 2))
    counts = dict(interval_exclusions=0, excluded_norm_types=0, excluded_pair_colors=0)

    def exclude(polynomial, box, context):
        lo, hi = interval_evaluate(polynomial, box)
        assert lo > 0 or hi < 0, f"Unverified exclusion: {context}"
        counts["interval_exclusions"] += 1

    anchor_types = list(combinations_with_replacement(range(6), 3))
    assert len(data["anchors"]) == len(anchor_types) == 56
    totals = dict(anchors=56, eligible_anchors=0, extension_nodes=0,
                  nine_cliques=0, self_compatible_nodes=0)
    reference = reference_colors()
    for colors, record in zip(anchor_types, data["anchors"]):
        assert record["colors"] == list(colors)
        anchor_box = [windows[c] for c in colors]
        if record["status"] == "determinant_too_small":
            assert interval_evaluate(ANCHOR, anchor_box)[1] <= Q(125, 84)
            continue
        assert record["status"] == "eligible"
        totals["eligible_anchors"] += 1
        extensions = [tuple(t) for t in record["extensions"]]
        assert extensions == sorted(set(extensions))
        assert all(len(t) == 3 and all(c in range(6) for c in t) for t in extensions)
        present = set(extensions)
        for triple in product(range(6), repeat=3):
            if triple not in present:
                exclude(NORM, anchor_box+[windows[c] for c in triple],
                        (colors, "norm", triple))
                counts["excluded_norm_types"] += 1
        edges = record["extension_edges"]
        assert edges == sorted(edges)
        edge_map = {}
        for i, j, color in edges:
            assert 0 <= i < j < len(extensions) and color in range(6)
            assert (i, j) not in edge_map
            edge_map[i, j] = color
        assert record["self_compatible_nodes"] == []
        for i, left in enumerate(extensions):
            for j in range(i, len(extensions)):
                for color in range(6):
                    if edge_map.get((i, j)) == color:
                        continue
                    box = anchor_box+[windows[c] for c in left]+[windows[c] for c in extensions[j]]+[windows[color]]
                    exclude(PAIR, box, (colors, "pair", i, j, color))
                    counts["excluded_pair_colors"] += 1
        cliques = [list(nodes) for nodes in combinations(range(len(extensions)), 6)
                   if all((i, j) in edge_map for i, j in combinations(nodes, 2))]
        assert [c["extension_indices"] for c in record["nine_cliques"]] == cliques
        for clique, witness in zip(cliques, record["nine_cliques"]):
            mapping = witness["candidate_permutation"]
            assert sorted(mapping) == list(range(9))
            gram = [[-1]*9 for _ in range(9)]
            for (i, j), color in zip(((0, 1), (0, 2), (1, 2)), colors):
                gram[i][j] = gram[j][i] = color
            for i, node in enumerate(clique, 3):
                for j, color in enumerate(extensions[node]):
                    gram[i][j] = gram[j][i] = color
            for i, j in combinations(range(6), 2):
                gram[3+i][3+j] = gram[3+j][3+i] = edge_map[clique[i], clique[j]]
            assert all(gram[i][j] == reference[mapping[i]][mapping[j]]
                       for i in range(9) for j in range(9))
        totals["extension_nodes"] += len(extensions)
        totals["nine_cliques"] += len(cliques)
    assert data["totals"] == totals
    assert totals["nine_cliques"] > 0
    return {"result": "PASS", **totals, **counts,
            "arithmetic": "stdlib Fractions; generic determinant polynomials; exact rational interval enclosure"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("certificate", nargs="?", type=Path,
                        default=Path(__file__).with_name("window_gram.json"))
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    raw = args.certificate.read_bytes()
    result = verify(json.loads(raw))
    result["certificate_sha256"] = hashlib.sha256(raw).hexdigest()
    rendered = json.dumps(result, indent=2)+"\n"
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
