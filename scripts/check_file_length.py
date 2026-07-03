#!/usr/bin/env python3
"""Fail if any tracked Python source file exceeds the project's max line count."""

from __future__ import annotations

import sys
from pathlib import Path

MAX_LINES = 500
SOURCE_DIRS = ("src", "tests")


def find_violations(root: Path) -> list[tuple[Path, int]]:
    violations: list[tuple[Path, int]] = []
    for source_dir in SOURCE_DIRS:
        for path in (root / source_dir).rglob("*.py"):
            line_count = sum(1 for _ in path.open(encoding="utf-8"))
            if line_count > MAX_LINES:
                violations.append((path, line_count))
    return violations


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    violations = find_violations(root)
    if not violations:
        print(f"OK: all files under {MAX_LINES} lines.")
        return 0

    print(f"Files exceeding the {MAX_LINES}-line limit:")
    for path, line_count in violations:
        print(f"  {path.relative_to(root)}: {line_count} lines")
    return 1


if __name__ == "__main__":
    sys.exit(main())
