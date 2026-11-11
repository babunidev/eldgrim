# Development Log

A concise account of meaningful project development, written from the human creative's perspective.

## 2026-11-11 — A time Eldgrim chooses

Eldgrim should not speak at the same hour every day. At the end of a run it picks one moment on the next day, and the computer wakes for that moment the way Anskar's noon run wakes it, then goes back to sleep on its own. For now a run can be asked for whenever it is needed. The announcement is written here and is not posted.

**Result:** The runner is in place. qwen3:8b chose a real moment on the next day. The first tries only repeated the motto and were rejected after that; a later run wrote a short hearth line and did not post it. The wake timer still needs root once before it can wake the machine.

## 2026-11-11 — Roots before a face

Eldgrim has to know where it stands before it tells any further story. The world is World of Warcraft Forever, and the people are on Azeroth. The rest of its roots is written on this computer and kept out of the public pages. Look, sound, and presence are not decided. Those are for Eldgrim to draft from the roots when the first runs begin, and they wait for acceptance before they count.

**Result:** The origin is in ~/.local/share/eldgrim/private/ORIGIN.md. Nothing was posted. No face was invented.

## 2026-11-11 — The guild chat file, then a clean slate

The guild chat archive on this computer is the record Eldgrim should read. It is already grouped by the character who spoke. Eldgrim turns those messages into keywords, checks them against what it already keeps, and notices whether the person is the same or whether something new was actually said. A plus or a minus has to follow the standing rules already written down, and it stays private. Afterwards the messages are cleared, so the addon can fill the file again the next time the game is played. The clear waits until the game is closed, because the client would otherwise write the old lines back. The same save can also carry a roster snapshot. That snapshot, not the chat, is how Eldgrim tells who is still in the guild.

**Result:** Specified in agent/ROSTER.md. The file was not emptied, and no database was built.

## 2026-11-11 — Connect character decisions to the final agent draft

The creative approved a recognizable text-roleplay closing and asked that the character decisions reach whoever prepares the final agent instructions. AI updated the voice guide and drafting references, with concealed material kept in a separate private supplement.

**Result:** Documentation only; no runtime prompt loading or deployment was performed.

## 2026-11-11 — The roster before Eldgrim acts

Before Eldgrim writes to the guild or acts on its own, I want the way it knows the guild written down. It lives on my computer. Anyone who comes through the Forge or the addon gets an entry. When sentences come back about that person, Eldgrim turns them into keywords and keeps the keywords, not the sentences. That roster is the overview it uses to be itself. A little lore can still be added. The announcement waits until the roster is real.

**Result:** Specified in agent/ROSTER.md. No database and no announcement have been built.

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


## 2026-11-10 — Preserve confirmed questions 81–90

The creative approved ten more governance decisions concerning reinstatement, Forge requirements, member-owned character records, the initial rank migration and the once-daily local AI session. AI updated the numbered question register, relevant governance chapters and decision history, preserving the distinction between existing Forge features and intended future workflows.

**Result:** Governance documentation committed to GitHub. No bot, agent or addon source was changed or tested.


## 2026-11-10 — Replace the offline-question queue with a temporary collection

The creative rejected the proposed waiting queue for questions addressed to Eldgrim. Members should be able to mention it freely. The bot or the local AI's collection round gathers these messages temporarily; Eldgrim then chooses up to one question per person, by chance or according to what suits the character's story. The collection is discarded after the run. AI reconciled this with the previously recorded daily question limit and revised the governance, agent and bot design documents.

**Result:** Approved Q100 and synchronized public documentation. No collection system, local AI or retention behavior was implemented or tested.


## 2026-11-10 — Establish the quest rules (Q101–110)

The creative approved ten governance answers setting the purpose, frequency, consent, suitability, evidence, witness eligibility, completion handling, deadlines and reward boundaries for Eldgrim's quests. AI integrated them into the governance register and rewrote the quest chapter to remove the outdated assumption that higher rank alone authorizes verification.

**Result:** Documentation committed to GitHub. No Discord quest workflow, local AI behavior or addon integration was implemented or tested.


## 2026-11-10 — Confirm Sunday gathering and bank custody principles (Q111–120)

The creative approved ten decisions describing Eldgrim's Sunday invitations and regional themes, voluntary bonfires, simultaneous gatherings, accessibility and attendance neutrality. Guild-bank rules now distinguish freely offered contributions, authorized human custodians, verified inventory snapshots and confirmed deliveries from merely announced allocations. AI revised the corresponding governance chapters and decision register.

**Result:** Documentation committed to GitHub. No agent, bot, addon or in-game bank operation was changed or tested.


## 2026-11-10 — Bank reserves and member-data boundaries (Q121–130)

The creative approved ten more governance decisions. Bank reservations and valuable transfers now require documented limits and human verification; disputed allocations have a review path. Eldgrim's observation scope excludes unrelated private conversations and restricts memory to relevant, supported impressions. Raw chat and temporary mention collections must not become hidden permanent archives, and members have private correction and departure-related deletion processes to be developed. AI synchronized the relevant governance chapters and decision register.

**Result:** Documentation committed to GitHub. No bot, agent, addon, data purge or legal-compliance procedure was implemented or tested.


## 2026-11-10 — Define privacy lifecycle, hold record access for revision

Nine privacy decisions were approved, covering clear member notices, optional personalization, in-game data processing, temporary raw-chat handling, interpreted-memory retention, audit records, backups, private data requests and breach response. Q138, about who can inspect private records, was marked for revision rather than accepted. AI synchronized the governance register and privacy chapter without assuming the disputed access model.

**Result:** Governance documentation committed. No bot, agent, addon, database, deletion job, consent flow or security incident process was implemented or tested.


## 2026-11-10 — Keep Eldgrim's lasting memories on my PC

I clarified that Eldgrim's character observations come from conversations already shared in guild chat or designated Discord guild channels, not private exchanges. The server bot and the game addon may collect raw material temporarily, but after my local AI selects what is worth remembering, the raw messages are discarded. The selected interpretations belong in a database on my PC, accessible directly only to me and the local AI, not other guild custodians. The server bot's existing registration and administrative state is a separate operational necessity, not Eldgrim's narrative-memory archive. AI updated the governance and architecture documents to retire the old combined server-memory proposal.

**Result:** Q138 confirmed and documented. No new Discord observation permissions, synchronization, deletion, local database or AI processing feature was implemented or tested.


## 2026-11-10 — Bound Eldgrim's technical authority (Q141–150)

The next ten decisions establish how Eldgrim may act without receiving unrestricted control of my computer or Discord. Authorized channel, role and permission changes should eventually be autonomous through independently checked tools, while exceptional infrastructure actions still require my explicit approval. Failed or ambiguous actions must not duplicate sanctions or rewards, and guild messages cannot command the system. The bot's present approval workflow remains until a validated replacement is built. AI synchronized the governance register, technical chapter, agent security, architecture, operations and bot instructions.

**Result:** Q141–150 recorded as founder-confirmed working policy. Documentation only; no live agent, new autonomous bot actions, audit executor or purge mechanism was implemented or tested.


## 2026-11-10 — Clarify conflicts and correction (Q151–160)

The latest ten answers establish how Eldgrim handles rules that disagree, especially the separate guild charter, mandatory platform requirements and my own informal instructions. The written rules remain authoritative unless an explicit founder decision amends them. A complaint involving me needs an impartial human reviewer, without giving that reviewer direct access to the local memory database. Members may hold their own events; friendships and ranks cannot alter disciplinary fairness. Eldgrim must verify uncertain character identities and correct memories when better evidence appears. AI recorded the decisions across the governance register, chapters on authority, conflicts, hierarchy, documents, membership, Sunday gatherings, moderation, memory and contributor guidance.

**Result:** Q151–160 documented as working governance. No charter ratification, reviewer system, identity matching or local memory correction feature was implemented or tested.


## 2026-11-10 — Define the adoption and activation gate (Q161–170)

The next ten answers distinguish the act of documenting rules from making them binding. A charter needs an identified approved version, effective date and member access; future amendments must be traceable and announced. No retroactive discipline or policing of unrelated private lives is allowed, and members remain free to suggest changes. Human duties can be delegated without turning recognition ranks into command positions or exposing the local memory database. Before Eldgrim can administer Discord autonomously, its tools, safeguards, appeals and emergency stop must be verified and deployment explicitly authorized. AI synchronized the question register, governance chapters, agent/bot guidance and development records.

**Result:** Q161–170 recorded as working governance. No charter ratification, new deployment approval, autonomous administration, safeguard test or bot integration was performed.


## 2026-11-10 — Complete the appeal and evidence rules (Q171–180)

The next ten decisions give members a private way to challenge sanctions, even after leaving the Discord server, without an absolute expiry. Seven days to acknowledge and fourteen to decide are operational targets, not invented guarantees. Discipline needs reliable evidence; uncertain character identity, standing and rumors are not proof. Temporary restrictions protect against present risk rather than pronounce guilt, and unresolved accusations remain unproven. Founder-related appeals require an impartial human reviewer without exposing the local narrative-memory database. Case records remain purpose-limited, subject to existing audit retention, and never become a permanent guild-chat archive. AI synchronized the question register, moderation, privacy, conflicts, agent and bot design, and development documentation.

**Result:** Q171–180 documented as founder-confirmed working policy. No appeal system, reviewer appointment, evidence vault, retention job or automated sanction was implemented or tested.


## 2026-11-10 — Define how Eldgrim can be stopped and safely recovered (Q181–190)

The latest ten decisions specify an emergency stop I can use, or delegate to an explicitly authorized technical custodian, without exposing the local memory database. It must halt new automated actions and stay off until authorized recovery. Server credentials remain separate from my PC-local memories, and tool permissions must be enforced by code rather than model instructions. Every administrative tool needs negative tests and failure/retry checks before a reversible rollout. Backup recovery must respect the approved retention and deletion rules. When my PC or AI is offline, the server bot continues only its verified functions; compromise triggers containment and review. Periodic technical and governance checks cannot change the charter by themselves. AI synchronized the question register, technical governance chapter, conflict inventory, agent security/memory guidance, bot documentation and development records.

**Result:** Q181–190 documented as founder-confirmed working requirements. No emergency stop, tool executor, autonomous administration, verified restore, custodian appointment, security test or deployment approval was performed.


## 2026-11-10 — Finish the rulebook interview (Q191–193)

I accepted the last three answers, completing all 193 governance questions. The final decisions require us to compare the answers with the sixteen chapters and the separate guild charter, preserve corrections instead of resurrecting old proposals, and track which rules are only written versus actually built and tested. The result is a working baseline, not a ratified guild charter or permission to switch on autonomous administration. AI recorded the final answers, created a consistency audit and implementation matrix, and updated the chapter index, documentation guide and contributor instructions.

**Result:** Interview complete and documentation committed. The audit is an initial documentation comparison, not a full cross-repository charter or runtime audit. No new feature was implemented, tested, deployed or ratified.
