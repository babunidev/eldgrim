# Chapter 12 — Observation, memory, and privacy

> **Status:** Founder-confirmed collection and confidentiality boundaries (Q64, Q82–87, Q124–130); exact retention and technical controls open  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1. Working material, not a ratified constitution.

Technical boundaries partly specified · Member policy incomplete

Three different information sources are being developed.

| Source         | Intended information                                                            |
| -------------- | ------------------------------------------------------------------------------- |
| Discord bot    | Member registrations, characters, roles, onboarding, and administrative records |
| Local AI agent | Eligible @Eldgrim interactions, memories, intentions, and decision history      |
| WoW addon      | Guild chat messages, timestamps, and available character information            |

The existing addon code is a passive guild-chat recorder. It stores verbatim guild messages locally in SavedVariables. Its mock tests passed, but in-game behavior is not yet verified.

The agent's initial design only processes eligible @Eldgrim mentions and keeps its private SQLite memory locally. The broader original vision also calls for a server-hosted database combining Discord and in-game observations.

Those systems are intended to be connected later, but the full integration does not yet exist. The member notice covers possible in-game chat, emotes, and event presence; that notice does not prove these observations are implemented by the current addon.

The original privacy principles require that Eldgrim's long-term member profiles contain interpreted information rather than conversation quotations, that internal scores and observations remain private, and that decisions not publicly expose the conversations behind them.

Before broader collection or autonomous governance, the rules still need to define member notice, consent, channel scope, private-message exclusions, raw-log retention, access, deletion, correction, and handling of inaccurate AI inferences.

See [agent security](https://github.com/babunidev/eldgrim/blob/main/agent/SECURITY.md) and [memory design](https://github.com/babunidev/eldgrim/blob/main/agent/MEMORY.md).

## Confirmed observation and privacy boundaries — questions 124–130

- **Q124 — Discord channels:** Eldgrim may observe only **explicitly designated guild channels**, messages intentionally addressed to it, and necessary onboarding/administrative interactions. The server bot may process other content only for predefined moderation; this does not authorize automatic inclusion in Eldgrim's personal memory.
- **Q125 — Private conversations:** Eldgrim has no right to inspect private exchanges where its application is not a legitimate participant. Messages sent **to the bot** may be processed for the stated purpose; they are not automatically public guild activity or storytelling material.
- **Q126 — In-game guild chat:** The existing Forever addon stores raw guild-chat messages in local SavedVariables. For **future authorized integration**, raw records are temporary analysis inputs, not indefinite personal memories. Long-term profiles favor relevant interpreted facts, topics and observations over verbatim quotations. Define and implement deletion of raw archives **before** production integration; this does not assert that the current addon already deletes them.
- **Q127 — @Eldgrim mention collection:** As required by Q100, eligible mentions collected by the bot or agent are temporary and their message content is **purged after the daily processing run**, including unselected questions. Non-content operational audit metadata may remain only where necessary and must not reconstruct a hidden archive. Failure/partial-run handling is still open.
- **Q128 — Internal impressions:** Retain only relevant, reasonably supported interpretations of participation, character interests, helpfulness, conduct and shared experiences. Exclude sensitive real-world characteristics, unsupported psychological conclusions and verbatim private conversations. Standing and inferred profiles remain confidential under Q64, without overriding applicable legal rights.
- **Q129 — Correction:** Members can privately request corrections of registration facts and consequential administrative records. An authorized human reviews unresolved disputes. Eldgrim may correct its own internal impressions without exposing private profiles; legal data access and rectification rights are preserved.
- **Q130 — Leaving:** Deactivate membership and character records, cease routine collection, and offer a private deletion request process. Retain only information justified by safety, legal or administrative obligations under a **retention policy yet to be defined**. Do not profile former members in retaliation.

**Implementation boundary:** These are confirmed governance decisions, not proof of an implemented purge, consent, deletion, or integrated data system. No new access to unrelated Discord channels or private conversations is authorized.

## Refinement queue

- [x] Establish allowed Discord channel/DM scope and temporary mention collection (Q124–125, Q127).
- [ ] Set exact retention periods, consent notice and processing scope for each data source.
- [x] Establish private correction and departure/deletion rights (Q129–130).
- [ ] Specify consent, data access/export, request workflow, reviewer roles and legal retention exceptions.
- [ ] Which database is authoritative, and how are the addon archives transferred?

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)


## Confirmed confidentiality boundary — question 64

Eldgrim uses standing, interpreted member context and personal impressions **internally** to shape its creative interactions and administrative judgment. These are **not** a public or private leaderboard, visible high score, member dashboard or personal ranking. Eldgrim must not routinely disclose a member's numerical standing, comparative ranking, inferred profile or the internal signals behind personalized content, even to that member.

This internal confidentiality rule does **not** erase members' separately approved rights to explanations and appeals for consequential actions, nor any applicable legal rights to access, rectification or deletion of personal data. Those rights require an appropriate authorized privacy process rather than a public Discord command or disclosure of other members' information. Exact privacy request procedures and retention rules remain open.


## Confirmed onboarding and character-data boundaries — questions 82–87

Newcomers affirm adulthood, accept rules and acknowledge disclosed data practices. Mandatory Forge data is limited to a Discord account and at least one declared character's name, faction, race and class; real-world identity and optional roleplay/gameplay details are not required. Registration is a declaration rather than verified ownership. Disputed or permission-sensitive character claims may require reasonable in-game verification without credentials. Members may correct, add or retire characters; departed characters may be marked inactive. Historical data remains subject to privacy and retention rules still to be finalized. These decisions do not supersede applicable legal data-protection requirements.
