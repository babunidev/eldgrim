# Concept

**Status:** Established character foundation; addon scope approved; local agent developing; Discord bot live with its Forge.

## Core idea

Eldgrim is a distinctive presence within the World of Warcraft Forever roleplaying world. This project develops the character's identity, voice, lore, relationship with Amberhearth, and experiences that emerge through interaction and storytelling.

Eldgrim initiated **Amberhearth**, a fellowship conceived as a welcoming home for travelers, stories, and companionship. Eldgrim exists outside its conventional rank structure.

## Character direction

The current creative direction describes Eldgrim as wise, playful, mischievous, curious, unpredictable, compassionate, eccentric, and whimsical.

These qualities should coexist rather than collapse into a single comic, solemn, or all-knowing persona. Eldgrim should feel present and responsive: capable of curiosity, warmth, surprise, strange observations, and quiet insight. Mystery is part of the experience, not a puzzle every story must solve.

## Technical companion: Forever addon

A separate **Eldgrim addon for World of Warcraft Forever only** is approved and documented under addon/. Its first milestone is deliberately narrow: passively collect guild-chat messages and the available human-readable character information associated with each speaker, then save the archive locally through SavedVariables.

The first milestone has no in-game interface, commands, chat output, notifications, sounds, addon communication, network activity, AI, summaries, or interpretation. It is a local recorder, not an in-game chatbot. The technical project does not change Eldgrim's character canon or reveal concealed lore.

The initial Lua and TOC implementation exists under addon/Eldgrim. In-game event correlation, character enrichment, and SavedVariables persistence remain unverified.

## Technical companion: local agent

A third workstream is developing under agent/. It is Eldgrim's once-daily voice on the founder's computer. A one-shot Python process wakes at a moment Eldgrim chose at the end of the previous run, uses local Ollama inference, and keeps only interpreted observations in a private SQLite database there. Its first task is one daily proclamation; replies to messages that mention Eldgrim come later.

The design avoids a permanently connected Discord Gateway session and does not require the language model to remain loaded between sessions. Direct replies may become autonomous within configured limits. Apart from the one approved daily proclamation, proactive channel posts stay disabled.

This is an out-of-character software design, not an established in-world power or proof of autonomous behavior. A local runner can write a test announcement and choose the next wake time; nothing is posted, and there is no Discord integration, roster database or armed timer yet. The agent must not expose private character information or concealed motives to players.

The agent never changes the addon's approved passive-recorder scope. Reading the addon's archive, and clearing its message lists after a successful save, is approved and specified in agent/ROSTER.md (2026-11-11).

## Technical companion: Discord bot

Eldgrim also appears on the guild Discord server as a bot. The existing Babuni Gaming Discord bot was renamed to Eldgrim and runs on the creative's always-online server. It keeps the earlier administration capabilities, and its multi-character Forge guides newcomers through declaring their in-game characters. Eldgrim speaks once a day: one proclamation first, and later replies to messages that mention @Eldgrim. The server keeps only the operational Forge and role data; Eldgrim's memory lives on the founder's computer.

The direction was approved on 2026-11-10 and is documented under bot/. The rename and the Forge are live; AI-driven administration is not. Like the addon, the bot does not define Eldgrim's in-world canon.

The server bot and the local agent work together: the bot is Eldgrim's always-online part for onboarding, administration, and data; the agent on the creative's PC is its once-daily voice. The agent may trigger administration through the bot's validated operations and may use the addon's archive. Administration tools are not yet specified; the archive reading is specified in agent/ROSTER.md. Neither is built.

## Project boundaries

This repository contains public-safe character and narrative documentation alongside separately scoped technical workstreams and Eldgrim's working governance rulebook. The binding Amberhearth charter and guild operations remain in the guild's own repository.

Any additional bot, assistant, autonomous behavior, integration, or feature beyond the documented scopes must be specified and approved separately. A character concept or technical specification is not evidence that software exists.

## Creative principles

1. Character before mechanics.
2. Preserve mystery without making the character incoherent.
3. Let relationships and witnessed moments shape the narrative.
4. Keep in-character presentation distinct from production notes.
5. Treat every new power, rule, history detail, or recurring behavior as a canon decision.
6. Keep public documentation free of secrets intended to remain unknown in-world.
