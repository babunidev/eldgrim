# Development Log

A concise account of meaningful project development, written from the human creative's perspective.

## 2026-11-09 — Documenting the local agent architecture

With Eldgrim's technical direction expanding beyond the passive addon, I asked AI to research and document a local agent that would act once per day while remaining autonomous within clear boundaries. The design separates Discord communication from local model inference: a systemd user timer starts a one-shot Python process, the process polls configured Discord channels through the HTTP API, local Ollama performs bounded reasoning and tool calls, and SQLite holds private runtime memory outside the repository.

AI checked the design against the current official Discord, Ollama, Python, and systemd documentation. The initial communication scope is limited to explicit mentions, without requesting Discord's privileged Message Content Intent. The documentation also records that REST polling still exposes message metadata for the selected channels, so unrelated messages must not be archived or sent to the model.

The agent remains independent of the Forever addon and of Eldgrim's public character canon. Proactive channel posts are documented as an opt-in capability rather than a default behavior.

**Result:** Added the agent architecture, specification, security, memory, and operations documentation; updated the repository map, instructions, concept, roadmap, decisions, and changelog. This was a documentation change only. No Python agent, Discord integration, SQLite runtime database, systemd unit, or deployment was created or tested.

## 2026-11-08 — Establishing the repository foundation

With Eldgrim becoming a distinct character and narrative project, I asked AI to establish a documentation structure that could hold the character's identity, voice, lore, and developing stories without confusing them with Amberhearth's guild administration or a possible future software implementation. The existing README provided the initial direction; AI organized the supporting documents and folder structure, preserving unresolved details as open rather than inventing canon.

**Result:** Documentation structure committed to the repository. No addon, bot, or other software was implemented or verified.

## 2026-11-08 — Defining the first addon milestone

After narrowing the addon's first responsibility to passive local guild-chat recording, I approved a dedicated technical area inside this repository while keeping it separate from Eldgrim's in-world character material and Amberhearth's guild operations. The initial archive is limited to character names, available human-readable character details, message text, and timestamps. It has no in-game interface or interaction.

AI reviewed the repository instructions and documentation, researched the Forever-specific chat and character APIs, and recorded both the available data and the unresolved runtime questions. The current research baseline is Forever 1.60.1, interface 16001, with build 1.60.1.70862 as the latest public build found during this work.

**Result:** Addon specification, API research, data model, and test plan added. No addon source code was implemented; no syntax checks or in-game tests were run.

## 2026-11-08 — First recorder implementation

With the first milestone settled, I asked AI to implement the Forever-only event recorder and its TOC manifest inside the existing addon/ area. The code registers only CHAT_MSG_GUILD, checks chat-messaging lockdown before reading the event payload, and accepts community author data only when the returned record is a guild message whose content and author exactly match the current event.

The archive stores character-facing names and values only, alongside timestamped message text. Community identifiers are kept transiently for correlation and are never written to SavedVariables. When a community record cannot be matched, the message uses local receipt time and is saved without unverified profile enrichment.

AI added a repeatable mocked test harness. Lua syntax validation and the mock behavior suite passed with texlua. These checks exercise local logic only; live Forever event correlation, profile data, SavedVariables persistence, and in-game behavior have not been verified.

**Result:** Initial addon source, TOC manifest, and mock tests committed. No public release was created.
