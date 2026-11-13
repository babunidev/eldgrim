"""The people of Amberhearth, as Eldgrim knows them. Built at run time from the local database.

Only membership facts: characters, race, class, level, in-game rank and professions. Never standing,
keywords, chat, Discord ids, or where someone is. A field the addon did not record is left out.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path
from random import SystemRandom

from eldgrim_agent.census import profession_names

HEADING = "The people of Amberhearth"
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
    """Characters grouped under one person only when the member declared them in the Forge (Q158)."""
    rows = db.execute(
        """SELECT c.name, c.race, c.class_name, c.level, c.game_rank, c.professions, c.link,
                  c.person_id, p.display_name, p.discord_id, p.opt_out
           FROM character AS c LEFT JOIN person AS p ON p.id = c.person_id
           WHERE c.in_guild = 1
           ORDER BY c.name COLLATE NOCASE"""
    ).fetchall()
    if not rows:
        return "No one is recorded in the in-game guild yet."
    groups: dict[int, list[sqlite3.Row]] = {}
    alone: list[sqlite3.Row] = []
    for row in rows:
        declared = row["link"] == "declared" and row["person_id"] is not None and row["discord_id"] is not None
        if declared:
            groups.setdefault(int(row["person_id"]), []).append(row)
        else:
            alone.append(row)
    entries: list[tuple[str, list[str]]] = []
    for members in groups.values():
        first = members[0]
        label = str(first["display_name"] or "").strip() or "One member"
        lines = [_character_line(row) for row in members]
        if first["opt_out"]:
            label += f" ({PRIVATE})"
        entries.append((f"{label}, on Discord, plays:", lines))
    for row in alone:
        line = _character_line(row)
        if row["opt_out"]:
            line += f" ({PRIVATE})"
        entries.append(("", [line]))
    entries.sort(key=lambda entry: (entry[0] or entry[1][0]).casefold())
    if shuffle:
        # A fixed order makes a small model favour the first names. Each run gets a fresh order.
        SystemRandom().shuffle(entries)
    out = [f"{len(rows)} characters are in the in-game guild."]
    for label, lines in entries:
        if label:
            out.append(f"- {label}")
            out.extend(f"  - {line}" for line in lines)
        else:
            out.append(f"- {lines[0]}")
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
