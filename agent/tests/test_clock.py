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
from eldgrim_agent.schedule import render_timer


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

    def test_timer_wakes_once_at_the_chosen_minute(self):
        text = render_timer(datetime(2026, 11, 12, 4, 5, tzinfo=STOCKHOLM))
        self.assertIn("OnCalendar=2026-11-12 04:05:00", text)
        self.assertIn("WakeSystem=true", text)
        self.assertIn("Persistent=false", text)
        self.assertIn("RandomizedDelaySec=0", text)

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

    def test_origin_without_guard_list_refuses_to_compose(self):
        from eldgrim_agent import announce

        with tempfile.TemporaryDirectory() as tmp:
            origin = Path(tmp) / "ORIGIN.md"
            origin.write_text("synthetic roots", encoding="utf-8")
            saved = announce.ORIGIN_PATH, announce.load_guard, announce.chat
            called = []
            announce.ORIGIN_PATH = origin
            announce.load_guard = lambda path=None: ()
            announce.chat = lambda *a, **k: called.append(1) or "text"
            try:
                with self.assertRaises(RuntimeError):
                    announce.compose(NOW)
            finally:
                announce.ORIGIN_PATH, announce.load_guard, announce.chat = saved
            self.assertEqual(called, [])


if __name__ == "__main__":
    unittest.main()
