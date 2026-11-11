"""Posting: one preview then the same plan applied, mentions made inert, and no double posts."""

from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from eldgrim_agent.discord_post import (
    AmbiguousPost,
    PostError,
    announcement_text,
    defuse_mentions,
    latest_unposted,
    operation,
    post_file,
    reset_for_resend,
    state,
)


class Fake:
    def __init__(self, apply_reply=None, apply_raises=None):
        self.calls = []
        self.apply_reply = apply_reply or {"ok": True, "result": {"status": "applied"}}
        self.apply_raises = apply_raises

    def __call__(self, command, input, capture_output, timeout, check):
        request = json.loads(input.decode())
        self.calls.append(request)
        if request["method"] == "preview":
            body = {"ok": True, "result": {"plan": "abc"}}
        else:
            if self.apply_raises:
                raise self.apply_raises
            body = self.apply_reply

        class Completed:
            returncode = 0
            stdout = json.dumps(body).encode()
            stderr = b""

        return Completed()


class PostTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.dir = Path(self.tmp.name)
        self.config = self.dir / "discord.toml"
        self.config.write_text("ssh_host = example\nssh_identity = /tmp/key\nactor = 7\nchannel = 12\n", encoding="utf-8")

    def announcement(self, name="20261111T030500.md", text="A hearth is lit."):
        path = self.dir / name
        path.write_text(f"# Eldgrim announcement\n\nWritten: now\nPosted: no\n\n{text}\n", encoding="utf-8")
        return path

    def test_operation_is_one_announce(self):
        self.assertEqual(
            operation(12, " Keep the fire. "),
            {"action": "announce", "channel": 12, "text": "Keep the fire."},
        )

    def test_mentions_are_made_inert(self):
        text = defuse_mentions("Hear me @everyone and @Here, <@123>, <@!45>, <@&678>.")
        self.assertNotIn("@everyone", text)
        self.assertNotIn("@Here", text)
        for raw in ("<@123>", "<@!45>", "<@&678>"):
            self.assertNotIn(raw, text)
        self.assertIn("Hear me", text)

    def test_post_previews_then_applies_and_marks_yes(self):
        fake = Fake()
        path = self.announcement()
        post_file(path, approval="note", config_path=self.config, runner=fake)
        self.assertEqual([c["method"] for c in fake.calls], ["preview", "apply"])
        self.assertEqual(fake.calls[1]["plan"], "abc")
        self.assertEqual(fake.calls[1]["confirmation"], "APPLY-abc")
        self.assertEqual(fake.calls[1]["approval_note"], "note")
        self.assertEqual(state(path), "yes")
        self.assertIn("Plan: abc", path.read_text(encoding="utf-8"))
        self.assertEqual(announcement_text(path), "A hearth is lit.")

    def test_lost_apply_reply_marks_unknown_and_is_not_resent(self):
        import subprocess

        path = self.announcement()
        fake = Fake(apply_raises=subprocess.TimeoutExpired("ssh", 120))
        with self.assertRaises(AmbiguousPost):
            post_file(path, approval="note", config_path=self.config, runner=fake)
        self.assertEqual(state(path), "unknown")
        self.assertIsNone(latest_unposted(self.dir))
        with self.assertRaises(PostError):
            post_file(path, approval="note", config_path=self.config, runner=Fake())
        reset_for_resend(path)
        self.assertEqual(state(path), "no")

    def test_preview_refusal_leaves_the_announcement_unposted(self):
        path = self.announcement()

        class Refuse(Fake):
            def __call__(self, command, input, capture_output, timeout, check):
                class Completed:
                    returncode = 0
                    stdout = json.dumps({"ok": False, "error": "channel missing"}).encode()
                    stderr = b""

                return Completed()

        with self.assertRaises(PostError):
            post_file(path, approval="note", config_path=self.config, runner=Refuse())
        self.assertEqual(state(path), "no")


if __name__ == "__main__":
    unittest.main()
