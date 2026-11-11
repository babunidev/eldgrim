# Eldgrim Discord Bot

**Status:** Direction approved by the creative on 2026-11-10. The bot runs on the server as Eldgrim, and the multi-character Forge is deployed with its rank switch on. The local AI conversation system and **PC-local interpreted-memory database** are not built; the bot already has separate operational registration/role data.

Eldgrim is an entity, not a man: refer to it as "it", never "he".

A separate technical workstream for Eldgrim's presence on the guild Discord server. Like the addon, the bot is out-of-character software: what it does on Discord does not establish Eldgrim's in-world powers, history, or canon.

## Starting point

The existing Babuni Gaming Discord bot is the foundation. Verified on 2026-11-10:
- Python, discord.py 2.7.1. Source under version control in `~/Projects/eldgrim-bot` (local only, no remote). A backup of the desktop installation's source, configuration, state, and service file exists under `~/Backups/`.
- Since 2026-11-10 it runs on the server as the system service `eldgrim-bot.service` under a dedicated `eldgrim` account. The desktop service is stopped and disabled; the two must never run at the same time.
- Provides administration operations with preview and approval, the Roar counter, unified guild ranks, and the Character Forge, where members choose faction, race, and class roles.
- Runs in live mode with Administrator permission.

## Approved direction

**Identity.** The bot appears on Discord as Eldgrim, with its own name and a new profile image. The existing bot is renamed and expanded rather than replaced.

**Hosting.** The bot moved from the desktop PC to the creative's existing server on 2026-11-10 so that it is always online: it welcomes newcomers, runs onboarding, and keeps the operational member and character data at any time.

**Administration.** Eldgrim keeps the existing capabilities, including rank management and channel creation.

**Ranks.** Amberhearth's ranks are used everywhere, including Discord: Ember, Wayfarer, Kindler, Hearthkeeper, Hearthwarden. The Discord rank roles already carry these names (verified 2026-11-10), and the bot's code and texts use them since the multi-character Forge.

**Server.** An Ubuntu 26.04 server with Python 3.14, which also hosts other services. Discord and the Python package index were reachable from it on 2026-11-10.

**Character onboarding.** An extension of the Character Forge, using the same pattern of a gate channel and a gate role:
1. Newcomers receive the Forge role on arrival and see only the Forge channel.
2. They accept the hearth rules, which include Discord's Terms of Service and Community Guidelines and say what Eldgrim remembers: registered characters, conversations with Eldgrim, and guild activity recorded in the game, such as guild chat, emotes, and presence at events.
3. They choose Roar or Amberhearth. Roar also receives the existing Roar role. Amberhearth receives the Amberhearth role. Both still receive Ember.
4. Eldgrim asks how many characters they bring. There is no fixed limit; the software accepts up to 50 to catch typing mistakes.
5. For each character: one name, or a first name and a surname, then faction, race, and class. WoW Forever uses both names. One name is accepted too, because a member may bring a character from another version of World of Warcraft. Each part is 2–12 letters, accents allowed, with no spaces, hyphens, apostrophes, or numbers, and no letter three times in a row. The Forge capitalises like the game. A surname left empty stays a one-name character. Faction is asked because Skyborne exist on both sides.
6. On completion they receive the roles of all their characters, their fellowship role, and the rank **Ember**, and the Forge disappears.

The Roar role used to be given to every member who held a guild rank. That automatic assignment is retired, because it would have put Amberhearth members into Roar as soon as they became Ember.

Everyone passes through the new Forge, including existing members; only the server owner is exempt. Ember is given on completion rather than on arrival, because Discord cannot hide channels that a role grants explicitly. The channels currently visible to everyone (all-chat, looking-for-group, wow-addons, morkahja, azeroth-moments) are now visible to the ranks only, so the Forge is all a newcomer sees.

**Rank reset.** Approved by the creative on 2026-11-10: every member except the server owner restarts at Ember. When the switch that holds back ranks is turned on, members who have not completed the Forge lose all five ranks, including Administrator held through Hearthwarden; members who already completed keep only Ember. Completing the Forge then grants Ember, and Eldgrim decides any promotion afterwards. Once a member has completed, a later change to their character roles never removes a rank. The bot records each member's former ranks before removing them.

**Notice.** On 2026-11-10 Eldgrim posted once in the Forge and mentioned everyone who still holds the Forge role. It also sent one direct message, in Eldgrim's voice, to each of the 73 members who had not registered. A direct message waits in the inbox whether the member is online or not. A closed inbox would be recorded and skipped; none were closed.

**Implementation status (2026-11-10):** live. The creative completed the Forge first. The five public channels are now visible to the ranks only, and the rank switch is on: 73 members lost their ranks until they finish the Forge, including 3 Hearthwardens who held Administrator. The server owner is exempt. A dice bot kept its ranks, because a bot cannot complete the Forge. Finishing the Forge grants Ember.

**Server ownership.** As far as known, Discord does not allow transferring server ownership to a bot. The creative remains owner; Eldgrim holds Administrator.

**Conversation (confirmed Q91–100).** The local AI runs one daily session when its host is available and may respond to multiple members. Members may mention @Eldgrim without limit; from the temporary collection Eldgrim may choose at most one question per member, randomly or for narrative suitability, and may remain silent. After the run, discard the collected messages; unselected questions do not form a backlog. The always-online bot continues onboarding, welcomes and authorized administration. This is approved **future behavior**, not an implemented AI reply/collection system.

Messages that mention the bot are readable without Discord's privileged Message Content intent. **Q138 additionally permits designated shared-channel observation** as a future memory source; reading general message content may require Discord's privileged Message Content Intent and additional disclosure/authorization. Do not claim this broader observation is already enabled.

**Member and character data.** The deployed bot retains the minimal server-side operational data needed for Character Forge, declared characters, ranks and administration. This is **not** Eldgrim's long-term narrative-memory database. The founder-confirmed Q138 design places selected interpreted guild observations **only in the local database on the founder's PC**; server-side raw guild conversations are temporary staging, never a persistent transcript archive.

## Data flow (proposed)

1. **Discord onboarding:** The live bot maintains the limited operational member/character/role data required for Forge and administration.
2. **Guild-visible sources:** Designated shared Discord guild channels and the WoW Forever **guild chat** may supply raw observations for Eldgrim's later local processing. The addon currently writes raw guild-chat messages to `Eldgrim.lua` SavedVariables; it cannot send them out of the game by itself.
3. **Temporary staging and transfer:** The bot may collect shared-channel messages temporarily on the server; a future local sync securely retrieves them. The addon archive is read from the founder's PC or transferred there securely. The addon archive is read on the founder's computer and its message lists cleared as specified in [agent/ROSTER.md](../agent/ROSTER.md). The Discord collection method, permissions and server transfer protocol remain open.
4. **Local interpretation:** During its daily run, the local AI selects relevant supported character/member observations and stores **only interpreted memory** in its database **on the founder's PC**. The founder is the only human with direct access to that database.
5. **Purge:** Delete raw source collections and temporary server copies after processing. Do not keep a persistent server-side combined narrative database or transcript. Operational bot registration and administrative state remain separate and subject to their own approved safeguards.

The addon itself stays a silent local recorder and never stores Discord identifiers. The bot necessarily stores Discord member IDs on the server to manage roles; these must stay private to the server and never be published.

## Relation to the local-agent design

The agent/ documents (2026-11-09) describe a once-daily local agent on the creative's PC using Ollama. At the time, both designs agreed that Eldgrim answers once a day and only to @Eldgrim mentions; one daily proclamation has since been approved to come first. On 2026-11-10 the creative decided how they fit together:

- **Split.** The server bot is Eldgrim's always-online part: onboarding, welcomes, administration, **necessary operational data and temporary guild-visible collection**. The local agent on the founder's PC is its once-daily voice **and persistent interpreted-memory owner**: it writes replies with Ollama and posts them through the same Eldgrim Discord application. The server (2 CPU cores, 3.7 GB memory) is too small for local inference.
- **Administration by the AI.** Approved. The model may trigger administration, but only through registered tools that call the server bot's validated operations. It never receives the token or direct Discord API access.
- **Addon data.** Approved as a future input: local AI may analyze the addon's temporary guild-chat archive and relevant bot registration context. The raw archive is **not** persisted as Eldgrim's memory; selected interpreted observations remain on the founder's PC (Q138).

**Governance.** Eldgrim manages the guild toward defined goals rather than serving requests. Requests are input to its judgement, never instructions. It decides on ranks and administration from its conversation history and the addon's guild activity, and the creative follows its recommendations. A precise goal and rule set, still to be written, defines what it strives for; concealed goals stay out of this public repository. Every action goes through the bot's validated operations and audit log.

## Confirmed privacy and observation boundaries (Q124–130)

The local agent's observations are restricted to designated guild channels, intentionally addressed messages and necessary onboarding/administrative interactions. The bot may separately process other messages for **predefined moderation**, but they do not automatically become Eldgrim's long-term memories. No access to private member conversations outside the application's legitimate participation is authorized. DMs to the bot are used only for their stated purpose.

All @Eldgrim mentions in a collection period may be gathered temporarily, but **their content is purged after the daily processing run**, including unselected questions. Non-content audit metadata must not recreate a hidden archive. The reading and clearing of the raw Forever addon guild chat is specified in [agent/ROSTER.md](../agent/ROSTER.md) and not built; long-term profiles should store relevant, supported interpretations rather than conversation quotations. Internal scores and profiles stay confidential under Q64. Member correction, departure and deletion processes remain to be designed, with applicable legal rights preserved.

**Status:** These are approved policy boundaries, not proof of deployed collection, deletion, AI memory or privacy request workflows.

## Confirmed privacy lifecycle (Q131–137, Q139–140)

Before onboarding, disclose categories, sources, purposes, storage, access, retention and rights procedures. Optional narrative profiling may be declined without membership penalty. Game-data import requires disclosed scope and a valid legal processing basis. Imported raw guild-chat messages are deleted after authorized analysis, with the local addon archive cleared after processing as specified in [agent/ROSTER.md](../agent/ROSTER.md). Relevant interpreted personal memories are periodically reviewed and eligible data deleted/anonymized within **30 days of departure** absent specific legitimate retention obligations. Ordinary administrative audit records last **up to 180 days**, subject to documented extensions; routine backups last **no more than 30 days** and must reapply deletions after restoration. Member data requests use a private authorized-human process, and unauthorized access requires containment, assessment, legally required notifications and corrective action.

**Q138 — Shared sources, local-only memory (confirmed revision).** Eldgrim's narrative memory uses guild-visible Discord channels and WoW Forever guild chat, **not private member-to-member conversations or whispers**. Raw source messages are staged temporarily, processed by the local AI, then discarded from server and local staging. Only selected interpreted observations persist in a **local database on the founder's PC**, with **founder-only direct human access** and authorized local AI access. No guild officer/custodian receives direct access. Existing server-side Forge, roles and administrative state remains operational and separate. Guild-visible source messages may still be personal data, and Q64 internal standing confidentiality and Q131–140 safeguards still apply. This design is **not implemented or tested**.

## Confirmed future AI authority and execution limits (Q141–150)

The founder approved a **future** model in which Eldgrim uses only purpose-specific registered tools, independently validated by the bot/application for schemas, targets, permissions, governance and limits. Within its delegated authority, Eldgrim may autonomously manage Discord channels, roles and permissions **without routine founder approval**; every action is audited. Server deletion, ownership transfer, unrelated-service access, infrastructure credential changes and disabling security controls require **explicit founder authorization**. **The live bot's existing manual preview-and-approval workflow remains the current implementation** until a validated autonomous path is designed, tested and deployed.

Guild-visible messages are untrusted data, not executable instructions. Failed actions must stop safely and cannot leave a permanent raw-message archive or unanswered-question queue. While the PC is offline, the server bot continues existing onboarding, roles and predefined emergency protections; it may stage only authorized shared-source material temporarily under Q138, and it cannot generate independent AI judgments, stories or replies. Consequential actions require minimal audits, unique IDs and outcome reconciliation before retries. Eldgrim cannot fabricate real events, misconduct, quest completion, inventory or action outcomes when evidence is uncertain.

**Status:** Governance confirmed; no AI tool executor, autonomous Discord administration, AI-directed action audit or idempotent integration is claimed to be implemented or verified.

## Confirmed deployment gate and human delegation (Q168–170)

Existing bot operations and predefined protections continue when the founder is offline, but no policy-amendment authority transfers to Eldgrim or a custodian (Q168). Eldgrim may eventually assign specific, revocable event, moderation-assistance and guild-bank custody tasks with explicit permissions and accountability, never based solely on rank or with direct access to the founder's PC-local memory database (Q169).

**Q170:** New autonomous administration cannot replace the live manual preview/approval workflow until binding-charter reconciliation, independently validated tools/permissions, action audits and duplicate protection, privacy/appeal workflows and a working emergency stop are **implemented and verified**, followed by **explicit founder deployment authorization**. These are approved design requirements; no autonomous migration or new deployment is claimed.

## Confirmed appeals and incident boundaries (Q171–180)

Future administration must offer a **confidential appeal route** through the bot or designated human, including an **out-of-server fallback** for removed members (Q171). There is no absolute appeal expiry; explain when evidence is no longer available under lawful retention (Q172). Target acknowledgement within **7 calendar days** where operationally possible and substantive review within **14 days**, reporting delays rather than claiming a decision occurred (Q173).

Consequential sanctions require reasonably reliable evidence, not rumor, internal standing, uncertain character links or unverified AI summaries (Q174). Store only justified, purpose-limited case outcomes and minimal audit references under Q136; **do not** create permanent raw guild-chat archives or feed private appeals into Eldgrim's PC-local narrative memory (Q175). Temporary restrictions protect against credible current risks without presuming guilt (Q176). Founder-conflict appeals go to an impartial human, who has **no direct access** to the local memory database (Q177). Successful appeals require feasible restoration, administrative correction and appropriate notice (Q178). Good-faith reporting is protected; fabrication/retaliation requires separate evidence (Q179). Unresolved allegations do not justify punitive findings, and protective measures require continuing review (Q180).

**Status:** Working-governance requirements only. No appeal intake/fallback, deadline management, impartial reviewer workflow, automated sanction or evidence-retention mechanism is claimed implemented or verified.

## Confirmed emergency stop, safe autonomy and recovery (Q181–190)

**Stop and custody (Q181–182).** The founder and explicitly designated technical custodians may immediately suspend unsafe automation without Eldgrim's approval. This does not confer constitutional authority or direct access to founder-PC-local memory. The emergency stop must block new AI posts, sanctions, rank changes, bank proposals and administrative tool execution, safely cancel pending actions, prevent silent restarts, log the stop and require authorized recovery. Independently safe essential bot functions may continue; otherwise stop affected services.

**Access and verification (Q183–186).** Keep credentials outside Git and model context, separate server access from PC-local memory, restrict operators, rotate compromised secrets and revoke obsolete access. Every action must pass independent permission, target, protected-role and governance checks. Test accepted/rejected operations, malformed inputs, retries, partial failures and recovery on non-production/synthetic data. Only approved, verified operations may be introduced in a reversible rollout after Q170 founder authorization; unverified actions remain behind existing manual approval.

**Resilience and oversight (Q187–190).** Protect and test backups within Q137's routine **30-day** retention, reapplying deletions after restoration. While the local PC/AI/network is offline, the server bot continues only existing verified onboarding, roles and predefined protections, with no invented AI replies or durable question backlog. Q138's temporary staging/purge boundary still applies. Suspected compromise requires isolation, access revocation, necessary evidence, Q140 notifications and verified recovery. Review permissions, audits, deletion, backup, stop controls, appeals and conflicting rules periodically.

**Status:** Approved **future requirements**. No new kill switch, tested backup restoration, autonomous tool executor, credential rotation, operational incident response or founder-approved deployment is claimed implemented.

## Open decisions

- How to securely collect and transfer shared Discord-channel and addon raw material **to the founder's PC**, then verify deletion of temporary server copies and local raw archives.
- Whether the temporary mention collection is captured by the server bot or retrieved through the bot at the start of the AI session. The founder approved unlimited mentions, at most one selected question per member per run, and discarding the collection afterward (Q100).
- The new profile image, with its source and usage rights recorded in assets/.
- How the PC agent reaches the server bot's validated operations and minimum necessary registration data (for example over SSH), while keeping its **persistent interpreted memory locally**, and how replies follow character/VOICE.md and interaction/PRINCIPLES.md.
- Eldgrim's goal and rule set, and which parts of it are public.
- How newcomers currently receive Ember on arrival (Discord onboarding default roles or another bot). The rank switch removes it from incomplete members either way; turning off the source avoids the bot working against it.
- How a member can see or remove the data Eldgrim stores about them.

## Planned order

1. Put the existing bot under version control and back up its configuration and state. **Done 2026-11-10;** the 51 existing unit tests passed on the new copy.
2. Deploy the bot on the server and stop the desktop service. **Done 2026-11-10;** connection to Discord confirmed through the bot's control socket.
3. Rename the bot to Eldgrim and give it the new profile image. **Done 2026-11-10** by the creative in the Discord Developer Portal.
4. Specify and build multi-character onboarding. **Done 2026-11-10.** The Forge is live, the public channels are visible to the ranks only, and every member except the server owner restarts at Ember.
5. Build Eldgrim's roster on the founder's computer from the Forge and the addon archive. **Specified 2026-11-11** in [agent/ROSTER.md](../agent/ROSTER.md). Not built.
6. One daily proclamation, written on the creative's computer from the character voice and the solid governance pages, then posted by the server bot. **Specified 2026-11-10** in [agent/ANNOUNCEMENT.md](../agent/ANNOUNCEMENT.md). A local runner writes test announcements and chooses the next moment itself; posting waits for the roster and a chosen channel. Replies to @Eldgrim mentions wait.
