# Deepening

How to deepen a cluster of shallow modules safely, given its dependencies. Assumes the vocabulary in [SKILL.md](SKILL.md): **module**, **interface**, **seam**, **adapter**.

## Dependency categories

When assessing a candidate for deepening, classify its dependencies. The category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable: merge the modules and test through the new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (a containerised database or broker, an in-memory filesystem). Deepenable if the stand-in exists. The deepened module is tested with the stand-in running in the test suite. The seam is internal; no port at the module's external interface.

### 3. Remote but owned (Ports & Adapters)

Your own services across the network (microservices, internal APIs). Define a **port** (interface) at the seam. The deep module owns the logic; the transport is injected as an **adapter**. Tests use an in-memory adapter. Production uses an HTTP/gRPC/queue adapter.

Recommendation shape: *"Define a port at the seam, implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."*

### 4. True external (Mock)

Third-party services (a bank API, a payment provider, an e-invoicing network) you don't control. The deepened module takes the external dependency as an injected port; tests provide a mock adapter.

## Seam discipline

The principles in [SKILL.md](SKILL.md) govern every port above: a port needs two justified adapters (typically production and test), and internal seams stay out of the interface even when tests use them.

## Testing strategy: replace, don't layer

Once tests exist at the deepened module's interface, the old unit tests on the shallow modules it absorbed are waste: delete them. New tests go at the deepened interface and assert on observable outcomes, so they survive internal refactors; a test that changes when the implementation changes is testing past the interface.
