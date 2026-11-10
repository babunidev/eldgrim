# Changelog

Meaningful repository and documentation changes are recorded here.

## 2026-11-10

- Confirmed Q171–180: confidential and post-ban appeal routes, no absolute appeal expiry, 7/14-day response targets, reliable evidence thresholds, purpose-limited incident audits, proportionate temporary protection, impartial founder-conflict review, remedies, good-faith reporting and unresolved-case safeguards. Updated governance and agent/bot documentation; no implementation or deployment.

- Confirmed Q161–170: explicit charter ratification/versioning and member notice; distinct governing documents; no retroactive discipline; guild-limited jurisdiction; member proposals; founder-only amendments during absences; scoped human delegation; verified safeguards and founder authorization required before new autonomous administration. Documentation only.

- Confirmed Q151–160: binding-charter and mandatory-law/platform precedence; explicit documented founder amendments; impartial founder-conflict appeals; equal standards, independent events, identity verification, memory correction and safe resolution of contradictory rules. Synchronized governance, agent memory and decision logs. Documentation only.

- Confirmed Q141–150: purpose-specific validated AI tools; autonomous delegated Discord administration with founder-only exceptional authorization; untrusted-message boundaries; safe failures and offline behavior; minimal audits, idempotent action execution and evidence verification. Synchronized governance and agent/bot documentation. Documentation only.

- Confirmed founder-revised Q138: Eldgrim derives narrative memory only from guild-visible Discord/Forever chat; raw server/addon collections are temporary, selected interpreted memories persist only on the founder's PC, and no other human custodian has direct access. Superseded the proposed persistent server-side narrative database and custodian access. Documentation only.

- Confirmed Q131–137 and Q139–140: privacy notices, optional profiling, in-game processing boundaries, raw chat deletion, 30-day post-departure memories, 180-day ordinary audit retention, 30-day backups, private data requests and breach response. Q138 record-access authority remains pending revision. Documentation only.

- Confirmed Q121–130: documented bank reserves, human verification for scarce/valuable items, review of allocation disputes, scoped Discord and in-game observation, temporary mention purge, confidential impressions, private corrections and departure-related data handling. Updated Chapters 11–12; documentation only.

- Confirmed Q111–120 and revised Chapters 09 and 11: voluntary Sunday bonfires with Eldgrim-chosen regions, accessible participation, and bank stewardship through authorized custodians, verified snapshots, confirmed transfers and nonpunitive failure handling. Documentation only.

- Confirmed Q101–110 and revised Chapter 08: voluntary character-suitable quests, one assignment decision per daily AI run, screenshot and authorized witness verification, nonpunitive deadlines, and discretionary rewards subject to stewardship controls. Documentation only.

- Confirmed revised Q100: unlimited @Eldgrim mentions, temporary per-run collection, discretionary random/narrative selection of at most one question per member, and discard after processing without a waiting queue. Clarified/superseded conflicting Q92/Q95 quota language. Documentation only.

- Confirmed Q91–99: daily question limits, response discretion, mention scope, proclamations, and routine decision quotas. Marked Q100 as needing revision without approving its proposed offline-message policy. Documentation only.

- Confirmed Q81–90: reinstatement after bans, adult-only Forge onboarding, required character data, unlimited membership character policy, ownership checks, character updates and departures, preservation of earned ranks, voluntary onboarding, and daily local-AI/server-bot separation. Documentation only.

- Confirmed Q78–80: private disciplinary appeals, founder or impartial human review, and reversal/correction of erroneous sanctions. Updated governance register and moderation chapter; changed interview cadence to ten questions per batch. Documentation only.

- Confirmed Q75–77: individual accountability in group incidents, distinction between mistakes/jokes and deliberate misconduct, and prohibition of random disciplinary outcomes. Documentation only.

- Confirmed Q72–74: permanent-removal safeguards, urgent protective intervention and predefined server-bot protections while the local AI is offline. Updated governance and technical-autonomy chapters; documentation only.

- Confirmed Q69–71: impartial assessment of conflicting testimony, definitions of warnings/demotions/timeouts/kicks/bans, and proportionate warning-before-escalation rules. Documentation only.

- Confirmed Q66–68: graduated disciplinary measures, 1-hour/24-hour/7-day timeouts, and fair hearings with emergency protection and subsequent review; updated governance register and moderation chapter. Documentation only.

- Named World of Warcraft Forever on the identity page and in the daily proclamation, so Eldgrim reads its setting.
- Confirmed Q64: standing, inferred profiles and personalization signals are internal to Eldgrim, not member-facing scores or rankings; preserved rights concerning consequential decisions and applicable data protection. Documentation only.
- Specified Eldgrim's first daily proclamation. It is written on the creative's computer from the solid character and governance pages, and replies to mentions wait.
- Documented confirmed governance answers Q63 and Q65 (score cannot alone justify discipline; misconduct severity classes), and marked Q64 open for revision. Documentation only.
- Saved confirmed governance answers Q1–62 in a numbered decision register, reconciled the relevant chapters, documented superseded proposals and updated decision/development logs. Documentation only; no runtime implementation changes.
- Established governance/ with a 16-chapter Eldgrim rules framework, an index, chapter-by-chapter refinement queues, and explicit draft/approval boundaries; updated documentation links and live Forge status. Documentation only; no new policy ratified.

- Sent one direct message, in Eldgrim's voice, to each member who has not registered.
- Accepted one character name or two, and posted one Forge notice for members who have not registered. Offline members see it when they next open Discord.
- Fixed the Forge to ask for each character's first name and surname, following WoW Forever's naming rules.
- Turned on the Forge switches after the creative tested it: the five public channels are visible to the ranks only, and every member except the server owner restarts at Ember.
- Deployed the multi-character Forge with the approved texts.
- Recorded that every member except the server owner restarts at Ember through the Forge, and that the hearth rules name guild activity recorded in the game (chat, emotes, presence at events).
- Recorded that Eldgrim is an entity referred to as "it", and corrected the documents accordingly.
- Recorded that Eldgrim governs the guild's Discord by defined goals rather than member requests, and that the creative follows its recommendations.
- Recorded the multi-character Forge design: Forge role on arrival, hearth rules, any number of characters, Ember on completion, public channels visible to ranks only, and every member except the owner passing through. Built and tested offline in the bot repository; not yet deployed.

- Recorded the approved direction for Eldgrim's Discord presence: rename and expand the existing guild bot, move it to an always-online server, and add multi-character onboarding, once-daily replies to @Eldgrim mentions, and a member and character database.
- Added bot/README.md with the approved direction, status, proposed data flow, open decisions, and planned order.
- Recorded that Amberhearth's ranks are used everywhere, including Discord, and that addon development continues in a separate environment.
- Recorded that the bot now runs on the creative's server under its own account.
- Merged the 2026-11-09 local-agent documentation with the Discord bot direction.
- Recorded how they fit together: the server bot is Eldgrim's always-online part, the local agent its once-daily voice. Approved AI-triggered administration through the bot's validated operations and use of the addon's archive; updated the agent documents and instructions accordingly.

## 2026-11-09

- Added the Eldgrim local-agent documentation workstream under agent/.
- Documented a once-daily, one-shot Python process using Discord REST polling, local Ollama tool calling, SQLite memory, and a systemd user timer.
- Documented the initial explicit-mention communication scope and the decision not to request Discord's privileged Message Content Intent.
- Added architecture, scope, security, memory, and operations documents.
- Updated project instructions, concept, roadmap, repository map, decisions, and development history to distinguish the proposed agent from the existing Forever addon.
- Documentation only: no Python agent, Discord application integration, runtime database, systemd unit, credentials, or deployment was created or tested.

## 2026-11-08

- Established the initial Eldgrim repository documentation foundation.
- Added contributor guidance, concept, roadmap, documentation policy, decisions, and development history.
- Added structured areas for character, lore, narrative, interaction, assets, and templates.
- Recorded the distinction between public character material, Amberhearth guild operations, and technical development.
- Documented the approved Forever-only Eldgrim addon scope: a passive local guild-chat recorder with compact character profiles and timestamped messages.
- Added Forever API research, data-model specification, and an in-game test plan.
- Added the initial Eldgrim Forever addon source and TOC manifest under addon/Eldgrim/ (version 0.1.0-alpha, interface 16001).
- Added a repeatable mock test harness under addon/tests/; Lua syntax validation and mocked behavior checks passed with texlua.
- No in-game tests, public tags, GitHub Releases, or CurseForge publication were performed.

This changelog describes repository changes, not in-world events.
