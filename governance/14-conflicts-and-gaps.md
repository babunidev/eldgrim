# Chapter 14 — Conflicts and gaps that must be resolved

> **Status:** Inventory of open and conflicting decisions  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1. Working material, not a ratified constitution.

These were the most important weaknesses in the baseline rule set. The last column shows where the interview answered each one as policy; implementation is tracked in the [implementation matrix](IMPLEMENTATION-MATRIX.md).

| Priority | Conflict | Required clarification | Current position |
| --- | --- | --- | --- |
| Critical | Fictional objectives versus members' welfare | Which interests take precedence when they conflict? | Resolved: Q3–5, Q30 |
| Critical | Autonomous moderation versus fairness | What evidence, review, and appeal protections apply? | Resolved: Q65–81, Q171–180 |
| Critical | Voluntary participation versus standing scores | Can inactivity ever lower standing or cause demotion? | Resolved: no (Q49, Q60–62) |
| Critical | Extensive observation versus member privacy | Exactly what is collected, retained, disclosed, and removable? | Resolved: Q124–140 |
| High | Eldgrim's full authority versus the bot's approval workflow | Which actions are autonomous, supervised, or forbidden? | Policy resolved (Q141–144, Q170); tool list and activation open |
| High | No human hierarchy versus privileged guild roles | Which permissions are practical responsibilities rather than social authority? | Resolved: Q43, Q50, Q169 |
| High | One daily appearance versus individual questions and proclamations | What exactly counts toward each communication limit? | Resolved: Q91–100 |
| High | Creative reward freedom versus valuable bank assets | What restrictions apply to scarce resources? | Resolved in principle (Q110, Q121–123); value thresholds open |
| High | Private scores versus accountable decisions | How can a member challenge an error without exposing others' private information? | Resolved: Q64, Q78–80, Q139 |
| High | Several characters per player | Is standing calculated per player, per character, or both? | Resolved: per player (Q51) |
| High | Local interpreted memory versus live bot operational records | Where does each kind of record live? | Resolved by Q138; transfer, deletion and consistency need implementation |
| Medium | Sunday attendance and addon observations | How is voluntary attendance distinguished from measurable participation? | Resolved: Q18, Q114–115 |
| Medium | One decision per category per day | What constitutes a category, and which exceptions are permitted? | Resolved: Q99 |
| Medium | Older ROARguild documentation | Replace retired Oracle terminology and outdated guild-status statements. | Open |

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

## Confirmed operational safeguards and remaining implementation gaps — questions 181–190

The founder confirmed technical-custodian emergency stop authority **without memory-database access** (Q181), a stop that halts new AI/admin actions and prevents silent restart (Q182), separate protected credentials (Q183), independent Discord permission enforcement and protected infrastructure boundaries (Q184), synthetic/non-production testing of tool authorization and failures (Q185), a verified, reversible founder-authorized rollout (Q186), tested backups and deletion replay under Q137 (Q187), bounded offline operation without fabricated replies or durable unanswered-question queues (Q188), containment and verified recovery after compromise under Q140 (Q189), and periodic governance/security review without silent policy changes (Q190).

**Still unresolved operationally:** appointing technical custodians; implementing and testing shutdown/restart prevention, tool allowlists, backup/restore, credential separation and compromise response; reconciling the existing manual-approval bot with future autonomy; and obtaining explicit founder go-live authorization. These are approved requirements, not completed safeguards.

## Final consistency and implementation review — questions 191–193

The interview is complete: **193/193 founder-confirmed answers**. Q191 requires a full consistency audit across the register, chapters and separate ROARguild charter, with explicit supersessions and unresolved conflicts rather than inferred resolutions. The initial [consistency audit](CONSISTENCY-AUDIT.md) lists concrete documentation and operational gaps. Q192 maps all decision groups to components, dependencies, tests and evidence in the [implementation matrix](IMPLEMENTATION-MATRIX.md). Q193 distinguishes **interview completion** from charter ratification, new membership obligations and live autonomy.

**Open:** Full cross-repository charter comparison, chapter-level cleanup, actual technical implementation, verification evidence, charter adoption and Q170 founder go-live authorization. The initial documentation audit is not a runtime audit or a claim that every conflict is resolved.

## Status update after questions 1–62

**Resolved in the working rulebook:** member rights override Eldgrim's narrative aims; only the founder can amend policy; inactivity is always neutral; ranks and standing belong to the player rather than individual characters; rank is recognition and not automatic administrative authority; Eldgrim's Discord channel/permission administration is authorized conceptually (Q34–35 supersedes the initial Q34 proposal).

**Partially resolved:** Evidence-based standing changes, proportional demotion and explanation requirements now exist, but formal appeals, scoring corrections, evidence verification and retention are still open.

**Subsequently resolved in working governance (Q63–140):** Appeals and fair moderation, one daily AI session with unlimited temporary mentions (Q100), voluntary quests and Sunday gatherings, bank custody and reserves, shared-source collection/privacy limits and retention. **Q138 supersedes the proposed persistent server-side narrative-memory database:** interpreted memories are kept only on the founder's PC; server-side Forge/role/administrative data remains separate. These are policy decisions, not deployed features.

**Further clarified by Q141–160:** Eldgrim's authorized Discord administration is intended to be autonomous through independently validated tools, while exceptional infrastructure actions require founder authorization. Untrusted messages cannot grant permissions; failures fail safely; actions require minimal audits, idempotency and verification. **Still open:** The existing bot's manual approval workflow versus future autonomy, exact tool schemas and protected boundaries, secure transfer and deletion, actual privacy request implementation, remaining governance questions and ROARguild charter reconciliation. Q151–160 also establish binding-charter and mandatory-law/platform precedence, founder-only documented amendments, impartial founder-conflict review, fair treatment of independent events, identity/memory corrections and referral of incompatible rules. No autonomous administration is claimed as implemented.

See the [confirmed question register](QUESTION-DECISIONS.md) for all Q1–193.

## Refinement queue

- [x] Which critical conflicts must be resolved before enabling autonomous moderation? The Q170 gate lists them.
- [ ] Which mismatches between current repositories need reconciliation first?

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)
