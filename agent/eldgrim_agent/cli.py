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
from eldgrim_agent.store import connect, set_opt_out, summary


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="eldgrim")
    sub = parser.add_subparsers(dest="command", required=True)
    run = sub.add_parser("run", help="refresh the guild, write one announcement, post it, and choose the next day")
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
    sub.add_parser("roster", help="print guild counts and names, with no chat text")
    opt_out = sub.add_parser("opt-out", help="keep a member's registration, and skip their keywords and standing")
    opt_out.add_argument("name")
    opt_in = sub.add_parser("opt-in", help="include a member in keywords and standing again")
    opt_in.add_argument("name")
    context = sub.add_parser("context", help="measure the approved reading without calling the model")
    context_sub = context.add_subparsers(dest="context_command", required=True)
    context_sub.add_parser("check", help="report whether the three tasks fit, including the largest input")
    compare = sub.add_parser("compare", help="compare today's model with another, blind, and do not post")
    compare.add_argument("--against", required=True, help="the other local Ollama model tag, already pulled")
    compare.add_argument("--runs", type=int, default=5, help="drafts of each kind, 1-13 (default 5)")
    compare.add_argument("--brief", type=Path, default=None, help="a local sample brief, if none has been stored")
    wake = sub.add_parser("wake-test", help="sleep now, let the timer wake the computer, and post")
    wake.add_argument("--minutes", type=int, default=1, help="minutes until the wake, 1-30 (default 1)")
    args = parser.parse_args(argv)
    if args.command == "wake-test":
        return wake_test(args.minutes)
    if args.command == "roster":
        db = connect()
        try:
            print(summary(db), end="")
        finally:
            db.close()
        return 0
    if args.command in {"opt-out", "opt-in"}:
        db = connect()
        try:
            print(set_opt_out(db, args.name, args.command == "opt-out"))
        finally:
            db.close()
        return 0
    if args.command == "post":
        return post_latest(args.resend)
    if args.command == "context":
        return context_check()
    if args.command == "compare":
        return run_compare(args.runs, args.brief, args.against)
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


def context_check() -> int:
    from eldgrim_agent.context import find_problems

    problems = find_problems()
    if problems:
        print("Context overflow.")
        for item in problems:
            print(item)
        return 1
    print("The context fits.")
    return 0


def run_compare(runs: int, sample: Path | None, against: str) -> int:
    from eldgrim_agent.compare import compare_proclamations

    try:
        texts, key = compare_proclamations(runs, sample, against=against)
    except (FileNotFoundError, RuntimeError, ValueError) as exc:
        print(str(exc))
        return 1
    print(f"Texts: {texts}")
    print(f"Key: {key}")
    return 0


def _format_run(report: dict[str, object]) -> str:
    lines = [
        f"Model: {MODEL}",
        "Posted: yes" if report.get("posted") else "Posted: no",
        "Officer note: yes" if report.get("officer_posted") else "Officer note: no",
        "",
    ]
    if report.get("announcement"):
        lines.append(str(report["announcement"]).strip())
    if report.get("forge"):
        lines.append(f"Forge: {report['forge']}")
    if report.get("chat"):
        lines.append(f"Guild chat: {report['chat']}")
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
