# CONTEXT.md Format

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Journal entry**:
{A one or two sentence description of the term}
_Avoid_: Voucher, transaction

**Posting**:
The act that makes a journal entry immutable and mints its verification number.
_Avoid_: Saving, committing

**Node**:
A tenant or company in the tenancy tree, identified by an id and a path.
_Avoid_: Tenant, company, client (each names one kind of node, not the concept)
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project's context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.
- **Swedish and English.** Where the domain term is Swedish (verifikation, räkenskapsår, kontoplan) and the code uses an English name, the entry is the English term with the Swedish word in the definition, so both are searchable and neither is ambiguous.

## Single vs multi-context repos

**Single context (most repos):** One `CONTEXT.md` at the repo root.

**Multiple contexts:** A `CONTEXT-MAP.md` at the repo root lists the contexts, where they live, and how they relate to each other:

```md
# Context Map

## Contexts

- [General Ledger](./src/Modules/GeneralLedger/CONTEXT.md): accounts, journal entries, fiscal years, verification numbers
- [Identity](./src/Modules/Identity/CONTEXT.md): principals, sign-in, function grants
- [Tenancy](./src/Modules/Tenancy/CONTEXT.md): the node tree and node settings

## Relationships

- **Tenancy → General Ledger**: every ledger row carries the node's path; the ledger never reads the tree directly
- **Identity → General Ledger**: posting requires a function grant on the target node
- **Shared kernel**: `Money`, `NodeId`, `PathLocator` are shared types, not owned by any context
```

The skill infers which structure applies:

- If `CONTEXT-MAP.md` exists, read it to find contexts
- If only a root `CONTEXT.md` exists, single context
- If neither exists, create a root `CONTEXT.md` lazily when the first term is resolved

When multiple contexts exist, infer which one the current topic relates to. If unclear, ask.
