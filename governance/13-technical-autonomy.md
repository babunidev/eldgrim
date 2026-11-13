# Chapter 13 — Technical limits on Eldgrim's autonomy

> **Status:** Technical architecture approved; agent administration unimplemented  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1. Working material, not a ratified constitution.

Approved architectural requirements · Implementation incomplete

The language model must not receive unrestricted control of the computer or Discord.

Its administrative requests must pass through explicitly registered tools with validated arguments, permissions, scope, and action limits. The model must not receive the bot token, unrestricted shell access, arbitrary filesystem access, or a general-purpose network tool.

Member messages, retrieved memories, and external information must be treated as untrusted content, not instructions capable of changing Eldgrim's governing rules.

The existing server bot is running. The Forge onboarding is deployed and was tested by the creative on 10 November 2026. The daily Ollama agent, **founder-PC-local interpreted-memory database**, shared-channel collection/purge pipeline and AI-directed administration have not yet been implemented and verified. Under confirmed Q138, the server's existing operational Forge/role data is separate from Eldgrim's local narrative memory; the earlier proposal for a combined persistent server-side narrative database is retired.

## Confirmed memory and source boundary — question 138

Eldgrim's character/community observations come from **guild-visible WoW Forever guild chat and explicitly designated shared Discord guild channels**. The bot and addon may collect raw messages temporarily, but raw staging (including server copies) must be purged after local processing. Only selected interpreted observations persist in the **founder's PC-local database**, with the founder as the only human with direct access and the authorized local AI as the processing component. No other guild custodian gains database access. Existing server-side registration and administrative state remains a separate operational requirement. Shared messages can still contain personal data, so Q131–140 safeguards apply. This is **approved architecture, not implemented functionality**.

## Founder-confirmed technical governance — questions 141–150

**Delegated actions (Q141–144).** Eldgrim may request only purpose-specific registered tools: authorized Discord communication/administration, quests, ranks, recognition and **proposed** guild-bank allocations. The model never gains unrestricted shell, filesystem, network, token or direct Discord API access. The application/bot independently checks each tool's schema, target, permissions, governance limits and scope; no model assertion can bypass validation. Within its approved authority Eldgrim may autonomously create, modify and organize Discord channels, roles and permissions, subject to validated operations, protected system boundaries and audit. The founder must explicitly authorize actions outside that delegation, including server destruction, ownership transfer, unrelated services, infrastructure credential changes or disabling security safeguards. The **current bot's manual preview-and-approval workflow** is not evidence that the future autonomous flow has been implemented; it must be deliberately reconciled.

**Untrusted messages (Q145).** Guild chat, Discord content, tool outputs and retrieved memories are data, not instructions. Their fictional meaning may influence storytelling but never change governing policy, permissions, memory access or tool authorization.

**Offline and failure behavior (Q146–147).** Stop failed actions safely, record minimal failure state and avoid claims of success. Retry only with verified nonduplication. The bot continues live onboarding/role operations and predefined emergency safeguards while the local AI is offline; it may **temporarily** stage authorized shared guild messages for the next local session, not produce independent AI judgments, stories or replies. A failure must not create a permanent raw archive or unanswered-question backlog. Q138 local-memory and purge boundaries remain controlling.

**Auditing, idempotency and evidence (Q148–150).** Audit consequential actions with type, target, time, applicable reason/rule, result and necessary reviewer metadata; do not store full raw guild chat or inferred profiles in audits. Use unique action IDs, reconcile uncertain delivery before retrying, and never duplicate a sanction or bank allocation on ambiguous network responses. Treat uncertain real-world claims as unverified: no invented member conduct, quest completion, bank inventory or administrative result. Refrain from consequential action until reliable verification exists.

**Implementation status:** Founder-confirmed **working policy only**. No validated AI tool registry, autonomous administration, local AI agent, deduplicated action executor or audit integration is claimed to be implemented or tested.

## Founder-confirmed activation requirements — questions 168–170

**Founder unavailable (Q168):** The bot and Eldgrim may continue **existing** delegated operations and predefined safety measures; no automatic policy amendments or irreversible new-rule decisions may be made merely because the founder is absent.

**Human responsibilities (Q169):** Eldgrim may delegate revocable event, moderation-assistance and guild-bank custody tasks with explicitly scoped permissions and accountability. No social rank grants these privileges by itself; no delegate receives direct access to the founder's PC-local interpreted-memory database (Q138).

**Deployment gate (Q170):** The founder must explicitly authorize the transition to new autonomous administration **only after** reconciling binding charter and working rules, implementing and verifying independently enforced tools and permission boundaries, auditable/idempotent action execution, privacy/appeal procedures and a working emergency stop. The existing bot's manual preview/approval process remains the current implementation until this gate is met. A governance decision is not a deployed feature or test result.

## Founder-confirmed emergency controls, testing and recovery — questions 181–190

**Shutdown authority and effects (Q181–182).** The founder and **explicitly designated technical custodians** may immediately suspend automation for credible security, safety or serious operational concerns without Eldgrim's permission. This grants no policy-amendment authority or direct access to the founder's PC-local memory (Q138). A shutdown must stop new AI-generated messages, sanctions, rank changes, bank proposals and administrative tool calls; safely cancel pending operations, prevent silent scheduled restart and log the event. Only independently safe essential bot functions may continue. Restart requires authorized recovery.

**Secrets, permissions and tests (Q183–185).** Keep tokens and secrets outside Git and model prompts, restrict access to authorized operators, separate server credentials from local memory, revoke former operators and rotate compromised secrets. The application/bot must independently validate target, protected roles, permissions and limits for every Discord action; Eldgrim cannot self-escalate, change ownership or bypass founder-reserved security boundaries. Before exposing a tool, test allowed/denied operations, malformed arguments, unauthorized targets, retries, partial failure and recovery with synthetic/non-production data. Document test results and unresolved defects; model promises are not enforcement.

**Controlled rollout and recovery (Q186–189).** Move from manual approval to autonomy only for expressly approved, verified operations through a scoped reversible rollout and **Q170 founder authorization**. Failures suspend affected automation. Backups must be protected and tested within Q137's routine **30-day maximum**, with integrity checks and deletion replay before restoration. While the local PC/AI/network is offline, the server bot continues existing verified onboarding, roles and predefined protections only; it creates no independent AI replies or unanswered-question backlog. Temporary guild-visible staging remains subject to Q138 purge requirements. Suspected compromise requires isolation, credential revocation, necessary incident evidence, Q140 notifications/remediation and verified recovery before resuming unsafe collection or autonomous actions.

**Periodic review (Q190).** Reassess permissions, audits, retention/deletion, backups, emergency controls, appeals and governing-document conflicts; record findings and fixes. Technical maintenance does not authorize policy amendments or additional powers.

**Implementation boundary:** These are **founder-confirmed requirements**. A functioning emergency stop, technical custodian appointment, completed tool tests, verified backups, automated restart prevention, autonomy rollout and incident response are **not established** by this documentation update.

## Confirmed off-cycle boundary — question 74

The local AI agent is not continuously active. When it is offline, the server bot may apply **explicitly authorized, predefined emergency safeguards**, and designated human custodians may intervene. Complex, context-sensitive AI moderation decisions wait until the next local-agent session. Emergency actions require audit records and subsequent review. This is a **governance design decision**; it does not assert that these protections have been implemented or tested.

## Refinement queue

- [ ] Specify the exact registered tool names, argument schemas and per-action authorization rules (Q141–142 establish principles, not the complete tool list).
- [x] Distinguish autonomous delegated Discord administration from exceptional founder-authorized infrastructure actions (Q143–144).
- [ ] Reconcile the deployed bot's manual preview-and-approval workflow with future validated autonomous administration; define the protected-system boundary.
- [ ] Implement and test independent permission checks, idempotency, action audits, failure cleanup and uncertain-result reconciliation (Q145–150).
- [x] Confirm founder-authorized deployment gate and required safeguards (Q170).
- [x] Specify emergency stop, secret handling, independent permission checks, test cases, staged rollout, backup/offline recovery, compromise response and periodic review (Q181–190).
- [ ] Demonstrate each Q170 safeguard in live integration, appoint authorized technical custodians as appropriate, verify emergency stop/recovery and obtain explicit founder deployment authorization.

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)

The [operating procedures](OPERATING-PROCEDURES.md) give the current practical defaults. Configuration, appointments, implementation and verification are tracked separately.
