"""Audit the closed 20-minute timeout and prepare a bounded 60-minute retry, never launch."""
from datetime import datetime, timezone
import json
from pathlib import Path

import prepare_plan_v5 as P
import supervise_stage_v5 as S


def main():
    old_report = S.HERE / "runs/n9-complete-v4-20261006-check-01"
    summary_path = old_report / "summary.json"
    summary = S.read_json(summary_path)
    S.require(summary["stage"] == "check" and summary["stage_completion"] == "INCONCLUSIVE"
              and summary["process_outcome"] == "INCONCLUSIVE_TIMEOUT" and summary["changed_prebound_inputs"] == [],
              "Prior stage is not the expected unchanged closed timeout")
    for row in [summary["plan"], summary["authorization"], summary["process_result"], *summary["process_logs"].values()]:
        S.check_binding(row)
    S.require(summary["process_result"]["sha256"] == "f809dcdd18b4b13fe41b337a481704b04a06d5fec075dacbade56d7a790fa66f",
              "Wrong timeout process report")
    process = S.read_json(summary["process_result"]["path"])
    S.require(process["outcome"] == "INCONCLUSIVE_TIMEOUT" and process["cleanup_complete"] is True
              and process["manifest_unchanged"] is True and process["changed_bindings"] == []
              and 1200 <= process["wall_seconds"] < 1202, "Prior process not the cleaned 1200-second timeout")
    manifest_path = old_report / "process/manifest.json"
    S.require(S.sha(manifest_path) == process["manifest_sha256"], "Prior guard manifest changed")
    manifest = S.read_json(manifest_path)
    old_plan = S.read_json(summary["plan"]["path"])
    S.require(summary["plan"]["sha256"] == "7d1b286b4bf325a1d9b35c0ff2afb5a773647c3688a9ca2f51248aa24e2db9e3",
              "Wrong original check plan")
    S.require(manifest["argv"] == old_plan["argv"] and manifest["limits"] == old_plan["limits"]
              and manifest["limits"]["wall_seconds"] == 1200
              and manifest["supervisor"]["sha256"] == S.GUARD_SHA, "Prior guard scope differs")
    for name, row in process["log_bindings"].items():
        S.require(row["path"] == str(old_report / "process" / name) and S.sha(row["path"]) == row["sha256"],
                  "Prior process log changed")
    observations = summary["pipeline"]["observations"]
    S.require(len(observations) == 1, "Unexpected interrupted pipeline directory count")
    failed_dir = S.plain_path(observations[0]["directory"])
    export_dir = S.SK / "runs/n9-complete-v4-20261006-export-01"
    S.require(failed_dir.parent == export_dir and failed_dir.name == "check-20261006-095413", "Wrong failed check directory")
    S.require((failed_dir / "nanoda.out").stat().st_size == 0 and (failed_dir / "nanoda.err").stat().st_size == 0,
              "Timeout gained a checker output/error; inspect it before retry")
    S.require((failed_dir / "VERDICT").read_text().strip() == "UNFINISHED", "Unexpected prior checker verdict")
    artifacts = [S.binding(summary_path), S.binding(Path(summary["plan"]["path"])),
                 S.binding(Path(summary["authorization"]["path"]))]
    for base in (old_report / "process", failed_dir):
        for path in sorted(base.rglob("*")):
            S.plain_path(path)
            if path.is_file():
                artifacts.append(S.binding(path))
    events = [json.loads(line) for line in (old_report / "process/events.jsonl").read_text().splitlines()]
    peak = max(row["peak_job_commit"] for row in events if "peak_job_commit" in row)
    slot = S.COPY / ".lean_slot/owner.txt"
    slot_record = None
    if slot.exists():
        S.plain_path(slot)
        raw = slot.read_bytes()
        S.require(raw.decode().strip() == "second_kernel run n9-complete-v4-20261006-export-01 pid 6873 since 2026-10-06T09:55:49-04:00",
                  "Unrecognized/live slot owner: do not remove or overwrite")
        slot_record = {"path": str(slot), "sha256": S.sha(slot), "bytesHex": raw.hex(),
                       "action": "No modification; root must separately preserve/clear the proven-stale owned lease before retry"}
    audit = {"status": "CLOSED_TIMEOUT_AUDITED_NOT_PROOF_REJECTION", "completedUtc": datetime.now(timezone.utc).isoformat(),
             "priorSummary": S.binding(summary_path), "cleanupComplete": True, "wallSeconds": process["wall_seconds"],
             "peakJobCommitBytes": peak, "rawCheckerStdoutBytes": 0, "rawCheckerStderrBytes": 0,
             "oldArtifacts": artifacts, "staleSlotAtPreparation": slot_record,
             "source": S.binding(__file__), "newProcessLaunched": False}
    audit_path = S.HERE / "actual-v4-check01-timeout-audit.json"
    S.require(not audit_path.exists(), "Timeout audit must be new")
    with audit_path.open("x", encoding="utf-8") as stream:
        json.dump(audit, stream, indent=2)
    plan = P.prepare("check", "C:/Program Files/Git/usr/bin/bash.exe",
        "n9-complete-v4-20261006-check-02", 3600, 8, 11.75,
        snapshot=S.WORKSPACE / "work/clean-n9/20261006-adaptive-v4",
        clean_run=S.WORKSPACE / "work/clean-n9/20261006-adaptive-v4/fresh-evidence/20261006T024511Z",
        run_id="n9-complete-v4-20261006-export-01",
        prior_supervision=S.HERE / "runs/n9-complete-v4-20261006-export-01/summary.json")
    old_inputs = {row["path"]: row for row in old_plan["inputs"]}
    carried = 0
    for role, path in old_plan["input_roles"].items():
        S.require(S.binding(path) == old_inputs[path], "Original check input changed")
        if role not in plan["input_roles"]:
            plan["input_roles"][role] = path
            plan["inputs"].append(old_inputs[path])
            carried += 1
        else:
            S.require(plan["input_roles"][role] == path, "Base input role changed")
    S.require(len(old_plan["input_roles"]) == 209 and carried == 187, "Unexpected original input-role coverage")
    additions = {"closed_check01_audit": S.binding(audit_path), "retry_plan_preparer": S.binding(__file__)}
    additions.update({f"closed_check01_artifact_{i:03d}": row for i, row in enumerate(artifacts)})
    for role, row in additions.items():
        S.check_binding(row)
        plan["input_roles"][role] = row["path"]
        if row["path"] not in {r["path"] for r in plan["inputs"]}:
            plan["inputs"].append(row)
    S.validate_plan(plan)
    out = S.HERE / "check-plan-v4-20261006-02.json"
    S.require(not out.exists(), "Retry plan must be new")
    with out.open("x", encoding="utf-8") as stream:
        json.dump(plan, stream, indent=2)
    print(json.dumps({"classification": "RETRY_PREPARED_NO_LAUNCH", "audit": S.binding(audit_path),
                      "plan": S.binding(out), "carriedOriginalRoles": len(old_plan["input_roles"]),
                      "closedArtifacts": len(artifacts), "staleSlotNeedsRootAction": slot_record is not None}))


if __name__ == "__main__":
    S.require(__debug__ and not S.sys.flags.optimize and not S.os.environ.get("PYTHONOPTIMIZE"), "No optimized Python")
    main()
