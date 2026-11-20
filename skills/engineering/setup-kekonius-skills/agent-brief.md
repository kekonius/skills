# Agent briefs

An **agent brief** is the body of a ticket that is `ready-for-agent`, or the last triage comment on an issue that became one. It is the authoritative specification an agent works from. The original body and discussion are context; the brief is the contract.

`to-tickets`, `triage`, and `pick-up` read and write this format.

## Principles

**Durability over precision.** A ticket may sit for weeks while the codebase moves. Describe interfaces, types, contracts, and behaviour; name the types and signatures the agent should look for. Never reference file paths or line numbers, and never assume the current structure survives. One exception: when a prototype produced a snippet that encodes a decision more precisely than prose can (a state machine, a reducer, a schema, a type shape), inline its decision-rich part and note that it came from a prototype.

**Behavioural, not procedural.** Describe what the system should do, not how to implement it. The agent explores the codebase fresh and makes its own implementation decisions.

- Good: "`RefundOrder` rejects a refund larger than the amount captured with a `422` and a problem details body naming the difference."
- Bad: "Open the refund handler and add an `if` on line 42."

**Complete acceptance criteria.** Every criterion is independently verifiable, ideally by a named test or a command. "Works correctly" is not a criterion.

**Explicit scope boundaries.** State what is out of scope, so the agent neither gold-plates nor guesses about adjacent features.

**Contract impact stated.** List every contract another deployable consumes that the ticket changes (an HTTP API, an integration event or message schema, a shared schema), each with its consuming repos, or say "none". An entry that changes the OpenAPI surface a frontend consumes through a generated client means `ship` is replaced by `contract-change` for this ticket, and the brief says so.

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

**Contract impact:** none / one line per changed contract: `<contract>` (HTTP API, event or message schema, or shared schema): what changes. Consumers: <repos>

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
**Summary:** Refunds are accepted on a cancelled order

**Current behaviour:**
`POST /orders/{id}/refunds` succeeds when the order has status `Cancelled`.
The payment provider is then asked to refund money that was never captured,
and ADR-0021 says a cancelled order accepts no further money movement.

**Desired behaviour:**
Every refund request on a cancelled order is refused with `409` and a problem
details body whose `type` names the cancelled-order rule. Reads are unaffected.

**Key interfaces:**
- The refund command handler: the cancelled check runs before the amount is
  validated, so the response is the same for a bad amount on a cancelled order
- `OrderStatus`: no change

**Contract impact:** none (the `409` is already in the contract for this route)

**Acceptance criteria:**
- [ ] An integration test requests a refund on a cancelled order and asserts `409`
- [ ] The same test asserts the payment gateway received no refund
- [ ] Refunds on a shipped order still succeed (existing tests stay green)

**Out of scope:**
- Reopening a cancelled order
- Partial cancellation

**Blocked by:** none
```

### Enhancement

```markdown
## Agent brief

**Category:** enhancement
**Summary:** List a customer's orders for the Order history page

**Current behaviour:**
The Orders module exposes `GET /orders/{id}` only. The frontend's Order
history page has nothing to list, so it shows a placeholder.

**Desired behaviour:**
`GET /orders?page=<n>&pageSize=<n>` returns a page of order summaries (id,
order number, date, status, total in the order's currency) for the signed-in
customer, newest first. A customer only ever sees their own orders.

**Key interfaces:**
- A new read model query in the Orders module, served from the read store,
  never from the aggregate
- The paged response shape already used by the product list, reused as is

**Contract impact:** `GET /orders` (HTTP API): added. Consumers: the web
frontend, through its generated client. Ship with `contract-change`.

**Acceptance criteria:**
- [ ] An integration test seeds three orders across two customers and asserts
      the list for one customer returns only their orders, newest first
- [ ] Paging beyond the last page returns an empty page, not an error
- [ ] The architecture rules stay green
- [ ] The frontend client regenerates without hand edits

**Out of scope:**
- Filtering by status or date
- Exporting the list

**Blocked by:** #104
```

### Bad brief

```markdown
## Agent brief

**Summary:** Fix the refund bug

The refund thing is broken on cancelled orders. Look at the handler in
src/orders/refunds/ and fix it, around line 150.
```
