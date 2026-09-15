---
name: contract-change
description: "Ship a backend API change and the frontend client regeneration it forces, as two linked PRs, backend first. Run it in the backend repo to ship the contract, then in the frontend repo to regenerate and fix the call sites."
disable-model-invocation: true
argument-hint: "In the frontend repo: the merged backend PR number"
---

# Contract change

A **contract change** is a backend change that alters the HTTP surface a frontend consumes through a generated OpenAPI client. Left half-done it fails at runtime, days later, in the other repo. This skill makes it two linked PRs, backend first, with nothing to remember in between.

It runs in two halves, in two repos, in two sessions. Which half you are in is decided by the repo you are standing in:

- **Backend half**: the repo serves an OpenAPI document (a `.slnx` or `.csproj` host that exposes `/openapi/*.json`, or whatever `docs/agents/` records).
- **Frontend half**: the repo has `docs/agents/contract-seams.md`. If it consumes a generated client but that file is missing, tell the user to run `/setup-kekonius-skills` here first.

## Backend half

1. **Confirm the contract moved.** Diff the served document between the base branch and this branch: run the host from this branch, fetch the spec URL, and compare with the spec the frontend has committed (`openapi/backend.json` in the client package, reachable through the path in the frontend's `contract-seams.md` if you know it; otherwise the base-branch document). List the endpoints and schemas that changed. When nothing changed, say so and stop: this is an ordinary `ship`.
2. **Check the brief.** The agent brief's **Contract impact** line must list the same endpoints. Where it does not, fix the brief on the issue (`gh issue edit <n> --body-file`) so the ticket records what actually shipped.
3. **Ship it.** Call the Skill tool with "ship". Ship merges the backend PR and, seeing the contract impact, hands back here.
4. **Hand off.** Tell the user, in three lines: the backend PR is merged at `<sha>`, the endpoints that changed, and the next command: open a session in the frontend repo and run `/contract-change <backend PR number>`.

**Done when:** the backend PR is merged and the user has the hand-off line.

## Frontend half

1. **Find the seam.** Read `docs/agents/contract-seams.md` and pick the row whose backend repo is the one the PR argument belongs to (`gh pr view <n> --repo <owner/repo> --json title,mergeCommit,body`). Read the PR body for the endpoints that changed.
2. **Branch.** `git fetch origin && git switch -c chore/regenerate-<client>-<backend-pr> origin/<base>`. Refuse to branch from a dirty tree.
3. **Bring the backend up at the merged contract.** In the backend repo path from the row: `git switch <base> && git pull --ff-only`, confirm the merge commit is present (`git merge-base --is-ancestor <sha> HEAD`), then check whether the spec URL answers. If not, run the row's start command in the background and wait for the URL to answer. Never regenerate from a backend that is not on its base branch at or after the merge.
4. **Regenerate.** Run the row's generate command. Confirm the committed spec changed (`git diff --stat` on the client package) and that the diff matches the endpoints from step 1. A generate that changes nothing means the backend served a stale document: go back to step 3.
5. **Fix what the typecheck rejects.** `pnpm typecheck` (or the repo's equivalent). Every error is a call site the contract moved under. Fix each by intent: a renamed field is a rename, a removed endpoint is a removed feature, a new required parameter is a real question for the user. New behaviour the change enables is not this PR: file it as an issue and say so.
6. **Verify.** The repo's full verification (typecheck, lint, tests, build). Where a test asserted the old contract shape, the test changes with the contract; where a test fails for any other reason, stop and report.
7. **Ship it.** Call the Skill tool with "ship". The PR body carries `Refs <backend-repo>#<backend PR>` so the two PRs link, and `Closes #<n>` only if this repo had its own ticket for the change.
8. **Stop the backend** if step 3 started it.

**Done when:** the frontend PR is merged, the committed spec matches the merged backend, and the two PRs reference each other.
