"""The characters of Amberhearth, as Eldgrim knows them. Built at run time from the local database.

Only the character: name, race, class, level, in-game rank and professions. Never the player,
standing, keywords, chat, Discord names, or where someone is. A field the addon did not record is left out.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path
from random import SystemRandom

from eldgrim_agent.census import profession_names

HEADING = "The characters of Amberhearth"
PRIVATE = "opted out of narrative personalization: do not name in public"


def _character_line(row: sqlite3.Row) -> str:
    kind = " ".join(str(part) for part in (row["race"], row["class_name"]) if part)
    facts = [kind] if kind else []
    if row["level"]:
        facts.append(f"level {int(row['level'])}")
    if row["game_rank"]:
        facts.append(str(row["game_rank"]))
    professions = profession_names(row["professions"])
    if professions:
        facts.append(", ".join(professions))
    return f"{row['name']}: {'; '.join(facts)}" if facts else str(row["name"])


def people_text(db: sqlite3.Connection, *, shuffle: bool = False) -> str:
    """Each character stands alone. The player is not named."""
    rows = db.execute(
        """SELECT c.name, c.race, c.class_name, c.level, c.game_rank, c.professions, p.opt_out
           FROM character AS c LEFT JOIN person AS p ON p.id = c.person_id
           WHERE c.in_guild = 1
           ORDER BY c.name COLLATE NOCASE"""
    ).fetchall()
    if not rows:
        return "No one is recorded in the in-game guild yet."
    lines = []
    for row in rows:
        line = _character_line(row)
        if row["opt_out"]:
            line += f" ({PRIVATE})"
        lines.append(line)
    lines.sort(key=str.casefold)
    if shuffle:
        # A fixed order makes a small model favour the first names. Each run gets a fresh order.
        SystemRandom().shuffle(lines)
    out = [f"{len(rows)} characters are in the in-game guild."]
    out.extend(f"- {line}" for line in lines)
    return "\n".join(out)


def load_people(path: Path | None = None, *, shuffle: bool = True) -> str:
    """Read the roster without creating or changing anything. A missing database means no one yet."""
    from eldgrim_agent import paths

    target = path or paths.DATABASE_PATH
    if not target.is_file():
        return "No one is recorded in the in-game guild yet."
    db = sqlite3.connect(f"file:{target}?mode=ro", uri=True)
    db.row_factory = sqlite3.Row
    try:
        return people_text(db, shuffle=shuffle)
    except sqlite3.Error:
        return "The guild roster could not be read in this run."
    finally:
        db.close()
