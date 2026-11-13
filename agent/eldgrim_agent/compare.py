"""Write a blind comparison. It does not post, and it does not build a guild brief."""

from __future__ import annotations

from datetime import datetime
from pathlib import Path
from random import SystemRandom

from eldgrim_agent.announce import draft_current, draft_selected
from eldgrim_agent.ollama import ensure_server, stop_server, unload
from eldgrim_agent.paths import COMPARE_DIR, LAST_BRIEF, ensure_runtime
from eldgrim_agent.run import hold_run_lock


def load_brief(sample: Path | None = None) -> str:
    if sample is not None:
        if not sample.is_file():
            raise FileNotFoundError(f"No sample brief at {sample}.")
        return sample.read_text(encoding="utf-8")
    if not LAST_BRIEF.is_file():
        raise FileNotFoundError("No brief has been stored. Pass a local sample file.")
    return LAST_BRIEF.read_text(encoding="utf-8")


def write_blind(pairs: list[tuple[str, str]], directory: Path) -> tuple[Path, Path]:
    """Shuffle drafts into A, B, C… and keep the key in a separate file. No Posted line."""
    order = list(pairs)
    SystemRandom().shuffle(order)
    letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if len(order) > len(letters):
        raise ValueError("At most 13 comparisons of each kind.")
    texts = ["# Comparison", ""]
    key = ["# Key", ""]
    for index, (setup, text) in enumerate(order):
        letter = letters[index]
        texts.extend([f"## {letter}", "", text.strip(), ""])
        key.append(f"{letter}: {setup}")
    directory.mkdir(parents=True, exist_ok=True)
    texts_path = directory / "texts.md"
    key_path = directory / "key.md"
    texts_path.write_text("\n".join(texts).rstrip() + "\n", encoding="utf-8")
    key_path.write_text("\n".join(key).rstrip() + "\n", encoding="utf-8")
    texts_path.chmod(0o600)
    key_path.chmod(0o600)
    return texts_path, key_path


def compare_proclamations(runs: int = 5, sample: Path | None = None) -> tuple[Path, Path]:
    """Five of today's reading and five of the new bundle, from one stored brief."""
    if not 1 <= runs <= 13:
        raise ValueError("Choose between 1 and 13 runs.")
    brief = load_brief(sample)
    pairs: list[tuple[str, str]] = []
    ensure_runtime()
    with hold_run_lock():
        server = None
        try:
            server = ensure_server()
            for _ in range(runs):
                pairs.append(("current", draft_current(brief)))
            for _ in range(runs):
                pairs.append(("selected", draft_selected(brief)))
        finally:
            unload()
            stop_server(server)
        stamp = datetime.now().astimezone().strftime("%Y%m%dT%H%M%S")
        return write_blind(pairs, COMPARE_DIR / stamp)
