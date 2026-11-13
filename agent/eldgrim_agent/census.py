"""Counts and names for the keepers' note: members, who spoke in guild chat, and who holds which profession."""

from __future__ import annotations

import sqlite3
from dataclasses import dataclass, field
from datetime import datetime, timedelta

from eldgrim_agent.lua_saved import Table, parse_saved

ACTIVE_DAYS = 7


@dataclass
class Census:
    members: list[str] = field(default_factory=list)
    active: list[str] = field(default_factory=list)
    professions: dict[str, list[str]] = field(default_factory=dict)
    # (character, level at the last posted note, level now); only characters with a baseline.
    level_ups: list[tuple[str, int, int]] = field(default_factory=list)
    has_baseline: bool = True


def profession_names(stored: str | None) -> list[str]:
    """Read the profession names the addon actually saved. Anything unreadable is left out."""
    if not stored:
        return []
    try:
        table = parse_saved(stored).get("professions")
    except ValueError:
        return []
    if not isinstance(table, Table):
        return []
    names: list[str] = []
    for _key, value in table.items:
        name = value.get("name") if isinstance(value, Table) else None
        if isinstance(name, str) and name.strip() and name.strip() not in names:
            names.append(name.strip())
    return names


def take_census(db: sqlite3.Connection, now: datetime) -> Census:
    """Characters in the in-game guild. Active means a guild-chat line within the last seven days."""
    since = (now.astimezone().date() - timedelta(days=ACTIVE_DAYS - 1)).isoformat()
    rows = db.execute(
        "SELECT name, professions, last_spoke, level, census_level FROM character "
        "WHERE in_guild = 1 ORDER BY name COLLATE NOCASE"
    ).fetchall()
    census = Census()
    for row in rows:
        name = str(row["name"])
        if name in census.members:
            continue
        census.members.append(name)
        if row["last_spoke"] and str(row["last_spoke"]) >= since:
            census.active.append(name)
        for profession in profession_names(row["professions"]):
            census.professions.setdefault(profession, []).append(name)
        if row["level"] is not None and row["census_level"] is not None:
            if int(row["level"]) > int(row["census_level"]):
                census.level_ups.append((name, int(row["census_level"]), int(row["level"])))
    census.has_baseline = any(row["census_level"] is not None for row in rows)
    census.professions = dict(sorted(census.professions.items(), key=lambda item: item[0].casefold()))
    return census


def _names(names: list[str], limit: int | None) -> str:
    if not names:
        return "none"
    if limit is None or len(names) <= limit:
        return ", ".join(names)
    shown = names[:limit]
    rest = len(names) - limit
    return (", ".join(shown) + f" and {rest} more") if shown else f"{rest} not named"


def render_census(census: Census, limit: int | None = None) -> str:
    lines = [
        f"**Guild members: {len(census.members)}**",
        "",
        f"**Active in guild chat, last {ACTIVE_DAYS} days: {len(census.active)}**",
        _names(census.active, limit),
        "",
    ]
    if not census.has_baseline:
        lines.append("**Level-ups:** counted from the next note on.")
    else:
        gained = sum(new - old for _name, old, new in census.level_ups)
        people = len(census.level_ups)
        lines.append(f"**Level-ups since the last note: {gained}** ({people} {'character' if people == 1 else 'characters'})")
        lines.append(_names([f"{name} {old} → {new}" for name, old, new in census.level_ups], limit))
    lines.extend(["", "**Professions**"])
    if not census.professions:
        lines.append("No professions recorded yet.")
    for profession, names in census.professions.items():
        lines.append(f"{profession} ({len(names)})")
        lines.append(_names(names, limit))
    return "\n".join(lines)
