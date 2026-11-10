# Eldgrim

Eldgrim is a character and narrative project set within the wider World of Warcraft Forever roleplaying world. This repository keeps the character's identity, voice, lore, relationship with Amberhearth, and developing narrative experiences in one place. It also contains a separately maintained technical workstream for the Eldgrim World of Warcraft Forever addon.

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

This repository contains two distinct workstreams:

- **Character and narrative:** Eldgrim's public identity, voice, lore, relationships, and stories.
- **Technical addon:** a separate World of Warcraft Forever addon, documented under addon/. Its approved first milestone is a passive local guild-chat recorder.
- **Discord bot:** Eldgrim's presence on the guild Discord server, documented under bot/. The direction is approved; implementation has not started.

The addon is an out-of-character technical project. It does not define Eldgrim's in-world powers, motives, or canon. An initial Lua and TOC implementation now exists under addon/Eldgrim; its in-game behavior and persistence remain unverified.

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
| bot/ | Eldgrim Discord bot direction, open decisions, and planned order |

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for the complete structure and [addon/README.md](addon/README.md) for the addon workstream.

## Canon and secrecy

This is a public repository. Documents here must not disclose concealed character information or private motives intended to remain unknown to the in-world fellowship. Public documentation should describe only what is safe to make public. Private canon must be kept outside this repository unless it is deliberately approved for publication.

Unconfirmed ideas must be labelled as developing, proposed, or open rather than presented as established lore.

## Current status

**Character project:** documentation foundation established.

**Addon:** initial Forever-only Lua/TOC implementation and mock tests exist. Local syntax and mock behavior checks passed; in-game event correlation, profile enrichment, and SavedVariables persistence remain unverified.

**Discord bot:** direction approved; no Eldgrim-specific code or server deployment yet.
