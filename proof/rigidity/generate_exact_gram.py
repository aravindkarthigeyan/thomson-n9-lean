"""Discover the finite Gram-extension certificate using SymPy polynomial algebra."""
from __future__ import annotations

import argparse
from fractions import Fraction
from itertools import combinations, combinations_with_replacement, product
import json
from pathlib import Path

import sympy as sp


R = sp.Symbol("r")
LNUM = 7105483340929538113277041792727912437680
DEN = 10**40
LO, HI = Fraction(LNUM, DEN), Fraction(LNUM + 1, DEN)
PALETTE = [sp.Poly(t, R, domain=sp.ZZ) for t in
           (-1, -2*R, R, 4*R**2-2, 2-3*R**2, R**2-2)]


def coefficients(p):
    return [int(x) for x in reversed(p.all_coeffs())]


def enclosure(p):
    low = high = Fraction(0)
    for c in reversed(coefficients(p)):
        endpoints = (low*LO, low*HI, high*LO, high*HI)
        low, high = min(endpoints) + c, max(endpoints) + c
    return low, high


def classify(p):
    if p.is_zero:
        return "zero"
    lo, hi = enclosure(p)
    if lo > 0:
        return "positive"
    if hi < 0:
        return "negative"
    raise ArithmeticError(f"Unresolved polynomial: {p.as_expr()}, {lo}, {hi}")


def bilinear(v, a, w):
    return sum((v[i]*a[i][j]*w[j] for i in range(3) for j in range(3)),
               sp.Poly(0, R, domain=sp.ZZ))


def candidate_color(i, j):
    if i == j:
        return -1
    if i < 6 and j < 6:
        return 4 if i//3 == j//3 else (3 if i % 3 == j % 3 else 5)
    if i >= 6 and j >= 6:
        return 0
    return 1 if i % 3 == j % 3 else 2


REFERENCE = [[candidate_color(i, j) for j in range(9)] for i in range(9)]


def candidate_permutation(g):
    signatures = [tuple(row.count(c) for c in range(6)) for row in g]
    reference_signatures = [tuple(row.count(c) for c in range(6)) for row in REFERENCE]
    mapping = [-1]*9
    used = set()

    def search():
        if len(used) == 9:
            return mapping.copy()
        choices = []
        for i in range(9):
            if mapping[i] != -1:
                continue
            allowed = [j for j in range(9) if j not in used
                       and signatures[i] == reference_signatures[j]
                       and all(mapping[k] == -1 or g[i][k] == REFERENCE[j][mapping[k]]
                               for k in range(9))]
            choices.append((len(allowed), i, allowed))
        _, i, allowed = min(choices)
        for j in allowed:
            mapping[i] = j
            used.add(j)
            answer = search()
            if answer is not None:
                return answer
            used.remove(j)
            mapping[i] = -1
        return None

    return search()


def six_cliques(adj):
    def extend(chosen, remaining):
        needed = 6-len(chosen)
        if needed == 0:
            yield chosen
            return
        for pos, v in enumerate(remaining):
            if len(remaining)-pos < needed:
                break
            yield from extend(chosen+[v], [w for w in remaining[pos+1:] if w in adj[v]])
    return extend([], list(range(len(adj))))


def generate():
    records = []
    totals = {"anchors": 0, "positive_anchors": 0, "zero_anchors": 0,
              "negative_anchors": 0, "extension_nodes": 0, "nine_cliques": 0}
    for colors in combinations_with_replacement(range(6), 3):
        a, b, c = (PALETTE[t] for t in colors)
        determinant = 8-2*(a*a+b*b+c*c)+2*a*b*c
        status = classify(determinant)
        record = {"colors": list(colors), "determinant_of_twice_gram": coefficients(determinant),
                  "status": status}
        totals["anchors"] += 1
        totals[status+"_anchors"] += 1
        if status != "positive":
            records.append(record)
            continue
        adjugate = [[4-c*c, b*c-2*a, a*c-2*b],
                    [b*c-2*a, 4-b*b, a*b-2*c],
                    [a*c-2*b, a*b-2*c, 4-a*a]]
        extensions, vectors = [], []
        norm_counts = {"zero": 0, "positive": 0, "negative": 0}
        for triple in product(range(6), repeat=3):
            v = [PALETTE[t] for t in triple]
            residual = bilinear(v, adjugate, v)-2*determinant
            norm_status = classify(residual)
            norm_counts[norm_status] += 1
            if norm_status == "zero":
                extensions.append(list(triple))
                vectors.append(v)
        edges, adjacency = [], [set() for _ in extensions]
        edge_lookup = {}
        for i, j in combinations(range(len(extensions)), 2):
            numerator = bilinear(vectors[i], adjugate, vectors[j])
            matches = []
            for color, value in enumerate(PALETTE):
                if classify(numerator-value*determinant) == "zero":
                    matches.append(color)
            if len(matches) > 1:
                raise ArithmeticError("Palette collision")
            if matches:
                color = matches[0]
                edges.append([i, j, color])
                edge_lookup[i, j] = color
                adjacency[i].add(j)
                adjacency[j].add(i)
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
            permutation = candidate_permutation(gram)
            if permutation is None:
                raise ArithmeticError(f"NONCANDIDATE NINE-CLIQUE: {colors}, {clique}, {gram}")
            cliques.append({"extension_indices": clique, "candidate_permutation": permutation})
        record.update(extensions=extensions, norm_residual_counts=norm_counts,
                      extension_edges=edges, nine_cliques=cliques)
        totals["extension_nodes"] += len(extensions)
        totals["nine_cliques"] += len(cliques)
        records.append(record)
        print(f"anchor {colors}: {len(extensions)} nodes, {len(edges)} edges, {len(cliques)} nine-cliques", flush=True)
    return {"format": "thomson-n9-exact-gram-v1", "radius_lower_numerator": str(LNUM),
            "radius_upper_numerator": str(LNUM+1), "radius_denominator": str(DEN),
            "twice_inner_product_palette": [coefficients(p) for p in PALETTE],
            "anchors": records, "totals": totals}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=Path(__file__).with_name("exact_gram.json"))
    args = parser.parse_args()
    certificate = generate()
    args.output.write_text(json.dumps(certificate, indent=2)+"\n", encoding="utf-8")
    print(json.dumps(certificate["totals"], indent=2))
