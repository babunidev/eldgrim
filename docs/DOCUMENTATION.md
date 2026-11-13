# Documentation Guide

## Author voice and AI attribution

Write project documentation in Babuni’s first-person voice. Tell readers what prompted the work, which choices shaped it, and how the experience unfolded from Babuni’s point of view. Recast third-person author narration such as “Babuni requested” as first-person prose. Use “I” and “my” naturally within sentences and vary the openings. Never begin a narrative sentence with “I” or “My.” Use **creative** as the role label. Keep technical facts, commands, and tables direct. Keep changelogs neutral and limited to what actually changed. Preserve established viewpoints in fiction and in-world material, and retain original quotations, credits, and legal notices.

Whenever AI contributed, identify the tool or product by name and give the exact model name or version when it can be verified. Say what each tool and model actually did, including research, proposals, drafting, asset generation, coding, or testing as applicable. If the tool is known but the model is undocumented, say the model was not recorded. If the tool itself cannot be verified, say it was not recorded. Never guess or infer a model from the date, provider, or product name. Keep the human creative’s ideas, decisions, and firsthand observations distinct from AI contributions and distinguish proposals, implementation, and verified results. Put this attribution in the relevant narrative or collaboration record so the changelog can stay focused on changes.

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
- **Agent:** the local, once-daily Discord agent described under agent/.
- **Bot:** the always-online Eldgrim Discord bot described under bot/. Its source lives in a separate private repository.
- **Eldgrim governance:** the public, non-ratified chapter-by-chapter framework and refinement questions belong in governance/. The binding Amberhearth charter and guild operations remain in ROARguild.

The addon, agent and bot must not silently expand one another's scope. Neither technical implementation nor model output establishes character canon.

## Governance rulebook

The [governance index](../governance/README.md) links all 16 chapters of the working framework. Each chapter records a source baseline, its decision status, and a refinement queue. A proposal does not become binding merely by appearing in a chapter; approved guild-wide rules must also be reconciled with ROARguild. Never place private character canon in the public rulebook.

## Completed governance interview

All **193** numbered questions are founder-confirmed in [QUESTION-DECISIONS.md](../governance/QUESTION-DECISIONS.md). The [consistency audit](../governance/CONSISTENCY-AUDIT.md) identifies known contradictions, stale drafts and missing procedures; the [implementation matrix](../governance/IMPLEMENTATION-MATRIX.md) maps requirements to components, tests and verification evidence. The interview is complete, but a **binding charter** requires Q161 ratification and **new autonomous administration** requires Q170 verification and explicit founder deployment approval. Never mark an untested feature implemented or infer adoption from a documentation commit.

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

## Final agent character draft

The final character instructions must combine the public character and voice guides with the private origin held on the founder's computer. A separate private supplement dated 11 November 2026 was named but is not on disk; if it is written, it is read too. Both are deliberately excluded from this public repository. See agent/README.md for the drafting requirement; never copy the private material into repository files or public outputs, and do not hint at it through code, tests or examples.
