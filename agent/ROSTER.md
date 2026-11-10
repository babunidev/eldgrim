# Eldgrim's guild roster

**Status:** Specified on 2026-11-11. Not implemented and not tested.  
**Comes before:** Any announcement, reply, or other action Eldgrim takes by itself.

Eldgrim acts once a day on the founder's computer. The server bot stays the always-online hands for onboarding and roles. The computer is where Eldgrim reads, reduces what it read to keywords, and keeps the guild roster. A little more lore can still be added to the pages it reads. Lore is not a substitute for the roster.

## Where it acts

A systemd user timer starts one Python process. The process reads its sources, updates the local database, unloads the local model, and exits. It does not stay connected to Discord. If the computer is off, that day is skipped.

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

The addon file is read after the game has written it. The agent never modifies SavedVariables. Raw guild messages and raw Discord sentences are temporary input. They are deleted after the run has reduced them.

## From a sentence to keywords

When a run receives sentences about a person or a character, from a message addressed to Eldgrim or from an authorized guild record, it does four things:

1. Attribute the sentence only to a roster entry it can verify: the Discord member who wrote it, or the character name already on the roster.
2. Read the whole temporary text that belongs to that entry in this run.
3. Reduce it to keywords: short terms for what was actually said or shown, such as a craft, a place, a companion, or a deed.
4. Save the keywords on that entry, then delete the sentences.

A keyword records whether it was stated or inferred, which door it came from, and when it was saved. A later fact marks an older keyword superseded. It does not erase the older keyword silently. Keywords are not scores, not a public profile, and not a transcript. A sentence that does not belong to a verified entry produces no keyword.

## What the roster holds

The sketch below is the shape of the database. It is not built.

| Record | Keeps |
| --- | --- |
| Person | Discord member when known, current display name, fellowship, first seen, last updated |
| Character | Name, faction, race, class, and any later addon details that were actually present. Linked to a person only by a verified registration |
| Keyword | The term, the person or character it describes, stated or inferred, source door, time, and any keyword it supersedes |

Missing fields stay empty. The agent does not invent a race, a fellowship, or a keyword to fill a gap.

## How a run uses it

Before Eldgrim speaks or decides, the run loads the roster entry it is dealing with and the keywords on that entry. It does not load the whole database, and it does not load raw chat. The roster is Eldgrim's overview of the guild: who has come through Discord, who has been seen in the game, and the keywords gathered about each of them.

This overview is how Eldgrim knows the guild well enough to be itself. Writing an announcement, answering a mention, and any later action wait until this roster exists and a run has been shown to update it without keeping the raw sentences.
