"""Repository pages and the private runtime directory."""

from __future__ import annotations

import os
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
AGENT_ROOT = REPO_ROOT / "agent"

RUNTIME_ROOT = Path(
    os.environ.get("ELDGRIM_RUNTIME", Path.home() / ".local" / "share" / "eldgrim")
)
ORIGIN_PATH = Path(
    os.environ.get("ELDGRIM_ORIGIN", RUNTIME_ROOT / "private" / "ORIGIN.md")
)
# Phrases that would give the roots away. Kept beside the origin, never in the repository.
GUARD_PATH = Path(
    os.environ.get("ELDGRIM_GUARD", RUNTIME_ROOT / "private" / "GUARD.txt")
)
NEXT_RUN_PATH = RUNTIME_ROOT / "next-run.json"
ANNOUNCEMENTS = RUNTIME_ROOT / "announcements"
OFFICER_NOTES = RUNTIME_ROOT / "officer"
LOGS = RUNTIME_ROOT / "logs"
LOCK_PATH = RUNTIME_ROOT / "run.lock"
LAST_BRIEF = RUNTIME_ROOT / "last-brief.txt"
COMPARE_DIR = RUNTIME_ROOT / "compare"
DATABASE_PATH = RUNTIME_ROOT / "eldgrim.sqlite3"

MODEL = os.environ.get("ELDGRIM_MODEL", "qwen3:8b")

# What Eldgrim reads is named in agent/context.toml.


def ensure_runtime() -> None:
    for path in (RUNTIME_ROOT, ANNOUNCEMENTS, LOGS):
        path.mkdir(parents=True, exist_ok=True)
    RUNTIME_ROOT.chmod(0o700)
    (RUNTIME_ROOT / "private").mkdir(parents=True, exist_ok=True)
