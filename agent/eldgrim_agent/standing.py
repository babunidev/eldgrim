"""Who is in view for a rank. The score and the positivity orient. They do not change the rank.

Founder decision 2026-11-20: a promotion is recommended when the private score reaches the
next rank's minimum and the member's overall positivity is at least 75%. A demotion is
recommended when the score is below the current rank's minimum and positivity is under 50%.
Anyone else past a minimum is only named to look at. The day's keyword no longer decides.
"""

from __future__ import annotations

import sqlite3
from dataclasses import dataclass, field
from datetime import datetime

from eldgrim_agent.store import RANK_MINIMUM, RANKS, positivity

PROMOTION_POSITIVITY = 0.75
DEMOTION_POSITIVITY = 0.50
# Names per line, so the note stays short.
MOST = 3


@dataclass
class Recommendation:
    reviewed: bool
    promote: list[str] = field(default_factory=list)
    demote: list[str] = field(default_factory=list)
    look: list[str] = field(default_factory=list)
    involve: list[str] = field(default_factory=list)


def _next_rank(rank: str) -> str:
    if rank not in RANKS:
        return "Cinder"
    index = RANKS.index(rank)
    if index + 1 >= len(RANKS):
        return ""
    return RANKS[index + 1]


def recommend(
    db: sqlite3.Connection,
    polarity_today: dict[int, str],
    *,
    reviewed: bool,
    now: datetime | None = None,
) -> Recommendation:
    if not reviewed:
        return Recommendation(reviewed=False)
    now = now or datetime.now().astimezone()
    people = db.execute(
        "SELECT id, display_name, standing, opt_out, owner, rank FROM person ORDER BY id"
    ).fetchall()
    promotions: list[tuple[int, str]] = []
    demotions: list[tuple[int, str]] = []
    look: list[tuple[int, str]] = []
    involve: list[str] = []
    for person in people:
        if person["opt_out"] or person["owner"] or person["standing"] is None:
            continue
        person_id = int(person["id"])
        standing = int(person["standing"])
        rank = str(person["rank"] or "Ember")
        if rank not in RANKS:
            rank = "Ember"
        name = str(person["display_name"] or "").strip()
        if not name:
            continue
        nxt = _next_rank(rank)
        promotion_ready = bool(nxt) and standing >= RANK_MINIMUM[nxt]
        demotion_ready = rank != "Ember" and standing < RANK_MINIMUM[rank]
        share = positivity(db, person_id, now) if promotion_ready or demotion_ready else None
        if promotion_ready and share is not None and share >= PROMOTION_POSITIVITY:
            promotions.append((standing, name))
        elif demotion_ready and share is not None and share < DEMOTION_POSITIVITY:
            demotions.append((standing, name))
        elif promotion_ready or demotion_ready:
            look.append((standing if demotion_ready else -standing, name))
        elif polarity_today.get(person_id, "") == "neither":
            involve.append(name)
    return Recommendation(
        True,
        promote=[name for _score, name in sorted(promotions, key=lambda item: (-item[0], item[1]))][:MOST],
        demote=[name for _score, name in sorted(demotions, key=lambda item: (item[0], item[1]))][:MOST],
        look=_names(look),
        involve=involve[:MOST],
    )


def _names(pairs: list[tuple[int, str]]) -> list[str]:
    ordered = [name for _score, name in sorted(pairs, key=lambda item: (item[0], item[1]))]
    return ordered[:MOST]


def rank_line(recommendation: Recommendation) -> str:
    if not recommendation.reviewed:
        return "The ranks could not be reviewed."
    lines = []
    if recommendation.promote:
        lines.append(company_line(recommendation.promote, "Consider", "")[:-1] + " for promotion.")
    if recommendation.demote:
        lines.append(company_line(recommendation.demote, "Consider", "")[:-1] + " for demotion.")
    return "\n".join(lines) or "The ranks look in order."


def company_line(names: list[str], verb: str, empty: str) -> str:
    if not names:
        return empty
    if len(names) == 1:
        return f"{verb} {names[0]}."
    return f"{verb} {', '.join(names[:-1])} and {names[-1]}."
