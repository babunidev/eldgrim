"""The places a quest may name, chosen by the character's level and side. Code chooses, not the model."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

from eldgrim_agent.paths import REPO_ROOT

WORLD_PATH = REPO_ROOT / "lore" / "WORLD.md"
# The page says raids and battlegrounds are never an errand. A quest is not shown them.
NOT_ERRANDS = ("Raids", "Battlegrounds")
LINK = re.compile(r"\[([^\]]+)\]\([^)]*\)")
FIRST_NUMBER = re.compile(r"\d+")


@dataclass(frozen=True)
class Place:
    section: str
    name: str
    low: int | None
    side: str
    row: str


@dataclass(frozen=True)
class Section:
    heading: str
    prose: tuple[str, ...]
    header: str


def read(path: Path | None = None) -> tuple[list[Section], list[Place]]:
    """Every table row on the world page, with its section, the low end of its levels, and its side."""
    sections: list[Section] = []
    places: list[Place] = []
    heading = ""
    prose: list[str] = []
    columns: list[str] = []
    header = ""

    def close() -> None:
        if heading:
            sections.append(Section(heading, tuple(prose), header))

    for line in (path or WORLD_PATH).read_text(encoding="utf-8").splitlines():
        if line.startswith("## "):
            close()
            heading, prose, columns, header = line[3:].strip(), [], [], ""
            continue
        if not heading:
            continue
        if line.startswith("|"):
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if not columns:
                columns, header = cells, line
                continue
            if set("".join(cells)) <= set("-: "):
                continue
            values = dict(zip(columns, cells))
            levels = FIRST_NUMBER.search(values.get("Levels", ""))
            places.append(
                Place(
                    section=heading,
                    name=LINK.sub(r"\1", cells[0]),
                    low=int(levels.group()) if levels else None,
                    side=values.get("Side", "").strip(),
                    row=LINK.sub(r"\1", line),
                )
            )
        elif line.strip():
            prose.append(line.strip())
    close()
    return sections, places


def allowed(places: list[Place], level: int | None, faction: str) -> set[str]:
    """A place whose band starts at or below the level, on no side or the character's own.
    Cities are always allowed. A row with no level is not an errand, as the page says.
    An unknown character level keeps every band; an unknown side keeps every side."""
    side = (faction or "").strip().lower()
    names = set()
    for place in places:
        if place.section in NOT_ERRANDS or place.low is None:
            continue
        if side and place.side.lower() in ("alliance", "horde") and place.side.lower() != side:
            continue
        if place.section != "Cities" and level is not None and place.low > level:
            continue
        names.add(place.name)
    return names


def world_text(sections: list[Section], places: list[Place], names: set[str]) -> str:
    """The allowed rows under their section headings, with each section's own notes."""
    lines = ["Places this character may be sent:"]
    for section in sections:
        rows = [place.row for place in places if place.section == section.heading and place.name in names]
        if not rows:
            continue
        lines.extend(["", f"### {section.heading}", *section.prose, section.header, *rows])
    return "\n".join(lines) if len(lines) > 1 else ""


def named_outside(body: str, places: list[Place], names: set[str]) -> list[str]:
    """Places on the world page that the body names and this character may not be sent to."""
    found = []
    for place in places:
        if place.name in names:
            continue
        forms = {place.name}
        if place.name.startswith("The "):
            forms.add(place.name[4:])
        for form in forms:
            if re.search(rf"(?<!\w){re.escape(form)}(?!\w)", body, re.IGNORECASE):
                found.append(place.name)
                break
    return found
