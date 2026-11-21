# Project Structure

    eldgrim/
    ├── README.md
    ├── AGENTS.md
    ├── LICENSE
    ├── CHANGELOG.md
    ├── addon/
    │   ├── API_RESEARCH.md
    │   ├── HEARTH.md
    │   ├── install-local.sh
    │   ├── README.md
    │   ├── SPECIFICATION.md
    │   ├── TEST_PLAN.md
    │   ├── Eldgrim/
    │   │   ├── Eldgrim.lua
    │   │   ├── Eldgrim.toc
    │   │   ├── EldgrimBoard.lua
    │   │   ├── EldgrimButton.tga
    │   │   ├── EldgrimCorner.tga
    │   │   ├── EldgrimCornerSmall.tga
    │   │   ├── EldgrimEmbers.lua
    │   │   ├── EldgrimField.tga
    │   │   ├── EldgrimFlame.tga
    │   │   ├── EldgrimGlyphs.tga
    │   │   ├── EldgrimSkin.lua
    │   │   ├── EldgrimSync.lua
    │   │   └── EldgrimVerified.lua
    │   ├── tests/
    │   │   ├── test_board.lua
    │   │   ├── test_hearth.lua
    │   │   ├── test_names.lua
    │   │   └── test_recorder.lua
    │   └── tools/
    │       ├── hearth_art.py
    │       └── preview/
    │           ├── preview.lua
    │           ├── preview.sh
    │           ├── render.py
    │           └── wowmock.lua
    ├── agent/
    │   ├── ANNOUNCEMENT.md
    │   ├── ARCHITECTURE.md
    │   ├── CAPABILITIES.md
    │   ├── context.toml
    │   ├── MEMORY.md
    │   ├── OPERATIONS.md
    │   ├── README.md
    │   ├── ROSTER.md
    │   ├── SECURITY.md
    │   ├── SPECIFICATION.md
    │   ├── eldgrim_agent/
    │   │   ├── __init__.py
    │   │   ├── __main__.py
    │   │   ├── announce.py
    │   │   ├── census.py
    │   │   ├── chatfile.py
    │   │   ├── choose.py
    │   │   ├── cli.py
    │   │   ├── clock.py
    │   │   ├── compare.py
    │   │   ├── context.py
    │   │   ├── discord_post.py
    │   │   ├── embers.py
    │   │   ├── keywords.py
    │   │   ├── lua_saved.py
    │   │   ├── mentions.py
    │   │   ├── officer.py
    │   │   ├── ollama.py
    │   │   ├── paths.py
    │   │   ├── people.py
    │   │   ├── quests.py
    │   │   ├── refresh.py
    │   │   ├── run.py
    │   │   ├── schedule.py
    │   │   ├── standing.py
    │   │   └── store.py
    │   ├── systemd/
    │   │   ├── eldgrim-arm.path
    │   │   ├── eldgrim-arm.service
    │   │   ├── eldgrim-daily.service
    │   │   ├── eldgrim-wake-helper
    │   │   └── install-wake.sh
    │   └── tests/
    │       ├── test_clock.py
    │       ├── test_context.py
    │       ├── test_mentions.py
    │       ├── test_post.py
    │       ├── test_quests.py
    │       ├── test_roster.py
    │       ├── test_run.py
    │       └── test_standing.py
    ├── assets/
    │   └── README.md
    ├── bin/
    │   └── eldgrim
    ├── bot/
    │   └── README.md
    ├── character/
    │   ├── PROFILE.md
    │   ├── README.md
    │   ├── SELF.md
    │   └── VOICE.md
    ├── docs/
    │   ├── AI_COLLABORATION.md
    │   ├── ASSET_RIGHTS.md
    │   ├── CONCEPT.md
    │   ├── DECISIONS.md
    │   ├── DEVLOG.md
    │   ├── DOCUMENTATION.md
    │   ├── PROJECT_STRUCTURE.md
    │   └── ROADMAP.md
    ├── governance/
    │   ├── 01-established-foundation.md
    │   ├── 02-identity-and-purpose.md
    │   ├── 03-social-rules.md
    │   ├── 04-ranks-and-membership.md
    │   ├── 05-eldgrims-authority.md
    │   ├── 06-daily-conduct-and-communication.md
    │   ├── 07-member-evaluation-and-standing.md
    │   ├── 08-quests-recognition-and-rewards.md
    │   ├── 09-sunday-gatherings.md
    │   ├── 10-moderation-and-discipline.md
    │   ├── 11-guild-bank-and-stewardship.md
    │   ├── 12-observation-memory-and-privacy.md
    │   ├── 13-technical-autonomy.md
    │   ├── 14-conflicts-and-gaps.md
    │   ├── 15-proposed-priority-hierarchy.md
    │   ├── 16-constitutional-documents.md
    │   ├── CONSISTENCY-AUDIT.md
    │   ├── IMPLEMENTATION-MATRIX.md
    │   ├── OPERATING-PROCEDURES.md
    │   ├── QUESTION-DECISIONS.md
    │   └── README.md
    ├── interaction/
    │   ├── PRINCIPLES.md
    │   └── README.md
    ├── lore/
    │   ├── AMBERHEARTH.md
    │   ├── eldgrim_fire_items_100.csv
    │   ├── FIRE_ITEMS.md
    │   ├── FIRES_AND_SYMBOLS.md
    │   ├── README.md
    │   └── WORLD.md
    ├── narrative/
    │   ├── CHRONICLE.md
    │   ├── EMBERS.md
    │   ├── README.md
    │   └── STORIES.md
    └── templates/
        ├── CHARACTER_NOTE_TEMPLATE.md
        ├── README.md
        └── STORY_TEMPLATE.md
    (bot/private/ is gitignored: the bot source, kept out of the public repository)

## Responsibilities

- The root holds only README.md, AGENTS.md, LICENSE and CHANGELOG.md: project identity, working rules, the license and repository history.
- docs/ holds the concept, roadmap, documentation practice, decisions, development history, AI collaboration record and asset rights.
- governance/ holds Eldgrim's public working constitutional chapters and chapter-specific refinement queues, plus the 193-question decision register, the consistency audit and the implementation matrix. It is not the ratified guild charter.
- character/ contains public character identity, personality, and voice.
- lore/ contains approved setting context, Amberhearth connections, symbolic motifs, the fire-item catalog with its research list (eldgrim_fire_items_100.csv), and the world page.
- narrative/ contains stories, scenes, and in-world chronology.
- interaction/ records how Eldgrim communicates and participates in roleplay.
- assets/ stores approved creative resources and provenance.
- templates/ provides reusable formats.
- addon/ contains the Forever-only addon source, manifest, specification, hearth board, API research, data model, test plan, and mock tests. The installable addon directory is addon/Eldgrim/. That directory is the source. addon/install-local.sh copies it into the Forever client's Interface/AddOns/Eldgrim for a local test, and stops when the installed copy is newer. A newer installed ember file is left in place. The hearth board is implemented and has not been tested in game.
- agent/ contains the local agent's architecture, scope, security, memory, operations, proclamation and roster documentation, the eldgrim_agent runner with its tests, and the root-owned wake path sources in agent/systemd/. The runner prepares the guild information, sends quests and replies, writes an announcement and posts it through the server bot, posts the Hearth Keepers note, and chooses the next wake time; bin/eldgrim starts it from any directory. Runtime data, the private origin and credentials stay outside the repository.
- bot/ contains the Eldgrim Discord bot workstream: approved direction, status, open decisions, and planned order. The bot's source lives in bot/private inside this project. That directory is gitignored, so live Discord identifiers, credentials, and runtime data are not part of the public repository.

## Boundaries

Eldgrim's public governance framework is drafted in governance/; the binding Amberhearth guild charter and operations belong in ROARguild. Draft chapters do not override the charter. Private canon does not belong in this public repository. The addon is a separate technical workstream and does not redefine character canon. The agent and bot are also separate from character canon. Their use of addon data is specified in agent/ROSTER.md and is built. The database itself stays outside this repository. Runtime memory, actual conversations, credentials, private prompts, and logs remain outside Git. Other software features require their own approved scope.
