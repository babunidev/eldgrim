# Roadmap

This roadmap records areas of development, not promises or fixed deadlines.

## Foundation — established
- [x] Establish Eldgrim as the current character name; retire Oracle as the working label.
- [x] Establish this repository as the character and narrative home.
- [x] Separate Eldgrim, Amberhearth, and technical development into distinct workstreams.
- [x] Establish public-canon and secrecy rules.
- [x] Approve a dedicated World of Warcraft Forever addon workstream without merging it into character canon.

## Character definition — developing
- [ ] Expand the public character profile and presentation.
- [ ] Refine voice principles and example dialogue.
- [ ] Record known behaviors and recurring motifs as they become established.
- [ ] Keep unresolved identity and backstory questions explicitly open.

## Lore and relationships — developing
- [ ] Document the public-facing relationship with Amberhearth.
- [ ] Develop the symbolism and role of fires and gatherings where approved.
- [ ] Record significant in-world relationships and events without inventing chronology.
- [ ] Keep concealed information outside this public repository.

## Narrative and interaction — proposed
- [ ] Collect approved scenes, stories, and narrative fragments.
- [ ] Define interaction patterns only as they emerge from actual roleplay.
- [ ] Preserve examples of Eldgrim's voice with enough context.

## Assets — open
- [ ] Add approved visual or audio assets with provenance and usage notes.

## Eldgrim addon — privacy-first activity counter implemented
- [x] Establish Forever-only support and a separate technical documentation area.
- [x] Define a passive local activity counter for the current guild roster.
- [x] Retain only member names, membership state, and aggregate activity counts.
- [x] Count supported guild, officer, say, yell, whisper, party, raid, instance, custom/community, and emote events from current guild members.
- [x] Aggregate activity by type and calendar day; do not store message contents or individual event records.
- [x] Migrate the previous message archive into aggregate counters and discard message/profile fields in the new schema.
- [x] Add mocked tests for roster updates, member filtering, channel counters, privacy, migration, and lockdown.
- [ ] Verify initial roster loading and member add/remove events in the current Forever client.
- [ ] Verify supported chat-event delivery, full-name matching, and outgoing whisper attribution in-game.
- [ ] Test migration, reload, logout, cold-start persistence, lockdown, and partial roster failures in-game.
- [ ] Inspect the SavedVariables file after the first successful post-migration save and confirm no message text remains.

The addon remains a passive local activity counter. A documented task is not an implemented feature, and API documentation or mocked tests are not in-game verification.
