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

## Eldgrim addon — approved scope; initial implementation created

- [x] Establish Forever-only support and a separate technical documentation area.
- [x] Define the first milestone as passive, local guild-chat recording.
- [x] Define the compact character-profile and timestamped-message data model.
- [x] Research the relevant Forever API surface and document its limitations.
- [ ] Verify chat-event and community-message correlation in the current Forever client.
- [ ] Verify character enrichment and Forever race-name mapping in-game.
- [x] Implement the initial recorder using account-wide SavedVariables.
- [ ] Test reload, logout, cold-start persistence, chat lockdown, and missing profile data in-game.
- [ ] Verify that the addon has no visible or audible output and records no unrelated channels.

## Eldgrim Discord bot — direction approved
- [x] Approve Eldgrim's Discord presence based on the existing Babuni Gaming bot.
- [x] Put the existing bot under version control and back it up.
- [x] Move the bot to the creative's server.
- [x] Rename the bot to Eldgrim and give it a new profile image.
- [x] Replace the former rank names remaining in bot texts with Amberhearth's ranks.
- [x] Specify and build multi-character onboarding, and deploy it.
- [x] Approve the Forge texts.
- [x] Hide the public channels behind the ranks and restart every member except the server owner at Ember.
- [x] Accept one character name or two, and call unregistered members in the Forge and by direct message.
- [ ] Specify, build, and test once-a-day replies to @Eldgrim mentions.
- [ ] Transfer addon data to the server and build Eldgrim's database.

The addon remains a recorder only until the creative approves a broader scope. A documented task is not an implemented feature, and API documentation is not an in-game test.

## Eldgrim local agent — architecture documented; implementation not started

### Documentation foundation — complete

- [x] Establish agent/ as a third, separate technical workstream.
- [x] Document the once-daily, one-shot execution model.
- [x] Document Discord REST polling, explicit-mention scope, and the Message Content Intent boundary.
- [x] Document local Ollama tool calling and model lifecycle.
- [x] Document SQLite memory boundaries and a conceptual data model.
- [x] Document tool permissions, prompt-injection defenses, and local secret handling.
- [x] Document intended systemd user timer and service operations.

### Foundation implementation — proposed

- [ ] Verify the installed Ollama version, local model tag, and Qwen3 tool-calling behavior.
- [ ] Create/configure the Discord application and bot with only the required channel permissions.
- [ ] Verify mention-only message content through the Discord HTTP API without enabling Message Content Intent.
- [ ] Implement the one-shot Python entry point and configuration validation.
- [ ] Implement REST polling, cursor pagination, deduplication, and safe checkpoint commits.
- [ ] Implement the SQLite schema, migrations, backup, and memory search.
- [ ] Implement the bounded Ollama tool-call loop and allowlisted tool dispatcher.
- [ ] Implement direct replies with safe mention handling and per-run limits.
- [ ] Implement a private systemd user service and daily calendar timer.
- [ ] Test failures, rate limits, missed runs, duplicate prevention, model unloading, and restart recovery.

### Later autonomy — proposed and separately gated

- [ ] Add owner-controlled memory inspection, export, correction, and deletion.
- [ ] Evaluate scheduled internal intentions and follow-up handling.
- [ ] Consider proactive messages in explicitly approved channels, with cooldowns and strict daily limits.
- [ ] Evaluate semantic retrieval only if SQLite text search proves insufficient.
- [ ] Consider any addon-data integration only through a separate approved specification.

The agent remains a documentation-only design until implementation and integration tests are completed. The daily schedule time, channel allowlist, data-retention policy, and proactive-posting scope remain open decisions.
