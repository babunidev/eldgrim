# Concept

**Status:** Established character foundation; addon scope approved; local agent architecture developing; Discord bot direction approved.

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

## Technical companion: Discord bot

Eldgrim also appears on the guild Discord server as a bot. The existing Babuni Gaming Discord bot is being renamed to Eldgrim and expanded, and it now runs on the creative's always-online server. Eldgrim keeps the current administration and Character Forge capabilities, and will guide newcomers through declaring their in-game characters. Eldgrim speaks only once a day and only in reply to messages that mention @Eldgrim. The member and character data stored on the server will form the basis of Eldgrim's database, later combined with the addon's in-game records.

The direction is approved on 2026-11-10 and documented under bot/. The unchanged bot runs on the server; renaming and new features are not implemented yet. Like the addon, the bot does not define Eldgrim's in-world canon.

Parts of this direction differ from the earlier local-agent design: where the bot runs, whether Eldgrim performs administration, and whether addon data is used. These points are open decisions listed in bot/README.md.

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
