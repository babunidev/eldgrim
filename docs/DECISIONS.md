# Decisions

A concise record of meaningful creative and structural decisions.

## 2026-11-08 — Eldgrim is the current name
**Decision:** Use Eldgrim as the character's name. Oracle is an obsolete working label.
**Reason:** The character's identity has moved beyond the temporary label.
**Status:** Established.

## 2026-11-08 — Eldgrim initiated Amberhearth
**Decision:** Document Amberhearth as a fellowship initiated by Eldgrim and conceived as a home for travelers, stories, and companionship.
**Boundary:** Eldgrim stands outside the fellowship's conventional rank structure. This does not define additional powers, governance, or rank responsibilities.
**Status:** Established foundation.

## 2026-11-08 — Separate character canon from guild operations and software
**Decision:** Character and narrative material remains distinct from Amberhearth governance. Guild operations belong in the ROARguild repository. Technical work must remain in its own clearly identified area and must not silently alter character canon.
**Status:** Established.

## 2026-11-08 — Approve the Eldgrim Forever addon recorder
**Decision:** Add a dedicated addon workstream under addon/ in this repository. The addon targets World of Warcraft Forever only. Its first milestone was a passive local guild-chat archive.
**Historical scope:** The original recorder briefly stored message text, timestamps, and available character details. That implementation and scope are superseded by the privacy-first activity-counter decision below.
**Status:** Retained as development history; no longer current.

## 2026-11-09 — Expand to a guild-member conversation archive
**Decision:** Build an entry for every current guild member and capture that member's player-authored messages across supported in-game chat channels.
**Historical scope:** The expanded archive included guild and officer chat, say, yell, character whispers, party, raid, instance, custom/community channels, and player emotes. It stored individual message records and some character-profile data.
**Status:** Superseded by the privacy-first activity-counter decision below. The content-recording implementation is not the current design.

## 2026-11-09 — Replace message collection with activity counters
**Decision:** Eldgrim must measure guild-member participation without retaining what members say. Each supported chat or emote event from a current guild member increments an aggregate counter for that member.
**Activity scope:** Guild, officer, say, yell, incoming/outgoing character whispers, party, raid, raid warning, instance, custom channels, community channels, and emotes. Standard and text emotes share one `EMOTE` counter. Outgoing whispers count for the local character; their recipient is not retained.
**Storage rule:** Save only full character name, current/former guild membership, lifetime total and per-type counts, and daily aggregate counts. Do not save message text, individual message records, exact event timestamps, recipients, channel names, or character-profile details.
**Migration:** Convert previous saved message records into aggregate counts by type and day, then discard the message records and profile fields from the new schema.
**Behavior boundary:** Keep the addon silent and local. No UI, slash commands, chat output, notifications, sounds, custom addon messaging, external services, AI, summaries, or interpretation. The built-in FocusMembers roster subscription may cause normal game-client/server traffic.
**Status:** Approved; schema version 3 implementation and mocked tests created; live Forever verification pending.

## Open decisions
- Further details of Eldgrim's public identity and history.
- The precise scope of recurring in-world interactions.
- Whether the local activity metrics will later be used by a separate external tool; this is outside the current addon scope.
- Exact runtime behavior of Forever's guild roster and chat-event APIs on the current client build.
