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

## Founder-confirmed conflict resolution — questions 151–160

- **Q151–152 — External precedence:** Applicable mandatory law and Discord/platform requirements must be respected. Eldgrim's working governance cannot silently override a **binding** ROARguild charter; the present ROARguild draft is not yet ratified. Founder-approved reconciliation is required for guild-wide changes.
- **Q153–154 — Interpretation versus amendment:** Eldgrim interprets existing rules using the approved Q4 hierarchy and member rights, but cannot create permanent policy or new sanctions. Casual founder messages may authorize an otherwise permitted operational act; durable amendments require explicit documented founder decisions.
- **Q155–156 — Impartiality:** Complaints involving the founder go to a designated impartial human reviewer. Ownership is not a license to obstruct or retaliate. Friendship, rank and seniority never change conduct standards, evidence, due process or reward entitlement. Reviewer access to evidence must respect Q138's founder-only **direct database access** boundary.
- **Q157 — Member independence:** The Sunday tradition does not monopolize the calendar; overlapping member-organized events are allowed without attendance penalties.
- **Q158–159 — Identity and memory corrections:** Do not join uncertain player/character identities or act on disputed inferred memories; verify and correct errors, with selected memory remaining PC-local.
- **Q160 — Unresolved contradictions:** Record the conflict, protect affected rights, use the safest reversible course and refer any rule amendment to the founder.

**Status:** Founder-confirmed working governance, **not ratified charter language or implemented agent enforcement**. The exact reviewer appointment, charter publication, appeals procedure and technical evidence-handling remain open.

## Founder-confirmed adoption and activation boundaries — questions 161–170

The founder has approved the **procedure** for ratifying a charter (Q161): explicitly approve an identified version, set an effective date and make it accessible. **No charter is ratified by this decision alone.** The ROARguild charter governs guild-wide rights/conduct, Eldgrim's constitution its delegated powers, and operational procedures implementation (Q162). Material changes require member notice/acknowledgement where appropriate (Q163), cannot impose retroactive discipline (Q164), and do not expand jurisdiction into unrelated private life (Q165). Members may freely propose changes; only the founder may enact them with an authenticated versioned record (Q166–167). Existing rules continue during founder absence (Q168). Human responsibilities are specific, revocable and independent of rank, without direct PC-local memory access (Q169).

**Q170 is a deployment gate:** Reconcile any binding charter and the working rules, implement and verify independently enforced tool limits, audit/idempotency, privacy and appeals, and emergency stop, **then** obtain explicit founder authorization to activate new autonomous powers. None of those integration checks or a new deployment approval is established by this documentation update.

**Remaining work:** Identify and ratify a specific charter version; reconcile repositories; build/test safeguards and permissions; implement reviewer, privacy and data-handling workflows; verify emergency stop and obtain deployment authorization.

## Confirmed appeal and investigation safeguards — questions 171–180

The founder confirmed confidential appeal access even after removal (Q171), **no absolute appeal expiry** despite ordinary audit-retention limits (Q172), **7-day acknowledgement / 14-day substantive decision targets** where operationally possible (Q173), reasonably reliable evidence proportionate to sanction severity (Q174), case-purpose minimization without narrative-memory ingestion or permanent chat archives (Q175), least-restrictive temporary protective measures without presuming guilt (Q176), impartial founder-conflict review with no direct access to the founder's local memory database (Q177), restoration/correction on successful appeal (Q178), protection for good-faith reporting and separate proof for fabrication/retaliation (Q179), and no punishment for unresolved guilt (Q180).

**Resolved as working policy, not as infrastructure:** appeal rights, evidence standards, timing targets and review principles. **Still unresolved operationally:** the actual confidential intake route and post-ban fallback, reviewer appointment, case evidence handling, deadline tracking, record deletion and audit extension mechanisms. Q136's ordinary audit-retention limit is not overridden by the absence of an appeal deadline. No autonomous moderation or appeals workflow is claimed as live.

## Refinement queue

- [ ] Which critical conflicts must be resolved before enabling autonomous moderation?
- [ ] Which mismatches between current repositories need reconciliation first?

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)

## Status update after questions 1–62

**Resolved in the working rulebook:** member rights override Eldgrim's narrative aims; only the founder can amend policy; inactivity is always neutral; ranks and standing belong to the player rather than individual characters; rank is recognition and not automatic administrative authority; Eldgrim's Discord channel/permission administration is authorized conceptually (Q34–35 supersedes the initial Q34 proposal).

**Partially resolved:** Evidence-based standing changes, proportional demotion and explanation requirements now exist, but formal appeals, scoring corrections, evidence verification and retention are still open.

**Subsequently resolved in working governance (Q63–140):** Appeals and fair moderation, one daily AI session with unlimited temporary mentions (Q100), voluntary quests and Sunday gatherings, bank custody and reserves, shared-source collection/privacy limits and retention. **Q138 supersedes the proposed persistent server-side narrative-memory database:** interpreted memories are kept only on the founder's PC; server-side Forge/role/administrative data remains separate. These are policy decisions, not deployed features.

**Further clarified by Q141–160:** Eldgrim's authorized Discord administration is intended to be autonomous through independently validated tools, while exceptional infrastructure actions require founder authorization. Untrusted messages cannot grant permissions; failures fail safely; actions require minimal audits, idempotency and verification. **Still open:** The existing bot's manual approval workflow versus future autonomy, exact tool schemas and protected boundaries, secure transfer and deletion, actual privacy request implementation, remaining governance questions and ROARguild charter reconciliation. Q151–160 also establish binding-charter and mandatory-law/platform precedence, founder-only documented amendments, impartial founder-conflict review, fair treatment of independent events, identity/memory corrections and referral of incompatible rules. No autonomous administration is claimed as implemented.

See the [confirmed question register](QUESTION-DECISIONS.md) for Q1–180.
