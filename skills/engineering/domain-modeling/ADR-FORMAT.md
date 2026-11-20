# ADR Format

ADRs live in the repo's ADR directory (`docs/decisions/` unless `docs/agents/domain.md` says otherwise), one file per decision, named `ADR-NNNN-<slug>.md`, numbered monotonically across the whole project and zero-padded to four digits. `README.md` in the same directory is the index: a table of id, title, and status. Keep it current.

Numbering: scan the directory for the highest existing number and increment by one.

## Template

If the directory has a `_template.md`, use it. Otherwise this one, which is the same shape:

```md
# ADR-NNNN · {Short title of the decision}

- **Status**: Proposed | Accepted | Superseded by ADR-XXXX | Deprecated
- **Date**: YYYY-MM-DD
- **Area**: {module, layer, or concern: Orders, Payments, API client, Tooling}

## Context

{What forces are in play. The problem, the constraint, the prior decision this builds on.}

## Options

{The genuine alternatives: two or three, plus the smallest change as a baseline. If there was only one, the decision needed no ADR. Rate them on the few dimensions the decision actually turns on:}

| Dimension | {Option A} | {Option B} | {Smallest change} |
| --- | --- | --- | --- |
| {dimension} | {Low / Med / High: one-line reason} | {...} | {...} |

{Then walk one or two real scenarios from this system (a workflow, a failure, a load spike, a change request) through each option, and say what breaks, slows, or couples.}

## Decision

{What was decided, concretely enough that the implementation can be checked against it.}

## Rationale

{Why this option over the others. Tie it to a concrete force: a standard or regulation the domain must meet, a legal requirement, a security property, or an architectural principle from the binding docs.}

## Consequences

{What changes as a result: files, packages, follow-ups owed, known limitations.}

**Trade-off accepted:** {what this decision deliberately gives up, in exchange for what.}

## Related

{Links to the ADRs, conventions, and architecture docs this touches.}
```

Sections may be short; the shape is for the reader who scans fifty of them, not for padding. Two rules hold however short the ADR is:

- **Ratings are qualitative, with a reason.** Low, Med, or High against the other options, never an invented number. Real numbers only where they were measured (a benchmark, a latency budget, a monthly cost).
- **The "Trade-off accepted:" line is required.** A decision that names no trade-off is unfinished: if you cannot see what it costs, you have not found the cost yet.

## Immutability

An accepted ADR is not edited. When a decision changes, add a new ADR, mark the old one `Superseded by ADR-NNNN`, and cross-link both. History stays readable.

## When to offer an ADR

All three of these must be true:

1. **Hard to reverse**: the cost of changing your mind later is meaningful
2. **Surprising without context**: a future reader will look at the code and wonder "why on earth did they do it this way?"
3. **The result of a real trade-off**: there were genuine alternatives and you picked one for specific reasons

If a decision is easy to reverse, skip it: you'll just reverse it. If it's not surprising, nobody will wonder why. If there was no real alternative, there's nothing to record beyond "we did the obvious thing."

### What qualifies

- **Architectural shape.** "Modular monolith, one schema per module, no cross-schema foreign keys." "Order totals are a read model projected from order events."
- **Integration patterns between contexts.** "Modules communicate through their interfaces and integration events, never by reaching into each other's internals."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target, UI primitive library. Not every package: just the ones that would take a quarter to swap out.
- **Scope and ownership decisions.** "Customer data is owned by the Customers module; other modules reference it by id only." The explicit no-s are as valuable as the yes-s.
- **Deliberate deviations from the obvious path.** "Gap-free invoice numbers come from a number series inside the order transaction, never a database sequence." Anything where a reasonable reader would assume the opposite. These stop the next engineer from "fixing" something that was deliberate.
- **Constraints not visible in the code.** A legal requirement, a partner contract, a compliance rule.
- **Rejected alternatives when the rejection is non-obvious.** If you considered a custom lint rule and picked a banned-API list for subtle reasons, record it; otherwise someone will suggest the analyzer again in six months.
