"""Exact root/Hermite data checker; the analytic remainder theorem is documented."""
import argparse
from copy import deepcopy
from fractions import Fraction as Q
import hashlib
import json
from math import comb
from pathlib import Path

from exact_interval import I, S, BITS

if not __debug__:
    raise RuntimeError("Exact Hermite verification requires assertions")

OLD_LO = Q(7105483340929538113277041792727912437680, 10**40)
OLD_HI = OLD_LO+Q(1, 10**40)


def stationarity(r):
    return (-2*I(3).sqrt()/r**2+3*r/(2*(1-r*r).sqrt()**3)+
            6*r/(4-r*r).sqrt()**3-6/(2+2*r).sqrt()**3+6/(2-r).sqrt()**3)


def family_energy(r):
    return (2*I(3).sqrt()/r+3/(2*(1-r*r).sqrt())+6/(4-r*r).sqrt()+
            I(3).sqrt()+6/(2+2*r).sqrt()+12/(2-r).sqrt())


def hermite_intervals(lo, hi):
    r = I(lo, hi)
    contacts = [r*r/2-1, -r, I(Q(-1, 2)), 2*r*r-1, 1-3*r*r/2, r/2]
    assert all(-S < c.lo <= c.hi < S for c in contacts)
    assert all(a.hi < b.lo for a, b in zip(contacts, contacts[1:]))
    groups = [I(-1)]+contacts
    labels = [0]*9+[label for label in range(1, 7) for _ in range(2)]
    nodes = [groups[label] for label in labels]
    rows = []
    for i, label in enumerate(labels):
        row = [(2-2*nodes[i]).sqrt().inv()]
        for order in range(1, i+1):
            if label == labels[i-order]:
                if label == 0:
                    row.append(I(Q(comb(2*order, order), 2**(3*order+1))))
                else:
                    assert order == 1
                    row.append((2-2*nodes[i]).sqrt().inv()**3)
            else:
                row.append((row[-1]-rows[i-1][order-1])/(nodes[i]-nodes[i-order]))
        rows.append(row)
    coefficients = [I(0)]*21
    basis = [I(1)]
    for j in range(21):
        for k, c in enumerate(basis):
            coefficients[k] += rows[j][j]*c
        if j < 20:
            following = [I(0)]*(len(basis)+1)
            for k, c in enumerate(basis):
                following[k] -= nodes[j]*c
                following[k+1] += c
            basis = following
    return coefficients, contacts


def checked_root(data):
    lo, hi = map(Q, data["radius_interval"])
    assert OLD_LO < lo < hi < OLD_HI and hi-lo <= Q(1, 10**160)
    left, right = stationarity(I(lo)), stationarity(I(hi))
    assert left.hi < 0 < right.lo, "Original stationarity signs are not certified"
    midpoint = (lo+hi)/2
    assert Q(data["radius_midpoint"]) == midpoint
    return lo, hi, midpoint, left, right


def check(data):
    assert data["format"] == "thomson-n9-near-sharp-hermite-v1"
    lo, hi, midpoint, left, right = checked_root(data)
    intervals, contacts = hermite_intervals(lo, hi)
    coefficients = list(map(Q, data["coefficients_monomial"]))
    assert len(coefficients) == 21
    bounds = [value.endpoints() for value in intervals]
    nonconstant_error = sum(max(abs(a-c), abs(b-c))
                            for (a, b), c in zip(bounds[1:], coefficients[1:]))
    dominance = bounds[0][0]-coefficients[0]-nonconstant_error
    assert dominance >= 0, "Rational h is not certified below the exact Hermite polynomial"
    error = max(abs(bounds[0][0]-coefficients[0]), abs(bounds[0][1]-coefficients[0]))+nonconstant_error
    assert error < Q(1, 10**130), "Hermite approximation misses the required accuracy"
    energy_interval = family_energy(I(midpoint))
    energy_upper = Q(data["energy_upper"])
    assert Q(energy_interval.hi, S) <= energy_upper
    assert energy_upper-Q(energy_interval.lo, S) < Q(1, 10**130)
    epsilon = Q(data["window_half_width"])
    assert epsilon == Q(1, 10000)
    derivative_lower = Q(comb(42, 21), 2**64)
    assert derivative_lower > Q(1, 10**8)
    exterior = Q(1, 10**92)
    assert derivative_lower*epsilon**21 > exterior
    return {"result": "PASS", "coefficients_monomial": list(map(str, coefficients)),
            "energy_upper": str(energy_upper), "radius_interval": [str(lo), str(hi)],
            "radius_midpoint": str(midpoint), "radius_interval_width": str(hi-lo),
            "endpoint_stationarity_intervals": [left.strings(), right.strings()],
            "candidate_contacts_enclosures": [value.strings() for value in contacts],
            "hermite_coefficient_intervals": [value.strings() for value in intervals],
            "hermite_error_upper": str(error), "hermite_dominance_margin": str(dominance),
            "midpoint_energy_interval": energy_interval.strings(),
            "window_half_width": str(epsilon), "exterior_slack_lower": str(exterior),
            "remainder_derivative_lower": str(derivative_lower), "dyadic_bits": BITS,
            "scope": "Exact rational data plus the explicit Hermite remainder and family-minimum arguments; not Lean checked"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("certificate", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--negative-control", action="store_true")
    args = parser.parse_args()
    raw = args.certificate.read_bytes()
    data = json.loads(raw)
    report = check(data)
    if args.negative_control:
        cases = []
        corrupted = deepcopy(data)
        corrupted["coefficients_monomial"][0] = str(Q(corrupted["coefficients_monomial"][0])+Q(1, 10**120))
        cases.append(("Hermite constant raised above its enclosure", corrupted))
        corrupted = deepcopy(data)
        corrupted["energy_upper"] = str(Q(corrupted["energy_upper"])-Q(1, 10**120))
        cases.append(("energy upper enclosure lowered", corrupted))
        corrupted = deepcopy(data)
        lo, hi = map(Q, corrupted["radius_interval"])
        corrupted["radius_interval"] = [str(lo+Q(1, 10**200)), str(hi+Q(1, 10**200))]
        corrupted["radius_midpoint"] = str((lo+hi)/2+Q(1, 10**200))
        cases.append(("radius bracket translated away from the root", corrupted))
        for label, corrupted in cases:
            try:
                check(corrupted)
            except AssertionError:
                pass
            else:
                raise AssertionError("Corrupted Hermite data accepted: "+label)
        report["negative_controls_rejected"] = [label for label, _ in cases]
    report["certificate_sha256"] = hashlib.sha256(raw).hexdigest()
    rendered = json.dumps(report, indent=2)+"\n"
    if args.output:
        args.output.write_text(rendered)
    print(json.dumps({k: v for k, v in report.items() if k not in ["coefficients_monomial", "hermite_coefficient_intervals", "candidate_contacts_enclosures", "endpoint_stationarity_intervals", "midpoint_energy_interval"]}, indent=2))
