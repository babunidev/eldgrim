"""One run: write an announcement locally, then choose the next day's moment."""

from __future__ import annotations

import fcntl
import json
from datetime import datetime

from eldgrim_agent.announce import compose
from eldgrim_agent.choose import choose_next
from eldgrim_agent.ollama import OllamaError, ensure_server, stop_server, unload
from eldgrim_agent.paths import LOCK_PATH, LOGS, ensure_runtime
from eldgrim_agent.schedule import install_system_timer, save_choice


def execute(*, scheduled: bool) -> dict[str, object]:
    ensure_runtime()
    handle = LOCK_PATH.open("a+")
    try:
        fcntl.flock(handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError as exc:
        raise RuntimeError("Another Eldgrim run is already in progress.") from exc
    started = datetime.now().astimezone()
    server = None
    announcement = ""
    error = ""
    try:
        server = ensure_server()
        announcement = compose(started)
    except (OllamaError, OSError, RuntimeError) as exc:
        error = str(exc)
    finally:
        chosen, source = _choose_quietly(started)
        save_choice(chosen, source)
        wake = install_system_timer(chosen)
        unload()
        stop_server(server)
        fcntl.flock(handle.fileno(), fcntl.LOCK_UN)
        handle.close()
    report = {
        "started": started.isoformat(timespec="seconds"),
        "scheduled": scheduled,
        "posted": False,
        "announcement": announcement,
        "error": error,
        "next_at": chosen.isoformat(timespec="minutes"),
        "next_source": source,
        "wake_installed": bool(wake.get("installed")),
        "wake_reason": wake.get("reason", ""),
    }
    log = LOGS / f"run-{started.strftime('%Y%m%dT%H%M%S')}.json"
    log.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    log.chmod(0o600)
    return report


def _choose_quietly(now: datetime) -> tuple[datetime, str]:
    try:
        return choose_next(now)
    except Exception:
        from eldgrim_agent.clock import fallback_moment

        return fallback_moment(now), "fallback"
