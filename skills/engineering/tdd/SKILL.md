---
name: tdd
description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests.
---

# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle: consult them before and during the loop, not after.

When exploring the codebase, read `CONTEXT.md` (if it exists) so test names and interface vocabulary match the project's domain language, and respect ADRs in the area you're touching. Where the repo documents a testing strategy (`docs/conventions/testing-strategy.md` or the testing section of `CLAUDE.md`), its layout and coverage rules win over the defaults here. Call the Skill tool with "stack-conventions" for the repo's test framework, test doubles, test layout, and examples in its language.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification: `Creator_cannot_approve_own_invoice` tells you exactly what rule exists, and it survives refactors because it doesn't care about internal structure.

A good test:

- Tests behaviour callers care about, through the public interface only
- Survives internal refactors
- Describes what, not how, in a name that reads as a sentence
- Makes one logical assertion

See [mocking.md](mocking.md) for when a test double is right.

## Seams: where tests go

A **seam** is the public boundary you test at: the interface where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. No test is written at an unconfirmed seam. You can't test everything, so agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

Ask: "What's the public interface, and which seams should we test?"

The usual seams, by layer:

- **Domain**: the aggregate root's public methods. Pure, no I/O, fast. Invariants live here (balancing, immutability, gates).
- **Application**: the command consumer or query handler, with ports faked. Still no I/O.
- **Infrastructure**: the repository, mapping, query filter, or outbox, against a real database in a container. Integration.
- **API**: the endpoint through the HTTP host, for contract shape and status codes.
- **UI**: the view through what the user sees and does, with the backend stubbed where the pack says.

When the shape of that interface is itself in question (how deep the module is, where the seam belongs, what the interface should expose), call the Skill tool with "codebase-design" for the vocabulary. It is the shared source of the module, interface, depth, seam, adapter, leverage and locality terms, and it is a reference to consult, not a session to run.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, asserts on call counts or order, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological**: the assertion recomputes the expected value the way the code does (a total expected as the sum of the same lines the code sums, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth: a known-good literal, a worked example, the spec.
- **Horizontal slicing**: writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead: one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.
- **Integration where unit would do**: spinning up a container to test a rule the aggregate enforces in memory. Containers are for what only a real database can show: mappings, filters, locks, concurrency.

## Rules of the loop

- **Red before green.** Write the failing test first, watch it fail for the right reason, then only enough code to pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **A control needs a test that fails when the control is removed.** For a security or tenancy rule, the red state is the attack succeeding; green is the attack refused.
- **Refactoring is not part of the loop.** It belongs to the review stage (see the `code-review` skill), not the red → green implementation cycle.
- **Architecture rules stay green.** When the slice touches the dependencies between modules, run whatever enforces the rules (the pack names it) with the slice's tests.
