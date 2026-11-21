"""The run in steps. Every model, bot and guild call is replaced; nothing is posted."""

from __future__ import annotations

import json
import sys
import tempfile
import unittest
from contextlib import ExitStack
from datetime import datetime, timedelta, timezone
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from eldgrim_agent import announce, run
from eldgrim_agent.discord_post import PostError
from eldgrim_agent.refresh import Refresh

STOCKHOLM = timezone(timedelta(hours=1))


class RunStepTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.prepared = self.root / "prepared.json"
        self.calls: list[str] = []
        self.chosen: list[str] = []
        self.overflow: set[str] = set()

    def _start(self, **overrides):
        calls = self.calls

        def refresh(started, ask):
            calls.append("prepare")
            return Refresh(brief="Newcomers: none", note="A note.")

        def compose(started, brief):
            calls.append("announce:" + brief)
            return "Text", self.root / "a.md"

        def fits(task):
            if task in self.overflow:
                raise run.Skipped(f"context overflow. {task}: too large")

        fakes = {
            "_fits": fits,
            "PREPARED_PATH": self.prepared,
            "LOCK_PATH": self.root / "run.lock",
            "ensure_runtime": lambda: None,
            "ensure_server": lambda: calls.append("server"),
            "server_version": lambda: "0.0-test",
            "stop_server": lambda server: None,
            "unload": lambda: None,
            "refresh_guild": refresh,
            "save_last_brief": lambda text: None,
            "_remember_officer": lambda started, note: None,
            "run_daily_quests": lambda started: calls.append("quests") or {},
            "run_daily_replies": lambda started: calls.append("replies") or {},
            "compose": compose,
            "post_file": lambda path, approval: calls.append("posted"),
            "post_officer": lambda note, approval: calls.append("ranks:" + note),
            "_mark_levels": lambda: None,
            "_choose_quietly": lambda started: (started, "model"),
            "save_choice": lambda chosen, source: self.chosen.append(source),
            "_write_log": lambda started, report: None,
        }
        fakes.update(overrides)
        stack = ExitStack()
        for name, value in fakes.items():
            stack.enter_context(patch(f"eldgrim_agent.run.{name}", value))
        self.addCleanup(stack.close)

    def _save_prepared(self, date: str, brief: str = "Saved brief"):
        self.prepared.write_text(
            json.dumps({"date": date, "at": date + "T09:00+01:00", "brief": brief, "note": "Saved note."}),
            encoding="utf-8",
        )

    def test_full_run_does_every_step_in_order(self):
        self._start()
        report = run.execute(scheduled=True)
        self.assertEqual(list(report["steps"]), list(run.STEPS))
        self.assertTrue(all(value == "done" for value in report["steps"].values()))
        self.assertEqual(
            [call for call in self.calls if call != "server"],
            ["prepare", "quests", "replies", "announce:Newcomers: none", "posted", "ranks:A note.", ],
        )
        self.assertEqual(self.calls.count("server"), 1)
        self.assertEqual(report["model"], run.MODEL)
        self.assertEqual(report["ollama_version"], "0.0-test")
        self.assertEqual(self.chosen, ["model"])
        self.assertEqual(report["error"], "")
        saved = json.loads(self.prepared.read_text(encoding="utf-8"))
        self.assertEqual(saved["brief"], "Newcomers: none")

    def test_a_silent_server_is_logged_as_unknown_and_the_summary_names_it(self):
        from eldgrim_agent.cli import _format_run

        self._start(server_version=lambda: None)
        report = run.execute(scheduled=True)
        self.assertEqual(report["ollama_version"], "unknown")
        self.assertIn("Ollama: unknown", _format_run(report))

    def test_the_server_version_is_read_from_the_version_endpoint(self):
        from io import BytesIO
        from eldgrim_agent import ollama

        class Reply(BytesIO):
            def __enter__(self):
                return self

            def __exit__(self, *exc):
                return False

        seen = []

        def opened(url, timeout):
            seen.append(url)
            return Reply(b'{"version": "0.12.3"}')

        with patch("eldgrim_agent.ollama.urllib.request.urlopen", opened):
            self.assertEqual(ollama.server_version(), "0.12.3")
        self.assertEqual(seen, [ollama.HOST + "/api/version"])
        with patch("eldgrim_agent.ollama.urllib.request.urlopen", side_effect=OSError("down")):
            self.assertIsNone(ollama.server_version())

    def test_an_announcement_that_does_not_fit_stops_only_itself(self):
        self.overflow = {"proclamation"}
        self._start()
        report = run.execute(scheduled=True)
        self.assertTrue(report["steps"]["announce"].startswith("skipped: context overflow"))
        for name in ("prepare", "quests", "replies", "ranks", "choose"):
            self.assertEqual(report["steps"][name], "done")
        self.assertFalse(report["posted"])
        self.assertTrue(report["officer_posted"])
        self.assertIn("Announce: skipped", report["error"])

    def test_a_failed_bot_exchange_does_not_stop_the_announcement(self):
        def broken(started):
            raise PostError("bot unreachable")

        self._start(run_daily_quests=broken)
        report = run.execute(scheduled=False)
        self.assertTrue(report["steps"]["quests"].startswith("failed:"))
        self.assertEqual(report["quests"], {"error": "unavailable"})
        self.assertTrue(report["posted"])
        self.assertTrue(report["officer_posted"])

    def test_a_failed_preparation_skips_announce_and_ranks_and_does_not_prepare_twice(self):
        def broken(started, ask):
            self.calls.append("prepare")
            raise OSError("guild file unreadable")

        self._start(refresh_guild=broken)
        report = run.execute(scheduled=True)
        self.assertEqual(self.calls.count("prepare"), 1)
        self.assertTrue(report["steps"]["prepare"].startswith("failed:"))
        self.assertTrue(report["steps"]["announce"].startswith("skipped:"))
        self.assertTrue(report["steps"]["ranks"].startswith("skipped:"))
        self.assertEqual(report["steps"]["quests"], "done")
        self.assertEqual(report["steps"]["replies"], "done")
        self.assertEqual(report["steps"]["choose"], "done")

    def test_one_step_uses_todays_brief_and_leaves_tomorrow_alone(self):
        today = datetime.now().astimezone().date().isoformat()
        self._save_prepared(today)
        self._start()
        report = run.execute(scheduled=False, step="announce")
        self.assertEqual(list(report["steps"]), ["announce"])
        self.assertEqual([call for call in self.calls if call != "server"], ["announce:Saved brief", "posted"])
        self.assertEqual(report["prepared"], today + "T09:00+01:00")
        self.assertEqual(self.chosen, [])
        self.assertEqual(report["next_at"], "")

    def test_one_step_prepares_first_when_the_brief_is_from_another_day(self):
        self._save_prepared("2000-01-01", brief="Old brief")
        self._start()
        report = run.execute(scheduled=False, step="ranks")
        self.assertEqual(list(report["steps"]), ["prepare", "ranks"])
        self.assertEqual(self.calls, ["server", "prepare", "ranks:A note."])

    def test_ranks_alone_does_not_start_the_model(self):
        self._save_prepared(datetime.now().astimezone().date().isoformat())
        self._start()
        run.execute(scheduled=False, step="ranks")
        self.assertEqual(self.calls, ["ranks:Saved note."])

    def test_choose_falls_back_when_its_reading_does_not_fit(self):
        self.overflow = {"choose-moment"}
        self._start()
        report = run.execute(scheduled=False, step="choose")
        self.assertEqual(report["steps"]["choose"], "fallback")
        self.assertEqual(report["next_source"], "fallback")
        self.assertEqual(self.chosen, ["fallback"])
        self.assertNotIn("server", self.calls)

    def test_unknown_step_is_refused(self):
        with self.assertRaises(ValueError):
            run.execute(scheduled=False, step="everything")

    def test_cli_refuses_scheduled_with_one_step(self):
        from eldgrim_agent.cli import main

        with patch("sys.stderr"), self.assertRaises(SystemExit):
            main(["run", "announce", "--scheduled"])


class GuardReasonTests(unittest.TestCase):
    GUARD = ("violet test root",)

    def _guarded(self, *replies):
        answers = iter(replies)
        with patch("eldgrim_agent.announce.chat", lambda messages, **options: next(answers)):
            return announce._guarded([{"role": "user", "content": "x"}], self.GUARD, num_predict=10, num_ctx=100)

    def test_a_retry_that_passes_is_posted(self):
        self.assertEqual(self._guarded("Play to inspire, not to impress.", "A clean fire."), "A clean fire.")

    def test_the_log_names_both_checks(self):
        with self.assertRaises(RuntimeError) as caught:
            self._guarded("Play to inspire, not to impress.", "The violet test root again.")
        message = str(caught.exception)
        self.assertIn("the draft repeated the motto", message)
        self.assertIn("the retry named a private root", message)
        self.assertNotIn("violet", message)

    def test_an_empty_draft_is_not_retried(self):
        with self.assertRaisesRegex(RuntimeError, "the draft was empty"):
            self._guarded("<think>only thinking</think>")


if __name__ == "__main__":
    unittest.main()
