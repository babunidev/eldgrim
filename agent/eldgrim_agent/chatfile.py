"""Use the guild-chat file as it sits. New lines are reduced. Then those lists are cleared."""

from __future__ import annotations

import hashlib
import os
import sqlite3
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

from eldgrim_agent.keywords import validate_keyword
from eldgrim_agent.lua_saved import (
    Table,
    character_messages,
    dump_saved,
    empty_messages,
    parse_saved,
)
from eldgrim_agent.store import (
    add_keyword,
    adjust_standing,
    apply_ingame_roster,
    ensure_member,
    forget_hashes,
    known_hashes,
    message_hash,
    record_spoke,
    remember_hashes,
)

SKIPPED_PROFILE = {"messages", "online", "lastOnline", "rankIndex", "note", "publicNote", "officerNote"}
PROFILE_FIELDS = {
    "race": "race",
    "class": "class_name",
    "faction": "faction",
    "zone": "zone",
    "level": "level",
    "rank": "game_rank",
    "achievementPoints": "achievement_points",
}


@dataclass
class ChatOutcome:
    skipped: str = ""
    error: str = ""
    themes: list[str] = field(default_factory=list)
    polarity: dict[int, str] = field(default_factory=dict)
    cleared: list[str] = field(default_factory=list)
    departed: list[str] = field(default_factory=list)
    pending_hashes: list[str] = field(default_factory=list)


def saved_path(path: Path | None = None) -> Path | None:
    if path is not None:
        return path
    override = os.environ.get("ELDGRIM_SAVED", "").strip()
    if override:
        return Path(override)
    config = Path(os.environ.get("ELDGRIM_WOW", Path.home() / ".config" / "eldgrim" / "wow.toml"))
    if not config.is_file():
        return None
    for line in config.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        if key.strip() == "saved_variables":
            return Path(value.strip().strip('"').strip("'"))
    return None


def _profile_fields(character: Table) -> dict[str, object]:
    fields: dict[str, object] = {}
    for source, column in PROFILE_FIELDS.items():
        value = character.get(source)
        if value in (None, ""):
            continue
        if column == "level" and isinstance(value, (int, float)):
            fields[column] = int(value)
        elif column == "achievement_points" and isinstance(value, (int, float)):
            fields[column] = int(value)
        elif isinstance(value, str):
            fields[column] = value
    professions = character.get("professions")
    if isinstance(professions, Table) and professions.items:
        fields["professions"] = dump_saved({"professions": professions}).strip()
    return fields


def _roster_members(roster: Table) -> tuple[int | None, dict[str, dict[str, object]]]:
    updated = roster.get("updated")
    members = roster.get("members")
    if not isinstance(updated, (int, float)) or not isinstance(members, Table):
        return None, {}
    names: dict[str, dict[str, object]] = {}
    for key, value in members.items:
        if not isinstance(key, str) or not isinstance(value, Table):
            continue
        names[key] = _profile_fields(value)
    return int(updated), names


def _without_messages(character: Table) -> list[tuple[object, object]]:
    return [(key, value) for key, value in character.items if key != "messages"]


def reduce_chat(
    db: sqlite3.Connection,
    path: Path | None,
    ask,
    now: datetime,
) -> ChatOutcome:
    outcome = ChatOutcome()
    if path is None or not path.is_file():
        outcome.skipped = "missing"
        return outcome
    try:
        original = path.read_bytes()
    except OSError as exc:
        outcome.error = f"Could not read the guild-chat file: {exc}"
        return outcome
    if not original.strip():
        outcome.skipped = "empty"
        return outcome
    try:
        tables = parse_saved(original.decode("utf-8"))
    except ValueError as exc:
        outcome.error = f"Could not read the guild-chat file: {exc}"
        return outcome
    characters = tables.get("EldgrimDB")
    if not isinstance(characters, Table):
        outcome.skipped = "empty"
    else:
        _reduce_characters(db, characters, ask, now, outcome)
        if outcome.cleared:
            if _clear_finished(path, original, tables, outcome.cleared):
                forget_hashes(db, outcome.pending_hashes)
                db.commit()
            else:
                outcome.error = outcome.error or "The guild-chat file changed before it could be cleared."
                outcome.cleared = []
    roster = tables.get("EldgrimRoster")
    if isinstance(roster, Table):
        updated, names = _roster_members(roster)
        if updated is not None and names:
            outcome.departed = apply_ingame_roster(db, updated=updated, names=names, now=now)
    db.commit()
    return outcome


def _reduce_characters(db: sqlite3.Connection, characters: Table, ask, now: datetime, outcome: ChatOutcome) -> None:
    spoken = []
    for key, value in characters.items:
        if not isinstance(key, str) or not isinstance(value, Table):
            continue
        messages = character_messages(value)
        if messages:
            spoken.append((key, value, messages))
    for key, value in characters.items:
        if isinstance(key, str) and isinstance(value, Table):
            ensure_member(db, key, _profile_fields(value), now)
    if not spoken:
        outcome.skipped = "empty"
        db.commit()
        return
    finished: list[str] = []
    finished_hashes: list[str] = []
    for name, table, messages in spoken:
        person_id = ensure_member(db, name, _profile_fields(table), now)
        if not person_id:
            continue
        person = db.execute("SELECT opt_out, standing FROM person WHERE id = ?", (person_id,)).fetchone()
        if person is None or person["opt_out"] or person["standing"] is None:
            continue
        record_spoke(db, person_id, name, _spoke_on(messages, now))
        hashes = [message_hash(name, int(item["timestamp"]), str(item["message"])) for item in messages]
        fresh_index = [index for index, digest in enumerate(hashes) if digest not in known_hashes(db, hashes)]
        if not fresh_index:
            finished.append(name)
            finished_hashes.extend(hashes)
            continue
        fresh = [str(messages[index]["message"]) for index in fresh_index]
        try:
            parsed = None if ask is None else validate_keyword(str(ask(fresh)))
        except Exception:
            continue
        keyword_id = None
        if parsed is not None:
            polarity, term = parsed
            keyword_id = add_keyword(db, person_id, term, polarity, now)
            outcome.themes.append(term)
            outcome.polarity[person_id] = polarity
            if polarity == "positive":
                adjust_standing(db, person_id, 1, "positive keyword", keyword_id, now)
            elif polarity == "negative":
                adjust_standing(db, person_id, -2, "negative keyword", keyword_id, now)
        else:
            outcome.polarity.setdefault(person_id, "")
        adjust_standing(db, person_id, 1, "guild-chat activity", keyword_id, now)
        remember_hashes(db, [hashes[index] for index in fresh_index])
        db.commit()
        finished.append(name)
        finished_hashes.extend(hashes)
    outcome.cleared = finished
    outcome.pending_hashes = finished_hashes


def _spoke_on(messages: list[dict[str, object]], now: datetime) -> str:
    """The local date of the newest line. A missing or future stamp falls back to the run's date."""
    today = now.astimezone().date()
    newest = max(int(item["timestamp"]) for item in messages)
    try:
        day = datetime.fromtimestamp(newest, tz=now.tzinfo).date()
    except (OverflowError, OSError, ValueError):
        return today.isoformat()
    if day > today or day.year < 2020:
        return today.isoformat()
    return day.isoformat()


def normalize_key(name: str) -> str:
    from eldgrim_agent.store import normalize

    return normalize(name)


def _clear_finished(path: Path, original: bytes, tables: dict[str, Table], cleared: list[str]) -> bool:
    characters = tables.get("EldgrimDB")
    if not isinstance(characters, Table) or not cleared:
        return False
    before = {name: _without_messages(table) for name, table in _named(characters)}
    roster_before = tables.get("EldgrimRoster")
    for name, table in _named(characters):
        if name in cleared:
            empty_messages(table)
    payload = dump_saved(tables).encode("utf-8")
    temporary = path.with_name(path.name + ".eldgrim-tmp")
    try:
        current = path.read_bytes()
        if hashlib.sha256(current).digest() != hashlib.sha256(original).digest():
            return False
        temporary.write_bytes(payload)
        checked = parse_saved(temporary.read_text(encoding="utf-8"))
        _verify_rewrite(checked, before, roster_before, cleared)
        os.replace(temporary, path)
        written = parse_saved(path.read_text(encoding="utf-8"))
        _verify_rewrite(written, before, roster_before, cleared)
        return True
    except (OSError, ValueError):
        return False
    finally:
        temporary.unlink(missing_ok=True)


def _named(characters: Table) -> list[tuple[str, Table]]:
    return [(key, value) for key, value in characters.items if isinstance(key, str) and isinstance(value, Table)]


def _verify_rewrite(tables: dict[str, Table], before: dict, roster_before: Table | None, cleared: list[str]) -> None:
    characters = tables.get("EldgrimDB")
    if not isinstance(characters, Table):
        raise ValueError("EldgrimDB missing after rewrite.")
    found = dict(_named(characters))
    for name in cleared:
        messages = character_messages(found[name])
        if messages:
            raise ValueError("Messages were still present after the clear.")
        if not _same_items(_without_messages(found[name]), before[name]):
            raise ValueError("A profile field changed.")
    if roster_before is not None:
        if dump_saved({"EldgrimRoster": tables.get("EldgrimRoster")}) != dump_saved({"EldgrimRoster": roster_before}):
            raise ValueError("EldgrimRoster changed.")


def _same_items(left: list[tuple[object, object]], right: list[tuple[object, object]]) -> bool:
    if len(left) != len(right):
        return False
    return all(_same(a, c) and _same(b, d) for (a, b), (c, d) in zip(left, right))


def _same(left: object, right: object) -> bool:
    if isinstance(left, Table) and isinstance(right, Table):
        return _same_items(left.items, right.items)
    return left == right
