"""Bind the completed owned-slot preservation to a new retry plan; never launch."""
import json
from pathlib import Path
import supervise_stage_v5 as S


def main():
    original = S.HERE / "check-plan-v4-20261006-02.json"
    S.require(S.sha(original) == "c2b0dd5ab525a7b06895c371c52ce3e3326f070ecd5de3b07cccd4625c7ddb6e", "Wrong prepared retry")
    plan = S.read_json(original)
    receipt = S.HERE / "preserved-check01-slot/RECEIPT.json"
    doc = S.read_json(receipt)
    owner = S.HERE / "preserved-check01-slot/owner.txt"
    S.require(doc["status"] == "OWNED_TIMEOUT_SLOT_PRESERVED_AND_EMPTY_DIRECTORY_REMOVED"
              and doc["ownedCleanupConfirmed"] is True and doc["noRelevantProcessObservedTwice"] is True
              and doc["recursiveDeletion"] is False and doc["proofSourcesOrObjectsChanged"] is False,
              "Incomplete slot preservation")
    S.require(doc["source"] == str(S.COPY / ".lean_slot/owner.txt") and not (S.COPY / ".lean_slot").exists(),
              "Original slot has reappeared; inspect ownership before retry")
    S.require(doc["preserved"] == str(owner) and doc["bytes"] == owner.stat().st_size == 93
              and doc["sha256"] == S.sha(owner) == "ede448301280b34e72fd4f18ba716bd26550c4348436ccbbbc0abead36214ca5",
              "Preserved owner differs")
    S.require(doc["timeoutResultSha256"] == "f809dcdd18b4b13fe41b337a481704b04a06d5fec075dacbade56d7a790fa66f"
              and S.sha(doc["timeoutResult"]) == doc["timeoutResultSha256"], "Wrong timeout provenance")
    extras = {"check01_slot_preservation_receipt": receipt, "check01_slot_preserved_owner": owner,
              "check01_slot_preservation_helper": S.HERE / "PreserveCheck01Slot.ps1",
              "slot_bound_retry_preparer": Path(__file__).absolute()}
    for role, path in extras.items():
        plan["input_roles"][role] = str(path)
        plan["inputs"].append(S.binding(path))
    S.validate_plan(plan)
    output = S.HERE / "check-plan-v4-20261006-02-slot-bound.json"
    S.require(not output.exists(), "Output plan already exists")
    with output.open("x", encoding="utf-8") as stream:
        json.dump(plan, stream, indent=2)
    print(json.dumps({"classification": "RETRY_PREPARED_NO_LAUNCH", "plan": S.binding(output),
                      "slotReceipt": S.binding(receipt), "totalInputRoles": len(plan["input_roles"])}))


if __name__ == "__main__":
    S.require(__debug__ and not S.sys.flags.optimize and not S.os.environ.get("PYTHONOPTIMIZE"), "No optimized Python")
    main()
