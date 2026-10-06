"""Finite interval Gram search; discovery code, checked separately."""
from __future__ import annotations

import argparse
from fractions import Fraction as Q
from itertools import combinations, combinations_with_replacement, product
import json
from pathlib import Path

from generate_exact_gram import (DEN, LNUM, PALETTE, candidate_permutation,
                                 enclosure, six_cliques)


def point(a):
    return Q(a), Q(a)


def plus(a, b):
    return a[0]+b[0], a[1]+b[1]


def minus(a, b):
    return a[0]-b[1], a[1]-b[0]


def times(a, b):
    values = [x*y for x in a for y in b]
    return min(values), max(values)


def scaled(n, a):
    return times(point(n), a)


def bilinear(v, adj, w):
    result = point(0)
    for i in range(3):
        for j in range(3):
            result = plus(result, times(times(v[i], adj[i][j]), w[j]))
    return result


def has_zero(interval):
    return interval[0] <= 0 <= interval[1]


def generate(epsilon):
    windows = [(enclosure(p)[0]-2*epsilon, enclosure(p)[1]+2*epsilon) for p in PALETTE]
    threshold = Q(125, 84)
    records = []
    totals = {"anchors": 56, "eligible_anchors": 0, "extension_nodes": 0,
              "nine_cliques": 0, "self_compatible_nodes": 0}
    for colors in combinations_with_replacement(range(6), 3):
        a, b, c = (windows[t] for t in colors)
        squares = plus(plus(times(a, a), times(b, b)), times(c, c))
        det = plus(minus(point(8), scaled(2, squares)), scaled(2, times(times(a, b), c)))
        record = {"colors": list(colors)}
        if det[1] <= threshold:
            record["status"] = "determinant_too_small"
            records.append(record)
            continue
        assert det[0] > 0
        totals["eligible_anchors"] += 1
        record["status"] = "eligible"
        adj = [[minus(point(4), times(c, c)), minus(times(b, c), scaled(2, a)), minus(times(a, c), scaled(2, b))],
               [minus(times(b, c), scaled(2, a)), minus(point(4), times(b, b)), minus(times(a, b), scaled(2, c))],
               [minus(times(a, c), scaled(2, b)), minus(times(a, b), scaled(2, c)), minus(point(4), times(a, a))]]
        extensions, vectors = [], []
        for triple in product(range(6), repeat=3):
            v = [windows[t] for t in triple]
            if has_zero(minus(bilinear(v, adj, v), scaled(2, det))):
                extensions.append(list(triple))
                vectors.append(v)
        edges, edge_lookup = [], {}
        adjacency = [set() for _ in extensions]
        self_compatible = []
        for i in range(len(vectors)):
            for j in range(i, len(vectors)):
                numerator = bilinear(vectors[i], adj, vectors[j])
                possible = [color for color, window in enumerate(windows)
                            if has_zero(minus(numerator, times(window, det)))]
                if i == j:
                    if possible:
                        self_compatible.append(i)
                    continue
                if len(possible) > 1:
                    raise ArithmeticError(f"Ambiguous edge color: {colors}, {i}, {j}, {possible}")
                if possible:
                    color = possible[0]
                    edges.append([i, j, color])
                    edge_lookup[i, j] = color
                    adjacency[i].add(j)
                    adjacency[j].add(i)
        if self_compatible:
            raise ArithmeticError(f"Duplicate extension types not excluded: {colors}, {self_compatible}")
        cliques = []
        for clique in six_cliques(adjacency):
            gram = [[-1]*9 for _ in range(9)]
            for (i, j), color in zip(((0, 1), (0, 2), (1, 2)), colors):
                gram[i][j] = gram[j][i] = color
            for k, node in enumerate(clique, 3):
                for i, color in enumerate(extensions[node]):
                    gram[i][k] = gram[k][i] = color
            for i, j in combinations(range(6), 2):
                gram[3+i][3+j] = gram[3+j][3+i] = edge_lookup[clique[i], clique[j]]
            mapping = candidate_permutation(gram)
            if mapping is None:
                raise ArithmeticError(f"Noncandidate approximate nine-clique: {colors}, {clique}, {gram}")
            cliques.append({"extension_indices": clique, "candidate_permutation": mapping})
        record.update(extensions=extensions, extension_edges=edges, self_compatible_nodes=[], nine_cliques=cliques)
        records.append(record)
        totals["extension_nodes"] += len(extensions)
        totals["nine_cliques"] += len(cliques)
        print(f"anchor {colors}: {len(extensions)} nodes, {len(edges)} edges, {len(cliques)} nine-cliques", flush=True)
    return {"format": "thomson-n9-window-gram-v1", "radius_lower_numerator": str(LNUM),
            "radius_upper_numerator": str(LNUM+1), "radius_denominator": str(DEN),
            "inner_product_half_width": str(epsilon),
            "anchor_gram_determinant_strict_lower_bound": "125/672",
            "anchors": records, "totals": totals}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--epsilon", default="1/10000")
    parser.add_argument("--output", type=Path, default=Path(__file__).with_name("window_gram.json"))
    args = parser.parse_args()
    result = generate(Q(args.epsilon))
    args.output.write_text(json.dumps(result, indent=2)+"\n", encoding="utf-8")
    print(json.dumps(result["totals"], indent=2))
