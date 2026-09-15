# Agent briefs

An **agent brief** is the body of a ticket that is `ready-for-agent`, or the last triage comment on an issue that became one. It is the authoritative specification an agent works from. The original body and discussion are context; the brief is the contract.

`to-tickets`, `triage`, and `pick-up` read and write this format.

## Principles

**Durability over precision.** A ticket may sit for weeks while the codebase moves. Describe interfaces, types, contracts, and behaviour; name the types and signatures the agent should look for. Never reference file paths or line numbers, and never assume the current structure survives.

**Behavioural, not procedural.** Describe what the system should do, not how to implement it. The agent explores the codebase fresh and makes its own implementation decisions.

- Good: "`PostJournalEntry` rejects an entry whose lines do not balance in the functional currency with a `422` and a problem details body naming the difference."
- Bad: "Open the posting handler and add an `if` on line 42."

**Complete acceptance criteria.** Every criterion is independently verifiable, ideally by a named test or a command. "Works correctly" is not a criterion.

**Explicit scope boundaries.** State what is out of scope, so the agent neither gold-plates nor guesses about adjacent features.

**Contract impact stated.** Say whether the ticket changes the HTTP surface the frontend's generated client consumes. If it does, `ship` is replaced by `contract-change` for this ticket, and the brief says so.

## Template

```markdown
## Agent brief

**Category:** bug / enhancement
**Summary:** one line: what needs to happen

**Current behaviour:**
What happens now. For a bug, the broken behaviour. For an enhancement, the status quo the feature builds on.

**Desired behaviour:**
What should happen after the work is done. Specific about edge cases and error conditions.

**Key interfaces:**
- `TypeName`: what changes and why
- `Method()` contract: what it returns now vs what it should return
- Configuration or schema shape: anything new

**Contract impact:** none / changes the OpenAPI surface (list the endpoints)

**Acceptance criteria:**
- [ ] Specific, testable criterion
- [ ] Specific, testable criterion

**Out of scope:**
- What must not change in this ticket
- The adjacent feature that looks related but is separate

**Blocked by:** #NN, #NN, or "none"
```

## Examples

### Bug

```markdown
## Agent brief

**Category:** bug
**Summary:** Node settings accept writes on an inactive node

**Current behaviour:**
`PUT /nodes/{id}/settings/{key}` succeeds when the target node has status
`Inactive`. The settings history then shows edits on a node that should be
frozen, and ADR-0053 says every write on an inactive node is refused.

**Desired behaviour:**
Every settings write on an inactive node is refused with `409` and a problem
details body whose `type` names the inactive-node rule. Reads are unaffected.

**Key interfaces:**
- The node settings command consumer: the inactive check runs before any
  validation of the value, so the response is the same for a bad value on an
  inactive node
- `NodeStatus`: no change

**Contract impact:** none (the `409` is already in the contract for this route)

**Acceptance criteria:**
- [ ] An integration test writes a setting on an inactive node and asserts `409`
- [ ] The same test asserts the settings history is unchanged
- [ ] Writes on an active node still succeed (existing tests stay green)

**Out of scope:**
- Reactivating a node
- Settings inheritance rules

**Blocked by:** none
```

### Enhancement

```markdown
## Agent brief

**Category:** enhancement
**Summary:** List journal entries for the Journal entries page

**Current behaviour:**
The ledger exposes `GET /journal-entries/{id}` only. The frontend's Journal
entries page has nothing to list, so it shows a placeholder.

**Desired behaviour:**
`GET /journal-entries?fiscalYear=<id>&page=<n>&pageSize=<n>` returns a page of
entry summaries (id, verification number, date, description, total in the
functional currency, status) for the operating node, newest first. Tenant
scoping applies through the global query filter; no per-query predicate.

**Key interfaces:**
- A new read model query in the ledger's Application layer, served from the
  read store, never from the aggregate
- The paged response shape already used by the accounts list, reused as is

**Contract impact:** changes the OpenAPI surface: adds `GET /journal-entries`.
Ship with `contract-change`.

**Acceptance criteria:**
- [ ] An integration test seeds three entries across two nodes and asserts the
      list for one node returns only its entries, newest first
- [ ] Paging beyond the last page returns an empty page, not an error
- [ ] The architecture tests stay green
- [ ] The frontend client regenerates without hand edits

**Out of scope:**
- Filtering by account or amount
- Exporting the list

**Blocked by:** #104
```

### Bad brief

```markdown
## Agent brief

**Summary:** Fix the settings bug

The settings thing is broken on inactive nodes. Look at the consumer in
src/Modules/Tenancy/Application/NodeSettings/ and fix it, around line 150.
```
