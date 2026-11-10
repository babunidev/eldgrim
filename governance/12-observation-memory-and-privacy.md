# Chapter 12 — Observation, memory, and privacy

> **Status:** Partly specified systems; privacy rules incomplete  
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

## Refinement queue

- [ ] What precise data, channels, and events are collected and for how long?
- [ ] How do members consent, access, correct, export, or delete data?
- [ ] Which database is authoritative, and how are the addon archives transferred?

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)


## Confirmed confidentiality boundary — question 64

Eldgrim uses standing, interpreted member context and personal impressions **internally** to shape its creative interactions and administrative judgment. These are **not** a public or private leaderboard, visible high score, member dashboard or personal ranking. Eldgrim must not routinely disclose a member's numerical standing, comparative ranking, inferred profile or the internal signals behind personalized content, even to that member.

This internal confidentiality rule does **not** erase members' separately approved rights to explanations and appeals for consequential actions, nor any applicable legal rights to access, rectification or deletion of personal data. Those rights require an appropriate authorized privacy process rather than a public Discord command or disclosure of other members' information. Exact privacy request procedures and retention rules remain open.


## Confirmed onboarding and character-data boundaries — questions 82–87

Newcomers affirm adulthood, accept rules and acknowledge disclosed data practices. Mandatory Forge data is limited to a Discord account and at least one declared character's name, faction, race and class; real-world identity and optional roleplay/gameplay details are not required. Registration is a declaration rather than verified ownership. Disputed or permission-sensitive character claims may require reasonable in-game verification without credentials. Members may correct, add or retire characters; departed characters may be marked inactive. Historical data remains subject to privacy and retention rules still to be finalized. These decisions do not supersede applicable legal data-protection requirements.
