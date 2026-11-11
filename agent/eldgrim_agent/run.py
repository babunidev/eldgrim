"""One run: write an announcement, post it through the bot, then choose the next day's moment.

Test runs started by hand post too: posting is part of what a run is tested for.
"""

from __future__ import annotations

import fcntl
import json
from datetime import datetime

from eldgrim_agent.announce import compose
from eldgrim_agent.choose import choose_next
from eldgrim_agent.clock import fallback_moment
from eldgrim_agent.discord_post import PostError, approval_for, post_file
from eldgrim_agent.ollama import OllamaError, ensure_server, stop_server, unload
from eldgrim_agent.paths import LOCK_PATH, LOGS, ensure_runtime
from eldgrim_agent.schedule import save_choice


def execute(*, scheduled: bool) -> dict[str, object]:
    ensure_runtime()
    handle = LOCK_PATH.open("a+")
    try:
        fcntl.flock(handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError as exc:
        handle.close()
        raise RuntimeError("Another Eldgrim run is already in progress.") from exc

    started = datetime.now().astimezone()
    report: dict[str, object] = {
        "started": started.isoformat(timespec="seconds"),
        "scheduled": scheduled,
        "posted": False,
        "announcement": "",
        "error": "",
        "next_at": "",
        "next_source": "",
    }
    server = None
    try:
        try:
            server = ensure_server()
            announcement, path = compose(started)
            report["announcement"] = announcement
            post_file(path, approval=approval_for(scheduled))
            report["posted"] = True
        except (OllamaError, OSError, RuntimeError, PostError) as exc:
            report["error"] = str(exc)
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
            try:
                stop_server(server)
            finally:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)
                handle.close()
    _write_log(started, report)
    return report


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
