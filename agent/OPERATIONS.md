# Eldgrim Agent — Operations

**Status:** Intended operating procedure; no service or agent implementation exists.  
**Target environment:** Nobara Linux user session.

## 1. Scheduling model

Use a systemd **user** timer to activate a matching one-shot service once per day.

Intended units:

- eldgrim-daily.timer
- eldgrim-daily.service

The timer uses an OnCalendar schedule in the user's local timezone. The exact time is open and must be chosen during deployment.

The service is a one-shot process. It must not use a persistent agent loop or remain active after its daily work is complete.

## 2. Missed runs and machine availability

Use Persistent=true with an OnCalendar timer.

Systemd records the last trigger time and starts the service when the timer becomes active if at least one scheduled activation was missed while the timer was inactive. This is a catch-up run, not a replay of every missed day.

- If the computer is powered off at the scheduled time, the run cannot happen at that time.
- The service can catch up when the user timer becomes active again.
- If the computer is suspended, a calendar timer is handled after resume; it does not imply that the machine will wake itself.
- WakeSystem is not part of the initial design.
- A systemd user manager normally runs with the user's session. Enabling lingering to run while logged out is an optional operational decision, not a default requirement.

## 3. Service lifecycle

The intended one-shot service should:

1. Start the Python agent in its project virtual environment.
2. Load non-secret configuration and private credentials from outside Git.
3. Acquire a process lock.
4. Validate the database and local dependencies.
5. Poll Discord and process eligible work.
6. Use Ollama only when there is work to process.
7. Persist outcomes and pending actions.
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
- Preserve eligible messages as pending work if Ollama is unavailable.
- Record ambiguous message-send outcomes for reconciliation rather than blindly sending duplicates.
- Release the process lock during all normal and exceptional exits.
- Ensure model unloading is attempted during cleanup.
- Keep a clear run outcome for success, partial completion, and failure.

## 8. Backups and maintenance

Before production use, implement and document:

- A consistent SQLite backup procedure.
- A retention policy for backups.
- A restore test.
- Schema migration and rollback expectations.
- Memory inspection, export, correction, and deletion.
- A procedure for rotating the Discord token.
- A procedure for disabling the timer and revoking the bot's channel permissions.

## 9. Deployment status

No Python package, virtual environment, configuration, credential file, SQLite database, systemd service, systemd timer, or Discord bot integration has been created as part of this documentation work.
