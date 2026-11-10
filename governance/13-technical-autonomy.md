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

## Refinement queue

- [ ] What is the explicit allowlist of administrative tools and arguments?
- [ ] Which operations require preview and approval?
- [ ] How will each permission and audit boundary be verified in live integration?

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)


## Confirmed off-cycle boundary — question 74

The local AI agent is not continuously active. When it is offline, the server bot may apply **explicitly authorized, predefined emergency safeguards**, and designated human custodians may intervene. Complex, context-sensitive AI moderation decisions wait until the next local-agent session. Emergency actions require audit records and subsequent review. This is a **governance design decision**; it does not assert that these protections have been implemented or tested.
