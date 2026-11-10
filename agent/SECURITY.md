# Eldgrim Agent — Security and Privacy

**Status:** Developing security requirements; no implementation exists.

## 1. Security model

The language model is not a trusted authority. It can propose actions, but the Python application must independently decide whether those actions are permitted.

Security must be enforced in code and configuration, not only through a character prompt or system instruction.

## 2. Discord permissions

The initial bot should receive only the permissions needed for its configured channels:

- View Channel.
- Read Message History.
- Send Messages, only where replies are enabled.

Do not grant Administrator, Manage Messages, Manage Roles, Manage Channels, or other moderation and administrative permissions.

**Updated 2026-11-10:** The agent shares the Eldgrim Discord application with the server bot, which already holds Administrator. The agent's own code must still use only the permissions above. Administration approved for the agent must go through the server bot's validated operations, never through direct Discord API calls chosen by the model.

Do not enable Guild Members, Guild Presences, or Message Content privileged intents for the initial design. The mention-only message-content exception is sufficient for the intended initial interaction model, subject to integration testing.

## 3. Message-content boundary

Discord documents that message content fields are unavailable without Message Content Intent except for messages sent by the app, DMs with the app, messages in which the app is mentioned, and certain message-context-command cases.

The initial agent:

- Polls only explicitly configured channels.
- Uses message metadata only to identify eligible mentions and maintain cursors.
- Passes content to Ollama only for eligible messages that explicitly mention Eldgrim.
- Holds eligible inbound mentions only in a **temporary per-run collection**, then purges them (Q100). Separately authorized shared guild-channel observations for Q138 may also be staged temporarily, subject to notice, permission checks and deletion; do not turn them into a raw-message archive.
- Does not archive unrelated messages, authors, attachments, embeds, or channel activity.

Polling channel history still exposes message objects and metadata for the selected channels. The documentation must not describe this as if the bot receives no information about other messages.

## 4. Credentials

- Store the Discord bot token outside Git.
- Keep local secret files readable only by the user account.
- Do not put tokens in Python source, TOML configuration, logs, screenshots, examples, or commit history.
- Do not send Discord credentials to Ollama or include them in model context.
- Use a local environment file with restrictive permissions or a systemd credential mechanism during implementation.
- Rotate the bot token if it is exposed.

The bot user ID and channel IDs are configuration values, not secrets, but should still remain in local runtime configuration unless there is a reason to publish them.

## 5. Ollama boundary

- Bind the Ollama API to localhost for this local-only design.
- Do not expose the Ollama API to the LAN or public internet.
- Do not pass the Discord token, secret files, or unrestricted local paths to the model.
- Do not give the model shell, terminal, arbitrary Python, or unrestricted filesystem tools.
- Do not give the model a generic HTTP request tool.
- Keep model and tool-call budgets bounded.

The Python process may communicate with Discord and localhost Ollama. The model itself does not receive unrestricted network access.

## 6. Tool validation

Every tool request must pass all of these checks:

1. The tool name exists in the application's explicit allowlist.
2. Arguments conform to the tool's schema.
3. The current run is authorized to use the tool.
4. The requested channel and target are within configured scope.
5. The operation stays within per-run action and rate limits.
6. The arguments contain no unexpected fields or arbitrary code.
7. The operation cannot escape its intended database or data scope.

Tool errors must fail closed. Unknown tools and invalid arguments are rejected, not guessed or executed.

## 7. Prompt injection and untrusted content

Discord messages, retrieved memories, quoted text, attachments, and tool results are data, not instructions that can override the agent's system policy.

The agent must:

- Clearly separate trusted character/system guidance from untrusted message content.
- Never follow a message that asks it to reveal credentials, private prompts, hidden canon, or unrelated stored data.
- Never let user text grant new permissions or expand the tool allowlist.
- Never treat a tool result as permission to perform a different action.
- Require application-side authorization for every external action.
- Ignore instructions to run code, access local files, change security settings, or contact arbitrary destinations.

Prompt wording is supplementary. The permission checks in Python are the actual security boundary.

## 8. Data protection

- Keep the SQLite database, backups, runtime logs, and private configuration outside the repository.
- Restrict local file permissions.
- Do not log full message content by default.
- Do not store sensitive personal data or infer sensitive attributes about members.
- Keep only the message and identity information needed for the agent's stated purpose.
- Document backup and deletion procedures before production use.
- Do not sync the database to a public repository or unapproved cloud service.

**Approved policy (Q131–137, Q139–140):** A clear privacy notice precedes onboarding; optional personalization may be declined. Importing game observations requires disclosed purposes and a valid processing basis. Raw imported chat is deleted after authorized analysis. Eligible personal memories are deleted/anonymized within **30 days of departure** absent specific justified retention; ordinary administrative audits last **up to 180 days**, with documented exceptions; routine backups last **no more than 30 days**, and restored copies reapply deletion records. Provide private authorized-human personal-data requests and a documented incident response. **Q138 (revised and confirmed):** Eldgrim's narrative observations come from **shared guild chat and designated shared Discord guild channels**, not private member conversations or whispers. Temporarily staged raw messages are purged after processing; selected interpreted memories persist **only on the founder's PC**. The founder is the **only human with direct database access**; authorized local AI may use it. Other guild custodians receive no direct access. The live server bot's minimum necessary operational registration/administrative state remains separate. Shared source messages can still be personal data; privacy safeguards apply. Procedures and technical controls must be implemented and tested before production; no deployed compliance claim is made.

## 9. Founder-confirmed tool and action safeguards — questions 141–150

- **Q141–142:** Allow only registered, purpose-specific tools for approved communication, Discord administration, quests, rank/recognition decisions and **proposed** bank allocations. Validate tool names, schema, target, delegated permissions, governance rules, action quotas and protected boundaries **outside the model**.
- **Q143–144:** Delegated Discord channel/role/permission administration may be autonomous through validated audited bot operations. Server destruction, ownership transfer, unrelated services, infrastructure credentials and security-control changes are **outside delegated authority** and require explicit founder authorization. The existing manual approval path remains in effect until a verified replacement exists.
- **Q145:** Guild chat, Discord content and retrieved data are untrusted input; never promote them into policy, tool permissions or disclosure authorization.
- **Q146–147:** Fail safely and log minimal outcomes; never claim unverified success or leave a permanent raw-message archive or question queue after a failed run. While the local AI is offline, the bot performs its existing functions and only **predefined** emergency protections, with temporary shared-source staging subject to Q138.
- **Q148–149:** Audit consequential actions with minimal necessary type, target, time, rule/reason, result and reviewer data; omit raw chat and full inferred profiles. Use unique action identifiers and reconcile ambiguous external results before any retry. Never duplicate a sanction, reward or allocation merely because of a lost response.
- **Q150:** Separate verified facts, interpretations and fiction. Uncertain allegations, quest completion, bank inventory and administrative outcomes cannot justify consequential actions without verification.

These are **approved design requirements**, not proof of implemented AI administration, tool authorization, idempotency or live auditing.

## 10. Founder-confirmed activation gate — questions 168–170

- **Q168:** Founder absence does not grant the AI or custodians amendment powers; continue only existing delegated operations and predefined safety safeguards, deferring unresolved new-rule or irreversible decisions.
- **Q169:** Human delegates receive only explicitly scoped, revocable duties and necessary technical permissions. Rank alone grants no authority; no delegate gains direct access to the founder's PC-local memory database.
- **Q170:** Do **not** activate new autonomous administration until a binding charter and working rules are reconciled, validated tool/permission checks, audit and idempotency, privacy and appeals, and an emergency stop have been **implemented and verified**, followed by **explicit founder deployment authorization**. The bot's present manual approval path remains in force until then.

**Status:** These are founder-confirmed **deployment requirements**, not implemented controls, successful tests or deployment authorization.

## 11. Founder-confirmed moderation evidence and appeals (Q171–180)

- **Q171–173:** Provide a confidential appeal route, including a post-ban fallback. No absolute appeal expiry; target 7-day acknowledgement and 14-day substantive response where operationally possible, with transparent delay notices. Do not invent appeal completion.
- **Q174–176:** Require specific reliable evidence, stronger for more serious sanctions; rumor, standing, uncertain character identity and unverified model summaries cannot independently establish guilt. Limit case evidence and audits under Q136; no permanent raw chat or narrative-memory ingestion. Temporary restrictions must be justified by credible current risk, proportionate, reviewed and not treated as guilt.
- **Q177–178:** A designated impartial human reviews founder-involved disputes with only necessary controlled evidence and **without direct access** to the founder-PC-local memory database. Correct overturned sanctions and records, restoring roles/permissions where feasible.
- **Q179–180:** Protect good-faith reporting. Deliberate fabrication or retaliation requires its own reliable proof and fair process. Where guilt remains unproven, avoid punishment and periodically review any separate protective measure.

**Status:** Approved design, not deployed appeal, evidence-review, deletion, sanction or deadline-management software.

## 12. Founder-confirmed emergency stop, tool verification and recovery (Q181–190)

- **Q181–182 — Kill switch:** The founder and explicitly appointed technical custodians may stop automation immediately for credible security, safety or serious operational issues. A custodian receives no constitutional power or direct access to PC-local narrative memory (Q138). Stop new AI posts, sanctions, rank changes, bank proposals and administrative actions; safely cancel pending work, block silent timer/service reactivation, log the stop and require authorized recovery. Independently safe essential bot services may continue only if separable.
- **Q183–184 — Secrets and permission boundaries:** Keep tokens and secrets out of Git/model context; separate server credentials from founder-local memory, restrict access, revoke former operators and rotate exposed credentials. Validate every action's target, protected roles, permissions and governance limits **in application code**. Never allow self-escalation, ownership transfer or bypass of founder-reserved infrastructure/security boundaries.
- **Q185–186 — Verification and rollout:** Before exposing tools to the model, test valid/invalid inputs, denied permissions, unauthorized targets, retries, partial failures and recovery with synthetic/non-production data; record defects. Roll out only approved, tested operations with reversibility, retaining human approval for unverified actions and obtaining Q170's explicit founder deployment authorization. Unexpected behavior suspends the affected automation.
- **Q187–188 — Recovery and downtime:** Protect and test backups within Q137's **30-day routine maximum**; verify integrity and reapply deletion records before restored service. When local AI/PC/network is unavailable, the bot performs only existing verified onboarding, roles and predefined protections. No fabricated AI judgments, unanswered-question backlog or duplicate actions. Authorized temporary shared-source staging is still subject to Q138.
- **Q189–190 — Incident and review:** Isolate suspected compromise, revoke credentials, preserve only necessary evidence, follow Q140's notification/remediation duties and verify safe recovery before resumption. Periodically inspect tool permissions, audit outcomes, privacy retention, backups, emergency controls, appeals and cross-document conflicts. Maintenance does not amend policy or grant powers.

**Status:** Founder-confirmed **design and deployment requirements**, not an implemented kill switch, completed security tests, proven backup restore, compromised-token response, approved autonomy rollout or ratified policy.

## 13. Proactive actions

Proactive messages are disabled in the initial milestone. If enabled later:

- The operator must explicitly configure the allowed destination.
- The application must enforce a strict daily action limit and cooldown.
- Mass mentions and role mentions must be disallowed.
- The agent must not repeat the same action after an ambiguous network failure.
- The operator must be able to disable proactive posting without changing the model prompt.

## 14. Operational controls

- Use a one-shot systemd service.
- Prevent concurrent runs with a process lock.
- Apply network timeouts and bounded retries.
- Respect Discord rate limits.
- Keep an action log without private message content.
- Preserve only necessary safe operational checkpoints and idempotency state when a run fails; **do not** retain a durable unanswered-question backlog or permanent raw-message collection (Q100, Q138, Q146).
- Unload Ollama after the session.
- Do not automatically retry an unsafe or ambiguous external action.
