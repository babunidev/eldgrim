"""Rank recommendations from the private score and overall positivity. Synthetic members only."""

from __future__ import annotations

import sqlite3
import sys
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from eldgrim_agent import store
from eldgrim_agent.officer import render_note
from eldgrim_agent.standing import Recommendation, rank_line, recommend

STOCKHOLM = timezone(timedelta(hours=1))
NOW = datetime(2026, 11, 20, 20, 0, tzinfo=STOCKHOLM)


class StandingTests(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.row_factory = sqlite3.Row
        self.db.executescript(store.SCHEMA)
        store._migrate(self.db)
        self.addCleanup(self.db.close)

    def person(self, name, standing, rank="Ember", *, days=10, negative_days=(), owner=0):
        created = (NOW - timedelta(days=days - 1)).isoformat()
        cursor = self.db.execute(
            "INSERT INTO person (display_name, standing, rank, owner, created, updated) VALUES (?, ?, ?, ?, ?, ?)",
            (name, standing, rank, owner, created, created),
        )
        person_id = cursor.lastrowid
        for day in negative_days:
            when = (NOW - timedelta(days=day)).isoformat()
            self.db.execute(
                "INSERT INTO keyword (person_id, term, polarity, source, created) VALUES (?, 'sharp words', 'negative', 'guild-chat', ?)",
                (person_id, when),
            )
        return person_id

    def test_new_minimums_and_cap(self):
        self.assertEqual(store.RANK_MINIMUM, {"Wayfarer": 60, "Kindler": 90, "Hearthkeeper": 150, "Hearthwarden": 200})
        person = self.person("High", 199)
        self.assertEqual(store.adjust_standing(self.db, person, 5, "test", None, NOW), 1)
        self.assertEqual(self.db.execute("SELECT standing FROM person WHERE id = ?", (person,)).fetchone()[0], 200)

    def test_positivity_counts_member_days_and_each_negative_day_once(self):
        person = self.person("Ten Days", 50, days=10, negative_days=(0, 0, 3))
        self.assertAlmostEqual(store.positivity(self.db, person, NOW), 0.8)
        quiet = self.person("Silent", 50, days=4)
        self.assertEqual(store.positivity(self.db, quiet, NOW), 1.0)

    def test_promotion_needs_the_score_and_75_percent(self):
        self.person("Bright", 61, days=4)  # 100%
        self.person("Mixed", 70, days=4, negative_days=(1,))  # 75%
        self.person("Sharp", 65, days=4, negative_days=(1, 2))  # 50%
        self.person("Low", 59, days=4)
        result = recommend(self.db, {}, reviewed=True, now=NOW)
        self.assertEqual(result.promote, ["Mixed", "Bright"])
        self.assertEqual(result.look, ["Sharp"])
        self.assertEqual(rank_line(result), "Consider Mixed and Bright for promotion.")

    def test_the_days_keyword_no_longer_decides(self):
        bright = self.person("Bright", 61, days=4)
        result = recommend(self.db, {bright: ""}, reviewed=True, now=NOW)
        self.assertEqual(result.promote, ["Bright"])

    def test_demotion_needs_a_low_score_and_under_50_percent(self):
        self.person("Falling", 55, "Wayfarer", days=4, negative_days=(0, 1, 2))  # 25%
        self.person("Below", 55, "Wayfarer", days=4, negative_days=(1, 2))  # 50%
        self.person("Ember Low", 10, days=4, negative_days=(0, 1, 2))
        result = recommend(self.db, {}, reviewed=True, now=NOW)
        self.assertEqual(result.demote, ["Falling"])
        self.assertEqual(result.look, ["Below"])
        self.assertEqual(rank_line(result), "Consider Falling for demotion.")

    def test_hearthwarden_is_in_view_only_at_200_and_the_founder_is_never_named(self):
        self.person("Keeper", 199, "Hearthkeeper", days=4)
        self.person("Founder", 200, "Hearthwarden", owner=1)
        self.assertEqual(recommend(self.db, {}, reviewed=True, now=NOW).promote, [])
        self.db.execute("UPDATE person SET standing = 200 WHERE display_name = 'Keeper'")
        result = recommend(self.db, {}, reviewed=True, now=NOW)
        self.assertEqual(result.promote, ["Keeper"])
        self.assertNotIn("Founder", rank_line(result) + " ".join(result.look))

    def test_note_lines_and_no_score_or_share_printed(self):
        self.person("Bright", 61, days=4)
        self.person("Falling", 55, "Wayfarer", days=4, negative_days=(0, 1, 2))
        note = render_note(recommend(self.db, {}, reviewed=True, now=NOW))
        self.assertIn("Consider Bright for promotion.\nConsider Falling for demotion.", note)
        for private in ("61", "55", "25", "%"):
            self.assertNotIn(private, note)
        self.assertIn("The ranks look in order.", rank_line(Recommendation(reviewed=True)))


if __name__ == "__main__":
    unittest.main()
