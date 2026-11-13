# Eldgrim governance implementation and verification matrix

**Baseline:** All 193 founder-confirmed questions, 10 November 2026.  
**Status:** Requirements mapped; this file is **not** a test report, production sign-off, charter ratification or autonomous deployment authorization.

See the [operating procedures](OPERATING-PROCEDURES.md) for design defaults. This matrix tracks implementation and evidence.

## Status legend

- **Documented:** Confirmed requirement recorded in the numbered register and relevant chapter.
- **Implemented:** Actual code/procedure exists; evidence and commit/reference must be supplied.
- **Tested:** Relevant negative, failure and integration tests passed with reproducible evidence.
- **Deployed:** Verified on the intended live environment with explicit authorization.
- **Not verified:** No adequate implementation/test/deployment evidence established.

All rows below are **documented**. The existing server bot and Character Forge have separately documented live functions, but this does **not** establish that the *new governance behavior* in these rows is implemented, tested or deployed.

## Traceability by decision group

| Questions | Components and required behavior | Dependencies and verification evidence | Status |
| --- | --- | --- | --- |
| Q1–20 | ROARguild charter; member rights, conduct, voluntariness, fair participation | Identify charter version, founder ratification, effective date, accessible notice, acknowledgement where necessary | Documented; charter adoption not verified |
| Q21–30 | Eldgrim public persona and narrative rules; distinguish fiction from real administration | Public-safe prompt/content review; no concealed canon in public repo; administrative truthfulness checks | Documented; agent behavior unverified |
| Q31–42 | Bot and agent; delegated authority, founder-reserved changes, auditable consequential decisions | Tool permission matrix, protected targets, negative authorization tests and decision audits | Documented; new autonomy unverified |
| Q43–52 | Forge, role sync, WoW rank administration; five social ranks and person-level attribution | Test rank mapping across alts, authorized sync, refusals, demotions and permission separation | Documented; live Forge/rank baseline separate from unverified AI rank control |
| Q53–64 | PC-local interpreted memory; internal standing 0–100, neutral inactivity, confidentiality | Scoring and correction tests, private-data access restrictions, no member-facing inferred profile disclosure except lawful rights | Documented; local standing system unverified |
| Q65–80 | Bot moderation and human appeals; proportional sanctions, evidence, emergency protection, review | Simulated misconduct/appeals, hearing, impartiality, sanctions/undo and audit retention | Documented; autonomous enforcement unverified |
| Q81–90 | Existing Forge onboarding, multiple characters, bot/offline separation, daily agent | Verify registration state and per-person identity; local scheduling and safe bot-only operation | Documented; Forge live baseline, daily agent unverified |
| Q91–100 | Bot mention collection and local daily selection; one per member per run, no backlog | Temporary staging, deduplication, purge on success/failure, offline and restart tests | Documented; pipeline unverified |
| Q101–110 | Quest engine and witness verification; voluntary quests, screenshots and rewards | Evidence submission/witness/appeal tests, optional participation and safe reward constraints | Documented; automated quest engine unverified |
| Q111–120 | Sunday event coordination and bank custody; voluntary attendance, verified inventory and human handoff | Test event notice/time zone, simultaneous fires, bank snapshots, custodian handoff and item reconciliation | Documented; integrated automation unverified |
| Q121–130 | Bank reserves and shared-source observation; limited guild-visible inputs only | Test roleplay-led allocation regardless of item price or rarity, transfer availability, privacy scopes, no whispers/DM narrative intake and no permanent raw transcripts | Documented; integrated controls unverified |
| Q131–140 | Privacy notice, opt-out, local interpreted-memory storage, purge, data requests and breach response | Verify lawful basis/notice, secure transfer, founder-only direct memory access, 30-day personal-memory deletion and backup limit, 180-day ordinary audits, rights and breach drills | Documented; end-to-end pipeline unverified |
| Q141–150 | Agent/bot tool registry; independent permissions, untrusted-input isolation, audit, idempotency and uncertain evidence | Schema and negative permission tests, prompt-injection tests, lost-response reconciliation, failure cleanup | Documented; action executor unverified |
| Q151–160 | Rule precedence, impartial founder-conflict review, event freedom, identity/memory correction | Compare charter and working rules, reviewer conflict checks, identity mismatch tests and correction audits | Documented; procedures unverified |
| Q161–170 | Ratification/versioned amendments, limited jurisdiction, delegation and founder-authorized autonomy gate | Founder-approved version/effective date; notice and history; delegation scopes; complete go-live checklist and explicit sign-off | Documented; charter/deployment not authorized |
| Q171–180 | Confidential and post-ban appeals, 7/14-day targets, evidence minimization and remedies | Test post-ban intake, deadlines, reviewer assignment, controlled evidence, restoration and case deletion | Documented; appeal workflow unverified |
| Q181–190 | Emergency stop, credential boundaries, tool testing, reversible rollout, backup recovery, offline/incident response and periodic reviews | Kill-switch and no-auto-restart drills, credential access review, negative tests, 30-day backup/deletion replay, compromise simulation and review log | Documented; new controls unverified |
| Q191 | Governance docs; final consistency audit | Review [CONSISTENCY-AUDIT.md](CONSISTENCY-AUDIT.md), reconcile stale proposals and separately compare ROARguild charter | Documented; initial documentation audit recorded, full cross-repo audit open |
| Q192 | Governance and engineering docs; traceable verification matrix | Attach actual component changes, test runs, versions, owners and deployed evidence to each row | Documented; evidence collection open |
| Q193 | Governance register; complete interview without automatic ratification/deployment | Confirm 193/193 decisions, publish working baseline, keep charter/deployment gates separate | Documented; interview complete |

## Outstanding work — ordered by dependency

1. **Document reconciliation:** Review all sixteen chapters against the final decision register, retire stale conflicting proposals and compare the separate ROARguild charter. Do not treat its draft as ratified.
2. **Governance adoption:** Identify the intended binding charter version, record explicit founder approval and effective date, publish accessible rules and necessary member notice/acknowledgement.
3. **Privacy foundation:** Define purpose-specific notice, lawful basis, member opt-out and rights workflow; implement guild-visible-only intake, bounded temporary server/addon staging, secure transfer and purge; implement founder-PC-local interpreted memory with no other direct human database access.
4. **Retention and recovery:** Implement member departure/deletion, administrative audit limits and exceptions, backups (routine maximum 30 days), restore integrity and deletion replay. Verify no permanent raw transcripts or question backlog.
5. **Appeals and safety:** Implement confidential and post-ban appeal intake, impartial reviewer workflow, 7/14-day response targets, evidence handling, corrections and predefined protective bot operations.
6. **Delegated action boundaries:** Define exact tool schemas, target and protected-role rules, operator access, bank human handoff, action IDs, audit records, prompt-injection separation and fail-safe retry/reconciliation.
7. **Emergency stop and tests:** Appoint any technical custodians explicitly; implement stop/cancel/no-silent-restart, credential isolation, non-production negative tests, failure/recovery drills and compromise response.
8. **Autonomous deployment:** Reconcile existing manual approval with validated reversible tool rollout, verify every Q170 prerequisite and obtain **separate explicit founder deployment authorization**. Do not infer authorization from this document.
9. **Ongoing review:** Maintain test evidence, operational audits, permission reviews, privacy/deletion verification, appeal quality and charter/document consistency.

## Verification record template

For each component or row, record **owner, requirement/Q numbers, code or procedure reference, environment/version, test command or steps, expected and actual result, date, defects, independent reviewer if needed, deployment approval and rollback plan**. Do not mark “tested” or “deployed” without corresponding evidence.

The repository's existing bot/Forge implementation claims remain separate from the unimplemented local AI and autonomous governance. No new code, credentials, live configuration, release tag or deployment is created by this matrix.
