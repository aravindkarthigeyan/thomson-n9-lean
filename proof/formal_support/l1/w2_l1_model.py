"""Exact model of the L1 Lean pipeline (shared by the generator and the self-check).

Reads the REDUCED certificate (hash-checked, read-only) and computes, with python-flint integers:

  * kernel columns  cols_k[r] = [delta*B_k[i][r] for i in 0..10-k]   (delta = 10^60), k = 0..9
    (block 10 is asserted identically zero and dropped);
  * PK = sum_k Expr_k   where Expr_k = 56*Sym6(Y_k) + 8*Sym6(Y_k)(u,u,1) + 8*Sym6(Y_k)(v,v,1)
                                       + 8*Sym6(Y_k)(t,t,1) + Sym6(Y_k)(1,1,1),
    Y_k = (sum_r a_r(u) a_r(v)) * q_k(u,v,t),  a_r(x) = sum_i cols_k[r][i] x^i,
    Sym6 = plain sum over the six argument permutations (no 1/6), so that
    Expr_k = 48*delta^2 * correctedFactorKernel(B_k, x^i, k)   (Codex's definition);
  * SOS columns  c = sum_i delta*C_r[i,m] * b_{r,i}  (integer polynomials), one copy per column,
    multiplier trees g_code = 10^4 * domainWeight(M,u,v,t)[code], code = r // 2;
    running total T = sum g_code * c^2 (one copy);
  * LHS  = 3*10^64 * (H(u)+H(v)+H(t)) + c0,  H_i = delta*h_i,  c0 = -S*e/36,  S = 9*10^124;
  * residual R = LHS - 1875*PK - 3*(T + T(v,u,t) + T(t,u,v))  and its exact l1.

Scale bookkeeping (S = 9*10^124):
  S * (h(u)+h(v)+h(t))/3 = 3*10^64 * (H(u)+H(v)+H(t));
  S * correctedFactorKernel_k = 1875 * Expr_k            (1875 * 48 * 10^120 = S);
  S * sum_r sigma_r = 3 * (T + T(v,u,t) + T(t,u,v))       (weights g/(3*10^124), see README);
  hence R = S * A (A = residual of the Python verifier) and l1(R) = S * L_new = 10 * L_num.
"""
import hashlib
import json
from fractions import Fraction as F
from itertools import permutations
from pathlib import Path

import flint

W = Path(r"C:\Users\REDACTED\Documents\Codex\2026-10-05\analyze-what-s-u")
CERT = W / "claude/formal/data/reduced/near-sharp-d10-reduced-D60.json"
SHA = "9816ae66f3b68caf4a03d6c6f7c514124c8cd8ba4415497a79443ce64f158781"
D = 21                     # per-variable exponent bound
DELTA = 10 ** 60           # factor-entry denominator
GSCALE = 10 ** 4           # multiplier scale (denominator of M = 5593/10000)
S_GLOB = 9 * 10 ** 124     # global identity scale
HSCALE = 3 * 10 ** 64      # S_GLOB / (3 * DELTA)
KSCALE = 1875              # S_GLOB / (48 * DELTA^2)
SSCALE = 3                 # S_GLOB / (3 * GSCALE * DELTA^2)
CTX = flint.fmpz_mpoly_ctx.get(("u", "v", "t"), "lex")
U, V, T = CTX.gens()
ONE = CTX.from_dict({(0, 0, 0): 1})
ZERO = CTX.from_dict({})


def kexp(e):
    a, b, d = e
    return a + D * (b + D * d)


def load():
    raw = CERT.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == SHA, "certificate hash mismatch"
    data = json.loads(raw)
    assert data["format"] == "thomson-threepoint-sos-v1"
    assert data["sos_basis"] == "symmetry-box-v1"
    assert data["n"] == 9 and data["degree"] == 10
    assert F(data["minimum_inner_product"]) == -1
    assert F(data["maximum_inner_product"]) == F(5593, 10000)
    return data


def to_int(x, scale):
    v = F(x) * scale
    assert v.denominator == 1, f"entry {x} not on the 1/{scale} grid"
    return int(v)


# ------------------------------------------------------------------ kernel part
def qpolys(n):
    w = T - U * V
    m = (1 - U ** 2) * (1 - V ** 2)
    q = [ONE, w]
    while len(q) < n + 1:
        q.append(2 * w * q[-1] - m * q[-2])
    return q[: n + 1]


def kernel_cols(data):
    kf = data["kernel_factors"]
    assert len(kf) == 11
    assert all(F(x) == 0 for row in kf[10] for x in row), "kernel block 10 is not zero"
    out = []
    for k in range(10):
        size = 11 - k
        rows = kf[k]
        assert len(rows) == size and all(len(r) == size for r in rows)
        cols = [[to_int(rows[i][r], DELTA) for i in range(size)] for r in range(size)]
        out.append(cols)
    return out


def sym6(p):
    # edgeSymmetrize order: F u v t, F v u t, F u t v, F t u v, F v t u, F t v u
    return (p + p.compose(V, U, T) + p.compose(U, T, V) + p.compose(T, U, V)
            + p.compose(V, T, U) + p.compose(T, V, U))


def expr_k(cols, k, q):
    acc = ZERO
    for c in cols:
        a_u = CTX.from_dict({(i, 0, 0): x for i, x in enumerate(c) if x})
        a_v = CTX.from_dict({(0, i, 0): x for i, x in enumerate(c) if x})
        acc += a_u * a_v
    y = acc * q[k]
    s = sym6(y)
    return (56 * s + 8 * s.compose(U, U, ONE) + 8 * s.compose(V, V, ONE)
            + 8 * s.compose(T, T, ONE) + s.compose(ONE, ONE, ONE))


def kernel_total(kcols):
    q = qpolys(10)
    pk = ZERO
    for k, cols in enumerate(kcols):
        pk += expr_k(cols, k, q)
    return pk


def l1_list(c):
    return sum(abs(x) for x in c)


def qL1(n):
    a, b = 1, 2
    if n == 0:
        return 1
    for _ in range(n - 1):
        a, b = b, 4 * b + 4 * a
    return b


def expr_l1(cols, k):
    """uncollected l1 of Expr_k exactly as built in Lean (KC.Ops.exprPoly)"""
    return 486 * sum(l1_list(c) ** 2 for c in cols) * qL1(k)


# ------------------------------------------------------------------ SOS part
def monomial_list(q):
    return [(i, j, k) for i in range(q + 1) for j in range(q + 1 - i) for k in range(q + 1 - i - j)]


def basis_full_group(q):
    reps = sorted({(a, b, c) for a in range(q + 1) for b in range(a + 1) for c in range(b + 1)
                   if a + b + c <= q})
    even = [{x: 1 for x in set(permutations(e))} for e in reps]
    odd = [{(i, j, k): 1, (i, k, j): -1} for (i, j, k) in monomial_list(q) if j < k]
    return even, odd


def basis_u_anchored(q):
    even = []
    for (i, j, k) in monomial_list(q):
        if j < k:
            even.append({(i, j, k): 1, (i, k, j): 1})
        elif j == k:
            even.append({(i, j, k): 1})
    odd = [{(i, j, k): 1, (i, k, j): -1} for (i, j, k) in monomial_list(q) if j < k]
    return even, odd


GRAMD = 1 + 2 * U * V * T - U ** 2 - V ** 2 - T ** 2


def gpoly(code):
    """10^4 * domainWeight(M,u,v,t)[code], M = 5593/10000 (integer polynomial)"""
    lo = 1 + U
    hi = 5593 - 10000 * U          # 10^4 (M - u)
    return [10000 * ONE, 10000 * lo, hi, 10000 * GRAMD, lo * hi, GRAMD * lo * hi][code]


def sos_blocks():
    """(code, basis) in certificate order (symmetry-box-v1, d = 10)."""
    mult = [(0, 10, True), (1, 9, False), (2, 9, False), (3, 8, True), (4, 9, False), (5, 7, False)]
    out = []
    for code, q, full in mult:
        even, odd = basis_full_group(q) if full else basis_u_anchored(q)
        out.append((code, even))
        out.append((code, odd))
    return out


def sos_columns(data):
    """list of (code, [column dicts]) per SOS block (nonzero columns only)"""
    specs = sos_blocks()
    sf = data["sos_factors"]
    assert len(sf) == 12
    sizes = [len(b) for _, b in specs]
    assert sizes == [67, 125, 125, 95, 125, 95, 41, 70, 125, 95, 70, 50], sizes
    out = []
    for (code, basis), rows in zip(specs, sf):
        n = len(basis)
        assert len(rows) == n and all(len(r) == n for r in rows)
        Ci = [[to_int(x, DELTA) for x in row] for row in rows]
        cols = []
        for m in range(n):
            c = {}
            for i in range(n):
                v = Ci[i][m]
                if v:
                    for e, s in basis[i].items():
                        c[e] = c.get(e, 0) + s * v
            c = {e: x for e, x in c.items() if x}
            if c:
                cols.append(c)
        out.append((code, cols))
    return out


# ------------------------------------------------------------------ LHS and residual
def lhs_data(data):
    h = [F(x) for x in data["minorant"]]
    assert len(h) == 21
    H = [to_int(x, DELTA) for x in h]
    e = F(data["raw_energy"])
    c0 = -S_GLOB * e / 36
    assert c0.denominator == 1
    return H, int(c0), e


def lhs_poly(H, c0):
    hu = CTX.from_dict({(i, 0, 0): x for i, x in enumerate(H) if x})
    return HSCALE * (hu + hu.compose(V, U, T) + hu.compose(T, V, U)) + c0


def residual(lhs, pk, tot):
    return lhs - KSCALE * pk - SSCALE * (tot + tot.compose(V, U, T) + tot.compose(T, U, V))


def poly_l1(p):
    return sum(abs(int(c)) for c in p.coeffs())


def L_new(data):
    e = F(data["raw_energy"])
    cert = F(data["certified_energy"])
    return (e - cert) / 36
