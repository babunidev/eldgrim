# Eldgrim's guild roster

**Status:** Built on 2026-11-12. A run opens the local database, refreshes the Forge, reduces new guild-chat lines, then writes. Mention replies still wait.  
**Comes before:** Any reply or administrative action Eldgrim takes by itself. The daily announcement posts after the refresh, and still posts when the refresh cannot be finished.

Eldgrim acts once a day on the founder's computer. The server bot stays the always-online hands for onboarding and roles. The computer is where Eldgrim reads, reduces what it read to keywords, and keeps the guild roster. A little more lore can still be added to the pages it reads. Lore is not a substitute for the roster.

## Where it acts

A system wake timer starts one Python process, which runs as the user. The process reads its sources, updates the local database, unloads the local model, and exits. It does not stay connected to Discord. If the computer is off, that day is skipped.

The database lives only on this computer, outside the repository:

~~~text
~/.local/share/eldgrim/eldgrim.sqlite3
~~~

The founder is the only person with direct access. The server does not keep this database. The live bot's Forge and role records stay on the server as operational data, separate from Eldgrim's memory.

## Where a member comes from

A guild member enters the roster from either door. Both doors create or update an entry. Neither door is guessed into the other.

| Door | What arrives | Roster result |
| --- | --- | --- |
| The in-game guild, through the addon | The character's name, their guild rank when the roster saved it, and whatever human-readable details the addon actually saved | A member. The character name is the name until Discord is known |
| Discord, through the Character Forge | The Discord name, their fellowship (Roar or Amberhearth), and each character they declare | That Discord name is attached to the member who already bears the character. A character who was not in the guild yet is added |

The in-game guild is the member list. A character in that guild is a member Eldgrim works with, whether or not they have used Discord. Some members never will. The Forge connects a Discord name, and the characters that person declares, to the member who is already there. Two Discord members declaring the same character name link neither. An uncertain match never moves a rank, a memory, or a keyword from one entry to another.

The run uses the addon file as it sits, whether or not the game is open. An empty file is skipped. Lines already reduced are not sent to the model again; if they are still in the file, they are cleared. New lines are reduced, then those message lists are cleared. A file that changes while the run is reading it is left for the next run. Raw guild messages are temporary input. They are not written into the database. The cleanup is specified under [The guild chat file](#the-guild-chat-file).

## From a sentence to keywords

When a run receives guild-chat lines for a character, it does four things:

1. Attribute them to the member who bears that character name. A name claimed by two people gets no keyword.
2. Read every new line from that member in this file as one pile. A greeting and a long speech are the same pile.
3. Reduce the pile to one keyword: a short term for the essence, marked positive, negative, or neither.
4. Save that one keyword, then clear the message list.

A keyword records its mark, the guild-chat door, and when it was saved. One member, one run, one keyword. An opted-out member, and a name claimed by two people, produces no keyword. Those lines stay in the file. Keywords are private notes for the founder and for Eldgrim. They are not a public profile and not a transcript.

## The guild chat file

The Forever addon writes the guild chat archive as account-wide SavedVariables. The path pattern is in [addon/SPECIFICATION.md](../addon/SPECIFICATION.md). The account directory is local configuration and is not written into this repository.

The table `EldgrimDB` is already sorted by speaking character. Each character key holds timestamped guild messages and whatever profile fields the addon actually saved. Eldgrim walks those keys. It does not flatten the file and sort it again.

For each character in that table, one run does this:

1. Load the member who bears that character name, creating the member when the guild names them and Discord does not.
2. Read that character's messages for this run. The text stays temporary.
3. Reduce that member's new messages to one keyword, as specified above.
4. Record the day's standing points, as specified under [Same, new, and standing](#same-new-and-standing).
5. Commit the database.
6. Clear that character's message list, leaving an empty list the addon can append to. Profile fields stay. The separate roster table stays. An opted-out member's lines stay. A name claimed by two people stays, because it cannot be attributed.

The clear is one fixed operation on this configured file. The model does not choose a path, and it does not receive a general write tool. If the database commit fails, the messages stay for the next run. A message already reduced is recognized by a temporary hash of the character, the timestamp and the text, so a failed clear cannot add the same keyword twice. Those hashes are deleted once the clear has succeeded. They are not a transcript.

The client currently being played also writes `EldgrimRoster` into the same file: a guild name, an update time, and the members present at that refresh. The recorder milestone in this repository does not write that table. When the table is present and its update time is newer than the snapshot last applied, it is how Eldgrim sees who is still in the guild. Chat is not that list. A character who has not spoken is still a member if the newer roster names them. A character missing from a newer roster is no longer in the in-game guild. Their roster membership ends, and `left_on` records that date. Keywords are not deleted by this run. A later review can use the date for the 30-day departure rule. Leaving the game guild does not, by itself, remove a Discord member. A missing or older roster is not treated as everyone having left. Public notes, numeric rank indexes, online flags and last-online gaps are not keywords and do not change standing. A human-readable rank, level, class, zone or profession is kept only when the file actually contains it.

## Same, new, and standing

After the keyword is saved, Eldgrim records the day's points. Standing is the internal 0–100 judgment in governance chapter 07. It is private. It is not a rank shown to the guild, and it never by itself warns, demotes, or removes someone.

- A new member, and a member at Ember, starts at 50. A member who already holds Wayfarer, Kindler, Hearthkeeper, or Hearthwarden starts at that rank's minimum: 60, 70, 80, or 90. The in-game rank is the one that sets this. Standing belongs to the person, including a member who has no Discord account.
- Any guild-chat message on the day is +1. A positive keyword is +1 more. A negative keyword is −2. A keyword marked neither adds nothing beyond the activity point. Silence adds nothing and takes nothing.
- The result stays inside 0–100. The adjustment is stored with the rule and the keyword. A later run does not score the same lines again.
- The score shows who is in view for a rank. It does not apply the rank. Wayfarer is in view at 60, Kindler at 70, Hearthkeeper at 80, and Hearthwarden at 90. There is no demotion below Ember by score. The daily note for Hearthkeepers and Hearthwardens names at most one person, and only when the day's keyword agrees. Otherwise it says the ranks look in order.
- The same note ends with a census of the in-game guild: the number of members; the number and names of members active in guild chat, meaning a guild-chat line within the last seven days; and each recorded profession with its count and the characters who hold it. A profession appears only when the addon saved it. If the note would pass Discord's 2,000-character limit, every list is shortened alike and ends with "and N more". An opted-out member is never marked active.

## What Eldgrim knows of the people

Every model call reads "The people of Amberhearth" right after Eldgrim's core self (approved 2026-11-13). The block is built at run time from this database and never stored in the repository. It lists every character in the in-game guild with race, class, level, in-game rank and professions, leaving out any field the addon did not record. Characters are grouped under one member, with that member's Discord display name, only when the member declared them in the Forge; an in-game-only character stands alone (Q158). A member who opted out stays listed with basic facts and is marked not to be named in public (Q132). The block never holds standing, keywords, chat, Discord ids or where someone is. Its order is shuffled on every run, because a small model favours whoever is listed first.

The proclamation may name a member's character when it is kind, and may then say only what that member's line says. It never gives a member a deed, find, journey, feeling or quality that is not written there, never compares members, never hints at a rank change or judgement, and never uses Discord names in public.

## What the roster holds

The sketch below is the shape of the database.

| Record | Keeps |
| --- | --- |
| Person | Discord name when known, current display name, fellowship, guild rank, internal standing, opt-out, owner flag, first seen, last updated, and `left_on` when no character remains in the game guild |
| Character | Name, faction, race, class, in-game membership, `left_on` when a newer roster no longer names them, `last_spoke` (only the date of the latest guild-chat line, never its text), and any later addon details that were actually present. A Forge link is marked `declared` |
| Keyword | The one term for that member on that run, whether it is positive, negative, or neither, source door, and time |
| Standing adjustment | The person, the amount actually applied, the rule, the supporting keyword, and the time. Private, and not a sanction |

Missing fields stay empty. The agent does not invent a race, a fellowship, or a keyword to fill a gap. The founder can set opt-out locally with `eldgrim opt-out NAME` and reverse it with `eldgrim opt-in NAME`. `eldgrim roster` prints counts and names, and no chat text.

## How a run uses it

Before Eldgrim speaks or decides, the run loads the roster entry it is dealing with and the keywords on that entry. It does not load the whole database, and it does not load raw chat. The roster is Eldgrim's overview of the guild: who has come through Discord, who has been seen in the game, and the keywords gathered about each of them.

This overview is how Eldgrim knows the guild well enough to be itself. Answering a mention and any later action wait until this roster exists and a run has been shown to update it without keeping the raw sentences. The daily announcement is the exception and already posts.
