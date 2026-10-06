"""Adversarial tests; mutate copies only, and require the intended rejection."""
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import subprocess
import sys

from check_exact_gram import verify as verify_exact
from check_window_gram import verify as verify_window

if not __debug__:
    raise RuntimeError("Tests require assertions.")


HERE = Path(__file__).resolve().parent
FILES = [HERE / "exact_gram.json", HERE / "window_gram.json"]
BEFORE = [hashlib.sha256(path.read_bytes()).hexdigest() for path in FILES]
EXACT, WINDOW = [json.loads(path.read_text(encoding="utf-8")) for path in FILES]
RESULTS = []


def reject(name, checker, certificate, expected=""):
    try:
        checker(certificate)
    except AssertionError as error:
        assert expected in str(error)
        RESULTS.append({"test": name, "result": "REJECTED", "diagnostic": str(error) or "AssertionError"})
    else:
        raise AssertionError(f"Corrupted certificate accepted: {name}")


bad = deepcopy(EXACT)
bad["anchors"][0]["determinant_of_twice_gram"][0] += 1
reject("exact determinant coefficient +1", verify_exact, bad)

bad = deepcopy(EXACT)
record = next(a for a in bad["anchors"] if a.get("nine_cliques"))
mapping = record["nine_cliques"][0]["candidate_permutation"]
mapping[0] = mapping[1]
reject("exact clique permutation duplicated", verify_exact, bad)

bad = deepcopy(WINDOW)
record = next(a for a in bad["anchors"] if a.get("nine_cliques"))
node = record["nine_cliques"][0]["extension_indices"][0]
record["extensions"].pop(node)
reject("window actual extension omitted", verify_window, bad, "Unverified exclusion")

bad = deepcopy(WINDOW)
record = next(a for a in bad["anchors"] if a.get("nine_cliques"))
i, j = record["nine_cliques"][0]["extension_indices"][:2]
edge = next(e for e in record["extension_edges"] if e[:2] == [i, j])
edge[2] = (edge[2]+1) % 6
reject("window actual edge color changed", verify_window, bad, "Unverified exclusion")

for checker in ("check_exact_gram.py", "check_window_gram.py", "check_antipodal_window.py"):
    run = subprocess.run([sys.executable, "-O", str(HERE / checker)], capture_output=True, text=True)
    assert run.returncode != 0 and "do not use python -O" in run.stderr
    RESULTS.append({"test": checker + " refuses -O", "result": "REJECTED"})

assert BEFORE == [hashlib.sha256(path.read_bytes()).hexdigest() for path in FILES]
report = {"result": "PASS", "tests": RESULTS, "original_certificates_unchanged": True}
rendered = json.dumps(report, indent=2)+"\n"
(HERE / "mutation.check.json").write_text(rendered, encoding="utf-8")
print(rendered, end="")
