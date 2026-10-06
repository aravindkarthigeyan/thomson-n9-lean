"""Plan, or explicitly authorize work-only staging of small secondary evidence.

Never invokes a checker/compiler or writes to outputs. Default planning does not
hash growing check logs or create files. Staging requires a completed outer run,
a hash-bound independent audit, fresh root authorization, and an approved plan.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import shutil
import stat

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
V = ROOT / "work/n9-independent-verification"
S = V / "tools/second_kernel"
B = S / "build/runs/20261005-224433"
E = S / "runs/n9-complete-v4-20261006-export-01"
C = E / "check-20261006-095413"
U = ROOT / "work/n9-independent-supervision"
OE = U / "runs/n9-complete-v4-20261006-export-01"
OC = U / "runs/n9-complete-v4-20261006-check-01"
N = ROOT / "claude/verify_final/tools/second_kernel/src/nanoda_lib"
STAGING = ROOT / "work/n9-secondary-bundle"
PREFIX = "verification/secondary/"
EXPORT = {"path": str(E / "export.ndjson"), "bytes": 514465728,
          "sha256": "6ea32a64e1aabdfbf06dc731537de0083f7e60e5eb76b408e5c418ccf1a93b3c",
          "lines": 9727409, "declarations": 55248,
          "included": False, "reason": "Large locally retained proof-term artifact; regenerate from pinned sources"}


def need(value, message):
    if not value:
        raise ValueError(message)


def plain(path):
    path = Path(path).absolute()
    for part in (path, *path.parents):
        if part.exists() or part.is_symlink():
            info = part.lstat()
            need(not stat.S_ISLNK(info.st_mode) and not getattr(info, "st_file_attributes", 0) & 1024,
                 f"Reparse/symlink path: {part}")
    return path


def digest(path):
    with plain(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def load(path):
    def pairs(items):
        value = {}
        for key, item in items:
            need(key not in value, f"Duplicate JSON key: {key}")
            value[key] = item
        return value
    return json.loads(plain(path).read_text(encoding="utf-8-sig"), object_pairs_hook=pairs)


def encoded(value):
    return (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()


def binding(path):
    path = plain(path)
    need(path.is_file(), f"Missing evidence: {path}")
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": digest(path)}


def check_binding(row):
    need(binding(row["path"]) == row, f"Recorded evidence changed: {row['path']}")


def fixed_entries():
    rows = []
    def group(base, names, target, required=True, live=False):
        for name in names:
            rows.append({"source": str(base / name), "destination": PREFIX + target + name,
                         "required": required, "liveUntilCompletion": live})
    group(V, ["PREPARATION_AUDIT_5.json"], "sources/")
    group(V / "tools", ["FINAL_PINS.json", "vf_common.py", "run_step.py", "resource_policy.py"], "sources/tools/")
    group(S, ["PINS.json", "env.sh", "build_second_kernel.sh", "run_second_kernel.sh", "sk_tool.py",
              "redirect.py", "make_semantic_sites.py", "nanoda_semantic_sites.json"], "sources/tools/second_kernel/")
    group(U, ["supervise_stage_v5.py", "prepare_actual_v4_check.py"], "sources/supervision/")
    group(HERE, ["prepare_secondary_bundle.py"], "sources/supervision/")
    group(ROOT / "work/n8_orchestration", ["ordinary_job_guard.py"], "sources/supervision/")
    for package in ("lean4export", "nanoda_lib"):
        rows.append({"source": str(S / "src" / package / "LICENSE"),
                     "destination": PREFIX + "licenses/" + package + ".txt", "required": True,
                     "liveUntilCompletion": False})
    group(N, ["Cargo.lock", "src/tc.rs", "src/parser.rs"], "upstream/nanoda_lib/")
    group(N / "test_resources/ProjFromProp", ["config.json", "export"], "tool-control/ProjFromProp/")
    group(B, ["TOOL_BUILD_RECORD.json", "SUMMARY.json", "BINARIES.sha256", "checkout-pre.json",
              "checkout-post.json", "environment.txt", "journal.jsonl", "build.log"], "tool-control/")
    control_names = ["accept_good", "reject_projfromprop", "missing_export", "invalid_config_json",
                     "wrong_format", "malformed_export", "missing_pp"]
    group(B / "selftest", [name + suffix for name in control_names
                            for suffix in (".out", ".err", ".result.json", ".runner.txt")], "tool-control/selftest/")
    group(B / "selftest", ["accept_good.json", "missing_export.json", "invalid_config.json", "wrong_format.json",
                            "malformed_export.json", "missing_pp.json", "forced_resource.json", "controls.json",
                            "nat_add_succ.ndjson", "wrong_format.ndjson", "malformed.ndjson",
                            "forced_resource.result.json", "export.err", "export.runner.txt", "export.stats.json"],
          "tool-control/selftest/")
    for cap in (16777216, 4194304, 1048576, 524288):
        group(B / "selftest", [f"forced_resource_{cap}bytes{suffix}" for suffix in
                                (".out", ".err", ".result.json", ".runner.txt", ".err.limit.json")], "tool-control/selftest/")
    group(E, ["RUN_MANIFEST.json", "nanoda.config.json", "export.stats.json", "OLEAN_SHA256.txt", "bind.json",
              "environment.txt", "journal.jsonl", "RESULT.json", "STATUS.tsv", "VERDICT", "VERDICT.json",
              "run.log", "export.err", "runner-export.txt", "tool-record-check.txt"], "export/")
    group(U, ["actual-v4-export-audit-20261006.json"], "export/")
    for label, base in (("export", OE), ("check", OC)):
        group(base, ["summary.json", "process/manifest.json", "process/result.json", "process/events.jsonl",
                     "process/stdout.log", "process/stderr.log"], "supervision/" + label + "/", live=label == "check")
    group(C, ["environment.txt", "nanoda.config.json", "nanoda.out", "nanoda.err", "runner-nanoda.txt",
              "OLEAN_SHA256.txt", "run.log", "STATUS.tsv", "VERDICT", "tool-record-check.txt"], "check/", live=True)
    group(C, ["journal.jsonl", "RESULT.json", "VERDICT.json", "nanoda.result.json", "bind-check.log",
              "integrity.log", "bind-check.txt", "integrity.txt"], "check/", required=False, live=True)
    group(C / "positive", ["export.err", "export.stats.json", "runner-export-positive.txt", "nanoda.config.json",
                            "nanoda-positive.out", "nanoda-positive.err", "nanoda-positive.result.json",
                            "runner-nanoda-positive.txt"], "check/positive/", required=False, live=True)
    group(C / "tamper", ["nanoda.config.json", "nanoda-tampered.out", "nanoda-tampered.err",
                          "nanoda-tampered.result.json", "runner-nanoda-tampered.txt", "mutation.json"],
          "check/tamper/", required=False, live=True)
    return rows


def completed():
    if not (OC / "summary.json").is_file() or not (OC / "process/result.json").is_file():
        return False
    summary, process = load(OC / "summary.json"), load(OC / "process/result.json")
    need(summary.get("stage") == "check", "Wrong completed supervision stage")
    need(process.get("cleanup_complete") is True and type(process.get("return_code")) is int,
         "Outer process completion/cleanup is not confirmed")
    check_binding(summary["process_result"])
    need(summary["process_result"]["path"] == str(OC / "process/result.json"), "Wrong process result binding")
    return True


def final_entries(audit_path=None, audit_sha=None):
    rows = fixed_entries()
    is_done = completed()
    if is_done:
        for label, base in (("export", OE), ("check", OC)):
            summary = load(base / "summary.json")
            for key in ("plan", "authorization"):
                check_binding(summary[key])
                rows.append({"source": summary[key]["path"], "destination": PREFIX + f"supervision/{label}/{key}.json",
                             "required": True, "liveUntilCompletion": False})
    if audit_path is not None:
        need(is_done, "Independent final audit cannot authorize a running stage")
        row = binding(audit_path)
        need(row["sha256"] == audit_sha, "Independent final audit digest differs")
        rows.append({"source": row["path"], "destination": PREFIX + "independent-check-audit.json",
                     "required": True, "liveUntilCompletion": False})
    return rows, is_done


def plan(audit_path=None, audit_sha=None):
    rows, is_done = final_entries(audit_path, audit_sha)
    found, missing, pending = [], [], []
    destinations = set()
    for row in rows:
        name = row["destination"]
        need(name.startswith(PREFIX) and ".." not in Path(name).parts and "\\" not in name,
             "Unsafe portable destination")
        need(name.casefold() not in destinations, "Duplicate portable destination")
        destinations.add(name.casefold())
        path = plain(row["source"])
        if row["liveUntilCompletion"] and not is_done:
            pending.append(dict(row, observedBytes=path.stat().st_size if path.is_file() else None))
        elif path.is_file():
            found.append(dict(row, **{k: v for k, v in binding(path).items() if k != "path"}))
        else:
            missing.append(row)
    need(all(not row["required"] for row in missing), "Required finalized bundle input missing: " +
         ", ".join(row["source"] for row in missing if row["required"]))
    ready = is_done and audit_path is not None and not pending
    return {"schema": "n9-small-secondary-evidence-plan-v1", "status": "READY_FOR_AUTHORIZED_WORK_STAGING" if ready else "PLAN_ONLY_NOT_READY",
            "mathematicalClassification": "NONE", "producerSha256": digest(__file__), "completedOuterStage": is_done,
            "independentAudit": binding(audit_path) if audit_path else None, "files": found,
            "missingOptionalFiles": missing, "pendingFilesNotHashed": pending,
            "bytes": sum(row["bytes"] for row in found), "omittedLargeArtifact": EXPORT,
            "liveDocsNotIncluded": "Root supplies finalized README/portable recipe separately after outcome audit",
            "metadataAllowlist": [row["destination"] for row in found] + [PREFIX + "BUNDLE_MANIFEST.json"]}


def stage(plan_path, auth_path):
    expected = load(plan_path)
    auth = load(auth_path)
    need(auth.get("root_authorized") is True and auth.get("final_status_independently_audited") is True
         and auth.get("exclusive_no_writers") is True, "Root/audit/exclusive authorization missing")
    need(auth.get("plan") == binding(plan_path) and auth.get("helperSha256") == digest(__file__), "Authorization binding differs")
    now = datetime.now(timezone.utc)
    start = datetime.fromisoformat(auth["issuedUtc"].replace("Z", "+00:00"))
    end = datetime.fromisoformat(auth["expiresUtc"].replace("Z", "+00:00"))
    need(start.tzinfo is not None and end.tzinfo is not None and start <= now < end
         and 0 < (end-start).total_seconds() <= 5400, "Expired/invalid authorization")
    need(auth.get("finalAudit") == expected["independentAudit"], "Independent audit is not authorized")
    audit = expected["independentAudit"]
    need(audit is not None, "No final independent audit")
    actual = plan(audit["path"], audit["sha256"])
    need(actual == expected and actual["status"] == "READY_FOR_AUTHORIZED_WORK_STAGING", "Stale or incomplete plan")
    max_bytes = auth.get("maxTotalBytes")
    need(type(max_bytes) is int and 0 < max_bytes <= 15 * 1024**2 and actual["bytes"] <= max_bytes, "Unapproved total evidence size")
    oversized = {row["destination"]: row["bytes"] for row in actual["files"] if row["bytes"] > 2 * 1024**2}
    need(auth.get("oversizedFiles", {}) == oversized, "Oversized members need exact explicit size approval")
    name = auth.get("stagingName")
    need(isinstance(name, str) and re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,79}", name), "Unsafe staging name")
    target = plain(STAGING / name)
    need(not target.exists(), "Never reuse or replace a staging directory")
    target.mkdir(parents=True, exist_ok=False)
    for row in actual["files"]:
        src, dst = plain(row["source"]), target / row["destination"]
        need(src.stat().st_size == row["bytes"] and digest(src) == row["sha256"], "Source changed before copy")
        dst.parent.mkdir(parents=True, exist_ok=True)
        with src.open("rb") as reader, dst.open("xb") as writer:
            shutil.copyfileobj(reader, writer, 1024 * 1024)
        need(dst.stat().st_size == row["bytes"] and digest(dst) == row["sha256"] and digest(src) == row["sha256"], "Copy/source hash mismatch")
    need(plan(audit["path"], audit["sha256"]) == expected, "Evidence changed during staging")
    manifest = dict(actual, status="WORK_STAGING_BYTES_VERIFIED_NOT_RELEASED", authorization=binding(auth_path),
                    approvedPlan=binding(plan_path), staging=str(target))
    need(actual["bytes"] + len(encoded(manifest)) <= max_bytes, "Evidence plus manifest exceeds approved total size")
    with (target / PREFIX / "BUNDLE_MANIFEST.json").open("xb") as stream:
        stream.write(encoded(manifest))
    print(json.dumps({"status": manifest["status"], "staging": str(target), "files": len(actual["files"]),
                      "bytes": actual["bytes"], "manifest": binding(target / PREFIX / "BUNDLE_MANIFEST.json")}, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=("plan", "stage"), default="plan")
    parser.add_argument("--audit", type=Path)
    parser.add_argument("--audit-sha256")
    parser.add_argument("--out", type=Path, help="Optional new work-only plan file; no evidence copied")
    parser.add_argument("--plan", type=Path)
    parser.add_argument("--authorization", type=Path)
    args = parser.parse_args()
    if args.mode == "stage":
        need(args.plan is not None and args.authorization is not None, "Explicit approved plan and authorization required")
        stage(args.plan, args.authorization)
        return
    need((args.audit is None) == (args.audit_sha256 is None), "Audit path and digest must be supplied together")
    result = plan(args.audit, args.audit_sha256)
    if args.out:
        out = plain(args.out)
        need(STAGING in out.parents and not out.exists(), "Plan output must be new and work-only")
        out.parent.mkdir(parents=True, exist_ok=True)
        with out.open("xb") as stream:
            stream.write(encoded(result))
        print(json.dumps({"status": result["status"], "plan": binding(out)}, indent=2))
    else:
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
