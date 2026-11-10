# Changelog

Meaningful repository and documentation changes are recorded here.

## 2026-11-10

- Fixed the Forge to ask for each character's first name and surname, following WoW Forever's naming rules.
- Deployed the multi-character Forge with the approved texts; the rank and channel switches stay off until the creative has tested it.
- Recorded that every member except the server owner restarts at Ember through the Forge, and that the hearth rules name guild activity recorded in the game (chat, emotes, presence at events).
- Recorded that Eldgrim is an entity referred to as "it", and corrected the documents accordingly.
- Recorded that Eldgrim governs the guild's Discord by defined goals rather than member requests, and that the creative follows its recommendations.
- Recorded the multi-character Forge design: Forge role on arrival, hearth rules, any number of characters, Ember on completion, public channels visible to ranks only, and every member except the owner passing through. Built and tested offline in the bot repository; not yet deployed.

- Recorded the approved direction for Eldgrim's Discord presence: rename and expand the existing guild bot, move it to an always-online server, and add multi-character onboarding, once-daily replies to @Eldgrim mentions, and a member and character database.
- Added bot/README.md with the approved direction, status, proposed data flow, open decisions, and planned order.
- Recorded that Amberhearth's ranks are used everywhere, including Discord, and that addon development continues in a separate environment.
- Recorded that the bot now runs on the creative's server under its own account.
- Merged the 2026-11-09 local-agent documentation with the Discord bot direction.
- Recorded how they fit together: the server bot is Eldgrim's always-online part, the local agent its once-daily voice. Approved AI-triggered administration through the bot's validated operations and use of the addon's archive; updated the agent documents and instructions accordingly.

## 2026-11-09

- Added the Eldgrim local-agent documentation workstream under agent/.
- Documented a once-daily, one-shot Python process using Discord REST polling, local Ollama tool calling, SQLite memory, and a systemd user timer.
- Documented the initial explicit-mention communication scope and the decision not to request Discord's privileged Message Content Intent.
- Added architecture, scope, security, memory, and operations documents.
- Updated project instructions, concept, roadmap, repository map, decisions, and development history to distinguish the proposed agent from the existing Forever addon.
- Documentation only: no Python agent, Discord application integration, runtime database, systemd unit, credentials, or deployment was created or tested.

## 2026-11-08

- Established the initial Eldgrim repository documentation foundation.
- Added contributor guidance, concept, roadmap, documentation policy, decisions, and development history.
- Added structured areas for character, lore, narrative, interaction, assets, and templates.
- Recorded the distinction between public character material, Amberhearth guild operations, and technical development.
- Documented the approved Forever-only Eldgrim addon scope: a passive local guild-chat recorder with compact character profiles and timestamped messages.
- Added Forever API research, data-model specification, and an in-game test plan.
- Added the initial Eldgrim Forever addon source and TOC manifest under addon/Eldgrim/ (version 0.1.0-alpha, interface 16001).
- Added a repeatable mock test harness under addon/tests/; Lua syntax validation and mocked behavior checks passed with texlua.
- No in-game tests, public tags, GitHub Releases, or CurseForge publication were performed.

This changelog describes repository changes, not in-world events.
