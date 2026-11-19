"""Open the guild database, refresh it, then hand the run a brief and one officer note."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

from eldgrim_agent.census import take_census
from eldgrim_agent.chatfile import reduce_chat, saved_path
from eldgrim_agent.officer import render_note
from eldgrim_agent.standing import recommend
from eldgrim_agent.store import connect, normalize, upsert_forge


@dataclass
class Refresh:
    forge_error: str = ""
    chat_error: str = ""
    chat_skipped: str = ""
    brief: str = ""
    note: str = ""
    newcomers: list[str] = field(default_factory=list)
    cleared: list[str] = field(default_factory=list)


BRIEF_LIMIT = 2000


def guild_brief(
    newcomers: list[str],
    themes: list[str],
    forge_error: str,
    chat_skipped: str,
    level_ups: list[str] | None = None,
    quests: list[str] | None = None,
) -> str:
    """At most 2,000 characters. Extra people and themes are dropped whole, never cut mid-name."""
    names = [str(name).strip() for name in newcomers if str(name).strip()]
    levels = [str(item).strip() for item in (level_ups or []) if str(item).strip()]
    done = [str(item).strip() for item in (quests or []) if str(item).strip()]
    unique: list[str] = []
    for theme in themes:
        text = str(theme).strip()
        if text and text not in unique:
            unique.append(text)
        if len(unique) == 5:
            break
    notes: list[str] = []
    if forge_error:
        notes.append("The Forge could not be refreshed in this run.")
    if chat_skipped:
        notes.append("No new guild-chat lines were waiting.")
    kept_notes = list(notes)
    while len(_render_brief([], 0, [], kept_notes, [], 0, [], 0)) > BRIEF_LIMIT and kept_notes:
        kept_notes.pop()
    shown_levels, waiting_levels = _fit(levels, lambda shown, omitted: _render_brief(
        [], 0, [], kept_notes, shown, omitted, [], 0
    ))
    shown_quests, waiting_quests = _fit(done, lambda shown, omitted: _render_brief(
        [], 0, [], kept_notes, shown_levels, len(waiting_levels), shown, omitted
    ))
    shown: list[str] = []
    waiting = list(names)
    while waiting:
        trial = _render_brief(
            shown + [waiting[0]], len(waiting) - 1, [], kept_notes,
            shown_levels, len(waiting_levels), shown_quests, len(waiting_quests),
        )
        if len(trial) <= BRIEF_LIMIT:
            shown.append(waiting.pop(0))
        else:
            break
    shown_themes: list[str] = []
    pending = list(unique)
    while pending:
        trial = _render_brief(
            shown, len(waiting), shown_themes + [pending[0]], kept_notes,
            shown_levels, len(waiting_levels), shown_quests, len(waiting_quests),
        )
        if len(trial) <= BRIEF_LIMIT:
            shown_themes.append(pending.pop(0))
        else:
            break
    return _render_brief(
        shown, len(waiting), shown_themes, kept_notes,
        shown_levels, len(waiting_levels), shown_quests, len(waiting_quests),
    )


def _fit(items: list[str], render) -> tuple[list[str], list[str]]:
    shown: list[str] = []
    waiting = list(items)
    while waiting:
        if len(render(shown + [waiting[0]], len(waiting) - 1)) <= BRIEF_LIMIT:
            shown.append(waiting.pop(0))
        else:
            break
    return shown, waiting


def describe_newcomers(db, names: list[str]) -> list[str]:
    """A new character, and the race and class the record actually holds."""
    described = []
    for name in names:
        row = db.execute(
            """SELECT race, class_name FROM character
               WHERE name = ? ORDER BY in_guild DESC, id DESC LIMIT 1""",
            (name,),
        ).fetchone()
        kind = " ".join(part for part in ((row["race"] if row else None), (row["class_name"] if row else None)) if part)
        described.append(f"{name}, {kind}" if kind else name)
    return described


def level_lines(db, census) -> list[str]:
    """Character names and the two levels. An opted-out member is left out."""
    quiet = _opted_out(db)
    return [
        f"{name} {old} to {new}"
        for name, old, new in census.level_ups
        if normalize(name) not in quiet
    ]


def quest_lines(db) -> list[str]:
    """How many Eldgrim quests each character has completed. The score is not here."""
    quiet = _opted_out(db)
    rows = db.execute(
        """SELECT character_name, COUNT(*) AS n FROM quest
           WHERE status = 'done' GROUP BY character_name
           ORDER BY character_name COLLATE NOCASE"""
    ).fetchall()
    return [
        f"{row['character_name']} {int(row['n'])}"
        for row in rows
        if str(row["character_name"]).strip() and normalize(str(row["character_name"])) not in quiet
    ]


def _opted_out(db) -> set[str]:
    rows = db.execute(
        """SELECT character.name FROM character
           JOIN person ON person.id = character.person_id
           WHERE person.opt_out = 1"""
    ).fetchall()
    return {normalize(str(row["name"])) for row in rows}


def _news(label: str, shown: list[str], omitted: int) -> str:
    if shown or omitted:
        parts = list(shown)
        if omitted:
            parts.append(f"and {omitted} more")
        return f"{label}: " + ", ".join(parts)
    return f"{label}: none"


def _render_brief(
    shown: list[str],
    omitted: int,
    shown_themes: list[str],
    notes: list[str],
    shown_levels: list[str] | None = None,
    omitted_levels: int = 0,
    shown_quests: list[str] | None = None,
    omitted_quests: int = 0,
) -> str:
    if shown_themes:
        theme_line = "Themes, with no name attached: " + ", ".join(shown_themes)
    else:
        theme_line = "Themes, with no name attached: none"
    return "\n".join([
        _news("Newcomers", shown, omitted),
        _news("Level-ups", list(shown_levels or []), omitted_levels),
        _news("Quests completed", list(shown_quests or []), omitted_quests),
        theme_line,
        *notes,
    ])


def pull_forge(runner=None) -> dict[str, object]:
    from eldgrim_agent.discord_post import PostError, control, load_config

    reply = control(load_config(), {"method": "forge_export"}, runner)
    result = reply.get("result")
    if not isinstance(result, dict):
        raise PostError("The Forge export was empty.")
    return result


def refresh_guild(
    now: datetime,
    ask,
    *,
    database: Path | None = None,
    saved: Path | None = None,
    forge=None,
) -> Refresh:
    db = connect(database)
    result = Refresh()
    try:
        reviewed = True
        try:
            payload = forge() if forge is not None else pull_forge()
            members = payload.get("members") if isinstance(payload, dict) else None
            result.newcomers = upsert_forge(db, list(members or []), now)
        except Exception as exc:
            result.forge_error = str(exc)
            reviewed = False
        chat = reduce_chat(db, saved if saved is not None else saved_path(), ask, now)
        result.chat_error = chat.error
        result.chat_skipped = chat.skipped
        result.cleared = list(chat.cleared)
        census = take_census(db, now)
        result.brief = guild_brief(
            describe_newcomers(db, result.newcomers),
            chat.themes,
            result.forge_error,
            chat.skipped,
            level_lines(db, census),
            quest_lines(db),
        )
        result.note = render_note(recommend(db, chat.polarity, reviewed=reviewed), census)
        return result
    finally:
        db.close()
