"""Render the wake timer. Installing it into /etc needs root, as Anskar's wake timer does."""

from __future__ import annotations

import json
import os
import pwd
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

from eldgrim_agent.paths import BIN, NEXT_RUN_PATH, REPO_ROOT, STAGING, ensure_runtime

SERVICE_NAME = "eldgrim-daily.service"
TIMER_NAME = "eldgrim-daily.timer"
SYSTEM_UNIT_DIR = Path("/etc/systemd/system")


def runtime_user() -> pwd.struct_passwd:
    if os.geteuid() != 0:
        return pwd.getpwuid(os.getuid())
    name = os.environ.get("ELDGRIM_USER") or os.environ.get("SUDO_USER") or "babuni"
    return pwd.getpwnam(name)


def user_unit_dir() -> Path:
    return Path(runtime_user().pw_dir) / ".config" / "systemd" / "user"


def render_timer(when: datetime) -> str:
    local = when.astimezone()
    stamp = local.strftime("%Y-%m-%d %H:%M:00")
    return (
        "[Unit]\n"
        "Description=Wake the computer for Eldgrim's next chosen moment\n"
        "\n"
        "[Timer]\n"
        f"OnCalendar={stamp}\n"
        "Persistent=false\n"
        "WakeSystem=true\n"
        "AccuracySec=1min\n"
        "RandomizedDelaySec=0\n"
        f"Unit={SERVICE_NAME}\n"
        "\n"
        "[Install]\n"
        "WantedBy=timers.target\n"
    )


def render_system_service(script: Path) -> str:
    return (
        "[Unit]\n"
        "Description=Eldgrim's one-shot run after the machine wakes\n"
        "After=network-online.target\n"
        "Wants=network-online.target\n"
        "\n"
        "[Service]\n"
        "Type=oneshot\n"
        f"ExecStart={script}\n"
        "Nice=10\n"
        "\n"
        "[Install]\n"
        "WantedBy=multi-user.target\n"
    )


def render_wake_script() -> str:
    user = runtime_user()
    python = shutil.which("python3") or "/usr/bin/python3"
    agent = REPO_ROOT / "agent"
    runtime = Path(user.pw_dir) / ".local" / "share" / "eldgrim"
    return f"""#!/bin/bash
# Wake path. Root holds sleep off, the user runs Eldgrim, then root arms the next wake.
set -u
export PYTHONPATH={agent}
export ELDGRIM_RUNTIME={runtime}
export ELDGRIM_USER={user.pw_name}
status=0
/usr/bin/systemd-inhibit --what=idle:sleep:handle-lid-switch --who=Eldgrim \\
  --why="Eldgrim daily run" --mode=block \\
  /usr/bin/runuser -u {user.pw_name} -- env \\
  HOME={user.pw_dir} USER={user.pw_name} LOGNAME={user.pw_name} \\
  PYTHONPATH={agent} ELDGRIM_RUNTIME={runtime} \\
  XDG_RUNTIME_DIR=/run/user/{user.pw_uid} \\
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/{user.pw_uid}/bus \\
  {python} -m eldgrim_agent run --scheduled || status=$?
{python} -m eldgrim_agent install-timer || true
exit "$status"
"""


def render_user_service() -> str:
    python = shutil.which("python3") or "/usr/bin/python3"
    agent = REPO_ROOT / "agent"
    return (
        "[Unit]\n"
        "Description=Eldgrim on-demand run\n"
        "\n"
        "[Service]\n"
        "Type=oneshot\n"
        f"WorkingDirectory={REPO_ROOT}\n"
        f"Environment=PYTHONPATH={agent}\n"
        "ExecStart=/usr/bin/systemd-inhibit "
        "--what=idle:sleep:handle-lid-switch --who=Eldgrim "
        '--why="Eldgrim run" --mode=block '
        f"{python} -m eldgrim_agent run\n"
        "Nice=10\n"
    )


def save_choice(when: datetime, source: str) -> None:
    ensure_runtime()
    payload = {
        "at": when.astimezone().isoformat(timespec="minutes"),
        "source": source,
    }
    NEXT_RUN_PATH.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    NEXT_RUN_PATH.chmod(0o600)


def load_choice() -> datetime | None:
    if not NEXT_RUN_PATH.is_file():
        return None
    payload = json.loads(NEXT_RUN_PATH.read_text(encoding="utf-8"))
    text = str(payload.get("at", "")).strip()
    if not text:
        return None
    return datetime.fromisoformat(text)


def stage_units(when: datetime) -> dict[str, str]:
    """Write the timer, service, and wake script where a later root install can copy them."""
    ensure_runtime()
    script = BIN / "eldgrim-wake.sh"
    script.write_text(render_wake_script(), encoding="utf-8")
    script.chmod(0o755)
    timer = STAGING / TIMER_NAME
    service = STAGING / SERVICE_NAME
    timer.write_text(render_timer(when), encoding="utf-8")
    service.write_text(render_system_service(script), encoding="utf-8")
    user_dir = user_unit_dir()
    user_dir.mkdir(parents=True, exist_ok=True)
    user_service = user_dir / SERVICE_NAME
    user_service.write_text(render_user_service(), encoding="utf-8")
    if os.geteuid() != 0:
        _systemctl(["--user", "daemon-reload"])
    return {
        "script": str(script),
        "timer": str(timer),
        "service": str(service),
        "user_service": str(user_service),
    }


def install_system_timer(when: datetime | None = None) -> dict[str, object]:
    """Arm the RTC wake when this process is root. Otherwise leave the staged units."""
    chosen = when or load_choice()
    if chosen is None:
        return {"installed": False, "reason": "no next run has been chosen"}
    staged = stage_units(chosen)
    if os.geteuid() != 0:
        return {
            "installed": False,
            "reason": "root is required to write the wake timer",
            "at": chosen.astimezone().isoformat(timespec="minutes"),
            **staged,
        }
    SYSTEM_UNIT_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copy(staged["service"], SYSTEM_UNIT_DIR / SERVICE_NAME)
    shutil.copy(staged["timer"], SYSTEM_UNIT_DIR / TIMER_NAME)
    reloaded = _systemctl(["daemon-reload"]) == 0
    enabled = _systemctl(["enable", TIMER_NAME]) == 0
    restarted = _systemctl(["restart", TIMER_NAME]) == 0
    return {
        "installed": reloaded and enabled and restarted,
        "at": chosen.astimezone().isoformat(timespec="minutes"),
        "reloaded": reloaded,
        "enabled": enabled,
        "restarted": restarted,
        **staged,
    }


def _systemctl(args: list[str]) -> int:
    if shutil.which("systemctl") is None:
        return 1
    try:
        completed = subprocess.run(
            ["systemctl", *args],
            stdin=subprocess.DEVNULL,
            capture_output=True,
            timeout=30,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return 1
    return completed.returncode
