# Project invariants

Rules this repo holds on top of `code-review`'s invariant baseline (interface bypass, layer inversion, non-idempotent consumer, foreign write, secrets in code, test shape). `code-review` pastes every entry into its Architecture sub-agent and treats a breach exactly as it treats a baseline breach.

Write each entry as one line in the baseline's shape: **Name**: the breach to look for, with the concrete forms it takes in this codebase.

## Invariants

_<one bullet per invariant>_

## Worked examples

_(Template only: copy the entries that apply into the list above, then delete this section.)_

Two invariants a multi-tenant product with append-only records keeps, worded exactly as `code-review` carried them in its baseline before they moved here:

- **Scoping bypass**: a query or write on tenant-scoped data that sidesteps the automatic filter or stamping (raw SQL, `IgnoreQueryFilters`, bulk verbs, a hand-built command).
- **Immutability breach**: an update or delete path on data the domain declares append-only or immutable (posted entries, audit logs).
