# Eldgrim Addon

A separate technical workstream for the Eldgrim World of Warcraft Forever addon. The source is this folder. A local test copies `Eldgrim/` into the Forever AddOns folder.

## Current scope

The archive is still the guild-chat recorder in [SPECIFICATION.md](SPECIFICATION.md). Version 0.4.0-alpha adds the hearth board in [HEARTH.md](HEARTH.md): a weekly ember that only Jasmine Amberbrew can publish, member quests, and a one-way relay of guild chat. The board has not been tested in game.

The archive does not record officer chat or other channels. A guild line relayed by one member is kept with the name of the person who passed it on, and the daily run does not score it.

## Status

**Hearth board implemented; in-game verification pending.**

The installable addon source is in `Eldgrim/`:
- `Eldgrim/Eldgrim.toc` — Forever manifest and account-wide SavedVariables declaration.
- `Eldgrim/EldgrimEmbers.lua` — the weekly ember. Shipped copies stay at revision 0.
- `Eldgrim/EldgrimVerified.lua` — witnessed ember completions, written by the daily run on Jasmine Amberbrew's machine. Shipped copies stay empty.
- `Eldgrim/Eldgrim.lua` — guild-chat archive, daily roster, and the invite whisper.
- `Eldgrim/EldgrimSync.lua` — guild sync and the chat relay.
- `Eldgrim/EldgrimSkin.lua` — the frame, buttons, text fields, lists and scroll areas.
- `Eldgrim/EldgrimBoard.lua` — the hearth window and the guild-panel flame.
- `Eldgrim/EldgrimFlame.tga` — the flame emblem.
- `Eldgrim/EldgrimCorner.tga`, `EldgrimCornerSmall.tga`, `EldgrimButton.tga`, `EldgrimField.tga`, `EldgrimGlyphs.tga` — the frame corners, buttons, fields and small glyphs.

`tools/hearth_art.py` draws every texture. `tools/preview/preview.sh <folder>` renders the board from sample data, for checking the layout outside the game.

Mocked checks live in `tests/test_recorder.lua`, `tests/test_hearth.lua` and `tests/test_board.lua`. They passed locally. That does not establish that the APIs or the event sequence work in game.

## Install for local testing

From the repository root:

```sh
addon/install-local.sh
```

That copies the files in `Eldgrim/` into the Forever client's `Interface/AddOns/Eldgrim/`. It does not copy the game folder back into the repository. The script compares every file. If an installed file differs and is newer than the project copy, it stops, names the file, and leaves the installed files in place. An installed `EldgrimVerified.lua` is never replaced, even with `--force`, because the daily run writes it. A newer installed `EldgrimEmbers.lua` is left in place even when the rest is copied, so a weekly ember edited on this machine is not replaced by the blank shipped file. `addon/install-local.sh --force` replaces the installed copy with the project copy, including the ember file.

Then:

1. Enable **Eldgrim** in the AddOns list at the character-selection screen.
2. Open the guild panel and use the flame, or type `/eldgrim log`. Restart the client after new or changed textures; `/reload` is not enough.
3. `/eldgrim` with no other text still whispers the guild invitation to the target.
4. Log out normally, then inspect `WTF/Account/<account>/SavedVariables/Eldgrim.lua`.

SavedVariables are written by the game during its normal save lifecycle, not immediately to disk after each message. Do not inspect or edit the file while the client is running.

## Documents and tests

- [SPECIFICATION.md](SPECIFICATION.md) — the archive: stored fields and local data model.
- [HEARTH.md](HEARTH.md) — the hearth board, the ember, member quests, and the relay.
- [API_RESEARCH.md](API_RESEARCH.md) — Forever-specific API findings, source links, and unresolved behavior.
- [TEST_PLAN.md](TEST_PLAN.md) — required in-game checks. The hearth checks are not done.
- [tests/test_recorder.lua](tests/test_recorder.lua) — mocked archive test.
- [tests/test_hearth.lua](tests/test_hearth.lua) — mocked hearth-board test.
- [tests/test_names.lua](tests/test_names.lua) — mocked check that the master is found by full name and the ember publishes.
- [tests/test_board.lua](tests/test_board.lua) — mocked hearth-window test: buttons, the quest form, and dates.

Run the mock tests from the repository root with:

```sh
lua addon/tests/test_recorder.lua addon/Eldgrim/Eldgrim.lua
lua addon/tests/test_hearth.lua addon/Eldgrim
lua addon/tests/test_board.lua addon/Eldgrim
lua addon/tests/test_names.lua addon/Eldgrim
```

## Future integration privacy boundary (Q126)

The existing first milestone stores raw guild-chat records locally in SavedVariables. Under confirmed governance Q126, those raw records may be used as **temporary source material** only. Long-term member/character memories should retain relevant supported interpretations rather than verbatim quotations. The reading, keyword comparison, internal standing and message-list cleanup are specified in [agent/ROSTER.md](../agent/ROSTER.md). The addon does not delete the master's archive. A client already being played may write an `EldgrimRoster` table into the same file; the agent specification accepts that table when it is present. The hearth relay can send held guild lines to Jasmine Amberbrew and does not keep a second copy after the ack. The board does not score anyone.

## Compatibility

World of Warcraft Forever only. Manifest interface: 16001. The latest public build found during research was 1.60.1.70862 (2026-11-07). Recheck the installed client build and API after updates.

The race-name table includes the Forever race IDs. High Order Skyborne ID 95 is sourced from pre-launch 1.60.1 data and still needs confirmation against the installed live client. Unknown race values are omitted.

This addon project is separate from Eldgrim's in-world character canon and from Amberhearth guild administration.
