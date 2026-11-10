# Chapter 13 — Technical limits on Eldgrim's autonomy

> **Status:** Technical architecture approved; agent administration unimplemented  
> **Source:** Consolidated guild governance framework, 10 November 2026, v0.1. Working material, not a ratified constitution.

Approved architectural requirements · Implementation incomplete

The language model must not receive unrestricted control of the computer or Discord.

Its administrative requests must pass through explicitly registered tools with validated arguments, permissions, scope, and action limits. The model must not receive the bot token, unrestricted shell access, arbitrary filesystem access, or a general-purpose network tool.

Member messages, retrieved memories, and external information must be treated as untrusted content, not instructions capable of changing Eldgrim's governing rules.

The existing server bot is running. The Forge onboarding is deployed and was tested by the creative on 10 November 2026. The daily Ollama agent, combined database, and AI-directed administration have not yet been implemented and verified.

## Refinement queue

- [ ] What is the explicit allowlist of administrative tools and arguments?
- [ ] Which operations require preview and approval?
- [ ] How will each permission and audit boundary be verified in live integration?

---

[← Rulebook index](README.md) · [Amberhearth guild repository](https://github.com/babunidev/ROARguild)
