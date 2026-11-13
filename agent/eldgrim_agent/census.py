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
        "SELECT name, professions, last_spoke FROM character WHERE in_guild = 1 ORDER BY name COLLATE NOCASE"
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
        "**Professions**",
    ]
    if not census.professions:
        lines.append("No professions recorded yet.")
    for profession, names in census.professions.items():
        lines.append(f"{profession} ({len(names)})")
        lines.append(_names(names, limit))
    return "\n".join(lines)
