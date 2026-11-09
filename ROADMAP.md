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

## Eldgrim addon — expanded scope approved; implementation created
- [x] Establish Forever-only support and a separate technical documentation area.
- [x] Define a passive local archive of the current guild roster and member conversations.
- [x] Research the Forever guild roster, chat-event, community-message, and lockdown APIs.
- [x] Implement event-driven guild roster synchronization and member entries.
- [x] Implement member-only recording across supported player-chat channels, including officer chat and outgoing whisper attribution.
- [x] Preserve existing guild-chat history through schema migration and retain former-member archives.
- [x] Add mocked tests for roster updates, member filtering, channel capture, timestamps, migration, and technical-field exclusion.
- [ ] Verify initial roster loading and member add/remove/update events in the current Forever client.
- [ ] Verify every supported chat event, full-name matching, and outgoing whisper attribution in-game.
- [ ] Test reload, logout, cold-start persistence, lockdown, and partial roster failures in-game.
- [ ] Verify that the addon has no visible or audible output and no custom addon messages or external services.

The addon remains a passive local archive. A documented task is not an implemented feature, and API documentation or mocked tests are not in-game verification.
