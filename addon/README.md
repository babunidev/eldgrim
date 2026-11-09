# Eldgrim Addon

A separate technical workstream for the Eldgrim World of Warcraft Forever addon.

## Current milestone

**Approved scope:** a passive, local archive of the current guild roster and the player-authored chat messages from guild members.

Eldgrim builds a local entry for every current guild member, then records that member's messages from guild, officer, say, yell, whisper, party, raid, instance, custom-channel, community, and player-emote events supported by the client. The speaker must match a current guild member. Messages are grouped under the member's full character name and include channel and timestamp information.

Roster synchronization uses the game's built-in `C_Club.FocusMembers` member subscription and membership events; there is no polling or custom addon messaging. Former members retain their old archive, but new messages from them are not recorded. The addon can only capture messages delivered to the local character's client.

The addon has no in-game interface, slash commands, chat output, notifications, sounds, custom addon messages, external services, AI, summaries, or interpretation. The built-in roster subscription may use normal game-client/server traffic to load guild member data. System/NPC messages, Battle.net conversations, and Discord-relay messages are excluded.

## Status

**Expanded implementation created; local syntax and mocked behavior checks passed; in-game verification pending.**

The installable addon source is in `Eldgrim/`:
- `Eldgrim/Eldgrim.toc` — Forever manifest and account-wide SavedVariables declaration.
- `Eldgrim/Eldgrim.lua` — passive guild roster synchronizer and member-chat recorder.

A repeatable mocked test is in `tests/test_recorder.lua`. It covers schema migration, roster creation and updates, current/former membership, member-only message filtering, supported chat events, outgoing whisper attribution, timestamps, lockdown, and exclusion of technical identifiers. These tests do not prove that the event sequence works in-game.

## Install for local testing

1. Copy the `Eldgrim/` directory into the Forever client's `Interface/AddOns/` directory.
2. Confirm the resulting paths are `Interface/AddOns/Eldgrim/Eldgrim.toc` and `Interface/AddOns/Eldgrim/Eldgrim.lua`.
3. Enable **Eldgrim** in the AddOns list at the character-selection screen.
4. Log in and allow the guild/club member list to finish loading.
5. Send and receive messages in the supported channels as guild members.
6. Use `/reload` or log out normally, then inspect `WTF/Account/<account>/SavedVariables/Eldgrim.lua` after the client has saved.

The addon intentionally has no commands or visible confirmation. SavedVariables are written by the game during its normal save lifecycle, not immediately to disk after each message. Do not inspect or edit the file while the client is running.

## Documents and tests

- [SPECIFICATION.md](SPECIFICATION.md) — approved behavior, saved fields, and data model.
- [API_RESEARCH.md](API_RESEARCH.md) — Forever-specific API findings, source links, and unresolved behavior.
- [TEST_PLAN.md](TEST_PLAN.md) — required in-game checks before the archive can be considered verified.
- [tests/test_recorder.lua](tests/test_recorder.lua) — repeatable mocked behavior and syntax test.

Run the mock suite from the repository root:

```sh
texlua addon/tests/test_recorder.lua addon/Eldgrim/Eldgrim.lua
```

The mock suite is not an in-game test.

## Compatibility

World of Warcraft Forever only. Manifest interface: 16001. The latest public build found during this research is 1.60.1.70862 (2026-11-07). Recheck the installed client build and API after updates.

The race-name table includes the Forever race IDs. High Order Skyborne ID 95 remains provisional pending confirmation against the installed live client. Unknown race values are omitted.

This addon project is separate from Eldgrim's in-world character canon and from Amberhearth guild administration.
