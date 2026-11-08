# Eldgrim Addon

A separate technical workstream for the Eldgrim World of Warcraft Forever addon.

## Current milestone

**Approved scope:** a passive, local guild-chat recorder.

The addon listens only to guild chat, records the character name, message, timestamp, and available human-readable character information, then persists the archive through account-wide SavedVariables.

It has no in-game interface, slash commands, chat output, notifications, sounds, addon messages, network communication, AI, summaries, or interpretation. It does not record officer chat or other channels.

## Status

**Documentation prepared; implementation not started.**

No addon source files, installable package, automated tests, or in-game verification exist yet.

## Documents

- [SPECIFICATION.md](SPECIFICATION.md) — approved behavior, stored fields, and local data model.
- [API_RESEARCH.md](API_RESEARCH.md) — Forever-specific API findings, source links, and unresolved behavior.
- [TEST_PLAN.md](TEST_PLAN.md) — required in-game checks before the recorder can be considered working.

## Compatibility

World of Warcraft Forever only. Current research baseline: version 1.60.1, interface 16001. The latest public build found during the initial research was 1.60.1.70862 (2026-11-07). Recheck the client build and API after updates.

This addon project is separate from Eldgrim's in-world character canon and from Amberhearth guild administration.
