# TypeScript pack

## Concept map

- **Module interface**: a workspace package's entry points (the `exports` field of its `package.json`, usually `src/index.ts`). Everything else in the package is internal. Inside an app, a feature folder's `index.ts` plays the same role.
- **Architecture rules**: dependency-cruiser, run by `pnpm lint` or its own script: no imports past a package's entry points, no cycles, no imports against the layer direction.
- **Tests**: Vitest. A one-member port is faked with `vi.fn()`; a port with state gets a hand-written fake object.
- **HTTP in tests**: stub the API at the generated client's middleware (the same place auth headers are stamped), so the typed client and its error mapping still run. MSW handlers where the repo already uses them. Never mock `fetch` globally.
- **Integration**: Testcontainers for Node, for a TypeScript backend's database or broker.
- **Verify**: `pnpm typecheck && pnpm lint && pnpm test && pnpm build`, which Turborepo runs across the workspace. Dev: `pnpm dev --filter <app>`.

## House opinions

- pnpm workspaces with Turborepo. Shared code lives in workspace packages (`@repo/*`), consumed only through their entry points.
- Tests sit beside the code they test: `format.test.ts` next to `format.ts`.
- Call the backend through the generated client, one typed call per endpoint. Each stub then returns one shape, with no conditionals in the fake.
- Test names are sentences: `"refuses a refund above the amount paid"`.

## Examples

Written red first, before `formatMoney` exists:

```typescript
// money/format.test.ts
test("formats an amount in the order's currency", () => {
  expect(formatMoney({ amount: 4200, currency: "EUR" }, "en")).toBe("€42.00");
});
```

Why the generated client makes faking easy:

```typescript
// GOOD: one typed call per endpoint; a stub answers exactly this operation
api.GET("/orders/{id}", { params: { path: { id } } });

// BAD: a hand-rolled wrapper with a string route; the fake must parse it
apiFetch(`/orders/${id}`);
```
