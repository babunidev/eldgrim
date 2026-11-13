"""Who is in view for a rank. The score orients. It does not change the rank."""

from __future__ import annotations

import sqlite3
from dataclasses import dataclass, field

from eldgrim_agent.store import RANK_MINIMUM, RANKS


@dataclass
class Recommendation:
    reviewed: bool
    kind: str = "order"
    name: str = ""
    look: list[str] = field(default_factory=list)
    involve: list[str] = field(default_factory=list)


def _next_rank(rank: str) -> str:
    if rank not in RANKS:
        return "Wayfarer"
    index = RANKS.index(rank)
    if index + 1 >= len(RANKS):
        return ""
    return RANKS[index + 1]


def recommend(db: sqlite3.Connection, polarity_today: dict[int, str], *, reviewed: bool) -> Recommendation:
    if not reviewed:
        return Recommendation(reviewed=False)
    people = db.execute(
        "SELECT id, display_name, standing, opt_out, owner, rank FROM person ORDER BY id"
    ).fetchall()
    promotions: list[tuple[int, str, str]] = []
    demotions: list[tuple[int, str, str]] = []
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
        polarity = polarity_today.get(person_id, "")
        nxt = _next_rank(rank)
        promotion_ready = bool(nxt) and standing >= RANK_MINIMUM[nxt]
        demotion_ready = rank != "Ember" and standing < RANK_MINIMUM[rank]
        if promotion_ready and polarity == "positive":
            promotions.append((standing, name, nxt))
        elif demotion_ready and polarity == "negative":
            demotions.append((standing, name, rank))
        elif promotion_ready or demotion_ready:
            look.append((standing if demotion_ready else -standing, name))
        elif polarity == "neither":
            involve.append(name)
    if promotions:
        _standing, name, _rank = max(promotions, key=lambda item: (item[0], item[1]))
        return Recommendation(True, "promote", name, _names(look), _involve(involve, name))
    if demotions:
        _standing, name, _rank = min(demotions, key=lambda item: (item[0], item[1]))
        return Recommendation(True, "demote", name, _names(look), _involve(involve, name))
    return Recommendation(True, "order", "", _names(look), involve[:3])


def _names(pairs: list[tuple[int, str]]) -> list[str]:
    ordered = [name for _score, name in sorted(pairs, key=lambda item: (item[0], item[1]))]
    return ordered[:3]


def _involve(names: list[str], chosen: str) -> list[str]:
    return [name for name in names if name != chosen][:3]


def rank_line(recommendation: Recommendation) -> str:
    if not recommendation.reviewed:
        return "The ranks could not be reviewed."
    if recommendation.kind == "promote":
        return f"Consider {recommendation.name} for promotion."
    if recommendation.kind == "demote":
        return f"Consider {recommendation.name} for demotion."
    return "The ranks look in order."


def company_line(names: list[str], verb: str, empty: str) -> str:
    if not names:
        return empty
    if len(names) == 1:
        return f"{verb} {names[0]}."
    return f"{verb} {', '.join(names[:-1])} and {names[-1]}."
