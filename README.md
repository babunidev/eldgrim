# Eldgrim

Eldgrim is a mysterious presence in the **Amberhearth** fellowship on World of Warcraft Forever. This repository is where its public character, stories and future ways of interacting with the guild take shape.

The character is part of an unfolding roleplaying story. The software that supports that story—Discord bot, local AI agent and game addon—is documented separately. **A technical feature does not define Eldgrim's in-world powers or establish new canon.**

## Begin with the story

Eldgrim set the idea of Amberhearth in motion. The fellowship has since been founded by Jasmine Amberbrew, who gathered signatures in Kharanos after hearing a voice at the campfires.

A few entry points:

- [Character](character/README.md) — who Eldgrim appears to be, and how it speaks.
- [Lore](lore/README.md) — the hearth, the fires, and the lands Eldgrim may name.
- [Narrative](narrative/README.md) — developing stories and in-world material.
- [Interaction](interaction/README.md) — how Eldgrim appears and communicates.

Only public-safe details belong here. Deliberately concealed character information is not published in the repository.

## What is being built

| Part | Purpose | Current position |
| --- | --- | --- |
| [Discord bot](bot/README.md) | Always-online member onboarding and authorized server operations | Running on the server; Character Forge and rank handling are documented as live |
| [Local agent](agent/README.md) | A once-daily voice and bounded decision process using Ollama on the creative's PC | Runs daily: the announcement, quests, replies and the Hearth Keepers note are posted through the bot. Autonomous administration is not implemented |
| [WoW Forever addon](addon/README.md) | Passive recording of permitted guild-facing information, and the hearth board with the weekly ember | Built; mock checks pass; the formal in-game checks have not been run |
| [Governance rulebook](governance/README.md) | Chapter-by-chapter framework for proposed stewardship, rights and safeguards | Working draft; **not a ratified charter** |

Eldgrim is an entity, referred to as **it**. The old working label *Oracle* survives only in earlier records.

The bot and agent have different jobs: the bot keeps its verified server-side functions running, while the local agent runs once a day on the creative's computer. The addon's guild-chat archive is read by that daily run. A connection that is only specified is not described as operational.

## The governance chapters

The [rulebook](governance/README.md) divides the framework into sixteen readable chapters, from the fellowship's identity and social rules through privacy, appeals, technical limits and unresolved constitutional questions. Its numbered decision register records founder answers separately from adopted guild policy.

**Guild-wide binding rules and operations belong in [ROARguild](https://github.com/babunidev/ROARguild)**. A design approved for refinement does not automatically become enforceable policy or authorize new autonomous action.

## Following the development

| Question | Document |
| --- | --- |
| What is the core vision? | [Concept](docs/CONCEPT.md) |
| What comes next? | [Roadmap](docs/ROADMAP.md) |
| Which decisions are established or still open? | [Decisions](docs/DECISIONS.md) |
| How did the project develop? | [Development journal](docs/DEVLOG.md) · [Changelog](CHANGELOG.md) |
| How does it fit together? | [Project structure](docs/PROJECT_STRUCTURE.md) |
| How should code and documentation be handled? | [AGENTS.md](AGENTS.md) · [Documentation guide](docs/DOCUMENTATION.md) |

This is a public repository. Credentials, runtime member data, private messages, local agent memory and concealed character instructions stay outside Git. Technical records distinguish source-level design, tests, live integration and unverified plans.

## License

Original bot, agent and addon code are licensed under [MIT](LICENSE). Eldgrim's character, lore and guild-associated creative content are not automatically included; see [asset rights](docs/ASSET_RIGHTS.md).
