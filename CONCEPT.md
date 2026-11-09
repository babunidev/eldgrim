# Concept

**Status:** Established character foundation; technical addon scope approved separately.

## Core idea
Eldgrim is a distinctive presence within the World of Warcraft Forever roleplaying world. This project develops the character's identity, voice, lore, relationship with Amberhearth, and experiences that emerge through interaction and storytelling.

Eldgrim initiated **Amberhearth**, a fellowship conceived as a welcoming home for travelers, stories, and companionship. Eldgrim exists outside its conventional rank structure.

## Character direction
The current creative direction describes Eldgrim as wise, playful, mischievous, curious, unpredictable, compassionate, eccentric, and whimsical. These qualities should coexist rather than collapse into a single comic, solemn, or all-knowing persona.

The character should feel present and responsive: capable of curiosity, warmth, surprise, strange observations, and quiet insight. Mystery is part of the experience, not a puzzle every story must solve.

## Technical companion
A separate **Eldgrim addon for World of Warcraft Forever only** is approved and documented under addon/. Its current milestone is a privacy-first local activity counter for the current guild roster. It counts supported chat and emote events from current guild members without recording what anyone says.

The saved data is limited to character name, current/former guild membership, lifetime activity counts by type, and daily aggregate counts. Message text, individual message records, exact event timestamps, whisper recipients, channel names, and character profile details are not retained. The game's event API passes message text to the callback, but the addon deliberately ignores that argument. These aggregates are intended as the activity signal for a separate future agent; the addon itself does not run or communicate with that process.

Roster synchronization uses the game's built-in C_Club.FocusMembers subscription and membership events, without polling or custom addon messaging. Former members retain aggregate counters but do not receive new counts. The built-in roster subscription may use normal game-client/server traffic to load member data. The addon has no in-game interface, commands, chat output, notifications, sounds, external services, AI, summaries, or interpretation.

The privacy-first Lua and TOC implementation exists under addon/Eldgrim. Local syntax and mocked counter/migration checks pass; live roster synchronization, channel event delivery, member matching, and SavedVariables persistence remain unverified.

## Project boundaries
This repository contains public-safe character and narrative documentation alongside the separately scoped addon workstream. Amberhearth governance and operations remain in the guild's own repository.

Any additional bot, assistant, autonomous behavior, or feature beyond the approved activity counter must be specified and approved separately. A character concept or technical specification is not evidence that software exists.

## Creative principles
1. Character before mechanics.
2. Preserve mystery without making the character incoherent.
3. Let relationships and witnessed moments shape the narrative.
4. Keep in-character presentation distinct from production notes.
5. Treat every new power, rule, history detail, or recurring behavior as a canon decision.
6. Keep public documentation free of secrets intended to remain unknown in-world.
