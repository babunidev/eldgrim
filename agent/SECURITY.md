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
- Stores only eligible inbound messages and relevant bot replies.
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

## 9. Proactive actions

Proactive messages are disabled in the initial milestone. If enabled later:

- The operator must explicitly configure the allowed destination.
- The application must enforce a strict daily action limit and cooldown.
- Mass mentions and role mentions must be disallowed.
- The agent must not repeat the same action after an ambiguous network failure.
- The operator must be able to disable proactive posting without changing the model prompt.

## 10. Operational controls

- Use a one-shot systemd service.
- Prevent concurrent runs with a process lock.
- Apply network timeouts and bounded retries.
- Respect Discord rate limits.
- Keep an action log without private message content.
- Preserve pending work when a run fails.
- Unload Ollama after the session.
- Do not automatically retry an unsafe or ambiguous external action.
