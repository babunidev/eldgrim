# Decisions

A concise record of meaningful creative and structural decisions.

## 2026-11-09 — Document the daily local-agent direction

**Direction:** Establish agent/ as a third, separate technical workstream and document a local agent that activates once per day through a systemd user timer. A one-shot Python process polls explicitly configured Discord channels through the HTTP API, processes message content when Eldgrim is explicitly mentioned, uses local Ollama inference for bounded reasoning and tool calls, and stores selected interactions and memories in a private local SQLite database.

**Communication boundary:** The initial design does not maintain a Discord Gateway connection and does not request the privileged Message Content Intent. Discord documents an exception for message content in which the app is mentioned. REST polling still returns message objects and metadata for channel history, so the application must not store or pass unrelated messages to the model. Only explicitly configured channels are polled.

**Autonomy boundary:** The agent may eventually answer eligible mentions and maintain memory without per-message approval, within application-enforced limits. Proactive channel posts remain a separate opt-in capability. Arbitrary shell execution, unrestricted file access, moderation, and administrative actions are excluded.

**Separation:** The agent is not integrated with the Forever addon and does not use its SavedVariables archive. Neither workstream establishes character canon or exposes private character information.

**Status:** Developing architecture documented; no agent code, Discord integration, database, systemd service, or deployment implemented or tested.

## 2026-11-08 — Eldgrim is the current name

**Decision:** Use Eldgrim as the character's name. Oracle is an obsolete working label.

**Reason:** The character's identity has moved beyond the temporary label.

**Status:** Established.

## 2026-11-08 — Eldgrim initiated Amberhearth

**Decision:** Document Amberhearth as a fellowship initiated by Eldgrim and conceived as a home for travelers, stories, and companionship.

**Boundary:** Eldgrim stands outside the fellowship's conventional rank structure. This does not define additional powers, governance, or rank responsibilities.

**Status:** Established foundation.

## 2026-11-08 — Separate character canon from guild operations and software

**Decision:** Character and narrative material remains distinct from Amberhearth governance. Guild operations belong in the ROARguild repository. Technical work must remain in its own clearly identified area and must not silently alter character canon.

**Status:** Established.

## 2026-11-08 — Approve the Eldgrim Forever addon recorder

**Decision:** Add a dedicated addon workstream under addon/ in this repository. The addon targets World of Warcraft Forever only. Its first milestone is a passive local archive of guild messages and available human-readable information about the characters who send them.

**Recording scope:** Character name, race, class, level, faction, zone, profession names and skill ranks, achievement points when available, plus each guild message and its timestamp.

**Behavior boundary:** No in-game interface, slash commands, chat output, notifications, sounds, addon messaging, network communication, AI, summaries, interpretation, roster scanning, or character inspection in the first milestone. Officer chat and all other channels are excluded.

**Storage boundary:** Use account-wide SavedVariables. Do not persist account identities, GUIDs, club/member/message/chat-line IDs, or other technical identifiers. Any identifier required for a transient lookup must be discarded before saving.

**Status:** Scope approved and documented; initial implementation exists, with in-game verification pending.

## Open decisions

- Further details of Eldgrim's public identity and history.
- The precise scope of recurring in-world interactions.
- The daily agent's exact local execution time.
- The Discord channel allowlist and bot identity.
- The memory retention period and owner-controlled deletion/export workflow.
- Whether proactive messages should ever be enabled, and the limits for that capability.
- The exact local Ollama model tag and installed-version compatibility.
- The local secret-delivery mechanism and whether the user service manager should run while logged out.
- Whether any later agent/addon data integration is desirable; no integration is currently approved.
- Exact runtime behavior of Forever's chat-event and community-message APIs on the current client build.
