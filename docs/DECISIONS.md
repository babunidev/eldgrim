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
**Status:** Original scope superseded by the expanded decision below; retained as development history.

## 2026-11-09 — Expand Eldgrim into a guild-member conversation archive
**Decision:** Expand the addon to build a local entry for every current guild member and record that member's player-authored messages across supported in-game chat channels, including guild and officer chat, say, yell, character whispers, party, raid, instance, custom/community channels, and player emotes.
**Membership rule:** Only messages whose speaker matches the current guild roster are recorded. Outgoing whispers are attributed to the local character when that character is a current guild member; the recipient is stored separately.
**Roster rule:** Read the guild roster through Forever's C_Club APIs on initial load and relevant membership events. Call the built-in C_Club.FocusMembers subscription once for the current guild, then wait for member-list readiness. Do not poll or scan unrelated characters. Create entries for members with no messages. Preserve former members' existing history and mark them as former after a complete roster scan; do not record new messages from them.
**Storage rule:** Migrate the old archive to schema version 2 under EldgrimDB.members, preserve existing messages, and continue to exclude technical identifiers, account data, notes, and presence information.
**Behavior boundary:** The addon remains silent and passive. No UI, slash commands, chat output, notifications, sounds, custom addon messaging, external services, AI, summaries, or interpretation. The standard FocusMembers subscription may cause normal game-client/server roster traffic; it is not custom addon messaging.
**Status:** Scope approved; implementation and mocked checks created; live Forever verification pending.

## Open decisions
- Further details of Eldgrim's public identity and history.
- The precise scope of recurring in-world interactions.
- Whether the local archive will later be used by a separate external tool; this is outside the current addon scope.
- Exact runtime behavior of Forever's chat-event and community-message APIs on the current client build.
