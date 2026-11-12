# Eldgrim Agent — Operations

**Status:** `eldgrim run` writes an announcement, posts it through the server bot, and chooses the next moment. The root-owned wake path in `agent/systemd/` is installed once with `sudo agent/systemd/install-wake.sh`.  
**Target environment:** Nobara Linux, timezone Europe/Stockholm.

## 1. Scheduling model

Eldgrim does not run at a fixed hour. At the end of a run it chooses one moment on the next local calendar day, and the application saves it to `~/.local/share/eldgrim/next-run.json`. A system timer with `WakeSystem=true` wakes the computer for that moment, following the pattern used by Anskar Grotzschnapf. `Persistent=false`, so a missed day is skipped rather than replayed.

A run can be asked for at any time with `eldgrim run`. A test run posts, like a scheduled one, because posting is part of what is being tested. Asking for another run posts another announcement.

## 2. The wake path and who runs what

Root runs only root-owned files. Eldgrim's Python code always runs as the user.

| File (installed root-owned) | Runs as | Job |
| --- | --- | --- |
| `/usr/local/libexec/eldgrim/eldgrim-wake-helper` | root | Reads the saved moment as plain data, accepts only a timestamp in the coming two days, writes the timer, and decides about returning to sleep |
| `eldgrim-arm.path` → `eldgrim-arm.service` | root | Re-arms the timer whenever a run saves a new moment, including a test run |
| `eldgrim-daily.timer` | — | One absolute `OnCalendar` stamp, `WakeSystem=true`, `Persistent=false` |
| `eldgrim-daily.service` | root, then the user | `begin` notes whether the timer woke the machine and waits 30 seconds for the network; `systemd-inhibit` holds sleep off around `runuser`, which runs `eldgrim run --scheduled` as the user; `finish` re-arms and returns to sleep |

The sources are in `agent/systemd/`. Install or update them with:

~~~bash
sudo agent/systemd/install-wake.sh
~~~

The installer also removes the earlier user-owned wake script and gives back any files in `~/.local/share/eldgrim/` that a root run had left root-owned.

## 3. Returning to sleep

After a scheduled run the helper suspends the computer again only when both are true:

- The computer resumed from sleep within five minutes before the run, so the timer woke it.
- No other program holds a **sleep** inhibitor in block mode. Idle blocks, such as falcond's game profile, only stop automatic idle-suspend and do not count; delay-mode agents such as NetworkManager do not count either. Plasma's idle hint is not used, because it stays "not idle" for minutes after an RTC wake. When something does block, the journal names it.

If the computer was already awake, or anything else holds sleep off, it is left awake. Eldgrim never suspends after a run started by hand. A wake counts only when `systemd-sleep` logged "returned from sleep" within five minutes before the run, so a suspend that failed is never mistaken for one.

### Wake test

`eldgrim wake-test` (default 1 minute, `--minutes 1` to `30`) proves the whole cycle in about a minute and a half: the wake is timed to the second, and the timer fires within a second (`AccuracySec=1s`). After your sudo password, the helper arms the timer a few minutes ahead and puts the computer to sleep. The timer wakes it, Eldgrim writes and posts one announcement through the bot with an audit note that names the wake test, chooses its next moment, and the computer sleeps again if nothing else holds it awake. The timer is then re-armed for Eldgrim's chosen moment. Check the result with `sudo journalctl -u eldgrim-daily.service -b --since -1h` and the newest file in `~/.local/share/eldgrim/logs/`.

## 4. Missed runs and machine availability

- If the computer is powered off at the chosen moment, that day is skipped. The next choice happens the next time a run finishes.
- Suspend is different from power-off. The system timer wakes the machine from suspend; a user timer would not.
- If the saved moment is missing or invalid, the helper leaves the existing timer alone and logs why.
- Lingering is enabled for this user, so the user session exists for `runuser`.

## 5. Posting and audit notes

Posting goes through the server bot's preview-and-apply control. Each announcement file records `Posted: no`, `sending`, `yes`, or `unknown`. If the apply request leaves this computer but its outcome is unclear, the file becomes `unknown` and is never re-sent automatically; check the channel, then use `eldgrim post --resend NAME` only if it is missing. The approval note sent to the bot says truthfully whether the post came from the wake timer, a run started by hand, or `eldgrim post`. Mentions in the text are made inert before sending, and the bot sends announcements with no allowed mentions.

The SSH key for the server is passphrase-protected, so a run reaches it through the user's ssh-agent at `/run/user/<uid>/ssh-agent.socket`, which the wake service passes in. After a reboot the key must be unlocked in the session again, or a scheduled run cannot post.

## 6. Service lifecycle

For the full agent, beyond today's announcement runner, the one-shot service should:

1. Start the Python agent in its project virtual environment.
2. Load non-secret configuration and private credentials from outside Git.
3. Acquire a process lock.
4. Validate the database and local dependencies.
5. Gather eligible @Eldgrim mentions for question selection, and any separately authorized **shared guild-channel and WoW guild-chat** observations for memory interpretation. Collection may use temporary server staging and/or a bot-mediated collection round (mechanism open). Do not collect private conversations or whispers as narrative inputs.
6. During the daily session, use Ollama as needed to select at most one question per member, randomly or for narrative suitability, and optionally answer.
7. Persist allowed outcomes and **selected interpreted memories only in the founder's PC-local database**; discard temporary mention and raw guild-message collections after processing, including server-side raw staging. Start a fresh collection period; never roll over unselected questions.
8. Unload the model and close resources.
9. Release the lock and exit with an accurate status code.

The service should use a bounded execution timeout. A failed session must not leave an agent loop running.

## 7. Local paths

Intended separation:

~~~text
~/.config/eldgrim/
    config.toml
    secrets.env

~/.local/share/eldgrim/
    eldgrim.sqlite3
    backups/
    logs/
~~~

These are proposed paths. The implementation may refine them, but no secret or runtime database belongs inside the repository.

Restrict secret-file permissions to the local user. Do not place the bot token in source code, command history, committed examples, or logs.

## 8. Ollama lifecycle

- Connect to the local Ollama API, normally through 127.0.0.1:11434.
- Confirm that the expected model tag is installed before the run.
- Load the model for the reasoning session.
- Keep it available through the bounded tool-call loop.
- Explicitly unload it when the session ends.
- Verify that GPU memory returns to the expected idle state.

The current local Qwen3 8B model is an initial candidate. The exact tag, installed Ollama version, and tool-calling behavior must be recorded during local verification. Do not assume that a model name in documentation matches the installed tag.

## 9. Logs and diagnostics

The wake path logs to the system journal. Each run also writes `~/.local/share/eldgrim/logs/run-*.json` with the outcome, the announcement, any problem, and the next moment. Logs contain no tokens.

~~~bash
systemctl list-timers eldgrim-daily.timer
systemctl status eldgrim-daily.service eldgrim-arm.path
journalctl -u eldgrim-daily.service -u eldgrim-arm.service
ollama list
~~~

## 10. Failure handling

- Respect Discord rate limits and retry guidance.
- Use bounded exponential backoff for transient network failures.
- Do not advance channel cursors after incomplete intake or failed database writes.
- Do not create a durable unanswered-question queue. Define the behavior of temporary mention collections on failed or interrupted runs before implementation.
- Assign unique action identifiers, record ambiguous send/role/sanction/reward/transfer outcomes, and reconcile external state before retrying; never blindly duplicate a consequential action (Q149).
- Release the process lock during all normal and exceptional exits.
- Ensure model unloading is attempted during cleanup.
- Keep a minimal run outcome for success, partial completion and failure without full raw messages, inferred profiles or fabricated success (Q146, Q148).

## 11. Confirmed administrative operation boundaries — questions 141–150

- Use only registered purpose-specific tools; the bot/application independently checks schemas, targets, delegated authority and per-run limits (Q141–142).
- Authorized channel/role/permission management may be autonomous once a validated bot operation replaces the **current** manual preview-and-approval path. Exceptional server/ownership/infrastructure/security actions require explicit founder authorization (Q143–144).
- Treat all guild messages and external content as untrusted data, not operational instructions (Q145).
- Fail safely; preserve minimal diagnostic and idempotency state without a permanent raw-message archive or unanswered-question queue (Q146).
- When the PC is offline, the server bot continues existing services and explicitly predefined emergency safeguards, not AI-authored decisions. Any authorized shared-channel staging must remain temporary and subject to Q138 (Q147).
- Audit actions with minimal metadata, deduplicate by unique action ID, reconcile ambiguous results, and verify facts before consequential decisions (Q148–150).

**Implementation status:** These operational procedures and AI tool integrations are not implemented or verified.

## 12. Backups and maintenance

Before production use, implement and document:

- A consistent SQLite backup procedure.
- Backup rotation that keeps routine backups no more than 30 days (Q137).
- A restore test.
- Schema migration and rollback expectations.
- Memory inspection, export, correction, and deletion.
- A procedure for rotating the Discord token.
- A procedure for disabling the timer and revoking the bot's channel permissions.

## 13. Deployment status

The announcement runner, Discord posting through the server bot, and the wake path sources exist. The wake path runs only after `install-wake.sh` has been run with sudo. There is no SQLite roster database, mention intake, or credential file in this repository.
