# Changelog

Meaningful repository and documentation changes are recorded here.

## 2026-11-09
- Expanded the approved Eldgrim addon scope from guild-only chat capture to a local archive of the current guild roster and member-authored messages across supported player-chat channels.
- Added event-driven roster synchronization through the built-in C_Club.FocusMembers subscription, member entries for silent members, current/former membership state, and preservation of former-member history.
- Added officer, say, yell, character whisper, party, raid, instance, custom/community channel, and player-emote event handling with current-member filtering.
- Added outgoing whisper attribution to the local guild member and channel/direction metadata to message records.
- Migrated the original name-keyed archive to SavedVariables schema version 2 without discarding existing guild messages.
- Expanded Forever API research, specification, installation notes, and in-game test plan.
- Local texlua syntax and mocked behavior checks passed. Expanded live roster and chat-event behavior remains unverified in-game.
- No publishing tag, GitHub Release, or CurseForge publication was created.

## 2026-11-08
- Established the initial Eldgrim repository documentation foundation.
- Added contributor guidance, concept, roadmap, documentation policy, decisions, and development history.
- Added structured areas for character, lore, narrative, interaction, assets, and templates.
- Recorded the distinction between public character material, Amberhearth guild operations, and technical development.
- Documented the approved Forever-only Eldgrim addon scope: a passive local guild-chat recorder with compact character profiles and timestamped messages.
- Added Forever API research, data-model specification, and an in-game test plan.

- Added the initial Eldgrim Forever addon source and TOC manifest under addon/Eldgrim/ (version 0.1.0-alpha, interface 16001).
- Added a repeatable mock test harness under addon/tests/; Lua syntax validation and mocked behavior checks passed with texlua.
- No in-game verification was included in the development commit. The creative later reported that the original guild-only recorder worked after reload; the exact build and checks were not recorded. No public tags, GitHub Releases, or CurseForge publication were created.

This changelog describes repository changes, not in-world events.
