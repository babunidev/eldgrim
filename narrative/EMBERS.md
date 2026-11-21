# Eldgrim's Embers

**Status:** Developing record.

The weekly ember is the card on the hearth board in the Forever addon. Only Jasmine Amberbrew's client publishes it, from the `EldgrimEmbers.lua` installed on her machine. The copy in `addon/Eldgrim/` stays blank at revision 0. This page keeps the text of each ember, so it can be read and reviewed here. A week runs to Sunday 00:00 UTC. How it works is in [addon/HEARTH.md](../addon/HEARTH.md).

An ember is a card in Eldgrim's voice. Declining it changes nothing. It is completed only in Discord: a screenshot in the Eldgrim channel with @Eldgrim and the word ember, Roared by another Amberhearth member. The daily run records it and adds one private standing point per member per week (decided 20 November 2026). Revision 3 changed both hints from marking the ember on the board to that proof. In revision 4 the hints no longer say it: the board's question-mark tooltip adds those instructions after every card's hint, and nowhere else on the board shows them.

The installed file holds two cards: the current one and the next one. When the current card ends, the next takes over. Then a new next card is written, the revision is raised, and it is published at Jasmine Amberbrew's next login or `/reload`, so one is always prepared.

## 1. A Fire of Your Own

- **id:** `ember-2026-11-20`, the current card in revision 4
- **Week:** from Friday 20 November 2026, 00:00 UTC, to Sunday 22 November 2026, 00:00 UTC.
- **Written:** 20 November 2026, by Claude Code (Claude Opus 5.5) at the creative's request, from [character/SELF.md](../character/SELF.md), [character/VOICE.md](../character/VOICE.md), [lore/FIRES_AND_SYMBOLS.md](../lore/FIRES_AND_SYMBOLS.md), [lore/WORLD.md](../lore/WORLD.md) and [lore/FIRE_ITEMS.md](../lore/FIRE_ITEMS.md). Revision 1 started it on 22 November and said "This week"; the creative moved it to end on Sunday.
- **Published:** not yet. Revision 1 never published, because the addon took Jasmine Amberbrew's name as "Jasmine".

> Every hearth was once a single small fire that someone decided to keep. Before the week turns, light one of your own. Find a stretch of road where you have never stopped, set your fire there, and stay beside it until it has warmed you through. Watch the road while it burns. If someone stops, make room for them. If no one does, the fire was still worth lighting. Before you go, notice one thing that small light showed you, something you would have walked straight past. Keep the fire.

**Hint** (behind the question mark):

> Any fire you light yourself counts. A Basic Campfire Kit, made with Cooking, builds one. Simple Wood and Flint and Tinder are sold by general goods vendors in many towns. Keep to roads on the Alliance side or in lands with no side.

The campfire kit and both goods are from [FIRE_ITEMS.md](../lore/FIRE_ITEMS.md), read from ZugZugDB and not checked in the game.

## 2. The Place You Always Pass

- **id:** `ember-2026-11-22`, the next card in revision 4
- **Week:** Sunday 22 November 2026, 00:00 UTC, to Sunday 29 November 2026, 00:00 UTC.
- **Written:** 20 November 2026, by Claude Code (Claude Opus 5.5) at the creative's request, from the same pages. The first card sends people somewhere new; this one sends them back to somewhere familiar.
- **Published:** not yet.

> There is a place you walk through so often that you no longer see it: a gate, a stair, an inn, the road to your trainer. This week, go back there and slow down. Stand still where you usually hurry. Look up. Look behind the door. Read the sign you have never read. Somewhere in that place is one small thing that has been waiting a long time for someone to notice it. Find it, and let it be yours for a while. Keep the fire.

**Hint:**

> Any place you pass often counts: a city street, an inn, the road out of your starting town. Keep to the Alliance side or to lands with no side. You do not need to show anyone what you found.

Both texts are plain ASCII on one line, because sending a line break or a curly quote in an addon message has not been tested.
