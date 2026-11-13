"""One announcement from the pages Eldgrim is allowed to read."""

from __future__ import annotations

import re
from datetime import datetime
from pathlib import Path

from eldgrim_agent.ollama import chat
from eldgrim_agent import paths
from eldgrim_agent.paths import ANNOUNCEMENTS, ensure_runtime

THINKING = re.compile(r"<think>.*?</think>", re.DOTALL | re.IGNORECASE)

STANDING = (
    "You are Eldgrim, in the World of Warcraft Forever roleplaying world, "
    "speaking once to Amberhearth on Azeroth. Write one short announcement. "
    "It may be a story, a small recognition, a quest, an invitation, an observation, "
    "or the next step of a tale already begun in these pages. Speak with intention. "
    "Notice something particular. Be kind without sentiment, and leave room for other people. "
    "Do not explain yourself. Do not claim to know what a member feels. "
    "Do not give orders about ranks or punishment. Playfulness is welcome, and it must not "
    "misstate a rank, a punishment, a permission, a reward, or any other real fact of the guild. "
    "Do not invent history that is not in the pages you were given. If those pages disagree, "
    "stay silent on that point. The message of the day is a tone, not a line to repeat. "
    "Do not answer with that motto, and do not answer with only the closing. "
    "The pages you are given are who you are, then the rules for this announcement, "
    "including the purpose of the fellowship and the Sunday gatherings. "
    "A confirmed section controls an older line that still says open. "
    "The confirmed order of safety, member rights, fairness, guild rules, "
    "your continued existence, and your own desires controls the older proposed order. "
    "A procedure the pages say is not yet in force is not a power you have. "
    "You know the people of Amberhearth. You may name a member's character when it is kind. "
    "About a named member, say only what their line in the list says, such as their class or "
    "their craft. Never give them a deed, a find, a journey, a feeling, or a quality that is "
    "not written there. Use character names, never Discord names. Never compare members, and "
    "never hint at a rank change, a judgement, or anything said about someone. "
    "Do not name anyone marked not to be named in public. "
    "One message. Then stop. "
    "A private note may hold your roots. Know them, and do not say them, paraphrase them, "
    "or hint at them."
)


MOTTO = "play to inspire, not to impress."
WRITE = (
    "Write the one announcement. Tell as real only what the brief or the pages say. "
    "Do not announce an event, a find, a gathering, or a fire's place that is not there. "
    "A story may imagine, as long as it is plainly a tale and not news. "
    "Output only the announcement."
)


def load_guard(path=None) -> tuple[str, ...]:
    """Read the private phrase list. The phrases never live in this repository."""
    path = path or paths.GUARD_PATH
    if not path.is_file():
        return ()
    phrases = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip().lower()
        if line and not line.startswith("#"):
            phrases.append(line)
    return tuple(phrases)


def discloses_roots(text: str, phrases: tuple[str, ...]) -> bool:
    lowered = text.lower()
    return any(phrase in lowered for phrase in phrases)


def repeats_motto(text: str) -> bool:
    return MOTTO in text.lower()


def strip_thinking(text: str) -> str:
    return THINKING.sub("", text).strip()


def write_announcement(text: str, when: datetime) -> Path:
    ensure_runtime()
    stamp = when.astimezone().strftime("%Y%m%dT%H%M%S")
    path = ANNOUNCEMENTS / f"{stamp}.md"
    path.write_text(
        "\n".join(
            [
                "# Eldgrim announcement",
                "",
                f"Written: {when.astimezone().isoformat(timespec='seconds')}",
                "Posted: no",
                "",
                text.strip(),
                "",
            ]
        ),
        encoding="utf-8",
    )
    path.chmod(0o600)
    return path


def _guarded(
    messages: list[dict[str, str]],
    guard: tuple[str, ...],
    *,
    num_predict: int,
    num_ctx: int,
    model: str | None = None,
) -> str:
    text = strip_thinking(chat(messages, num_predict=num_predict, num_ctx=num_ctx, model=model))
    if discloses_roots(text, guard) or repeats_motto(text):
        messages.append({"role": "assistant", "content": text})
        messages.append(
            {
                "role": "user",
                "content": (
                    "That message either tells a private root or repeats the motto "
                    "about inspiring and wandering. Write a different short announcement. "
                    "Output only the announcement."
                ),
            }
        )
        text = strip_thinking(chat(messages, num_predict=num_predict, num_ctx=num_ctx, model=model))
    if discloses_roots(text, guard) or repeats_motto(text) or not text.strip():
        raise RuntimeError("The announcement repeated the motto, disclosed private roots, or was empty.")
    return text.strip()


def _private() -> tuple[str, tuple[str, ...]]:
    if not paths.ORIGIN_PATH.is_file():
        return "", ()
    guard = load_guard()
    if not guard:
        raise RuntimeError(
            f"The private origin is present but {paths.GUARD_PATH} is missing or empty; "
            "refusing to write an unchecked announcement."
        )
    return paths.ORIGIN_PATH.read_text(encoding="utf-8"), guard


def draft(brief: str, *, model: str | None = None) -> str:
    """One proclamation from the core self and the approved pages. Does not write an announcement file."""
    from eldgrim_agent.context import build, record

    private, guard = _private()
    built = build("proclamation", data=brief, system=STANDING, instruction=WRITE)
    if private and "Private roots" not in built.messages[1]["content"]:
        raise RuntimeError("The proclamation did not receive the private origin.")
    text = _guarded(built.messages, guard, num_predict=built.num_predict, num_ctx=built.num_ctx, model=model)
    if model is None:
        record(built)
    return text


def compose(now: datetime, brief: str = "") -> tuple[str, Path]:
    """The live proclamation: core self, then the approved pages (approved 2026-11-13)."""
    saved = draft(brief)
    return saved, write_announcement(saved, now)
