# Eldgrim Addon — Guild-Member Conversation Archive

**Status:** Expanded scope approved; Lua/TOC implementation created; in-game verification pending.
**Target:** World of Warcraft Forever only.
**Research baseline:** Version 1.60.1, interface 16001; latest public build found on 2026-11-09: 1.60.1.70862.

## 1. Purpose

Create a quiet, local archive of the current guild roster and the player-authored conversations from guild members that the local game client receives or sends. The addon records; it does not interpret, summarize, answer, or otherwise use the collected data inside the game.

## 2. Runtime behavior

- Load automatically with the character.
- Read the current guild roster through Forever's `C_Club` APIs.
- Create a local entry for every current guild member, including members who have not sent a recorded message.
- Listen to supported player-chat events and record a message only when its speaker matches a current guild member.
- Store each message under the speaker's full character name.
- Refresh the roster on initial club load and relevant membership-change events. Do not poll or repeatedly scan in the background.
- Keep the archive local through account-wide SavedVariables.

The addon remains silent and invisible in-game:
- No windows, frames intended for display, buttons, menus, or visual indicators.
- No slash commands.
- No chat messages or system output.
- No notifications or sounds.
- No addon messages or external services. The only roster request is the game's built-in `C_Club.FocusMembers(clubId)` subscription needed to load and track the current guild roster; it may cause normal game-client/server roster traffic.
- No AI, summaries, interpretation, or responses.

## 3. Message channels

Record player-authored messages delivered to the local client from current guild members in these supported event families:

- Guild and officer chat.
- Say and yell.
- Incoming and outgoing character whispers.
- Party and party-leader chat.
- Raid, raid-leader, and raid-warning chat.
- Instance and instance-leader chat.
- Custom chat channels, including channels such as General and Trade.
- Community chat streams.
- Custom and standard player text emotes.

The event list is explicit in the Lua source. A message is not recorded merely because its channel is enabled: the speaker must resolve to a current guild-member entry.

For an outgoing whisper, Forever reports the recipient in the event's player-name field. Eldgrim therefore attributes the message to the local character identified by the roster's `isSelf` member record and stores the recipient separately.

The addon can only record messages delivered to this character's client. It cannot capture conversations happening elsewhere, such as whispers exchanged between two other players or say/yell messages outside the client's received range.

Excluded sources include system messages, NPC/creature messages, combat-log and loot notices, addon messages, Battle.net whispers/conversations, and Discord-relay messages. Officer chat is included.

## 4. Guild roster and membership

Use the current guild club returned by `C_Club.GetGuildClubId()`. Verify that it is a guild club, call `C_Club.FocusMembers(clubId)` once to subscribe the game client to that guild's member updates, wait until `C_Club.AreMembersReady(clubId)` reports readiness, then enumerate `C_Club.GetClubMembers(clubId)` and read each row with `C_Club.GetMemberInfo(clubId, memberId)`. This uses the game's built-in roster subscription; it is not custom addon messaging or an external service.

Only the member's human-readable character name and approved character-facing fields are saved. Member IDs, club IDs, GUIDs, account IDs, notes, presence, and other technical or private fields are transient or ignored.

Roster synchronization is event-driven:
- Initial clubs load.
- Guild member-list updates and member add/remove events.
- The local character joining or leaving a guild.
- Club stream load, for refreshing the Guild and Officer stream mapping.
- A targeted member-info update may refresh that member's human-readable profile.

No roster polling is used. All restricted roster calls are skipped while chat-messaging lockdown is active. If the roster scan is incomplete, known rows may be refreshed, but missing rows are not marked as former members.

Every current member gets an entry with a `messages` array, even when it is empty. When a member leaves, their previous record and messages remain in the archive and `isGuildMember` becomes `false` after a complete roster scan. New messages from former members are not recorded. If they rejoin, their entry becomes current again.

## 5. Character information

Store only human-readable values supplied by the guild member record or a safely matched guild/officer community-message author:

- Full character name — used as the member key.
- Current guild-member status.
- Guild rank name.
- Race.
- Class.
- Level.
- Faction.
- Zone.
- Profession names and skill ranks.
- Achievement points.

Fields are optional. Missing information stays absent; it is never guessed. Do not match on first name alone. Full Forever character names are used, with conservative case and space/hyphen display normalization.

## 6. Message records and timestamps

Each message record contains:
- Timestamp in Unix seconds.
- Channel label.
- Message text.

Optional context fields:
- `direction = "IN"` or `"OUT"` for whispers.
- `recipient` for outgoing whispers.
- `channelName` for custom and community channels.

For guild and officer messages only, `C_Club.GetInfoFromLastCommunityChatLine()` may provide the original timestamp and author profile. Eldgrim accepts that data only when the returned club is the current guild, the stream matches the event's Guild or Officer stream, and the author and content match the event being handled. Otherwise, it uses local receipt time and the roster profile.

For other chat events, use local receipt time. It is not described as the sender's exact send time.

## 7. Saved data model

The account-wide database uses schema version 2:

    EldgrimDB = {
        schemaVersion = 2,
        members = {
            ["Example Character"] = {
                isGuildMember = true,
                guildRank = "Member",
                race = "Dwarf",
                class = "Warrior",
                level = 60,
                faction = "Alliance",
                zone = "Ironforge",
                professions = {
                    { name = "Mining", skill = 300 },
                    { name = "Blacksmithing", skill = 300 },
                },
                achievementPoints = 123,
                messages = {
                    {
                        timestamp = 1794168000,
                        channel = "GUILD",
                        message = "Meet at the fire after sunset.",
                    },
                    {
                        timestamp = 1794168060,
                        channel = "WHISPER",
                        direction = "OUT",
                        recipient = "Another Character",
                        message = "I will be there shortly.",
                    },
                },
            },
        },
    }

The example is illustrative, not a real character record. All current roster members are represented, even when their `messages` array is empty. Former-member entries are retained with `isGuildMember = false`.

The previous name-keyed database is migrated in memory without discarding messages. Existing messages are labelled `GUILD`, because the previous version listened only to `CHAT_MSG_GUILD`.

Do not save:
- Character GUIDs.
- Class or race numeric IDs.
- Guild club IDs or member IDs.
- Message IDs or chat line IDs.
- Battle.net, account, or Discord identifiers.
- Public or officer notes.
- Presence flags, mobile status, or other unapproved chat metadata.

## 8. Local persistence

Declare account-wide SavedVariables as `EldgrimDB`. The expected file is:

    World of Warcraft/_forever_/WTF/Account/<account>/SavedVariables/Eldgrim.lua

The game writes SavedVariables during its normal save lifecycle, including `/reload` and logout/exit. The addon cannot append directly to an arbitrary text file. A crash can lose messages collected since the last successful save.

## 9. Boundaries and verification

The archive remains local to the user's game installation and is not transmitted or shared by the addon. The operator remains responsible for following applicable game, guild, and privacy rules.

API documentation and mocked tests do not prove live event delivery, roster synchronization, whisper direction, name matching, or persistence. Those behaviors require in-game testing on the stated Forever build. Any broader automation or external use requires a separate scope decision.
