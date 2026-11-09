# Documentation Guide

## Purpose

This guide defines how material is organized and maintained in the Eldgrim repository, including the separate technical addon and local-agent workstreams.

## Status labels

- **Established** — explicitly decided or confirmed.
- **Developing** — actively taking shape; details may change.
- **Proposed** — an idea awaiting approval.
- **Open** — unresolved or intentionally undecided.
- **Retired** — superseded material retained for historical context.

## Technical evidence labels

Use explicit evidence labels in technical research and implementation records:

- **API-documented** — the relevant official API documentation lists the endpoint, event, function, field, or restriction.
- **Inferred** — a proposed implementation follows from documented behavior, but the exact runtime behavior has not been verified.
- **Locally verified** — tested against the installed local software, with versions and reproduction steps recorded.
- **Integration verified** — tested against the actual external service and local application together.
- **In-game verified** — tested in the stated World of Warcraft Forever build, with the build number and reproduction steps recorded.
- **Unverified** — not yet confirmed or tested.

An API entry proves that the service documents an API surface; it does not prove that the intended event sequence or integration works in the target environment. Never infer Forever compatibility from another WoW client or from an interface number alone. Do not claim an agent capability is implemented merely because its API supports it.

## Workstream boundaries

- **Character and narrative:** public character identity, lore, relationships, and stories.
- **Addon:** the separate Forever-only passive recorder described under addon/.
- **Agent:** the proposed local Discord agent described under agent/.
- **Amberhearth operations:** guild governance and administration belong in the ROARguild repository.

The addon and agent must not silently expand one another's scope. Neither technical implementation nor model output establishes character canon.

## Canon layers

- **Public canon:** information safe to present to readers and in-world characters.
- **Production notes:** out-of-character context about writing, design, and development.
- **Private canon:** concealed motives, identity details, or information deliberately withheld from the fellowship. Private canon must not be stored in this public repository.

Do not use hints, euphemisms, or metadata to leak information that is intentionally private.

## Public documentation and private runtime data

The public repository may contain architecture, specifications, source code, tests, and non-sensitive examples. It must not contain:

- Discord bot tokens or other credentials.
- Actual private Discord conversations or message archives.
- Runtime SQLite databases or backups.
- Personal data copied from live users.
- Private character instructions or concealed canon.
- Logs that expose message content, tokens, or personal information.

Agent runtime configuration, memory, secrets, and logs belong in appropriate local directories outside the repository. Use synthetic examples in committed documentation and tests.

## Writing standards

- Separate in-character text from out-of-character explanation.
- Preserve uncertainty where the creative has not settled a detail.
- Attribute creative direction and AI assistance accurately.
- Do not treat brainstorms or generated alternatives as approved decisions.
- Keep entries concise and link to detailed source material.

## Maintenance

Update the relevant source document when a decision changes. Add a concise entry to DECISIONS.md for meaningful decisions and DEVLOG.md for substantial development milestones. Update CHANGELOG.md for repository changes.

For addon work, record the Forever client version, build, interface number, source, and verification status. Keep implementation, automated checks, and in-game testing clearly separate.

For agent work, record the Python and Ollama versions, exact model tag, Discord API behavior, systemd environment, test method, and verification status. Keep documented API capability, local model behavior, Discord integration, and scheduled operational behavior as separate evidence claims.
