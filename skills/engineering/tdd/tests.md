# Good and Bad Tests

Examples in xUnit with AwesomeAssertions (backend) and Vitest (frontend). The principles are the same in both.

## Good Tests

**Behaviour through the interface**: test what a caller observes, not how it happens.

```csharp
// GOOD: the aggregate's own rule, through its public method
[Fact]
public void Posting_an_unbalanced_entry_is_refused()
{
    var entry = JournalEntry.Draft(fiscalYear, date: new DateOnly(2026, 3, 1));
    entry.AddLine(account1910, debit: Money.Sek(100));
    entry.AddLine(account3010, credit: Money.Sek(90));

    var act = () => entry.Post(numberSeries, clock);

    act.Should().Throw<DomainException>().WithMessage("*does not balance*");
}
```

```typescript
// GOOD: the hook's observable result, API stubbed at the client middleware
test("fiscal year list shows the open year first", async () => {
  server.use(fiscalYears([closed2024, open2025]));
  const { result } = renderHook(() => useFiscalYears(), { wrapper });
  await waitFor(() => expect(result.current.data?.[0].id).toBe(open2025.id));
});
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test
- Name reads as a sentence: `Creator_cannot_approve_own_invoice`, `"shows the open year first"`

## Bad Tests

**Implementation-detail tests**: coupled to internal structure.

```csharp
// BAD: asserts on the collaborator, not the outcome
[Fact]
public async Task Post_calls_the_number_series()
{
    var series = Substitute.For<INumberSeries>();
    await handler.Handle(new PostEntry(entryId), CancellationToken.None);
    series.Received(1).Next(Arg.Any<FiscalYearId>());
}
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```csharp
// BAD: bypasses the interface to verify
[Fact]
public async Task Creating_a_vendor_writes_a_row()
{
    await api.PostAsync("/vendors", vendor);
    var row = await db.Vendors.SingleAsync(v => v.Name == "Acme");
    row.Should().NotBeNull();
}

// GOOD: verifies through the interface
[Fact]
public async Task A_created_vendor_is_retrievable()
{
    var created = await api.PostAsync<VendorView>("/vendors", vendor);
    var fetched = await api.GetAsync<VendorView>($"/vendors/{created.Id}");
    fetched.Name.Should().Be("Acme");
}
```

**Tautological tests**: expected value restates the implementation, so the test passes by construction.

```csharp
// BAD: expected value is recomputed the way the code computes it
[Fact]
public void Total_sums_the_lines()
{
    var lines = new[] { Money.Sek(10), Money.Sek(5) };
    entry.Total.Should().Be(lines.Aggregate(Money.Zero, (a, b) => a + b));
}

// GOOD: expected value is an independent, known literal
[Fact]
public void Total_sums_the_lines()
{
    entry.Total.Should().Be(Money.Sek(15));
}
```

**Integration where unit would do**: a container for a rule the domain enforces in memory.

```csharp
// BAD: Testcontainers to prove an aggregate throws
[Fact]
public async Task Closed_year_rejects_posting()
{
    await using var db = await PostgresFixture.StartAsync();
    ...
}

// GOOD: the same rule, in the Domain folder, no I/O
[Fact]
public void Closed_year_rejects_posting()
{
    var year = FiscalYear.Closed(2025);
    var act = () => year.EnsureOpenFor(new DateOnly(2025, 6, 1));
    act.Should().Throw<DomainException>();
}
```

## Where each kind lives

Unless the repo documents otherwise:

- One test project per module, a folder per layer inside: `Domain/` and `Application/` are unit (no I/O), `Infrastructure/` is integration (Testcontainers).
- Architecture tests in their own project, never in the per-module ones.
- Frontend tests beside the code they test (`format.test.ts` next to `format.ts`), with the API stubbed at the client's middleware, never with `fetch` mocked globally.
