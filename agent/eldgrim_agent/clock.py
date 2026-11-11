"""The next local calendar day, and one validated moment on it."""

from __future__ import annotations

import re
from datetime import datetime, timedelta
from random import SystemRandom

STAMP = re.compile(r"(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})")


def local_now(now: datetime | None = None) -> datetime:
    if now is None:
        return datetime.now().astimezone()
    if now.tzinfo is None:
        raise ValueError("now must be timezone-aware")
    return now.astimezone()


def next_calendar_day(now: datetime) -> datetime:
    current = local_now(now)
    midnight = current.replace(hour=0, minute=0, second=0, microsecond=0)
    return midnight + timedelta(days=1)


def parse_choice(text: str, now: datetime) -> datetime | None:
    """Accept one clock time on the next local calendar day. Reject every other stamp."""
    match = STAMP.search(text or "")
    if match is None:
        return None
    year, month, day, hour, minute = (int(part) for part in match.groups())
    if not (0 <= hour <= 23 and 0 <= minute <= 59):
        return None
    current = local_now(now)
    try:
        chosen = datetime(
            year, month, day, hour, minute, tzinfo=current.tzinfo
        )
    except ValueError:
        return None
    tomorrow = next_calendar_day(current).date()
    if chosen.date() != tomorrow:
        return None
    return chosen


def fallback_moment(now: datetime, rng: SystemRandom | None = None) -> datetime:
    """A random minute on the next local calendar day, used only when the model does not choose."""
    current = local_now(now)
    start = next_calendar_day(current)
    picker = rng or SystemRandom()
    return start + timedelta(hours=picker.randrange(24), minutes=picker.randrange(60))
