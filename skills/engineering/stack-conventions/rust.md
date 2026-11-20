# Rust pack

## Concept map

- **Module interface**: a crate's `pub` items, re-exported from `lib.rs`. Internals are `pub(crate)` or private modules. A module whose seam must be enforced is its own crate in the workspace.
- **Architecture rules**: the workspace crate graph. A crate can use only what its `Cargo.toml` depends on, so a forbidden edge is a missing dependency, enforced by the compiler. A rule the graph cannot express (a domain crate that must never depend on `sqlx`) is a test that reads `cargo metadata` and fails on the edge.
- **Tests**: `cargo test`. Unit tests in a `#[cfg(test)] mod tests` beside the code; integration tests in `tests/`, which see only the `pub` interface. `#[tokio::test]` for async.
- **Test doubles**: ports are traits; a hand-written fake struct implements each. `mockall` only for a wide trait where a fake would be mostly stubs. Time comes through a `Clock` trait.
- **Integration**: testcontainers-rs (`testcontainers` with `testcontainers-modules`).
- **Verify**: `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test --workspace`.

## House opinions

- Hand-written fakes before `mockall`: a fake that records calls asserts on outcomes, a mock asserts on call shapes.
- Clippy warnings fail the build.
- A crate's behaviour is tested from `tests/` by default, exactly as callers use it; `#[cfg(test)]` modules are for logic too small to reach from there.

## Examples

A domain rule, written red first:

```rust
#[test]
fn refunding_more_than_was_paid_is_refused() {
    let mut order = Order::paid(Money::eur(100));

    let err = order.refund(Money::eur(120), &FixedClock::at(NOON)).unwrap_err();

    assert_eq!(err, RefundError::ExceedsAmountPaid);
}
```

A stateful fake for a port, and the handler test that uses it:

```rust
#[derive(Default)]
struct RecordingGateway {
    refunds: RefCell<Vec<Money>>,
}

impl PaymentGateway for RecordingGateway {
    fn refund(&self, amount: Money) -> Result<(), GatewayError> {
        self.refunds.borrow_mut().push(amount);
        Ok(())
    }
}
```

```rust
#[test]
fn a_refund_reaches_the_payment_gateway() {
    let gateway = RecordingGateway::default();
    let handler = RefundHandler::new(&gateway, FixedClock::at(NOON));

    handler.handle(RefundOrder { order_id, amount: Money::eur(30) }).unwrap();

    assert_eq!(*gateway.refunds.borrow(), vec![Money::eur(30)]);
}
```
