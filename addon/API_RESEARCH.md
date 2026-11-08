# Eldgrim Addon — Forever API Research

**Research date:** 2026-11-08  
**Target:** World of Warcraft Forever 1.60.1  
**Interface:** 16001  
**Latest public build found during this research:** 1.60.1.70862 (2026-11-07)  
**Status:** API surface documented; intended event-to-author correlation and all addon behavior still require in-game verification.

## 1. Evidence and version discipline

Forever's current public client build found during research is 1.60.1.70862. A browsable API reference generated from the client's own APIDocumentation is available, but its published capture is build 70170 from 2026-10-01. The individual API pages below identify Forever 1.60.1 support where stated. The older generated dump is useful for signatures, not proof that the latest build behaves identically.

Do not infer behavior from Retail or another WoW client. Recheck the live client build and relevant API documentation before implementation or after a client update.

## 2. Guild chat event

**API-documented for Forever:** CHAT_MSG_GUILD fires when a message is sent or received in the guild channel. Its payload includes the message text and sender name, along with additional metadata.

The event documentation marks it as restricted during chat-messaging lockdown. The event itself does not supply the full character profile or a message timestamp.

Only the text and sender name are needed for the archive. Other event values, including chat line IDs and GUIDs, must not be saved.

Source: [CHAT_MSG_GUILD — Warcraft Wiki](https://warcraft.wiki.gg/wiki/CHAT_MSG_GUILD)

## 3. Community message and author information

**API-documented for Forever 1.60.1:** C_Club.GetInfoFromLastCommunityChatLine() returns a message record, club ID, stream ID, and club type. The message record contains:
- Message content.
- An author record.
- A message identifier whose epoch field is the number of microseconds since the Unix epoch.

The author record can contain:
- Character name.
- Class ID.
- Race value.
- Level.
- Zone.
- Achievement points.
- Two profession names and skill ranks.
- Faction.
- Other guild, presence, account, and identifier fields that Eldgrim must ignore.

The function may return nothing, requires clubs to be initialized, and is restricted during chat-messaging lockdown. The club-type enum identifies Guild as one of its values.

**Important inference requiring an in-game test:** The function describes the last community chat line, but the recorder must prove that the returned line is the same message that triggered the current CHAT_MSG_GUILD event. The implementation must check that the club type is Guild and safely match the author and content before attaching profile information or using the original timestamp. If the match cannot be established, keep the event data and use local receipt time only.

Source: [C_Club.GetInfoFromLastCommunityChatLine — Warcraft Wiki](https://warcraft.wiki.gg/wiki/API:C_Club.GetInfoFromLastCommunityChatLine)

## 4. Targeted member information

**API-documented for Forever 1.60.1:** C_Club.GetMemberInfo(clubId, memberId) returns a ClubMemberInfo record. It exposes the same useful character fields as the author record and has the same relevant initialization and chat-lockdown restrictions.

This is a possible targeted fallback only when the matched author record provides a member reference but omits a useful field. It is not permission to scan the guild roster. The lookup must be tested before use. Its input identifiers are transient and must never be saved.

Source: [C_Club.GetMemberInfo — Warcraft Wiki](https://warcraft.wiki.gg/wiki/API:C_Club.GetMemberInfo)

## 5. Class names

**API-documented for Forever 1.60.1:** C_CreatureInfo.GetClassInfo(classID) returns class information including a localized class name and a locale-independent class token. The archive needs only the human-readable class name.

The Forever class roster contains exactly nine classes:
- Warrior
- Paladin
- Hunter
- Rogue
- Priest
- Shaman
- Mage
- Warlock
- Druid

Do not include classes from later expansions. Do not persist the numeric class ID.

Source: [C_CreatureInfo.GetClassInfo — Warcraft Wiki](https://warcraft.wiki.gg/wiki/API:C_CreatureInfo.GetClassInfo)

## 6. Race names

Forever's playable choices are the eight original races — Human, Dwarf, Night Elf, Gnome, Orc, Undead, Tauren, and Troll — plus Skyborne, which can join either faction. The client data distinguishes the Alliance High Order Skyborne and Horde Windshaper Skyborne entries. Treat those faction-specific names accurately; do not add later-expansion races.

The community-member author record supplies a numeric race value. The API page for C_CreatureInfo.GetRaceInfo does not list Forever 1.60.1 support, so do not assume that function is available. Before implementation, verify the current Forever race records and build a finite mapping for only the Forever choices. Convert the value to a human-readable name and discard the numeric value. Never save it.

Sources:
- [Forever race and class data — WoW Forever](https://wow-forever.gg/races/)
- [Meet the New Skyborne — Blizzard](https://worldofwarcraft.blizzard.com/en-us/news/24302071)
- [C_CreatureInfo.GetRaceInfo — Warcraft Wiki](https://warcraft.wiki.gg/wiki/API:C_CreatureInfo.GetRaceInfo)

## 7. Chat-messaging lockdown

**API-documented for Forever 1.60.1:** C_ChatInfo.InChatMessagingLockdown() returns whether chat-messaging security restrictions are active. CHAT_MSG_GUILD and the relevant community APIs are marked as restricted in that state.

The recorder must skip inaccessible values safely. It must not try to extract, compare, stringify, or otherwise work around protected chat data while restrictions are active.

Sources:
- [C_ChatInfo.InChatMessagingLockdown — Warcraft Wiki](https://warcraft.wiki.gg/wiki/API:C_ChatInfo.InChatMessagingLockdown)
- [CHAT_MSG_GUILD — Warcraft Wiki](https://warcraft.wiki.gg/wiki/CHAT_MSG_GUILD)

## 8. SavedVariables and local file behavior

Use the addon's account-wide SavedVariables declaration for EldgrimDB. The expected file is Eldgrim.lua under the Forever installation's account SavedVariables directory. This is a normal game-managed Lua data file, not an arbitrary text file the addon opens or appends to.

A SavedVariables loading issue was reported in early Forever beta builds. Later Forever addon-maintenance notes report that the client restores SavedVariables on builds 70009 and later. The current research target, 70862, is newer, but reload, logout, and cold-start persistence must still be tested in-game.

Sources:
- [Forever SavedVariables fix — ForeverSVFix](https://github.com/nobewayo/ForeverSVFix)
- [Dynamic Ambiance Forever — SavedVariables notes](https://github.com/imperial64/dynamic-ambiance-forever)
- [Forever addon installation and SavedVariables location](https://forevermastery.com/en/guides/install-addons)

## 9. Confirmed, inferred, and unverified summary

| Item | Evidence status |
| --- | --- |
| CHAT_MSG_GUILD exists and reports sent/received guild messages | API-documented for Forever |
| C_Club.GetInfoFromLastCommunityChatLine exists and returns message/author information | API-documented for Forever |
| Author record includes race, class, level, zone, professions, faction, and achievement points | API-documented for Forever |
| C_CreatureInfo.GetClassInfo provides a class name | API-documented for Forever |
| C_ChatInfo.InChatMessagingLockdown reports chat restrictions | API-documented for Forever |
| Last community line always matches the current guild event | Inferred; must be tested |
| Every author field is populated for every guild member | Unverified |
| Race-name lookup method and values on build 70862 | Must be verified against the current client |
| SavedVariables reload and cold-start behavior on the user's current build | Must be tested in-game |

No API calls have been tested in-game for this project. No addon code exists yet.
