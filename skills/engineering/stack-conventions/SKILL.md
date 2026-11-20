---
name: stack-conventions
description: How this repo's languages express seams, architecture rules, tests, test doubles, and verify commands. Use when writing or testing code in a specific language, choosing verify commands, or when another skill needs the repo's stack specifics.
---

# Stack conventions

The other skills speak in language-neutral terms: module, interface, seam, adapter, architecture rules, verify commands. This skill maps those terms onto the repo's languages through **packs**, and loads only the packs the repo uses.

## 1. Find the packs

Read `docs/agents/stack.md`. It maps paths to packs, and a repo may list several:

| Path | Packs |
| ---- | ----- |
| `src/` | csharp |
| `web/` | typescript, react |

A pack is a built-in name or a repo-local file (`docs/agents/packs/<lang>.md`). Load only the packs whose path covers the files in play. A layered pack loads with its base: react with typescript. Verify commands listed in `stack.md` override the pack defaults.

Built-in packs: [csharp](csharp.md), [rust](rust.md), [python](python.md), [typescript](typescript.md), [react](react.md).

## 2. When `stack.md` is missing

Detect the languages from manifests, per directory: `*.csproj` or `*.slnx` is csharp, `Cargo.toml` is rust, `pyproject.toml` is python, `package.json` is typescript (plus react when it depends on `react`). Load the matching packs, and tell the user once that `/setup-kekonius-skills` records the mapping in `docs/agents/stack.md`.

## 3. When a language has no pack

Answer each concept-map row from the repo's `CLAUDE.md` plus the language's standard idioms. At the end of the session, offer to draft a pack for it at `docs/agents/packs/<lang>.md`, in the shape below, from what the session established, and to add its row to `stack.md`.

## Pack shape

Each pack is 300 to 500 words in three sections:

- **Concept map**: the module interface (seam); how the architecture rules are enforced; test framework and test doubles; integration-test infrastructure; default verify commands, plus a dev command where one is conventional.
- **House opinions**: only where they differ from the language's defaults.
- **Examples**: one or two test-first examples.

## Briefing sub-agents

A sub-agent cannot call this skill. A skill that briefs one pastes the pack rows it needs into the prompt, usually the architecture-rule enforcement and the verify commands.
