# Changelog

Meaningful repository and documentation changes are recorded here.

## 2026-11-09 — Privacy-first activity counters
- Replaced the conversation-archive scope with a privacy-first activity counter for current guild members.
- Changed storage to schema version 3: member name, membership status, lifetime totals, per-type totals, and daily aggregate counts only.
- Removed message text, individual message records, exact event timestamps, recipients, channel names, and character profile fields from the saved data model.
- Changed the event handler to use the speaker field only and increment a counter; it no longer calls the community-message content API.
- Added migration from the previous message archive, aggregating existing records by type/day and discarding message and profile fields.
- Expanded mock tests to check that message content and profile data do not survive in SavedVariables.
- Local texlua syntax and mocked behavior checks passed. Live roster and event behavior remains unverified in-game.
- No publishing tag, GitHub Release, or CurseForge publication was created.

## 2026-11-09 — Guild-member conversation archive (superseded)
- The initial expanded design added a current guild roster and capture across supported player-chat channels.
- That message-content archive was implemented briefly, then superseded by the privacy-first counter design above.
- Its implementation is retained in Git history, not as the current addon behavior.

## 2026-11-08
- Established the initial Eldgrim repository documentation foundation.
- Added contributor guidance, concept, roadmap, documentation policy, decisions, and development history.
- Added structured areas for character, lore, narrative, interaction, assets, and templates.
- Recorded the distinction between public character material, Amberhearth guild operations, and technical development.
- Documented the original Forever-only Eldgrim addon scope and its initial guild-chat recorder.

- Added the initial Eldgrim Forever addon source and TOC manifest under addon/Eldgrim/ (version 0.1.0-alpha, interface 16001).
- Added a repeatable mock test harness under addon/tests/; Lua syntax validation and mocked behavior checks passed with texlua.
- No in-game verification was included in the development commit. The creative later reported that the original guild-only recorder worked after reload; the exact build and checks were not recorded. No public tags, GitHub Releases, or CurseForge publication were created.

This changelog describes repository changes, not in-world events.
