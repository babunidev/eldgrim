# Eldgrim Addon — Privacy-First Guild Activity Counter

**Status:** Activity-counter scope approved; Lua/TOC implementation created; in-game verification pending.
**Target:** World of Warcraft Forever only.
**Research baseline:** Version 1.60.1, interface 16001; latest public build found on 2026-11-09: 1.60.1.70862.

## 1. Purpose

Measure how active current guild members are in the chat and emote channels visible to the local player, without collecting what they say. Eldgrim is an activity counter, not a conversation archive. These aggregates are intended to be the activity signal for a separate future agent; that agent is outside this addon's scope and must not receive chat content.

## 2. Core rules

- Create a local entry for every current guild member, including members who have not generated any activity.
- Count one activity for each supported player-chat event delivered by the local client when its speaker matches a current guild member.
- Attribute outgoing whispers to the local character if that character is a current guild member. Do not save the recipient.
- Keep counters grouped under the member's full character name.
- Preserve aggregate counts for former members, but do not count new events from them.
- Refresh the roster on initial club load and relevant membership events. Do not poll.
- Save only aggregate activity metrics through account-wide SavedVariables.

## 3. Privacy boundary

The WoW chat event API supplies message text as an event argument. Eldgrim deliberately does not assign, inspect, compare, parse, summarize, or save that argument. The event handler retrieves only the speaker field needed for guild-member matching, plus the community relay marker needed to exclude relayed messages. It increments counters and discards the event call.

Saved data is limited to:
- Character full name as the key in `EldgrimDB.members`.
- `isGuildMember` boolean.
- Lifetime activity total.
- Lifetime counts by activity type.
- Daily aggregate total and counts by activity type.

Never save:
- Message text or individual message records.
- Per-message timestamps or exact event times.
- Whisper recipients or direction.
- Custom/community channel names.
- Message IDs, chat-line IDs, GUIDs, club/member IDs, account/Battle.net/Discord identifiers.
- Guild rank, race, class, level, faction, zone, professions, achievement points, notes, presence, or other character profile data.

The character name is retained because the approved feature requires activity to be attributed to a guild member. No other profile information is needed.

## 4. Activity categories

Each supported event increments exactly one counter:

| Event(s) | Stored activity type |
| --- | --- |
| `CHAT_MSG_GUILD` | `GUILD` |
| `CHAT_MSG_OFFICER` | `OFFICER` |
| `CHAT_MSG_SAY` | `SAY` |
| `CHAT_MSG_YELL` | `YELL` |
| `CHAT_MSG_WHISPER` | `WHISPER_IN` |
| `CHAT_MSG_WHISPER_INFORM` | `WHISPER_OUT` |
| `CHAT_MSG_PARTY`, `CHAT_MSG_PARTY_LEADER` | `PARTY` |
| `CHAT_MSG_RAID`, `CHAT_MSG_RAID_LEADER` | `RAID` |
| `CHAT_MSG_RAID_WARNING` | `RAID_WARNING` |
| `CHAT_MSG_INSTANCE_CHAT`, `CHAT_MSG_INSTANCE_CHAT_LEADER` | `INSTANCE` |
| `CHAT_MSG_CHANNEL` | `CHANNEL` |
| `CHAT_MSG_COMMUNITIES_CHANNEL` | `COMMUNITY` |
| `CHAT_MSG_EMOTE`, `CHAT_MSG_TEXT_EMOTE` | `EMOTE` |

A standard emote and a text emote are combined into one `EMOTE` category. Party/raid/instance leader variants share their respective category.

Only current guild members are counted. A message in General, Trade, party, raid, or another supported channel is counted only if the speaker is a current guild member and the event is delivered to the local client. Eldgrim cannot count conversations that the local client does not receive.

System messages, NPC/creature messages, combat-log and loot notices, Battle.net conversations, addon messages, and Discord-relayed community messages are excluded.

## 5. Guild roster

Use the current guild club returned by `C_Club.GetGuildClubId()`. Verify it is a guild club, call `C_Club.FocusMembers(clubId)` once for that guild, wait until `C_Club.AreMembersReady(clubId)` reports readiness, then enumerate `C_Club.GetClubMembers(clubId)` and read each row with `C_Club.GetMemberInfo(clubId, memberId)`.

Only `memberInfo.name` and `memberInfo.isSelf` are used. Member and club IDs are transient lookup values and are never saved. The built-in roster subscription may use normal game-client/server traffic; it is not custom addon messaging or an external service.

Roster synchronization is event-driven:
- `PLAYER_LOGIN` and `INITIAL_CLUBS_LOADED` initiate roster loading.
- `CLUB_MEMBERS_UPDATED`, `CLUB_ADDED`, and `CLUB_REMOVED` refresh the current guild roster.
- `CLUB_MEMBER_ADDED` and `CLUB_MEMBER_REMOVED` invalidate the in-memory allowlist until the aggregate member update arrives.
- `PLAYER_GUILD_UPDATE` handles the local character joining or leaving a guild.

All restricted roster calls are skipped during chat-messaging lockdown. If a scan is incomplete, unread members are not marked former. The in-memory allowlist contains only names successfully read from the current roster. No roster polling or unrelated roster scanning occurs.

Every current member gets an entry with zeroed counters if necessary. When a member leaves, the existing name and aggregate counts remain and `isGuildMember` becomes `false` after a complete roster scan. New activity from former members is ignored. If they rejoin, the existing counters continue.

## 6. Saved data model

Schema version 3:

```lua
EldgrimDB = {
    schemaVersion = 3,
    members = {
        ["Example Character"] = {
            isGuildMember = true,
            activity = {
                total = 16,
                byType = {
                    GUILD = 4,
                    SAY = 3,
                    YELL = 2,
                    EMOTE = 7,
                },
                byDay = {
                    ["2026-11-09"] = {
                        total = 16,
                        byType = {
                            GUILD = 4,
                            SAY = 3,
                            YELL = 2,
                            EMOTE = 7,
                        },
                    },
                },
            },
        },
    },
}
```

The example is illustrative. The database stores aggregate counts only. `byDay` uses the local calendar date (`YYYY-MM-DD`); if the date helper is unavailable, the fallback key is a UTC epoch-day index. No individual activity event or exact timestamp is retained.

`activity.total` is the lifetime number of counted events. `activity.byType` breaks that total down by channel/activity category. `activity.byDay` provides daily aggregate totals and per-type counts.

## 7. Migration from schema versions 1 and 2

On first load, the new implementation rebuilds the database using a strict field whitelist:
- Existing member names and boolean membership status are retained.
- Existing message records are converted into aggregate counters by their saved channel.
- Existing message timestamps are used only to derive a daily bucket.
- Message text, recipients, individual timestamps, channel names, message IDs, and all character-profile fields are discarded.
- Existing messages without a recognized channel are counted as `GUILD` only when their channel field was absent, matching the original guild-only recorder.

The migration does not copy message text into the new schema. The game writes the sanitized SavedVariables during its normal save lifecycle. Until the first successful save after migration, the old file on disk can still contain the previous message text. Log in with this version and then `/reload` or log out normally to write the new schema.

## 8. Local persistence

Declare account-wide SavedVariables as `EldgrimDB`. The expected file is:

```text
World of Warcraft/_forever_/WTF/Account/<account>/SavedVariables/Eldgrim.lua
```

The game writes SavedVariables during its normal save lifecycle. A crash can lose counters accumulated since the last successful save. The addon cannot append directly to an arbitrary text file.

## 9. Boundaries and verification

The archive remains local to the user's game installation and is not transmitted or shared by the addon. The operator remains responsible for following applicable game, guild, and privacy rules.

API documentation and mocked tests do not prove live event delivery, roster synchronization, member matching, or persistence. Those behaviors require in-game testing on the stated Forever build.
