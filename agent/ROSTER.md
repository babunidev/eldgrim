# Eldgrim's guild roster

**Status:** Specified on 2026-11-11. Not implemented and not tested.  
**Comes before:** Any reply or administrative action Eldgrim takes by itself. The daily announcement already posts without it (2026-11-11).

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
| Discord, through the Character Forge | The member, their fellowship (Roar or Amberhearth), and each character's name, faction, race and class | A person entry, plus one character entry for each registered character |
| The Forever addon, through guild chat | The speaking character's name and whatever human-readable details the addon actually saved: race, class, level, faction, zone, professions, achievement points | A character entry. A person entry is added only when that character is already registered to a Discord member |

An addon character with no Forge registration stays unlinked. A Forge member who has not yet spoken in guild chat still has a roster entry. Two characters with the same name are not merged. An uncertain match never moves a rank, a memory, or a keyword from one entry to another.

The addon file is read after the game has written it, and only while the Forever client is closed. While the client is running, the on-disk file can be stale, and a logout would write the client's copy back over any cleanup. A run that finds the client open skips this file. Raw guild messages and raw Discord sentences are temporary input. They are deleted after the run has reduced them. The cleanup of the addon file is specified under [The guild chat file](#the-guild-chat-file).

## From a sentence to keywords

When a run receives sentences about a person or a character, from a message addressed to Eldgrim or from an authorized guild record, it does four things:

1. Attribute the sentence only to a roster entry it can verify: the Discord member who wrote it, or the character name already on the roster.
2. Read the whole temporary text that belongs to that entry in this run.
3. Reduce it to keywords: short terms for what was actually said or shown, such as a craft, a place, a companion, or a deed.
4. Save the keywords on that entry, then delete the sentences.

A keyword records whether it was stated or inferred, which door it came from, and when it was saved. The run then compares those keywords with the ones already stored for that entry. A keyword already present, and still true, is left as it is: the member is the same in that respect. A new keyword is added. A later fact marks an older keyword superseded. It does not erase the older keyword silently. Keywords are not a public profile and not a transcript. A sentence that does not belong to a verified entry produces no keyword.

## The guild chat file

The Forever addon writes the guild chat archive as account-wide SavedVariables. The path pattern is in [addon/SPECIFICATION.md](../addon/SPECIFICATION.md). The account directory is local configuration and is not written into this repository.

The table `EldgrimDB` is already sorted by speaking character. Each character key holds timestamped guild messages and whatever profile fields the addon actually saved. Eldgrim walks those keys. It does not flatten the file and sort it again.

For each character in that table, one run does this:

1. Load the character entry, and the person entry only when a Forge registration already links them.
2. Read that character's messages for this run. The text stays temporary.
3. Reduce the messages to keywords, then compare them with the keywords already stored, as specified above.
4. Consider internal standing, as specified under [Same, new, and standing](#same-new-and-standing).
5. Commit the database.
6. Clear that character's message list, leaving an empty list the addon can append to. Profile fields stay. The separate roster table stays.

The clear is one fixed operation on this configured file. The model does not choose a path, and it does not receive a general write tool. If the database commit fails, the messages stay for the next run. A message already reduced is recognized by a temporary hash of the character, the timestamp and the text, so a failed clear cannot add the same keyword twice. Those hashes are deleted once the clear has succeeded. They are not a transcript.

The client currently being played also writes `EldgrimRoster` into the same file: a guild name, an update time, and the members present at that refresh. The recorder milestone in this repository does not write that table. When the table is present and its update time is newer than the snapshot last applied, it is how Eldgrim sees who is still in the guild. Chat is not that list. A character who has not spoken is still a member if the newer roster names them. A character missing from a newer roster is no longer in the in-game guild. Their roster membership ends. Eligible personal keywords then follow the departure rule already confirmed: review, and delete or anonymize within 30 days unless a specific retention need applies. Leaving the game guild does not, by itself, remove a Discord member. A missing or older roster is not treated as everyone having left. Public notes, numeric rank indexes, online flags and last-online gaps are not keywords and do not change standing. A human-readable rank, level, class, zone or profession is kept only when the file actually contains it.

## Same, new, and standing

After the keyword comparison, Eldgrim may value what changed. Standing is the internal 0–100 judgment already confirmed in governance chapter 07. It is private. It is not a rank shown to the guild, and it never by itself warns, demotes or removes someone.

- A new person starts at 50 when standing is first stored. An unlinked addon character can gain keywords and does not gain a standing score until a verified registration ties that character to a person. Standing belongs to the person.
- Nothing new, or the same keywords as before, leaves standing where it is. Silence, absence and a quiet log are not a minus.
- A plus or a minus has to follow the confirmed bands: minor 1–3, significant 4–10, exceptional up to 20, and the result stays inside 0–100. Character facts and personal history give context. They do not move the number by themselves. Kindness, help, creativity and meaningful support can raise it when the messages reasonably support that. Verified misconduct can lower it. A joke, a rumor or an unsupported inference cannot.
- The adjustment is stored with the rule it relied on and the keyword that supports it. Applying a Discord rank change or a sanction from that number is a later, separate action. It is not part of reading this file.

## What the roster holds

The sketch below is the shape of the database. It is not built.

| Record | Keeps |
| --- | --- |
| Person | Discord member when known, current display name, fellowship, internal standing when stored, first seen, last updated |
| Character | Name, faction, race, class, in-game membership when a roster snapshot says so, and any later addon details that were actually present. Linked to a person only by a verified registration |
| Keyword | The term, the person or character it describes, stated or inferred, source door, time, and any keyword it supersedes |
| Standing adjustment | The person, the amount, the rule, the supporting keyword, and the time. Private, and not a sanction |

Missing fields stay empty. The agent does not invent a race, a fellowship, or a keyword to fill a gap.

## How a run uses it

Before Eldgrim speaks or decides, the run loads the roster entry it is dealing with and the keywords on that entry. It does not load the whole database, and it does not load raw chat. The roster is Eldgrim's overview of the guild: who has come through Discord, who has been seen in the game, and the keywords gathered about each of them.

This overview is how Eldgrim knows the guild well enough to be itself. Answering a mention and any later action wait until this roster exists and a run has been shown to update it without keeping the raw sentences. The daily announcement is the exception and already posts.
