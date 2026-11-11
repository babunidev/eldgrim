"""Ask the server bot to post one finished announcement. The model never sees the token."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

CONFIG_PATH = Path(
    os.environ.get("ELDGRIM_DISCORD", Path.home() / ".config" / "eldgrim" / "discord.toml")
)
APPROVAL = "Creative asked Eldgrim to post the announcement it kept."


class PostError(RuntimeError):
    pass


def load_config(path: Path | None = None) -> dict[str, object]:
    source = path or CONFIG_PATH
    if not source.is_file():
        raise PostError(f"Discord posting is not configured ({source}).")
    values: dict[str, str] = {}
    for line in source.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip().strip('"').strip("'")
    try:
        return {
            "host": values["ssh_host"],
            "identity": values["ssh_identity"],
            "actor": int(values["actor"]),
            "channel": int(values["channel"]),
        }
    except (KeyError, ValueError) as exc:
        raise PostError("Discord config needs ssh_host, ssh_identity, actor, and channel.") from exc


def operation(channel: int, text: str) -> dict[str, object]:
    body = text.strip()
    if not 1 <= len(body) <= 2000:
        raise PostError("The announcement must be 1–2000 characters.")
    if channel <= 0:
        raise PostError("The announcements channel is not set.")
    return {"action": "announce", "channel": channel, "text": body}


def control(config: dict[str, object], request: dict[str, object], runner=None) -> dict:
    payload = (json.dumps(request) + "\n").encode()
    command = [
        "ssh",
        "-i",
        str(config["identity"]),
        "-o",
        "IdentitiesOnly=yes",
        "-o",
        "BatchMode=yes",
        str(config["host"]),
        "sudo -n -u eldgrim /usr/local/bin/eldgrim-control",
    ]
    run = runner or subprocess.run
    try:
        completed = run(
            command,
            input=payload,
            capture_output=True,
            timeout=120,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise PostError(f"The bot control call failed: {exc}") from exc
    if completed.returncode != 0 and not completed.stdout:
        detail = (completed.stderr or b"").decode(errors="replace")[:300]
        raise PostError(detail or "The bot control call failed.")
    try:
        reply = json.loads(completed.stdout.decode())
    except json.JSONDecodeError as exc:
        raise PostError("The bot control reply was not JSON.") from exc
    if not reply.get("ok"):
        raise PostError(str(reply.get("error") or "The bot refused the request."))
    return reply


def publish(text: str, *, config_path: Path | None = None, runner=None) -> dict[str, object]:
    config = load_config(config_path)
    preview = control(
        config,
        {
            "method": "preview",
            "actor": config["actor"],
            "operation": operation(int(config["channel"]), text),
        },
        runner,
    )
    plan = str(preview["result"]["plan"])
    applied = control(
        config,
        {
            "method": "apply",
            "actor": config["actor"],
            "plan": plan,
            "confirmation": "APPLY-" + plan,
            "approval_note": APPROVAL,
        },
        runner,
    )
    status = applied["result"].get("status")
    if status != "applied":
        raise PostError(f"The bot did not post ({status}).")
    return {"posted": True}


def mark_posted(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    path.write_text(text.replace("Posted: no", "Posted: yes", 1), encoding="utf-8")
    path.chmod(0o600)


def latest_unposted(directory: Path) -> Path | None:
    files = sorted(directory.glob("*.md"))
    for path in reversed(files):
        body = path.read_text(encoding="utf-8")
        if "Posted: no" in body:
            return path
    return None


def announcement_text(path: Path) -> str:
    lines = path.read_text(encoding="utf-8").splitlines()
    try:
        start = lines.index("Posted: no")
    except ValueError as exc:
        raise PostError(f"{path.name} has already been posted or is not an announcement.") from exc
    rest = lines[start + 1 :]
    while rest and rest[0] == "":
        rest = rest[1:]
    text = "\n".join(rest).strip()
    if not text:
        raise PostError(f"{path.name} has no announcement text.")
    return text
