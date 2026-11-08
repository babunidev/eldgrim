# Eldgrim Addon — First-Milestone Specification

**Status:** Approved scope; implementation not started.  
**Target:** World of Warcraft Forever only.  
**Research baseline:** Version 1.60.1, interface 16001; latest public build found during research: 1.60.1.70862.

## 1. Purpose

Create a quiet, local archive of guild conversations and the characters who participate in them. The first milestone is a recorder only. It does not interpret, summarize, answer, or otherwise use the collected data inside the game.

## 2. Runtime behavior

- Load automatically with the character.
- Listen only to CHAT_MSG_GUILD.
- Record guild messages sent and received when their payload is accessible.
- Associate each message with the speaking character's name.
- Enrich that character's profile with character information supplied by Forever's guild/community APIs when it can be reliably associated with the same message.
- Save the archive locally through account-wide SavedVariables.

The addon must remain silent and invisible in-game:
- No windows, frames intended for display, buttons, menus, or visual indicators.
- No slash commands.
- No chat messages or system output.
- No notifications or sounds.
- No addon messages, network communication, or external services.
- No AI, summaries, interpretation, or responses.

Officer chat and every channel other than guild chat are excluded.

## 3. Character information

Use only information that Forever actually supplies for the speaking character. Store human-readable values when available:

- Character name — used as the profile key.
- Race.
- Class.
- Level.
- Faction.
- Current or reported zone.
- Profession names and skill ranks.
- Achievement points.

These fields are optional. Missing information stays absent; it is never guessed or filled from unrelated data. Update the character's current profile snapshot when newer information is available. The message history remains append-only.

The first milestone does not request character inspection, scan the entire guild roster, or poll for updates. It uses the author information associated with a guild message and, only if needed and verified, a targeted member-info lookup.

## 4. Message records

Each recorded message contains only:
- Timestamp.
- Message text.

Messages are grouped under the speaking character's name and kept in chronological order. When the matched Forever community-message record supplies its epoch timestamp, convert its microseconds to Unix seconds before saving. Otherwise use the local receipt time and treat it as a receipt timestamp, not the sender's exact send time.

## 5. Compact local data model

The character name is the human-readable key. No technical identifier is required in the saved structure.

    EldgrimDB = {
        ["Example Character"] = {
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
                    message = "Meet at the fire after sunset.",
                },
            },
        },
    }

The example is illustrative, not a real character record. Profile fields that are unavailable are omitted. Profession entries contain names and skill ranks, not profession IDs.

Do not save:
- Character GUIDs.
- Class or race numeric IDs.
- Guild club IDs or member IDs.
- Message IDs or chat line IDs.
- Battle.net, account, or Discord identifiers.
- Member notes, officer notes, or account-level metadata.
- Presence flags, mobile status, or other chat metadata not approved above.

An identifier may be used temporarily to correlate an API result or make a targeted lookup, but it must not be written to SavedVariables.

## 6. Forever API handling

The intended event is CHAT_MSG_GUILD. Its payload supplies the message text and sender name, but it does not itself provide the full character profile or an original message timestamp.

C_Club.GetInfoFromLastCommunityChatLine() is the documented candidate for obtaining the last community message, its author record, and its timestamp. Before using its author data, the implementation must verify that the returned record is a guild message and that its content and author correspond to the event currently being handled. Never attach details from an unrelated last chat line.

If the community record is missing, incomplete, restricted, or cannot be matched safely, record only the event's accessible sender name, message, and local receipt timestamp.

When C_ChatInfo.InChatMessagingLockdown() reports that chat restrictions are active, or when the event payload is inaccessible, skip the affected record safely. Do not attempt to bypass the restriction.

See [API_RESEARCH.md](API_RESEARCH.md) for field details and evidence status.

## 7. Local persistence

Declare the account-wide SavedVariables database as EldgrimDB. The expected file is:

    World of Warcraft/_forever_/WTF/Account/<account>/SavedVariables/Eldgrim.lua

The game writes SavedVariables during its normal save lifecycle, including /reload and logout/exit. The addon cannot append directly to an arbitrary .txt file. The local archive is therefore the game's SavedVariables .lua file. A future text export or external file writer would be a separate project and is not part of this milestone.

A crash can lose messages collected since the last successful save. Persistence across reload, logout, and a full client restart must be tested in the current Forever build.

## 8. Boundaries

The archive is local to the user's game installation. The addon does not transmit it or share it with other players. Quiet in-game behavior does not remove the operator's responsibility to follow applicable game, guild, and privacy rules.

No broader helper behavior is approved by this specification. Any expansion requires an explicit scope decision.
