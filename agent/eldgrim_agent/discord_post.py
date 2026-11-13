"""Ask the server bot to post one finished announcement. The model never sees the token.

Each announcement file carries a "Posted:" line that moves through
    no -> sending -> yes
and becomes "unknown" when the apply request was sent but its outcome is unclear.
An unknown announcement is never re-sent automatically; a person checks the channel
and then uses `eldgrim post --resend NAME` if it really did not appear.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
from pathlib import Path

CONFIG_PATH = Path(
    os.environ.get("ELDGRIM_DISCORD", Path.home() / ".config" / "eldgrim" / "discord.toml")
)

# Truthful audit notes. The bot records the note with the applied plan.
APPROVAL_SCHEDULED = (
    "Scheduled run from the wake timer. Not reviewed by a person before posting; "
    "standing approval for the daily proclamation is recorded in docs/DECISIONS.md (2026-11-11)."
)
APPROVAL_MANUAL = "The creative started `eldgrim run` by hand; a run includes posting its announcement."
APPROVAL_POST = "The creative ran `eldgrim post` for {name}."
APPROVAL_REHEARSAL = (
    "Wake test started by the creative with `eldgrim wake-test`; the computer slept, "
    "the timer woke it, and this run posted."
)
REHEARSAL_FLAG = Path(os.environ.get("ELDGRIM_REHEARSAL_FLAG", "/run/eldgrim/rehearsal"))


def approval_for(scheduled: bool, *, officer: bool = False) -> str:
    """The truthful audit note for a run."""
    if scheduled and REHEARSAL_FLAG.is_file():
        note = APPROVAL_REHEARSAL
    else:
        note = APPROVAL_SCHEDULED if scheduled else APPROVAL_MANUAL
    if officer:
        note += " This message is the daily note for Hearthkeepers and Hearthwardens."
    return note

ZERO_WIDTH = "​"
MENTION = re.compile(r"<(@[!&]?|#)(\d+)>")


class PostError(RuntimeError):
    pass


class AmbiguousPost(PostError):
    """The apply request left this computer, but whether it posted is unknown."""


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
        loaded: dict[str, object] = {
            "host": values["ssh_host"],
            "identity": values["ssh_identity"],
            "actor": int(values["actor"]),
            "channel": int(values["channel"]),
        }
    except (KeyError, ValueError) as exc:
        raise PostError("Discord config needs ssh_host, ssh_identity, actor, and channel.") from exc
    if values.get("officer_channel"):
        try:
            loaded["officer_channel"] = int(values["officer_channel"])
        except ValueError as exc:
            raise PostError("The Hearthkeeper channel is not a number.") from exc
    return loaded


def defuse_mentions(text: str) -> str:
    """Make @everyone, @here, and user/role/channel mentions inert text."""
    text = re.sub(r"@(everyone|here)", "@" + ZERO_WIDTH + r"\1", text, flags=re.IGNORECASE)
    return MENTION.sub(lambda m: "<" + ZERO_WIDTH + m.group(1) + m.group(2) + ">", text)


def operation(channel: int, text: str) -> dict[str, object]:
    body = defuse_mentions(text.strip())
    if not 1 <= len(body) <= 2000:
        raise PostError("The announcement must be 1–2000 characters.")
    if channel <= 0:
        raise PostError("The announcements channel is not set.")
    return {"action": "announce", "channel": channel, "text": body}


def control(config: dict[str, object], request: dict[str, object], runner=None, *, sent_is_ambiguous=False) -> dict:
    payload = (json.dumps(request) + "\n").encode()
    command = [
        "ssh",
        "-i",
        str(config["identity"]),
        "-o",
        "IdentitiesOnly=yes",
        "-o",
        "BatchMode=yes",
        "-o",
        "ConnectTimeout=20",
        str(config["host"]),
        "sudo -n -u eldgrim /usr/local/bin/eldgrim-control",
    ]
    fail = AmbiguousPost if sent_is_ambiguous else PostError
    run = runner or subprocess.run
    try:
        completed = run(command, input=payload, capture_output=True, timeout=120, check=False)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise fail(f"The bot control call failed: {exc}") from exc
    if completed.returncode != 0 and not completed.stdout:
        detail = (completed.stderr or b"").decode(errors="replace")[:300]
        raise fail(detail or "The bot control call failed.")
    try:
        reply = json.loads(completed.stdout.decode())
    except json.JSONDecodeError as exc:
        raise fail("The bot control reply was not JSON.") from exc
    if not reply.get("ok"):
        raise fail(str(reply.get("error") or "The bot refused the request."))
    return reply


def publish(
    text: str,
    *,
    approval: str,
    config_path: Path | None = None,
    runner=None,
    before_apply=None,
    channel: int | None = None,
) -> dict[str, object]:
    """Preview, then apply the same plan. `before_apply(plan)` runs just before the apply is sent."""
    config = load_config(config_path)
    target = int(config["channel"] if channel is None else channel)
    preview = control(
        config,
        {"method": "preview", "actor": config["actor"], "operation": operation(target, text)},
        runner,
    )
    plan = str(preview["result"]["plan"])
    if before_apply is not None:
        before_apply(plan)
    applied = control(
        config,
        {
            "method": "apply",
            "actor": config["actor"],
            "plan": plan,
            "confirmation": "APPLY-" + plan,
            "approval_note": approval,
        },
        runner,
        sent_is_ambiguous=True,
    )
    status = applied["result"].get("status")
    if status != "applied":
        raise AmbiguousPost(f"The bot did not confirm the post ({status}).")
    return {"posted": True, "plan": plan}


def _set_state(path: Path, state: str, plan: str | None = None) -> None:
    lines = path.read_text(encoding="utf-8").splitlines()
    out: list[str] = []
    for line in lines:
        if line.startswith("Posted: "):
            out.append(f"Posted: {state}")
            if plan:
                out.append(f"Plan: {plan}")
        elif line.startswith("Plan: ") and plan:
            continue
        else:
            out.append(line)
    tmp = path.with_suffix(".tmp")
    tmp.write_text("\n".join(out) + "\n", encoding="utf-8")
    tmp.chmod(0o600)
    os.replace(tmp, path)


def state(path: Path) -> str:
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("Posted: "):
            return line[len("Posted: "):].strip()
    return ""


def post_officer(text: str, *, approval: str, config_path: Path | None = None, runner=None) -> None:
    """Post the keepers' note. It is not an announcement file and is not sent twice by `eldgrim post`."""
    config = load_config(config_path)
    channel = config.get("officer_channel")
    if not isinstance(channel, int):
        raise PostError("The Hearthkeeper channel is not configured.")
    publish(text, approval=approval, config_path=config_path, runner=runner, channel=channel)


def post_file(path: Path, *, approval: str, config_path: Path | None = None, runner=None) -> None:
    """Post one announcement file and keep its Posted: line truthful at every step."""
    if state(path) != "no":
        raise PostError(f"{path.name} is marked '{state(path)}', not 'no'; it will not be sent again.")
    text = announcement_text(path)
    try:
        publish(
            text,
            approval=approval,
            config_path=config_path,
            runner=runner,
            before_apply=lambda plan: _set_state(path, "sending", plan),
        )
    except AmbiguousPost:
        _set_state(path, "unknown")
        raise
    except PostError:
        if state(path) == "sending":
            _set_state(path, "unknown")
        raise
    _set_state(path, "yes")


def latest_unposted(directory: Path) -> Path | None:
    for path in sorted(directory.glob("*.md"), reverse=True):
        if state(path) == "no":
            return path
    return None


def uncertain(directory: Path) -> list[Path]:
    return [p for p in sorted(directory.glob("*.md")) if state(p) in {"sending", "unknown"}]


def reset_for_resend(path: Path) -> None:
    if state(path) not in {"sending", "unknown"}:
        raise PostError(f"{path.name} is marked '{state(path)}'; only uncertain posts can be reset.")
    _set_state(path, "no")


def announcement_text(path: Path) -> str:
    lines = path.read_text(encoding="utf-8").splitlines()
    starts = [i for i, line in enumerate(lines) if line.startswith("Posted: ")]
    if not starts:
        raise PostError(f"{path.name} is not an announcement.")
    rest = lines[starts[0] + 1 :]
    while rest and (rest[0] == "" or rest[0].startswith("Plan: ")):
        rest = rest[1:]
    text = "\n".join(rest).strip()
    if not text:
        raise PostError(f"{path.name} has no announcement text.")
    return text
