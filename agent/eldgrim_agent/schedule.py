"""Save the moment Eldgrim chose. Arming the wake timer is root's job, not this code's.

The root-owned helper installed by agent/systemd/install-wake.sh watches the saved
file, validates the timestamp as plain data, and writes the system wake timer.
Nothing in this package runs as root.
"""

from __future__ import annotations

import json
import os
from datetime import datetime

from eldgrim_agent.paths import NEXT_RUN_PATH, ensure_runtime


def save_choice(when: datetime, source: str) -> None:
    ensure_runtime()
    payload = {
        "at": when.astimezone().isoformat(timespec="minutes"),
        "source": source,
    }
    tmp = NEXT_RUN_PATH.with_suffix(".tmp")
    tmp.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    tmp.chmod(0o600)
    os.replace(tmp, NEXT_RUN_PATH)


def load_choice() -> datetime | None:
    if not NEXT_RUN_PATH.is_file():
        return None
    payload = json.loads(NEXT_RUN_PATH.read_text(encoding="utf-8"))
    text = str(payload.get("at", "")).strip()
    if not text:
        return None
    return datetime.fromisoformat(text)
