# Stack

Which stack packs `stack-conventions` loads for which paths. A pack is a built-in name (`csharp`, `rust`, `python`, `typescript`, `react`) or a repo-local file under `docs/agents/packs/`. A language with no pack is named anyway; `stack-conventions` falls back to its standard idioms.

| Path | Packs |
| ---- | ----- |
| `_<src/>_` | `_<csharp>_` |
| `_<web/>_` | `_<typescript, react>_` |

## Verify commands

_<Only when this repo runs commands that differ from the packs' defaults; otherwise delete this section.>_

- `_<command>_`
