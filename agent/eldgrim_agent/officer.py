"""The daily note for Hearthkeepers and Hearthwardens. It recommends. It does not change a rank."""

from __future__ import annotations

from eldgrim_agent.census import Census, render_census
from eldgrim_agent.standing import Recommendation, company_line, rank_line

GREETING = "A small watch on the ranks, for the keepers and the wardens."
PRACTICAL = "Keep a place at the fire for someone new, and draw a quiet member into the company."
# Discord's limit for one message.
MAX_LENGTH = 2000


def _involve(names: list[str]) -> str:
    if not names:
        return "No one in particular to involve more."
    if len(names) == 1:
        return f"Involve {names[0]} more."
    listed = ", ".join(names[:-1]) + " and " + names[-1]
    return f"Involve {listed} more."


def render_note(recommendation: Recommendation, census: Census | None = None) -> str:
    look = company_line(recommendation.look, "Look at", "No one in particular to look at.")
    body = look + "\n" + _involve(recommendation.involve)
    parts = [GREETING, rank_line(recommendation), body, PRACTICAL]
    note = "\n\n".join(parts)
    if census is None:
        return note
    longest = max([len(census.active), len(census.level_ups), *(len(names) for names in census.professions.values()), 0])
    # Name everyone when it fits; otherwise shorten every list alike until the note fits one message.
    for limit in [None, *range(longest - 1, -1, -1)]:
        candidate = note + "\n\n" + render_census(census, limit)
        if len(candidate) <= MAX_LENGTH:
            return candidate
    return note
