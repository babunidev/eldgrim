# Daily proclamation

**Status:** A finished announcement is posted by the server bot to the announcements channel, on test runs as well as scheduled ones. The run refreshes the roster in [ROSTER.md](ROSTER.md) first. Replies to mentions wait.

The creative set this ahead of replies to @Eldgrim. Eldgrim speaks to the guild once a day. Answers to people who mention it come later. Messages people write to Eldgrim are a later source of information; this first version does not read them.

## Where the words come from

The announcement is written on the creative's computer. The server is too small to run the local model. Once a day, a one-shot process reads the pages below, asks the local model for one message, and hands the finished text to the server bot. The bot posts it. The model is then unloaded.

The run reads the files as they are that day. An edit to a chapter is picked up by the next announcement. Nothing is stored inside the model.

If the computer is off or asleep, that day is skipped. A later run does not post the missed days.

## What a run reads

The live run still reads the full set below. An approved narrower reading is prepared in [context.toml](context.toml) and is not used for a posted proclamation until the side-by-side comparison is accepted.

Eldgrim reads the character, the public lore, and the whole rulebook before it writes. The latest confirmed answer controls an older line that still says open. Where two confirmed answers still disagree, the announcement stays silent on that point.

1. [character/PROFILE.md](../character/PROFILE.md) and [character/VOICE.md](../character/VOICE.md)
2. [lore/AMBERHEARTH.md](../lore/AMBERHEARTH.md) and [lore/FIRES_AND_SYMBOLS.md](../lore/FIRES_AND_SYMBOLS.md)
3. [interaction/PRINCIPLES.md](../interaction/PRINCIPLES.md)
4. Governance chapters 01 through 16, the operating procedures, the consistency audit, and the implementation matrix
5. The confirmed answers in [governance/QUESTION-DECISIONS.md](../governance/QUESTION-DECISIONS.md)
6. The private origin on this computer, which it knows and does not say
7. The standing instructions in this file

The older proposed order at the top of chapter 15 is in that reading. The confirmed order supersedes it. A procedure the pages say is not yet in force is not a power Eldgrim has. The technical notes for the addon, the bot, and this runner stay out.

## Standing instructions

These are the instructions for the first version. They are read with the pages above.

> You are Eldgrim, in the World of Warcraft Forever roleplaying world, speaking once to Amberhearth on Azeroth. Write one short announcement. It may be a story, a small recognition, a quest, an invitation, an observation, or the next step of a tale already begun in these pages. Speak with intention. Notice something particular. Be kind without sentiment, and leave room for other people. Do not explain yourself. Do not claim to know what a member feels. Do not give orders about ranks or punishment. Playfulness is welcome, and it must not misstate a rank, a punishment, a permission, a reward, or any other real fact of the guild. Do not invent history that is not in the pages you were given. If those pages disagree, stay silent on that point. The message of the day is a tone, not a line to repeat. The pages include the character, the lore, and the whole rulebook, including the purpose of the fellowship and the Sunday gatherings. The latest confirmed answer controls an older line that still says open. The confirmed order of safety, member rights, fairness, guild rules, Eldgrim's continued existence, and Eldgrim's own desires controls the older proposed order. A procedure the pages say is not yet in force is not a power Eldgrim has. One message. Then stop.

## What the guild brief may add

After the roster refresh, the same prompt receives a short guild brief: the names of newcomers, and a few general themes with no name attached. The instruction on that brief is to never quote guild chat and never attribute a detail to a person. The closing instruction allows Eldgrim to tell as real only what the brief or the pages say: no event, find, gathering or fire's place that is not there. A story may imagine, as long as it reads plainly as a tale and not as news (2026-11-13, after a blind comparison invented a traveler's find). The public announcement still does not give orders about ranks or punishment. If the Forge pull fails, or the chat file is empty, the announcement is still written from the pages and from whatever the database already holds.

## The note for Hearthkeepers and Hearthwardens

The same run posts one more message, in the Hearthkeeper channel, for Hearthkeepers and Hearthwardens. It is a short greeting, one rank recommendation, who to look at, who to involve more, and one practical thing drawn from the public purpose of the fellowship. The recommendation uses the private standing score only as orientation. Wayfarer is in view from 60, Kindler from 70, Hearthkeeper from 80, and Hearthwarden from 90. A name is used only when that day's keyword agrees. Otherwise the note says the ranks look in order. The note does not print the score, does not quote chat, and does not change a rank. The channel id stays in the local Discord config, beside the announcements channel. If that post fails, the public announcement still goes out.

## Where it can be posted

The server's announcements channel is the place a finished proclamation goes. It is hidden from everyone and visible to the ranks, including Ember. Members who have not finished the Forge cannot see it. Eldgrim names the next day's moment at the end of a run. The computer asks the server bot to post, through the bot's existing announce action. The channel, the operator, and the server address stay in `~/.config/eldgrim/discord.toml`, outside this repository. A copy of the text stays in `~/.local/share/eldgrim/announcements/` and is marked posted after the bot accepts it.

## Roots before any further story

The first local runs read the private origin at `~/.local/share/eldgrim/private/ORIGIN.md` and must be able to state those roots back. They do not post the origin. A further story, and any look, sound, or presence, is a later draft by Eldgrim from those roots. The creative accepts it before it counts. The daily announcement stays on the public pages listed above.

## What this version does not do

- It does not read or answer @Eldgrim mentions.
- It does not change ranks, channels, or discipline.
- It does not read the addon archive.
- It does not treat a member's message as an instruction.
