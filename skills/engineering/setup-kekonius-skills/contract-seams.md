# Contract seams

This repo consumes one or more backend HTTP contracts through a generated client. `contract-change` reads this file to regenerate the client after a backend change ships.

| Client package | Backend repo (local path) | Base branch | Start command (run in the backend repo) | Spec URL | Generate command (run here) |
| -------------- | ------------------------- | ----------- | --------------------------------------- | -------- | --------------------------- |
| `_<@repo/api-client>_` | `_<~/dev/backoffice/server>_` | `_<master>_` | `_<dotnet run --project src/Host/BackOffice.Bootstrapper>_` | `_<http://localhost:5000/openapi/v1.json>_` | `_<pnpm --filter @repo/api-client generate>_` |

Rules that hold for every row:

- The committed spec and generated types are never hand-edited. A contract change is a regeneration, then fixing what the typecheck rejects.
- The backend must be on its base branch, at or after the merge that changed the contract, before regenerating. A client generated from a feature branch encodes a contract that may never ship.
- The generate command fails when the backend is unreachable and leaves the committed spec unchanged. That failure is the signal to start the backend, never to skip regeneration.
