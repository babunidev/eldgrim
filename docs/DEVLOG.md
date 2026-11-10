# Development Log

A concise account of meaningful project development, written from the human creative's perspective.

## 2026-11-10 — Roar and Amberhearth in the Forge

Some people on the Discord belong to Roar, and some belong to Amberhearth. I asked for that choice in the Forge, after the rules and before the characters. Roar members keep the Roar role as well as Ember. Amberhearth members receive a new Amberhearth role and Ember. AI found that the Roar role had been given automatically to anyone with a guild rank, which would have erased the difference, and retired that automatic assignment.

**Result:** The choice is live. The Amberhearth role exists. Members who already finished are unchanged until they run the Forge again.

## 2026-11-10 — A daily word from Eldgrim

Replies to mentions can wait. What I want first is Eldgrim speaking to the guild once a day, a story or a small announcement, in its own voice. The governance chapters are still being written, so the first version reads only the pages that are already solid, and it reads them again each day so a later edit is picked up. The writing happens on my computer, because that is where the model runs. The bot on the server only posts the finished words.

**Result:** Specified, not scheduled, and not posting. The announcements channel is already visible to the ranks and hidden from members who have not finished the Forge.

## 2026-11-10 — Preparing Eldgrim's governance chapters

To work through Eldgrim's constitution chapter by chapter, I asked AI to put the consolidated guild rules and governance framework into the Eldgrim repository as separate Markdown documents. AI organized the sixteen chapters into governance/, added individual refinement queues, linked the rulebook from project documentation, and kept private character canon out of the public files. It also aligned the Forge status with the confirmed live deployment instead of preserving the earlier offline-only description.

**Result:** The working rulebook is in GitHub as documentation; no new governance rules were ratified and no autonomous administration was implemented or tested.

## 2026-11-10 — Approving the Forge and the rank reset

Reviewing AI's drafts, I corrected three things: Eldgrim is an entity and must never be called "he"; the notice covers all guild activity recorded in the game, including emotes and presence at events; and the Forge must make clear that race and class are being asked. Beyond that, I decided that everyone except me restarts at Ember, with Eldgrim deciding promotions afterwards.

AI made the corrections and built the reset into the switch that holds back ranks. It removes ranks only from members who never completed the Forge, so a later promotion cannot be undone by accident, and records former ranks first. Deploying, AI found that its own copy step had left the files unreadable for the service account; the bot was offline for about seven minutes until AI fixed the permissions and wrote a safer update script.

Some members bring characters from other versions of World of Warcraft, so a single name has to be allowed as well as a first name and a surname. I also asked Eldgrim to call everyone who has not registered. AI posted that call in the Forge, then sent the same call as a direct message to each of them.

Testing the Forge myself, I found it rejected a full character name: WoW Forever gives every character a first name and a surname, and AI had built the check for a single name. AI verified the naming rules from Blizzard's announcement and a rules guide, then split the question into first name and surname with the same limits the game uses.

After testing the Forge, I approved both switches. AI hid the five public channels behind the ranks, then removed every rank except mine. A dice bot kept its ranks, since a bot cannot complete the Forge.

**Result:** The Forge is live. A character may have one name or two, and Eldgrim has called the 73 members who have not registered. They see only the Forge until they finish, and finishing grants Ember.

## 2026-11-10 — Building the multi-character Forge

With the bot renamed to Eldgrim and given its new image, I asked AI to build the multi-character onboarding. Every newcomer should see only the Forge, accept the hearth rules, name every character they bring, and become an Ember on completion. Existing members pass through it too; only I as server owner am exempt.

AI checked the live permission layout and found that Discord cannot hide channels a role grants explicitly, so Ember now follows completion instead of arrival, and the five public channels will move to the ranks. A test also showed that hiding a channel from everyone would hide it from ranks relying on server-wide access, so every rank receives the former public access explicitly. AI rewrote the Forge, drafted the hearth rules and Eldgrim's texts, and replaced the old rank names in the bot.

**Result:** Built and tested offline (61 tests). Not deployed; the texts await my approval, and the switches that hold back Ember and hide the public channels stay off until I approve them.

## 2026-11-10 — Moving the bot to the server

To keep the bot online at all times, I approved moving it to my existing server under its own account. AI wrote the setup script, staged the code and configuration, stopped the desktop service, and transferred the bot's database; I ran the script with my server password. Two problems surfaced and AI fixed both: the service account could not read the Python environment, and the bot's token check rejected the file permissions systemd uses for system services.

When publishing these notes, AI found the local-agent documentation from 2026-11-09 on GitHub and merged it. Both designs agree that Eldgrim answers once a day and only to @Eldgrim. Afterwards, I decided how they fit together: the server bot stays always online for onboarding, administration, and data, while the agent on my PC becomes Eldgrim's daily voice. The agent may also trigger administration through the bot and use the addon's archive.

**Result:** The bot runs on the server and its Discord connection was confirmed. Behavior is unchanged; it is not yet renamed.

## 2026-11-10 — Bringing Eldgrim to Discord

Eldgrim should be present where the guild gathers outside the game. Rather than starting a new bot, I decided to rename and expand the existing guild Discord bot, which already runs the Character Forge, and to move it to a server so it is always online. Its first new task is to ask newcomers which characters they play in the guild before opening the server to them. Eldgrim will speak only once a day, and only to those who call on it with @Eldgrim.

AI inspected the existing bot and the installed addon. The addon's saved archive held 79 guild messages from 8 characters but no character details, so profile enrichment does not yet work in-game. AI recorded the direction, data flow, and open questions under bot/, copied the existing bot's source into its own local git repository, backed up its configuration, state, and service file, and confirmed that the 51 existing unit tests pass on the copy.

**Result:** Direction documented and bot source under version control.

## 2026-11-09 — Documenting the local agent architecture

With Eldgrim's technical direction expanding beyond the passive addon, I asked AI to research and document a local agent that would act once per day while remaining autonomous within clear boundaries. The design separates Discord communication from local model inference: a systemd user timer starts a one-shot Python process, the process polls configured Discord channels through the HTTP API, local Ollama performs bounded reasoning and tool calls, and SQLite holds private runtime memory outside the repository.

AI checked the design against the current official Discord, Ollama, Python, and systemd documentation. The initial communication scope is limited to explicit mentions, without requesting Discord's privileged Message Content Intent. The documentation also records that REST polling still exposes message metadata for the selected channels, so unrelated messages must not be archived or sent to the model.

The agent remains independent of the Forever addon and of Eldgrim's public character canon. Proactive channel posts are documented as an opt-in capability rather than a default behavior.

**Result:** Added the agent architecture, specification, security, memory, and operations documentation; updated the repository map, instructions, concept, roadmap, decisions, and changelog. This was a documentation change only. No Python agent, Discord integration, SQLite runtime database, systemd unit, or deployment was created or tested.

## 2026-11-08 — Establishing the repository foundation

With Eldgrim becoming a distinct character and narrative project, I asked AI to establish a documentation structure that could hold the character's identity, voice, lore, and developing stories without confusing them with Amberhearth's guild administration or a possible future software implementation. The existing README provided the initial direction; AI organized the supporting documents and folder structure, preserving unresolved details as open rather than inventing canon.

**Result:** Documentation structure committed to the repository. No addon, bot, or other software was implemented or verified.

## 2026-11-08 — Defining the first addon milestone

After narrowing the addon's first responsibility to passive local guild-chat recording, I approved a dedicated technical area inside this repository while keeping it separate from Eldgrim's in-world character material and Amberhearth's guild operations. The initial archive is limited to character names, available human-readable character details, message text, and timestamps. It has no in-game interface or interaction.

AI reviewed the repository instructions and documentation, researched the Forever-specific chat and character APIs, and recorded both the available data and the unresolved runtime questions. The current research baseline is Forever 1.60.1, interface 16001, with build 1.60.1.70862 as the latest public build found during this work.

**Result:** Addon specification, API research, data model, and test plan added. No addon source code was implemented; no syntax checks or in-game tests were run.

## 2026-11-08 — First recorder implementation

With the first milestone settled, I asked AI to implement the Forever-only event recorder and its TOC manifest inside the existing addon/ area. The code registers only CHAT_MSG_GUILD, checks chat-messaging lockdown before reading the event payload, and accepts community author data only when the returned record is a guild message whose content and author exactly match the current event.

The archive stores character-facing names and values only, alongside timestamped message text. Community identifiers are kept transiently for correlation and are never written to SavedVariables. When a community record cannot be matched, the message uses local receipt time and is saved without unverified profile enrichment.

AI added a repeatable mocked test harness. Lua syntax validation and the mock behavior suite passed with texlua. These checks exercise local logic only; live Forever event correlation, profile data, SavedVariables persistence, and in-game behavior have not been verified.

**Result:** Initial addon source, TOC manifest, and mock tests committed. No public release was created.

## 2026-11-10 — Preserving confirmed governance answers

To protect the question-by-question rule review from conversation limits, the creative asked AI to document every approved answer through question 62 in GitHub. AI updated the affected governance chapters and introduced a numbered decision register, including the correction allowing Eldgrim to manage Discord channels independently. Private character details were deliberately kept out of the public repository.

**Result:** Governance documentation committed. No bot, agent or game addon source changed or tested.


## 2026-11-10 — Clarify Q64 internal standing confidentiality

The creative clarified that Eldgrim's standing and member-personalization context are internal, not a high score, ranking or member-facing profile. AI recorded the confirmed revision in the question register and relevant governance chapters, distinguishing confidential creative context from appeals of consequential decisions and applicable data rights.

**Result:** Documentation only. No bot, agent or addon implementation or tests.
