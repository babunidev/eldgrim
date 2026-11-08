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
    └── addon/
        ├── README.md
        ├── SPECIFICATION.md
        ├── API_RESEARCH.md
        ├── TEST_PLAN.md
        ├── Eldgrim/
        │   ├── Eldgrim.toc
        │   └── Eldgrim.lua
        └── tests/
            └── test_recorder.lua

## Responsibilities
- Root documents define project identity, rules, direction, planned work, and repository history.
- docs/ defines documentation practice, decisions, and development history.
- character/ contains public character identity, personality, and voice.
- lore/ contains approved setting context, Amberhearth connections, and symbolic motifs.
- narrative/ contains stories, scenes, and in-world chronology.
- interaction/ records how Eldgrim communicates and participates in roleplay.
- assets/ stores approved creative resources and provenance.
- templates/ provides reusable formats.
- addon/ contains the separate Forever-only addon source, manifest, specification, API research, data model, test plan, and mock tests. The installable addon directory is addon/Eldgrim/.

## Boundaries
Amberhearth governance and guild operations belong in the ROARguild repository. Private canon does not belong in this public repository. The addon is a separate technical workstream and does not redefine character canon. Other software features require their own approved scope.
