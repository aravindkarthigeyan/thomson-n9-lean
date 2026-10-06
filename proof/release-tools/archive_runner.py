"""Plan or create an audited source ZIP; creation requires a successful clean proof run.

No Lean compiler is invoked. Plan mode performs no writes. Create mode never
copies proof objects: sources come exclusively from the accepted FREEZE file.
"""
from __future__ import annotations

import argparse
import ast
from dataclasses import dataclass
from datetime import datetime, timezone
import fnmatch
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import sys
import zipfile

HERE = Path(__file__).absolute().parent
TOP = "thomson-n9"


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def plain(path):
    path = Path(os.path.abspath(path))
    for part in (path, *path.parents):
        if part.exists() or part.is_symlink():
            info = part.lstat()
            require(not stat.S_ISLNK(info.st_mode), f"Symlink forbidden: {part}")
            require(not getattr(info, "st_file_attributes", 0) & 0x400,
                    f"Reparse point forbidden: {part}")
    return path


def within(path, root):
    return path == root or root in path.parents


def read_json(path):
    return json.loads(plain(path).read_text(encoding="utf-8-sig"))


def safe_name(name, policy):
    require(isinstance(name, str) and name and "\\" not in name,
            f"Invalid archive path: {name!r}")
    parts = name.split("/")
    require(not name.startswith("/") and all(p not in (".", "..", "") for p in parts),
            f"Absolute/traversal name: {name}")
    require(all(":" not in p and not p.endswith((" ", ".")) for p in parts),
            f"Unsafe Windows archive name: {name}")
    require(not re.search(r'[<>"|?*\x00-\x1f]', name), f"Invalid filesystem character: {name}")
    forbidden = {p.casefold() for p in policy["forbidden_path_components"]}
    require(not any(p.casefold() in forbidden for p in parts), f"Excluded folder: {name}")
    require(not any(fnmatch.fnmatchcase(parts[-1].casefold(), p.casefold())
                    for p in policy["forbidden_file_patterns"]), f"Excluded artifact: {name}")
    require(all(not re.fullmatch(r"(?i)(con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\..*)?", p)
                for p in parts), f"Reserved device name: {name}")
    return name


@dataclass
class Member:
    path: str
    source: Path
    role: str
    provenance: str
    digest: str
    size: int
    module: str | None = None

    def record(self):
        license_reference = ("lean/vendor/DELSARTE_LICENSE; Apache-2.0" if self.path.startswith("lean/vendor/") else
            "verification/CLAUDE_L1_IMPORT.json; user-authorized contribution, no blanket relicensing" if self.path.startswith("lean/ClaudeL1/") else
            "verification/CLAUDE_L2B_IMPORT.json; user-authorized contribution, no blanket relicensing" if self.path.startswith("lean/ClaudeL2b/") else
            "verification/CLAUDE_FORMAL_IMPORT.json; user-authorized contribution, no blanket relicensing" if self.path.startswith(("lean/ClaudeWindow/", "lean/ThomsonN9/Bernstein/")) else
            "Project-authored or separately attributed source; no blanket relicensing")
        result = dict(path=self.path, bytes=self.size, sha256=self.digest,
                      role=self.role, provenance=self.provenance,
                      license_reference=license_reference)
        if self.module:
            result.update(clean_module_if_lean=self.module, frozen_sha256_if_lean=self.digest)
        return result


class Inventory:
    def __init__(self, policy):
        self.policy, self.members = policy, {}
        self.folded = {}

    def add(self, source, target, role, provenance, expected=None, module=None):
        target = safe_name(target, self.policy)
        source = plain(source)
        require(source.is_file(), f"Missing source: {source}")
        digest = sha(source)
        require(expected is None or digest == expected, f"Source hash mismatch: {source}")
        folded = target.casefold()
        if folded in self.folded:
            previous = self.members[self.folded[folded]]
            require(previous.path == target and previous.source == source,
                    f"Case collision or duplicate destination: {target}")
            return
        self.folded[folded] = target
        self.members[target] = Member(target, source, role, provenance, digest,
                                      source.stat().st_size, module)


def python_closure(delivery, seeds, search_directories):
    pending = [delivery / name for name in seeds]
    found, external, edges = set(), set(), []
    while pending:
        path = plain(pending.pop())
        if path in found:
            continue
        require(path.is_file() and within(path, delivery), f"Missing/nonlocal Python source: {path}")
        found.add(path)
        tree = ast.parse(path.read_text(encoding="utf-8-sig"), filename=str(path))
        for node in ast.walk(tree):
            names = ([a.name for a in node.names] if isinstance(node, ast.Import) else
                     [node.module] if isinstance(node, ast.ImportFrom) and node.module else [])
            for name in names:
                relative = Path(*name.split("."))
                candidates = [path.parent / relative.with_suffix(".py")]
                candidates += [delivery / d / relative.with_suffix(".py") for d in search_directories]
                available = [p for p in candidates if p.is_file()]
                if available:
                    chosen = plain(available[0])
                    edges.append([path.relative_to(delivery).as_posix(), name,
                                  chosen.relative_to(delivery).as_posix()])
                    pending.append(chosen)
                elif name.split(".")[0] not in sys.stdlib_module_names:
                    external.add(name.split(".")[0])
    return sorted(found), sorted(external), edges


def collect_delivery(inv, delivery, policy, inputs, certificates):
    for item in certificates["files"]:
        inv.add(delivery / item["path"], item["path"], item["role"],
                "Explicit certificate planning inventory", item["sha256"])
    for name in inputs["generation_inputs"]:
        inv.add(delivery / name, name, "Immutable generation input; not a proof premise",
                "Explicit generator input closure")
    for item in inputs.get("diagnostic_files", []):
        inv.add(delivery / item["path"], item["path"],
                "Optional numerical diagnostic; not a proof premise",
                "Explicit diagnostic inventory", item["sha256"])
    seeds = inputs["python_seeds"] + policy["exact_checker_source_closure"]
    sources, external, edges = python_closure(delivery, seeds, inputs["python_module_search_directories"])
    for source in sources:
        name = source.relative_to(delivery).as_posix()
        inv.add(source, name, "Checker or untrusted generator source", "Explicit seeds plus static local-import closure")
    for name in inputs["metadata_files"]:
        inv.add(delivery / name, name, "Documentation, pins, or provenance", "Explicit metadata allowlist")
    for source in sorted(delivery.glob("*.md")):
        inv.add(source, source.name, "Current mathematical/reproduction documentation", "Root Markdown document allowlist")
    for name in ("archive_runner.py", "archive_source_scan.ps1", "SOURCE_ARCHIVE_POLICY.json",
                 "SOURCE_ARCHIVE_INPUTS.json", "SOURCE_ARCHIVE_CERTIFICATES.json"):
        inv.add(HERE / name, "release-tools/" + name, "Source archive tooling/policy", "This archive implementation")
    return external, edges


def verify_evidence_inventory(run, result, policy):
    expected = {}
    for item in result["evidenceFiles"]:
        name = safe_name(item["path"], policy)
        require("/" not in name and name != "RESULT.json", "Invalid flat evidence name")
        require(name.casefold() not in {n.casefold() for n in expected}, "Duplicate evidence name")
        expected[name] = item
    actual = {p.name for p in run.iterdir() if p.name != "RESULT.json"}
    require(actual == set(expected), "Fresh evidence inventory membership changed")
    for name, row in expected.items():
        path = plain(run / name)
        require(path.is_file() and path.stat().st_size == row["bytes"], "Fresh evidence size changed: " + name)
        require(sha(path) == row["sha256"], "Fresh evidence hash changed: " + name)


def collect_clean(inv, snapshot, result_path, freeze_hash, result_hash, policy):
    snapshot, result_path = plain(snapshot), plain(result_path)
    require(within(result_path, snapshot / "fresh-evidence"), "Clean result must belong to this snapshot")
    freeze_path = snapshot / "FREEZE.json"
    require(freeze_hash and sha(freeze_path) == freeze_hash, "Explicit final FREEZE digest required")
    require(result_hash and sha(result_path) == result_hash, "Explicit successful RESULT digest required")
    frozen, result = read_json(freeze_path), read_json(result_path)
    require(result["status"] == "PASS" and result["manifestSha256"] == freeze_hash,
            "No matching successful final clean result")
    require(result["finalTheoremsChecked"] == 6, "Six unconditional final theorem checks required")
    require(Path(frozen["snapshotRoot"]) == snapshot, "Snapshot identity mismatch")
    run = result_path.parent
    verify_evidence_inventory(run, result, policy)
    driver_rows = [row for row in frozen["files"] if row["path"] == "fresh-verification/FreezeRebuild.ps1"]
    require(len(driver_rows) == 1 and driver_rows[0]["sha256"] == result["driverSha256"],
            "Clean result driver does not match its frozen source")
    require(read_json(run / "toolchain.json")["driverSha256"] == result["driverSha256"],
            "Clean toolchain provenance records a different driver")
    require(sha(run / "targets.txt") == result["targetsSha256"], "Clean target inventory changed")
    require(sha(run / "steps.json") == result["stepsSha256"], "Clean step evidence changed")
    targets = (run / "targets.txt").read_text(encoding="utf-8-sig").splitlines()
    require(len(targets) == result["modules"] and len(set(targets)) == len(targets), "Target inventory mismatch")
    steps = read_json(run / "steps.json")
    required_steps = set(targets) | {"default-targets", "source-scanner-tests", "source-audit",
                                   "all-axioms", "final-target-types", "corrupt-coefficient"}
    required_steps |= {test["path"] for test in frozen["tests"]}
    require(required_steps <= {s["name"] for s in steps if s["passed"]}, "Incomplete clean-run steps")
    require(all(s["passed"] for s in steps), "A failed clean step remains")
    for source in frozen["files"]:
        relative = source["path"]
        module = None
        if relative.endswith(".lean") and not relative.startswith(("frozen-tests/", "fresh-verification/")):
            module = relative.removeprefix("vendor/").removesuffix(".lean").replace("/", ".")
            require(module in targets, f"Unbuilt proof-source module: {module}")
        inv.add(snapshot / relative, "lean/" + relative, source["role"],
                "Successful clean source freeze " + freeze_hash, source["sha256"], module)
    for required in policy["required_license_files"]:
        require(required in inv.members, f"Required license/provenance absent: {required}")
    for required in ("lean/ThomsonN9/Completion.lean", "lean/Challenge.lean", "lean/Solution.lean"):
        require(required in inv.members, f"Final proof source absent: {required}")
    for report in steps:
        for key in ("stdout", "stderr"):
            log = plain(report[key])
            require(within(log, run), f"Step log outside fresh evidence: {log}")
            require(log.is_file(), f"Missing fresh log: {log}")
            require(sha(log) == report[key + "Sha256"], f"Clean step log changed: {log}")
    final_step = next(s for s in steps if s["name"] == "final-target-types")
    final_text = Path(final_step["stdout"]).read_text(encoding="utf-8-sig")
    for name in policy["required_final_theorems"]:
        require(name in final_text, f"Missing final theorem report: {name}")
    for source in sorted(run.iterdir()):
        plain(source)
        require(source.is_file(), f"Unexpected nested clean evidence: {source}")
        require(source.suffix in (".json", ".log", ".txt"), f"Unexpected evidence extension: {source}")
        inv.add(source, "evidence/clean/" + source.name, "Fresh successful clean-run evidence", str(result_path))
    inv.add(freeze_path, "evidence/clean/FREEZE.json", "Original source-only freeze manifest", freeze_hash)
    return result


def encoded(data):
    return (json.dumps(data, indent=2, sort_keys=True) + "\n").encode("utf-8")


def zip_write(archive, name, stream):
    info = zipfile.ZipInfo(TOP + "/" + name, (1980, 1, 1, 0, 0, 0))
    info.compress_type = zipfile.ZIP_DEFLATED
    info.external_attr = (stat.S_IFREG | 0o644) << 16
    with archive.open(info, "w", force_zip64=True) as target:
        shutil.copyfileobj(stream, target, 1024 * 1024)


def extract_verify(archive_path, extract_root, manifest, policy):
    require(not extract_root.exists(), "Extraction target must not exist")
    plain(extract_root)
    extract_root.mkdir(parents=True)
    expected = {TOP + "/" + row["path"]: row for row in manifest["files"]}
    expected[TOP + "/SOURCE_MANIFEST.json"] = dict(bytes=len(encoded(manifest)),
                                                    sha256=hashlib.sha256(encoded(manifest)).hexdigest())
    seen = set()
    with zipfile.ZipFile(archive_path) as archive:
        for member in archive.infolist():
            require(member.filename.startswith(TOP + "/"), "Wrong archive root")
            safe_name(member.filename, policy)
            require(member.filename.casefold() not in seen, "Duplicate archive member")
            seen.add(member.filename.casefold())
            require(member.filename in expected, "Unmanifested archive member")
            require(stat.S_IFMT(member.external_attr >> 16) in (0, stat.S_IFREG), "Non-regular ZIP member")
            row = expected[member.filename]
            require(member.file_size == row["bytes"], "ZIP member size mismatch")
            target = extract_root.joinpath(*PurePosixPath(member.filename).parts)
            require(within(target, extract_root), "Extraction escapes target")
            target.parent.mkdir(parents=True, exist_ok=True)
            with archive.open(member) as src, target.open("xb") as dst:
                shutil.copyfileobj(src, dst, 1024 * 1024)
            require(sha(target) == row["sha256"], "Extracted SHA mismatch: " + member.filename)
    require(seen == {name.casefold() for name in expected}, "Missing archive entries")
    return extract_root / TOP


def checked(command, cwd, logfile):
    env = os.environ.copy()
    env.pop("PYTHONOPTIMIZE", None)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    with logfile.open("xb") as out:
        code = subprocess.run(command, cwd=cwd, env=env, stdout=out, stderr=subprocess.STDOUT).returncode
    require(code == 0, f"Post-extraction check failed ({code}): {command}; see {logfile}")
    return dict(command=command, exitCode=code, log=logfile.name, logSha256=sha(logfile))


def main():
    require(__debug__ and sys.flags.optimize == 0,
            "Python assertions must be enabled; optimized execution is forbidden before any writes")
    require(not os.environ.get("PYTHONOPTIMIZE"),
            "Inherited nonempty PYTHONOPTIMIZE is forbidden before any writes")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=("plan", "create"), default="plan")
    parser.add_argument("--delivery", type=Path, required=True)
    parser.add_argument("--snapshot", type=Path)
    parser.add_argument("--clean-result", type=Path)
    parser.add_argument("--freeze-sha256")
    parser.add_argument("--result-sha256")
    parser.add_argument("--zip", type=Path)
    parser.add_argument("--extract-root", type=Path)
    args = parser.parse_args()
    delivery = plain(args.delivery)
    policy = read_json(HERE / "SOURCE_ARCHIVE_POLICY.json")
    inputs = read_json(HERE / "SOURCE_ARCHIVE_INPUTS.json")
    certificates = read_json(HERE / "SOURCE_ARCHIVE_CERTIFICATES.json")
    inv = Inventory(policy)
    external, edges = collect_delivery(inv, delivery, policy, inputs, certificates)
    result = None
    if args.snapshot and args.clean_result:
        result = collect_clean(inv, args.snapshot, args.clean_result, args.freeze_sha256,
                               args.result_sha256, policy)
    if args.mode == "plan":
        print(json.dumps(dict(status="PLAN ONLY", noFilesWritten=True, noCompilerLaunched=True,
            finalCleanResultValidated=result is not None, files=len(inv.members),
            bytes=sum(m.size for m in inv.members.values()), externalPythonModules=external,
            pythonImportEdges=edges,
            remainingGate="Create requires exact successful final FREEZE/RESULT digests and new ZIP/extraction paths"), indent=2))
        return
    require(result is not None, "No archive before the successful final clean proof run")
    require(args.zip and args.extract_root, "New ZIP and extraction paths required")
    destination, extract_root = plain(args.zip), plain(args.extract_root)
    require(not destination.exists() and not extract_root.exists(), "Never overwrite an archive or extraction tree")
    require(not within(destination, delivery) and not within(extract_root, delivery),
            "Create outside the live delivery tree; publish only after validation")
    require(not within(destination, Path(args.snapshot).absolute()) and
            not within(extract_root, Path(args.snapshot).absolute()), "Do not modify the clean snapshot")
    audit = Path(str(destination) + ".audit")
    require(not audit.exists(), "Audit directory already exists")
    destination.parent.mkdir(parents=True, exist_ok=True)
    audit.mkdir()
    manifest = dict(schema="thomson-n9-source-release-v1",
        claim="Sources byte-identical to the successful clean project-source rebuild; pinned external dependencies were cached",
        finalFreezeSha256=args.freeze_sha256, finalResultSha256=args.result_sha256,
        finalTheorems=policy["required_final_theorems"], externalPythonModules=external,
        pythonImportEdges=edges, generatedUtc=datetime.now(timezone.utc).isoformat(),
        archiveTool="Python stdlib zipfile " + sys.version,
        files=[inv.members[name].record() for name in sorted(inv.members)])
    import io
    with zipfile.ZipFile(destination, "x", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name in sorted(inv.members):
            member = inv.members[name]
            require(sha(member.source) == member.digest, "Source changed before ZIP creation: " + name)
            with member.source.open("rb") as source:
                zip_write(archive, name, source)
        zip_write(archive, "SOURCE_MANIFEST.json", io.BytesIO(encoded(manifest)))
    extracted = extract_verify(destination, extract_root, manifest, policy)
    checks = []
    checks.append(checked(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        str(extracted / "release-tools/archive_source_scan.ps1"), "-ProjectRoot", str(extracted / "lean")],
        extracted, audit / "source-scan.log"))
    checks.append(checked(["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
        str(extracted / "lean/verification/Build.ps1"), "-ListTargets"], extracted, audit / "targets.log"))
    checks.append(checked([sys.executable, "verify_global.py", "--reduced", "--refined", "--report",
                          str(audit / "replayed-global.json")], extracted, audit / "exact-global.log"))
    checks.append(checked([sys.executable, "ambient_circuit/check.py", "ambient_circuit/ambient-circuit-k0.json",
        "--negative-controls", "--report", str(audit / "replayed-ambient.json")], extracted, audit / "exact-ambient.log"))
    checks.append(checked([sys.executable, "ambient_circuit/check_recipes.py", "--report",
                          str(audit / "replayed-recipes.json")], extracted, audit / "exact-recipes.log"))
    for member in inv.members.values():
        require(sha(extracted / member.path) == member.digest, "Extraction check modified a source: " + member.path)
    digest = sha(destination)
    outcome = dict(status="PASS", zipSha256=digest, archive=str(destination), extraction=str(extract_root),
                   members=len(manifest["files"]) + 1, finalFreezeSha256=args.freeze_sha256,
                   finalResultSha256=args.result_sha256, checks=checks,
                   pythonAssertionsEnabled=True, inheritedPythonOptimizeRejected=True,
                   newLeanCompilationPerformed=False)
    (audit / "RESULT.json").write_bytes(encoded(outcome))
    (audit / "SHA256SUMS.txt").write_text(digest + "  " + destination.name + "\n", encoding="ascii")
    print(json.dumps(outcome, indent=2))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(json.dumps(dict(status="INCOMPLETE", error=str(error))), file=sys.stderr)
        raise SystemExit(1)
