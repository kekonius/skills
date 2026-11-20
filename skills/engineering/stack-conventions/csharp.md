# C# pack

## Concept map

- **Module interface**: each module's `<Module>.Contracts` project holds its public commands, queries, integration events, and DTOs. Everything else in the module is `internal`, visible only to the module's own tests.
- **Architecture rules**: NetArchTest, in a dedicated `*.Architecture.Tests` project. No module references another module's assemblies except its `.Contracts`; Domain references no infrastructure (EF Core, the message bus, ASP.NET).
- **Tests**: xUnit with AwesomeAssertions. Ports are constructor parameters (`RefundHandler(IPaymentGateway gateway, IClock clock)`); a handler never `new`s an external client. Time comes through `IClock`.
- **Test doubles**: NSubstitute for a port with one or two members; a hand-written in-memory adapter when the port has state (an in-memory outbox, a gateway that records refunds).
- **Integration**: Testcontainers for PostgreSQL and RabbitMQ, never an in-memory EF provider pretending to be the engine. API tests go through `WebApplicationFactory`.
- **Integration events**: MassTransit on RabbitMQ. Events are records in the producing module's `.Contracts`. The MassTransit EF Core transactional outbox writes an event in the same `SaveChanges` as the change, and its inbox makes consumers idempotent by recording processed message ids.
- **Verify**: `dotnet build`, `dotnet test`, `dotnet format --verify-no-changes`. Dev: `dotnet run --project <host>`.

## House opinions

- One test project per module, with a folder per layer: `Domain/` and `Application/` are unit tests (no I/O), `Infrastructure/` is integration (Testcontainers). Architecture tests live in their own project, never in the per-module ones.
- A container only for what only the real engine can show: mappings, query filters, locks, migrations. A rule the aggregate enforces in memory is a `Domain/` test.
- Test names are sentences: `Customer_cannot_refund_an_unshipped_order`.

## Examples

A domain rule, written red first, through the aggregate's public method:

```csharp
[Fact]
public void Refunding_more_than_was_paid_is_refused()
{
    var order = Order.Paid(OrderId.New(), Money.Eur(100));

    var act = () => order.Refund(Money.Eur(120), clock);

    act.Should().Throw<DomainException>().WithMessage("*exceeds the amount paid*");
}
```

Verify through the interface, not a side channel:

```csharp
// BAD: reaches past the interface into the database
[Fact]
public async Task Placing_an_order_writes_a_row()
{
    await api.PostAsync("/orders", draft);
    (await db.Orders.SingleAsync(o => o.CustomerId == customerId)).Should().NotBeNull();
}

// GOOD: what a caller observes
[Fact]
public async Task A_placed_order_is_retrievable()
{
    var placed = await api.PostAsync<OrderView>("/orders", draft);
    var fetched = await api.GetAsync<OrderView>($"/orders/{placed.Id}");
    fetched.Total.Should().Be(Money.Eur(42));
}
```
