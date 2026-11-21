"""The places a quest may name. The real world page, and a synthetic one."""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from eldgrim_agent.world import allowed, named_outside, read, world_text

PAGE = """# World

Opening rules.

## Cities

| City | Side | Levels | Land |
| --- | --- | --- | --- |
| Stormwind | Alliance | 10 | Stone |
| Orgrimmar | Horde | 10 | Canyon |

## Eastern Kingdoms

| Place | Levels | Side | Land |
| --- | --- | --- | --- |
| Elwynn Forest | 5–10 | Alliance | Woods |
| Duskwood | 10–28 | — | Gloom |
| Burning Steppes | 50–59 | — | Ash |
| Blackrock Mountain | — | — | A volcano |

A note about the lands.

## Dungeons

| Dungeon | Levels | Side | Door | Group |
| --- | --- | --- | --- | --- |
| The Deadmines | 16 | Alliance | Westfall | 5 |
| Ragefire Chasm | 13 | Horde | Orgrimmar | 5 |

## Raids

| Raid | Levels | Group | Door |
| --- | --- | --- | --- |
| Molten Core | 60 | 40 | Burning Steppes |
"""


class WorldTests(unittest.TestCase):
    def setUp(self):
        self.path = Path(tempfile.mkdtemp()) / "WORLD.md"
        self.path.write_text(PAGE, encoding="utf-8")
        self.sections, self.places = read(self.path)

    def test_a_level_and_a_side_choose_the_places(self):
        names = allowed(self.places, 12, "Alliance")
        self.assertEqual(names, {"Stormwind", "Elwynn Forest", "Duskwood"})
        self.assertIn("The Deadmines", allowed(self.places, 16, "Alliance"))
        self.assertIn("Ragefire Chasm", allowed(self.places, 16, "Horde"))
        self.assertNotIn("Ragefire Chasm", allowed(self.places, 60, "Alliance"))

    def test_a_city_is_always_allowed_and_a_raid_or_a_row_with_no_level_never(self):
        self.assertIn("Stormwind", allowed(self.places, 1, "Alliance"))
        for level in (None, 60):
            self.assertNotIn("Molten Core", allowed(self.places, level, "Alliance"))
            self.assertNotIn("Blackrock Mountain", allowed(self.places, level, "Alliance"))

    def test_an_unknown_level_or_side_keeps_every_band_or_side(self):
        names = allowed(self.places, None, "")
        self.assertIn("Burning Steppes", names)
        self.assertIn("Orgrimmar", names)

    def test_the_text_keeps_section_notes_and_only_allowed_rows(self):
        text = world_text(self.sections, self.places, allowed(self.places, 12, "Alliance"))
        self.assertIn("### Eastern Kingdoms", text)
        self.assertIn("A note about the lands.", text)
        self.assertIn("| Duskwood |", text)
        self.assertNotIn("Burning Steppes", text)
        self.assertNotIn("### Dungeons", text)
        self.assertNotIn("Molten Core", text)

    def test_a_body_that_names_a_place_outside_is_caught(self):
        names = allowed(self.places, 12, "Alliance")
        self.assertEqual(named_outside("Walk the ash of the Burning Steppes.", self.places, names), ["Burning Steppes"])
        self.assertEqual(named_outside("Go down into the deadmines.", self.places, names), ["The Deadmines"])
        self.assertEqual(named_outside("Light a fire in Duskwood, by Stormwind.", self.places, names), [])

    def test_the_real_page_reads_every_section(self):
        sections, places = read()
        headings = [section.heading for section in sections]
        for heading in ("Cities", "Eastern Kingdoms", "Kalimdor", "Dungeons", "Forever dungeons", "Raids"):
            self.assertIn(heading, headings)
        found = {place.name: place for place in places}
        self.assertEqual(found["Duskwood"].low, 10)
        self.assertEqual(found["Hall of Thanes"].low, 13)
        self.assertEqual(found["Teldrassil"].side, "Alliance")
        self.assertIsNone(found["Blackrock Mountain"].low)
        self.assertNotIn("Warsong Gulch", found)


if __name__ == "__main__":
    unittest.main()
