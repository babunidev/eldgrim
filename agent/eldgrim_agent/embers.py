"""Witnessed weekly embers.

An ember is completed only through Discord: a picture in the Eldgrim channel
that mentions Eldgrim and says ember, and a Roar on it from another Amberhearth
member. The bot stages that proof with the character it is for. This run
records the character for the ember's week, adds one standing point per member
per week, and writes EldgrimVerified.lua into the installed addon on this
computer. Jasmine Amberbrew's client reads that file at login and sends the
list to the guild.

Only the character name, the week, and the member's local id are kept. No
message, picture, or Discord identifier goes into the addon file.
"""

from __future__ import annotations

import os
import re
import tempfile
from datetime import datetime
from pathlib import Path

from eldgrim_agent.chatfile import saved_path
from eldgrim_agent.store import adjust_standing, normalize, stamp

DAY = 86400
# A picture whose character was never chosen is dropped after this long.
CHOICE_WAIT = 7 * DAY
# The addon keeps the current ember and four before it.
KEEP_WEEKS = 6
VERIFIED_NAME = "EldgrimVerified.lua"
NAME = re.compile(r"^[^\x00-\x1f\"\\\\]{1,80}$")

SCHEMA = """
CREATE TABLE IF NOT EXISTS ember_done (
    id INTEGER PRIMARY KEY,
    week INTEGER NOT NULL,
    character_name TEXT NOT NULL,
    person_id INTEGER NOT NULL REFERENCES person(id),
    created TEXT NOT NULL,
    UNIQUE (week, character_name)
);
"""


def week_end(posted: float) -> int:
    """The first Sunday 00:00 UTC strictly after this moment, as the addon counts weeks."""
    day = int(posted // DAY)
    weekday = (day + 4) % 7  # 0 is Sunday
    ahead = (7 - weekday) % 7 or 7
    return (day + ahead) * DAY


def _person(db, discord_id: int):
    return db.execute("SELECT * FROM person WHERE discord_id = ?", (int(discord_id),)).fetchone()


def _names(db, person_id: int) -> list[str]:
    rows = db.execute(
        """SELECT name FROM character
           WHERE person_id = ? AND in_guild = 1 AND (left_on IS NULL OR left_on = '')
           ORDER BY name COLLATE NOCASE""",
        (person_id,),
    ).fetchall()
    return [str(row["name"]) for row in rows]


def settle_ember(db, proof: dict, now: datetime) -> str:
    """Record one ember proof.

    Returns "recorded", "known" (already recorded), "refused", or "wait" when
    the member has several characters and has not chosen one yet. A "wait"
    proof is left staged for the next run.
    """
    db.executescript(SCHEMA)
    if proof["author"] == proof["witness"]:
        return "refused"
    person = _person(db, proof["author"])
    witness = _person(db, proof["witness"])
    if person is None or witness is None or str(witness["fellowship"] or "") != "Amberhearth":
        return "refused"
    names = _names(db, int(person["id"]))
    wanted = normalize(proof.get("character") or "")
    name = next((item for item in names if normalize(item) == wanted), None) if wanted else None
    if name is None and not wanted and len(names) == 1:
        name = names[0]
    posted = float(proof.get("posted") or 0) or now.timestamp()
    if name is None:
        if not wanted and len(names) > 1 and now.timestamp() - posted < CHOICE_WAIT:
            return "wait"
        return "refused"
    if not NAME.match(name):
        return "refused"
    week = week_end(posted)
    already = db.execute(
        "SELECT 1 FROM ember_done WHERE week = ? AND character_name = ?",
        (week, name),
    ).fetchone()
    if already is not None:
        return "known"
    earlier = db.execute(
        "SELECT 1 FROM ember_done WHERE week = ? AND person_id = ?",
        (week, int(person["id"])),
    ).fetchone()
    db.execute(
        "INSERT INTO ember_done (week, character_name, person_id, created) VALUES (?, ?, ?, ?)",
        (week, name, int(person["id"]), stamp(now)),
    )
    if earlier is None:
        adjust_standing(db, int(person["id"]), 1, "witnessed ember", None, now)
    return "recorded"


def verified_path(saved: Path | None = None) -> Path | None:
    """EldgrimVerified.lua in the installed addon, beside the SavedVariables this run reads."""
    override = os.environ.get("ELDGRIM_VERIFIED", "").strip()
    if override:
        return Path(override)
    saved = saved_path(saved)
    if saved is None:
        return None
    # <game>/WTF/Account/<account>/SavedVariables/Eldgrim.lua
    try:
        game = saved.parents[4]
    except IndexError:
        return None
    addon = game / "Interface" / "AddOns" / "Eldgrim"
    if not addon.is_dir():
        return None
    return addon / VERIFIED_NAME


def _lua_string(text: str) -> str:
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def render(db, now: datetime) -> str:
    db.executescript(SCHEMA)
    since = week_end(now.timestamp()) - KEEP_WEEKS * 7 * DAY
    rows = db.execute(
        """SELECT id, week, character_name FROM ember_done
           WHERE week > ? ORDER BY week, character_name COLLATE NOCASE""",
        (since,),
    ).fetchall()
    top = db.execute("SELECT COALESCE(MAX(id), 0) AS n FROM ember_done").fetchone()
    lines = [
        "-- Written by Eldgrim's daily run. Do not edit by hand.",
        "-- Characters whose ember picture was Roared by another Amberhearth member.",
        "-- week is the Sunday 00:00 UTC that ember's week ends.",
        "",
        "EldgrimVerifiedFile = {",
        f"    revision = {int(top['n'])},",
        "    embers = {",
    ]
    for row in rows:
        name = str(row["character_name"])
        if NAME.match(name):
            lines.append(f"        {{ week = {int(row['week'])}, name = {_lua_string(name)} }},")
    lines += ["    },", "}", ""]
    return "\n".join(lines)


def write_verified(db, now: datetime, path: Path | None = None) -> bool:
    """Write the file when its content changed. False when there is no installed addon."""
    target = path or verified_path()
    if target is None:
        return False
    text = render(db, now)
    if target.is_file() and target.read_text(encoding="utf-8") == text:
        return True
    target.parent.mkdir(parents=True, exist_ok=True)
    handle, temporary = tempfile.mkstemp(dir=target.parent, prefix=".eldgrim-verified-")
    try:
        with os.fdopen(handle, "w", encoding="utf-8") as stream:
            stream.write(text)
        os.chmod(temporary, 0o644)
        os.replace(temporary, target)
    except BaseException:
        Path(temporary).unlink(missing_ok=True)
        raise
    return True
