# Eldgrim Discord Bot

**Status:** Direction approved by the creative on 2026-11-10. Specification developing. No Eldgrim-specific bot code, server deployment, or Discord change exists yet.

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

**Ranks.** Amberhearth's ranks are used everywhere, including Discord: Ember, Wayfarer, Kindler, Hearthkeeper, Hearthwarden. The Discord rank roles already carry these names (verified 2026-11-10). Some bot texts and notes still use the former names Wanderer, Adventurer, Pathfinder, Trailblazer, and Firekeeper.

**Server.** An Ubuntu 26.04 server with Python 3.14, which also hosts other services. Discord and the Python package index were reachable from it on 2026-11-10.

**Character onboarding.** An extension of the Character Forge, using the same pattern of a gate channel and a gate role:
1. Newcomers receive the gate role automatically and see only the onboarding channel.
2. Eldgrim asks how many characters they have in the guild.
3. For each character, Eldgrim asks the character name, class, and race.
4. On completion, the member gains access to the relevant channels and to the Discord server in general.

**Conversation.** Eldgrim speaks only once a day and reacts only to messages that mention @Eldgrim. He does not answer other messages or unaddressed questions. Onboarding, welcomes, administration, and data storage keep running at all times; the once-a-day rule applies to Eldgrim's replies.

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

- **Split.** The server bot is Eldgrim's always-online part: onboarding, welcomes, administration, and data. The local agent on the PC is his once-daily voice: it writes replies with Ollama and posts them through the same Eldgrim Discord application. The server (2 CPU cores, 3.7 GB memory) is too small for local inference.
- **Administration by the AI.** Approved. The model may trigger administration, but only through registered tools that call the server bot's validated operations. It never receives the token or direct Discord API access.
- **Addon data.** Approved. Eldgrim's database combines onboarding data with the addon's archive, and the AI may use it.

**Proposed safeguards for AI administration (not yet decided):** an allowlist of operations the AI may use, with kicks, bans, and permission changes excluded at first; per-day limits; every action recorded in the bot's audit log; and Discord messages treated as untrusted input, since anyone can mention @Eldgrim.

## Open decisions

- Server details (operating system, access, Python version), and how the sync step transfers the addon file to it.
- When Eldgrim's daily moment happens, and whether he answers all mentions gathered since the previous day or only some.
- The new profile image, with its source and usage rights recorded in assets/.
- How the PC agent reaches the server bot's operations and the combined database (for example over SSH), and how replies follow character/VOICE.md and interaction/PRINCIPLES.md.
- Which safeguards apply to AI administration.
- Whether onboarding replaces or extends the current faction, race, and class roles, and which roles each declared character grants.
- Where the bot source code lives: in this repository, or in its own repository linked from here.
- What members are told about the data Eldgrim stores, and how a member can change or remove it.
## Planned order

1. Put the existing bot under version control and back up its configuration and state. **Done 2026-11-10;** the 51 existing unit tests passed on the new copy.
2. Deploy the bot on the server and stop the desktop service. **Done 2026-11-10;** connection to Discord confirmed through the bot's control socket.
3. Rename the bot to Eldgrim and give it the new profile image. The application name and image are changed by the creative in the Discord Developer Portal.
4. Specify and build multi-character onboarding.
5. Specify and build message reading and replies.
6. Build the addon sync and Eldgrim's database.
