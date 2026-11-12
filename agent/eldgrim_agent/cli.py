"""Commands: run (write, post, choose the next moment) and post (send a kept announcement)."""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

from eldgrim_agent.discord_post import (
    APPROVAL_POST,
    PostError,
    announcement_text,
    latest_unposted,
    post_file,
    reset_for_resend,
    uncertain,
)
from eldgrim_agent.paths import ANNOUNCEMENTS, MODEL
from eldgrim_agent.run import execute


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="eldgrim")
    sub = parser.add_subparsers(dest="command", required=True)
    run = sub.add_parser("run", help="write one announcement, post it, and choose the next day")
    run.add_argument(
        "--scheduled",
        action="store_true",
        help="used by the wake timer; records the post as scheduled rather than started by hand",
    )
    post = sub.add_parser("post", help="post the newest announcement that has not been posted")
    post.add_argument(
        "--resend",
        metavar="NAME",
        help="after checking the channel, mark an uncertain announcement as not posted and send it",
    )
    wake = sub.add_parser("wake-test", help="sleep now, let the timer wake the computer, and post")
    wake.add_argument("--minutes", type=int, default=1, help="minutes until the wake, 1-30 (default 1)")
    args = parser.parse_args(argv)
    if args.command == "wake-test":
        return wake_test(args.minutes)
    if args.command == "post":
        return post_latest(args.resend)
    report = execute(scheduled=args.scheduled)
    print(_format_run(report))
    return 1 if report.get("error") else 0


HELPER = Path("/usr/local/libexec/eldgrim/eldgrim-wake-helper")


def wake_test(minutes: int) -> int:
    if not 1 <= minutes <= 30:
        print("Choose between 1 and 30 minutes.")
        return 2
    if not HELPER.is_file():
        print("The wake path is not installed. Run: sudo agent/systemd/install-wake.sh")
        return 1
    print(
        f"Wake test: the computer goes to sleep now and the timer wakes it in {minutes} minute(s).\n"
        "Eldgrim then writes and posts one announcement, chooses its next moment, and stops all of\n"
        "its activity, so the desktop's idle timer can put the computer to sleep. Check afterwards with:\n"
        "  journalctl -u eldgrim-daily.service -b --since -1h\n"
        "sudo asks for your password next."
    )
    sys.stdout.flush()
    os.execvp("sudo", ["sudo", str(HELPER), "rehearse", str(minutes)])
    return 1


def post_latest(resend: str | None = None) -> int:
    try:
        if resend:
            path = ANNOUNCEMENTS / resend
            if not path.is_file():
                print(f"No announcement named {resend}.")
                return 1
            reset_for_resend(path)
        else:
            unclear = uncertain(ANNOUNCEMENTS)
            if unclear:
                names = ", ".join(p.name for p in unclear)
                print(
                    f"Uncertain earlier posts: {names}. Check the channel; if one is missing, "
                    "use `eldgrim post --resend NAME`."
                )
            path = latest_unposted(ANNOUNCEMENTS)
            if path is None:
                print("No unposted announcement.")
                return 1
        text = announcement_text(path)
        post_file(path, approval=APPROVAL_POST.format(name=path.name))
    except PostError as exc:
        print(f"Not posted: {exc}")
        return 1
    print(text)
    print()
    print(f"Posted: yes ({path.name})")
    return 0


def _format_run(report: dict[str, object]) -> str:
    lines = [f"Model: {MODEL}", "Posted: yes" if report.get("posted") else "Posted: no", ""]
    if report.get("announcement"):
        lines.append(str(report["announcement"]).strip())
    if report.get("error"):
        lines.append(f"Problem: {report['error']}")
    lines.extend(
        [
            "",
            f"Next run: {report.get('next_at') or 'not saved'} ({report.get('next_source') or '-'})",
            "The wake timer re-arms itself from that choice.",
        ]
    )
    return "\n".join(lines)


if __name__ == "__main__":
    sys.exit(main())
