"""The bot receives one announce operation, then the matching apply."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from eldgrim_agent.discord_post import announcement_text, operation, publish


class Fake:
    def __init__(self):
        self.calls = []

    def __call__(self, command, input, capture_output, timeout, check):
        request = json.loads(input.decode())
        self.calls.append(request)
        if request["method"] == "preview":
            body = json.dumps({"ok": True, "result": {"plan": "abc"}}).encode()
        else:
            body = json.dumps({"ok": True, "result": {"status": "applied"}}).encode()

        class Completed:
            returncode = 0
            stdout = body
            stderr = b""

        return Completed()


class PostTests(unittest.TestCase):
    def test_operation_is_one_announce(self):
        self.assertEqual(
            operation(12, " Keep the fire. "),
            {"action": "announce", "channel": 12, "text": "Keep the fire."},
        )

    def test_publish_previews_then_applies_the_same_plan(self):
        fake = Fake()
        config = Path(self.id().replace(".", "_") + ".toml")
        config.write_text(
            "ssh_host = example\nssh_identity = /tmp/key\nactor = 7\nchannel = 12\n",
            encoding="utf-8",
        )
        self.addCleanup(config.unlink)
        result = publish("A hearth is lit.", config_path=config, runner=fake)
        self.assertTrue(result["posted"])
        self.assertEqual(fake.calls[0]["method"], "preview")
        self.assertEqual(fake.calls[0]["operation"]["text"], "A hearth is lit.")
        self.assertEqual(fake.calls[1]["method"], "apply")
        self.assertEqual(fake.calls[1]["plan"], "abc")
        self.assertEqual(fake.calls[1]["confirmation"], "APPLY-abc")

    def test_announcement_file_text_follows_the_posted_line(self):
        path = Path(self.id().replace(".", "_") + ".md")
        path.write_text(
            "# Eldgrim announcement\n\nWritten: now\nPosted: no\n\nKeep the fire.\n",
            encoding="utf-8",
        )
        self.addCleanup(path.unlink)
        self.assertEqual(announcement_text(path), "Keep the fire.")


if __name__ == "__main__":
    unittest.main()
