#!/usr/bin/env python3
"""Scaffold a new data science project from ``projects/_template``.

Usage:
    uv run scripts/new_project.py "house price prediction"
    python scripts/new_project.py house-price-prediction

Copies ``projects/_template`` to ``projects/<slug>``, renames the
``src/project_template`` package to ``src/<package>``, and substitutes the
placeholder tokens (``project_template`` / ``Project Template``) with the new
project's package name and title across every text file in the new project.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
TEMPLATE_DIR = REPO_ROOT / "projects" / "_template"
PROJECTS_DIR = REPO_ROOT / "projects"

PACKAGE_PLACEHOLDER = "project_template"
TITLE_PLACEHOLDER = "Project Template"


def slugify(name: str) -> str:
    """Turn arbitrary input into a lowercase, hyphenated folder name."""
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", name.strip()).strip("-").lower()
    if not slug:
        raise ValueError(f"'{name}' does not contain any usable characters")
    return slug


def to_package_name(slug: str) -> str:
    """Convert a hyphenated slug into a valid, importable Python package name."""
    package = slug.replace("-", "_")
    if package[0].isdigit():
        package = f"p_{package}"
    return package


def to_title(slug: str) -> str:
    return " ".join(word.capitalize() for word in slug.split("-"))


def replace_in_file(path: Path, package: str, title: str) -> None:
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, ValueError):
        return  # binary file, leave untouched

    updated = text.replace(PACKAGE_PLACEHOLDER, package).replace(
        TITLE_PLACEHOLDER, title
    )
    if updated != text:
        path.write_text(updated, encoding="utf-8")


def create_project(raw_name: str) -> Path:
    if not TEMPLATE_DIR.exists():
        raise SystemExit(f"Template not found at {TEMPLATE_DIR}")

    slug = slugify(raw_name)
    package = to_package_name(slug)
    title = to_title(slug)

    dest = PROJECTS_DIR / slug
    if dest.exists():
        raise SystemExit(f"Project already exists: {dest}")

    shutil.copytree(TEMPLATE_DIR, dest)

    old_pkg_dir = dest / "src" / PACKAGE_PLACEHOLDER
    new_pkg_dir = dest / "src" / package
    if old_pkg_dir.exists():
        old_pkg_dir.rename(new_pkg_dir)

    for path in dest.rglob("*"):
        if path.is_file():
            replace_in_file(path, package, title)

    return dest


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "name",
        help="Project name, e.g. 'house price prediction' or 'house-price-prediction'",
    )
    args = parser.parse_args()

    try:
        dest = create_project(args.name)
    except (ValueError, SystemExit) as exc:
        print(f"error: {exc}", file=sys.stderr)
        sys.exit(1)

    rel = dest.relative_to(REPO_ROOT)
    print(f"Created new project at {rel}")
    print()
    print("Next steps:")
    print(f"  cd {rel}")
    print("  uv sync")
    print(f"  # fill in the TODOs in {rel}/README.md and {rel}/data/README.md")
    print(f"  # then add the project to the table in {REPO_ROOT / 'README.md'}")


if __name__ == "__main__":
    main()
