# CONTEXT.md Format

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, cart

**Shipment**:
The dispatch of some or all of an order's lines to one address.
_Avoid_: Delivery, parcel

**Customer**:
A person or business that places orders, identified by an id.
_Avoid_: User, client, account (each names one aspect, not the concept)
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project's context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.
- **Two languages.** Where the domain speaks a different language from the code (Swedish *verifikation*, *räkenskapsår* behind English names in code), the entry is the code's term with the domain's word in the definition, so both are searchable and neither is ambiguous.

## Single vs multi-context repos

**Single context (most repos):** One `CONTEXT.md` at the repo root.

**Multiple contexts:** A `CONTEXT-MAP.md` at the repo root lists the contexts, where they live, and how they relate to each other:

```md
# Context Map

## Contexts

- [Orders](./src/orders/CONTEXT.md): orders, order lines, shipments, refunds
- [Payments](./src/payments/CONTEXT.md): charges, captures, payment providers
- [Customers](./src/customers/CONTEXT.md): customers, addresses, sign-in

## Relationships

- **Customers → Orders**: every order carries the customer's id; Orders never reads the customer store directly
- **Payments → Orders**: an order ships only after Payments confirms the capture
- **Shared kernel**: `Money` and `CustomerId` are shared types, not owned by any context
```

The skill infers which structure applies:

- If `CONTEXT-MAP.md` exists, read it to find contexts
- If only a root `CONTEXT.md` exists, single context
- If neither exists, create a root `CONTEXT.md` lazily when the first term is resolved

When multiple contexts exist, infer which one the current topic relates to. If unclear, ask.
