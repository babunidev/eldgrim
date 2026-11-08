# Documentation Guide

## Purpose
This guide defines how material is organized and maintained in the Eldgrim repository, including the separate technical addon workstream.

## Status labels
- **Established** — explicitly decided or confirmed.
- **Developing** — actively taking shape; details may change.
- **Proposed** — an idea awaiting approval.
- **Open** — unresolved or intentionally undecided.
- **Retired** — superseded material retained for historical context.

## Technical evidence labels
Use explicit evidence labels in addon research:
- **API-documented** — the Forever API documentation lists the event, function, field, or restriction.
- **Inferred** — a proposed implementation follows from documented API behavior, but the exact runtime behavior has not been verified.
- **In-game verified** — tested in the stated World of Warcraft Forever build, with the build number and reproduction steps recorded.
- **Unverified** — not yet confirmed or tested.

An API entry proves that the client documents an API surface; it does not prove that a particular event sequence or data association works in-game. Never infer Forever compatibility from another WoW client or from an interface number alone.

## Canon layers
- **Public canon:** information safe to present to readers and in-world characters.
- **Production notes:** out-of-character context about writing, design, and development.
- **Private canon:** concealed motives, identity details, or information deliberately withheld from the fellowship. Private canon must not be stored in this public repository.

Do not use hints, euphemisms, or metadata to leak information that is intentionally private.

## Writing standards
- Separate in-character text from out-of-character explanation.
- Preserve uncertainty where the creative has not settled a detail.
- Attribute creative direction and AI assistance accurately.
- Do not treat brainstorms or generated alternatives as approved decisions.
- Keep entries concise and link to detailed source material.

## Maintenance
Update the relevant source document when a decision changes. Add a concise entry to DECISIONS.md for meaningful decisions and DEVLOG.md for substantial development milestones. Update CHANGELOG.md for repository changes.

For addon work, record the Forever client version, build, interface number, source, and verification status. Keep implementation, automated checks, and in-game testing clearly separate.
