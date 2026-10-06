"""Check public artifact bytes; this does not check the mathematical theorem."""

import argparse
import hashlib
import json
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = "PUBLICATION_MANIFEST.json"
HOME = re.compile(r"(?i)([a-z]:[\\/]+Users[\\/]+|\\+Users\\+|/(?:mnt/)?[a-z]/Users/|/home/|/Users/)([a-z0-9_.@-]+)")
SECRETS = re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|(?:ghp_|github_pat_)[A-Za-z0-9_]{24,}|sk-proj-[A-Za-z0-9_-]{32,}")


def sha(data):
    return hashlib.sha256(data).hexdigest()


def need(test, message):
    if not test:
        raise ValueError(message)


def retained(path):
    parts = path.relative_to(ROOT).parts
    if any(p in {".git", ".lake", "__pycache__"} for p in parts):
        return False
    if parts[0] in {"local-results", "dist"}:
        return False
    if path.suffix in {".pyc", ".aux", ".toc", ".fls"}:
        return False
    return path.is_file() and str(path.relative_to(ROOT).as_posix()) != MANIFEST


def inventory():
    return {p.relative_to(ROOT).as_posix(): p.read_bytes()
            for p in ROOT.rglob("*") if retained(p)}


def derivation(files):
    record = json.loads(files["PUBLICATION_DERIVATION.json"])
    rows = record["files"]
    need(len(rows) == 1173, "Original member count differs")
    need(len({r["path"] for r in rows}) == len(rows), "Duplicate derivation path")
    need(record["original_archive_sha256"] ==
         "de141e877858893f88995c54147938ad6fb3b9616e1ce9350d9414cfbfdacf63",
         "Unexpected original archive")
    for row in rows:
        name = row["path"]
        need(name in files, "Missing original-derived file: " + name)
        need(sha(files[name]) == row["public_sha256"], "Derived hash mismatch: " + name)
        need(len(files[name]) == row["public_bytes"], "Derived byte count mismatch: " + name)
        if name.endswith(".lean") or name.startswith(("proof/certificates/", "proof/near_sharp/", "proof/rigidity/", "proof/ambient_circuit/", "proof/algebra/", "proof/sdp/")):
            need(row["original_sha256"] == row["public_sha256"],
                 "Proof source or exact input changed: " + name)
    need(sum(r["path"].endswith(".lean") for r in rows) == 199, "Lean source count differs")
    need({p for p in files if p.startswith("proof/")} == {r["path"] for r in rows},
         "Unexpected file inside original-derived proof tree")


def privacy(files):
    for name, data in files.items():
        try:
            encoding = "utf-16" if data.startswith((b"\xff\xfe", b"\xfe\xff")) else "utf-8-sig"
            text = data.decode(encoding)
        except UnicodeDecodeError:
            continue
        for match in HOME.finditer(text):
            need(match[2] == "REDACTED", "Unredacted home path in " + name)
        need(SECRETS.search(text) is None, "Credential-shaped text in " + name)
    # This is a targeted publication check, not a guarantee against every secret.


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--freeze", action="store_true", help="Write a NEW inventory; refuses to overwrite")
    args = parser.parse_args()
    files = inventory()
    derivation(files)
    privacy(files)
    actual = [{"path": name, "bytes": len(data), "sha256": sha(data)}
              for name, data in sorted(files.items())]
    manifest = ROOT / MANIFEST
    if args.freeze:
        need(not manifest.exists(), "Refusing to replace an existing release inventory")
        manifest.write_text(json.dumps({"schema": "thomson-n9-publication-inventory-v1",
                                       "claim": "File integrity only; not theorem checking", "files": actual},
                                      indent=2) + "\n", encoding="utf-8")
    else:
        need(manifest.exists(), "No finalized publication inventory yet")
        expected = json.loads(manifest.read_text(encoding="utf-8"))["files"]
        need(actual == expected, "Publication inventory differs (missing, altered, or extra file)")
    print(json.dumps({"result": "PASS", "files": len(files),
                      "original_lean_files_unchanged": 199,
                      "derivation_integrity": "PASS", "targeted_privacy_scan": "PASS",
                      "scope": "Publication inventory only, not a Lean theorem check"}, indent=2))


if __name__ == "__main__":
    main()
