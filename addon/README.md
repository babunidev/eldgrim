# Eldgrim Addon

A separate technical workstream for the Eldgrim World of Warcraft Forever addon.

## Current milestone

**Approved scope:** a passive, local guild-chat recorder.

The addon listens only to guild chat, records the character name, message, timestamp, and available human-readable character information, then persists the archive through account-wide SavedVariables.

It has no in-game interface, slash commands, chat output, notifications, sounds, addon messages, network communication, AI, summaries, or interpretation. It does not record officer chat or other channels.

## Status

**Initial implementation created; in-game verification pending.**

The installable addon source is in `Eldgrim/`:
- `Eldgrim/Eldgrim.toc` — Forever manifest and account-wide SavedVariables declaration.
- `Eldgrim/Eldgrim.lua` — passive guild-chat recorder.

A repeatable mocked test is in `tests/test_recorder.lua`. Syntax and mocked behavior checks passed locally. This does not establish that the APIs or event sequence work in-game.

## Install for local testing

1. Copy the `Eldgrim/` directory into the Forever client's `Interface/AddOns/` directory.
2. Confirm the resulting paths are `Interface/AddOns/Eldgrim/Eldgrim.toc` and `Interface/AddOns/Eldgrim/Eldgrim.lua`.
3. Enable **Eldgrim** in the AddOns list at the character-selection screen.
4. Send and receive guild messages.
5. Log out normally, then inspect `WTF/Account/<account>/SavedVariables/Eldgrim.lua`.

The addon intentionally has no commands or visible confirmation. SavedVariables are written by the game during its normal save lifecycle, not immediately to disk after each message. Do not inspect or edit the file while the client is running.

## Documents and tests

- [SPECIFICATION.md](SPECIFICATION.md) — approved behavior, stored fields, and local data model.
- [API_RESEARCH.md](API_RESEARCH.md) — Forever-specific API findings, source links, and unresolved behavior.
- [TEST_PLAN.md](TEST_PLAN.md) — required in-game checks before the recorder can be considered working.
- [tests/test_recorder.lua](tests/test_recorder.lua) — mocked behavior and syntax test.

Run the repeatable mock test from the repository root with:

```sh
texlua addon/tests/test_recorder.lua addon/Eldgrim/Eldgrim.lua
```

## Compatibility

World of Warcraft Forever only. Manifest interface: 16001. The latest public build found during research was 1.60.1.70862 (2026-11-07). Recheck the installed client build and API after updates.

The race-name table includes the Forever race IDs. High Order Skyborne ID 95 is sourced from pre-launch 1.60.1 data and still needs confirmation against the installed live client. Unknown race values are omitted.

This addon project is separate from Eldgrim's in-world character canon and from Amberhearth guild administration.
