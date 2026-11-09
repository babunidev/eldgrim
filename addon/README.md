# Eldgrim Addon

A separate technical workstream for the Eldgrim World of Warcraft Forever addon.

## Current milestone

**Approved scope:** a privacy-first local activity counter for the current guild roster.

Eldgrim creates an entry for every current guild member and counts the player's chat activity when the local Forever client delivers a supported chat event. It records aggregate counts by activity type and calendar day. It does not record message text, individual message records, recipients, channel names, or exact event timestamps.

Activity categories:
- Guild and officer chat.
- Say and yell.
- Incoming and outgoing character whispers.
- Party, raid, raid warning, and instance chat.
- Custom chat channels and community channels.
- Player emotes (standard and text emotes are combined as `EMOTE`).

Only current guild members are counted. Outgoing whispers are attributed to the local character; the recipient is not saved. Messages relayed from Discord are excluded. The addon can only count events delivered to the local character's client.

The roster is synchronized through the game's built-in `C_Club.FocusMembers` subscription and membership events. This may use normal game-client/server traffic to load guild member data. Eldgrim sends no custom addon messages and does not poll.

## Privacy boundary

SavedVariables contain only:
- The character's full name as the member key.
- Current/former guild membership status.
- Lifetime activity total and counts by activity type.
- Daily aggregate totals and counts by activity type.

The addon does not save message content, per-message timestamps, message/line IDs, whisper recipients, channel names, guild rank, race, class, level, faction, zone, professions, achievements, notes, presence, account identifiers, or GUIDs.

The WoW chat event API supplies message text as an event argument. Eldgrim deliberately does not assign or inspect that argument; it uses the speaker field only to match the current guild roster and increment a counter. No message-content API is called.

## Status

**Implementation created; local Lua syntax and mocked behavior checks passed; in-game verification pending.**

Installable addon source:
- `Eldgrim/Eldgrim.toc` — Forever manifest and account-wide SavedVariables declaration.
- `Eldgrim/Eldgrim.lua` — guild roster synchronizer and privacy-first activity counter.

Mock tests:
- `tests/test_recorder.lua` — schema migration, roster creation/updates, channel counters, member-only filtering, lockdown, and proof that message text/profile fields are not retained.

Run from the repository root:

```sh
texlua addon/tests/test_recorder.lua addon/Eldgrim/Eldgrim.lua
```

Mock tests do not prove live in-game behavior.

## Install for local testing

1. Copy the `Eldgrim/` directory into the Forever client's `Interface/AddOns/` directory.
2. Confirm the resulting paths are `Interface/AddOns/Eldgrim/Eldgrim.toc` and `Interface/AddOns/Eldgrim/Eldgrim.lua`.
3. Enable **Eldgrim** in the AddOns list at the character-selection screen.
4. Log in and allow the guild/club member list to finish loading.
5. Let guild members use the supported chat channels.
6. Use `/reload` or log out normally, then inspect `WTF/Account/<account>/SavedVariables/Eldgrim.lua` after the client has saved and closed.

### Migrating from the previous message archive

The new schema converts existing message records into aggregate counts, using any existing timestamps only to assign a calendar-day bucket. It then discards the message records and all saved character-profile fields. No message text is copied into the new database.

The game writes SavedVariables during its normal save lifecycle, not immediately. After installing this version, log in once and then `/reload` or log out normally so the migrated database is written. Until that save occurs, the existing file on disk can still contain the previous message text. Do not inspect or edit SavedVariables while the client is running.

## Data location

The account-wide SavedVariables file is:

```text
World of Warcraft/_forever_/WTF/Account/<account>/SavedVariables/Eldgrim.lua
```

The game owns the save lifecycle. A crash can lose counters accumulated since the last successful save.

## Documents

- [SPECIFICATION.md](SPECIFICATION.md) — approved behavior and data model.
- [API_RESEARCH.md](API_RESEARCH.md) — Forever API findings and unresolved runtime behavior.
- [TEST_PLAN.md](TEST_PLAN.md) — required in-game checks.
- [tests/test_recorder.lua](tests/test_recorder.lua) — automated mock tests.

## Compatibility

World of Warcraft Forever only. Manifest version: 0.3.0-alpha; interface: 16001. The current research baseline is build 1.60.1.70862 (2026-11-07); recheck the installed client build after game updates.

This addon project is separate from Eldgrim's in-world character canon and Amberhearth guild administration.
