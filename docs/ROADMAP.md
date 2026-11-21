# Roadmap

This roadmap records areas of development, not promises or fixed deadlines. A checked item is built or decided; it is not proof that it works in game or on Discord unless the item says so. Updated 21 November 2026.

## Next

- [ ] Restart the Forever client and check the hearth board, the guild-panel flame and the ember sync before the first ember starts on Sunday 22 November 2026, 00:00 UTC. The two-client checks are listed in [addon/HEARTH.md](../addon/HEARTH.md).
- [ ] Go through the Character Forge again and keep only Jasmine Amberbrew.
- [ ] Watch the first live run with the smaller reading, fire items and places by level.
- [ ] Write the third ember card before its week begins.

## Foundation — established

- [x] Establish Eldgrim as the current character name; retire Oracle as the working label.
- [x] Establish this repository as the character and narrative home.
- [x] Separate Eldgrim, Amberhearth, and technical development into distinct workstreams.
- [x] Establish public-canon and secrecy rules.
- [x] Approve a dedicated World of Warcraft Forever addon workstream without merging it into character canon.
- [x] Keep only README.md, AGENTS.md, LICENSE and CHANGELOG.md at the root; all other documentation lives in docs/.

## Character definition — developing

- [x] Set the private origin roots on the founder's computer. Public pages keep the setting and do not carry the origin.
- [x] Give Eldgrim a public self for every call (character/SELF.md) and a recognizable closing, "Keep the fire."
- [ ] At the first runs, confirm Eldgrim knows those roots, then let it draft a further story and a presence for the creative to accept.
- [ ] Expand the public character profile and presentation.
- [ ] Refine voice principles and example dialogue.
- [ ] Record known behaviors and recurring motifs as they become established.
- [ ] Keep unresolved identity and backstory questions explicitly open.

## Lore and relationships — developing

- [x] Catalog fire-themed items with their level and source (lore/FIRE_ITEMS.md), and keep items without a named source out of errands.
- [x] Record the places Eldgrim knows, with level bands, sides and a picture of each land (lore/WORLD.md).
- [ ] Document the public-facing relationship with Amberhearth.
- [ ] Develop the symbolism and role of fires and gatherings where approved.
- [ ] Record significant in-world relationships and events without inventing chronology.
- [ ] Keep concealed information outside this public repository.

## Narrative and interaction — developing

- [x] Keep the weekly ember texts in narrative/EMBERS.md.
- [ ] Collect approved scenes, stories, and narrative fragments.
- [ ] Define interaction patterns only as they emerge from actual roleplay.
- [ ] Preserve examples of Eldgrim's voice with enough context.

## Assets — open

- [ ] Add approved visual or audio assets with provenance and usage notes.

## Eldgrim addon — recorder and hearth board built; not tested in game

- [x] Establish Forever-only support and a separate technical documentation area.
- [x] Define the first milestone as passive, local guild-chat recording.
- [x] Define the compact character-profile and timestamped-message data model.
- [x] Research the relevant Forever API surface and document its limitations.
- [x] Implement the recorder using account-wide SavedVariables. The daily run has read real guild chat from it.
- [x] Build the hearth board (0.4.0-alpha): the weekly ember only Jasmine Amberbrew can publish, member quests, the guild-panel flame, and a one-way guild-chat relay. Mock tests passed.
- [x] Edit the addon in addon/Eldgrim/ and install it with addon/install-local.sh.
- [ ] Record the exact client build and run the in-game checks in addon/TEST_PLAN.md.
- [ ] Verify chat-event and community-message correlation in the current Forever client.
- [ ] Verify character enrichment and Forever race-name mapping in-game.
- [ ] Test reload, logout, cold-start persistence, chat lockdown, and missing profile data in-game.
- [ ] Verify that the archive records no unrelated channels.
- [ ] Run the hearth board's two-client checks in addon/HEARTH.md.

The addon stays within addon/SPECIFICATION.md and addon/HEARTH.md until the creative approves a broader scope. A documented task is not an implemented feature, and API documentation is not an in-game test.

## Eldgrim Discord bot — running on the server

- [x] Approve Eldgrim's Discord presence based on the existing Babuni Gaming bot.
- [x] Put the existing bot under version control and back it up. Its source lives in the gitignored bot/private.
- [x] Move the bot to the creative's server.
- [x] Rename the bot to Eldgrim and give it a new profile image.
- [x] Use Amberhearth's ranks in every bot text.
- [x] Build and deploy the Character Forge, and approve its texts.
- [x] Hide the public channels behind the ranks and restart every member except the server owner at Ember.
- [x] Ask Roar or Amberhearth before characters, and retire the automatic Roar role for every rank.
- [x] Take one character per member in the Forge (2026-11-20).
- [x] Hold mentions in the Eldgrim channel until the daily run, mark them with a fire, and answer an info mention at once by direct message.
- [x] Open a private thread for a quest ask, and stage quest and ember proofs witnessed with the Roar.
- [x] Post the daily announcement, the Hearth Keepers note, quests and replies for the local agent.
- [ ] Reconcile the manual preview-and-approval workflow with validated, audited administration tools (Q141–150) before any autonomous administration.

## Eldgrim governance — working framework, not ratified

- [x] Record the 10 November 2026 working framework as 16 editable chapters under governance/.
- [x] Record the founder's answers to all 193 interview questions. This is a working record, not a ratified charter.
- [x] Audit the chapters Eldgrim reads on every call, and correct chapters 01 and 15 (2026-11-21).
- [ ] Close the remaining conflicts in governance/14-conflicts-and-gaps.md and ratify the rule set. Until then it does not turn on AI administration.

## Eldgrim local agent — daily runner built

### Documentation foundation — complete

- [x] Establish agent/ as a third, separate technical workstream.
- [x] Document the once-daily, one-shot execution model.
- [x] Document the mention scope and the Message Content Intent boundary.
- [x] Document the local Ollama model lifecycle.
- [x] Document SQLite memory boundaries and a conceptual data model.
- [x] Document tool permissions, prompt-injection defenses, and local secret handling.
- [x] Document the operations: the one-shot service and the system wake timer.

### Daily runner — built

- [x] A one-shot `eldgrim run` that runs in steps (`prepare`, `quests`, `replies`, `announce`, `ranks`, `choose`), each able to run alone (2026-11-20).
- [x] Run the local model through Ollama, load it for the run and unload it after. The runs use `qwen3:8b`. The model gets no tools: each call is a prompt and its answer is checked by code.
- [x] Read mentions and proofs from the server bot instead of polling Discord, and delete the staged copies after the run.
- [x] Keep the roster, keywords, standing and quests in a local SQLite database outside the repository (2026-11-12).
- [x] Reply once to each member who wrote in the Eldgrim channel, seeing only that member's character (tested with synthetic letters on 19 November 2026).
- [x] Send quests: a bonfire first, then fire items and places that fit the character's level and side (2026-11-21).
- [x] Record witnessed weekly embers and write them into the installed addon's verified file.
- [x] Recommend rank changes to the Hearth Keepers by score and overall positivity.
- [x] Read only the pages and sections each task needs, from agent/context.toml (2026-11-21).
- [x] Wake the computer at the moment Eldgrim chooses with a root-owned system timer, proven by `eldgrim wake-test` on 12 November 2026, and leave sleep to the desktop.
- [x] Record the model tag and the Ollama server version in each run log, as docs/DOCUMENTATION.md asks (2026-11-21). The server reported 0.40.6.
- [ ] Test rate limits, missed runs and restart recovery against live Discord.
- [ ] Add migrations and a tested backup of the database, within Q137's 30-day limit.

### Later autonomy — proposed and separately gated

- [ ] An allowlisted tool dispatcher with independent validation, before any administration (Q141–150, Q170).
- [ ] Owner-controlled memory inspection, export, correction, and deletion.
- [ ] Scheduled internal intentions and follow-up handling.
- [ ] Proactive messages in explicitly approved channels, with cooldowns and strict daily limits.
- [ ] Semantic retrieval, only if SQLite text search proves insufficient.

Administration is still design until it is implemented, tested and authorized by the founder (Q170).
