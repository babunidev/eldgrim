# Project Structure

    eldgrim/
    ├── README.md
    ├── AGENTS.md
    ├── CONCEPT.md
    ├── ROADMAP.md
    ├── CHANGELOG.md
    ├── docs/
    │   ├── DOCUMENTATION.md
    │   ├── PROJECT_STRUCTURE.md
    │   ├── DECISIONS.md
    │   └── DEVLOG.md
    ├── governance/
    │   ├── README.md
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
    │   ├── QUESTION-DECISIONS.md
    │   ├── CONSISTENCY-AUDIT.md
    │   └── IMPLEMENTATION-MATRIX.md
    ├── character/
    │   ├── README.md
    │   ├── PROFILE.md
    │   └── VOICE.md
    ├── lore/
    │   ├── README.md
    │   ├── AMBERHEARTH.md
    │   └── FIRES_AND_SYMBOLS.md
    ├── narrative/
    │   ├── README.md
    │   ├── STORIES.md
    │   └── CHRONICLE.md
    ├── interaction/
    │   ├── README.md
    │   └── PRINCIPLES.md
    ├── assets/
    │   └── README.md
    ├── templates/
    │   ├── README.md
    │   ├── STORY_TEMPLATE.md
    │   └── CHARACTER_NOTE_TEMPLATE.md
    ├── addon/
    │   ├── README.md
    │   ├── SPECIFICATION.md
    │   ├── API_RESEARCH.md
    │   ├── TEST_PLAN.md
    │   ├── Eldgrim/
    │   │   ├── Eldgrim.toc
    │   │   └── Eldgrim.lua
    │   └── tests/
    │       └── test_recorder.lua
    ├── agent/
    │   ├── README.md
    │   ├── ARCHITECTURE.md
    │   ├── SPECIFICATION.md
    │   ├── SECURITY.md
    │   ├── MEMORY.md
    │   ├── OPERATIONS.md
    │   ├── ANNOUNCEMENT.md
    │   ├── ROSTER.md
    │   ├── eldgrim_agent/
    │   └── tests/
    │       └── test_clock.py
    └── bot/
        └── README.md

## Responsibilities

- Root documents define project identity, rules, direction, planned work, and repository history.
- docs/ defines documentation practice, decisions, and development history.
- governance/ holds Eldgrim's public working constitutional chapters and chapter-specific refinement queues, plus the 193-question decision register, the consistency audit and the implementation matrix. It is not the ratified guild charter.
- character/ contains public character identity, personality, and voice.
- lore/ contains approved setting context, Amberhearth connections, and symbolic motifs.
- narrative/ contains stories, scenes, and in-world chronology.
- interaction/ records how Eldgrim communicates and participates in roleplay.
- assets/ stores approved creative resources and provenance.
- templates/ provides reusable formats.
- addon/ contains the separate Forever-only addon source, manifest, specification, API research, data model, test plan, and mock tests. The installable addon directory is addon/Eldgrim/. Further addon development happens in a separate environment (2026-11-10), so the copy here is the first-milestone recorder.
- agent/ contains the local agent's architecture, scope, security, memory, operations, proclamation and roster documentation, and the eldgrim_agent runner with its tests. The runner writes a local announcement and chooses the next wake time; it does not post. Runtime data, the private origin and credentials stay outside the repository.
- bot/ contains the Eldgrim Discord bot workstream: approved direction, status, open decisions, and planned order. The bot's source lives in a separate private local repository.

## Boundaries

Eldgrim's public governance framework is drafted in governance/; the binding Amberhearth guild charter and operations belong in ROARguild. Draft chapters do not override the charter. Private canon does not belong in this public repository. The addon is a separate technical workstream and does not redefine character canon. The agent and bot are also separate from character canon. Their use of addon data is approved and specified in agent/ROSTER.md; it is not built. Runtime memory, actual conversations, credentials, private prompts, and logs remain outside Git. Other software features require their own approved scope.
