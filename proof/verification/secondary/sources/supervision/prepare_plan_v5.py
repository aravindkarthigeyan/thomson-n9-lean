"""Prepare a source-bound stage plan, never an authorization and never a process launch."""
import argparse
import json
import os
from pathlib import Path

import supervise_stage_v5 as S


def prepare(stage, bash, report_id, wall_seconds, cap_gib, launch_commit_gib,
            snapshot=None, clean_run=None, run_id=None, prior_supervision=None):
    S.require(stage in S.STAGES, "Unknown stage")
    S.require(S.re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]{0,95}", report_id) is not None, "Unsafe report id")
    env = {k:os.environ[k] for k in ("SystemRoot","WINDIR","COMSPEC","TEMP","TMP","USERPROFILE",
                                  "HOMEDRIVE","HOMEPATH","PATHEXT") if k in os.environ}
    git_root = Path("C:/Program Files/Git")
    env.update(W=S.msys(S.WORKSPACE), PY=S.msys(S.EXPECTED_ROLES["python"]),
        PATH=";".join(str(p) for p in [git_root/"usr/bin",git_root/"mingw64/bin",
            Path(os.environ["SystemRoot"])/"System32",Path(os.environ["SystemRoot"]),
            S.EXPECTED_ROLES["lean"].parent,S.EXPECTED_ROLES["python"].parent]),
        HOME=S.msys(Path(os.environ["USERPROFILE"])), LANG="C", LC_ALL="C", RUST_BACKTRACE="0",
        SK_GO="1", LEAN_NUM_THREADS="1", NANODA_THREADS="1", MIN_FREE_GB="6.5",
        MIN_FREE_COMMIT_GB="11.75", SLOT_WAIT_MIN="0")
    roles = {name:str(path) for name,path in S.EXPECTED_ROLES.items()}
    script = S.SK/("build_second_kernel.sh" if stage == "selftest" else "run_second_kernel.sh")
    argv = [str(Path(bash).resolve(strict=True)),"--noprofile","--norc",str(script)]
    if stage == "selftest":
        env["ONLY"] = "selftest"
    else:
        S.require(snapshot and clean_run and run_id, "Final stage needs real snapshot, clean run, RUN_ID")
        snapshot, clean_run = Path(snapshot).resolve(strict=True),Path(clean_run).resolve(strict=True)
        roles.update(freeze=str(snapshot/"FREEZE.json"),clean_result=str(clean_run/"RESULT.json"),
            clean_objects=str(clean_run/"local-objects.json"),external_objects=str(clean_run/"external-objects-after.json"),
            tool_record=str(S.SK/"build/TOOL_BUILD_RECORD.json"))
        env.update(SK_STAGE=stage, SK_BIND="codex-clean", RUN_ID=run_id,
            SK_FREEZE_SHA256=S.sha(roles["freeze"]), SK_CLEAN_RESULT_SHA256=S.sha(roles["clean_result"]),
            SK_CODEX_SNAPSHOT=S.msys(snapshot), SK_CODEX_RUN=S.msys(clean_run), SK_TOOL_RECORD=S.msys(roles["tool_record"]))
        argv += ["--preset","final"]
    if stage == "check":
        S.require(prior_supervision, "Check needs prior export process summary")
        run = S.SK/"runs"/run_id
        roles.update(prior_run_manifest=str(run/"RUN_MANIFEST.json"), prior_export=str(run/"export.ndjson"),
            prior_verdict=str(run/"VERDICT.json"), prior_supervision=str(Path(prior_supervision).resolve(strict=True)))
        prior = S.read_json(prior_supervision)
        roles.update(prior_plan=prior["plan"]["path"],prior_process_result=prior["process_result"]["path"],
                     prior_authorization=prior["authorization"]["path"])
    audit_path = S.COPY/"PREPARATION_AUDIT_5.json"
    audit = S.read_json(audit_path)
    tools = [S.binding(argv[0])] + [S.binding(roles[k]) for k in ("lean","lake","python","lean4export","nanoda")]
    # These directly named shell dependencies are frozen too; Windows and Git runtime trust remains explicit.
    for path in [git_root/"mingw64/bin/git.exe",git_root/"usr/bin/cygpath.exe",git_root/"usr/bin/tee.exe",
                 git_root/"usr/bin/msys-2.0.dll"]:
        tools.append(S.binding(path))
    plan = {"schema":"n9-second-kernel-process-stage-v1", "mathematical_classification":"NONE",
        "stage":stage,"cwd":str(S.COPY),"argv":argv,"environment":env,
        "guard":S.binding(S.GUARD),"wrapper":S.binding(S.__file__),
        "copy_audit":S.binding(audit_path),
        "copy_sources":[S.binding(S.COPY/r["path"]) for r in S.audited_sources(audit)],
        "tools":tools,"inputs":[S.binding(path) for path in roles.values()],"input_roles":roles,
        "stop_file":str(S.SK/"STOP"),"report_dir":str(S.HERE/"runs"/report_id),
        "limits":{"launch_commit":int(launch_commit_gib*S.GIB),"launch_physical":13*S.GIB//2,
                  "reserve_commit":2*S.GIB,"private_tree_cap":int(cap_gib*S.GIB),"wall_seconds":wall_seconds}}
    S.validate_plan(plan)
    return plan


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage",required=True,choices=sorted(S.STAGES))
    parser.add_argument("--bash",default="C:/Program Files/Git/usr/bin/bash.exe")
    parser.add_argument("--report-id",required=True)
    parser.add_argument("--wall-seconds",required=True,type=int)
    parser.add_argument("--cap-gib",required=True,type=float)
    parser.add_argument("--launch-commit-gib",required=True,type=float)
    parser.add_argument("--snapshot")
    parser.add_argument("--clean-run")
    parser.add_argument("--run-id")
    parser.add_argument("--prior-supervision")
    parser.add_argument("--out",required=True)
    args = parser.parse_args()
    plan = prepare(args.stage,args.bash,args.report_id,args.wall_seconds,args.cap_gib,args.launch_commit_gib,
                   args.snapshot,args.clean_run,args.run_id,args.prior_supervision)
    out = S.plain_path(args.out)
    S.require(S.inside(out,S.HERE) and not out.exists(), "Plan must be a new work-only file")
    with out.open("x",encoding="utf-8") as stream:
        json.dump(plan,stream,indent=2)
    print(json.dumps({"plan":S.binding(out),"classification":"PREPARED_ONLY_NO_LAUNCH"}))
