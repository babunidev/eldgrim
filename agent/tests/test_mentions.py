"""One reply for each member who wrote. No live Discord call."""

from __future__ import annotations

import sys
import tempfile
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from eldgrim_agent.context import build
from eldgrim_agent.mentions import (
    REPLY_INSTRUCTION,
    REPLY_SYSTEM,
    letter_text,
    parse_reply,
    run_daily_replies,
)
from eldgrim_agent.quests import character_card
from eldgrim_agent.store import connect, upsert_forge

STOCKHOLM = timezone(timedelta(hours=1))
NOW = datetime(2026, 11, 17, 2, 30, tzinfo=STOCKHOLM)
ANSWER = (
    "Learned: positive cold hearth\n"
    "\n"
    "The hill keeps its own time. Light it again when you are ready.\n\n"
    "Keep the fire."
)


class ReplyParseTests(unittest.TestCase):
    def test_the_motto_and_a_refusal_are_refused(self):
        self.assertIsNone(
            parse_reply(
                "Learned: positive cold hearth\n\nPlay to inspire, not to impress. The hill keeps its own time."
            )
        )
        silent = parse_reply("Reply: none")
        self.assertIsNotNone(silent)
        self.assertFalse(silent.answer)


class DailyReplyTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.db_path = Path(self.tmp.name) / "guild.sqlite3"
        self.sent = []
        self.purged = []
        self.seen_data = []

    def deliver(self, channel, message, text):
        self.sent.append((channel, message, text))
        return "sent"

    def purge(self, ids):
        self.purged.append(list(ids))

    def ask(self, data):
        self.seen_data.append(data)
        return ANSWER

    def seed(self, member, name, *, opt_out=0):
        db = connect(self.db_path)
        upsert_forge(
            db,
            [{
                "member": member,
                "display_name": f"Member{member}",
                "fellowship": "Amberhearth",
                "rank": "Ember",
                "owner": False,
                "characters": [{"name": name, "faction": "Alliance", "race": "Dwarf", "class": "Warrior"}],
            }],
            NOW,
        )
        if opt_out:
            db.execute("UPDATE person SET opt_out = 1 WHERE discord_id = ?", (member,))
            db.commit()
        db.close()

    def standing(self, member):
        db = connect(self.db_path)
        try:
            return int(db.execute("SELECT standing FROM person WHERE discord_id = ?", (member,)).fetchone()["standing"])
        finally:
            db.close()

    def keywords(self, member):
        db = connect(self.db_path)
        try:
            return db.execute(
                """SELECT term, polarity, source FROM keyword
                   WHERE person_id = (SELECT id FROM person WHERE discord_id = ?)""",
                (member,),
            ).fetchall()
        finally:
            db.close()

    def letters(self):
        return [
            {"id": 1, "message": 9001, "channel": 7, "member": 5, "body": "tell me something small"},
            {"id": 2, "message": 9002, "channel": 8, "member": 6, "body": "the fire on the hill went out"},
        ]

    def test_each_member_is_answered_from_that_member_alone(self):
        self.seed(5, "Bea")
        self.seed(6, "Ada")
        outcome = run_daily_replies(
            NOW,
            pull=self.letters,
            purge=self.purge,
            ask=self.ask,
            deliver=self.deliver,
            database=self.db_path,
        )
        self.assertEqual(outcome["replied"], 2)
        self.assertEqual(outcome["learned"], 2)
        self.assertEqual(
            self.sent,
            [
                (7, 9001, "The hill keeps its own time. Light it again when you are ready.\n\nKeep the fire."),
                (8, 9002, "The hill keeps its own time. Light it again when you are ready.\n\nKeep the fire."),
            ],
        )
        self.assertEqual(self.purged, [[1, 2]])
        self.assertIn("Bea", self.seen_data[0])
        self.assertNotIn("Ada", self.seen_data[0])
        self.assertIn("Ada", self.seen_data[1])
        self.assertNotIn("Bea", self.seen_data[1])
        self.assertNotIn("Member5", self.seen_data[0])
        self.assertEqual(self.standing(6), 50)
        self.assertEqual(self.keywords(6)[0]["term"], "cold hearth")
        self.assertEqual(self.keywords(5)[0]["source"], "mention")
        again = run_daily_replies(
            NOW,
            pull=self.letters,
            purge=self.purge,
            ask=self.ask,
            deliver=self.deliver,
            database=self.db_path,
        )
        self.assertEqual(again["replied"], 0)
        self.assertEqual(len(self.sent), 2)
        self.assertEqual(self.purged[-1], [1, 2])

    def test_silence_and_a_named_opt_out_post_nothing(self):
        self.seed(6, "Ada", opt_out=1)

        def quiet(_data):
            return "Reply: none"

        run_daily_replies(
            NOW,
            pull=self.letters,
            purge=self.purge,
            ask=quiet,
            deliver=self.deliver,
            database=self.db_path,
        )
        self.assertEqual(self.sent, [])
        self.assertEqual(self.purged, [[1, 2]])

        def names_them(_data):
            return (
                "Learned: positive cold hearth\n\n"
                "Ada, the hill keeps its own time and the fire will wait."
            )

        db = connect(self.db_path)
        db.execute("DELETE FROM mention_seen")
        db.commit()
        db.close()
        self.purged.clear()
        outcome = run_daily_replies(
            NOW,
            pull=lambda: [self.letters()[1]],
            purge=self.purge,
            ask=names_them,
            deliver=self.deliver,
            database=self.db_path,
        )
        self.assertEqual(outcome["replied"], 0)
        self.assertEqual(self.sent, [])
        self.assertEqual(self.keywords(6), [])
        self.assertEqual(self.standing(6), 50)
        db = connect(self.db_path)
        try:
            card, names, quiet = character_card(db, 6, __import__("random").Random(0))
        finally:
            db.close()
        shown = letter_text(card, self.letters()[1]["body"])
        self.assertIn("not to be named", shown)
        self.assertNotIn("Ada", shown)
        self.assertEqual(names, ["Ada"])
        self.assertTrue(quiet)

    def test_a_failed_send_does_not_keep_the_impression(self):
        self.seed(6, "Ada")
        outcome = run_daily_replies(
            NOW,
            pull=lambda: [self.letters()[1]],
            purge=self.purge,
            ask=self.ask,
            deliver=lambda channel, message, text: "closed",
            database=self.db_path,
        )
        self.assertEqual(outcome["replied"], 0)
        self.assertEqual(outcome["learned"], 0)
        self.assertEqual(self.keywords(6), [])
        self.assertEqual(self.purged, [[2]])


class ReplyContextTests(unittest.TestCase):
    def test_the_reply_task_reads_the_conduct_pages(self):
        root = Path(tempfile.mkdtemp())
        origin = root / "ORIGIN.md"
        origin.write_text("violet test root\n", encoding="utf-8")
        guard = root / "GUARD.txt"
        guard.write_text("violet test root\n", encoding="utf-8")
        database = root / "people.sqlite3"
        with (
            patch("eldgrim_agent.paths.ORIGIN_PATH", origin),
            patch("eldgrim_agent.paths.GUARD_PATH", guard),
            patch("eldgrim_agent.paths.DATABASE_PATH", database),
        ):
            built = build(
                "reply",
                data="1. Ada: the fire on the hill went out",
                system=REPLY_SYSTEM,
                instruction=REPLY_INSTRUCTION,
            )
        names = [page.name for page in built.pages]
        self.assertIn("governance/06-daily-conduct-and-communication.md", names)
        self.assertIn("governance/12-observation-memory-and-privacy.md", names)
        self.assertNotIn("lore/WORLD.md", names)
        self.assertNotIn("The people of Amberhearth", names)
        self.assertLessEqual(built.estimate + built.num_predict, built.num_ctx)
        self.assertIn("never a direct message", built.messages[0]["content"])
        self.assertIn("Do not name any other character", built.messages[0]["content"])
