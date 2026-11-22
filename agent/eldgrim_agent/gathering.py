"""The Sunday gathering: one standing point per member per Sunday attended.

The addon records, on Sunday from 19:00 to 20:00 Swedish time, the guild members
who spoke in /say near an addon user and the guild members in an addon user's
group or raid. The record arrives in `EldgrimGathering`, keyed by the Sunday's
date. A member counts as present when Jasmine Amberbrew's client saw them
itself, when two members passed on the same mark, or when the one member who
passed it on is someone else. Nobody witnesses themselves alone.

Founder decision, 22 November 2026. The say lines are used only to see who was
there. They are not scored, not kept, and the day is cleared from the file after
the run has recorded it.
"""

from __future__ import annotations

import re
import sqlite3
from datetime import datetime, time
from zoneinfo import ZoneInfo

from eldgrim_agent.lua_saved import Table
from eldgrim_agent.store import adjust_standing, ensure_member, stamp

STOCKHOLM = ZoneInfo("Europe/Stockholm")
END = time(20, 0)
DAY = re.compile(r"^\d{4}-\d{2}-\d{2}$")
RULE = "sunday gathering"


def finished(day: str, now: datetime) -> bool:
    """Whether that Sunday's hour is over, by Swedish time."""
    try:
        date = datetime.strptime(day, "%Y-%m-%d").date()
    except ValueError:
        return False
    if date.weekday() != 6:
        return False
    return now.astimezone(STOCKHOLM) >= datetime.combine(date, END, tzinfo=STOCKHOLM)


def present(rows: Table) -> list[str]:
    """Names seen at the gathering, in first-seen order, under the witness rule."""
    names: list[str] = []
    for _, row in rows.items:
        if not isinstance(row, Table):
            continue
        speaker = row.get("speaker")
        kind = row.get("kind")
        if not isinstance(speaker, str) or not speaker.strip() or kind not in ("say", "group"):
            continue
        passer = row.get("passedBy")
        if passer is not None and passer == speaker:
            continue
        if speaker not in names:
            names.append(speaker)
    return names


def award(db: sqlite3.Connection, gatherings: Table | None, now: datetime) -> tuple[list[str], dict[str, list[str]]]:
    """Give the point once per member and Sunday. Returns the days finished and who was present."""
    done: list[str] = []
    seen: dict[str, list[str]] = {}
    if not isinstance(gatherings, Table):
        return done, seen
    for day, rows in gatherings.items:
        if not isinstance(day, str) or not DAY.match(day) or not isinstance(rows, Table):
            continue
        if not finished(day, now):
            continue
        names = present(rows)
        for name in names:
            person_id = ensure_member(db, name, {}, now)
            if not person_id:
                continue
            cursor = db.execute(
                "INSERT OR IGNORE INTO gathering_attended (person_id, day, created) VALUES (?, ?, ?)",
                (person_id, day, stamp(now)),
            )
            if cursor.rowcount == 1:
                adjust_standing(db, person_id, 1, RULE, None, now)
        db.commit()
        done.append(day)
        seen[day] = names
    return done, seen

