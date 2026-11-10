# Eldgrim Local Agent

**Status:** Developing architecture; documentation only.  
**Execution model:** One scheduled run per day; one-shot process.  
**Inference:** Local Ollama.  
**Communication:** Discord HTTP API.  
**Memory:** Private local SQLite database.

## Purpose

The Eldgrim agent is a proposed local software companion that allows Eldgrim to receive selected Discord messages, remember meaningful interactions, reason about what deserves a response, and act within a deliberately limited set of permissions.

It is designed to wake once per day, complete one bounded session, and exit. It is not a continuously running chatbot and does not need a permanently connected Discord Gateway session.

## Daily cycle

1. A systemd user timer activates the one-shot Python service.
2. The service validates its local configuration and reads saved channel cursors.
3. It polls only explicitly configured Discord channels through the HTTP API.
4. It identifies messages that explicitly mention Eldgrim. The initial design does not request Discord's privileged Message Content Intent.
5. Eligible messages and the required private cursor state are saved to SQLite.
6. If there is eligible work or a due internal intention, the application loads relevant memories and starts local Ollama inference.
7. The model reasons and may request allowlisted tools. Python validates and executes each request.
8. Eldgrim replies, saves relevant memories, or chooses to do nothing.
9. The application records the outcome, unloads the model, closes the database, and exits.

If there is no eligible work and no due task, the service can finish without loading the model. A daily run does not have to produce a Discord message.

## Architecture documents

- [ARCHITECTURE.md](ARCHITECTURE.md) — components, data flow, daily lifecycle, and reliability.
- [SPECIFICATION.md](SPECIFICATION.md) — initial scope, required behavior, boundaries, and acceptance criteria.
- [SECURITY.md](SECURITY.md) — credentials, Discord permissions, tool boundaries, and prompt-injection handling.
- [MEMORY.md](MEMORY.md) — private SQLite data model, retrieval, provenance, and retention questions.
- [OPERATIONS.md](OPERATIONS.md) — intended Nobara/Linux scheduling, model lifecycle, logs, and deployment considerations.

## Initial scope

The first implementation milestone is intended to support:

- Daily polling of a configured channel allowlist.
- Direct messages in those channels that explicitly mention Eldgrim.
- Context retrieval from Eldgrim's own stored interaction history.
- Local model reasoning through Ollama's chat and tool-calling API.
- A small allowlist of memory and reply tools.
- Autonomous replies to eligible mentions, within application-enforced limits.
- Persistent memory and an auditable record of actions.
- A one-shot systemd service that exits after the daily session.

Proactive messages that are not replies to a mention are disabled by default. Enabling them requires an explicit scope decision and configuration.

## Important boundaries

- The agent is separate from the World of Warcraft Forever addon. It does not read or modify the addon's SavedVariables.
- The agent's behavior does not establish Eldgrim's character canon or reveal concealed character information.
- Private runtime data, actual Discord messages, database files, credentials, and private prompts do not belong in this public repository.
- The model cannot execute arbitrary shell commands, arbitrary Python, unrestricted file operations, or Discord moderation/administration actions.
- The initial design does not maintain a Discord Gateway connection or request Message Content Intent.

## Current reality

This directory contains architecture and specification documents only. No Python source, Discord bot integration, SQLite runtime database, systemd unit, credentials, or deployment has been created or tested.

## Technical references

The architecture is based on the current official documentation:

- [Discord Message Resource](https://docs.discord.com/developers/resources/message)
- [Discord Gateway and Message Content Intent](https://docs.discord.com/developers/events/gateway)
- [Ollama chat API](https://docs.ollama.com/api/chat)
- [Ollama tool calling](https://docs.ollama.com/capabilities/tool-calling)
- [Ollama generate API and model keep-alive](https://docs.ollama.com/api/generate)
- [Python sqlite3](https://docs.python.org/3/library/sqlite3.html)
- [systemd.timer](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html)
