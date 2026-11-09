# Eldgrim Addon — Guild-Member Conversation Archive Test Plan

**Target:** World of Warcraft Forever only.
**Baseline:** Version 1.60.1, interface 16001.
**Latest public build found:** 1.60.1.70862 (2026-11-07).
**Status:** Local Lua syntax validation and mocked behavior tests passed with texlua. Expanded roster and channel behavior remains unverified in-game. The creative reported that the earlier guild-only recorder worked after a reload; the exact client build and individual checks were not recorded.

## 1. Client and loading
- [ ] Confirm the installed client is World of Warcraft Forever.
- [ ] Record the exact version, build, and interface reported by the running client.
- [ ] Confirm the addon loads with its Forever-only manifest.
- [ ] Confirm account-wide SavedVariables initialize and migrate from the previous schema.

## 2. Guild roster synchronization
- [ ] After initial clubs load, verify `C_Club.FocusMembers` is called once for the current guild and the client loads the member list.
- [ ] Verify `C_Club.FocusMembers` is not called repeatedly for the same guild or while chat-messaging lockdown is active.
- [ ] After initial clubs load, verify every current guild member receives an entry in `EldgrimDB.members`.
- [ ] Verify members with no messages still have an empty `messages` array.
- [ ] Verify full character names, including surnames, are stored and matched.
- [ ] Verify rank, race, class, level, faction, zone, professions, and achievement points when supplied.
- [ ] Verify missing profile fields remain absent rather than guessed.
- [ ] Verify the local character is identified from the roster's `isSelf` field.
- [ ] Verify member additions create entries and member removals mark entries former without deleting history.
- [ ] Verify a member-info update refreshes human-readable fields without replacing message history.
- [ ] Verify an incomplete roster scan does not mark unread members as former.
- [ ] Verify roster updates are event-driven and no polling occurs.

## 3. Supported message capture
- [ ] Guild chat: receive and send; verify one record per message.
- [ ] Officer chat: receive and send; verify one record per message.
- [ ] Say and yell: verify messages from guild members are recorded.
- [ ] Incoming whispers: verify the message is filed under the guild member who sent it.
- [ ] Outgoing whispers: verify the message is filed under the local guild member, with recipient and `OUT` direction.
- [ ] Party and party-leader chat.
- [ ] Raid, raid-leader, and raid-warning chat.
- [ ] Instance and instance-leader chat.
- [ ] Custom channels such as General and Trade; verify the human-readable channel name.
- [ ] Community streams; verify the human-readable stream name.
- [ ] Custom and standard player text emotes.
- [ ] Verify a guild member's message is recorded only when the event is actually delivered to this client.

## 4. Member-only filtering and exclusions
- [ ] Verify messages from non-guild members are ignored in every supported channel.
- [ ] Verify former members' new messages are ignored after a complete roster update.
- [ ] Verify former members' historical messages remain intact.
- [ ] Verify rejoining members become current again and continue their existing history.
- [ ] Verify system messages, NPC/creature messages, combat-log and loot notices, addon messages, Battle.net conversations, and Discord-relay messages are excluded.
- [ ] Verify whispers exchanged between two other players are not captured.
- [ ] Verify say/yell messages outside the client's received range are not captured.

## 5. Name matching and attribution
- [ ] Verify full Forever names match between roster rows and chat-event senders.
- [ ] Verify supported space/hyphen display variants resolve to the same full name.
- [ ] Verify the addon never matches by first name alone.
- [ ] Verify outgoing whisper event payloads are attributed to the local character, not the recipient.
- [ ] Verify guild and officer community-message author/content/club/stream checks reject stale or unrelated records.

## 6. Timestamps and channels
- [ ] Verify matched guild and officer messages use the community-message epoch timestamp.
- [ ] Verify a wrong club, stream, author, or content falls back to local receipt time and does not enrich the profile.
- [ ] Verify all other channels use local receipt time.
- [ ] Verify each message stores a channel label and optional whisper/channel context.
- [ ] Verify repeated identical messages are not deduplicated merely because their text matches.

## 7. Restrictions and failure handling
- [ ] Test while chat-messaging lockdown is active.
- [ ] Verify restricted chat and roster APIs are skipped without Lua errors.
- [ ] Verify no attempt is made to bypass lockdown or inspect secret values.
- [ ] Verify missing APIs, nil member records, partial roster data, missing streams, and unavailable author data fail safely.
- [ ] Verify roster refresh events for initial load, member changes, stream load, guild join, and guild leave.

## 8. Saved data
- [ ] Use `/reload` and verify the archive is written.
- [ ] Log out normally and verify the archive is written.
- [ ] Fully exit and restart the client; verify the archive is restored.
- [ ] Verify all current guild members are present, including those with no messages.
- [ ] Verify old schema messages are preserved and labelled `GUILD` after migration.
- [ ] Verify former members remain in the archive with `isGuildMember = false`.
- [ ] Verify no GUIDs, account identifiers, club/member/message/chat-line IDs, numeric race/class IDs, notes, or presence fields are saved.
- [ ] Confirm a forced client crash can lose unsaved in-memory records.

## 9. Quiet operation
- [ ] Verify there are no visible frames, buttons, menus, or indicators.
- [ ] Verify there are no slash commands, chat messages, notifications, or sounds.
- [ ] Verify there is no custom addon messaging or external service use.
- [ ] Verify the only network-dependent operation is the standard game-client `C_Club.FocusMembers` roster subscription required by the approved roster scan.
- [ ] Verify there is no roster polling or background character inspection.

## 10. Automated checks

Current automated checks:
- [x] Lua syntax validation via `loadfile` in the mock test harness.
- [x] Mocked tests for database migration, roster creation and updates, current/former status, profile updates, member-only filtering, supported channel records, outgoing whisper attribution, guild/officer stream matching, local-time fallback, lockdown, partial roster handling, and exclusion of technical identifiers.
- [ ] Static checks against the current installed Forever API declarations.

Run from the repository root:

```sh
texlua addon/tests/test_recorder.lua addon/Eldgrim/Eldgrim.lua
```

The mock suite is not an in-game test. Do not mark any in-game item complete until it has actually been performed in the stated Forever build.
