# Eldgrim Discord Bot

**Status:** Direction approved by the creative on 2026-11-10. Specification developing. No Eldgrim-specific bot code, server deployment, or Discord change exists yet.

A separate technical workstream for Eldgrim's presence on the guild Discord server. Like the addon, the bot is out-of-character software: what it does on Discord does not establish Eldgrim's in-world powers, history, or canon.

## Starting point

The existing Babuni Gaming Discord bot is the foundation. Verified on 2026-11-10:
- Python, discord.py 2.7.1, running as a systemd user service on the creative's desktop PC.
- The running copy lives in a local assistant project folder. Since 2026-11-10 its source is also under version control in `~/Projects/eldgrim-bot` (local only, no remote), and a backup of source, configuration, state, and service file exists under `~/Backups/`.
- Provides administration operations with preview and approval, the Roar counter, unified guild ranks, and the Character Forge, where members choose faction, race, and class roles.
- Runs in live mode with Administrator permission.

## Approved direction

**Identity.** The bot appears on Discord as Eldgrim, with its own name and a new profile image. The existing bot is renamed and expanded rather than replaced.

**Hosting.** The bot moves from the desktop PC to the creative's existing server so that it is always online: it welcomes newcomers, runs onboarding, and stores member and character data at any time.

**Administration.** Eldgrim keeps the existing capabilities, including rank management and channel creation.

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

## Open decisions

- Server details (operating system, access, Python version), and how the sync step transfers the addon file to it.
- When Eldgrim's daily moment happens, and whether he answers all mentions gathered since the previous day or only some.
- The new profile image, with its source and usage rights recorded in assets/.
- How replies are written: fixed texts, an AI model, or both. If AI is used, which model and where it runs, and how replies follow character/VOICE.md and interaction/PRINCIPLES.md.
- Whether onboarding replaces or extends the current faction, race, and class roles, and which roles each declared character grants.
- How the bot's current guild ranks (Wanderer, Adventurer, Pathfinder, Trailblazer, Firekeeper) relate to Amberhearth's ranks (Ember, Wayfarer, Kindler, Hearthkeeper, Hearthwarden).
- Where the bot source code lives: in this repository, or in its own repository linked from here.
- What members are told about the data Eldgrim stores, and how a member can change or remove it.
- Whether administration actions stay behind the existing preview-and-approval process when performed by Eldgrim.

## Planned order

1. Put the existing bot under version control and back up its configuration and state. **Done 2026-11-10;** the 51 existing unit tests passed on the new copy.
2. Deploy the unchanged bot on the server and stop the desktop service.
3. Rename the bot to Eldgrim and give it the new profile image. The application name and image are changed by the creative in the Discord Developer Portal.
4. Specify and build multi-character onboarding.
5. Specify and build message reading and replies.
6. Build the addon sync and Eldgrim's database.
