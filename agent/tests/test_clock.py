"""The next-day choice accepts one moment tomorrow and rejects every other stamp."""

from __future__ import annotations

import sys
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path
from random import SystemRandom

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import tempfile

from eldgrim_agent.announce import discloses_roots, load_guard, repeats_motto, strip_thinking
from eldgrim_agent.clock import fallback_moment, parse_choice


STOCKHOLM = timezone(timedelta(hours=1))
NOW = datetime(2026, 11, 11, 2, 40, tzinfo=STOCKHOLM)


class ClockTests(unittest.TestCase):
    def test_tomorrow_is_accepted(self):
        chosen = parse_choice("2026-11-12 04:05", NOW)
        self.assertEqual(chosen, datetime(2026, 11, 12, 4, 5, tzinfo=STOCKHOLM))

    def test_today_and_the_day_after_are_rejected(self):
        self.assertIsNone(parse_choice("2026-11-11 18:00", NOW))
        self.assertIsNone(parse_choice("2026-11-13 18:00", NOW))

    def test_prose_around_a_valid_stamp_is_accepted(self):
        chosen = parse_choice("I will act at 2026-11-12 23:59, after the fire.", NOW)
        self.assertEqual(chosen.hour, 23)
        self.assertEqual(chosen.minute, 59)

    def test_fallback_lands_on_the_next_calendar_day(self):
        chosen = fallback_moment(NOW, SystemRandom(7))
        self.assertEqual(chosen.date().isoformat(), "2026-11-12")

    def test_root_helper_accepts_only_a_near_future_timestamp(self):
        import json
        import subprocess
        from datetime import datetime as dt

        helper = Path(__file__).resolve().parents[1] / "systemd" / "eldgrim-wake-helper"
        soon = (dt.now().astimezone() + timedelta(hours=20)).replace(second=0, microsecond=0)
        cases = {
            "valid": (json.dumps({"at": soon.isoformat(timespec="minutes")}), soon.strftime("%Y-%m-%d %H:%M:00")),
            "past": (json.dumps({"at": "2020-01-01T03:00+01:00"}), None),
            "far": (json.dumps({"at": (soon + timedelta(days=5)).isoformat(timespec="minutes")}), None),
            "junk": ('{"at": "tomorrow; rm -rf /"}', None),
            "inject": ('{"at": "$(touch /tmp/x)2026-11-12T03:00"}', None),
        }
        with tempfile.TemporaryDirectory() as tmp:
            for name, (body, expected) in cases.items():
                path = Path(tmp) / f"{name}.json"
                path.write_text(body, encoding="utf-8")
                done = subprocess.run(
                    ["bash", str(helper), "stamp", str(path)], capture_output=True, text=True, timeout=10
                )
                if expected is None:
                    self.assertNotEqual(done.returncode, 0, name)
                else:
                    self.assertEqual(done.returncode, 0, done.stdout + done.stderr)
                    self.assertEqual(done.stdout.strip(), expected)

    def test_idle_and_sleep_blocks_are_named(self):
        import subprocess

        helper = Path(__file__).resolve().parents[1] / "systemd" / "eldgrim-wake-helper"
        listing = (
            "falcond 0 root 1 systemd-inhibit idle Game profile active block\n"
            "PowerDevil 1000 u 2 org_kde_powerde handle-power-key:handle-suspend-key:handle-lid-switch KDE handles power events block\n"
            "NetworkManager 0 root 3 NetworkManager sleep NetworkManager needs to turn off networks delay\n"
            "Eldgrim 0 root 4 systemd-inhibit idle:sleep:handle-lid-switch Eldgrim daily run block\n"
        )
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "list.txt"
            path.write_text(listing, encoding="utf-8")
            env = {"PATH": "/usr/bin:/bin", "ELDGRIM_INHIBIT_LIST": str(path)}
            done = subprocess.run(["bash", str(helper), "blockers"], capture_output=True, text=True, env=env, timeout=10)
            self.assertEqual(done.stdout.split(), ["falcond"])
            path.write_text(listing + "obs 1000 u 5 obs sleep Recording block\n", encoding="utf-8")
            done = subprocess.run(["bash", str(helper), "blockers"], capture_output=True, text=True, env=env, timeout=10)
            self.assertEqual(done.stdout.split(), ["falcond", "obs"])

    def test_a_resume_logged_after_the_unit_starts_still_counts(self):
        import subprocess
        import threading
        import time

        helper = Path(__file__).resolve().parents[1] / "systemd" / "eldgrim-wake-helper"
        with tempfile.TemporaryDirectory() as tmp:
            log = Path(tmp) / "sleep.log"
            log.write_text(f"{time.time() - 3600:.6f} pc systemd-sleep[1]: Performing sleep operation 'suspend'...\n", encoding="utf-8")
            state = Path(tmp) / "state"
            env = {"PATH": "/usr/bin:/bin", "ELDGRIM_SLEEP_LOG": str(log), "ELDGRIM_STATE_DIR": str(state), "ELDGRIM_SETTLE_SECONDS": "6"}

            def resume_later():
                time.sleep(2)
                with log.open("a", encoding="utf-8") as f:
                    f.write(f"{time.time():.6f} pc systemd-sleep[1]: System returned from sleep operation 'suspend'.\n")

            threading.Thread(target=resume_later).start()
            done = subprocess.run(["bash", str(helper), "begin"], capture_output=True, text=True, env=env, timeout=20)
            self.assertIn("resumed from sleep", done.stdout)
            self.assertTrue((state / "woken").is_file())

            log.write_text(f"{time.time() - 3600:.6f} pc systemd-sleep[1]: System returned from sleep operation 'suspend'.\n", encoding="utf-8")
            env["ELDGRIM_SETTLE_SECONDS"] = "2"
            done = subprocess.run(["bash", str(helper), "begin"], capture_output=True, text=True, env=env, timeout=20)
            self.assertIn("already awake", done.stdout)
            self.assertFalse((state / "woken").exists())

    def test_private_roots_are_rejected_and_thinking_is_removed(self):
        # Synthetic phrases only. The real list is private and never appears here.
        guard = ("silver lantern", "hidden door")
        self.assertTrue(discloses_roots("Through the Hidden Door, a word.", guard))
        self.assertFalse(discloses_roots("Keep the fire.", guard))
        self.assertTrue(repeats_motto("Play to inspire, not to impress."))
        self.assertFalse(repeats_motto("The hearth is lit in Elwynn."))
        self.assertEqual(strip_thinking("<think>secret</think>\nKeep the fire."), "Keep the fire.")

    def test_guard_list_is_read_from_a_private_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "GUARD.txt"
            self.assertEqual(load_guard(path), ())
            path.write_text("# comment\n\nSilver Lantern\nhidden door\n", encoding="utf-8")
            self.assertEqual(load_guard(path), ("silver lantern", "hidden door"))

    def test_a_proclamation_reads_its_self_and_the_approved_pages(self):
        from unittest.mock import patch

        from eldgrim_agent.announce import STANDING, WRITE
        from eldgrim_agent.context import build

        with tempfile.TemporaryDirectory() as tmp, \
                patch("eldgrim_agent.paths.ORIGIN_PATH", Path(tmp) / "absent-origin.md"):
            built = build("proclamation", data="Newcomers: none", system=STANDING, instruction=WRITE)
        names = [page.name for page in built.pages]
        self.assertEqual(names[0], "character/SELF.md")
        for name in ("character/VOICE.md", "governance/15-proposed-priority-hierarchy.md",
                     "agent/CAPABILITIES.md", "governance/09-sunday-gatherings.md"):
            self.assertIn(name, names)
        for name in ("governance/QUESTION-DECISIONS.md", "governance/CONSISTENCY-AUDIT.md",
                     "governance/10-moderation-and-discipline.md"):
            self.assertNotIn(name, names)
        self.assertIn("Attendance is always voluntary", built.messages[1]["content"])

    def test_origin_without_guard_list_refuses_to_compose(self):
        from unittest.mock import patch

        from eldgrim_agent import announce

        with tempfile.TemporaryDirectory() as tmp:
            origin = Path(tmp) / "ORIGIN.md"
            origin.write_text("synthetic roots", encoding="utf-8")
            called = []
            with patch("eldgrim_agent.paths.ORIGIN_PATH", origin), \
                    patch("eldgrim_agent.paths.GUARD_PATH", Path(tmp) / "absent-guard.txt"), \
                    patch("eldgrim_agent.announce.chat", lambda *a, **k: called.append(1) or "text"):
                with self.assertRaises(RuntimeError):
                    announce.compose(NOW)
            self.assertEqual(called, [])


if __name__ == "__main__":
    unittest.main()
