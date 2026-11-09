# Eldgrim Addon — Privacy-First Activity Counter Test Plan

**Target:** World of Warcraft Forever only.
**Baseline:** Version 1.60.1, interface 16001.
**Latest public build found during research:** 1.60.1.70862 (2026-11-07).
**Status:** Local Lua syntax validation and mocked behavior tests passed with texlua. Live roster synchronization, chat-event delivery, and SavedVariables persistence remain unverified in-game.

## 1. Client and loading
- [ ] Confirm the installed client is World of Warcraft Forever.
- [ ] Record the exact version, build, and interface reported by the running client.
- [ ] Confirm the addon loads with its Forever-only manifest.
- [ ] Confirm account-wide SavedVariables initialize and migrate to schema version 3.

## 2. Guild roster
- [ ] Verify the current guild roster loads after initial clubs are ready.
- [ ] Verify `C_Club.FocusMembers` is called once for the current guild, not repeatedly.
- [ ] Verify every current guild member gets an entry, including members with zero activity.
- [ ] Verify only the full character name and membership status are saved from roster data.
- [ ] Verify member additions, removals, rejoining, guild changes, and incomplete roster responses.
- [ ] Verify former members retain aggregate counters but receive no new counters.
- [ ] Verify the roster is event-driven and no polling occurs.
- [ ] Verify no calls are made during chat-messaging lockdown.

## 3. Activity event counting
- [ ] Guild chat: incoming and local player's own message.
- [ ] Officer chat: incoming and local player's own message.
- [ ] Say and yell.
- [ ] Incoming character whispers.
- [ ] Outgoing character whispers: attribute the count to the local guild member, without storing the recipient.
- [ ] Party and party-leader chat.
- [ ] Raid, raid-leader, and raid-warning chat.
- [ ] Instance and instance-leader chat.
- [ ] Custom channels such as General and Trade.
- [ ] Community channels; verify Discord-relayed events are excluded.
- [ ] Standard and text emotes; both increment `EMOTE`.
- [ ] Verify each delivered event increments exactly one lifetime counter and one daily counter.
- [ ] Verify non-guild members are ignored in every supported channel.
- [ ] Verify activity not delivered to the local client is not counted.

## 4. Privacy and data minimization
- [ ] Inspect SavedVariables after a normal save and confirm no message text is present.
- [ ] Confirm no individual message records or per-message timestamps exist.
- [ ] Confirm no whisper recipient, direction, channel name, message ID, or chat-line ID is saved.
- [ ] Confirm no race, class, level, faction, zone, profession, achievement, rank, notes, presence, GUID, account, or member/club IDs are saved.
- [ ] Confirm the code does not call `C_Club.GetInfoFromLastCommunityChatLine`.
- [ ] Confirm the event handler does not assign or inspect the message-text argument.
- [ ] Confirm no Discord-relayed community message is counted.
- [ ] Confirm no custom addon messages, external services, UI, slash commands, chat output, sounds, or notifications exist.

## 5. Migration and persistence
- [ ] Load an existing schema-1 or schema-2 SavedVariables file.
- [ ] Verify old message records become aggregate counters by activity type.
- [ ] Verify old timestamps are used only to create daily buckets.
- [ ] Verify old message text and all profile fields disappear from the in-memory schema.
- [ ] Use `/reload` or log out normally, then inspect the SavedVariables file with the client closed.
- [ ] Restart the client and verify schema version 3 and aggregate counters are restored.
- [ ] Confirm the on-disk file is not considered sanitized until the first successful save after migration.
- [ ] Confirm a forced client crash can lose counters accumulated since the last save.

## 6. Restrictions and failure handling
- [ ] Test while chat-messaging lockdown is active.
- [ ] Verify restricted roster/chat operations are skipped without Lua errors.
- [ ] Verify missing APIs, nil member records, partial roster data, and unavailable date/time helpers fail safely.
- [ ] Verify lifetime counters still increment if daily date derivation is unavailable.
- [ ] Verify no attempt is made to bypass lockdown or inspect secret values.

## 7. Automated checks
Current automated checks:
- [x] Lua syntax validation via `loadfile` in the mock test harness.
- [x] Mocked tests for roster loading, current/former membership, rejoining, partial scans, all supported activity categories, outgoing whisper attribution, Discord relay exclusion, migration, and data minimization.
- [ ] Static checks against the current installed Forever API declarations.

Run from the repository root:

```sh
texlua addon/tests/test_recorder.lua addon/Eldgrim/Eldgrim.lua
```

Mock tests are not in-game tests. Do not mark any in-game item complete until it has actually been performed in the stated Forever build.
