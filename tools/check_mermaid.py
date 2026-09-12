#!/usr/bin/env python3
"""Render every Mermaid block in the repository to catch syntax errors.

Documentation repositories embed diagram source as text; a typo is invisible
until a reader opens the file on GitHub. This script extracts each
`` ```mermaid `` block, renders it with the pinned Mermaid CLI, and fails on the
first parse error.

Requirements
------------
* Node.js available on ``PATH`` (the CI runner provides it).
* ``@mermaid-js/mermaid-cli`` is fetched with ``npx`` at the pinned version
  below, so the check is reproducible across machines.

Exit codes
----------
0  every Mermaid block rendered
1  at least one block failed to render
2  usage error, or Mermaid CLI unavailable
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

MERMAID_CLI_VERSION = "11.4.2"
# Puppeteer needs the sandbox disabled in containers and many CI runners.
PUPPETEER_ARGS = ["--no-sandbox", "--disable-setuid-sandbox"]
OPEN_FENCE = re.compile(r"^\s*(```+|~~~+)\s*mermaid\s*$")
ANY_FENCE = re.compile(r"^\s*(```+|~~~+)\s*$")

EXCLUDED_DIRS = {".git", "node_modules", "venv", ".venv"}


def blocks(text: str):
    """Yield (start_line, source) for each Mermaid fenced block."""
    lines = text.splitlines()
    index = 0
    while index < len(lines):
        if OPEN_FENCE.match(lines[index]):
            start = index + 1
            body: list[str] = []
            index = start
            while index < len(lines) and not ANY_FENCE.match(lines[index]):
                body.append(lines[index])
                index += 1
            yield start, "\n".join(body)
        index += 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".", help="repository root (default: .)")
    args = parser.parse_args()

    root = Path(args.repo).resolve()
    if not root.is_dir():
        print(f"error: {root} is not a directory", file=sys.stderr)
        return 2

    npx = shutil.which("npx")
    if not npx:
        print("error: npx not found on PATH", file=sys.stderr)
        return 2

    failures: list[str] = []
    rendered = 0

    with tempfile.TemporaryDirectory(prefix="mermaid-") as tmp:
        tmpdir = Path(tmp)
        puppeteer_config = tmpdir / "puppeteer.json"
        puppeteer_config.write_text(
            json.dumps({"args": PUPPETEER_ARGS}), encoding="utf-8"
        )
        for md in sorted(root.rglob("*.md")):
            if any(part in EXCLUDED_DIRS for part in md.parts):
                continue
            text = md.read_text(encoding="utf-8", errors="replace")
            rel = md.relative_to(root)
            for line_number, source in blocks(text):
                if not source.strip():
                    continue
                rendered += 1
                source_file = tmpdir / "diagram.mmd"
                output_file = tmpdir / "diagram.svg"
                source_file.write_text(source, encoding="utf-8")
                output_file.unlink(missing_ok=True)
                result = subprocess.run(
                    [
                        npx,
                        "-y",
                        f"@mermaid-js/mermaid-cli@{MERMAID_CLI_VERSION}",
                        "-i",
                        str(source_file),
                        "-o",
                        str(output_file),
                        "-p",
                        str(puppeteer_config),
                        "--quiet",
                    ],
                    capture_output=True,
                    text=True,
                    check=False,
                )
                if result.returncode != 0 or not output_file.exists():
                    detail = (result.stderr or result.stdout or "").strip().splitlines()
                    reason = detail[-1] if detail else "unknown error"
                    failures.append(f"{rel}:{line_number}: {reason}")

    print(f"rendered {rendered} Mermaid block(s)")
    if failures:
        print(f"\n{len(failures)} Mermaid block(s) failed to render:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("all Mermaid blocks render")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
