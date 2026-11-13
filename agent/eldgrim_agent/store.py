"""Eldgrim's guild database. It stays on this computer and never holds raw chat."""

from __future__ import annotations

import hashlib
import json
import sqlite3
import unicodedata
from datetime import datetime
from pathlib import Path

from eldgrim_agent.paths import DATABASE_PATH, ensure_runtime

RANKS = ("Ember", "Wayfarer", "Kindler", "Hearthkeeper", "Hearthwarden")
# Minimum standing before that rank is in view. Ember is the entry rank.
RANK_MINIMUM = {"Wayfarer": 60, "Kindler": 70, "Hearthkeeper": 80, "Hearthwarden": 90}
STARTING_STANDING = 50

SCHEMA = """
CREATE TABLE IF NOT EXISTS person (
    id INTEGER PRIMARY KEY,
    discord_id INTEGER UNIQUE,
    display_name TEXT NOT NULL DEFAULT '',
    fellowship TEXT NOT NULL DEFAULT '',
    standing INTEGER,
    opt_out INTEGER NOT NULL DEFAULT 0,
    owner INTEGER NOT NULL DEFAULT 0,
    rank TEXT NOT NULL DEFAULT '',
    created TEXT NOT NULL,
    updated TEXT NOT NULL,
    left_on TEXT
);
CREATE TABLE IF NOT EXISTS character (
    id INTEGER PRIMARY KEY,
    person_id INTEGER REFERENCES person(id),
    name TEXT NOT NULL,
    faction TEXT,
    race TEXT,
    class_name TEXT,
    zone TEXT,
    level INTEGER,
    game_rank TEXT,
    professions TEXT,
    achievement_points INTEGER,
    link TEXT NOT NULL DEFAULT '',
    in_guild INTEGER NOT NULL DEFAULT 1,
    left_on TEXT,
    last_spoke TEXT,
    census_level INTEGER,
    updated TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS keyword (
    id INTEGER PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES person(id),
    term TEXT NOT NULL,
    polarity TEXT NOT NULL,
    source TEXT NOT NULL,
    created TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS standing_adjustment (
    id INTEGER PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES person(id),
    amount INTEGER NOT NULL,
    rule TEXT NOT NULL,
    keyword_id INTEGER,
    created TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS seen_message (
    hash TEXT PRIMARY KEY
);
CREATE TABLE IF NOT EXISTS roster_snapshot (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    updated TEXT NOT NULL,
    names TEXT NOT NULL,
    applied TEXT NOT NULL
);
"""


def normalize(name: str) -> str:
    return unicodedata.normalize("NFC", name.strip()).casefold()


def connect(path: Path | None = None) -> sqlite3.Connection:
    ensure_runtime()
    target = path or DATABASE_PATH
    target.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(target)
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA foreign_keys = ON")
    db.executescript(SCHEMA)
    _migrate(db)
    db.commit()
    if target.exists():
        try:
            target.chmod(0o600)
        except OSError:
            pass
    return db


def _migrate(db: sqlite3.Connection) -> None:
    """Add columns that a database made by an earlier version lacks."""
    columns = {str(row["name"]) for row in db.execute("PRAGMA table_info(character)").fetchall()}
    if "last_spoke" not in columns:
        db.execute("ALTER TABLE character ADD COLUMN last_spoke TEXT")
    if "census_level" not in columns:
        db.execute("ALTER TABLE character ADD COLUMN census_level INTEGER")


def mark_census_levels(db: sqlite3.Connection) -> None:
    """After the keepers' note is posted, its levels become the baseline for the next note."""
    db.execute("UPDATE character SET census_level = level WHERE level IS NOT NULL")
    db.commit()


def record_spoke(db: sqlite3.Connection, person_id: int, name: str, day: str) -> None:
    """Keep only the date of a character's latest guild-chat line. Never the text."""
    row = _find_character(db, person_id=person_id, name=name)
    if row is None:
        return
    if row["last_spoke"] and str(row["last_spoke"]) >= day:
        return
    db.execute("UPDATE character SET last_spoke = ? WHERE id = ?", (day, int(row["id"])))


def stamp(now: datetime) -> str:
    return now.astimezone().isoformat(timespec="seconds")


def message_hash(name: str, timestamp: int, text: str) -> str:
    payload = "\n".join((unicodedata.normalize("NFC", name), str(timestamp), unicodedata.normalize("NFC", text)))
    return hashlib.sha256(payload.encode()).hexdigest()


def _seed(rank: str) -> int:
    return RANK_MINIMUM.get(rank, STARTING_STANDING)


def upsert_forge(db: sqlite3.Connection, members: list[dict[str, object]], now: datetime) -> list[str]:
    """Attach Discord registration to the in-game member when the character is already known.

    Standing is seeded once, then left alone. A name declared by two Discord members links neither.
    """
    newcomers: list[str] = []
    when = stamp(now)
    claimed: dict[str, set[int]] = {}
    for member in members:
        discord_id = int(member["member"])
        for character in member.get("characters") or []:
            if isinstance(character, dict) and str(character.get("name") or "").strip():
                claimed.setdefault(normalize(str(character["name"])), set()).add(discord_id)
    conflicts = {name for name, ids in claimed.items() if len(ids) > 1}
    for member in members:
        discord_id = int(member["member"])
        display = str(member.get("display_name") or "").strip()
        fellowship = str(member.get("fellowship") or "").strip()
        rank = str(member.get("rank") or "")
        if rank not in RANKS:
            rank = ""
        owner = 1 if member.get("owner") else 0
        characters = [
            character
            for character in (member.get("characters") or [])
            if isinstance(character, dict) and str(character.get("name") or "").strip()
        ]
        holders: list[int] = []
        for character in characters:
            if normalize(str(character["name"])) in conflicts:
                continue
            for row in _characters_named(db, str(character["name"])):
                if not row["person_id"]:
                    continue
                person = person_row(db, int(row["person_id"]))
                if person["discord_id"] and int(person["discord_id"]) != discord_id:
                    continue
                if int(person["id"]) not in holders:
                    holders.append(int(person["id"]))
        existing = db.execute("SELECT id FROM person WHERE discord_id = ?", (discord_id,)).fetchone()
        if existing is not None:
            person_id = int(existing["id"])
        elif holders:
            person_id = holders[0]
        else:
            cursor = db.execute(
                """INSERT INTO person
                   (discord_id, display_name, fellowship, standing, owner, rank, created, updated)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                (discord_id, display, fellowship, _seed(rank or "Ember"), owner, rank or "Ember", when, when),
            )
            person_id = int(cursor.lastrowid)
            if display:
                newcomers.append(display)
        for other in holders:
            _merge_person(db, person_id, other, now)
        current = person_row(db, person_id)
        next_rank = str(current["rank"] or "") or rank or "Ember"
        db.execute(
            """UPDATE person
               SET discord_id = ?, display_name = ?, fellowship = ?, owner = ?, rank = ?, updated = ?
               WHERE id = ?""",
            (
                discord_id,
                display or current["display_name"],
                fellowship or current["fellowship"],
                owner,
                next_rank,
                when,
                person_id,
            ),
        )
        if current["standing"] is None:
            db.execute("UPDATE person SET standing = ? WHERE id = ?", (_seed(next_rank), person_id))
        for character in characters:
            name = str(character["name"]).strip()
            fields = {
                "faction": character.get("faction"),
                "race": character.get("race"),
                "class_name": character.get("class") or character.get("klass"),
            }
            if normalize(name) in conflicts:
                _upsert_character(db, person_id=person_id, name=name, link="declared", fields=fields, now=when)
                continue
            rows = _characters_named(db, name)
            if rows:
                db.execute(
                    "UPDATE character SET person_id = ?, link = 'declared', name = ? WHERE id = ?",
                    (person_id, name, int(rows[0]["id"])),
                )
                for extra in rows[1:]:
                    db.execute("DELETE FROM character WHERE id = ?", (int(extra["id"]),))
            _upsert_character(db, person_id=person_id, name=name, link="declared", fields=fields, now=when)
    db.commit()
    return newcomers


def _find_character(db: sqlite3.Connection, *, person_id: int | None, name: str) -> sqlite3.Row | None:
    key = normalize(name)
    if person_id is None:
        rows = db.execute("SELECT * FROM character WHERE person_id IS NULL").fetchall()
    else:
        rows = db.execute("SELECT * FROM character WHERE person_id = ?", (person_id,)).fetchall()
    for row in rows:
        if normalize(str(row["name"])) == key:
            return row
    return None


def _upsert_character(
    db: sqlite3.Connection,
    *,
    person_id: int | None,
    name: str,
    link: str,
    fields: dict[str, object],
    now: str,
) -> int:
    row = _find_character(db, person_id=person_id, name=name)
    present = {key: value for key, value in fields.items() if value not in (None, "")}
    if row is None:
        columns = ["person_id", "name", "link", "updated", *present.keys()]
        values: list[object] = [person_id, name, link, now, *present.values()]
        placeholders = ", ".join("?" for _ in columns)
        cursor = db.execute(
            f"INSERT INTO character ({', '.join(columns)}) VALUES ({placeholders})",
            values,
        )
        return int(cursor.lastrowid)
    assignments = ["updated = ?"]
    values = [now]
    if link and not row["link"]:
        assignments.append("link = ?")
        values.append(link)
    for key, value in present.items():
        assignments.append(f"{key} = ?")
        values.append(value)
    if row["left_on"] and link == "declared":
        assignments.append("left_on = NULL")
        assignments.append("in_guild = 1")
    values.append(int(row["id"]))
    db.execute(f"UPDATE character SET {', '.join(assignments)} WHERE id = ?", values)
    return int(row["id"])


def link_targets(db: sqlite3.Connection) -> dict[str, int | None]:
    """Map a normalized character name to one person. Two people with the same name link neither."""
    rows = db.execute("SELECT person_id, name FROM character WHERE person_id IS NOT NULL").fetchall()
    people: dict[str, set[int]] = {}
    for row in rows:
        people.setdefault(normalize(str(row["name"])), set()).add(int(row["person_id"]))
    return {name: (next(iter(ids)) if len(ids) == 1 else None) for name, ids in people.items()}


def _higher_rank(left: str, right: str) -> str:
    ranks = [rank for rank in (left, right) if rank in RANKS]
    if not ranks:
        return ""
    return max(ranks, key=RANKS.index)


def _characters_named(db: sqlite3.Connection, name: str) -> list[sqlite3.Row]:
    key = normalize(name)
    return [row for row in db.execute("SELECT * FROM character").fetchall() if normalize(str(row["name"])) == key]


def adopt_rank(db: sqlite3.Connection, person_id: int, rank: str, now: datetime) -> None:
    """Keep the higher guild rank. Standing rises to that floor only before any daily points."""
    if rank not in RANKS:
        return
    person = person_row(db, person_id)
    chosen = _higher_rank(str(person["rank"]), rank) or rank
    when = stamp(now)
    if person["rank"] != chosen:
        db.execute("UPDATE person SET rank = ?, updated = ? WHERE id = ?", (chosen, when, person_id))
    adjustments = db.execute(
        "SELECT COUNT(*) AS n FROM standing_adjustment WHERE person_id = ?",
        (person_id,),
    ).fetchone()
    if adjustments is not None and int(adjustments["n"]) > 0:
        return
    seeded = _seed(chosen)
    current = person["standing"]
    if current is None or int(current) < seeded:
        db.execute("UPDATE person SET standing = ?, updated = ? WHERE id = ?", (seeded, when, person_id))


def ensure_member(db: sqlite3.Connection, name: str, fields: dict[str, object], now: datetime) -> int | None:
    """The in-game guild is the member list. A character is a member before anyone uses the Forge."""
    rows = _characters_named(db, name)
    holders: list[int] = []
    for row in rows:
        if row["person_id"] and int(row["person_id"]) not in holders:
            holders.append(int(row["person_id"]))
    if len(holders) > 1:
        return None
    when = stamp(now)
    rank = str(fields.get("game_rank") or "")
    if holders:
        person_id = holders[0]
        link = ""
        if rank in RANKS:
            adopt_rank(db, person_id, rank, now)
        for row in rows:
            if not row["person_id"]:
                db.execute("DELETE FROM character WHERE id = ?", (int(row["id"]),))
    else:
        use_rank = rank if rank in RANKS else "Ember"
        cursor = db.execute(
            """INSERT INTO person
               (display_name, fellowship, standing, rank, created, updated)
               VALUES (?, '', ?, ?, ?, ?)""",
            (name, _seed(use_rank), use_rank, when, when),
        )
        person_id = int(cursor.lastrowid)
        link = "in-game"
        if rows:
            db.execute(
                """UPDATE character
                   SET person_id = ?, link = CASE WHEN link = '' THEN 'in-game' ELSE link END, updated = ?
                   WHERE id = ?""",
                (person_id, when, int(rows[0]["id"])),
            )
            for extra in rows[1:]:
                db.execute("DELETE FROM character WHERE id = ?", (int(extra["id"]),))
    _upsert_character(db, person_id=person_id, name=name, link=link, fields=fields, now=when)
    return person_id


def _merge_person(db: sqlite3.Connection, keep_id: int, drop_id: int, now: datetime) -> None:
    """Fold an in-game member into the Discord member who later claimed that character."""
    if keep_id == drop_id:
        return
    keep = person_row(db, keep_id)
    drop = person_row(db, drop_id)
    if keep["discord_id"] and drop["discord_id"] and int(keep["discord_id"]) != int(drop["discord_id"]):
        return
    discord_id = keep["discord_id"] or drop["discord_id"]
    display = str(keep["display_name"] or drop["display_name"] or "")
    if drop["discord_id"] and not keep["discord_id"]:
        display = str(drop["display_name"] or display)
    standing_values = [int(value) for value in (keep["standing"], drop["standing"]) if value is not None]
    standing = max(standing_values) if standing_values else None
    db.execute("UPDATE person SET discord_id = NULL WHERE id = ?", (drop_id,))
    db.execute("UPDATE character SET person_id = ? WHERE person_id = ?", (keep_id, drop_id))
    db.execute("UPDATE keyword SET person_id = ? WHERE person_id = ?", (keep_id, drop_id))
    db.execute("UPDATE standing_adjustment SET person_id = ? WHERE person_id = ?", (keep_id, drop_id))
    db.execute(
        """UPDATE person
           SET discord_id = ?, display_name = ?, fellowship = ?, standing = ?, owner = ?, rank = ?, updated = ?
           WHERE id = ?""",
        (
            discord_id,
            display,
            keep["fellowship"] or drop["fellowship"],
            standing,
            1 if keep["owner"] or drop["owner"] else 0,
            _higher_rank(str(keep["rank"]), str(drop["rank"])) or str(keep["rank"] or drop["rank"] or ""),
            stamp(now),
            keep_id,
        ),
    )
    db.execute("DELETE FROM person WHERE id = ?", (drop_id,))


def save_seen_profile(
    db: sqlite3.Connection,
    *,
    name: str,
    person_id: int | None,
    fields: dict[str, object],
    now: datetime,
) -> None:
    """Store profile fields that were actually present. A conflicted name is not given a new row."""
    targets = link_targets(db)
    key = normalize(name)
    when = stamp(now)
    if key in targets and targets[key] is None:
        return
    owner = person_id if person_id is not None else targets.get(key)
    link = "declared" if owner else ""
    _upsert_character(db, person_id=owner, name=name, link=link, fields=fields, now=when)


def person_row(db: sqlite3.Connection, person_id: int) -> sqlite3.Row:
    row = db.execute("SELECT * FROM person WHERE id = ?", (person_id,)).fetchone()
    if row is None:
        raise KeyError(person_id)
    return row


def known_hashes(db: sqlite3.Connection, hashes: list[str]) -> set[str]:
    if not hashes:
        return set()
    placeholders = ", ".join("?" for _ in hashes)
    rows = db.execute(f"SELECT hash FROM seen_message WHERE hash IN ({placeholders})", hashes).fetchall()
    return {str(row["hash"]) for row in rows}


def remember_hashes(db: sqlite3.Connection, hashes: list[str]) -> None:
    db.executemany("INSERT OR IGNORE INTO seen_message (hash) VALUES (?)", [(item,) for item in hashes])


def forget_hashes(db: sqlite3.Connection, hashes: list[str]) -> None:
    db.executemany("DELETE FROM seen_message WHERE hash = ?", [(item,) for item in hashes])


def add_keyword(db: sqlite3.Connection, person_id: int, term: str, polarity: str, now: datetime) -> int:
    cursor = db.execute(
        """INSERT INTO keyword (person_id, term, polarity, source, created)
           VALUES (?, ?, ?, 'guild-chat', ?)""",
        (person_id, term, polarity, stamp(now)),
    )
    return int(cursor.lastrowid)


def adjust_standing(
    db: sqlite3.Connection,
    person_id: int,
    amount: int,
    rule: str,
    keyword_id: int | None,
    now: datetime,
) -> int:
    """Apply a daily point and clamp it to 0–100. The stored amount is what actually changed."""
    row = person_row(db, person_id)
    if row["standing"] is None or row["opt_out"]:
        return 0
    current = int(row["standing"])
    updated = max(0, min(100, current + amount))
    applied = updated - current
    if applied == 0:
        return 0
    db.execute("UPDATE person SET standing = ?, updated = ? WHERE id = ?", (updated, stamp(now), person_id))
    db.execute(
        """INSERT INTO standing_adjustment (person_id, amount, rule, keyword_id, created)
           VALUES (?, ?, ?, ?, ?)""",
        (person_id, applied, rule, keyword_id, stamp(now)),
    )
    return applied


def apply_ingame_roster(
    db: sqlite3.Connection,
    *,
    updated: int,
    names: dict[str, dict[str, object]],
    now: datetime,
) -> list[str]:
    """A newer in-game roster says who is still in the guild. Keywords are kept."""
    current = db.execute("SELECT updated, names FROM roster_snapshot WHERE id = 1").fetchone()
    newer = current is None or int(current["updated"]) < updated
    previous = json.loads(current["names"]) if current is not None else []
    previous_by_key = {normalize(name): name for name in previous}
    when = stamp(now)
    day = now.astimezone().date().isoformat()
    for name, fields in names.items():
        person_id = ensure_member(db, name, fields, now)
        if person_id is None:
            continue
        row = _find_character(db, person_id=person_id, name=name)
        if row is not None and row["left_on"]:
            db.execute(
                "UPDATE character SET left_on = NULL, in_guild = 1, updated = ? WHERE id = ?",
                (when, int(row["id"])),
            )
    departed: list[str] = []
    if newer and current is not None:
        present = {normalize(name) for name in names}
        for key, name in sorted(previous_by_key.items()):
            if key in present:
                continue
            _mark_departed(db, key, day, when)
            departed.append(name)
    if newer:
        payload = json.dumps(sorted(names))
        db.execute(
        """INSERT INTO roster_snapshot (id, updated, names, applied)
           VALUES (1, ?, ?, ?)
           ON CONFLICT(id) DO UPDATE SET updated = excluded.updated, names = excluded.names, applied = excluded.applied""",
        (str(updated), payload, when),
    )
    db.commit()
    return departed


def _person_for_name(db: sqlite3.Connection, name: str) -> int | None:
    target = link_targets(db).get(normalize(name))
    return target or None


def _mark_departed(db: sqlite3.Connection, normalized_name: str, day: str, when: str) -> None:
    rows = db.execute("SELECT id, person_id, name FROM character").fetchall()
    for row in rows:
        if normalize(str(row["name"])) != normalized_name:
            continue
        db.execute(
            "UPDATE character SET left_on = COALESCE(left_on, ?), in_guild = 0, updated = ? WHERE id = ?",
            (day, when, int(row["id"])),
        )
        person_id = row["person_id"]
        if person_id is None:
            continue
        still = db.execute(
            "SELECT COUNT(*) AS n FROM character WHERE person_id = ? AND in_guild = 1",
            (int(person_id),),
        ).fetchone()
        if still is not None and int(still["n"]) == 0:
            db.execute(
                "UPDATE person SET left_on = COALESCE(left_on, ?), updated = ? WHERE id = ?",
                (day, when, int(person_id)),
            )


def set_opt_out(db: sqlite3.Connection, name: str, opted_out: bool) -> str:
    key = normalize(name)
    people = db.execute("SELECT id, display_name FROM person").fetchall()
    matches = [row for row in people if normalize(str(row["display_name"])) == key]
    if not matches:
        characters = db.execute(
            "SELECT person_id, name FROM character WHERE person_id IS NOT NULL"
        ).fetchall()
        ids = {int(row["person_id"]) for row in characters if normalize(str(row["name"])) == key}
        matches = [row for row in people if int(row["id"]) in ids]
    if len(matches) != 1:
        return "No single member matches that name."
    db.execute("UPDATE person SET opt_out = ? WHERE id = ?", (1 if opted_out else 0, int(matches[0]["id"])))
    db.commit()
    state = "opted out" if opted_out else "opted in"
    return f"{matches[0]['display_name'] or name} is {state}."


def summary(db: sqlite3.Connection) -> str:
    """Counts and names for the founder. No chat text and no Discord ids."""
    people = db.execute("SELECT * FROM person ORDER BY display_name COLLATE NOCASE, id").fetchall()
    characters = db.execute("SELECT * FROM character ORDER BY name COLLATE NOCASE, id").fetchall()
    lines = [f"People: {len(people)}", f"Characters: {len(characters)}", ""]
    by_person: dict[int, list[sqlite3.Row]] = {}
    unlinked: list[sqlite3.Row] = []
    for character in characters:
        if character["person_id"] is None:
            unlinked.append(character)
        else:
            by_person.setdefault(int(character["person_id"]), []).append(character)
    for person in people:
        standing = "-" if person["standing"] is None else str(person["standing"])
        flags = []
        if person["opt_out"]:
            flags.append("opted out")
        if person["left_on"]:
            flags.append(f"left {person['left_on']}")
        extra = f" ({', '.join(flags)})" if flags else ""
        lines.append(
            f"{person['display_name'] or '(unnamed)'} — {person['fellowship'] or '-'} — {person['rank'] or '-'} — standing {standing}{extra}"
        )
        keywords = db.execute(
            "SELECT term, polarity FROM keyword WHERE person_id = ? ORDER BY id",
            (int(person["id"]),),
        ).fetchall()
        if keywords:
            lines.append("  keywords: " + "; ".join(f"{row['term']} ({row['polarity']})" for row in keywords))
        for character in by_person.get(int(person["id"]), []):
            lines.append(f"  {character['name']} ({character['link'] or 'unlinked'})")
    if unlinked:
        lines.append("")
        lines.append("Unlinked characters:")
        for character in unlinked:
            lines.append(f"  {character['name']}")
    return "\n".join(lines).rstrip() + "\n"
