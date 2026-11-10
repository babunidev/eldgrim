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
**Decision:** Add a dedicated addon workstream under addon/ in this repository. The addon targets World of Warcraft Forever only. Its first milestone is a passive local archive of guild messages and available human-readable information about the characters who send them.
**Recording scope:** Character name, race, class, level, faction, zone, profession names and skill ranks, achievement points when available, plus each guild message and its timestamp.
**Behavior boundary:** No in-game interface, slash commands, chat output, notifications, sounds, addon messaging, network communication, AI, summaries, interpretation, roster scanning, or character inspection in the first milestone. Officer chat and all other channels are excluded.
**Storage boundary:** Use account-wide SavedVariables. Do not persist account identities, GUIDs, club/member/message/chat-line IDs, or other technical identifiers. Any identifier required for a transient lookup must be discarded before saving.
**Status:** Scope approved and documented; implementation and in-game verification not started.

## 2026-11-10 — Eldgrim appears on Discord as the guild bot
**Decision:** Rename the existing Babuni Gaming Discord bot to Eldgrim, move it to an always-online server, and expand it. Eldgrim keeps the current administration capabilities, including rank management and channel creation, and the Character Forge.
**First feature:** Multi-character onboarding. Newcomers receive a gate role automatically, state how many guild characters they have, give each character's name, class, and race, and then gain access to the server.
**Identity:** New name and profile image on Discord. Hosted on the creative's existing server.
**Conversation:** Eldgrim is active once a day and reacts only to messages that mention @Eldgrim. Onboarding, welcomes, administration, and data storage run continuously.
**Further scope:** Store member and character data on the server as the basis of Eldgrim's database, later combined with the addon's in-game data.
**Boundary:** The addon remains a silent local recorder. The bot does not define character canon. Details are tracked in bot/README.md.
**Status:** Direction approved; specification developing; nothing implemented.

## Open decisions
- Further details of Eldgrim's public identity and history.
- The precise scope of recurring in-world interactions.
- How the addon's local archive is transferred to the bot's server; the first addon milestone itself remains local-only.
- Open bot decisions listed in bot/README.md.
- Exact runtime behavior of Forever's chat-event and community-message APIs on the current client build.
