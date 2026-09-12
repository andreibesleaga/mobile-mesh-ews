#!/usr/bin/env python3
"""Check that the PRD and the Requirements Traceability Matrix agree.

The PRD is the source of requirement identifiers (``REQ-<GROUP>-<NNN>``) and the
Requirements Traceability Matrix (RTM) is the authoritative status view. Drift
between the two is the highest-value documentation defect this repository can
have, so it is checked mechanically in both directions:

* every identifier defined in the PRD must be covered by an RTM row;
* every identifier or range referenced by the RTM must exist in the PRD.

The RTM expresses coverage with numeric ranges, for example
``REQ-GEN-001–006`` (en dash) or ``REQ-EDGE-001-009`` (hyphen). Both are
expanded before comparison.

Exit codes
----------
0  PRD and RTM agree
1  identifiers are missing on one side
2  usage or parse error
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ID_RE = re.compile(r"\bREQ-[A-Z]+-\d{3}\b")
# A range start, an optional "–"/"-", then the trailing numeric field.
RANGE_RE = re.compile(r"\b(REQ-([A-Z]+)-(\d{3}))\s*[–—-]\s*(\d{3})\b")

PRD_GLOBS = ("PRD_*.md",)
RTM_GLOBS = ("Requirements_Traceability_Matrix.md",)


def expand(text: str) -> set[str]:
    """Return every requirement identifier mentioned in ``text``, ranges expanded."""
    found: set[str] = set()
    for group, prefix, start, end in RANGE_RE.findall(text):
        low, high = int(start), int(end)
        if high < low or high - low > 500:
            found.add(group)
            continue
        for number in range(low, high + 1):
            found.add(f"REQ-{prefix}-{number:03d}")
    for identifier in ID_RE.findall(text):
        found.add(identifier)
    return found


def gather(root: Path, globs: tuple[str, ...]) -> set[str]:
    identifiers: set[str] = set()
    for pattern in globs:
        for path in sorted(root.rglob(pattern)):
            if any(part in {".git", "node_modules"} for part in path.parts):
                continue
            identifiers |= expand(path.read_text(encoding="utf-8", errors="replace"))
    return identifiers


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".", help="repository root (default: .)")
    args = parser.parse_args()

    root = Path(args.repo).resolve()
    if not root.is_dir():
        print(f"error: {root} is not a directory", file=sys.stderr)
        return 2

    prd = gather(root, PRD_GLOBS)
    rtm = gather(root, RTM_GLOBS)

    if not prd:
        print("error: no PRD requirement identifiers found", file=sys.stderr)
        return 2
    if not rtm:
        print("error: no RTM requirement identifiers found", file=sys.stderr)
        return 2

    missing_in_rtm = sorted(prd - rtm)
    missing_in_prd = sorted(rtm - prd)

    print(f"PRD identifiers: {len(prd)}; RTM identifiers: {len(rtm)}")

    if not missing_in_rtm and not missing_in_prd:
        print("PRD and RTM are in agreement")
        return 0

    if missing_in_rtm:
        print(f"\n{len(missing_in_rtm)} PRD identifier(s) not covered by the RTM:", file=sys.stderr)
        for identifier in missing_in_rtm:
            print(f"  - {identifier}", file=sys.stderr)
    if missing_in_prd:
        print(f"\n{len(missing_in_prd)} RTM identifier(s) not defined in the PRD:", file=sys.stderr)
        for identifier in missing_in_prd:
            print(f"  - {identifier}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
