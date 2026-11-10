# Eldgrim

Eldgrim is a character and narrative project set within the wider World of Warcraft Forever roleplaying world. This repository keeps the character's identity, voice, lore, relationship with Amberhearth, and developing narrative experiences in one place. It also documents three separate technical workstreams: the World of Warcraft Forever addon, a proposed local Discord agent, and the always-online Eldgrim Discord bot.

## The foundation

Eldgrim initiated **Amberhearth**, a fellowship conceived as a home for travelers, stories, and companionship. Eldgrim stands outside the fellowship's rank structure rather than occupying a conventional member or officer position.

The name **Eldgrim** replaces the earlier working label **Oracle**. The two names may appear in historical notes, but current documentation should use Eldgrim.

Amberhearth's current rank names are:

- Ember
- Wayfarer
- Kindler
- Hearthkeeper
- Hearthwarden

The rank names are recorded here without assigning duties, privileges, or progression rules that have not been established.

## Project scope

This repository contains four distinct workstreams:

- **Character and narrative:** Eldgrim's public identity, voice, lore, relationships, and stories.
- **Technical addon:** a separate World of Warcraft Forever addon, documented under addon/. Its approved first milestone is a passive local guild-chat recorder.
- **Local agent:** a developing design for a once-daily Python process that uses local Ollama inference, Discord's HTTP API, and a private SQLite database. Its architecture and boundaries are documented under agent/. No agent implementation or deployment exists yet.
- **Discord bot:** Eldgrim's always-online presence on the guild Discord server, documented under bot/. The existing bot runs on the creative's server; renaming and new features are in progress.

The addon, agent, and bot are out-of-character technical projects. None defines Eldgrim's in-world powers, motives, or canon. The addon remains a passive recorder; using its archive in Eldgrim's database is approved but not built. The server bot is Eldgrim's always-online part and the agent its once-daily voice; the agent must not be described as operational until implemented and verified.

The repository remains separate from:

- **ROAR**, the wider creative and development project around World of Warcraft Forever.
- **Amberhearth**, the in-game fellowship initiated by Eldgrim. Guild governance and operations belong in the ROARguild repository.

## Documentation map

| Location | Purpose |
| --- | --- |
| AGENTS.md | Working rules for contributors and AI assistance |
| CONCEPT.md | Core creative direction and project boundaries |
| ROADMAP.md | Staged development, with proposed work distinguished from completed work |
| CHANGELOG.md | Meaningful repository changes |
| docs/ | Documentation standards, decisions, history, and canon policy |
| character/ | Eldgrim's public identity, personality, and voice |
| lore/ | Amberhearth, fires, and the shared mythic setting |
| narrative/ | Story development, quests, and narrative material |
| interaction/ | How Eldgrim appears and communicates within the project |
| assets/ | Visual, audio, and other creative resources |
| templates/ | Reusable formats for future documentation |
| addon/ | Forever-only addon source, specification, API research, data model, and tests |
| agent/ | Local agent architecture, scope, security, memory, and operations documentation |
| bot/ | Eldgrim Discord bot direction, status, open decisions, and planned order |

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for the complete structure, [addon/README.md](addon/README.md) for the addon workstream, and [agent/README.md](agent/README.md) for the agent design.

## Canon and secrecy

This is a public repository. Documents here must not disclose concealed character information or private motives intended to remain unknown to the in-world fellowship. Public documentation should describe only what is safe to make public. Private canon must be kept outside this repository unless it is deliberately approved for publication.

The agent's runtime database, actual conversations, credentials, and private runtime instructions must also remain outside Git. The agent documentation describes public architecture and implementation requirements, not private character secrets or live user data.

Unconfirmed ideas must be labelled as developing, proposed, or open rather than presented as established lore or implemented behavior.

## Current status

**Character project:** documentation foundation established.

**Addon:** initial Forever-only Lua/TOC implementation and mock tests exist. Local syntax and mock behavior checks passed; in-game event correlation, profile enrichment, and SavedVariables persistence remain unverified.

**Agent:** architecture and technical specifications documented as a developing workstream. No Python agent, Discord application integration, SQLite runtime database, systemd unit, or deployment has been implemented or tested.

**Discord bot:** the existing bot runs on the creative's server with a confirmed Discord connection. Renaming, onboarding, and replies are not implemented yet.
