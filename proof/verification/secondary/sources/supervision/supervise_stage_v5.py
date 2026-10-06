"""Bound a separately authorized second-kernel stage; never certify a proof.

This wrapper neither generates authorization nor builds tools. The existing
pipeline remains responsible for semantic verdicts and dependency validation.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import re
import sys
import time
from types import SimpleNamespace


HERE = Path(__file__).resolve().parent
WORKSPACE = HERE.parent.parent
COPY = WORKSPACE / "work/n9-independent-verification"
SK = COPY / "tools/second_kernel"
GUARD = WORKSPACE / "work/n8_orchestration/ordinary_job_guard.py"
GUARD_SHA = "6def5e9bfd0209dcc7f02a8413b979b35fc32b2a266894625b31d2a5ff944b52"
AUDIT_SHA = "f3fa828ed7ec24411be8dfcf2f7c77d98e7a98d0594b3b56464181d00501fa77"
GIB = 1 << 30
STAGES = {"selftest", "export", "check"}
FORBIDDEN_ENV = {
    "BASH_ENV", "ENV", "SHELLOPTS", "BASHOPTS", "LD_PRELOAD", "LD_LIBRARY_PATH",
    "PYTHONPATH", "PYTHONHOME", "LEAN_PATH", "LEAN_SRC_PATH", "LEAN_OPTS",
    "LEAN_EXTRA_PATH", "LEAN_TC", "LEAN_EXE", "LEAN4EXPORT_EXE", "NANODA_EXE",
    "SK_BUILD_DIRS", "SK_MODULES", "SK_THEOREMS", "SK_EXPECT", "SK_PP",
    "SK_AXIOMS", "SK_REBUILD_RUN", "SK_KEEP_TAMPERED", "STEP_ENV",
}
CONTROL_ENV = {
    "SK_GO", "ONLY", "SK_BIND", "SK_STAGE", "RUN_ID", "SK_FREEZE_SHA256",
    "SK_CODEX_SNAPSHOT", "SK_CODEX_RUN", "SK_CLEAN_RESULT_SHA256", "SK_TOOL_RECORD",
    "LEAN_NUM_THREADS", "NANODA_THREADS", "MIN_FREE_GB", "MIN_FREE_COMMIT_GB",
    "SLOT_WAIT_MIN", "SK_MIN_FREE_DISK_GB", "SK_NANODA_STACK_BYTES",
}
BASE_ENV = {"W", "PY", "PATH", "SystemRoot", "WINDIR", "COMSPEC", "TEMP", "TMP", "HOME",
            "USERPROFILE", "HOMEDRIVE", "HOMEPATH", "PATHEXT", "LANG", "LC_ALL", "RUST_BACKTRACE"}
REQUIRED_SOURCES = [
    "tools/run_step.py", "tools/vf_common.py", "tools/vf_tool.py",
    "tools/resource_policy.py", "tools/FINAL_PINS.json",
    "tools/second_kernel/env.sh", "tools/second_kernel/sk_tool.py",
    "tools/second_kernel/redirect.py", "tools/second_kernel/build_second_kernel.sh",
    "tools/second_kernel/run_second_kernel.sh", "tools/second_kernel/nanoda_semantic_sites.json",
]
EXTERNAL_SK = WORKSPACE/"claude/verify_final/tools/second_kernel"
EXPECTED_ROLES = {
    "lean":WORKSPACE/"work/toolchains/lean-4.34.1-windows/bin/lean.exe",
    "lake":WORKSPACE/"work/toolchains/lean-4.34.1-windows/bin/lake.exe",
    "python":WORKSPACE/"work/venv/Scripts/python.exe",
    "lean4export":EXTERNAL_SK/"src/lean4export/.lake/build/bin/lean4export.exe",
    "nanoda":EXTERNAL_SK/"src/nanoda_lib/target/release/nanoda_bin.exe",
    "nanoda_lock":EXTERNAL_SK/"src/nanoda_lib/Cargo.lock",
    "nanoda_tc":EXTERNAL_SK/"src/nanoda_lib/src/tc.rs",
    "nanoda_parser":EXTERNAL_SK/"src/nanoda_lib/src/parser.rs",
    "projection_control":EXTERNAL_SK/"src/nanoda_lib/test_resources/ProjFromProp/config.json",
    "projection_export":EXTERNAL_SK/"src/nanoda_lib/test_resources/ProjFromProp/export",
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(path):
    with Path(path).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def plain_path(path):
    """Reject junction/symlink ancestors before canonicalizing an output path."""
    path = Path(os.path.abspath(path))
    for parent in (path, *path.parents):
        if parent.exists() or parent.is_symlink():
            require(not (parent.lstat().st_file_attributes & 0x400),
                    f"Reparse path is not allowed: {parent}")
    return path


def binding(path):
    path = plain_path(path).resolve(strict=True)
    return {"path": str(path), "sha256": sha(path), "bytes": path.stat().st_size}


def check_binding(record):
    require(set(record) == {"path", "sha256", "bytes"}, "Invalid file binding schema")
    require(type(record["bytes"]) is int and record["bytes"] >= 0, "Invalid byte count")
    require(re.fullmatch("[0-9a-f]{64}", record["sha256"]) is not None, "Invalid SHA256")
    require(binding(record["path"]) == record, f"Changed file: {record['path']}")


def inside(path, root):
    return path == root or root in path.parents


def read_json(path):
    def pairs(items):
        result = {}
        for key,value in items:
            require(key not in result, "Duplicate JSON key")
            result[key] = value
        return result
    def invalid(value):
        raise ValueError(f"Non-finite JSON constant {value}")
    return json.loads(Path(path).read_text(encoding="utf-8-sig"),object_pairs_hook=pairs,parse_constant=invalid)


def canonical_hash(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def msys(path):
    path = Path(path)
    require(bool(path.drive), "Expected absolute Windows path")
    return "/"+path.drive[0].lower()+path.as_posix()[2:]


def audited_sources(audit):
    rows = [{"path":r["path"], "sha256":r["copiedSha256"]} for r in audit["sourceFiles"]]
    rows += [{"path":r["path"], "sha256":r["sha256"]} for r in audit["newAuthoredFiles"]]
    require(len({r["path"].casefold() for r in rows}) == len(rows), "Duplicate audited source path")
    return rows


def stage_environment(stage, env):
    require(stage in STAGES, "Only separately authorized selftest/export/check stages exist")
    require(type(env) is dict and all(type(k) is str and type(v) is str for k,v in env.items()),
            "Environment must be an explicit string map")
    require(all(k and "=" not in k and "\0" not in k+v for k,v in env.items()), "Invalid environment")
    require(not (FORBIDDEN_ENV & set(env)), "Unsafe environment override")
    require(set(env) <= CONTROL_ENV | BASE_ENV, "Unreviewed environment variable")
    require(not [k for k in env if k.startswith("SK_") and k not in CONTROL_ENV], "Unknown SK override")
    expected = {"SK_GO":"1", "LEAN_NUM_THREADS":"1", "NANODA_THREADS":"1",
                "MIN_FREE_GB":"6.5", "MIN_FREE_COMMIT_GB":"11.75", "SLOT_WAIT_MIN":"0"}
    if stage == "selftest":
        expected["ONLY"] = "selftest"
        require(not ({"SK_STAGE", "SK_BIND", "RUN_ID", "SK_CODEX_RUN", "SK_CODEX_SNAPSHOT",
                      "SK_CLEAN_RESULT_SHA256", "SK_FREEZE_SHA256", "SK_TOOL_RECORD"} & set(env)),
                "Selftest cannot inherit final-run or reuse settings")
    else:
        expected.update(SK_STAGE=stage, SK_BIND="codex-clean")
        require("ONLY" not in env, "Final stage cannot inherit tool-build scope")
        require(re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,95}", env.get("RUN_ID", "")) is not None,
                "An explicit safe RUN_ID is required")
        for key in ("SK_FREEZE_SHA256", "SK_CLEAN_RESULT_SHA256"):
            require(re.fullmatch("[0-9a-f]{64}", env.get(key, "")) is not None, f"Missing {key}")
        for key in ("SK_CODEX_SNAPSHOT", "SK_CODEX_RUN", "SK_TOOL_RECORD"):
            require(bool(env.get(key)), f"Missing {key}")
    for key,value in expected.items():
        require(env.get(key) == value, f"Wrong {key}: expected {value}")
    for key in ("HEAVY_MIN_FREE_GB", "FRESH_MIN_FREE_GB", "PIN_MIN_FREE_GB",
                "ASSEMBLY_MIN_FREE_COMMIT_GB", "HEAVY_MIN_FREE_COMMIT_GB", "STEP_COMMIT"):
        require(key not in env, f"Unnecessary resource override: {key}")
    require(env.get("RUST_BACKTRACE", "0") == "0", "Panic output must retain reviewed format")
    require(env.get("W") == msys(WORKSPACE), "Workspace override differs from fixed workspace")
    require(env.get("PY") == msys(WORKSPACE/"work/venv/Scripts/python.exe"), "Python override differs")
    require("PKG_CACHE" not in env and "SK_TOOL_OVERRIDES" not in env, "Do not override package/tool resolution")


def validate_limits(stage, limits):
    require(set(limits) == {"launch_commit", "launch_physical", "reserve_commit", "private_tree_cap",
                            "wall_seconds"}, "Exact resource policy fields required")
    for key in ("launch_commit", "launch_physical", "reserve_commit", "private_tree_cap"):
        require(type(limits[key]) is int and limits[key] > 0, f"Invalid {key}")
    require(type(limits["wall_seconds"]) in (int,float) and math.isfinite(limits["wall_seconds"])
            and 0 < limits["wall_seconds"] <= 3600, "Stage wall cap must be at most one hour")
    require(limits["launch_commit"] >= 47*GIB//4 and limits["launch_physical"] >= 13*GIB//2,
            "Production prelaunch floors are 11.75/6.5 GiB")
    require(limits["reserve_commit"] >= 2*GIB, "Keep at least 2 GiB commit reserve")
    require(limits["private_tree_cap"] + limits["reserve_commit"] <= limits["launch_commit"],
            "Job hard cap plus reserve must fit within launch gate")
    if stage == "selftest":
        require(limits["private_tree_cap"] == 8*GIB, "Selftest cap is exactly 8 GiB")


def validate_plan(plan, *, existing_export=False):
    require(plan.get("schema") == "n9-second-kernel-process-stage-v1", "Wrong plan schema")
    require(plan.get("mathematical_classification") == "NONE", "Supervisor cannot certify mathematics")
    stage = plan["stage"]
    require(type(existing_export) is bool and (not existing_export or stage == "export"), "Invalid historical-plan mode")
    stage_environment(stage, plan["environment"])
    validate_limits(stage, plan["limits"])
    require(plan["cwd"] == str(COPY), "Working directory must be the reviewed copy")
    require(plan["stop_file"] == str(SK/"STOP"), "Use the active stop file shared by inner pipeline")
    require(not plain_path(plan["stop_file"]).exists(), "STOP file is active; never remove it automatically")
    report = plain_path(plan["report_dir"])
    require(inside(report, HERE/"runs") and report != HERE/"runs", "Reports belong in owned runs directory")
    require(existing_export or not report.exists(), "Stage reports must be fresh")
    require(plan["guard"] == binding(GUARD) and plan["guard"]["sha256"] == GUARD_SHA, "Guard pin mismatch")
    require(plan["wrapper"] == binding(__file__), "Wrapper source changed")
    require(plan["copy_audit"]["path"] == str(COPY/"PREPARATION_AUDIT_5.json")
            and plan["copy_audit"]["sha256"] == AUDIT_SHA, "Reviewed preparation revision5 required")
    for record in plan["tools"] + plan["inputs"] + [plan["copy_audit"]]:
        check_binding(record)
    require(len({r["path"] for r in plan["tools"]}) == len(plan["tools"]), "Duplicate tool binding")
    bash = plan["tools"][0]
    require(Path(bash["path"]).name.lower() == "bash.exe", "Production root must be the bound Bash executable")
    script = SK/("build_second_kernel.sh" if stage == "selftest" else "run_second_kernel.sh")
    expected = [bash["path"], "--noprofile", "--norc", str(script)]
    if stage != "selftest":
        expected += ["--preset", "final"]
    require(plan["argv"] == expected, "Exact reviewed stage argv required")
    audit = read_json(plan["copy_audit"]["path"])
    require(audit["originalSourcesUnchanged"] is True and audit["realVerificationPerformed"] is False,
            "Expected the source-only preparation audit")
    source_records = []
    audited = audited_sources(audit)
    for source in audited:
        path = plain_path(COPY/source["path"])
        require(inside(path, COPY), "Copy source path escapes copy")
        actual = binding(path)
        require(actual["sha256"] == source["sha256"], f"Changed copied source {path}")
        source_records.append(actual)
    require(set(REQUIRED_SOURCES) <= {r["path"] for r in audited}, "Incomplete copy audit")
    require(plan["copy_sources"] == source_records, "Plan does not bind complete copied source inventory")
    by_role = plan["input_roles"]
    input_map = {r["path"]:r for r in plan["inputs"]}
    require(all(path in input_map for path in by_role.values()), "Role references unbound input")
    require(set(EXPECTED_ROLES) <= set(by_role), "Missing direct tool/source inputs")
    for role,path in EXPECTED_ROLES.items():
        require(by_role[role] == str(path), f"Bound role does not match actual pipeline path: {role}")
    for key in ("lean", "lake", "python", "lean4export", "nanoda"):
        require(by_role[key] in {r["path"] for r in plan["tools"]}, f"Tool {key} not bound as executable")
    pins = read_json(COPY/"tools/FINAL_PINS.json")
    require(input_map[by_role["lean"]]["sha256"] == pins["tool_sha256"]["lean.exe"], "Lean pin mismatch")
    for role,pin in (("lean4export", "lean4export_sha256"), ("nanoda", "nanoda_sha256")):
        require(input_map[by_role[role]]["sha256"] == pins["second_kernel"][pin], f"Wrong pinned {role}")
    if stage != "selftest":
        require({"freeze", "clean_result", "clean_objects", "external_objects", "tool_record"} <= set(by_role),
                "Final export/check requires actual clean-result and object bindings")
        require(input_map[by_role["freeze"]]["sha256"] == plan["environment"]["SK_FREEZE_SHA256"], "Freeze mismatch")
        require(input_map[by_role["clean_result"]]["sha256"] == plan["environment"]["SK_CLEAN_RESULT_SHA256"],
                "Clean result hash mismatch")
        require(plan["environment"]["SK_CODEX_SNAPSHOT"] == msys(Path(by_role["freeze"]).parent)
                and plan["environment"]["SK_CODEX_RUN"] == msys(Path(by_role["clean_result"]).parent)
                and plan["environment"]["SK_TOOL_RECORD"] == msys(by_role["tool_record"]),
                "Final pipeline paths do not match bound inputs")
        clean = read_json(by_role["clean_result"])
        require(clean.get("status") == "PASS" and clean.get("manifestSha256") == plan["environment"]["SK_FREEZE_SHA256"],
                "A real successful clean RESULT must exist; placeholder or incomplete result refused")
        require(read_json(by_role["tool_record"]).get("status") == "PASS", "Successful selftest tool record required")
        for role,name in (("clean_objects","local-objects.json"),("external_objects","external-objects-after.json")):
            require(by_role[role] == str(Path(by_role["clean_result"]).parent/name), "Wrong clean inventory path")
        run = plain_path(SK/"runs"/plan["environment"]["RUN_ID"])
        require(existing_export or stage == "check" or not run.exists(), "Export run directory must be new")
    if stage == "check":
        require({"prior_run_manifest", "prior_export", "prior_verdict", "prior_supervision", "prior_plan", "prior_process_result", "prior_authorization"} <= set(by_role),
                "Check requires a separately bound completed export and supervision receipt")
        require(by_role["prior_run_manifest"] == str(run/"RUN_MANIFEST.json")
                and by_role["prior_export"] == str(run/"export.ndjson")
                and by_role["prior_verdict"] == str(run/"VERDICT.json"), "Wrong prior export paths")
        verify_prior_export(plan)
    return source_records


def pipeline_before(plan):
    stage = plan["stage"]
    if stage == "selftest":
        root = plain_path(SK/"build/runs")
    else:
        root = plain_path(SK/"runs"/plan["environment"]["RUN_ID"])
    before = set(p.name for p in root.iterdir()) if root.is_dir() else set()
    return root, before


def pipeline_observation(plan, root, before):
    """Retain raw, hash-bound verdict files without assigning semantic meaning."""
    if plan["stage"] == "export":
        directories = [root] if root.is_dir() else []
    else:
        directories = [plain_path(p) for p in root.iterdir() if p.name not in before and p.is_dir()] \
            if root.is_dir() else []
    observations = []
    for directory in directories:
        files = []
        for name in ("VERDICT", "VERDICT.json", "RESULT.json", "TOOL_BUILD_RECORD.json", "SUMMARY.json", "STATUS.tsv"):
            path = plain_path(directory/name)
            if path.is_file():
                record = binding(path)
                require(record["bytes"] <= 2 << 20, "Unexpectedly large verdict metadata")
                record["text"] = path.read_text(encoding="utf-8", errors="replace")
                files.append(record)
        observations.append({"directory":str(directory), "files":files})
    return {"classification":"UNINTERPRETED_PIPELINE_OUTPUT", "new_directory_count":len(directories),
            "observations":observations}


def clean_stage_exit(stage, result):
    expected = 4 if stage == "export" else 0
    outcome = "INCONCLUSIVE_PROCESS_FAILURE" if expected else "PROCESS_SUCCEEDED"
    return (type(result.get("return_code")) is int and result.get("return_code") == expected and result.get("outcome") == outcome
        and result.get("resumed") is True and result.get("cleanup_complete") is True
        and result.get("manifest_unchanged") is True and result.get("changed_bindings") == [])


def check_export_verdict(plan, verdict):
    require(verdict.get("scope") == "EXPORT-ONLY" and verdict.get("aggregate") == "PASS"
            and verdict.get("verdict") == "EXPORT-ONLY:PASS" and verdict.get("stage") == "export"
            and verdict.get("run_id") == plan["environment"]["RUN_ID"], "Exit4 lacks this run's successful EXPORT-ONLY receipt")
    require(set(verdict.get("required_checks",[])) == {"preflight","export","bind"}
            and all(verdict.get("checks",{}).get(k,{}).get("status") == "PASS"
                    for k in ("preflight","export","bind")), "Export required checks are not all successful")


def export_artifacts(plan, root, result, changed):
    require(not changed and clean_stage_exit("export",result), "Export did not complete with its exact normal exit4")
    require(root == SK/"runs"/plan["environment"]["RUN_ID"], "Wrong export output path")
    names = ("RUN_MANIFEST.json","export.ndjson","VERDICT.json","RESULT.json")
    records = {name:binding(root/name) for name in names}
    verdict = read_json(root/"VERDICT.json")
    check_export_verdict(plan,verdict)
    require(records["export.ndjson"]["bytes"] > 0, "Empty export")
    return records


def verify_prior_export(plan):
    roles = plan["input_roles"]
    prior = read_json(roles["prior_supervision"])
    require(prior.get("stage") == "export" and prior.get("stage_completion") == "EXPORT_ONLY_COMPLETED",
            "Prior receipt is not a completed export-only stage")
    for name in ("plan","process_result","authorization"):
        check_binding(prior[name])
    require(prior["plan"]["path"] == roles["prior_plan"]
            and prior["process_result"]["path"] == roles["prior_process_result"]
            and prior["authorization"]["path"] == roles["prior_authorization"], "Prior receipt input paths differ")
    old_plan = read_json(roles["prior_plan"])
    validate_plan(old_plan,existing_export=True)
    require(roles["prior_supervision"] == str(Path(old_plan["report_dir"])/"summary.json")
            and roles["prior_process_result"] == str(Path(old_plan["report_dir"])/"process/result.json"),
            "Prior receipt is not in its bound report directory")
    require(old_plan["stage"] == "export" and old_plan["environment"]["RUN_ID"] == plan["environment"]["RUN_ID"],
            "Prior export plan RUN_ID mismatch")
    for key in ("SK_FREEZE_SHA256","SK_CLEAN_RESULT_SHA256","SK_CODEX_SNAPSHOT","SK_CODEX_RUN","SK_TOOL_RECORD"):
        require(old_plan["environment"][key] == plan["environment"][key], f"Prior export context differs: {key}")
    process = read_json(roles["prior_process_result"])
    require(clean_stage_exit("export",process) and prior.get("changed_prebound_inputs") == [], "Prior process not clean")
    manifest_path = Path(roles["prior_process_result"]).parent/"manifest.json"
    require(sha(manifest_path) == process["manifest_sha256"], "Prior process manifest changed")
    manifest = read_json(manifest_path)
    require(manifest["argv"] == old_plan["argv"] and manifest["supervisor"]["sha256"] == GUARD_SHA,
            "Prior manifest command or supervisor differs")
    require(manifest["cwd"] == old_plan["cwd"] and manifest["environment_sha256"] ==
            hashlib.sha256(json.dumps(old_plan["environment"],sort_keys=True).encode()).hexdigest(),
            "Prior process environment or cwd differs")
    require(manifest["stop_file"] == old_plan["stop_file"] and manifest.get("test_assignment_failure") is False
            and manifest.get("test_resource_floor_after") is None, "Prior history has wrong STOP or test hooks")
    manifest_sources = {r["path"]:r["sha256"] for r in manifest["bindings"]["sources"]}
    require(all(manifest_sources.get(r["path"]) == r["sha256"]
                for r in old_plan["copy_sources"]+old_plan["tools"]+old_plan["inputs"]+[old_plan["wrapper"]]),
            "Prior guard did not bind the full stage source/tool/input set")
    check_binding(old_plan["wrapper"])
    for key in ("plan","authorization"):
        require(any(r["path"] == prior[key]["path"] and r["sha256"] == prior[key]["sha256"]
                    for r in manifest["bindings"]["configs"]), f"Prior guard did not bind its {key}")
    auth = read_json(roles["prior_authorization"])
    started = datetime.fromisoformat(manifest["started_utc"]).timestamp()
    deadline = authorization_deadline(auth,roles["prior_plan"],old_plan,at_epoch=started)
    require(manifest["deadline_epoch"] == deadline, "Prior guard deadline differs from authorization")
    require(all(manifest["limits"][k] == v for k,v in old_plan["limits"].items() if k != "wall_seconds")
            and 0 < manifest["limits"]["wall_seconds"] <= old_plan["limits"]["wall_seconds"],
            "Prior guard resource limits differ")
    verify_process_logs(Path(roles["prior_process_result"]).parent,process,prior["process_logs"])
    root = SK/"runs"/plan["environment"]["RUN_ID"]
    artifacts = export_artifacts(old_plan,root,process,[])
    require(prior.get("export_artifacts") == artifacts, "Export bytes/manifest/verdict/result differ from prior receipt")
    for name,role in (("RUN_MANIFEST.json","prior_run_manifest"),("export.ndjson","prior_export"),("VERDICT.json","prior_verdict")):
        require(artifacts[name] == next(r for r in plan["inputs"] if r["path"] == roles[role]), "New plan export binding differs")


def verify_process_logs(directory, process, sized_logs):
    names = {"stdout.log","stderr.log","events.jsonl"}
    require(set(process["log_bindings"]) == names and set(sized_logs) == names, "Incomplete prior log inventory")
    for name in names:
        record, full = process["log_bindings"][name], sized_logs[name]
        require(set(record) == {"path","sha256"} and record["path"] == str(directory/name), "Wrong guard log path/schema")
        check_binding(full)
        require(full["path"] == record["path"] and full["sha256"] == record["sha256"], "Prior process log differs")


def authorization_deadline(auth, plan_path, plan, *, at_epoch=None):
    require(auth.get("schema") == "n9-second-kernel-process-authorization-v1", "Wrong authorization schema")
    for key in ("root_authorized", "user_continuation_authorized", "exclusive_slot_released"):
        require(auth.get(key) is True, f"Explicit fresh {key}=true is required")
    require(auth.get("continuation_evidence") == "[Private continuation message redacted]"
            and auth.get("claude_stop_handoff") == "2026-10-05 21:39 EDT",
            "Record the actual user continuation and stopped-Claude handoff; do not fabricate new Claude approval")
    require(auth["stage"] == plan["stage"] and auth["plan"] == binding(plan_path), "Authorization plan mismatch")
    require(auth["environment_sha256"] == canonical_hash(plan["environment"]), "Authorization environment mismatch")
    require(auth["argv"] == plan["argv"] and auth["limits"] == plan["limits"], "Authorization scope mismatch")
    start = datetime.fromisoformat(auth["issued_utc"].replace("Z", "+00:00"))
    end = datetime.fromisoformat(auth["expires_utc"].replace("Z", "+00:00"))
    require(start.utcoffset() is not None and end.utcoffset() is not None, "Explicit UTC offsets required")
    now = time.time() if at_epoch is None else at_epoch
    require(start.timestamp() <= now < end.timestamp(), "Authorization is not currently active")
    require(0 < (end-start).total_seconds() <= 5400, "Authorization lifetime is at most 90 minutes")
    return end.timestamp()


def execute(plan_path, auth_path):
    plan, auth = read_json(plan_path), read_json(auth_path)
    sources = validate_plan(plan)
    deadline = authorization_deadline(auth, plan_path, plan)
    # A stale inherited override is an error, not a silent change of requested scope.
    for key in CONTROL_ENV | FORBIDDEN_ENV:
        if key in os.environ:
            require(os.environ[key] == plan["environment"].get(key), f"Inherited override conflicts: {key}")
    spec = importlib.util.spec_from_file_location("n9_exact_owned_guard", GUARD)
    guard = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(guard)
    report = plain_path(plan["report_dir"])
    report.parent.mkdir(parents=False, exist_ok=True)
    report.mkdir(exist_ok=False)
    effective = dict(plan["limits"])
    effective["wall_seconds"] = min(effective["wall_seconds"], deadline-time.time())
    require(effective["wall_seconds"] > 0, "Authorization expired before launch")
    original_config = [binding(plan_path), binding(auth_path), plan["copy_audit"]]
    pipeline_root, before = pipeline_before(plan)
    result = guard.supervise(plan["argv"], cwd=plan["cwd"], report_dir=report/"process",
        limits=SimpleNamespace(**effective),
        sources=[r["path"] for r in sources]+[__file__]+[r["path"] for r in plan["tools"]+plan["inputs"]],
        configs=[r["path"] for r in original_config], stop_file=plan["stop_file"],
        environment=plan["environment"], deadline_epoch=deadline)
    all_bound = sources+plan["tools"]+plan["inputs"]+original_config+[plan["wrapper"],plan["guard"]]
    changed = []
    for expected in all_bound:
        try:
            if binding(expected["path"]) != expected:
                changed.append(expected["path"])
        except (OSError,ValueError):
            changed.append(expected["path"])
    outcome = "INCONCLUSIVE_PREBOUND_INPUT_CHANGED" if changed else result["outcome"]
    try:
        pipeline = pipeline_observation(plan, pipeline_root, before)
    except (ValueError, OSError) as error:
        pipeline = {"classification":"UNAVAILABLE", "error":str(error)}
        outcome = "INCONCLUSIVE_PIPELINE_OBSERVATION"
    stage_completion = "INCONCLUSIVE"
    export_receipt = None
    process_logs = {}
    try:
        process_logs = {name:binding(report/"process"/name) for name in ("stdout.log","stderr.log","events.jsonl")
                        if (report/"process"/name).is_file()}
        if clean_stage_exit(plan["stage"],result):
            verify_process_logs(report/"process",result,process_logs)
    except (ValueError,OSError,KeyError,TypeError):
        outcome = "INCONCLUSIVE_PROCESS_LOG_BINDING"
    if not changed and outcome == result["outcome"]:
        if plan["stage"] == "export":
            try:
                export_receipt = export_artifacts(plan,pipeline_root,result,changed)
                stage_completion = "EXPORT_ONLY_COMPLETED"
            except (ValueError,OSError,KeyError,TypeError):
                pass
        elif clean_stage_exit(plan["stage"],result):
            stage_completion = "PROCESS_COMPLETED_ZERO_EXIT"
    summary = {"schema":"n9-second-kernel-process-summary-v1", "stage":plan["stage"],
        "process_outcome":outcome, "mathematical_classification":"NONE", "changed_prebound_inputs":changed,
        "stage_completion":stage_completion, "export_artifacts":export_receipt,
        "plan":original_config[0], "authorization":original_config[1],
        "process_result":binding(report/"process/result.json"),
        "process_logs":process_logs,
        "pipeline":pipeline,
        "artifact_paths_are_pipeline_owned":True}
    with (report/"summary.json").open("x", encoding="utf-8") as stream:
        json.dump(summary, stream, indent=2)
    print(json.dumps(summary, indent=2))
    return 0 if stage_completion != "INCONCLUSIVE" else 2


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--plan", required=True)
    parser.add_argument("--authorization", required=True)
    args = parser.parse_args()
    try:
        sys.exit(execute(args.plan, args.authorization))
    except (ValueError, OSError, KeyError, TypeError) as error:
        print(f"REFUSED_OR_INCONCLUSIVE: {error}", file=sys.stderr)
        sys.exit(2)
