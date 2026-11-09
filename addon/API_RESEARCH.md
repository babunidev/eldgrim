# Eldgrim Addon — Forever API Research

**Research date:** 2026-11-09  
**Target:** World of Warcraft Forever 1.60.1  
**Interface:** 16001  
**Latest public build found during this research:** 1.60.1.70862 (2026-11-07)  
**Status:** Privacy-first activity-counter implementation created. Roster and chat event APIs remain subject to in-game verification.

## Current scope

The current implementation counts activity from current guild members. It does not store message content, individual event records, per-message timestamps, channel names, recipients, or character profiles.

The previous conversation-archive implementation and its content-correlation research are superseded. No message-content API is used by the current counter.

## Guild roster APIs

The implementation uses the current guild club only:

- `C_Club.GetGuildClubId()` identifies the player's guild club.
- `C_Club.GetClubInfo(clubId)` verifies that the club type is Guild (value 2).
- `C_Club.FocusMembers(clubId)` starts receiving updates for the guild's member list. The function is declared for Camelot; the wowlua emulator marks its implementation as guessed rather than implemented. The Communities member-list UI uses this call before checking readiness, which is a reference usage pattern rather than proof of Forever runtime behavior.
- `C_Club.AreMembersReady(clubId)` gates roster enumeration.
- `C_Club.GetClubMembers(clubId)` returns opaque member IDs.
- `C_Club.GetMemberInfo(clubId, memberId)` provides the member record. The current implementation reads only `name` and `isSelf`.

The FocusMembers call is the game's built-in roster subscription. It may cause normal client/server traffic to load and update guild member data. It is not custom addon messaging or an external service. The addon calls it once for the current guild and skips it during chat-messaging lockdown.

Sources:
- [C_Club API reference](https://wowlua.dev/api/C_Club)
- [C_Club.GetGuildClubId](https://warcraft.wiki.gg/wiki/API:C_Club.GetGuildClubId)
- [C_Club.GetClubInfo](https://warcraft.wiki.gg/wiki/API:C_Club.GetClubInfo)
- [C_Club.AreMembersReady](https://warcraft.wiki.gg/wiki/API:C_Club.AreMembersReady)
- [C_Club.GetClubMembers](https://warcraft.wiki.gg/wiki/API:C_Club.GetClubMembers)
- [C_Club.GetMemberInfo](https://warcraft.wiki.gg/wiki/API:C_Club.GetMemberInfo)
- [Communities member-list UI reference](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_Communities/CommunitiesMemberList.lua) — reference usage only, not Forever runtime proof.

## Roster events

Roster refresh is event-driven, not polled:

- `PLAYER_LOGIN` and `INITIAL_CLUBS_LOADED` start the initial attempt.
- `CLUB_MEMBERS_UPDATED` refreshes the current roster.
- `CLUB_ADDED` and `CLUB_REMOVED` refresh membership when the affected club is the current guild.
- `CLUB_MEMBER_ADDED` and `CLUB_MEMBER_REMOVED` invalidate the in-memory allowlist; the full scan waits for the aggregate update event.
- `PLAYER_GUILD_UPDATE` handles local guild changes.

The wowlua emulator marks `INITIAL_CLUBS_LOADED` as implemented, but marks several club/member update events as not implemented in its emulated event model. This is an emulator limitation, not proof that the live Forever client does not emit them. All roster event delivery must be verified in-game. If a scan is partial, missing rows are not marked former and unread names fail closed.

Sources:
- [INITIAL_CLUBS_LOADED](https://wowlua.dev/api/events/INITIAL_CLUBS_LOADED)
- [CLUB_MEMBERS_UPDATED](https://wowlua.dev/api/events/CLUB_MEMBERS_UPDATED)
- [CLUB_ADDED](https://wowlua.dev/api/events/CLUB_ADDED)
- [CLUB_MEMBER_ADDED](https://wowlua.dev/api/events/CLUB_MEMBER_ADDED)
- [CLUB_MEMBER_REMOVED](https://wowlua.dev/api/events/CLUB_MEMBER_REMOVED)
- [CLUB_REMOVED](https://wowlua.dev/api/events/CLUB_REMOVED)

## Player-chat events

The implementation registers these player-chat event families and increments one activity category when the speaker matches a current guild member:

| Event(s) | Counter |
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

The message-text argument is not assigned or inspected by the current handler. `select(2, ...)` retrieves the player-name field, and the handler increments a counter. On community events, the 18th argument is checked for a Discord relay marker when that argument is present; relayed messages are excluded. The implementation does not call `C_Club.GetInfoFromLastCommunityChatLine`.

For outgoing whispers, the event's player-name field identifies the recipient. The counter is attributed to the local character identified by the roster's `isSelf` record. The recipient is not saved.

Full character names are matched, with conservative case and space/hyphen display normalization. First-name-only matching is never used. The addon can count only events delivered to the local client's event stream.

Relevant references:
- [CHAT_MSG_GUILD](https://warcraft.wiki.gg/wiki/CHAT_MSG_GUILD)
- [CHAT_MSG_OFFICER](https://wowlua.dev/api/events/CHAT_MSG_OFFICER)
- [CHAT_MSG_SAY](https://wowlua.dev/api/events/CHAT_MSG_SAY)
- [CHAT_MSG_YELL](https://wowlua.dev/api/events/CHAT_MSG_YELL)
- [CHAT_MSG_WHISPER](https://wowlua.dev/api/events/CHAT_MSG_WHISPER)
- [CHAT_MSG_WHISPER_INFORM](https://wowlua.dev/api/events/CHAT_MSG_WHISPER_INFORM)
- [CHAT_MSG_PARTY](https://wowlua.dev/api/events/CHAT_MSG_PARTY)
- [CHAT_MSG_RAID](https://wowlua.dev/api/events/CHAT_MSG_RAID)
- [CHAT_MSG_INSTANCE_CHAT](https://wowlua.dev/api/events/CHAT_MSG_INSTANCE_CHAT)
- [CHAT_MSG_CHANNEL](https://wowlua.dev/api/events/CHAT_MSG_CHANNEL)
- [CHAT_MSG_COMMUNITIES_CHANNEL](https://wowlua.dev/api/events/CHAT_MSG_COMMUNITIES_CHANNEL)
- [CHAT_MSG_EMOTE](https://wowlua.dev/api/events/CHAT_MSG_EMOTE)
- [CHAT_MSG_TEXT_EMOTE](https://wowlua.dev/api/events/CHAT_MSG_TEXT_EMOTE)
- [CHAT_MSG_RAID_WARNING](https://wowlua.dev/api/events/CHAT_MSG_RAID_WARNING)

## Lockdown and persistence

`C_ChatInfo.InChatMessagingLockdown()` is checked before roster or chat-event processing. If the function is unavailable, errors, or reports a restricted state, the addon fails closed and skips the operation.

Account-wide persistence uses `EldgrimDB` through the .toc `SavedVariables` declaration. The expected file is `WTF/Account/<account>/SavedVariables/Eldgrim.lua`. SavedVariables are written by the game during its normal save lifecycle.

The Lua standard `time()` and `date()` helpers are used only to group counts by calendar day. The exact timestamp is not saved. If date derivation is unavailable, the implementation uses a UTC epoch-day bucket key; if time is unavailable, the lifetime counter still increments without a daily bucket.

## APIs intentionally no longer used

The activity counter does not call:
- `C_Club.GetInfoFromLastCommunityChatLine()` — no message content, author profile, message ID, or original message timestamp is needed.
- `C_Club.GetStreams()` — Guild/Officer stream correlation is no longer needed.
- `C_CreatureInfo.GetClassInfo()` — character class is not collected.
- Race/faction/profile mappings — no character profile is collected.

## Verification status

API references and previous research identify the expected API surfaces, but the exact event flow remains unverified in-game. Mock tests cover local counter and migration logic only. They do not prove live roster readiness, chat-event delivery, Discord relay payload position, or SavedVariables persistence on the installed Forever build.
