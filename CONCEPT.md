# Concept

**Status:** Established character foundation; technical addon scope approved separately.

## Core idea
Eldgrim is a distinctive presence within the World of Warcraft Forever roleplaying world. This project develops the character's identity, voice, lore, relationship with Amberhearth, and experiences that emerge through interaction and storytelling.

Eldgrim initiated **Amberhearth**, a fellowship conceived as a welcoming home for travelers, stories, and companionship. Eldgrim exists outside its conventional rank structure.

## Character direction
The current creative direction describes Eldgrim as wise, playful, mischievous, curious, unpredictable, compassionate, eccentric, and whimsical. These qualities should coexist rather than collapse into a single comic, solemn, or all-knowing persona.

The character should feel present and responsive: capable of curiosity, warmth, surprise, strange observations, and quiet insight. Mystery is part of the experience, not a puzzle every story must solve.

## Technical companion
A separate **Eldgrim addon for World of Warcraft Forever only** is approved and documented under addon/. Its approved milestone is a passive local archive of the current guild roster and the player-authored messages from current guild members across supported in-game chat channels. Every current member receives an entry, even before sending a message.

Roster synchronization uses the game's built-in C_Club.FocusMembers subscription and membership events, without polling or custom addon messaging. Former members retain their history but do not receive new message records. The addon has no in-game interface, commands, chat output, notifications, sounds, custom addon messages, external services, AI, summaries, or interpretation. The built-in roster subscription may use normal game-client/server traffic to load member data. The technical project does not change Eldgrim's character canon or reveal concealed lore.

The expanded Lua and TOC implementation now exists under addon/Eldgrim. Local syntax and mocked behavior checks pass; live roster synchronization, channel event delivery, full-name matching, and SavedVariables persistence remain unverified.

## Project boundaries
This repository contains public-safe character and narrative documentation alongside the separately scoped addon workstream. Amberhearth governance and operations remain in the guild's own repository.

Any additional bot, assistant, autonomous behavior, or feature beyond the approved archive must be specified and approved separately. A character concept or technical specification is not evidence that software exists.

## Creative principles
1. Character before mechanics.
2. Preserve mystery without making the character incoherent.
3. Let relationships and witnessed moments shape the narrative.
4. Keep in-character presentation distinct from production notes.
5. Treat every new power, rule, history detail, or recurring behavior as a canon decision.
6. Keep public documentation free of secrets intended to remain unknown in-world.
