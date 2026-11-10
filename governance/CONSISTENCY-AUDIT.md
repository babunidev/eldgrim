# Governance consistency audit — interview baseline

**Date:** 10 November 2026  
**Status:** Initial documentation audit after founder confirmation of Q1–193; **not** formal charter adoption or live-system certification.

## Scope and method

The founder confirmed all 193 numbered answers in [QUESTION-DECISIONS.md](QUESTION-DECISIONS.md), including revisions to Q100 and Q138 and supersession notes. This audit compares the confirmed decision groups with the sixteen governance chapters and the documented agent, bot and addon boundaries. It records visible contradictions, stale proposals, overlaps and missing operational procedures. It does **not** claim a complete source-code/security audit, a full review of the separate ROARguild repository, or successful runtime verification.

The **latest explicit founder decision controls** when earlier drafts differ. Mandatory law/platform obligations and a **binding** charter take precedence as described by Q151–152; the ROARguild charter is currently documented as a **developing draft**, not a ratified charter.

## Decisions and supersessions to preserve

| Questions | Current confirmed interpretation | Superseded or conflicting older wording |
| --- | --- | --- |
| Q34–35, Q141–144, Q170 | Eldgrim may eventually administer delegated Discord channels, roles and permissions autonomously **through independently validated tools after founder-authorized deployment** | Early blanket founder approval for each Discord change; conversely, any suggestion that current manual approval is already removed |
| Q54–62 | New standing baseline 50; inactivity and nonparticipation are neutral | Any suggestion that inactivity lowers standing or that zero means disengagement |
| Q64, Q138–140 | Internal standing and inferred profiles are not ordinarily disclosed; personal-data rights and lawful access requests still apply; founder alone has **direct human access** to PC-local narrative memory | Human custodian direct memory access or server-hosted permanent narrative profiles |
| Q92–100 | Unlimited mentions may be temporarily collected; at most one question per member is selected per daily run; purge collection after processing; no durable unanswered-question queue | One mention per UTC day, UTC-reset quota or a queued backlog |
| Q124–140, Q175 | Shared guild-visible WoW chat/designated Discord channels may supply temporary narrative observations; **private** appeals/onboarding/safety/data requests are separate administrative workflows | Collection of member-to-member private messages into narrative memory or permanent raw transcripts |
| Q151–170, Q191–193 | Written interview answers form a **working baseline**. Binding charter adoption requires identified founder-approved version, effective date and member access; new autonomous administration requires separate verified safeguards and founder go-live authorization | Any statement that completing the interview ratifies a charter or deploys Eldgrim |

## Findings requiring documentation or implementation reconciliation

1. **Outdated chapter status summaries.** Some chapter introductions and refinement queues still use older words such as “open” for topics whose *policy* was subsequently decided. Preserve the historical baseline where useful, but label confirmed policy separately from **unimplemented procedure**. Do not rewrite original source material as though it was always approved.
2. **Proposed hierarchy versus confirmed hierarchy.** Chapter 15 contains an older proposed hierarchy; Q4 and Q151–152 govern the confirmed internal priority and external compliance boundaries. Do not ratify the older proposal by inference.
3. **Separate guild charter.** The ROARguild charter is described as a developing draft and may contain older terminology or guild-status statements. A full cross-repository text comparison, founder-approved reconciliation and actual charter ratification have **not** occurred here.
4. **Autonomous Discord administration versus live approval.** Q143 and Q170 approve a future independently validated autonomous path, but the current bot retains manual preview/approval. Tool-level boundaries, tests, kill switch and founder deployment authorization remain outstanding.
5. **Narrative memory versus operational bot records.** Q138 supersedes earlier persistent server-side narrative-memory plans. Keep existing minimal server Forge/role records separate; implement temporary source transfer and purge and PC-local interpreted memory without creating a second permanent narrative archive.
6. **Appeals without permanent archives.** Q172 imposes no absolute appeal submission deadline, while Q136 limits ordinary audit retention and Q175 minimizes evidence. This is **not a contradiction**: accept later appeals while acknowledging lawfully unavailable evidence. Define the secure case process and documented exceptions without retaining raw chat indefinitely.
7. **Emergency stop and technical custodians.** Q181–182 allow appointed technical custodians to stop unsafe automation but **not** to amend policy or access the PC-local memory database. Appointment, technical scope, restart authorization and verification remain undefined in running software.
8. **Private data and public-facing records.** Q64 confidentiality, Q139 lawful personal-data requests and Q177 impartial review require purpose-limited, controlled disclosures without direct database access for other humans. The actual request and reviewer workflow is not implemented.
9. **Offline bot behavior.** Q147, Q188 and Q100 allow only existing verified bot functions, predefined protections and authorized temporary shared-source staging; no invented local-AI decisions and no permanent question queue. Offline staging needs bounded retention and failure cleanup.
10. **Tests versus approval.** Q170 and Q185–190 require real independent permission enforcement, synthetic negative testing, tested backups/deletion replay, incident response and reversible rollout. None is established by an accepted interview answer.

## Decision status

- **Confirmed:** All 193 founder answers; the above precedence, supersessions and boundaries.
- **Developing / unimplemented:** Practical charter adoption, review procedures, privacy pipelines, bot-to-PC transfer, local memory, action tools, emergency stop, testing, recovery and deployment.
- **Proposed, not adopted:** Older chapter proposals that differ from the latest confirmed answers.
- **Unresolved:** Exact wording or procedures requiring founder decisions or verified integration. No conflict is silently resolved in this audit.

The [implementation matrix](IMPLEMENTATION-MATRIX.md) is the actionable outstanding-work register. The public rulebook deliberately excludes concealed character identity, motives and private magical mechanics.
