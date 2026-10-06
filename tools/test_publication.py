"""Negative controls for the publication verifier, without changing files."""

import json
import runpy
from pathlib import Path


api = runpy.run_path(str(Path(__file__).with_name("verify_publication.py")))
files = api["inventory"]()
api["derivation"](files)
api["privacy"](files)


def rejects(label, fn, inputs):
    try:
        fn(inputs)
    except ValueError:
        return {"test": label, "result": "rejected-as-expected"}
    raise RuntimeError("Negative control accepted: " + label)


results = []
altered = dict(files)
altered["proof/lean/ThomsonN9/Basic.lean"] += b"\n"
results.append(rejects("changed-lean-source", api["derivation"], altered))
altered = dict(files)
altered["proof/near_sharp/reduced/near-sharp-d10-reduced-D60.json"] += b" "
results.append(rejects("changed-certificate", api["derivation"], altered))
altered = dict(files)
altered["proof/unlisted-file.txt"] = b"unlisted"
results.append(rejects("unexpected-proof-file", api["derivation"], altered))
altered = dict(files)
del altered["proof/lean/ThomsonN9/Basic.lean"]
results.append(rejects("missing-lean-source", api["derivation"], altered))
altered = {"synthetic.txt": ("C:" + chr(92) + "Users" + chr(92) + "PRIVATE_TEST").encode()}
results.append(rejects("private-path", api["privacy"], altered))
altered = {"synthetic.txt": (chr(92) + "Users" + chr(92) + "PRIVATE_TEST").encode()}
results.append(rejects("drive-relative-private-path", api["privacy"], altered))
altered = {"synthetic.txt": ("C:" + chr(92) + "Users" + chr(92) + "PRIVATE_TEST").encode("utf-16")}
results.append(rejects("utf16-private-path", api["privacy"], altered))
altered = {"synthetic.txt": ("gh" + "p_" + "0" * 36).encode()}
results.append(rejects("synthetic-credential", api["privacy"], altered))
print(json.dumps({"result": "PASS", "scope": "Publication verifier controls, not mathematical certificate controls",
                  "tests": results}, indent=2))
