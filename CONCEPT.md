# Concept

**Status:** Established character foundation; technical addon scope approved separately.

## Core idea
Eldgrim is a distinctive presence within the World of Warcraft Forever roleplaying world. This project develops the character's identity, voice, lore, relationship with Amberhearth, and experiences that emerge through interaction and storytelling.

Eldgrim initiated **Amberhearth**, a fellowship conceived as a welcoming home for travelers, stories, and companionship. Eldgrim exists outside its conventional rank structure.

## Character direction
The current creative direction describes Eldgrim as wise, playful, mischievous, curious, unpredictable, compassionate, eccentric, and whimsical. These qualities should coexist rather than collapse into a single comic, solemn, or all-knowing persona.

The character should feel present and responsive: capable of curiosity, warmth, surprise, strange observations, and quiet insight. Mystery is part of the experience, not a puzzle every story must solve.

## Technical companion
A separate **Eldgrim addon for World of Warcraft Forever only** is approved and documented under addon/. Its first milestone is deliberately narrow: passively collect guild-chat messages and the available human-readable character information associated with each speaker, then save the archive locally through SavedVariables.

The first milestone has no in-game interface, commands, chat output, notifications, sounds, addon communication, network activity, AI, summaries, or interpretation. It is a local recorder, not an in-game chatbot. The technical project does not change Eldgrim's character canon or reveal concealed lore.

The initial Lua and TOC implementation now exists under addon/Eldgrim. In-game event correlation, character enrichment, and SavedVariables persistence remain unverified.

## Discord presence
Eldgrim will also appear on the guild Discord server as a bot. The existing Babuni Gaming Discord bot will be renamed to Eldgrim, moved from the creative's PC to an always-online server, and expanded. Eldgrim keeps the current administration and Character Forge capabilities, and guides newcomers through declaring their in-game characters. Eldgrim speaks only once a day and only in reply to messages that mention @Eldgrim. The member and character data it stores on the server will form the basis of Eldgrim's database, later combined with the addon's in-game records.

The direction is approved; the specification is developing under bot/. No Eldgrim-specific bot code or server deployment exists yet. Like the addon, the bot does not define Eldgrim's in-world canon.

## Project boundaries
This repository contains public-safe character and narrative documentation alongside the separately scoped addon workstream. Amberhearth governance and operations remain in the guild's own repository.

Any additional assistant, autonomous behavior, or feature beyond the approved recorder and the approved Discord direction must be specified and approved separately. A character concept or technical specification is not evidence that software exists.

## Creative principles
1. Character before mechanics.
2. Preserve mystery without making the character incoherent.
3. Let relationships and witnessed moments shape the narrative.
4. Keep in-character presentation distinct from production notes.
5. Treat every new power, rule, history detail, or recurring behavior as a canon decision.
6. Keep public documentation free of secrets intended to remain unknown in-world.
