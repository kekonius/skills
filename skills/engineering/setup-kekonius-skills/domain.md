# Domain docs

How the engineering skills consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root, or
- **`CONTEXT-MAP.md`** at the repo root if it exists: it points at one `CONTEXT.md` per context. Read each one relevant to the topic.
- **ADRs** in `_<docs/decisions/>_`: read the ones that touch the area you're about to work in. In a multi-context repo, also check the context's own ADR directory.
- **Architecture and convention docs** listed in `CLAUDE.md`, when the repo has them. They are binding; an ADR is how they change.

If any of these files don't exist, proceed silently. Don't flag their absence or suggest creating them upfront. `domain-modeling` (reached via `grill-with-docs` and `improve-codebase-architecture`) creates them lazily when terms or decisions actually get resolved.

## Layout

Single-context repo (most repos):

```
/
├── CONTEXT.md
├── docs/decisions/
│   ├── ADR-0001-<slug>.md
│   └── ADR-0002-<slug>.md
└── src/
```

Multi-context repo (a `CONTEXT-MAP.md` at the root):

```
/
├── CONTEXT-MAP.md
├── docs/decisions/                    ← system-wide decisions
└── src/Modules/
    ├── GeneralLedger/
    │   ├── CONTEXT.md
    │   └── docs/decisions/            ← module-specific decisions
    └── Identity/
        ├── CONTEXT.md
        └── docs/decisions/
```

ADR filenames: `_<ADR-NNNN-<slug>.md>_`, numbered from the next free number. Where the repo keeps a `_template.md` or `README.md` in the ADR directory, follow it.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal: either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders), but worth reopening because…_
