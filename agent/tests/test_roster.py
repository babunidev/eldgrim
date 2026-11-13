"""Guild database: one keyword, daily points, and a note that does not change a rank."""

from __future__ import annotations

import sys
import tempfile
import unittest
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from eldgrim_agent.census import Census, profession_names, render_census, take_census
from eldgrim_agent.chatfile import reduce_chat
from eldgrim_agent.keywords import validate_keyword
from eldgrim_agent.lua_saved import dump_saved, parse_saved
from eldgrim_agent.officer import MAX_LENGTH, render_note
from eldgrim_agent.refresh import guild_brief, refresh_guild
from eldgrim_agent.standing import Recommendation
from eldgrim_agent.store import connect, message_hash, set_opt_out, summary, upsert_forge

NOW = datetime(2026, 11, 12, 22, 0, tzinfo=ZoneInfo("Europe/Stockholm"))

ARCHIVE = r"""
EldgrimDB = {
["Mira Stone"] = {
["messages"] = {
{
["message"] = "Hello \"there\"\nand welcome",
["timestamp"] = 10,
},
{
["message"] = "The fire is warm.",
["timestamp"] = 11,
},
},
["zone"] = "Ironforge",
["class"] = "Mage",
["race"] = "Human",
},
["Quiet Glen"] = {
["messages"] = {
},
["race"] = "Dwarf",
},
["Élodie Marsh"] = {
["messages"] = {
{
["message"] = "A long walk, then a longer one.",
["timestamp"] = 12,
},
},
["class"] = "Druid",
},
["Unregistered Soul"] = {
["messages"] = {
{
["message"] = "I just arrived.",
["timestamp"] = 13,
},
},
["class"] = "Warrior",
},
}
EldgrimRoster = {
["updated"] = 100,
["guild"] = "Amberhearth",
["members"] = {
["Mira Stone"] = {
["class"] = "Mage",
["rank"] = "Ember",
["online"] = false,
["rankIndex"] = 4,
["lastOnline"] = {
["hours"] = 2,
},
},
["Élodie Marsh"] = {
["class"] = "Druid",
["rank"] = "Wayfarer",
["online"] = false,
["rankIndex"] = 3,
},
},
}
"""


def member(discord_id, name, rank, characters, fellowship="Amberhearth", owner=False):
    return {
        "member": discord_id,
        "display_name": name,
        "fellowship": fellowship,
        "rank": rank,
        "owner": owner,
        "characters": characters,
    }


def people():
    return [
        member(1, "Mira", "Ember", [{"name": "Mira Stone", "faction": "Alliance", "race": "Human", "class": "Mage"}]),
        member(2, "Élodie", "Wayfarer", [{"name": "Élodie Marsh", "faction": "Alliance", "race": "Night Elf", "class": "Druid"}]),
        member(3, "Owner", "Hearthwarden", [{"name": "Owner Ash", "faction": "Alliance", "race": "Human", "class": "Paladin"}], owner=True),
    ]


class RosterTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.db_path = Path(self.tmp.name) / "eldgrim.sqlite3"
        self.chat = Path(self.tmp.name) / "Eldgrim.lua"
        self.chat.write_text(ARCHIVE, encoding="utf-8")
        self.db = connect(self.db_path)
        self.addCleanup(self.db.close)
        upsert_forge(self.db, people(), NOW)

    def ask(self, lines):
        self.calls.append(lines)
        if any("walk" in line for line in lines):
            return "negative sharp words"
        return "neither greeting"

    def test_parser_keeps_quotes_breaks_accents_and_empty_lists(self):
        tables = parse_saved(ARCHIVE)
        messages = []
        for key, value in tables["EldgrimDB"].items:
            if key == "Mira Stone":
                for _index, entry in value.get("messages").items:
                    messages.append(entry.get("message"))
            if key == "Quiet Glen":
                self.assertEqual(value.get("messages").items, [])
        self.assertEqual(messages[0], 'Hello "there"\nand welcome')
        self.assertIn("Élodie Marsh", tables["EldgrimDB"].as_dict())
        self.assertTrue(dump_saved(parse_saved(dump_saved(tables))).startswith("EldgrimDB"))

    def test_greeting_is_one_point_and_one_keyword(self):
        self.calls = []
        outcome = reduce_chat(self.db, self.chat, self.ask, NOW)
        self.assertEqual(len(self.calls), 3)
        self.assertEqual(len(self.calls[0]), 2)
        mira = self.db.execute("SELECT standing FROM person WHERE display_name = 'Mira'").fetchone()
        keywords = self.db.execute(
            "SELECT term, polarity FROM keyword WHERE person_id = (SELECT id FROM person WHERE display_name = 'Mira')"
        ).fetchall()
        self.assertEqual(mira["standing"], 51)
        self.assertEqual([(row["term"], row["polarity"]) for row in keywords], [("greeting", "neither")])
        self.assertIn("Mira Stone", outcome.cleared)
        self.assertIn("Unregistered Soul", outcome.cleared)
        rewritten = self.chat.read_text(encoding="utf-8")
        tables = parse_saved(rewritten)
        mira_messages = []
        for key, value in tables["EldgrimDB"].items:
            if key == "Mira Stone":
                self.assertEqual(value.get("zone"), "Ironforge")
                mira_messages = value.get("messages").items
            if key == "Unregistered Soul":
                self.assertEqual(value.get("messages").items, [])
        self.assertEqual(mira_messages, [])
        self.assertIn("rankIndex", rewritten)
        asked = len(self.calls)
        reduce_chat(self.db, self.chat, self.ask, NOW)
        self.assertEqual(len(self.calls), asked)
        self.assertEqual(len(self.db.execute("SELECT id FROM keyword").fetchall()), 3)

    def test_positive_and_negative_points_and_no_second_keyword_when_the_clear_fails(self):
        self.calls = []

        def changing_file(lines):
            self.chat.write_text(self.chat.read_text(encoding="utf-8") + "\n", encoding="utf-8")
            return self.ask(lines)

        outcome = reduce_chat(self.db, self.chat, changing_file, NOW)
        self.assertEqual(outcome.cleared, [])
        self.assertIn("changed", outcome.error)
        elodie = self.db.execute("SELECT standing FROM person WHERE display_name = 'Élodie'").fetchone()
        self.assertEqual(elodie["standing"], 59)
        reduce_chat(self.db, self.chat, self.ask, NOW)
        keywords = self.db.execute(
            "SELECT term FROM keyword WHERE person_id = (SELECT id FROM person WHERE display_name = 'Élodie')"
        ).fetchall()
        self.assertEqual([row["term"] for row in keywords], ["sharp words"])
        self.assertEqual(self.db.execute("SELECT standing FROM person WHERE display_name = 'Élodie'").fetchone()["standing"], 59)

    def test_ingame_character_is_a_member_before_discord(self):
        self.calls = []
        reduce_chat(self.db, self.chat, self.ask, NOW)
        row = self.db.execute(
            """SELECT character.person_id, character.class_name, person.standing, person.discord_id
               FROM character JOIN person ON person.id = character.person_id
               WHERE character.name = 'Unregistered Soul'"""
        ).fetchone()
        self.assertIsNotNone(row["person_id"])
        self.assertIsNone(row["discord_id"])
        self.assertEqual(row["class_name"], "Warrior")
        self.assertEqual(row["standing"], 51)
        text = summary(self.db)
        self.assertIn("Unregistered Soul", text)
        self.assertNotIn("I just arrived", text)

    def test_an_old_unlinked_row_becomes_the_member(self):
        from eldgrim_agent.store import ensure_member

        self.db.execute(
            "INSERT INTO character (person_id, name, link, updated) VALUES (NULL, 'Quiet Glen', '', ?)",
            (NOW.isoformat(),),
        )
        self.db.commit()
        person_id = ensure_member(self.db, "Quiet Glen", {"game_rank": "Wayfarer"}, NOW)
        self.db.commit()
        rows = self.db.execute("SELECT person_id, link FROM character WHERE name = 'Quiet Glen'").fetchall()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["person_id"], person_id)
        self.assertEqual(rows[0]["link"], "in-game")
        self.assertNotIn("Unlinked characters:", summary(self.db))

    def test_discord_registration_attaches_to_the_existing_member(self):
        from eldgrim_agent.store import ensure_member

        ensure_member(self.db, "Quiet Glen", {"game_rank": "Wayfarer", "class_name": "Hunter"}, NOW)
        self.db.commit()
        before = self.db.execute("SELECT COUNT(*) AS n FROM person").fetchone()["n"]
        upsert_forge(
            self.db,
            [member(20, "Glen", "Ember", [{"name": "Quiet Glen", "faction": "Alliance", "race": "Dwarf", "class": "Hunter"}])],
            NOW,
        )
        after = self.db.execute("SELECT COUNT(*) AS n FROM person").fetchone()["n"]
        self.assertEqual(after, before)
        person = self.db.execute(
            """SELECT person.display_name, person.standing, person.rank
               FROM person JOIN character ON character.person_id = person.id
               WHERE character.name = 'Quiet Glen'"""
        ).fetchone()
        self.assertEqual(person["display_name"], "Glen")
        self.assertEqual(person["standing"], 60)
        self.assertEqual(person["rank"], "Wayfarer")

    def test_same_declared_name_links_neither_and_one_name_does_not_match(self):
        upsert_forge(
            self.db,
            [
                member(8, "Ann One", "Ember", [{"name": "Ann", "faction": "Alliance", "race": "Human", "class": "Mage"}]),
                member(9, "Ann Two", "Ember", [{"name": "Ann", "faction": "Horde", "race": "Orc", "class": "Shaman"}]),
                member(10, "Full", "Ember", [{"name": "Ann Marsh", "faction": "Alliance", "race": "Human", "class": "Mage"}]),
            ],
            NOW,
        )
        archive = """
EldgrimDB = {
["Ann"] = {["messages"] = {{["message"] = "Hello", ["timestamp"] = 1,}}, ["class"] = "Mage"},
["Ann Marsh"] = {["messages"] = {{["message"] = "Hello there friend", ["timestamp"] = 2,}}, ["class"] = "Mage"},
["élodie marsh"] = {["messages"] = {{["message"] = "Back again", ["timestamp"] = 3,}}, ["class"] = "Druid"},
}
"""
        path = Path(self.tmp.name) / "names.lua"
        path.write_text(archive, encoding="utf-8")
        self.calls = []
        reduce_chat(self.db, path, lambda lines: "positive kept company", NOW)
        ann_keywords = self.db.execute(
            "SELECT COUNT(*) AS n FROM keyword WHERE person_id IN (SELECT id FROM person WHERE display_name LIKE 'Ann %')"
        ).fetchone()["n"]
        self.assertEqual(ann_keywords, 0)
        full = self.db.execute("SELECT standing FROM person WHERE display_name = 'Full'").fetchone()["standing"]
        self.assertEqual(full, 52)
        elodie = self.db.execute("SELECT standing FROM person WHERE display_name = 'Élodie'").fetchone()["standing"]
        self.assertEqual(elodie, 62)

    def test_opt_out_skips_keywords_and_points(self):
        self.assertIn("opted out", set_opt_out(self.db, "Mira", True))
        self.calls = []
        reduce_chat(self.db, self.chat, self.ask, NOW)
        self.assertEqual(self.db.execute("SELECT standing FROM person WHERE display_name = 'Mira'").fetchone()["standing"], 50)
        self.assertEqual(
            self.db.execute("SELECT COUNT(*) AS n FROM keyword WHERE person_id = (SELECT id FROM person WHERE display_name = 'Mira')").fetchone()["n"],
            0,
        )
        rewritten = parse_saved(self.chat.read_text(encoding="utf-8"))
        for key, value in rewritten["EldgrimDB"].items:
            if key == "Mira Stone":
                self.assertEqual(len(value.get("messages").items), 2)

    def test_departure_keeps_keywords_and_an_older_roster_ends_nobody(self):
        self.calls = []
        reduce_chat(self.db, self.chat, self.ask, NOW)
        keyword = message_hash("Élodie Marsh", 12, "A long walk, then a longer one.")
        self.assertIsNone(self.db.execute("SELECT hash FROM seen_message WHERE hash = ?", (keyword,)).fetchone())
        later = ARCHIVE.replace('["updated"] = 100', '["updated"] = 200').replace(
            """["Élodie Marsh"] = {
["class"] = "Druid",
["rank"] = "Wayfarer",
["online"] = false,
["rankIndex"] = 3,
},
""",
            "",
        )
        path = Path(self.tmp.name) / "later.lua"
        path.write_text(later, encoding="utf-8")
        outcome = reduce_chat(self.db, path, self.ask, NOW)
        self.assertIn("Élodie Marsh", outcome.departed)
        row = self.db.execute("SELECT left_on FROM character WHERE name = 'Élodie Marsh'").fetchone()
        self.assertEqual(row["left_on"], "2026-11-12")
        self.assertEqual(self.db.execute("SELECT left_on FROM person WHERE display_name = 'Élodie'").fetchone()["left_on"], "2026-11-12")
        self.assertGreaterEqual(self.db.execute("SELECT COUNT(*) AS n FROM keyword").fetchone()["n"], 1)
        older = reduce_chat(self.db, self.chat, self.ask, NOW)
        self.assertEqual(older.departed, [])

    def test_invalid_keyword_still_gives_the_activity_point(self):
        self.assertIsNone(validate_keyword("positive this is a sentence."))
        self.assertIsNone(validate_keyword('negative "quoted"'))
        self.assertIsNone(validate_keyword("negative home address"))
        self.assertEqual(validate_keyword("positive kept company"), ("positive", "kept company"))
        path = Path(self.tmp.name) / "one.lua"
        path.write_text(
            'EldgrimDB = {["Mira Stone"] = {["messages"] = {{["message"] = "Hello", ["timestamp"] = 4,}},}}\n',
            encoding="utf-8",
        )
        reduce_chat(self.db, path, lambda lines: "I will not answer in the required shape at all", NOW)
        self.assertEqual(self.db.execute("SELECT standing FROM person WHERE display_name = 'Mira'").fetchone()["standing"], 51)
        self.assertEqual(self.db.execute("SELECT COUNT(*) AS n FROM keyword").fetchone()["n"], 0)

    def test_note_uses_the_score_without_printing_it_or_changing_rank(self):
        def answers(lines):
            if any("walk" in line for line in lines):
                return "negative sharp words"
            return "positive kept company"

        self.db.execute("UPDATE person SET standing = 59 WHERE display_name = 'Mira'")
        self.db.commit()
        newcomers = people() + [
            member(4, "Newcomer", "Ember", [{"name": "New Soul", "faction": "Alliance", "race": "Human", "class": "Mage"}])
        ]
        refreshed = refresh_guild(NOW, answers, database=self.db_path, saved=self.chat, forge=lambda: {"members": newcomers})
        self.assertIn("Consider Mira for promotion.", refreshed.note)
        self.assertNotIn("61", refreshed.note)
        self.assertNotIn("59", refreshed.note)
        self.assertNotIn("Hello", refreshed.note)
        self.assertIn("Newcomer", refreshed.brief)
        self.assertNotIn("greeting", refreshed.brief)
        self.assertIn("kept company", refreshed.brief)
        self.db.execute("UPDATE person SET rank = 'Ember' WHERE display_name = 'Mira'")
        self.assertEqual(self.db.execute("SELECT rank FROM person WHERE display_name = 'Mira'").fetchone()["rank"], "Ember")

    def test_failed_forge_pull_still_builds_a_brief_and_reviews_no_names(self):
        def boom():
            raise RuntimeError("ssh failed")

        refreshed = refresh_guild(NOW, lambda lines: "neither greeting", database=self.db_path, saved=self.chat, forge=boom)
        self.assertIn("could not be reviewed", refreshed.note)
        ranks = refreshed.note.split("**Guild members")[0]
        self.assertNotIn("Mira", ranks)
        self.assertIn("The Forge could not be refreshed", refreshed.brief)
        self.assertIn("Newcomers: none", guild_brief([], [], "ssh failed", ""))

    def test_note_counts_members_activity_and_professions(self):
        self.db.execute(
            "UPDATE character SET professions = ? WHERE name = 'Mira Stone'",
            ('professions = {\n\t{\n\t\t["name"] = "Blacksmithing",\n\t\t["skill"] = 1,\n\t},\n'
             '\t{\n\t\t["name"] = "Mining",\n\t\t["skill"] = 1,\n\t},\n}',),
        )
        self.db.commit()
        refreshed = refresh_guild(NOW, lambda lines: "neither greeting", database=self.db_path, saved=self.chat, forge=lambda: {"members": people()})
        self.assertIn("**Active in guild chat, last 7 days: 3**\nMira Stone, Unregistered Soul, Élodie Marsh", refreshed.note)
        self.assertIn("Blacksmithing (1)\nMira Stone", refreshed.note)
        self.assertIn("Mining (1)\nMira Stone", refreshed.note)
        self.assertNotIn("Quiet Glen, ", refreshed.note.split("**Professions")[0].split("days:")[1])
        self.assertNotIn("The fire is warm", refreshed.note)
        db = connect(self.db_path)
        self.addCleanup(db.close)
        members = db.execute("SELECT COUNT(*) AS n FROM character WHERE in_guild = 1").fetchone()["n"]
        self.assertIn(f"**Guild members: {members}**", refreshed.note)
        # Seven days later the same lines no longer count as active.
        later = take_census(db, NOW.replace(day=19))
        self.assertEqual(later.active, [])
        self.assertEqual(take_census(db, NOW.replace(day=18)).active, ["Mira Stone", "Unregistered Soul", "Élodie Marsh"])

    def test_opted_out_speaker_is_not_marked_active(self):
        set_opt_out(self.db, "Mira", True)
        reduce_chat(self.db, self.chat, lambda lines: "neither greeting", NOW)
        self.assertNotIn("Mira Stone", take_census(self.db, NOW).active)

    def test_level_ups_count_from_the_last_posted_note(self):
        from eldgrim_agent.store import mark_census_levels

        self.db.execute("UPDATE character SET level = 10 WHERE name = 'Mira Stone'")
        self.db.execute("UPDATE character SET level = 20 WHERE name = 'Élodie Marsh'")
        self.db.commit()
        first = take_census(self.db, NOW)
        self.assertFalse(first.has_baseline)
        self.assertIn("**Level-ups:** counted from the next note on.", render_census(first))
        mark_census_levels(self.db)
        self.db.execute("UPDATE character SET level = 13 WHERE name = 'Mira Stone'")
        self.db.execute("INSERT INTO character (name, level, updated) VALUES ('Late Arrival', 30, 'x')")
        self.db.commit()
        later = take_census(self.db, NOW)
        self.assertEqual(later.level_ups, [("Mira Stone", 10, 13)])
        text = render_census(later)
        self.assertIn("**Level-ups since the last note: 3** (1 character)\nMira Stone 10 → 13", text)
        mark_census_levels(self.db)
        self.assertEqual(take_census(self.db, NOW).level_ups, [])

    def test_levels_are_marked_only_after_the_note_is_posted(self):
        from unittest.mock import patch

        from eldgrim_agent import run

        def fake_refresh(started, ask):
            from eldgrim_agent.refresh import Refresh

            return Refresh(brief="Newcomers: none", note="A note.")

        marked = []
        common = [
            patch("eldgrim_agent.run.preflight", lambda started: None),
            patch("eldgrim_agent.run.ensure_server", lambda: None),
            patch("eldgrim_agent.run.stop_server", lambda server: None),
            patch("eldgrim_agent.run.unload", lambda: None),
            patch("eldgrim_agent.run.refresh_guild", fake_refresh),
            patch("eldgrim_agent.run.save_last_brief", lambda text: None),
            patch("eldgrim_agent.run._remember_officer", lambda started, note: None),
            patch("eldgrim_agent.run.compose", lambda started, brief: ("Text", Path(self.tmp.name) / "a.md")),
            patch("eldgrim_agent.run.post_file", lambda path, approval: None),
            patch("eldgrim_agent.run._choose_quietly", lambda started: (NOW, "fallback")),
            patch("eldgrim_agent.run.save_choice", lambda chosen, source: None),
            patch("eldgrim_agent.run._write_log", lambda started, report: None),
            patch("eldgrim_agent.run.LOCK_PATH", Path(self.tmp.name) / "run.lock"),
            patch("eldgrim_agent.run.ensure_runtime", lambda: None),
            patch("eldgrim_agent.run._mark_levels", lambda: marked.append(1)),
        ]
        for item in common:
            item.start()
        try:
            from eldgrim_agent.discord_post import PostError

            def refuse(text, approval):
                raise PostError("bot unreachable")

            with patch("eldgrim_agent.run.post_officer", refuse):
                run.execute(scheduled=False)
            self.assertEqual(marked, [])
            with patch("eldgrim_agent.run.post_officer", lambda text, approval: None):
                run.execute(scheduled=False)
            self.assertEqual(marked, [1])
        finally:
            for item in common:
                item.stop()

    def test_long_census_is_shortened_to_one_message(self):
        names = [f"Character Number {index}" for index in range(200)]
        census = Census(members=names, active=names[:150], professions={"Tailoring": names[:120], "Mining": names[50:]})
        note = render_note(Recommendation(reviewed=True), census)
        self.assertLessEqual(len(note), MAX_LENGTH)
        self.assertIn("**Guild members: 200**", note)
        self.assertIn("Tailoring (120)", note)
        self.assertIn("more", note)
        small = render_note(Recommendation(reviewed=True), Census(members=["A"], active=[], professions={}))
        self.assertIn("**Active in guild chat, last 7 days: 0**\nnone", small)
        self.assertIn("No professions recorded yet.", small)

    def test_unreadable_professions_are_left_out(self):
        self.assertEqual(profession_names(None), [])
        self.assertEqual(profession_names("not lua {"), [])
        self.assertEqual(profession_names('professions = {{["skill"] = 3,},}'), [])
        self.assertIn("Tailoring (1)\nA", render_census(Census(["A"], [], {"Tailoring": ["A"]})))

    def test_empty_file_is_left_empty(self):
        empty = Path(self.tmp.name) / "empty.lua"
        empty.write_text("EldgrimDB = {}\nEldgrimRoster = {}\n", encoding="utf-8")
        before = empty.read_bytes()
        outcome = reduce_chat(self.db, empty, lambda lines: (_ for _ in ()).throw(AssertionError("asked")), NOW)
        self.assertEqual(outcome.skipped, "empty")
        self.assertEqual(empty.read_bytes(), before)

    def test_accents_round_trip_without_executing_lua(self):
        text = 'EldgrimDB = {["Élodie"] = {["messages"] = {}, ["zone"] = "Darnassus",},}\n'
        parsed = parse_saved(text)
        self.assertEqual(parsed["EldgrimDB"].get("Élodie").get("zone"), "Darnassus")


if __name__ == "__main__":
    unittest.main()
