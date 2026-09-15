# When to Mock

Mock at **system boundaries** only:

- External APIs (a bank, a payment provider, an e-invoicing network)
- Time (`IClock`) and randomness
- The message bus, in Application tests (the consumer is the unit; the transport is not)
- The file system, sometimes

Prefer a real thing over a mock where a real thing is cheap:

- Databases: a container (Testcontainers) in the `Infrastructure/` folder, never an in-memory provider pretending to be Postgres. Mappings, `ltree` filters, locks, and migrations only mean something against the real engine.
- The HTTP host: the test server, for API tests.
- The frontend API client: stub at its middleware (the same place auth and node headers are stamped), so the typed client and its error mapping still run.

Don't mock:

- Your own classes/modules
- Internal collaborators
- Anything you control

## Designing for mockability

At system boundaries, design interfaces that are easy to fake:

**1. Use dependency injection**

Pass external dependencies in rather than creating them internally:

```csharp
// Easy to fake
public sealed class ReleasePaymentHandler(IPaymentGateway gateway, IClock clock)
{
    public Task<Release> Handle(ReleasePayment cmd, CancellationToken ct)
        => gateway.Transfer(cmd.Amount, cmd.Iban, clock.UtcNow, ct);
}

// Hard to fake
public sealed class ReleasePaymentHandler
{
    public Task<Release> Handle(ReleasePayment cmd, CancellationToken ct)
        => new BankClient(Environment.GetEnvironmentVariable("BANK_KEY")).Transfer(...);
}
```

**2. Prefer SDK-style ports over generic fetchers**

Create one method per external operation instead of one generic method with conditional logic:

```csharp
// GOOD: each member is independently fakeable
public interface IBankGateway
{
    Task<Balance> GetBalance(Iban iban, CancellationToken ct);
    Task<Release> Transfer(Money amount, Iban to, DateTimeOffset at, CancellationToken ct);
}

// BAD: faking requires conditional logic inside the fake
public interface IBankGateway
{
    Task<HttpResponseMessage> Send(HttpRequestMessage request, CancellationToken ct);
}
```

```typescript
// GOOD: the generated client already gives one typed call per endpoint
api.GET("/fiscal-years", { params: { query: { nodeId } } });

// BAD: a hand-rolled fetch wrapper with a string route
apiFetch(`/fiscal-years?nodeId=${nodeId}`);
```

The SDK approach means:

- Each fake returns one specific shape
- No conditional logic in test setup
- Easier to see which operations a test exercises
- Type safety per operation

**3. One fake per port, kept beside the tests.** `NSubstitute` for a port with one or two members; a hand-written in-memory adapter when the port has state (an in-memory outbox, an in-memory gateway that records transfers). Two adapters is what makes the seam real.
