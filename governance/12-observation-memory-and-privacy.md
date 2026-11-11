# Chapter 12 — Observation, memory, and privacy

> **Status:** Founder-confirmed collection, retention, local-memory and privacy boundaries (Q64, Q82–87, Q124–140); technical implementation open  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1. Working material, not a ratified constitution.

Technical boundaries partly specified · Member policy confirmed; procedures unimplemented

Three different information sources are being developed.

| Source         | Intended information                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| Discord bot    | Member registrations, characters, roles, onboarding, and administrative records |
| Local AI agent | Eligible @Eldgrim interactions, memories, intentions, and decision history      |
| WoW addon      | Guild chat messages, timestamps, and available character information            |

The existing addon code is a passive guild-chat recorder. It stores verbatim guild messages locally in SavedVariables. Its mock tests passed, but in-game behavior is not yet verified.

The agent's initial design processes eligible @Eldgrim mentions and keeps its SQLite memory **on the founder's PC**. Under the founder's revised Q138, designated shared Discord-channel and in-game guild-chat observations may also supply temporary context for character memory. An earlier proposal to keep a **combined, persistent Eldgrim narrative-memory database on the server is superseded**. The deployed bot still keeps the minimal operational registration/role/administrative state necessary for its existing functions; this is a separate system.

Those systems are intended to be connected later, but the full integration does not yet exist. The member notice covers possible in-game chat, emotes, and event presence; that notice does not prove these observations are implemented by the current addon.

The original privacy principles require that Eldgrim's long-term member profiles contain interpreted information rather than conversation quotations, that internal scores and observations remain private, and that decisions not publicly expose the conversations behind them.

Founder decisions establish member notices, optional profiling, consent/processing boundaries, retention periods, backup handling, correction, departure and incident response. Q138 additionally establishes **guild-visible sources only for narrative memory**, temporary raw staging and founder-only human access to the persistent local memory database. Detailed technical implementation remains open.

See [agent security](../agent/SECURITY.md), [memory design](../agent/MEMORY.md) and [the roster](../agent/ROSTER.md).

## Confirmed observation and privacy boundaries — questions 124–130

- **Q124 — Discord channels:** Eldgrim may observe only **explicitly designated guild channels**, messages intentionally addressed to it, and necessary onboarding/administrative interactions. The server bot may process other content only for predefined moderation; this does not authorize automatic inclusion in Eldgrim's personal memory.
- **Q125 — Private conversations:** Eldgrim has no right to inspect private exchanges where its application is not a legitimate participant. Messages sent **to the bot** may be processed for the stated purpose; they are not automatically public guild activity or storytelling material.
- **Q126 — In-game guild chat:** The existing Forever addon stores raw guild-chat messages in local SavedVariables. For **future authorized integration**, raw records are temporary analysis inputs, not indefinite personal memories. Long-term profiles favor relevant interpreted facts, topics and observations over verbatim quotations. Define and implement deletion of raw archives **before** production integration; this does not assert that the current addon already deletes them.
- **Q127 — @Eldgrim mention collection:** As required by Q100, eligible mentions collected by the bot or agent are temporary and their message content is **purged after the daily processing run**, including unselected questions. Non-content operational audit metadata may remain only where necessary and must not reconstruct a hidden archive. Failure/partial-run handling is still open.
- **Q128 — Internal impressions:** Retain only relevant, reasonably supported interpretations of participation, character interests, helpfulness, conduct and shared experiences. Exclude sensitive real-world characteristics, unsupported psychological conclusions and verbatim private conversations. Standing and inferred profiles remain confidential under Q64, without overriding applicable legal rights.
- **Q129 — Correction:** Members can privately request corrections of registration facts and consequential administrative records. An authorized human reviews unresolved disputes. Eldgrim may correct its own internal impressions without exposing private profiles; legal data access and rectification rights are preserved.
- **Q130 — Leaving:** Deactivate membership and character records, cease routine collection, and offer a private deletion request process. Retain only information justified by safety, legal or administrative obligations under the retention periods later set by Q135–137. Do not profile former members in retaliation.

**Implementation boundary:** These are confirmed governance decisions, not proof of an implemented purge, consent, deletion, or integrated data system. No new access to unrelated Discord channels or private conversations is authorized.

## Confirmed notice, consent and retention — questions 131–137

- **Q131 — Notice:** Before onboarding, explain collected information, sources, purposes, storage, who may access it, retention and privacy rights. Disclose material changes before broader collection. The actual notice and its delivery/acknowledgement mechanism must be implemented and verified.
- **Q132 — Optional profiling:** Members may opt out of optional narrative personalization/profiling without losing membership, rank or ordinary activities. Necessary registration, security and administrative data may still be processed for disclosed lawful purposes.
- **Q133 — In-game collection:** Disclose observation scope and purposes to affected members and establish any legally required consent or other valid basis before importing guild-chat or activity data. Do not silently expand to whispers, private channels, unrelated players or other activity categories.
- **Q134 — Raw chat:** Imported raw in-game messages exist only during an authorized analysis session, then are deleted once permitted interpreted information has been extracted. The local SavedVariables archive needs its **own** defined retention/deletion process before production integration. Do not build a permanent server-side raw transcript archive.
- **Q135 — Interpreted memories:** Keep relevant, supported memories while membership remains active; review and correct or discard stale/unsupported impressions. Delete or anonymize eligible personal memories **within 30 days of departure**, unless a specific legitimate retention obligation applies.
- **Q136 — Administrative audits:** Ordinary disciplinary and administrative audit records are retained **up to 180 days** and then deleted or anonymized. Longer retention for unresolved appeals, credible safety issues or legal obligations must document purpose and review date.
- **Q137 — Backups:** Restrict access, encrypt where appropriate, keep routine backups **no more than 30 days**, and reapply recorded deletions to any restored backup before resuming service. Never retain backups indefinitely to preserve deleted data.

## Confirmed rights and incident handling — questions 139–140

- **Q139 — Data requests:** Provide a private channel with an authorized human reviewer. Verify the requester proportionately, respond within applicable legal deadlines, and provide access, correction, export or deletion where required. Protect other members' data. Confidential internal scores and inferred profiles do not become a routine member-facing ranking feature (Q64); legal access rights remain intact.
- **Q140 — Incidents:** Contain unauthorized disclosure or access immediately; revoke compromised access, preserve necessary evidence, assess risks, notify affected people and authorities when required, document remediation, and suspend unsafe collection until safeguards are restored.

## Confirmed revised data-source and access boundary — question 138

**Source versus storage:** Eldgrim's character/community memories are derived from **guild-visible source material**: WoW Forever guild chat and explicitly designated shared guild Discord channels. No whispers, private member conversations or private-channel material are ingested as narrative memories. Mentions addressed to Eldgrim remain part of its temporary question collection (Q100). Broader shared-channel observation needs the disclosed scope, appropriate technical permissions and processing basis (Q124, Q131–133), and is not automatically implemented by the mention-only bot.

**Processing lifecycle:** The bot and addon may temporarily stage raw guild-visible messages; the local AI then reviews the authorized collection and saves only selected, reasonably supported **interpreted observations** in a **local database on the founder's PC**. After processing, discard raw messages and temporary copies, **including those staged on the server**. The addon's local SavedVariables archive requires a separate verified deletion procedure before production integration; it is specified in [agent/ROSTER.md](../agent/ROSTER.md) and not yet verified. Do not retain a server-side long-term transcript or combined narrative-memory database.

**Who can access it:** The founder is the **only human with direct access** to Eldgrim's persistent local memory database. The authorized local AI may read and write it on the founder's computer. No other guild officers or custodians have direct database access. The existing live bot necessarily keeps limited server-side registration, role and administrative state to operate the Character Forge and guild services; these operational records are **separate** from the local narrative-memory database and do not authorize a raw-message archive.

**Not public by default:** Although the underlying guild chat and designated Discord messages are shared with guild members, the local interpreted memories, internal standing and inferred profiles remain confidential (Q64). Publicly shared text may still be **personal data**. Privacy notices, opt-outs, retention, correction/deletion rights and legally required access still apply (Q131–137, Q139–140). Private onboarding, safety reports, appeals and data requests are handled only for their stated administrative purposes, not added to narrative memories.

**Superseded:** The initial Q138 proposal allowing designated human custodians to inspect Eldgrim's memory and the earlier server-hosted combined narrative-memory database proposal are **retired**. The secure transfer, purge and local access mechanisms are not yet implemented or tested.

**Implementation boundary:** These are approved working-governance decisions, not evidence that privacy notices, opt-outs, retention jobs, backup deletion, member request workflows or incident procedures are deployed or legally verified.

## Identity verification and memory correction — questions 158–159

Uncertain character/player name matches do **not** authorize combining records, transferring rank or standing, assigning misconduct or granting sensitive permissions (Q158). Confirm disputed links proportionately using registered information, an authorized witness or appropriate in-game verification; correct mistaken associations.

New reliable evidence overrides old interpreted impressions (Q159). Eldgrim must correct or retire unsupported **PC-local** narrative memories and preserve only necessary **non-content provenance**, not the original raw transcript. Disputed impressions cannot establish misconduct or justify consequential action. These are **confirmed design rules**, not an implemented identity-resolution or memory-correction system.

## Purpose-limited appeals and case evidence — questions 171–180

**Separate administrative purpose (Q171, Q175):** Confidential bot/human appeals and necessary case evidence are **not** narrative-memory inputs, even when they involve members or characters. Do not ingest private appeal messages into Eldgrim's founder-PC-local interpreted social memory. Review only authorized material needed to assess the incident; retain minimal findings, non-content references and justified audit metadata under Q136 (**ordinary maximum 180 days**, with documented exceptions for unresolved appeals, credible safety concerns or legal obligations). Do not build a permanent raw guild-chat transcript or preserve raw addon/server staging to support hypothetical future appeals.

**Evidence availability (Q172, Q174):** The right to submit a later appeal is not a right to indefinite evidence retention. Explain when evidence has been lawfully deleted or cannot be recovered. Rumors, uncertain identity links, internal standing and unverified AI summaries cannot substitute for reasonably reliable proof.

**Reviewer and correction (Q177–178):** An impartial founder-conflict reviewer receives only the case evidence necessary for fair review through a controlled procedure. The reviewer receives **no direct database access** to Eldgrim's local narrative memory (Q138). Correct administrative records after successful appeals; keep any necessary minimal outcome audit, not unnecessary conversations. Member data rights and applicable law still govern case material.

**Status:** Confirmed policy only. Confidential intake, case access control, evidence-minimizing audit, deadline management and deletion mechanisms are **not implemented or tested**.

## Confirmed confidentiality boundary — question 64

Eldgrim uses standing, interpreted member context and personal impressions **internally** to shape its creative interactions and administrative judgment. These are **not** a public or private leaderboard, visible high score, member dashboard or personal ranking. Eldgrim must not routinely disclose a member's numerical standing, comparative ranking, inferred profile or the internal signals behind personalized content, even to that member.

This internal confidentiality rule does **not** erase members' separately approved rights to explanations and appeals for consequential actions, nor any applicable legal rights to access, rectification or deletion of personal data. Those rights require an appropriate authorized privacy process rather than a public Discord command or disclosure of other members' information. Retention periods are set by Q135–137; exact privacy request procedures remain open.

## Confirmed onboarding and character-data boundaries — questions 82–87

Newcomers affirm adulthood, accept rules and acknowledge disclosed data practices. Mandatory Forge data is limited to a Discord account and at least one declared character's name, faction, race and class; real-world identity and optional roleplay/gameplay details are not required. Registration is a declaration rather than verified ownership. Disputed or permission-sensitive character claims may require reasonable in-game verification without credentials. Members may correct, add or retire characters; departed characters may be marked inactive. Historical data remains subject to privacy and retention rules still to be finalized. These decisions do not supersede applicable legal data-protection requirements.

## Refinement queue

- [x] Establish allowed Discord channel/DM scope and temporary mention collection (Q124–125, Q127).
- [x] Establish notice, optional profiling, in-game processing scope and baseline retention periods (Q131–137).
- [ ] Implement and verify actual notice, opt-out, consent/basis, per-source deletion and backup restoration safeguards.
- [x] Establish private correction and departure/deletion rights (Q129–130).
- [x] Establish private data request rights and incident response duties (Q139–140).
- [x] Resolve Q138: guild-visible narrative sources, temporary raw data, local interpreted memory and founder-only direct human database access.
- [ ] Specify and implement operational privacy request and confidential appeal channels, case reviewers and lawful exceptions without granting custodians direct local narrative-memory access.
- [x] Confirm appeals/evidence minimization and case-purpose separation (Q171–180).
- [x] Establish the founder's PC as authoritative for Eldgrim's persistent interpreted narrative memories (Q138).
- [ ] Define secure transfer and purge of shared Discord raw data, and separation from the live server bot's operational registration database. The addon archive's reading and cleanup are specified in agent/ROSTER.md and not built.

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)
