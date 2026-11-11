# Eldgrim Agent — Architecture

**Status:** Developing design; no implementation exists.  
**Target environment:** Local Linux desktop, initially Nobara Linux.  
**Execution:** One scheduled, one-shot run per day.  
**Model runtime:** Local Ollama API.  
**Discord connection:** HTTP REST requests only; no persistent Gateway session.

## 1. Architectural goals

The system should:

1. Give Eldgrim persistent memory across separate daily sessions.
2. Let a local language model decide how to handle eligible interactions.
3. Allow the model to use a small set of useful tools.
4. Keep Discord access and local data access under application control.
5. Avoid keeping a model loaded in GPU memory between sessions.
6. Remain understandable, testable, and maintainable without a multi-agent framework.
7. Preserve the separation between the in-world character, the Forever addon, and the out-of-character agent.

The model supplies reasoning and language. Python owns scheduling, API access, persistence, permissions, validation, retries, and execution.

## 2. High-level design

~~~text
systemd wake timer (moment chosen by the previous run)
          |
          v
one-shot Python agent
          |
          +---- configuration and run lock
          |
          +---- Discord HTTP API
          |       - read configured channel history
          |       - find explicit Eldgrim mentions
          |       - send approved replies
          |
          +---- private SQLite database
          |       - channel cursors
          |       - transient mention collection
          |       - people and memories
          |       - operational state and action log
          |
          +---- local Ollama API
                  - chat completion
                  - bounded tool-call loop
                  - final response
                          |
                          v
                 Python tool dispatcher
                 (allowlist + validation)
~~~

There is no continuously connected Discord Gateway client in this design. The scheduled Python process makes ordinary HTTP requests to Discord, uses the local Ollama API when needed, then exits.

The Ollama server may remain installed or available as a local service. The model itself should only be loaded for the daily session and unloaded afterward. Stopping the agent process does not necessarily stop the Ollama server.

## 3. Components and responsibilities

### systemd user timer

- Starts the service once, at the moment the previous run chose on the next local calendar day.
- Is a system timer with `WakeSystem=true`, so it can wake the computer from suspend, and `Persistent=false`, so a missed day is skipped rather than replayed.
- Does not wake a powered-off computer.

There is no fixed execution time. See [OPERATIONS.md](OPERATIONS.md) for the units and the root step that arms the timer.

### Python application

Python is the orchestrator and security boundary. It:

- Loads configuration and secrets from local paths.
- Acquires a lock so two daily sessions cannot overlap.
- Polls Discord channels and handles pagination.
- Filters eligible mentions into a temporary collection; selects at most one question per member during the run.
- Retrieves relevant memory.
- Calls Ollama and manages tool-call rounds.
- Validates every tool request before execution.
- Sends permitted replies through Discord.
- Commits state and records outcomes.
- Unloads the model and exits.

The application must use bounded request timeouts, bounded retries, and a maximum tool-call round/action budget.

### Discord HTTP API

The initial **mention-only** design uses the channel message-history endpoint:

- GET /channels/{channel_id}/messages
- Query parameters include after and limit.
- Discord documents a maximum limit of 100 messages per request.
- The bot needs View Channel and Read Message History in each configured channel.
- Sending replies requires Send Messages in the destination channel.

The agent polls only an explicit channel allowlist. It must not discover channels, scan the whole server, enumerate members, or collect unrelated conversations. **Q138** additionally authorizes **guild-visible material in explicitly designated shared channels** as a future narrative-memory source, subject to member notice, valid processing basis, channel allowlisting and technical permission checks. This is distinct from @Eldgrim mentions used for question selection.

#### Mention-only content boundary

The initial **mention-only** design does not enable the privileged Message Content Intent. Reading **general shared-channel message content** for Q138 may require that privileged intent and separate approval/configuration; it is not a capability of the current mention-only design.

Discord documents that, without this intent, content fields are empty except for messages sent by the app, DMs with the app, messages in which the app is mentioned, and certain message-context-command cases. This makes direct mentions a viable initial interaction boundary without granting broad message-content access.

There is an important distinction: polling channel history still returns message objects and metadata for other messages. The application must:

1. Inspect only the metadata required to identify an explicit mention.
2. Pass message content to the model only when the message is eligible.
3. Keep eligible inbound mentions in the temporary collection until the run processes them, then discard that collection. Store only separately authorized memories and necessary operational/audit state.
4. Avoid retaining unrelated author metadata or message records.
5. Never enable Message Content Intent merely to make general channel reading easier.

A reply that does not explicitly mention Eldgrim is outside the initial scope unless a later decision expands it.

#### Cursor and pagination behavior

Maintain one last-successfully-processed message cursor per configured channel. Use Discord message IDs as opaque strings; do not convert snowflakes to floating-point numbers.

The implementation must:

- Request messages after the saved cursor.
- Handle the 100-message page limit and continue until caught up.
- Verify the API's returned ordering and pagination behavior in integration tests.
- Process eligible messages in chronological order.
- Deduplicate by message ID.
- Commit any necessary transient collection and cursor state safely; do not turn unselected mentions into a durable response queue.
- Never advance a cursor past messages not yet safely collected; exact cursor/collection consistency and failed-run handling need implementation design.

If a request fails, a page is incomplete, or a database transaction fails, retain the previous safe cursor and retry on a later run. Do not assume that a single page contains every message since the previous daily run.

### SQLite memory

SQLite is the first persistence layer. It is local, transactional, and available through Python's standard sqlite3 module.

It stores only the agent's required runtime state. The database lives outside the Git repository. See [MEMORY.md](MEMORY.md).

### Ollama

The application uses Ollama's local chat API with tool definitions. Ollama documents the tool-call cycle: the model requests a tool, the application executes it, the result is returned to the conversation, and the model continues.

The existing local Qwen3 8B installation is the initial candidate. Its exact tag, Ollama version, context configuration, and tool-call reliability must be verified on the target machine before implementation. The model name must remain configurable.

The model does not receive direct credentials or unrestricted access to Discord, the filesystem, the shell, or the network.

## 4. Daily execution sequence

1. **Activate.** systemd starts the one-shot Python service.
2. **Validate.** Load configuration, check required secrets, verify local Ollama availability, and acquire the run lock.
3. **Poll.** Fetch new message pages from configured Discord channels using saved cursors.
4. **Filter.** Identify messages that explicitly mention Eldgrim. Do not pass unrelated content to the model.
5. **Collect intake.** Gather eligible mentions into a temporary collection, either captured by the server bot or obtained through the bot during this session; choose the mechanism before implementation. Preserve only necessary private cursor/operational state.
6. **Check work.** If there are no eligible messages or due internal tasks, exit without loading the model, unless a separately enabled daily reflection task requires it.
7. **Build context.** Retrieve Eldgrim's approved public character guidance, relevant recent interactions, and a small selection of relevant memories. Private character instructions, if ever used, must be supplied from a local file outside Git.
8. **Select and reason.** For each member, select at most one question from the temporary collection (randomly or by narrative suitability), then call Ollama. The model may answer, request an allowlisted tool, or choose no action.
9. **Execute tools.** Python validates each tool name, arguments, permission, scope, and action budget before execution. Tool results are returned to the model.
10. **Act.** Send a permitted reply, save a relevant memory, or record a follow-up intention. The model may choose silence.
11. **Commit and discard.** Persist allowed action outcomes and separately authorized memories, **discard the temporary collected mentions after the run**, and begin a new collection period. Unselected questions are not queued or rolled over.
12. **Clean up.** Request model unloading, close database connections, release the lock, and exit.

A daily run is an opportunity to examine new activity, not a requirement to publish something.

## 5. Tool-calling loop

The model receives only the tools registered by the application. The application owns the dispatch table and schemas.

Conceptually:

~~~python
for round_number in range(MAX_TOOL_ROUNDS):
    response = ollama_chat(messages, tools=ALLOWED_TOOLS)

    if not response.tool_calls:
        handle_final_response(response)
        break

    for call in response.tool_calls:
        arguments = validate_schema(call.name, call.arguments)
        result = dispatch_allowlisted_tool(call.name, arguments)
        messages.append(tool_result(call.name, result))
else:
    record_tool_budget_exhausted()
~~~

This is illustrative pseudocode, not implemented source.

Initial tool candidates:

| Tool | Purpose | Boundary |
| --- | --- | --- |
| search_memory | Retrieve relevant stored memories | Read-only, local database |
| read_interaction_context | Retrieve selected interpreted context and non-content provenance | Only approved local memories; no retained raw-message transcript |
| save_memory | Store a useful fact or event | Validated fields and provenance |
| record_intention | Save an internal follow-up for a future daily run | No external scheduling service |
| send_reply | Reply to an eligible mention | Configured channel and per-run limits |

The model can request a tool; it cannot authorize the tool. Python must enforce all permissions independently.

## 6. Model lifecycle and resource use

- Ollama runs locally; the application connects through its local API.
- The model is loaded only when there is eligible work or a configured model-driven task.
- Keep the model available across the bounded reasoning and tool-call loop to avoid reloading it for each tool.
- At the end of the run, explicitly unload it using Ollama's documented keep-alive behavior.
- Verify that GPU memory returns to its expected idle baseline after the session.

Ollama's chat and generate APIs document the keep_alive parameter, including zero for immediate unloading. The exact unload request must be verified against the installed Ollama version during implementation.

## 7. Failure and recovery

- **Discord unavailable:** retain unprocessed cursors; retry with bounded backoff and respect rate-limit responses.
- **Rate limited:** honor Discord's retry guidance rather than repeatedly retrying immediately.
- **Ollama unavailable:** failed-run treatment of temporary mentions requires a separate explicit decision; do not silently create a permanent pending-answer queue.
- **Tool failure:** return a bounded error result to the model or stop the current action safely.
- **Database failure:** roll back the transaction and do not advance the affected cursor.
- **Process interruption:** use message-ID deduplication and durable checkpoints so the next run can safely resume.
- **Ambiguous message-send result:** avoid blind duplicate sends; record the uncertain action for reconciliation.
- **Model budget exhausted:** stop tool execution and record the run outcome. Do not silently roll over unselected member questions; define failed/partial-run cleanup separately.

A failed daily run must not create an infinite retry loop or keep the model loaded indefinitely.

## 8. Approved collection limits — questions 124–130

The agent may observe only configured guild channels, content intentionally addressed to Eldgrim and necessary onboarding/administrative interactions. The always-online bot's predefined moderation processing does not authorize wholesale memory ingestion (Q124). Member-to-member private messages outside the bot's legitimate participation are inaccessible and out of scope; DMs to the bot remain purpose-limited (Q125).

Guild-chat archives from the Forever addon are **temporary authorized analysis input**; their reading and cleanup are specified in [ROSTER.md](ROSTER.md). Do not silently turn raw messages into persistent member memories (Q126). The per-run @Eldgrim mention collection is purged after processing, including unselected questions; operational audit metadata must not reconstruct content (Q127). Long-term impressions remain relevant, supported, non-sensitive and confidential (Q128). Member correction, departure and deletion requests require private procedures and an approved retention policy before integration (Q129–130).

These constraints are approved **design requirements**, not implemented or tested agent features.

The roster built from the Forge and the addon, and the reduction of sentences to keywords, is specified in [ROSTER.md](ROSTER.md). That roster is the overview a later run reads. Announcements and other independent actions wait until it exists.

## 9. Confirmed local-memory pipeline — question 138

1. **Sources:** Use only authorized guild-visible messages from World of Warcraft Forever **guild chat** and **explicitly designated shared Discord guild channels**. Do not ingest whispers, private member conversations or private-channel content into Eldgrim's narrative memory. Mentions to Eldgrim remain a distinct temporary question-selection collection (Q100).
2. **Temporary collection:** The always-online bot may stage raw shared-channel content on the server; the game addon already archives guild chat locally in SavedVariables. Securely transfer only authorized temporary input to the founder's PC. No long-term raw transcript archive on the server. The precise transport and permission mechanism is not yet designed.
3. **Local interpretation:** The founder's PC runs the AI, selects relevant supported observations about members, characters and shared experiences, and saves **only interpreted memory** to its **local SQLite database**. The founder is the only human with direct access; the authorized local AI uses it under application controls. Internal standing remains confidential.
4. **Purge:** Delete temporary raw collections after processing, including server staging and local raw copies. For the addon file, the approved cleanup is the one in [ROSTER.md](ROSTER.md): after the keywords and any standing adjustment are committed, clear the guild-chat message lists, leave the profile fields and `EldgrimRoster`, and do this only while the Forever client is closed. A failed commit leaves the messages in place.
5. **Separate live bot operations:** The deployed bot keeps necessary Character Forge/role/administration data on the server. This is not Eldgrim's narrative-memory database and is not a justification for permanent raw-chat storage.
6. **Privacy:** Guild-visible source messages may still contain personal data. Preserve Q131–137 and Q139–140 rights and safeguards, and never assume general shared-channel content is readable without the appropriate Discord permissions.

**Superseded:** A persistent combined **server-hosted** Eldgrim narrative-memory database and direct database access for other human custodians. **Implementation status:** The transfer, selection, persistent-memory integration and purge pipeline have not been implemented or verified.

## 10. Approved action-tool design — questions 141–150

The intended local AI uses only registered purpose-specific tools for allowed communication, quests, ranks, recognition, **proposed** bank allocations and delegated Discord administration (Q141). Python and the bot independently validate schema, targets, permissions, governing rules and action quotas; the model cannot grant its own authority (Q142). Within this delegation, channel/role/permission changes may be autonomous through validated audited operations (Q143), but destructive server-level, ownership, infrastructure credential, unrelated-service or security-control changes require explicit founder authorization (Q144). This is **not** a claim that the deployed bot's manual preview-and-approval process has been replaced.

Shared Discord and in-game messages, retrieved memories and tool results are untrusted data, not policy or tool instructions (Q145). Fail closed on invalid or ambiguous actions; do not claim unverified success or convert failed runs into persistent raw-message archives or unanswered-question queues (Q146). While the PC is offline, the server bot continues existing services and predefined emergency actions, with only temporary authorized shared-source staging; it does not invent AI decisions or replies (Q147).

Log minimal consequential action metadata—type, target, time, reason/rule, result, reviewer where needed—without raw chat or complete inferred profiles (Q148). Use unique action IDs and outcome reconciliation before retrying sanctions, rewards or transfers (Q149). Separate verified real events from uncertain interpretations and fiction, and refrain from consequential action on unverified claims (Q150).

**Status:** Founder-confirmed policy. The exact tool registry, independent authorization, idempotency, auditing and full AI integration are not implemented or tested.

## 11. Explicit non-goals

- A continuously connected Discord Gateway bot.
- Instant or real-time replies.
- A permanently loaded Ollama model.
- Cloud inference or external AI services.
- A multi-agent swarm or separate planner/executor agents.
- Guild-wide message archiving or member scraping.
- Arbitrary shell, Python, filesystem, or network tools.
- Discord moderation, permission changes, or administration in the initial milestone. Approved later through the server bot (2026-11-10).
- Addon archive access beyond what [ROSTER.md](ROSTER.md) specifies.
- Publication of private canon or concealed character information.

## 12. Official technical references

- [Discord Get Channel Messages and message object](https://docs.discord.com/developers/resources/message)
- [Discord Gateway: Message Content Intent and exceptions](https://docs.discord.com/developers/events/gateway)
- [Ollama chat API](https://docs.ollama.com/api/chat)
- [Ollama tool calling](https://docs.ollama.com/capabilities/tool-calling)
- [Ollama generate API and keep-alive](https://docs.ollama.com/api/generate)
- [Python sqlite3](https://docs.python.org/3/library/sqlite3.html)
- [systemd.timer](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html)
