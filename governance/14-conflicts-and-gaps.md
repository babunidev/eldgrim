# Chapter 14 — Conflicts and gaps that must be resolved

> **Status:** Inventory of open and conflicting decisions  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1. Working material, not a ratified constitution.

These are the most important weaknesses in the current rule set.

| Priority | Conflict                                                           | Required clarification                                                            |
| -------- | ------------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| Critical | Fictional objectives versus members' welfare                   | Which interests take precedence when they conflict?                               |
| Critical | Autonomous moderation versus fairness                              | What evidence, review, and appeal protections apply?                              |
| Critical | Voluntary participation versus standing scores                     | Can inactivity ever lower standing or cause demotion?                             |
| Critical | Extensive observation versus member privacy                        | Exactly what is collected, retained, disclosed, and removable?                    |
| High     | Eldgrim's full authority versus the bot's approval workflow        | Which actions are autonomous, supervised, or forbidden?                           |
| High     | No human hierarchy versus privileged guild roles                   | Which permissions are practical responsibilities rather than social authority?    |
| High     | One daily appearance versus individual questions and proclamations | What exactly counts toward each communication limit?                              |
| High     | Creative reward freedom versus valuable bank assets                | What restrictions apply to scarce resources?                                      |
| High     | Private scores versus accountable decisions                        | How can a member challenge an error without exposing others' private information? |
| High     | Several characters per player                                      | Is standing calculated per player, per character, or both?                        |
| High     | Local interpreted memory versus live bot operational records       | **Partly resolved by Q138:** Eldgrim's narrative memory stays on the founder's PC; live Forge/role state remains on the server. Secure temporary transfer, deletion and consistency still require implementation. |
| Medium   | Sunday attendance and addon observations                           | How is voluntary attendance distinguished from measurable participation?          |
| Medium   | One decision per category per day                                  | What constitutes a category, and which exceptions are permitted?                  |
| Medium   | Older ROARguild documentation                                      | Replace retired Oracle terminology and outdated guild-status statements.          |

The older [ROARguild charter](https://github.com/babunidev/ROARguild/blob/main/guild/CHARTER.md) is explicitly a developing draft. It still contains outdated statements about Amberhearth's name and the earlier Oracle concept. It should not be treated as a binding rulebook.

## Refinement queue

- [ ] Which critical conflicts must be resolved before enabling autonomous moderation?
- [ ] Which mismatches between current repositories need reconciliation first?

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)

## Status update after questions 1–62

**Resolved in the working rulebook:** member rights override Eldgrim's narrative aims; only the founder can amend policy; inactivity is always neutral; ranks and standing belong to the player rather than individual characters; rank is recognition and not automatic administrative authority; Eldgrim's Discord channel/permission administration is authorized conceptually (Q34–35 supersedes the initial Q34 proposal).

**Partially resolved:** Evidence-based standing changes, proportional demotion and explanation requirements now exist, but formal appeals, scoring corrections, evidence verification and retention are still open.

**Subsequently resolved in working governance (Q63–140):** Appeals and fair moderation, one daily AI session with unlimited temporary mentions (Q100), voluntary quests and Sunday gatherings, bank custody and reserves, shared-source collection/privacy limits and retention. **Q138 supersedes the proposed persistent server-side narrative-memory database:** interpreted memories are kept only on the founder's PC; server-side Forge/role/administrative data remains separate. These are policy decisions, not deployed features.

**Further clarified by Q141–150:** Eldgrim's authorized Discord administration is intended to be autonomous through independently validated tools, while exceptional infrastructure actions require founder authorization. Untrusted messages cannot grant permissions; failures fail safely; actions require minimal audits, idempotency and verification. **Still open:** The existing bot's manual approval workflow versus future autonomy, exact tool schemas and protected boundaries, secure transfer and deletion, actual privacy request implementation, remaining governance questions and ROARguild charter reconciliation. No autonomous administration is claimed as implemented.

See [confirmed questions 1–62](QUESTION-DECISIONS.md).
