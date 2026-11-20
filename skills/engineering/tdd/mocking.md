# When to Mock

Mock at the **edges of the system** only, where you do not own the other side:

- External APIs (a payment provider, a shipping carrier, an e-mail service)
- Time and randomness
- The message bus, in application-layer tests (the consumer is the unit; the transport is not)
- The file system, sometimes

Prefer a real thing over a mock where a real thing is cheap:

- Databases: the real engine in a container, never an in-memory stand-in pretending to be it. Mappings, engine extensions, locks, and migrations only mean something against the real engine.
- The HTTP host: the framework's in-process test server, for API tests.
- A frontend's API client: stub it below the typed client, so the client and its error mapping still run.

Don't mock:

- Your own modules
- Internal collaborators
- Anything you control

## Designing for mockability

1. **Inject dependencies.** Pass the port in as a constructor or function parameter. Code under test never constructs an external client or reads its credentials itself.
2. **Prefer SDK-style ports over generic fetchers.** One operation per external call (`getBalance`, `refund`), not one generic `send(request)`. Each fake then returns one shape, test setup has no conditional logic, a test shows which operations it exercises, and every operation is typed.
3. **One fake per port, kept beside the tests.** A library double for a port with one or two members; a hand-written in-memory adapter when the port has state (an in-memory outbox, a gateway that records refunds). Two adapters is what makes the seam real.

The pack from "stack-conventions" names the double library and the container tooling, and shows these shapes in code.
