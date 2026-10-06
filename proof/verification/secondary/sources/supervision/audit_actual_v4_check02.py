"""Read-only audit of the completed actual N9 second-kernel run; no tool launches."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re

import supervise_stage_v5 as S


EXPECTED_OUTPUT = r"""
theorem ThomsonN9.thomson_nine_complete : ThomsonN9.Challenge.CompleteTarget := _
def ThomsonN9.Challenge.CompleteTarget : Prop :=
And ThomsonN9.Challenge.ParameterExistsUnique
(And ThomsonN9.Challenge.GlobalOptimality ThomsonN9.Challenge.GlobalUniqueness)
def ThomsonN9.Challenge.ParameterExistsUnique : Prop := ExistsUnique
(fun (r : Real) => And (LE.le (Rat.cast ThomsonN9.radiusLower) r)
(And (LE.le r (Rat.cast ThomsonN9.radiusUpper)) (Eq (ThomsonN9.stationarity r) (OfNat.ofNat 0))))
def ThomsonN9.Challenge.GlobalOptimality : Prop :=
forall (r : ThomsonN9.CandidateParameter) (x : ThomsonN9.Configuration),
ThomsonN9.IsSphereConfiguration x \u2192 LE.le (ThomsonN9.coulombEnergy (ThomsonN9.candidate r))
(ThomsonN9.coulombEnergy x)
def ThomsonN9.Challenge.GlobalUniqueness : Prop :=
forall (r : ThomsonN9.CandidateParameter) (x : ThomsonN9.Configuration),
ThomsonN9.IsSphereConfiguration x \u2192 Iff
(Eq (ThomsonN9.coulombEnergy x) (ThomsonN9.coulombEnergy (ThomsonN9.candidate r)))
(ThomsonN9.Congruent x (ThomsonN9.candidate r))
axiom propext {a b : Prop} : Iff a b \u2192 Eq a b
axiom Quot.sound.{u} {\u03b1 : Sort u} {r : \u03b1 \u2192 \u03b1 \u2192 Prop} {a b : \u03b1} :
r a b \u2192 Eq (Quot.mk r a) (Quot.mk r b)
axiom Classical.choice.{u} {\u03b1 : Sort u} : Nonempty \u03b1 \u2192 \u03b1
Checked 55248 declarations with no errors
""".encode("ascii").decode("unicode_escape")


def check_output(value):
    S.require(value.split() == EXPECTED_OUTPUT.split(), "Actual full output/type/axiom signatures differ")


def main():
    root = S.WORKSPACE
    outer = S.HERE / "runs/n9-complete-v4-20261006-check-02"
    export = S.SK / "runs/n9-complete-v4-20261006-export-01"
    run = export / "check-20261006-102019"
    snap = root / "work/clean-n9/20261006-adaptive-v4"
    summary = S.read_json(outer / "summary.json")
    plan_path = Path(summary["plan"]["path"])
    plan = S.read_json(plan_path)
    S.require(S.sha(plan_path) == "d79119e1be3d15bf3886712a9b5233bed567a4d7b5d9672f8dafbe8265be17b6", "Wrong retry plan")
    process = S.read_json(outer / "process/result.json")
    guard = S.read_json(outer / "process/manifest.json")
    for field in ("plan", "authorization", "process_result"):
        S.require(S.binding(summary[field]["path"]) == summary[field], f"Changed {field}")
    S.require(summary["stage"] == "check" and summary["stage_completion"] == "PROCESS_COMPLETED_ZERO_EXIT"
              and summary["process_outcome"] == "PROCESS_SUCCEEDED" and not summary["changed_prebound_inputs"], "Outer stage not complete")
    S.require(process["outcome"] == "PROCESS_SUCCEEDED" and process["return_code"] == 0
              and process["cleanup_complete"] is True and process["manifest_unchanged"] is True
              and process["changed_bindings"] == [], "Process/cleanup/input audit failed")
    S.require(process["manifest_sha256"] == S.sha(outer / "process/manifest.json"), "Guard manifest changed")
    S.verify_process_logs(outer / "process", process, summary["process_logs"])
    S.require(guard["argv"] == plan["argv"] and guard["cwd"] == plan["cwd"]
              and guard["limits"] == plan["limits"] and guard["stop_file"] == plan["stop_file"]
              and guard["test_assignment_failure"] is False and guard["test_resource_floor_after"] is None, "Guard scope differs")
    S.require(guard["environment_sha256"] == hashlib.sha256(json.dumps(plan["environment"], sort_keys=True).encode()).hexdigest(), "Guard environment differs")
    S.stage_environment("check", plan["environment"])
    S.validate_limits("check", plan["limits"])
    auth = S.read_json(summary["authorization"]["path"])
    started = datetime.fromisoformat(guard["started_utc"]).timestamp()
    deadline = S.authorization_deadline(auth, plan_path, plan, at_epoch=started)
    S.require(guard["deadline_epoch"] == deadline and started + process["wall_seconds"] < deadline, "Authorization deadline exceeded")
    S.require(process["job_configuration"] == {"flags": 8704, "private_cap": 8 * 1024**3}, "Wrong actual hard cap")
    for row in plan["copy_sources"] + plan["tools"] + plan["inputs"] + [plan["copy_audit"], plan["guard"], plan["wrapper"]]:
        S.require(S.binding(row["path"]) == row, f"Original planned bytes changed: {row['path']}")
    S.verify_prior_export(plan)
    sources = [{"path": row["path"], "sha256": row["sha256"]} for row in
               plan["copy_sources"] + [plan["wrapper"]] + plan["tools"] + plan["inputs"]]
    configs = [{"path": row["path"], "sha256": row["sha256"]} for row in
               [summary["plan"], summary["authorization"], plan["copy_audit"]]]
    S.require(guard["bindings"]["sources"] == sources and guard["bindings"]["configs"] == configs, "Observed guarded bindings differ")
    events = [json.loads(line) for line in (outer / "process/events.jsonl").read_text().splitlines()]
    S.require(events[-1]["pids"] == [] and events[-1]["return_code"] == 0, "Final owned-process sample not empty")
    peak = max(row.get("peak_job_commit", 0) for row in events)
    S.require(peak < 8 * 1024**3 and all(row.get("free_commit", 2 * 1024**3) >= 2 * 1024**3 for row in events), "Resource boundary crossed")

    manifest = S.read_json(export / "RUN_MANIFEST.json")
    config = S.read_json(run / "nanoda.config.json")
    S.require(config == manifest["nanoda_config"]["options"]
              and S.sha(run / "nanoda.config.json") == manifest["nanoda_config"]["sha256"], "Actual config differs from frozen export")
    S.require(config["permitted_axioms"] == ["propext", "Classical.choice", "Quot.sound"]
              and config["unpermitted_axiom_hard_error"] is True and "num_threads" not in config
              and config["unknown_pp_declar_hard_error"] is True, "Checker policy differs")
    expected_decls = ["ThomsonN9.thomson_nine_complete", "ThomsonN9.Challenge.CompleteTarget",
                      "ThomsonN9.Challenge.ParameterExistsUnique", "ThomsonN9.Challenge.GlobalOptimality",
                      "ThomsonN9.Challenge.GlobalUniqueness"]
    S.require(config["pp_declars"] == expected_decls, "Statement print scope differs")
    output = (run / "nanoda.out").read_text(encoding="utf-8")
    check_output(output)
    for old, new in [("Checked 55248", "Checked 55247"), ("Nonempty", "Inhabited"),
                     ("Iff a b", "And a b"), ("r a b", "True"),
                     ("And ThomsonN9.Challenge.ParameterExistsUnique", "And True"),
                     ("ThomsonN9.Congruent x (ThomsonN9.candidate r)", "True")]:
        try:
            check_output(output.replace(old, new, 1))
        except ValueError:
            pass
        else:
            raise ValueError("Output mutation was not rejected")
    S.require((run / "nanoda.err").stat().st_size == 0, "Actual checker stderr not empty")
    journal = [json.loads(line) for line in (run / "journal.jsonl").read_text().splitlines()]
    S.require(len(journal) == 1, "Unexpected checker invocations")
    child = journal[0]
    S.require(child["step"] == "nanoda" and child["invocation"] == "sk.1" and child["exit_code"] == 0
              and child["cwd"] == str(run) and child["env_LEAN_NUM_THREADS"] == "1", "Wrong actual child")
    expected_command = [plan["input_roles"]["python"], str(S.SK / "redirect.py"),
                        str(run / "nanoda.out"), str(run / "nanoda.err"),
                        plan["input_roles"]["nanoda"], str(run / "nanoda.config.json")]
    S.require(child["command"] == expected_command and child["job_assigned"] is True, "Wrong checker/config/redirect actual invocation")
    raw = S.read_json(run / "nanoda.result.json")
    S.require(raw["status"] == "ACCEPTED" and raw["cls"] == "accepted" and raw["exit_code"] == 0
              and raw["declarations"] == 55248 and raw["site"] is None
              and raw["invocation"] == child["invocation"], "Actual checker classification inconsistent")
    verdict = S.read_json(run / "VERDICT.json")
    checks = ["preflight", "export", "bind", "nanoda", "statement", "integrity"]
    S.require(verdict["verdict"] == "PASS" and verdict["aggregate"] == "PASS" and verdict["scope"] == "FINAL"
              and verdict["scope_reasons"] == [] and verdict["required_checks"] == checks
              and verdict["considered_checks"] == checks and set(verdict["checks"]) == set(checks)
              and all(verdict["checks"][key]["status"] == "PASS" for key in checks), "Incomplete aggregate")
    S.require(verdict["requested_optional_checks"] == []
              and verdict["subverdicts"] == {"source_provenance":"NOT-REQUESTED", "clean_build":"PASS",
                 "axioms":"NOT-REQUESTED", "statement_pins":"NOT-REQUESTED", "project_kernel_replay":"NOT-REQUESTED",
                 "full_env_replay":"NOT-REQUESTED"}, "Scope changed")
    S.require((run / "VERDICT").read_text() == "PASS\n", "Text verdict differs")
    observed = summary["pipeline"]["observations"]
    S.require(len(observed) == 1 and observed[0]["directory"] == str(run), "Wrong pipeline directory")
    for row in observed[0]["files"]:
        actual = S.binding(row["path"])
        S.require(all(actual[key] == row[key] for key in ("path", "sha256", "bytes")), "Outer-observed output changed")
    freeze = S.read_json(snap / "FREEZE.json")
    S.require(S.sha(snap / "FREEZE.json") == "22bb7406fef5a4379c856c8dbca26c8f964685e2bd036f24bdb45e0f5af3d10e", "Freeze differs")
    for row in freeze["files"]:
        path = snap / row["path"]
        S.require(path.stat().st_size == row["bytes"] and S.sha(path) == row["sha256"], "Frozen source changed")
    clean = S.read_json(plan["input_roles"]["clean_result"])
    S.require(clean["status"] == "PASS" and S.sha(plan["input_roles"]["clean_result"]) ==
              "1e10416d6f0e6abfd4c60dc12acf3fc8ba1d97c73c12d3078bcbe7076b25214f", "Clean build binding differs")
    S.require(not (S.COPY / ".lean_slot").exists(), "Owned pipeline slot not released")
    pipeline_files = [S.binding(path) for path in sorted(run.rglob("*")) if path.is_file()]
    statement_sources = [S.binding(snap / name) for name in
                         ("Challenge.lean", "ThomsonN9/Basic.lean", "ThomsonN9/Candidate.lean", "ThomsonN9/Completion.lean")]
    audit = {"status":"ACTUAL_SECOND_KERNEL_COMPLETE_CLOSURE_INDEPENDENT_AUDIT_PASS",
      "scope":"Existing completed run only; no checker/compiler launched by this audit",
      "summary":S.binding(outer / "summary.json"), "plan":summary["plan"], "authorization":summary["authorization"],
      "processResult":summary["process_result"], "guardManifest":S.binding(outer / "process/manifest.json"),
      "processLogs":summary["process_logs"], "pipelineFiles":pipeline_files,
      "cleanResult":S.binding(plan["input_roles"]["clean_result"]), "freeze":S.binding(snap / "FREEZE.json"),
      "actualCheckerExit":0, "declarations":55248, "rawOutput":S.binding(run / "nanoda.out"),
      "fullPrintedOutputMatchesExpectedTypesAndAxiomSignatures":True, "outputMutationControlsRejected":6,
      "requiredDeclarations":expected_decls, "axioms":["propext", "Quot.sound", "Classical.choice"],
      "axiomSignatures":"Propositional extensionality; quotient relation soundness; Nonempty Sort choice, exact raw signatures matched",
      "statementSources":statement_sources,
      "statementInterpretation":"CompleteTarget includes unique parameter existence and both global claims. Basic uses Fin9 in Euclidean R3, unit and injective points, i<j inverse Euclidean norm counted once, and a linear isometry equivalence with permutation. Candidate parameter is the stationarity root in the exact rational isolating interval, and candidate_admissible is proved in the frozen source.",
      "export":S.binding(export / "export.ndjson"), "exportManifest":S.binding(export / "RUN_MANIFEST.json"),
      "checkerConfig":S.binding(run / "nanoda.config.json"), "plannedInputRolesRehashed":len(plan["input_roles"]),
      "priorExportStrictValidator":"Unchanged supervise_stage_v5.verify_prior_export PASS",
      "frozenSourceFilesRehashed":len(freeze["files"]),
      "externalObjectScope":"Current inventory/provenance bytes are bound; this audit does not repeat the 71336-file external-cache hash walk. The actual pipeline's final integrity check passed, and the separate clean build audit remains bound.",
      "actualNanodaWallSeconds":child["wall_seconds"], "outerWallSeconds":process["wall_seconds"],
      "peakOuterJobCommitBytes":peak, "cleanupComplete":True, "finalObservedOwnedPids":[], "ownedSlotReleased":True,
      "historicalCheck01":"Preserved INCONCLUSIVE_TIMEOUT, never reinterpreted as success/rejection",
      "optionalSeparateReplayClaims":"None: no project/full-environment Lean replay or standalone pin rerun claimed here",
      "auditSource":S.binding(__file__), "auditedUtc":datetime.now(timezone.utc).isoformat()}
    out = S.HERE / "actual-v4-check02-independent-audit.json"
    with out.open("x", encoding="utf-8") as stream:
        json.dump(audit, stream, indent=2)
    print(json.dumps({"audit":S.binding(out), "status":audit["status"], "pipelineFiles":len(pipeline_files)}, indent=2))


if __name__ == "__main__":
    S.require(__debug__ and not S.os.environ.get("PYTHONOPTIMIZE"), "No optimized Python")
    main()
