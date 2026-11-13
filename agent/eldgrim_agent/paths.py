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

# What Eldgrim reads when it acts. The latest confirmed answer controls an older line.
ACTING_PAGES = (
    REPO_ROOT / "character" / "PROFILE.md",
    REPO_ROOT / "character" / "VOICE.md",
    REPO_ROOT / "lore" / "AMBERHEARTH.md",
    REPO_ROOT / "lore" / "FIRES_AND_SYMBOLS.md",
    REPO_ROOT / "interaction" / "PRINCIPLES.md",
    REPO_ROOT / "governance" / "01-established-foundation.md",
    REPO_ROOT / "governance" / "02-identity-and-purpose.md",
    REPO_ROOT / "governance" / "03-social-rules.md",
    REPO_ROOT / "governance" / "04-ranks-and-membership.md",
    REPO_ROOT / "governance" / "05-eldgrims-authority.md",
    REPO_ROOT / "governance" / "06-daily-conduct-and-communication.md",
    REPO_ROOT / "governance" / "07-member-evaluation-and-standing.md",
    REPO_ROOT / "governance" / "08-quests-recognition-and-rewards.md",
    REPO_ROOT / "governance" / "09-sunday-gatherings.md",
    REPO_ROOT / "governance" / "10-moderation-and-discipline.md",
    REPO_ROOT / "governance" / "11-guild-bank-and-stewardship.md",
    REPO_ROOT / "governance" / "12-observation-memory-and-privacy.md",
    REPO_ROOT / "governance" / "13-technical-autonomy.md",
    REPO_ROOT / "governance" / "14-conflicts-and-gaps.md",
    REPO_ROOT / "governance" / "15-proposed-priority-hierarchy.md",
    REPO_ROOT / "governance" / "16-constitutional-documents.md",
    REPO_ROOT / "governance" / "CONSISTENCY-AUDIT.md",
    REPO_ROOT / "governance" / "IMPLEMENTATION-MATRIX.md",
    REPO_ROOT / "governance" / "OPERATING-PROCEDURES.md",
    REPO_ROOT / "governance" / "QUESTION-DECISIONS.md",
)
PUBLIC_PAGES = ACTING_PAGES


def ensure_runtime() -> None:
    for path in (RUNTIME_ROOT, ANNOUNCEMENTS, LOGS):
        path.mkdir(parents=True, exist_ok=True)
    RUNTIME_ROOT.chmod(0o700)
    (RUNTIME_ROOT / "private").mkdir(parents=True, exist_ok=True)
