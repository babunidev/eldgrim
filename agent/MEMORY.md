# Eldgrim Agent — Memory Design

**Status:** Developing conceptual data model; no database implementation exists.

## 1. Purpose

Memory gives Eldgrim continuity between daily sessions. It should help Eldgrim recognize returning people, recall earlier conversations, remember shared events, and avoid treating every interaction as if it were the first.

Memory is not a complete transcript of the Discord server. It is a small, private record of interactions that involve Eldgrim and information that is useful to its future interactions.

## 2. Storage choice

Use one local SQLite database through Python's standard sqlite3 module.

Initial location:

~~~text
~/.local/share/eldgrim/
    eldgrim.sqlite3
    backups/
    logs/
~~~

The exact paths may be changed during implementation, but runtime data must remain outside the Git repository.

SQLite is sufficient for the first version. Start with indexed relational queries and ordinary text search. FTS5 may be added after verifying that the installed SQLite build supports it. Do not introduce a vector database or embeddings until a demonstrated retrieval problem justifies the added complexity.

## 3. Memory layers

### Interaction history

The temporary collection of all eligible @Eldgrim mentions is **not** a permanent interaction history. Under confirmed Q100 it is discarded after the daily processing run, including unselected questions. Any future persistent record of selected interactions or concise memories must follow the confirmed Q135–137 retention boundaries and remain distinct from this transient collection; the specific data model and deletion procedures are not implemented.

### People

A local profile for a Discord user Eldgrim has interacted with. Use the Discord user ID as the stable local key because display names can change or collide. Store it as a string and keep it only in the private database.

Possible fields:

- Discord user ID.
- Most recently observed display name.
- First and last interaction timestamps.
- Relevant facts explicitly shared by the person.
- Links to memories and interaction records.

Do not infer a real-world identity or collect unrelated profile data.

### Shared-world memories

Relevant events, gatherings, stories, places, plans, and experiences that have been discussed with Eldgrim.

### Agent continuity

Previous decisions, pending internal intentions, unfinished conversations, and the outcome of prior daily sessions.

These are operational memories, not new character canon. They must not silently establish new powers, history, or private motives.

## 4. Conceptual tables

The following is a design sketch, not an implemented schema.

| Table | Purpose |
| --- | --- |
| channel_cursors | Configured channel IDs and last safely processed message IDs |
| interactions | **Proposed only:** separately authorized selected-interaction records, not the raw per-run mention collection |
| people | Local profiles keyed by Discord user ID |
| memories | Concise facts, events, relationships, and observations |
| memory_sources | Links from a memory to the interactions that support it |
| intentions | Internal follow-up tasks for a future daily run |
| runs | Start time, finish time, outcome, and bounded diagnostics |
| actions | Tool/action audit records and delivery state |

Discord snowflake IDs must be stored as strings, never floating-point numbers. The channel and message IDs required for polling, deduplication, and provenance are private operational data and must not be committed to Git.

## 5. Memory quality

Every saved memory should:

- Have a clear type and concise content.
- Preserve its source interaction or source references.
- Distinguish an explicit statement from a model inference.
- Include creation and update timestamps.
- Avoid claiming certainty beyond its source.
- Be retrievable by relevant person, subject, or text.
- Be correctable or markable as superseded when new information changes it.

Do not silently overwrite contradictory information. Preserve the source and mark an earlier memory as superseded or uncertain.

A model-generated summary is not automatically a fact. The application should retain source references so the model can retrieve the original eligible interaction when needed.

## 6. Retrieval

For each eligible mention:

1. Load the person's local profile, if one exists.
2. Retrieve recent interactions with that person.
3. Search memories using names, subjects, and relevant terms from the current message.
4. Include only a compact, relevant selection in the model context.
5. Preserve source references in the context supplied to the model.

Do not load the entire database into the model prompt. Do not send unrelated users' memories unless directly relevant and permitted.

## 7. Intake and transaction safety

- Safely collect eligible inbound messages into a **temporary per-run collection** before selecting questions; do not treat this as a permanent interaction archive.
- Use message IDs to prevent duplicate intake.
- Commit cursor progress only after the corresponding records are durable.
- Use transactions for related message, memory, and cursor updates.
- Define failed-run collection cleanup and recovery before implementation; do not silently create a waiting queue for unselected questions.
- Use database migrations when the schema changes.
- Back up the database before destructive migrations.

The exact cursor commit strategy must be tested against Discord's pagination behavior and interruption scenarios.

## 8. Privacy and retention

The temporary collection may contain all explicitly eligible mentions, but **must be discarded after the processing run** under Q100. Unselected questions are not queued or archived as pending replies. Unrelated channel messages are not archived. Persistent memory and audit data, if authorized, must be governed separately.

Do not intentionally store sensitive personal information, private account details, credentials, or sensitive inferences. Do not store private character canon in the shared database unless a separate private local design explicitly requires it.

Before production use, define:

- How long raw interaction messages are retained.
- Whether summaries may outlive raw messages.
- How the operator inspects, corrects, exports, and deletes a person's memories.
- How a person can request that relevant memories be removed.
- How backups reflect deletions.
- Whether and how database backups are encrypted.

**Founder-confirmed Q131–137 and Q139–140:** Provide a pre-onboarding privacy notice, allow optional narrative profiling to be declined, and establish a lawful disclosed basis before importing in-game chat. Imported raw chat is deleted after authorized analysis (Q134), with a separate local SavedVariables retention/deletion procedure required before integration. Relevant interpreted personal memories are reviewed while membership is active and eligible memories deleted or anonymized within **30 days of departure** absent a specific legitimate retention obligation (Q135). Ordinary administrative audits are retained **up to 180 days**, with justified documented extensions (Q136). Routine backups are kept **no longer than 30 days**, protected appropriately, and any restored backup must reapply recorded deletions before service resumes (Q137). Provide private authorized-human data requests with legally required access/correction/export/deletion (Q139), and containment/notification/remediation for unauthorized disclosure (Q140). **Q138 access-authority details are pending founder revision.** The operational procedures, backup encryption decisions and exact data categories still need design and testing; indefinite retention is not approved.

## 9. Confirmed data boundaries — questions 124–130

- **Q124:** Restrict the agent's observations to explicitly designated guild channels, messages intentionally addressed to Eldgrim, and necessary onboarding/administrative data. The server bot's predefined moderation processing is **not** general permission to copy other content into agent memory.
- **Q125:** Do not access member-to-member private conversations to which the application is not a legitimate participant. Direct messages to the bot are purpose-limited and not automatically story material.
- **Q126:** Future authorized analysis of the WoW addon's raw guild-chat archive is temporary. Long-term memories favor supported interpretations, topics and character-relevant observations, **not verbatim conversation quotations**. Define a raw-archive deletion procedure before integrating it into production.
- **Q127:** Purge the temporary mention collection, including all unselected message content, after processing. Non-content audit metadata may persist where necessary, but may not recreate a hidden archive. This reinforces Q100; failure/partial-run semantics remain open.
- **Q128:** Retain only relevant, supported interpretations of character interests, participation, helpfulness, conduct and shared experiences. Do not infer sensitive real-world traits or unsupported psychology. Private standing and impressions remain confidential under Q64, subject to applicable legal rights.
- **Q129–130:** Provide a private correction process and an authorized human reviewer for unresolved consequential disputes. On departure deactivate membership/character records, cease routine collection, and allow requests for deletion of eligible data, subject to confirmed Q135–137 retention boundaries and justified exceptions; exact implementation remains open.

**Implementation status:** No retention, deletion, access-request or data transfer mechanism has been implemented or verified in the local agent.

## 10. Future options

Possible later additions include semantic embeddings, relationship graphs, richer event timelines, and a more sophisticated memory consolidation process. None is required for the first implementation.

Begin with reliable records, provenance, simple retrieval, and clear deletion behavior.
