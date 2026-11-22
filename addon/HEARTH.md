# Eldgrim hearth board

**Status:** Implemented in `Eldgrim/`. Mock tests passed. Not tested in World of Warcraft Forever.  
**Version:** 0.5.0-alpha.  
**Client:** Forever 1.60.1, interface 16001. The build used for a future in-game test still has to be recorded.

The weekly ember is written on the master's machine. Only **Jasmine Amberbrew** may publish it, and only when `CHAT_MSG_ADDON` reports her as the sender. A name written inside the payload is ignored. Other clients may show the last ember they saved. They never send that copy on.

`/eldgrim` still whispers the guild invitation. `/eldgrim log` opens the board only when the text after the command is exactly `log`. The guild panel's flame opens it too. The addon does not announce that chat is collected.

## The ember file

`EldgrimEmbers.lua` ships with `revision = 0` and empty `current` and `next`. On Jasmine Amberbrew's machine, fill those two cards and raise `revision` by one each time the text changes. Each card has `id`, `starts` (unix time), `title`, `story`, and `hint`. `story` is the card text. `hint` is only the question-mark tooltip. The card's name is **Eldgrim's Ember**.

Week boundaries use `GetServerTime()`. Sunday is 00:00 UTC. The current ember ends at the first Sunday 00:00 UTC strictly after `starts`. At that moment `next` becomes `current`, even if `next.starts` says something else. If the current ember has ended and there is no next, the card stays up, with its completed-by list, and says the next ember has not arrived. Saved history keeps the last 4 weeks. There is no ember score.

An alt of the same account is not the master. Logging in on an alt publishes nothing and does not take the relay.

A roster update that shows a changed rank or a new member is saved at once, without waiting for the daily refresh; a shorter list still waits for the daily refresh, so a partly loaded roster removes nobody (2026-11-22).

In Forever, `UnitName("player")` returned only the first name ("Jasmine") on 20 November 2026, while guild chat and `GetGuildRosterInfo` use "First Surname" (**in-game observed**: the saved roster and a test quest). The sync takes this client's full name from its own roster entry, matched by `UnitGUID("player")` against the roster's GUID, or else from the only roster name that starts with the first name and a space. The GUID is compared and dropped, never saved. Until the roster arrives the master's duties wait; a `GUILD_ROSTER_UPDATE` starts them and sends one more hello. **Unverified:** that the roster's 17th value is the GUID in Forever, and that `CHAT_MSG_ADDON` names the sender "Jasmine Amberbrew".

## Sync

`EldgrimSync.lua` registers the prefix `ELDGRIM`. Payloads are plain text: a version digit and a short checksum. No cipher. A send queue paces guild and whisper traffic at about four messages a second. That pace is a stand-in until the live cap is measured.

Hello, the ember, and member-quest records travel on `GUILD`. Held guild-chat lines travel by addon whisper.

- A hello carries the ember revision, a record count, and a hash of the sorted quest ids, plus the ids themselves. It is not the ember.
- Jasmine Amberbrew counts as online only after her hello in this session, and as offline when this client's guild roster shows her offline. The guild line "has gone offline" is not used.
- While she is online, her client answers every hello. If her revision is newer, the answer includes the ember card, `online since`, and the revision. A peer's records do not cancel that answer. Peers never send the ember.
- While she is offline, one peer may answer a hello about member-quest records after a random wait of 5 to 20 seconds, and cancels that answer if another peer answers first. The answer contains only records whose ids the asker does not already have.
- A passed-on record stays unconfirmed until a later message arrives whose reported sender is the person acting. It does not settle a quest.
- Long text is split as a message id plus part and total. An unfinished set is dropped after 60 seconds.
- The 255-byte cap, the live rate limit, whispers to a two-part name with no realm, and whether a payload keeps `#` are still unchecked on 1.60.1.

## Guild chat relay

Guild chat only. While the master is offline, a member addon holds new guild lines. Her hello includes `online since`. Members drop held lines received after that time, then whisper a summary: how many lines, and the time range. She asks the online member whose oldest line is the oldest, then the next. Lines go by addon whisper. The ack names the batch. The sender deletes exactly that batch. No ack means the lines stay and are tried again at the next hello.

She accepts a relayed line only when the passer and the named speaker are both on her current guild roster. The saved line records who passed it on. The same line from two or more members, matched by speaker, text, and receive times within 10 seconds, is kept as guild chat. A line from only one member is stored with `passedBy` and does not back a keyword or a standing change. Held lines older than 7 days are deleted without an ack.

On the master, delivered lines stay in `EldgrimDB`. SavedVariables are written at logout or `/reload`. If she crashes after the ack, the member has deleted the batch and her client never writes it. Those lines are gone. That loss is accepted.

## Member quests

Any addon user can create one: title (60), story (400), and objective (200). A quest has no end date: it stays until its creator deletes it, which the creator may do at any time (decided by the creator on 20 November 2026). At most 3 quests per creator. The creator cannot accept their own quest.

A member quest has no proof to choose (decided by the creator on 20 November 2026). Whoever takes it marks it complete when it is done. Then the creator confirms, and it is completed.

- An accept (`A`) counts when the sender is the one who accepts.
- **Mark complete** (`C`) counts when the sender is the one who took the quest, after accepting it. The button then reads **Waiting for** the creator.
- **Confirm** (`F`) counts when the sender is the creator, for someone who marked it complete. Only the creator sees that button. A confirmation passed on by anyone else stays unconfirmed.
- A deletion counts when the sender is the creator, or an officer deleting as themselves. Rank index 0 is the only invite rank on the list; `GuildControlGetRankFlags` is not the check.

Quest ids use `#` between the creator's name and the timestamp. A character can complete a given member quest once. The button reads **Accept**, then **Mark complete**, then **Waiting for** the creator, then **Completed**.

Once a quest is completed for a character, it leaves that character's list. It stays for everyone else, and for its creator. Member quests give no standing, and nothing about them is kept once the creator deletes them. There is no history. A quest saved in the older format, with a witness, officer, screenshot or Discord proof, is removed.

## The weekly ember is completed in Discord

Nobody completes the ember on the board, and the board has no button for it (decided by the creator on 20 November 2026). The proof is the same as for an Eldgrim quest:

1. The member posts a screenshot in the Eldgrim channel that mentions @Eldgrim and says **ember**.
2. The proof is for the member's one character. A member who still has several from before the one-character Forge is asked which in a private thread.
3. Another member with the Amberhearth role Roars the picture. The server bot stages the proof with the character. It does not finish the member's own Eldgrim quest, and the picture is not kept as a letter.
4. The next daily run on the founder's computer records the character for the ember's week, adds one standing point per member per week, and writes `EldgrimVerified.lua` into the installed addon. A proof counts for the week it was posted in, by Sunday 00:00 UTC.
5. When Jasmine Amberbrew next logs in or reloads, her client reads that file and sends the list to the guild. Members accept a list only from her, and only a newer one. A member who logs in later receives it with her answer to their hello.

The board shows the names as "Completed by". `EldgrimVerified.lua` holds only the week and the character name.

## The Sunday gathering

Founder decision, 22 November 2026. Every copy of the addon records who is at the Sunday gathering, and only during it: **Sunday 19:00 to 20:00 CET** (Central European time, which follows summer time; Europe/Stockholm in code). The hour is worked out from `GetServerTime()`, so it is the same for every member wherever they live. Nothing is recorded outside that hour.

- **/say:** a `CHAT_MSG_SAY` line from a character on the guild roster is kept with the speaker, the text and the time. A speaker who is not in the guild is skipped. The payload is not read during chat lockdown.
- **Group:** when the hour opens, and at every `GROUP_ROSTER_UPDATE` during it, each guild member in this character's party or raid is marked once, without text. A unit name without a surname is matched to the only roster name that starts with it.

On Jasmine Amberbrew's client the record goes straight into `EldgrimGathering`, keyed by the Sunday's date. Any other client holds it in `EldgrimQuests.gathering` and whispers it to her (`GATH`) when she is next heard: her hello at login, her answer to a hello, or the end of the hour while she is online. Batches are at most 25 lines and about 6,000 bytes. She checks that the sender and the named member are on her roster and that the time falls inside the hour the batch names, stores it, and acknowledges (`GACK`). The sender deletes exactly that batch and sends the next. An unacknowledged batch is sent again after two minutes or at the next login. Held records older than 14 days are deleted.

A record she saw herself has no `passedBy`. A record passed on by one member keeps that member's name. The same say line within 10 seconds, or the same group mark, passed on by a second member loses `passedBy`.

The daily run gives one standing point per member per Sunday attended, never twice for the same Sunday, once that Sunday's hour is over. A record counts when she saw it herself, when two members passed it on, or when the one member who passed it on is someone else: nobody witnesses themselves alone. The say lines are used only to see who was there. They are not scored for keywords and are cleared from the file with the day.

**Unverified in Forever 1.60.1:** that `CHAT_MSG_SAY` names the speaker "First Surname", that `UnitName` on a party or raid unit gives the first name only, and that `GROUP_ROSTER_UPDATE` fires as in other clients.

## The window

No minimap button. The flame emblem is attached to the guild window (`CommunitiesFrame`), centred on its top-left portrait, and glows on hover. The tooltip says "Eldgrim's Hearth". The guild crest is drawn as an overlay above the portrait, so the flame is raised above the highest frame in the guild window whenever the window opens or changes view, and once more a frame later. The portrait and the crest overlay under it are faded with `SetAlpha(0)` and are not reparented. **Unverified in Forever 1.60.1:** the key names `PortraitContainer` and `PortraitOverlay` on the guild window. Other installed Forever addons use `PortraitContainer` on other windows. If neither is found, the flame sits at the window's top-left.

The look is in `EldgrimSkin.lua`. The window's frame has cut corners. A triangle sits in each cut-away corner. From the outside in, the frame lines are one thick orange line, a gold line broken at random, a thinner red line that runs the whole way, a gap with small triangles at the corners, and an amber line. Each corner holds a small octagon with an upright flame and two flame-tipped scrolls. The flame emblem sits on the top edge over the lines and glows slowly. Each column has a lighter two-line frame with the same cut corners.

- The left column is Eldgrim's Ember: the card, its story in a scroll area, and who completed it. Its question mark shows the card's hint, then how to complete the ember in Discord. Those instructions appear nowhere else on the board (decided by the creator on 20 November 2026).
- The middle column lists open quests, except those this character has completed. Each row shows the title and who set it. **Create quest** is at the bottom.
- The right column shows the chosen quest: who set it, the story, the objective, and who took it up, marked complete, or completed. Its question mark says how a member quest is completed. Its buttons are below. **Create quest** opens the form in this column. The form has fields for the title, story and objective with letter counts.

Buttons light on hover, sink when pressed and grey out when they cannot be used. Text fields are sunk wells that glow when focused, with a placeholder. Tab moves to the next field. Escape closes the window.

The textures are drawn by `addon/tools/hearth_art.py`. Its frame geometry must match `EldgrimSkin.lua`. `addon/tools/preview/preview.sh` lays out the real board code on sample data in a mock of the frame API and renders it to PNG. That preview uses stand-in fonts and is not the game.

**Unverified in Forever 1.60.1:** `GetPhysicalScreenSize` (used to keep a thin line at least one pixel; skipped if missing), `FontString:SetMaxLines` (skipped if missing), the Morpheus title font, and the alpha animations. Other installed Forever addons use `InputBoxTemplate`, `SetTexCoord`, `SetVertexColor`, `SetBlendMode` and animation groups. That is not proof for this addon. **Inferred:** a new or changed `.tga` file loads only after the client is restarted, not after `/reload`.

## Checks still to do with two clients

- A forged master name does not publish an ember, and a forged revision does not replace the saved one.
- A peer never sends the ember, and a peer's records do not cancel the master's answer.
- A member who logs in after her hello receives the card when her revision is newer.
- The ember ends at the first Sunday 00:00 UTC after it was published.
- A peer answers with only the missing member-quest records, after a 5–20 second wait.
- Relayed lines land in the guild-chat lists. She asks the oldest online holder first. A speaker who is not on the roster is dropped. Two copies within 10 seconds match.
- Mark complete then the creator's Confirm completes a member quest, and it leaves only that member's list. The creator cannot accept it. A deleted quest disappears on every client.
- A split that stops halfway is discarded. Lines stay until the ack for that batch, and only that batch is deleted.
- The summary arrives before the lines. Lines newer than `online since` are not whispered. Held lines older than 7 days are deleted.
- A confirmation passed on by a peer stays unconfirmed. The creator's own confirmation settles it.
- A Roared ember picture reaches the board: bot export, daily run, `EldgrimVerified.lua`, Jasmine Amberbrew's login, then other members.
- Addon whispers reach `Jasmine Amberbrew`, and the live message cap and rate are written down.
- On a Sunday from 19:00 CET, /say from a guild member and the guild members in the group are recorded; a stranger's /say is not; nothing is recorded at 20:00 or later.
- A member's held gathering record reaches Jasmine Amberbrew at her next login and is deleted from the member only after her acknowledgement.
