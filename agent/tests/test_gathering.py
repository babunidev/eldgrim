"""The Sunday gathering point. Synthetic members and a synthetic saved file only."""

from __future__ import annotations

import sys
import tempfile
import unittest
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from eldgrim_agent.chatfile import reduce_chat
from eldgrim_agent.gathering import finished
from eldgrim_agent.lua_saved import parse_saved
from eldgrim_agent.store import connect

STOCKHOLM = ZoneInfo("Europe/Stockholm")
AFTER = datetime(2026, 11, 22, 21, 0, tzinfo=STOCKHOLM)
DURING = datetime(2026, 11, 22, 19, 30, tzinfo=STOCKHOLM)

SAVED = """EldgrimGathering = {
["2026-11-22"] = {
{
["speaker"] = "Ran Estuary",
["kind"] = "say",
["text"] = "What a fire!",
["received"] = 1795372200,
}, -- [1]
{
["speaker"] = "Faenra Greenleaf",
["kind"] = "group",
["received"] = 1795372200,
}, -- [2]
{
["speaker"] = "Ran Estuary",
["kind"] = "group",
["received"] = 1795372210,
}, -- [3]
{
["speaker"] = "Entai Dreamfall",
["kind"] = "group",
["received"] = 1795372200,
["passedBy"] = "Grimaldus Cragblade",
}, -- [4]
{
["speaker"] = "Grimaldus Cragblade",
["kind"] = "group",
["received"] = 1795372200,
["passedBy"] = "Grimaldus Cragblade",
}, -- [5]
},
}
EldgrimRoster = {
["updated"] = 100,
["guild"] = "Amberhearth",
["members"] = {
["Ran Estuary"] = {
["rank"] = "Ember",
},
},
}
"""


class GatheringTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.db = connect(Path(self.tmp.name) / "eldgrim.sqlite3")
        self.addCleanup(self.db.close)
        self.saved = Path(self.tmp.name) / "Eldgrim.lua"
        self.saved.write_text(SAVED, encoding="utf-8")

    def standing(self, name):
        row = self.db.execute(
            """SELECT person.standing FROM person JOIN character ON character.person_id = person.id
               WHERE character.name = ?""",
            (name,),
        ).fetchone()
        return None if row is None else row[0]

    def test_the_hour_ends_at_20_swedish_time_on_a_sunday(self):
        self.assertTrue(finished("2026-11-22", AFTER))
        self.assertFalse(finished("2026-11-22", DURING))
        self.assertFalse(finished("2026-11-21", AFTER), "a Saturday is not a gathering")

    def test_each_member_present_gets_one_point_and_the_day_is_cleared(self):
        outcome = reduce_chat(self.db, self.saved, None, AFTER)
        self.assertEqual(outcome.error, "")
        self.assertEqual(
            outcome.gatherings["2026-11-22"], ["Ran Estuary", "Faenra Greenleaf", "Entai Dreamfall"]
        )
        self.assertEqual(self.standing("Ran Estuary"), 51, "a say line and a group mark are one point")
        self.assertEqual(self.standing("Faenra Greenleaf"), 51)
        self.assertEqual(self.standing("Entai Dreamfall"), 51, "one other member's mark is enough")
        self.assertIsNone(self.standing("Grimaldus Cragblade"), "a member alone cannot witness themselves")
        tables = parse_saved(self.saved.read_text(encoding="utf-8"))
        self.assertEqual(tables["EldgrimGathering"].items, [])
        self.assertIsNotNone(tables["EldgrimRoster"].get("members").get("Ran Estuary"))
        rules = [row[0] for row in self.db.execute("SELECT rule FROM standing_adjustment")]
        self.assertEqual(rules.count("sunday gathering"), 3)

    def test_a_sunday_is_never_counted_twice(self):
        reduce_chat(self.db, self.saved, None, AFTER)
        self.saved.write_text(SAVED, encoding="utf-8")
        reduce_chat(self.db, self.saved, None, AFTER)
        self.assertEqual(self.standing("Ran Estuary"), 51)

    def test_the_hour_still_running_is_left_alone(self):
        outcome = reduce_chat(self.db, self.saved, None, DURING)
        self.assertEqual(outcome.gatherings, {})
        self.assertIsNone(self.standing("Faenra Greenleaf"))
        self.assertIn("2026-11-22", self.saved.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
