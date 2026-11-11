"""Commands: run on demand, or arm the wake timer from the saved choice."""

from __future__ import annotations

import argparse
import sys

from eldgrim_agent.discord_post import PostError, announcement_text, latest_unposted, mark_posted, publish
from eldgrim_agent.paths import ANNOUNCEMENTS, MODEL
from eldgrim_agent.run import execute
from eldgrim_agent.schedule import install_system_timer, load_choice


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="eldgrim_agent")
    sub = parser.add_subparsers(dest="command", required=True)
    run = sub.add_parser("run", help="write one local announcement and choose the next day")
    run.add_argument(
        "--scheduled",
        action="store_true",
        help="mark this run as the wake timer's run; it still does the same work",
    )
    sub.add_parser("install-timer", help="arm the system wake timer from the saved moment")
    sub.add_parser("post", help="post the newest unposted announcement through the Discord bot")
    args = parser.parse_args(argv)
    if args.command == "post":
        return post_latest()
    if args.command == "install-timer":
        report = install_system_timer(load_choice())
        print(_format_wake(report))
        return 0 if report.get("installed") or report.get("reason") else 1
    report = execute(scheduled=args.scheduled)
    print(_format_run(report))
    return 1 if report.get("error") else 0


def post_latest() -> int:
    path = latest_unposted(ANNOUNCEMENTS)
    if path is None:
        print("No unposted announcement.")
        return 1
    try:
        text = announcement_text(path)
        publish(text)
        mark_posted(path)
    except PostError as exc:
        print(f"Not posted: {exc}")
        return 1
    print(text)
    print()
    print(f"Posted: yes ({path.name})")
    return 0


def _format_run(report: dict[str, object]) -> str:
    lines = [
        f"Model: {MODEL}",
        "Posted: yes" if report.get("posted") else "Posted: no",
        "",
    ]
    if report.get("error"):
        lines.append(f"Announcement failed: {report['error']}")
    else:
        lines.append(str(report.get("announcement") or "").strip())
    lines.extend(
        [
            "",
            f"Next run: {report.get('next_at')} ({report.get('next_source')})",
            _wake_line(report),
        ]
    )
    return "\n".join(lines)


def _format_wake(report: dict[str, object]) -> str:
    if report.get("installed"):
        return f"Wake timer armed for {report.get('at')}."
    return _wake_line(report)


def _wake_line(report: dict[str, object]) -> str:
    if report.get("wake_installed") or report.get("installed"):
        return f"Wake timer armed for {report.get('next_at') or report.get('at')}."
    reason = report.get("wake_reason") or report.get("reason") or "not armed"
    return f"Wake timer not armed ({reason}). The chosen time is saved on this computer."


if __name__ == "__main__":
    sys.exit(main())
