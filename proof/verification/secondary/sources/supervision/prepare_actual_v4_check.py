"""Audit the real export and prepare a bound check-only plan; never launch nanoda."""
import hashlib
import json
from pathlib import Path

import prepare_plan_v5 as P
import supervise_stage_v5 as S


def main():
    root = S.WORKSPACE
    old_plan_path = S.HERE / "export-plan-v4-20261006-01.json"
    old_plan = S.read_json(old_plan_path)
    S.require(S.sha(old_plan_path) == "d88103ee3aeb675031b2a95bf85dbf6747d82abc71a768ebd3e49c5fdcbda8dd", "Export plan changed")
    summary_path = S.HERE / "runs/n9-complete-v4-20261006-export-01/summary.json"
    summary = S.read_json(summary_path)
    plan = P.prepare("check", "C:/Program Files/Git/usr/bin/bash.exe",
        "n9-complete-v4-20261006-check-01", 1200, 8, 11.75,
        snapshot=root / "work/clean-n9/20261006-adaptive-v4",
        clean_run=root / "work/clean-n9/20261006-adaptive-v4/fresh-evidence/20261006T024511Z",
        run_id="n9-complete-v4-20261006-export-01", prior_supervision=summary_path)
    export = Path(summary["export_artifacts"]["export.ndjson"]["path"])
    directory = export.parent
    manifest = S.read_json(directory / "RUN_MANIFEST.json")
    config = S.read_json(directory / "nanoda.config.json")
    stats = S.read_json(directory / "export.stats.json")
    S.require(config == manifest["nanoda_config"]["options"] and S.sha(directory / "nanoda.config.json") ==
              manifest["nanoda_config"]["sha256"], "Actual checker configuration differs from manifest")
    S.require(set(config["permitted_axioms"]) == {"propext", "Classical.choice", "Quot.sound"}
              and len(config["permitted_axioms"]) == 3 and config["unpermitted_axiom_hard_error"] is True
              and "num_threads" not in config, "Axiom/thread policy changed")
    needed = set(manifest["pp_declars"])
    S.require(manifest["modules"] == ["Solution"] and manifest["theorems"] == ["ThomsonN9.thomson_nine_complete"],
              "Wrong export scope")
    names, counts, declared, axiom_names = {0: ""}, {}, {}, []
    target_types = set()
    complete_type = None
    line_count = meta_count = 0
    digest = hashlib.sha256()
    total_bytes = 0
    with export.open("rb") as stream:
        for line_count, raw in enumerate(stream, 1):
            digest.update(raw)
            total_bytes += len(raw)
            item = json.loads(raw)
            S.require(isinstance(item, dict), f"Nonobject NDJSON line {line_count}")
            if "meta" in item:
                meta_count += 1
                S.require(line_count == 1 and item["meta"] == {
                    "exporter": {"name": "lean4export", "version": "3.1.0"},
                    "format": {"version": "3.1.0"},
                    "lean": {"githash": "5045d0056413266e57c625dcd7c365b10e377c52", "version": "4.34.1"}},
                    "Wrong/repeated exporter metadata")
            if "in" in item:
                i = item["in"]
                S.require(i not in names, "Duplicate name index")
                part = item.get("str", item.get("num"))
                prefix = names[part["pre"]]
                value = str(part.get("str", part.get("i")))
                names[i] = prefix + ("." if prefix else "") + value
            if "const" in item and names[item["const"]["name"]] == "ThomsonN9.Challenge.CompleteTarget":
                target_types.add(item["ie"])
            for kind in ("axiom", "thm", "def", "opaque", "quot"):
                if kind in item:
                    declaration = item[kind]
                    counts[kind] = counts.get(kind, 0) + 1
                    name = names[declaration["name"]]
                    if name in needed:
                        S.require(name not in declared, "Duplicate required declaration")
                        declared[name] = kind
                    if kind == "axiom":
                        axiom_names.append(name)
                    if name == "ThomsonN9.thomson_nine_complete":
                        S.require(kind == "thm", "Complete result is not a theorem declaration")
                        complete_type = declaration["type"]
            if "inductive" in item:
                for part in ("types", "ctors", "recs"):
                    for declaration in item["inductive"].get(part, []):
                        counts["inductive_items"] = counts.get("inductive_items", 0) + 1
                        name = names[declaration["name"]]
                        if name in needed:
                            S.require(name not in declared, "Duplicate required declaration")
                            declared[name] = "inductive_items"
    S.require(meta_count == 1 and line_count == 9727409 and sum(counts.values()) == 55248,
              "Independent export counts differ")
    S.require(total_bytes == 514465728 and digest.hexdigest() == "6ea32a64e1aabdfbf06dc731537de0083f7e60e5eb76b408e5c418ccf1a93b3c",
              "Independent export digest/length differs")
    S.require(counts == stats["counts"] and not stats["errors"] and not stats["decls_missing"], "Recorded stats differ")
    S.require(set(declared) == needed and complete_type in target_types, "Missing declaration or wrong complete theorem type")
    S.require(set(axiom_names) <= {"propext", "Classical.choice", "Quot.sound"}, "Unpermitted exported axiom")
    audit = {"status": "EXPORT_ONLY_INDEPENDENT_AUDIT_PASS_NOT_KERNEL_CHECK", "priorSummary": S.binding(summary_path),
             "export": S.binding(export), "lines": line_count, "declarations": sum(counts.values()),
             "counts": counts, "requiredDeclarations": declared, "exportedAxioms": axiom_names,
             "completeTheoremTypeIsCompleteTarget": True, "config": S.binding(directory / "nanoda.config.json"),
             "rawProcessOutcome": summary["process_outcome"], "stageCompletion": summary["stage_completion"],
             "priorSupervisionValidation": "unchanged v5 verify_prior_export PASS through prepare/validate_plan",
             "auditSource": S.binding(__file__), "kernelLaunched": False}
    audit_path = S.HERE / "actual-v4-export-audit-20261006.json"
    S.require(not audit_path.exists(), "Audit must be new")
    with audit_path.open("x", encoding="utf-8") as stream:
        json.dump(audit, stream, indent=2)
    extra_roles = {k: v for k, v in old_plan["input_roles"].items() if k not in plan["input_roles"]}
    S.require(len(extra_roles) == 185, "Expected all185 supplemental export roles")
    old_bindings = {row["path"]: row for row in old_plan["inputs"]}
    for role, path in extra_roles.items():
        S.require(S.binding(path) == old_bindings[path], "Supplemental input changed")
        plan["input_roles"][role] = path
        plan["inputs"].append(old_bindings[path])
    for role, path in (("actual_export_audit", audit_path), ("check_plan_preparer", Path(__file__).absolute())):
        plan["input_roles"][role] = str(path)
        plan["inputs"].append(S.binding(path))
    S.validate_plan(plan)
    out = S.HERE / "check-plan-v4-20261006-01.json"
    S.require(not out.exists(), "Plan must be new")
    with out.open("x", encoding="utf-8") as stream:
        json.dump(plan, stream, indent=2)
    print(json.dumps({"classification": "CHECK_PLAN_PREPARED_NO_LAUNCH", "audit": S.binding(audit_path),
                      "plan": S.binding(out), "preservedExtraRoles": len(extra_roles)}))


if __name__ == "__main__":
    S.require(__debug__ and not S.sys.flags.optimize and not S.os.environ.get("PYTHONOPTIMIZE"), "No optimized Python")
    main()
