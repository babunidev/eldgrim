# Eldgrim Agent — Initial Specification

**Status:** Developing; specification only.  
**Implementation status:** Not started.  
**Target:** Local Linux desktop, initially Nobara Linux.  
**Cadence:** Once per day.

## 1. Purpose

Create a local agent that allows Eldgrim to receive selected Discord interactions, remember meaningful experiences, reason about what deserves attention, and respond in a consistent character voice.

The agent should be autonomous within a defined environment, while the application retains control over permissions, data access, and external actions.

## 2. Initial operating model

- A systemd user timer starts one one-shot Python process per day.
- The process polls a configured list of Discord channels through the HTTP API.
- The initial input scope is messages that explicitly mention Eldgrim.
- The bot does not maintain a Gateway connection between runs.
- Local Ollama performs reasoning and tool calls only when eligible work exists.
- SQLite stores private runtime state and memory.
- The service completes its work, unloads the model, and exits.

The exact daily time is intentionally open.

## 3. Required behavior

### Intake

- Poll only channel IDs explicitly configured by the operator.
- Use the Discord channel message-history endpoint and a durable per-channel cursor.
- Handle pagination beyond 100 messages.
- Identify direct mentions of the configured bot user.
- Do not request the privileged Message Content Intent for the initial scope.
- Do not store or forward unrelated channel messages.
- Persist eligible messages before asking the model to process them.
- Deduplicate by Discord message ID.

### Reasoning

- Use the local Ollama API.
- Keep the model configurable; Qwen3 8B is the initial local candidate pending compatibility tests.
- Supply the public character profile and voice guidance from the repository.
- Keep private character instructions outside the public repository.
- Retrieve only relevant memories and recent interaction context.
- Support bounded multi-step tool calling.
- Allow the model to decide that no response or action is appropriate.

### Communication

- Reply only to eligible mentions in configured channels.
- Keep replies within Discord's message length limit.
- Use safe allowed-mentions settings so model-generated text cannot accidentally ping roles or everyone.
- Record the outbound message result and associate it with the triggering interaction.
- Do not send unsolicited channel messages in the initial milestone.

### Memory

- Save selected interactions and useful memories in a private local SQLite database.
- Preserve provenance for stored facts and summaries.
- Distinguish explicit user-provided facts from model inference.
- Do not silently turn guesses into facts.
- Do not store sensitive personal information or private character canon.

### Scheduling and shutdown

- Run as a one-shot service activated once per day.
- Prevent overlapping sessions.
- Preserve pending work after recoverable failures.
- Unload the model at the end of the session.
- Exit cleanly without leaving a resident agent process.

## 4. Autonomy levels

### Initial milestone — autonomous replies

The agent may independently:

- Decide whether an eligible mention needs a response.
- Search its own stored memories.
- Save relevant interaction memories.
- Formulate and send a reply within configured limits.
- Choose silence.
- Record an internal follow-up intention for a later session.

These actions do not require per-message human approval once the operator has configured and enabled the capability.

### Later milestone — proactive communication

The agent may eventually initiate a message without a new mention, but only if the creative explicitly enables this capability and configures its destination and limits.

Potential safeguards include:

- Dedicated approved channels only.
- A strict maximum number of proactive posts per day.
- Cooldowns between posts.
- No mass mentions.
- No repeated or duplicate announcements.
- An action log and an immediate operator disable switch.

This capability is not part of the initial milestone.

## 5. Initial tool allowlist

| Tool | Permission |
| --- | --- |
| Search own memory | Read local agent memory |
| Read stored interaction context | Read only eligible interactions |
| Save memory | Write validated memory records with provenance |
| Record internal intention | Add a bounded future task |
| Send reply | Send to the channel and interaction that triggered the response |

No arbitrary command execution, unrestricted file access, arbitrary URL fetching, moderation, or server administration is allowed.

## 6. Technology direction

| Area | Initial choice |
| --- | --- |
| Orchestration | Python |
| Model runtime | Local Ollama |
| Initial model candidate | Existing local Qwen3 8B; exact tag to be verified |
| Model interface | Ollama chat API and tool calling |
| Discord | HTTP REST API |
| Memory | SQLite through Python sqlite3 |
| Scheduling | systemd user timer and one-shot service |
| Logs | systemd journal plus minimal local application logs |

No agent framework, vector database, cloud inference, or multi-agent architecture is required for the first implementation.

## 7. Out of scope

- Real-time chat or instant replies.
- Persistent Discord Gateway connection.
- Reading and archiving all channel conversations.
- Message Content Intent in the initial mention-only milestone.
- Discord moderation, administration, role changes, or permission management.
- Unrestricted filesystem, shell, Python, or network access.
- Cloud-hosted model inference.
- Integration with the World of Warcraft Forever addon.
- Automatic publication of private canon or hidden character information.

## 8. Acceptance criteria

The initial implementation is not complete until all of the following are verified:

1. The timer starts one one-shot service at the configured daily time.
2. The agent does not keep a persistent Gateway connection.
3. Only configured channels are polled.
4. Direct mention content is accessible without enabling Message Content Intent.
5. Unrelated message content is not stored or sent to Ollama.
6. Pagination retrieves all new eligible messages without gaps.
7. Re-running after an interruption does not duplicate stored messages or replies.
8. Ollama tool calls are schema-validated and restricted to the allowlist.
9. The model can choose not to respond.
10. Memory survives process and machine restarts.
11. Discord and Ollama failures leave recoverable pending work.
12. The model unloads after the daily session.
13. The service exits and releases its run lock.
14. Secrets and runtime memory remain outside the repository.
15. Proactive posting is disabled unless separately approved and configured.

## 9. Open decisions

- Exact daily execution time.
- Discord application identity and channel allowlist.
- Exact Ollama version and model tag.
- Memory retention period and deletion/export workflow.
- Whether to enable an optional daily reflection when there are no mentions.
- Whether proactive communication should be enabled later.
- Final per-run limits for replies, tool calls, runtime, and model tokens.
