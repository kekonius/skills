# React pack

Layered on the [TypeScript pack](typescript.md): load both. React's own word "component" names a UI function here; outside React code, the repo's word is module.

## Concept map

- **Module interface**: a component's props and what the user sees and does; a hook's return value. Tests go through those, never a component's internal state.
- **Architecture rules**: the TypeScript pack's dependency-cruiser config. UI primitives come from the shared UI package (`@repo/ui`), never copied into an app.
- **Tests**: Vitest with Testing Library (`@testing-library/react`, `user-event`). Query by role and text, as a user would. Hooks go through `renderHook` with the app's providers (query client, router) in a wrapper.
- **Integration**: the API stubbed at the client middleware, per the TypeScript pack. End-to-end only where the repo already has a runner.
- **Verify**: the TypeScript pack's commands; `pnpm build` runs the Vite build.

## House opinions

- Vite, TanStack Router and TanStack Query, Tailwind v4, shadcn on Base UI primitives in `@repo/ui`.
- Server state lives in TanStack Query, not in component state.

## Prototype variants

What `prototype`'s UI branch needs in a React app:

- Each variant is an exported component (`VariantA`, `VariantB`, ...) built from `@repo/ui` primitives and Tailwind.
- The route renders the chosen variant above a shared switcher:

  ```tsx
  const variant = searchParams.get("variant") ?? "A";
  return (
    <>
      {variant === "A" && <VariantA {...data} />}
      {variant === "B" && <VariantB {...data} />}
      <PrototypeSwitcher variants={["A", "B"]} current={variant} />
    </>
  );
  ```

- The switcher writes the search param through the router: `navigate({ search })` on TanStack Router, `router.replace` on Next, `navigate` on React Router.
- Gate the switcher on `import.meta.env.DEV` (Vite) or `process.env.NODE_ENV !== "production"`.

## Example

Written red first, with the API stubbed:

```typescript
test("order list shows the newest order first", async () => {
  server.use(orders([placedMonday, placedTuesday]));
  const { result } = renderHook(() => useOrders(), { wrapper });
  await waitFor(() => expect(result.current.data?.[0].id).toBe(placedTuesday.id));
});
```
