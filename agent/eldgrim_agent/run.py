"""Eldgrim's daily run, in steps.

`eldgrim run` does every step in order. `eldgrim run STEP` does only that step. A step that
fails, or whose reading does not fit its window, is logged, and the steps after it still run.
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
from eldgrim_agent.context import find_problems, save_last_brief, take_records
from eldgrim_agent.discord_post import PostError, approval_for, post_file, post_officer
from eldgrim_agent.keywords import ask_keyword
from eldgrim_agent.mentions import run_daily_replies
from eldgrim_agent.ollama import OllamaError, ensure_server, server_version, stop_server, unload
from eldgrim_agent.paths import LOCK_PATH, LOGS, MODEL, OFFICER_NOTES, PREPARED_PATH, ensure_runtime
from eldgrim_agent.quests import run_daily_quests
from eldgrim_agent.refresh import refresh_guild
from eldgrim_agent.schedule import save_choice

# The live calls keep the full reading until the comparison is approved.
# Approved by the creative on 2026-11-13 after two blind comparisons.
CONTEXT_SWITCHED = True

# The order of a full run. Quests also write the witnessed embers for the addon.
STEPS = ("prepare", "quests", "replies", "announce", "ranks", "choose")
STEP_HELP = {
    "prepare": "read the Forge roster and the addon's guild chat, write keywords and standing, save today's brief",
    "quests": "settle quest asks and cancels staged on the bot, and write the witnessed embers",
    "replies": "answer the members who mentioned Eldgrim",
    "announce": "write and post the proclamation from today's brief",
    "ranks": "post today's note for the Hearth Keepers: ranks, people to look at, the census",
    "choose": "choose tomorrow's moment for the wake timer",
}
# The task whose window a step measures before it calls the model.
# Quests and replies measure each call themselves and skip one that does not fit.
STEP_TASK = {"prepare": "chat-keyword", "announce": "proclamation", "choose": "choose-moment"}
BOT_ERRORS = (OSError, PostError, RuntimeError)
STEP_ERRORS = (OllamaError, OSError, RuntimeError, PostError)


class Skipped(Exception):
    """The step did not start. The reason is logged."""


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


def execute(*, scheduled: bool, step: str | None = None) -> dict[str, object]:
    if step is not None and step not in STEPS:
        raise ValueError(f"Unknown step: {step}")
    with hold_run_lock():
        return _execute_locked(scheduled, step)


class _Run:
    def __init__(self, started: datetime, scheduled: bool, report: dict[str, object]) -> None:
        self.started = started
        self.scheduled = scheduled
        self.report = report
        self.prepared: dict[str, str] | None = None
        self._server = None
        self._model = False

    def model(self) -> None:
        """Start Ollama once, for the first step that needs the model."""
        if not self._model:
            self._server = ensure_server()
            self._model = True
            # Evidence for the run log: the model tag and the Ollama server that ran it.
            self.report["model"] = MODEL
            self.report["ollama_version"] = server_version() or "unknown"

    def close(self) -> None:
        if not self._model:
            return
        try:
            unload()
        finally:
            stop_server(self._server)

    def do(self, name: str) -> None:
        steps = self.report["steps"]
        if name in steps:
            return
        try:
            steps[name] = STEP_FUNCTIONS[name](self) or "done"
        except Skipped as exc:
            steps[name] = f"skipped: {exc}"
            self.problem(name, f"skipped, {exc}")
        except STEP_ERRORS as exc:
            steps[name] = f"failed: {exc}"
            self.problem(name, str(exc))

    def problem(self, name: str, text: str) -> None:
        self.report["error"] = _join(str(self.report["error"]), f"{name.capitalize()}: {text}")

    def today(self) -> dict[str, str]:
        """Today's brief and note: from this run, from earlier today, or prepared now."""
        if self.prepared is not None:
            return self.prepared
        if "prepare" not in self.report["steps"]:
            saved = _load_prepared(self.started)
            if saved is not None:
                self.prepared = saved
                self.report["prepared"] = saved["at"]
                return saved
            self.do("prepare")
        if self.prepared is None:
            raise Skipped("today's guild information could not be prepared")
        return self.prepared


def _execute_locked(scheduled: bool, step: str | None) -> dict[str, object]:
    started = datetime.now().astimezone()
    report: dict[str, object] = {
        "started": started.isoformat(timespec="seconds"),
        "scheduled": scheduled,
        "step": step or "all",
        "steps": {},
        "posted": False,
        "announcement": "",
        "officer_posted": False,
        "error": "",
        "model": "",
        "ollama_version": "",
        "next_at": "",
        "next_source": "",
        "context": [],
    }
    run = _Run(started, scheduled, report)
    try:
        for name in (step,) if step else STEPS:
            run.do(name)
    finally:
        try:
            run.close()
        finally:
            report["context"] = list(report.get("context") or []) + take_records()
            _write_log(started, report)
    return report


def _fits(task: str) -> None:
    """Measure one task's reading before the model is called. Other tasks do not stop this one."""
    if not CONTEXT_SWITCHED:
        return
    problems = find_problems(tasks=(task,))
    if problems:
        raise Skipped("context overflow. " + " ".join(problems))


def _prepare(run: _Run) -> str:
    _fits(STEP_TASK["prepare"])
    run.model()
    refreshed = refresh_guild(run.started, ask_keyword)
    save_last_brief(refreshed.brief)
    _remember_officer(run.started, refreshed.note)
    if refreshed.forge_error:
        run.report["forge"] = refreshed.forge_error
    if refreshed.chat_error:
        run.report["chat"] = refreshed.chat_error
    run.prepared = {
        "date": run.started.date().isoformat(),
        "at": run.started.isoformat(timespec="minutes"),
        "brief": refreshed.brief,
        "note": refreshed.note,
    }
    _save_prepared(run.prepared)
    run.report["prepared"] = run.prepared["at"]
    return "done"


def _quests(run: _Run) -> str:
    run.model()
    try:
        run.report["quests"] = run_daily_quests(run.started)
    except BOT_ERRORS as exc:
        run.report["quests"] = {"error": "unavailable"}
        raise RuntimeError(f"the bot exchange failed ({exc})") from exc
    return "done"


def _replies(run: _Run) -> str:
    run.model()
    try:
        run.report["reply"] = run_daily_replies(run.started)
    except BOT_ERRORS as exc:
        run.report["reply"] = {"error": "unavailable"}
        raise RuntimeError(f"the bot exchange failed ({exc})") from exc
    return "done"


def _announce(run: _Run) -> str:
    brief = run.today()["brief"]
    _fits(STEP_TASK["announce"])
    run.model()
    announcement, path = compose(run.started, brief=brief)
    run.report["announcement"] = announcement
    post_file(path, approval=approval_for(run.scheduled))
    run.report["posted"] = True
    return "done"


def _ranks(run: _Run) -> str:
    note = run.today()["note"]
    post_officer(note, approval=approval_for(run.scheduled, officer=True))
    run.report["officer_posted"] = True
    _mark_levels()
    return "done"


def _choose(run: _Run) -> str:
    try:
        _fits(STEP_TASK["choose"])
        run.model()
        chosen, source = _choose_quietly(run.started)
    except (Skipped, OllamaError) as exc:
        run.problem("choose", f"used the fallback, {exc}")
        chosen, source = fallback_moment(run.started), "fallback"
    save_choice(chosen, source)
    run.report["next_at"] = chosen.isoformat(timespec="minutes")
    run.report["next_source"] = source
    return "done" if source == "model" else "fallback"


STEP_FUNCTIONS = {
    "prepare": _prepare,
    "quests": _quests,
    "replies": _replies,
    "announce": _announce,
    "ranks": _ranks,
    "choose": _choose,
}


def _save_prepared(prepared: dict[str, str]) -> None:
    PREPARED_PATH.write_text(json.dumps(prepared, ensure_ascii=False) + "\n", encoding="utf-8")
    PREPARED_PATH.chmod(0o600)


def _load_prepared(now: datetime) -> dict[str, str] | None:
    """Only a brief from today's local date. An older one would announce stale news."""
    try:
        saved = json.loads(PREPARED_PATH.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None
    if not isinstance(saved, dict) or saved.get("date") != now.date().isoformat():
        return None
    if not all(isinstance(saved.get(key), str) for key in ("at", "brief", "note")):
        return None
    return {key: saved[key] for key in ("date", "at", "brief", "note")}


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
