# Eldgrim Discord Bot

**Status:** Direction approved by the creative on 2026-11-10. The bot runs on the server as Eldgrim, and the multi-character Forge is deployed with its switches off. Conversation and the database are not built.

Eldgrim is an entity, not a man: refer to it as "it", never "he".

A separate technical workstream for Eldgrim's presence on the guild Discord server. Like the addon, the bot is out-of-character software: what it does on Discord does not establish Eldgrim's in-world powers, history, or canon.

## Starting point

The existing Babuni Gaming Discord bot is the foundation. Verified on 2026-11-10:
- Python, discord.py 2.7.1. Source under version control in `~/Projects/eldgrim-bot` (local only, no remote). A backup of the desktop installation's source, configuration, state, and service file exists under `~/Backups/`.
- Since 2026-11-10 it runs on the server as the system service `eldgrim-bot.service` under a dedicated `eldgrim` account. The desktop service is stopped and disabled; the two must never run at the same time.
- Provides administration operations with preview and approval, the Roar counter, unified guild ranks, and the Character Forge, where members choose faction, race, and class roles.
- Runs in live mode with Administrator permission.

## Approved direction

**Identity.** The bot appears on Discord as Eldgrim, with its own name and a new profile image. The existing bot is renamed and expanded rather than replaced.

**Hosting.** The bot moves from the desktop PC to the creative's existing server so that it is always online: it welcomes newcomers, runs onboarding, and stores member and character data at any time.

**Administration.** Eldgrim keeps the existing capabilities, including rank management and channel creation.

**Ranks.** Amberhearth's ranks are used everywhere, including Discord: Ember, Wayfarer, Kindler, Hearthkeeper, Hearthwarden. The Discord rank roles already carry these names (verified 2026-11-10), and the bot's code and texts use them since the multi-character Forge.

**Server.** An Ubuntu 26.04 server with Python 3.14, which also hosts other services. Discord and the Python package index were reachable from it on 2026-11-10.

**Character onboarding.** An extension of the Character Forge, using the same pattern of a gate channel and a gate role:
1. Newcomers receive the Forge role on arrival and see only the Forge channel.
2. They accept the hearth rules, which include Discord's Terms of Service and Community Guidelines and say what Eldgrim remembers: registered characters, conversations with Eldgrim, and guild activity recorded in the game, such as guild chat, emotes, and presence at events.
3. They choose Roar or Amberhearth. Roar also receives the existing Roar role. Amberhearth receives the Amberhearth role. Both still receive Ember.
4. Eldgrim asks how many characters they bring. There is no fixed limit; the software accepts up to 50 to catch typing mistakes.
5. For each character: one name, or a first name and a surname, then faction, race, and class. WoW Forever uses both names. One name is accepted too, because a member may bring a character from another version of World of Warcraft. Each part is 2–12 letters, accents allowed, with no spaces, hyphens, apostrophes, or numbers, and no letter three times in a row. The Forge capitalises like the game. A surname left empty stays a one-name character. Faction is asked because Skyborne exist on both sides.
6. On completion they receive the roles of all their characters, their fellowship role, and the rank **Ember**, and the Forge disappears.

The Roar role used to be given to every member who held a guild rank. That automatic assignment is retired, because it would have put Amberhearth members into Roar as soon as they became Ember.

Everyone passes through the new Forge, including existing members; only the server owner is exempt. Ember is given on completion rather than on arrival, because Discord cannot hide channels that a role grants explicitly. The channels currently visible to everyone (all-chat, looking-for-group, wow-addons, morkahja, azeroth-moments) will be visible to the ranks only, so the Forge is all a newcomer sees.

**Rank reset.** Approved by the creative on 2026-11-10: every member except the server owner restarts at Ember. When the switch that holds back ranks is turned on, members who have not completed the Forge lose all five ranks, including Administrator held through Hearthwarden; members who already completed keep only Ember. Completing the Forge then grants Ember, and Eldgrim decides any promotion afterwards. Once a member has completed, a later change to their character roles never removes a rank. The bot records each member's former ranks before removing them.

**Notice.** On 2026-11-10 Eldgrim posted once in the Forge and mentioned everyone who still holds the Forge role. It also sent one direct message, in Eldgrim's voice, to each of the 73 members who had not registered. A direct message waits in the inbox whether the member is online or not. A closed inbox would be recorded and skipped; none were closed.

**Implementation status (2026-11-10):** live. The creative completed the Forge first. The five public channels are now visible to the ranks only, and the rank switch is on: 73 members lost their ranks until they finish the Forge, including 3 Hearthwardens who held Administrator. The server owner is exempt. A dice bot kept its ranks, because a bot cannot complete the Forge. Finishing the Forge grants Ember.

**Server ownership.** As far as known, Discord does not allow transferring server ownership to a bot. The creative remains owner; Eldgrim holds Administrator.

**Conversation.** Eldgrim speaks only once a day and reacts only to messages that mention @Eldgrim. It does not answer other messages or unaddressed questions. Onboarding, welcomes, administration, and data storage keep running at all times; the once-a-day rule applies to Eldgrim's replies.

Messages that mention the bot are readable without Discord's privileged Message Content intent, so this design does not need that permission.

**Member and character data.** The bot stores Discord members and the characters they declare on the server. That data becomes the basis of Eldgrim's local database, later combined with in-game data from the addon and used according to Eldgrim's rules.

## Data flow (proposed)

1. **Discord onboarding** on the server records which Discord member owns which declared characters.
2. **The addon** records guild messages and character details in the game. A WoW addon cannot send data out of the game; the client writes `Eldgrim.lua` to SavedVariables only on reload, logout, or exit.
3. **A sync step** on the creative's PC reads that file after logout and transfers it to the server.
4. **Eldgrim's database** on the server joins both sources by character name.

The addon itself stays a silent local recorder and never stores Discord identifiers. The bot necessarily stores Discord member IDs on the server to manage roles; these must stay private to the server and never be published.

## Relation to the local-agent design

The agent/ documents (2026-11-09) describe a once-daily local agent on the creative's PC using Ollama. Both designs agree that Eldgrim answers once a day and only to @Eldgrim mentions. On 2026-11-10 the creative decided how they fit together:

- **Split.** The server bot is Eldgrim's always-online part: onboarding, welcomes, administration, and data. The local agent on the PC is its once-daily voice: it writes replies with Ollama and posts them through the same Eldgrim Discord application. The server (2 CPU cores, 3.7 GB memory) is too small for local inference.
- **Administration by the AI.** Approved. The model may trigger administration, but only through registered tools that call the server bot's validated operations. It never receives the token or direct Discord API access.
- **Addon data.** Approved. Eldgrim's database combines onboarding data with the addon's archive, and the AI may use it.

**Governance.** Eldgrim manages the guild toward defined goals rather than serving requests. Requests are input to its judgement, never instructions. It decides on ranks and administration from its conversation history and the addon's guild activity, and the creative follows its recommendations. A precise goal and rule set, still to be written, defines what it strives for; concealed goals stay out of this public repository. Every action goes through the bot's validated operations and audit log.

## Open decisions

- How the sync step transfers the addon file to the server.
- When Eldgrim's daily moment happens, and whether it answers all mentions gathered since the previous day or only some.
- The new profile image, with its source and usage rights recorded in assets/.
- How the PC agent reaches the server bot's operations and the combined database (for example over SSH), and how replies follow character/VOICE.md and interaction/PRINCIPLES.md.
- Eldgrim's goal and rule set, and which parts of it are public.
- How newcomers currently receive Ember on arrival (Discord onboarding default roles or another bot). The rank switch removes it from incomplete members either way; turning off the source avoids the bot working against it.
- How a member can see or remove the data Eldgrim stores about them.

## Planned order

1. Put the existing bot under version control and back up its configuration and state. **Done 2026-11-10;** the 51 existing unit tests passed on the new copy.
2. Deploy the bot on the server and stop the desktop service. **Done 2026-11-10;** connection to Discord confirmed through the bot's control socket.
3. Rename the bot to Eldgrim and give it the new profile image. **Done 2026-11-10** by the creative in the Discord Developer Portal.
4. Specify and build multi-character onboarding. **Done 2026-11-10.** The Forge is live, the public channels are visible to the ranks only, and every member except the server owner restarts at Ember.
5. One daily proclamation, written on the creative's computer from the character voice and the solid governance pages, then posted by the server bot. **Specified 2026-11-10** in agent/ANNOUNCEMENT.md. Replies to @Eldgrim mentions wait. The channel and the hour are not chosen.
6. Build the addon sync and Eldgrim's database.
