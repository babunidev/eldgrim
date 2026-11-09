# Concept

**Status:** Established character foundation; addon scope approved; local agent architecture developing.

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

A third workstream is developing under agent/. It documents a proposed local communication agent that activates once per day through a systemd user timer. A one-shot Python process polls explicitly configured Discord channels through the HTTP API, processes messages that explicitly mention Eldgrim, uses local Ollama inference when there is eligible work, and stores selected interaction history and memories in a private SQLite database.

The design avoids a permanently connected Discord Gateway session and does not require the language model to remain loaded between sessions. Direct replies may become autonomous within configured limits. Proactive channel posts are a separate opt-in capability.

This is an out-of-character software design, not an established in-world power or proof of autonomous behavior. No agent implementation, Discord integration, runtime database, scheduled service, or deployment exists yet. The agent must not expose private character information or concealed motives to players.

The agent and addon are independent. The agent does not read the addon's SavedVariables or change the addon's approved passive-recorder scope.

## Project boundaries

This repository contains public-safe character and narrative documentation alongside separately scoped technical workstreams. Amberhearth governance and operations remain in the guild's own repository.

Any additional bot, assistant, autonomous behavior, integration, or feature beyond the documented scopes must be specified and approved separately. A character concept or technical specification is not evidence that software exists.

## Creative principles

1. Character before mechanics.
2. Preserve mystery without making the character incoherent.
3. Let relationships and witnessed moments shape the narrative.
4. Keep in-character presentation distinct from production notes.
5. Treat every new power, rule, history detail, or recurring behavior as a canon decision.
6. Keep public documentation free of secrets intended to remain unknown in-world.
