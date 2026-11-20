# Module integration

How modules share data and work, whether they live in one deployable or are separately deployed services. The concepts are the same at both scales; only the enforcement differs:

| | Modules in one deployable | Separately deployed services |
| --- | --- | --- |
| Interface held by | the architecture rules (tests, compiler visibility, a linter) | contract tests, and the network itself |
| Data separated by | a schema per module, no writes into another module's schema | a database per service |
| A failure between them | in process; one transaction is possible | partial: the network can lose, delay, or duplicate a message |

## When to extract a module into its own deployable

Start from the simplest shape that meets the vital few: usually modules in one deployable, their interfaces held by the architecture rules. That gives most of the structural benefit of services with none of the network's cost, where every remote call can fail, be slow, or arrive twice. Extract a module only when a runtime driver forces it: independent scaling, independent deployment, fault isolation, or a team that must ship on its own cadence. Modularity alone is never the reason; a modularity problem is fixed in process. Extract one well-seamed module at a time, each step with its own ADR.

## Granularity: split or keep together

The make-or-break decision for services. Weigh both lists for the specific capability; teams tend to weigh only the first.

**Reasons to split**

1. **Scope and function**: the parts do unrelated jobs.
2. **Code volatility**: one part changes far more often, and isolating it contains its deploy risk.
3. **Independent scaling**: one part needs different throughput.
4. **Fault isolation**: a fault-prone or critical part must not take the rest down.
5. **Security**: the parts hold data or functions of different sensitivity.
6. **Extensibility**: a capability needs room to grow without touching the rest.

**Reasons to keep together**

1. **Shared transactions**: an operation needs one atomic transaction across the parts.
2. **Chatty workflows**: the parts call back and forth, paying latency, fragility, and coupling on every step.
3. **Shared domain code**: logic both parts would otherwise duplicate or couple on.
4. **Tightly related data**: data joined or referenced so closely that splitting it is hard.

A split that leaves a keep-together reason strong is a split with a saga in its future. Record the decision as an ADR and name the trade-off accepted.

## Data ownership: one writer

Every piece of data has exactly one writer, the module or service that owns it. Others read it through the owner's interface, or keep their own copy fed by the owner's integration events. No database is shared between services; inside one deployable, no module writes into another module's schema.

When several modules write the same data, pick one fix: split the data so each part has one writer, make one owner and have the others ask it, or merge the writers.

## Integration events and eventual consistency

Across owners there is no shared transaction. The owner commits its change and publishes an **integration event**; each consumer updates its own data when the event arrives. Consumers are **eventually consistent**: for a window they hold the old state. Design what the user sees in that window (a pending status, a read from the owner).

An integration event is a contract. Name it in the past tense (`OrderPlaced`), and evolve it compatibly: add fields, and never repurpose or remove one a consumer reads, so producer and consumers deploy independently.

## Outbox and idempotent consumers

Two failures break eventual consistency, each with one fix:

- **Lost events**: the change commits but the publish fails, or the publish goes out and the change rolls back. Fix: an **outbox**. The event is written to an outbox table in the same transaction as the change, and a relay publishes it afterwards.
- **Duplicate events**: brokers deliver at least once, and relays retry. Fix: **idempotent consumers**. Handling an event twice has the effect of handling it once: the consumer records processed event ids in its own transaction, or makes its update naturally idempotent.

An outbox without idempotent consumers trades lost events for duplicates. The repo's pack names the mechanics (call the Skill tool with "stack-conventions").

## When a saga is justified

A **saga** is a sequence of local transactions across owners, each with a compensating action for when a later step fails. Use one when a business operation genuinely spans owners and must end consistent: reserve stock, capture payment, confirm the order. Prefer **orchestration** (one coordinator owns the state and the error paths) when the error handling is complex; **choreography** (each owner reacts to events) only for a simple, linear flow that needs throughput. Model the saga as a state machine with a compensation per step.

Needing many sagas signals wrong seams. When operations that span owners dominate a design, revisit granularity and ownership before writing the next saga.

## Contracts between services

Every interface another deployable consumes is a contract, and a contract-impact entry when it changes. Choose its strictness per relationship:

- **Strict**: exact schema and version. Certainty and tooling, but brittle: every change is coordinated.
- **Loose**: a tolerant reader that depends only on the fields it uses. Independent evolution, less certainty.

A loose contract stays safe with **consumer-driven contract tests**: each consumer publishes the expectations it relies on, and the producer's CI verifies them, so the producer cannot ship a change that breaks a consumer. Between modules in one deployable, the compiler and the architecture rules do this job.

Send a consumer the fields it needs. A whole document passed where three fields are read couples the consumer to all of it.

## Replication lag

A copy fed by events, or a read replica, lags its source. Design for three anomalies:

- **Read your own writes**: a user who just changed something reads a stale copy and sees the change undone. Serve that user from the owner or the primary right after a write.
- **Monotonic reads**: successive reads hit copies with different lag, and data appears to go back in time. Pin a user's reads to one copy.
- **Consistent prefix**: events applied out of order show an effect before its cause. Order events per entity (a partition key) and apply them in order.

State the acceptable staleness as a six-part scenario, like any other attribute.
