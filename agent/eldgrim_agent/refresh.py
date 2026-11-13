"""Open the guild database, refresh it, then hand the run a brief and one officer note."""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

from eldgrim_agent.census import take_census
from eldgrim_agent.chatfile import reduce_chat, saved_path
from eldgrim_agent.officer import render_note
from eldgrim_agent.standing import recommend
from eldgrim_agent.store import connect, upsert_forge


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


def guild_brief(newcomers: list[str], themes: list[str], forge_error: str, chat_skipped: str) -> str:
    """At most 2,000 characters. Extra people and themes are dropped whole, never cut mid-name."""
    names = [str(name).strip() for name in newcomers if str(name).strip()]
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
    while len(_render_brief([], len(names), [], kept_notes)) > BRIEF_LIMIT and kept_notes:
        kept_notes.pop()
    shown: list[str] = []
    waiting = list(names)
    while waiting:
        trial = _render_brief(shown + [waiting[0]], len(waiting) - 1, [], kept_notes)
        if len(trial) <= BRIEF_LIMIT:
            shown.append(waiting.pop(0))
        else:
            break
    shown_themes: list[str] = []
    pending = list(unique)
    while pending:
        trial = _render_brief(shown, len(waiting), shown_themes + [pending[0]], kept_notes)
        if len(trial) <= BRIEF_LIMIT:
            shown_themes.append(pending.pop(0))
        else:
            break
    return _render_brief(shown, len(waiting), shown_themes, kept_notes)


def _render_brief(shown: list[str], omitted: int, shown_themes: list[str], notes: list[str]) -> str:
    if shown or omitted:
        parts = list(shown)
        if omitted:
            parts.append(f"and {omitted} more")
        newcomer_line = "Newcomers: " + ", ".join(parts)
    else:
        newcomer_line = "Newcomers: none"
    if shown_themes:
        theme_line = "Themes, with no name attached: " + ", ".join(shown_themes)
    else:
        theme_line = "Themes, with no name attached: none"
    return "\n".join([newcomer_line, theme_line, *notes])


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
        result.brief = guild_brief(result.newcomers, chat.themes, result.forge_error, chat.skipped)
        result.note = render_note(recommend(db, chat.polarity, reviewed=reviewed), take_census(db, now))
        return result
    finally:
        db.close()
