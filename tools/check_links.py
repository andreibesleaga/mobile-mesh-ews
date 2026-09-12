#!/usr/bin/env python3
"""Validate intra-repository links and heading anchors.

This is the deterministic, offline half of the link check: it resolves every
relative Markdown link and image against the working tree and verifies that the
target file and (when present) the ``#fragment`` heading exist. External URLs
are deliberately ignored here and handled by Lychee in CI, which needs network
access.

Exit codes
----------
0  every relative link and anchor resolved
1  one or more relative links or anchors are broken
2  usage error
"""

from __future__ import annotations

import argparse
import re
import sys
import unicodedata
from pathlib import Path

LINK_RE = re.compile(r"!?\[[^\]]*\]\((?P<target>[^)\s]+)(?:\s+\"[^\"]*\")?\)")
FENCE_RE = re.compile(r"^(?P<fence>```+|~~~+)")
HEADING_RE = re.compile(r"^(?P<level>#{1,6})\s+(?P<title>.+?)\s*#*\s*$")

SKIP_PREFIXES = ("http://", "https://", "mailto:", "tel:", "data:", "ftp://")

EXCLUDED_DIRS = {".git", "node_modules", "venv", ".venv", "__pycache__"}


def slugify(title: str) -> str:
    """Approximate GitHub's heading slug algorithm."""
    text = re.sub(r"`([^`]*)`", r"\1", title)
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"<[^>]+>", "", text)
    text = unicodedata.normalize("NFKD", text)
    text = text.lower()
    text = re.sub(r"[^\w\s-]", "", text, flags=re.UNICODE)
    text = re.sub(r"\s+", "-", text.strip())
    return text


def strip_code_fences(text: str) -> str:
    """Remove fenced code blocks so example links inside them are ignored."""
    out: list[str] = []
    fence: str | None = None
    for line in text.splitlines():
        match = FENCE_RE.match(line)
        if match:
            marker = match.group("fence")[0] * 3
            if fence is None:
                fence = marker
            elif fence == marker:
                fence = None
            out.append("")
            continue
        out.append("" if fence else line)
    return "\n".join(out)


def iter_markdown(root: Path):
    for path in sorted(root.rglob("*.md")):
        if any(part in EXCLUDED_DIRS for part in path.parts):
            continue
        yield path


def collect_anchors(path: Path) -> set[str]:
    anchors: set[str] = set()
    text = strip_code_fences(path.read_text(encoding="utf-8", errors="replace"))
    counts: dict[str, int] = {}
    for line in text.splitlines():
        match = HEADING_RE.match(line)
        if not match:
            continue
        base = slugify(match.group("title"))
        seen = counts.get(base, 0)
        counts[base] = seen + 1
        anchors.add(base if seen == 0 else f"{base}-{seen}")
    return anchors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".", help="repository root (default: .)")
    args = parser.parse_args()

    root = Path(args.repo).resolve()
    if not root.is_dir():
        print(f"error: {root} is not a directory", file=sys.stderr)
        return 2

    anchor_cache: dict[Path, set[str]] = {}
    failures: list[str] = []
    checked = 0

    for md in iter_markdown(root):
        text = strip_code_fences(md.read_text(encoding="utf-8", errors="replace"))
        for match in LINK_RE.finditer(text):
            target = match.group("target").strip().strip("<>")
            if not target or target.startswith(SKIP_PREFIXES):
                continue

            checked += 1
            rel = md.relative_to(root)
            path_part, _, fragment = target.partition("#")

            if path_part:
                candidate = (md.parent / path_part).resolve()
                try:
                    candidate.relative_to(root)
                except ValueError:
                    failures.append(f"{rel}: link escapes repository -> {target}")
                    continue
                if not candidate.exists():
                    failures.append(f"{rel}: missing target -> {target}")
                    continue
                if fragment and candidate.suffix.lower() == ".md":
                    anchors = anchor_cache.setdefault(candidate, collect_anchors(candidate))
                    if fragment.lower() not in anchors:
                        failures.append(f"{rel}: missing anchor -> {target}")
            elif fragment:
                anchors = anchor_cache.setdefault(md, collect_anchors(md))
                if fragment.lower() not in anchors:
                    failures.append(f"{rel}: missing anchor -> {target}")

    print(f"checked {checked} relative link(s) across {root}")
    if failures:
        print(f"\n{len(failures)} broken relative link(s):", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("all relative links and anchors resolve")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
