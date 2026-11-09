# Development Log

A concise account of meaningful project development, written from the human creative's perspective.

## 2026-11-08 — Establishing the repository foundation
With Eldgrim becoming a distinct character and narrative project, I asked AI to establish a documentation structure that could hold the character's identity, voice, lore, and developing stories without confusing them with Amberhearth's guild administration or a possible future software implementation. The existing README provided the initial direction; AI organized the supporting documents and folder structure, preserving unresolved details as open rather than inventing canon.

**Result:** Documentation structure committed to the repository. No addon, bot, or other software was implemented or verified.

## 2026-11-08 — Defining the first addon milestone
After narrowing the addon's first responsibility to passive local guild-chat recording, I approved a dedicated technical area inside this repository while keeping it separate from Eldgrim's in-world character material and Amberhearth's guild operations. The initial archive was limited to character names, available human-readable character details, message text, and timestamps. It had no in-game interface or interaction.

AI reviewed the repository instructions and documentation, researched the Forever-specific chat and character APIs, and recorded both the available data and the unresolved runtime questions. The research baseline was Forever 1.60.1, interface 16001, with build 1.60.1.70862 as the latest public build found during that work.

**Result:** Addon specification, API research, data model, and test plan added.

## 2026-11-08 — First recorder implementation
With the first milestone settled, I asked AI to implement the Forever-only event recorder and its TOC manifest inside the existing addon/ area. The code registered `CHAT_MSG_GUILD` and saved timestamped message text with the available matching author information.

AI added a repeatable mocked test harness. Lua syntax validation and the mock behavior suite passed with texlua. Those checks exercised local logic only; live Forever event correlation, profile data, SavedVariables persistence, and in-game behavior were not verified.

**Result:** Initial addon source, TOC manifest, and mock tests committed. No public release was created.

## 2026-11-09 — Expanding to guild-member activity
After considering the privacy implications of keeping conversations, I changed the purpose of the addon. The aim is to understand participation, not to preserve private words. Eldgrim should count how often current guild members use supported chat and emote channels, while discarding the message content itself.

The new data model keeps only each member's name, current/former guild status, lifetime counts by activity type, and daily aggregate counts. Character profiles, recipients, channel names, individual message records, and exact event timestamps are no longer part of the archive. Existing saved messages are converted into aggregate counts during migration, then removed from the new in-memory database.

AI replaced the recorder with a counter, updated the schema to version 3, expanded the mock tests to check data minimization, and revised the addon documentation. Local texlua syntax and mocked behavior checks passed. Live roster synchronization, channel event delivery, and SavedVariables persistence still require testing in the installed Forever build.

**Result:** Privacy-first activity-counter implementation prepared as a development change. No publishing tag, GitHub Release, or CurseForge publication was created.
