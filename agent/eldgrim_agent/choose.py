"""At the end of a run, Eldgrim names one moment on the next local day."""

from __future__ import annotations

from datetime import datetime

from eldgrim_agent.clock import fallback_moment, next_calendar_day, parse_choice
from eldgrim_agent.ollama import chat

SYSTEM = "You are Eldgrim. You choose when you next act. You reply with one timestamp."

CHOICE = (
    "Choose the one moment on the next local calendar day when you will next act. "
    "Any minute of that day is allowed. Reply with only the date and time, "
    "as YYYY-MM-DD HH:MM, using 24-hour time. Do not explain."
)


def choose_next(now: datetime) -> tuple[datetime, str]:
    tomorrow = next_calendar_day(now).date().isoformat()
    messages = [
        {
            "role": "system",
            "content": SYSTEM,
        },
        {
            "role": "user",
            "content": f"The next local calendar day is {tomorrow}.\n{CHOICE}",
        },
    ]
    try:
        raw = chat(messages, num_predict=40)
    except Exception:
        return fallback_moment(now), "fallback"
    chosen = parse_choice(raw, now)
    if chosen is None:
        return fallback_moment(now), "fallback"
    return chosen, "model"
