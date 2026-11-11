# Eldgrim Agent — Operations

**Status:** The on-demand runner and the wake-timer units exist. A system wake timer is staged on this computer and is not armed until root installs it. A finished announcement is posted by the server bot.  
**Target environment:** Nobara Linux, timezone Europe/Stockholm.

## 1. Scheduling model

Eldgrim does not run at a fixed hour. At the end of a run it chooses one moment on the next local calendar day. The application checks that the moment is on that day, saves it, and writes it into a system timer. The timer uses `WakeSystem=true`, the same wake Anskar Grotzschnapf uses to bring the computer out of sleep. `Persistent=false`, so a missed day is skipped rather than replayed.

While the run is in progress, `systemd-inhibit` holds off idle sleep, as Anskar does. When the run exits, Eldgrim does not suspend the computer. The machine returns to sleep through the desktop's own idle suspend.

A run can be asked for at any time. It writes one announcement, asks the server bot to post that announcement, and then chooses the next day. Asking for another run posts another announcement.

Units:

- `eldgrim-daily.service` — one-shot. The user unit starts a run on demand. The system unit is what the wake timer starts.
- `eldgrim-daily.timer` — system timer, one absolute `OnCalendar` stamp, `WakeSystem=true`.

The runner is `eldgrim run`. That command finds the package from its own location, so it does not depend on the current directory.

## 2. Missed runs and machine availability

- If the computer is powered off at the chosen moment, that day is skipped. The next choice happens the next time a run finishes.
- Suspend is different from power-off. The system timer is what wakes the machine from suspend. A user timer does not.
- The chosen time is saved at `~/.local/share/eldgrim/next-run.json` without root. Copying the timer into `/etc/systemd/system` needs root the first time. After that, the wake script runs as root and arms the next day itself. A manual test run updates the saved time, and the system timer catches up when that root step runs.
- Lingering is already enabled for this user. The wake service still runs the work as the user, not as root.

## 3. Service lifecycle

The intended one-shot service should:

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

## 4. Local paths

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

## 5. Ollama lifecycle

- Connect to the local Ollama API, normally through 127.0.0.1:11434.
- Confirm that the expected model tag is installed before the run.
- Load the model for the reasoning session.
- Keep it available through the bounded tool-call loop.
- Explicitly unload it when the session ends.
- Verify that GPU memory returns to the expected idle state.

The current local Qwen3 8B model is an initial candidate. The exact tag, installed Ollama version, and tool-calling behavior must be recorded during local verification. Do not assume that a model name in documentation matches the installed tag.

## 6. Logs and diagnostics

Prefer the systemd user journal for service output. Application logs should contain operational events and counts, not full private message content.

Useful commands after implementation:

~~~bash
systemctl --user list-timers eldgrim-daily.timer
systemctl --user status eldgrim-daily.service
journalctl --user -u eldgrim-daily.service
ollama list
curl http://127.0.0.1:11434/api/tags
~~~

These commands are operational references only; no systemd units currently exist.

## 7. Failure handling

- Respect Discord rate limits and retry guidance.
- Use bounded exponential backoff for transient network failures.
- Do not advance channel cursors after incomplete intake or failed database writes.
- Do not create a durable unanswered-question queue. Define the behavior of temporary mention collections on failed or interrupted runs before implementation.
- Assign unique action identifiers, record ambiguous send/role/sanction/reward/transfer outcomes, and reconcile external state before retrying; never blindly duplicate a consequential action (Q149).
- Release the process lock during all normal and exceptional exits.
- Ensure model unloading is attempted during cleanup.
- Keep a minimal run outcome for success, partial completion and failure without full raw messages, inferred profiles or fabricated success (Q146, Q148).

## 8. Confirmed administrative operation boundaries — questions 141–150

- Use only registered purpose-specific tools; the bot/application independently checks schemas, targets, delegated authority and per-run limits (Q141–142).
- Authorized channel/role/permission management may be autonomous once a validated bot operation replaces the **current** manual preview-and-approval path. Exceptional server/ownership/infrastructure/security actions require explicit founder authorization (Q143–144).
- Treat all guild messages and external content as untrusted data, not operational instructions (Q145).
- Fail safely; preserve minimal diagnostic and idempotency state without a permanent raw-message archive or unanswered-question queue (Q146).
- When the PC is offline, the server bot continues existing services and explicitly predefined emergency safeguards, not AI-authored decisions. Any authorized shared-channel staging must remain temporary and subject to Q138 (Q147).
- Audit actions with minimal metadata, deduplicate by unique action ID, reconcile ambiguous results, and verify facts before consequential decisions (Q148–150).

**Implementation status:** These operational procedures and AI tool integrations are not implemented or verified.

## 9. Backups and maintenance

Before production use, implement and document:

- A consistent SQLite backup procedure.
- Backup rotation that keeps routine backups no more than 30 days (Q137).
- A restore test.
- Schema migration and rollback expectations.
- Memory inspection, export, correction, and deletion.
- A procedure for rotating the Discord token.
- A procedure for disabling the timer and revoking the bot's channel permissions.

## 10. Deployment status

No Python package, virtual environment, configuration, credential file, SQLite database, systemd service, systemd timer, or Discord bot integration has been created as part of this documentation work.
