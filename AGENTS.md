# Agent and Contributor Instructions

## Project role
Eldgrim is a character and narrative project in the World of Warcraft Forever roleplaying setting. The repository also contains a separately documented technical workstream for the Eldgrim addon under addon/.

Keep these areas distinct:
- Character, lore, and narrative documents describe Eldgrim as an in-world character.
- addon/ describes the out-of-character software project. Addon behavior does not establish character canon.
- Amberhearth governance and guild operations belong in the ROARguild repository.

The human creative owns the concept, canon, tone, scope, priorities, and final decisions. AI may assist with research, organization, drafting, review, implementation, testing, and documentation when requested.

## WoW Forever addon rules
- Develop for World of Warcraft Forever only. Current baseline: version 1.60.1, interface 16001. Record the exact client build used for research and testing; reverify after updates.
- Do not add Retail, Classic Era, Vanilla, Burning Crusade, or other-client compatibility or fallback branches.
- Verify every API against Forever-specific documentation or the current Forever client. Distinguish API-documented behavior, inference, and in-game verification. An API's presence in documentation does not prove that the intended event flow works in-game.
- Respect chat-messaging lockdown and secret-value restrictions. Skip inaccessible data safely; never attempt to bypass client restrictions.
- Keep the approved addon scope within addon/SPECIFICATION.md: a silent, local activity counter for the current guild roster and chat activity from current guild members.
- Count guild and officer chat, say, yell, character whispers, party, raid, instance, custom/community channels, and player emote events when the Forever client delivers them and the speaker matches the current guild roster.
- Never record, inspect, parse, compare, summarize, or persist message text. The event callback receives the game's chat payload, but the handler must use only the speaker field and the community-relay marker needed to exclude relayed messages.
- Use Forever's C_Club APIs to scan only the current guild roster. Call C_Club.FocusMembers once per current guild to subscribe the game client to member updates; use AreMembersReady before reading the list. This built-in roster subscription may cause normal client/server traffic, but no custom addon messages or external services are allowed.
- Persist each current guild member under their full character name, including members with zero activity. Save only membership status, lifetime aggregate counts by activity type, and daily aggregate counts. Preserve former members' counters but do not count new activity from them.
- Do not save character profile details, message records, exact event timestamps, whisper recipients, channel names, or technical identifiers.
- Keep the addon passive: no in-game UI, slash commands, chat output, notifications, sounds, custom addon messages, external services, AI, summaries, or interpretation.
- Use SavedVariables for local persistence. Do not assume an addon can write or append arbitrary files. Document the save lifecycle and verify persistence in the current client.
- Do not scan unrelated rosters, inspect characters outside the current guild, or poll. Refresh the current guild roster only on initial load and relevant membership events. Match full character names, never first names alone. Attribute outgoing whisper activity to the local guild member without retaining the recipient.

## Canon discipline
- Treat the current repository and explicit creative decisions as the source of truth.
- Distinguish Established, Developing, Proposed, Open, and Retired material.
- Never promote an assistant suggestion into canon without approval.
- Preserve corrections to names, relationships, chronology, and characterization.
- Use Eldgrim as the current name. Oracle is an obsolete working label and may appear only in historical context.
- Do not invent powers, limitations, backstory, schedules, or responsibilities.
- Keep public-facing material safe for readers who are not meant to know Eldgrim's concealed nature or private agenda. Do not place secret canon in this public repository.

## Authorship and collaboration
- Refer to the person who conceives and directs the work as the creative.
- Public development narratives use the creative's first-person perspective, but never begin a sentence with “I” or “My”.
- Attribute AI contributions accurately. Do not imply the creative personally wrote code or performed actions carried out by AI.
- Record meaningful decisions, discarded approaches, implementation, and verification accurately.
- Keep development journal entries concise.

## Writing
- Keep Eldgrim's voice distinctive, coherent, and context-sensitive.
- Prefer evocative, grounded writing over exaggerated claims or generic fantasy language.
- Preserve mystery. Do not explain every strange occurrence.
- Separate in-character text from out-of-character notes.
- Do not expose private conversations, credentials, personal data, or unpublished secrets.

## Repository workflow
- Read relevant documentation before changing it.
- Update relevant documents when an approved decision or substantial change occurs.
- Do not claim an asset, addon, bot, integration, or feature exists unless verified.
- Keep proposals separate from implemented and tested work.
- Prefer small, reviewable changes with clear commit messages.
