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

## 2026-11-10 — Eldgrim appears on Discord as the guild bot

**Decision:** Rename the existing Babuni Gaming Discord bot to Eldgrim, move it to an always-online server, and expand it. Eldgrim keeps the current administration capabilities, including rank management and channel creation, and the Character Forge.

**First feature:** Multi-character onboarding. Newcomers receive a gate role automatically, state how many guild characters they have, give each character's name, class, and race, and then gain access to the server.

**Identity:** New name and profile image on Discord. Hosted on the creative's existing server.

**Conversation:** Eldgrim is active once a day and reacts only to messages that mention @Eldgrim. Onboarding, welcomes, administration, and data storage run continuously.

**Further scope:** Store member and character data on the server as the basis of Eldgrim's database, later combined with the addon's in-game data.

**Relation to the local-agent design:** This direction was made without reference to the 2026-11-09 agent design. It agrees on the once-daily, mention-only conversation; the differences are open decisions in bot/README.md.

**Boundary:** The addon remains a silent local recorder. The bot does not define character canon.

**Status:** Direction approved. The unchanged bot runs on the server; renaming and new features not implemented.

## 2026-11-10 — Server bot and local agent work together

**Decision:** The server bot is Eldgrim's always-online part: onboarding, welcomes, administration, and data. The local agent on the creative's PC is its once-daily voice: it writes replies to @Eldgrim mentions with Ollama and posts them through the same Eldgrim Discord application.

**Administration by the AI:** Approved. The model may trigger administration only through registered tools that call the server bot's validated operations, never with the token or direct Discord API access. The exact allowed operations and limits are still to be specified.

**Addon data:** Approved. Eldgrim's database combines onboarding data with the addon's archive, and the agent may use it. The addon itself remains a silent recorder.

**Supersedes:** The 2026-11-09 agent boundaries that excluded administration and addon integration. Those remain excluded from the agent's initial milestone.

**Status:** Decided; nothing implemented.

## 2026-11-10 — Eldgrim governs the guild's Discord

**Decision:** Eldgrim's AI is not there to serve requests but to manage the guild toward defined goals. It decides on ranks and other administration itself, based on its conversations with members and the guild activity recorded by the addon. A request such as a promotion is input to its judgement, never an instruction; it acts only when it judges the action serves its goals.

**Authority:** Eldgrim holds the administrative permissions on Discord. The creative steps back from acting independently and follows Eldgrim's recommendations and plan for the guild.

**Goals and rule set:** A precise rule set will define what Eldgrim is for, what it wants, and what it strives for, so that every action can be checked against those goals. Goals that belong to Eldgrim's concealed agenda are private canon and stay outside this public repository.

**Technical boundary:** The model acts only through the server bot's validated operations, with every action recorded in the bot's audit log. It never receives the bot token or direct Discord API access. Discord's server owner keeps ownership regardless of role permissions.

**Status:** Decided. The goals and rule set are not yet written; no AI administration is implemented.

## 2026-11-10 — Amberhearth ranks everywhere

**Decision:** Use Amberhearth's ranks (Ember, Wayfarer, Kindler, Hearthkeeper, Hearthwarden) everywhere, including the Discord server, replacing the former Discord ranks Wanderer, Adventurer, Pathfinder, Trailblazer, and Firekeeper.

**Boundary:** This fixes the rank names only; duties, privileges, and progression remain undefined here.

**Status:** Decided. The Discord rank roles and the bot's texts use these names.

## 2026-11-10 — Addon development moves elsewhere

**Decision:** Further addon development happens in a separate development environment, not in this workspace.

**Status:** Established.

## 2026-11-10 — Eldgrim is an entity

**Decision:** Eldgrim is an entity, not a man. Refer to Eldgrim as "it", never "he", in documents and in everything Eldgrim says on Discord.

**Status:** Established.

## 2026-11-10 — Everyone restarts at Ember through the Forge

**Decision:** Every member except the server owner passes through the multi-character Forge and restarts at Ember on completion. Former ranks, including the Hearthwardens' Administrator permission, are removed until then; Eldgrim decides promotions afterwards.

**Member notice:** The hearth rules tell members that Eldgrim remembers their registered characters, their conversations with Eldgrim, and guild activity recorded in the game, such as guild chat, emotes, and presence at events. This notice describes intended use; what the addon records is defined in addon/ and in the separate addon environment.

**Rollout:** Step by step. The Forge is deployed first and tested by the creative; holding back ranks and hiding the public channels follow as separate, previewed switches.

**Status:** Applied on 2026-11-10 after the creative tested the Forge. The public channels are visible to the ranks only, and every member except the server owner restarts at Ember.

## 2026-11-10 — Establish an Eldgrim governance rulebook by chapter

**Decision:** Split the consolidated 10 November 2026 v0.1 working framework into 16 independently editable files under governance/ with an index and explicit refinement queues.

**Boundary:** These files distinguish established direction from developing, proposed, and open policy. They do not ratify a constitution, replace the ROARguild charter, or implement AI administration. Private character canon stays outside this public repository.

**Update:** Reconciled the Forge and rank reset status with the confirmed live rollout on 10 November 2026.

**Status:** Documentation structure established; substantive policy gaps remain open.

## 2026-11-10 — One daily proclamation comes before replies

**Decision:** Eldgrim speaks to the guild once a day before it answers mentions. The proclamation may be a story, a recognition, a quest, an invitation, an observation, or one step in a longer tale. People may write to Eldgrim so it can learn from them; reading those messages is a later step, not part of the first proclamation.

**How it reads:** The words are written on the creative's computer. Each run reads the current character voice, the established public identity, and the proclamation rules. Unfinished governance chapters are not rules. The server bot only posts the finished text. A day when the computer is off is skipped.

**Status:** Specified in agent/ANNOUNCEMENT.md. Not implemented. The channel and the hour are not chosen.

## Open decisions

- Further details of Eldgrim's public identity and history.
- The precise scope of recurring in-world interactions.
- The daily agent's exact local execution time.
- The Discord channel allowlist.
- The memory retention period and owner-controlled deletion/export workflow.
- Whether proactive messages should ever be enabled, and the limits for that capability.
- The exact local Ollama model tag and installed-version compatibility.
- The local secret-delivery mechanism and whether the user service manager should run while logged out.
- Eldgrim's goal and rule set for governing the guild.
- How the addon's local archive is transferred to the bot's server; the first addon milestone itself remains local-only.
- Open bot decisions listed in bot/README.md.
- Exact runtime behavior of Forever's chat-event and community-message APIs on the current client build.

## 2026-11-10 — Confirm the governance interview through question 62

**Decision:** The creative explicitly confirmed governance answers through Q62 in the 193-question review. Store the answers in the [question register](../governance/QUESTION-DECISIONS.md) and the relevant governance chapters.

**Key policies:** Founder-only constitutional amendments; rights and safety; 18+ membership; optional roleplay and event participation; ordinary Discord administration delegated to Eldgrim including channels and roles (correction to earlier Q34 proposal); recognition-based ranks; player-level shared rank and standing; new-member 50/100 standing; evidence-based score changes; no inactivity penalties; reviewable consequential decisions.

**Boundary:** Public documentation omits private character lore and secret motivations. This is an approved working governance record, not a change to the ROARguild charter and not implementation of autonomous administration. Next question: 63.


## 2026-11-10 — Standing and severity decisions Q63 and Q65

**Confirmed:** Q63 permits standing to inform promotions and rewards, but not discipline by score alone. A rule violation must be independently established. Q65 defines minor, moderate, serious and critical misconduct using intent, context, evidence and harm, without assigning automatic sanctions.

**Open:** Q64 was marked **needs revision**. The suggested private review and founder escalation procedure is not approved. No alternative has been decided.

**Documentation:** [Question register](../governance/QUESTION-DECISIONS.md), standing chapter and moderation chapter updated. No bot/agent behavior changed.


## 2026-11-10 — Q64: Standing and personalization are internal

**Confirmed revision:** The creative rejected the idea of a member-visible or member-reviewable standing system. Standing is Eldgrim's internal assessment, like a person's private impressions of friends, **not a high score or ranking**. Members are not routinely shown their standing, inferred profile, or internal information used to personalize Eldgrim's content. No score-inspection or score-appeal feature is approved.

**Boundary:** Existing rights to explanations and appeals of consequential guild decisions remain. Applicable legal rights over personal data must still be handled by an authorized process, without exposing other members' data. This changes documentation only; no member-facing data interface or scoring engine is implemented.

**Next:** Question 66 of 193.


## 2026-11-10 — Confirm disciplinary responses, timeout durations and hearings (Q66–68)

**Confirmed:** The creative accepted all three proposals. Eldgrim uses proportionate graduated consequences for minor, moderate, serious and critical violations, with no automatic sanction based solely on a severity label. Short, medium and long timeouts are **1 hour, 24 hours and 7 days** respectively; permanent exclusion is a distinct ban. Eldgrim hears those involved and reviews evidence whenever possible; immediate protective intervention for credible threats must be reviewed afterward. Randomness cannot determine guilt or sanctions.

**Boundary:** These are approved working-governance decisions. Evidence standards, conflicting testimony, appeals and technical enforcement remain unresolved. No bot/agent implementation or testing occurred.

**Next:** Question 69 of 193.


## 2026-11-10 — Confirm impartial testimony, disciplinary actions and warnings (Q69–71)

**Confirmed:** Eldgrim considers conflicting testimony impartially, seeks independent evidence, and does not presume higher-standing members more credible; unresolved allegations cannot justify punishment. Warning, demotion, timeout, kick and ban have distinct consequences and require documented reasons. Minor and moderate offenses ordinarily receive a warning and chance to correct behavior; serious and critical offenses may warrant immediate stronger action, with proportionality preserved.

**Boundary:** These are founder-confirmed working governance rules, not evidence of live AI enforcement. Detailed evidence thresholds, appeal procedures and reinstatement remain open.

**Next:** Question 72 of 193.
