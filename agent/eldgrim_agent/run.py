"""One run: write an announcement, post it through the bot, then choose the next day's moment.

Test runs started by hand post too: posting is part of what a run is tested for.
"""

from __future__ import annotations

import fcntl
import json
from contextlib import contextmanager
from datetime import datetime

from eldgrim_agent.announce import compose
from eldgrim_agent.choose import choose_next
from eldgrim_agent.clock import fallback_moment
from eldgrim_agent.context import preflight, save_last_brief, take_records
from eldgrim_agent.discord_post import PostError, approval_for, post_file, post_officer
from eldgrim_agent.keywords import ask_keyword
from eldgrim_agent.ollama import OllamaError, ensure_server, stop_server, unload
from eldgrim_agent.paths import LOCK_PATH, LOGS, OFFICER_NOTES, ensure_runtime
from eldgrim_agent.refresh import refresh_guild
from eldgrim_agent.schedule import save_choice

# The live calls keep the full reading until the comparison is approved.
# Approved by the creative on 2026-11-13 after two blind comparisons.
CONTEXT_SWITCHED = True


@contextmanager
def hold_run_lock():
    """The same lock a scheduled run takes. A second run, or a comparison, waits outside."""
    ensure_runtime()
    handle = LOCK_PATH.open("a+")
    try:
        fcntl.flock(handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError as exc:
        handle.close()
        raise RuntimeError("Another Eldgrim run is already in progress.") from exc
    try:
        yield
    finally:
        fcntl.flock(handle.fileno(), fcntl.LOCK_UN)
        handle.close()


def execute(*, scheduled: bool) -> dict[str, object]:
    with hold_run_lock():
        return _execute_locked(scheduled)


def _execute_locked(scheduled: bool) -> dict[str, object]:
    started = datetime.now().astimezone()
    report: dict[str, object] = {
        "started": started.isoformat(timespec="seconds"),
        "scheduled": scheduled,
        "posted": False,
        "announcement": "",
        "officer_posted": False,
        "error": "",
        "next_at": "",
        "next_source": "",
        "context": [],
    }
    server = None
    try:
        try:
            if CONTEXT_SWITCHED:
                blocked = preflight(started)
                if blocked is not None:
                    report.update(blocked)
                    return report
            server = ensure_server()
            refreshed = refresh_guild(started, ask_keyword)
            save_last_brief(refreshed.brief)
            _remember_officer(started, refreshed.note)
            if refreshed.forge_error:
                report["forge"] = refreshed.forge_error
            if refreshed.chat_error:
                report["chat"] = refreshed.chat_error
            try:
                announcement, path = compose(started, brief=refreshed.brief)
                report["announcement"] = announcement
                post_file(path, approval=approval_for(scheduled))
                report["posted"] = True
            except (OllamaError, OSError, RuntimeError, PostError) as exc:
                report["error"] = _join(str(report["error"]), str(exc))
            try:
                post_officer(refreshed.note, approval=approval_for(scheduled, officer=True))
                report["officer_posted"] = True
                _mark_levels()
            except (OSError, PostError) as exc:
                report["error"] = _join(str(report["error"]), f"Officer note: {exc}")
        except (OllamaError, OSError, RuntimeError, PostError) as exc:
            report["error"] = _join(str(report["error"]), str(exc))
        try:
            chosen, source = _choose_quietly(started)
            save_choice(chosen, source)
            report["next_at"] = chosen.isoformat(timespec="minutes")
            report["next_source"] = source
        except OSError as exc:
            report["error"] = (str(report["error"]) + "; " if report["error"] else "") + f"could not save next moment: {exc}"
    finally:
        try:
            unload()
        finally:
            stop_server(server)
            report["context"] = list(report.get("context") or []) + take_records()
            _write_log(started, report)
    return report


def _mark_levels() -> None:
    from eldgrim_agent.store import connect, mark_census_levels

    try:
        db = connect()
    except Exception:
        return
    try:
        mark_census_levels(db)
    finally:
        db.close()


def _join(left: str, right: str) -> str:
    if left and right:
        return left + "; " + right
    return left or right


def _remember_officer(started: datetime, note: str) -> None:
    OFFICER_NOTES.mkdir(parents=True, exist_ok=True)
    path = OFFICER_NOTES / f"{started.astimezone().strftime('%Y%m%dT%H%M%S')}.md"
    path.write_text(note.strip() + "\n", encoding="utf-8")
    path.chmod(0o600)


def _write_log(started: datetime, report: dict[str, object]) -> None:
    try:
        log = LOGS / f"run-{started.strftime('%Y%m%dT%H%M%S')}.json"
        log.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        log.chmod(0o600)
    except OSError:
        pass


def _choose_quietly(now: datetime) -> tuple[datetime, str]:
    try:
        return choose_next(now)
    except Exception:
        return fallback_moment(now), "fallback"
