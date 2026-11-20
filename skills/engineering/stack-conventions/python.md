# Python pack

## Concept map

- **Module interface**: a package's public names, re-exported from its `__init__.py` and listed in `__all__`. Internals live in `_private` modules.
- **Architecture rules**: import-linter contracts in `pyproject.toml` (`layers`, `independence`, `forbidden`), checked by `lint-imports`:

  ```toml
  [[tool.importlinter.contracts]]
  name = "Order domain depends on no infrastructure"
  type = "forbidden"
  source_modules = ["shop.orders.domain"]
  forbidden_modules = ["sqlalchemy", "shop.orders.infrastructure"]
  ```

- **Tests**: pytest with fixtures and plain `assert`. Cases that differ only in data use `@pytest.mark.parametrize`, never a loop inside one test.
- **Test doubles**: ports are `typing.Protocol`s; hand-written fakes implement them. `unittest.mock.create_autospec` only when a fake is impractical, never a bare `MagicMock`. Time comes through a clock port.
- **Integration**: testcontainers-python, one container per session through a fixture; API tests through the web framework's test client:

  ```python
  @pytest.fixture(scope="session")
  def database_url():
      with PostgresContainer("postgres:17") as pg:
          yield pg.get_connection_url()
  ```

- **Verify**: `uv run ruff check`, `uv run ruff format --check`, `uv run mypy .` (or `pyright` when the repo configures it), `uv run lint-imports`, `uv run pytest`.

## House opinions

- uv runs every command.
- Tests live in `tests/`, mirroring the package; container-backed tests sit in `tests/integration/` so the unit suite stays fast to run alone.
- Ports are `Protocol`s, so a fake needs no inheritance and the type checker proves it fits the port.
- Fakes over `unittest.mock`: a fake that records calls asserts on outcomes; a mock asserts on call shapes and passes for misspelt attributes.

## Examples

A domain rule, written red first:

```python
def test_refunding_more_than_was_paid_is_refused():
    order = Order.paid(Money.eur(100))

    with pytest.raises(RefundExceedsAmountPaid):
        order.refund(Money.eur(120), clock=FixedClock(NOON))
```

A stateful fake for a port, and the handler test that uses it:

```python
class RecordingGateway:
    def __init__(self) -> None:
        self.refunds: list[Money] = []

    def refund(self, amount: Money) -> None:
        self.refunds.append(amount)
```

```python
def test_a_refund_reaches_the_payment_gateway():
    gateway = RecordingGateway()
    handler = RefundHandler(gateway=gateway, clock=FixedClock(NOON))

    handler.handle(RefundOrder(order_id, Money.eur(30)))

    assert gateway.refunds == [Money.eur(30)]
```
