# Eldgrim Local Agent

**Status:** Developing. A local runner writes test announcements; nothing is posted.  
**Execution model:** One run per day at a moment Eldgrim chose at the end of the previous run; one-shot process.  
**Inference:** Local Ollama.  
**Communication:** Discord HTTP API.  
**Memory:** Private local SQLite database.

## Purpose

The Eldgrim agent is a proposed local software companion that allows Eldgrim to receive selected Discord messages, remember meaningful interactions, reason about what deserves a response, and act within a deliberately limited set of permissions.

It is designed to wake once per day, complete one bounded session, and exit. It is not a continuously running chatbot and does not need a permanently connected Discord Gateway session.

## Daily cycle

1. A system wake timer starts the one-shot Python service at the moment chosen by the previous run (see [OPERATIONS.md](OPERATIONS.md)).
2. The service validates its local configuration and reads saved channel cursors.
3. It polls only explicitly configured Discord channels through the HTTP API.
4. It identifies messages that explicitly mention Eldgrim. The initial design does not request Discord's privileged Message Content Intent.
5. Gather eligible mentions into a **temporary collection** (captured by the server bot or retrieved from it during the run; implementation choice open). Operational cursors may be stored privately; raw collected mentions are not a permanent message archive.
6. If there is eligible work or a due internal intention, the application loads relevant memories and starts local Ollama inference.
7. The model reasons and may request allowlisted tools. Python validates and executes each request.
8. Eldgrim may select one question per member at random or for narrative suitability, reply or choose silence, and record separately authorized concise memories.
9. After processing, discard the temporary mention collection, start a fresh collection period, record the outcome, unload the model, close resources, and exit. Unselected questions are not queued.

If there is no eligible work and no due task, the service can finish without loading the model. A daily run does not have to produce a Discord message.

## Architecture documents

- [ARCHITECTURE.md](ARCHITECTURE.md) — components, data flow, daily lifecycle, and reliability.
- [SPECIFICATION.md](SPECIFICATION.md) — initial scope, required behavior, boundaries, and acceptance criteria.
- [SECURITY.md](SECURITY.md) — credentials, Discord permissions, tool boundaries, and prompt-injection handling.
- [MEMORY.md](MEMORY.md) — private SQLite data model, retrieval, provenance, and retention questions.
- [OPERATIONS.md](OPERATIONS.md) — intended Nobara/Linux scheduling, model lifecycle, logs, and deployment considerations.
- [ANNOUNCEMENT.md](ANNOUNCEMENT.md) — the first daily proclamation: what it reads, what it may say, and what it does not do yet.
- [ROSTER.md](ROSTER.md) — the guild roster on the founder's computer: Forge and addon doors, keywords instead of saved sentences, and the overview Eldgrim uses before it acts.

## Initial scope

The first implementation milestone is intended to support:

- Daily polling of a configured channel allowlist.
- Direct messages in those channels that explicitly mention Eldgrim.
- Context retrieval from separately authorized memories; temporary mention collections are not durable conversation archives.
- Local model reasoning through Ollama's chat and tool-calling API.
- A small allowlist of memory and reply tools.
- Autonomous replies to eligible mentions, within application-enforced limits.
- Separately governed persistent memory and an auditable record of actions, distinct from the purged mention collection.
- A one-shot systemd service that exits after the daily session.

One daily proclamation is approved and is the first thing built (see [ANNOUNCEMENT.md](ANNOUNCEMENT.md)). Any other message that is not a reply to a mention is disabled by default; enabling it requires an explicit scope decision and configuration.

## Important boundaries

- The agent reads the Forever addon's SavedVariables on the founder's computer, as specified in [ROSTER.md](ROSTER.md). After a successful reduction, and only while the game client is closed, it may clear the guild-chat message lists in that one file. It does not edit the addon source, and it does not clear the file when the save failed (2026-11-11).
- The agent's behavior does not establish Eldgrim's character canon or reveal concealed character information.
- Private runtime data, actual Discord messages, database files, credentials, and private prompts do not belong in this public repository.
- The model cannot execute arbitrary shell commands, arbitrary Python, or unrestricted file operations. Discord administration is approved for a later milestone (2026-11-10), only through the server bot's validated operations.
- The initial design does not maintain a Discord Gateway connection or request Message Content Intent.

**Role since 2026-11-10:** The agent is Eldgrim's once-daily voice. It runs on the creative's PC and posts through the same Eldgrim Discord application as the always-online server bot. The first use, chosen on 2026-11-10, is one daily proclamation to the guild, specified in [ANNOUNCEMENT.md](ANNOUNCEMENT.md). It waits for the roster in [ROSTER.md](ROSTER.md). Replies to @Eldgrim mentions come after that. See [bot/README.md](../bot/README.md).

## Current reality

`eldgrim_agent` can write one local announcement and choose the next day's wake time. Run it with `PYTHONPATH=agent python -m eldgrim_agent run` from the repository root. It does not post to Discord. The system wake timer is rendered on each run and still needs root to be armed. There is no SQLite roster database yet.

## Technical references

The architecture is based on the current official documentation:

- [Discord Message Resource](https://docs.discord.com/developers/resources/message)
- [Discord Gateway and Message Content Intent](https://docs.discord.com/developers/events/gateway)
- [Ollama chat API](https://docs.ollama.com/api/chat)
- [Ollama tool calling](https://docs.ollama.com/capabilities/tool-calling)
- [Ollama generate API and model keep-alive](https://docs.ollama.com/api/generate)
- [Python sqlite3](https://docs.python.org/3/library/sqlite3.html)
- [systemd.timer](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html)

## Sources for the final character instructions

Before drafting the final agent instructions, read character/PROFILE.md, character/VOICE.md, the lore documents and the current governance decision register. Also read the private origin on the founder's computer:

~~~text
~/.local/share/eldgrim/private/ORIGIN.md
~~~

That file holds Eldgrim's private roots. It is absent from this repository on purpose. A separate private supplement dated 11 November 2026 was named earlier and was not on disk when the origin was written; if it appears, read it too. Do not invent the missing pages. Incorporate the private roots as internal knowledge and do not disclose them in guild dialogue, stories, quests, or public documentation. Look, sound, and presence are not in the origin. Eldgrim may draft them only after it has shown that it knows the roots, and a draft becomes roots only when the creative accepts it. Preserve the approved public closing from character/VOICE.md. This documentation does not deploy an agent.

### Two layers

Eldgrim has two kinds of knowledge about itself, and they stay apart:

- **Private roots** live only in `~/.local/share/eldgrim/private/` on the founder's computer: the origin, and `GUARD.txt`, a list of phrases that would give the roots away. The runner reads both at run time. Eldgrim knows its roots; it does not say them.
- **Public presentation** is everything in this repository: the character profile, voice, lore and governance pages. It shows a mysterious presence and does not describe, summarize or hint at the roots.

Nothing in the public code, tests, examples or documentation names the roots or carries the guard phrases; tests use made-up phrases. If the origin is present and the guard list is missing, the runner stops rather than write an unchecked announcement.
