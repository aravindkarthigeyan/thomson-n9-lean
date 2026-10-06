"""Exact exclusion of the seventh, antipodal contact window."""
import argparse
from fractions import Fraction as Q
from itertools import product
import json
from pathlib import Path

from check_exact_gram import COLORS, bounds

if not __debug__:
    raise RuntimeError("Certificate verification requires assertions; do not use python -O.")


def verify():
    epsilon = Q(1, 10000)
    windows = [(bounds(p)[0]/2-epsilon, bounds(p)[1]/2+epsilon) for p in COLORS]
    windows.append((Q(-1), -1+epsilon))
    assert all(-1 <= lo <= hi < 1 for lo, hi in windows)
    cases = []
    for i, j in product(range(7), repeat=2):
        u, v = windows[i], windows[j]
        uv_upper = max(a*b for a in u for b in v)
        sum_lower, sum_upper = u[0]+v[0], u[1]+v[1]
        sum_square_lower = Q(0) if sum_lower <= 0 <= sum_upper else min(sum_lower**2, sum_upper**2)
        assert 1+uv_upper >= 0
        determinant_upper = 2*epsilon*(1+uv_upper)-sum_square_lower
        assert determinant_upper < 0, f"Antipodal triple not excluded: {(i, j)}"
        assert determinant_upper < -Q(1, 6000)
        cases.append({"other_pair_colors": [i, j], "gram_determinant_upper": str(determinant_upper)})
    return {"result": "PASS", "inner_product_half_width": str(epsilon),
            "antipodal_window": ["-1", str(-1+epsilon)], "triple_color_cases": 49,
            "uniform_strict_determinant_upper_bound": "-1/6000",
            "largest_determinant_upper": str(max(Q(c["gram_determinant_upper"]) for c in cases)),
            "cases": cases,
            "identity": "det Gram(-1+delta,u,v)=2*delta*(1+u*v)-delta^2-(u+v)^2",
            "arithmetic": "stdlib Fractions, no floating-point decisions"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path,
                        default=Path(__file__).with_name("antipodal_window.check.json"))
    args = parser.parse_args()
    result = verify()
    args.output.write_text(json.dumps(result, indent=2)+"\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in result.items() if k != "cases"}, indent=2))
