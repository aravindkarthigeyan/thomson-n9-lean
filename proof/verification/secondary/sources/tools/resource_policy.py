"""Conservative gates for the Codex-owned copy; no source-name exceptions."""
import math
import os
import sys

MIN_PHYSICAL_GIB = 6.5
MIN_COMMIT_GIB = 11.75
PHYSICAL_VARIABLES = ("MIN_FREE_GB", "HEAVY_MIN_FREE_GB", "FRESH_MIN_FREE_GB", "PIN_MIN_FREE_GB")
COMMIT_VARIABLES = ("MIN_FREE_COMMIT_GB", "ASSEMBLY_MIN_FREE_COMMIT_GB", "HEAVY_MIN_FREE_COMMIT_GB", "STEP_COMMIT")


def number(value):
    result = float(value)
    if not math.isfinite(result) or result < 0:
        raise ValueError("Resource thresholds must be finite nonnegative numbers")
    return result


def effective_gates(physical=MIN_PHYSICAL_GIB, commit=MIN_COMMIT_GIB):
    # Unrecognized, renamed and changed sources all receive the same floor.
    return max(number(physical), MIN_PHYSICAL_GIB), max(number(commit), MIN_COMMIT_GIB)


def validate_environment(environ):
    for keys, floor in ((PHYSICAL_VARIABLES, MIN_PHYSICAL_GIB), (COMMIT_VARIABLES, MIN_COMMIT_GIB)):
        for key in keys:
            if key in environ and number(environ[key]) < floor:
                raise ValueError(f"{key}={environ[key]} is below the unprofiled floor {floor} GiB")


if __name__ == "__main__":
    try:
        validate_environment(os.environ)
    except (TypeError, ValueError) as error:
        print(f"REFUSED: {error}", file=sys.stderr)
        raise SystemExit(2)
