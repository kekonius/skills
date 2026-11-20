---
name: ship
description: "Close the loop on a finished branch: verify, commit, push, open or update the PR, wait for CI, merge, confirm the issues closed, tick the backlog, and clean up the branch. Use when the user says ship, merge, or open the PR, or when implement, implement-spec, or contract-change hands off a reviewed branch."
---

# Ship

Take the current branch from "done on my machine" to merged on the base branch, with nothing left open behind it. The PR conventions (base branch, merge method, CI checks, backlog file) are in `docs/agents/issue-tracker.md`; if it is missing, tell the user to run `/setup-kekonius-skills`.

Every step has a stop condition. A stop is a report, never a workaround: a red check is not merged around, a conflict is resolved by intent, a secret is not committed.

## Process

### 1. Identify what this branch closes

Collect the issue numbers from, in order: the argument the user passed, the branch name (`feat/123-slug`), `Closes #n` in commits already on the branch, and the agent brief loaded in context. Fetch each with `gh issue view <n> --json title,state,body` and note each entry of the brief's **contract impact**: the changed contract and the repos that consume it.

**Done when:** you can name every issue this PR closes, or you have confirmed with the user that it closes none.

### 2. Verify

Run the repo's full verification: the commands `CLAUDE.md` lists, or the steps its CI workflow runs, whichever is more complete. When neither is documented, call the Skill tool with "stack-conventions" and run the pack's default verify commands. Whatever enforces the repo's architecture rules (tests, compiler visibility, a linter, or contract tests between separately deployed services) runs as part of verification, never skipped.

**Stop if** anything is red. Report the failing output and stop; the fix is an `implement` loop, not a shipping step.

### 3. Commit what is outstanding

- If the repo keeps a backlog file (see `docs/agents/issue-tracker.md`), tick the task that references each closed issue (`- [ ]` to `- [x]`, with today's date) so the tick lands in the same PR.
- Stage everything that belongs to the change. Before committing, scan the staged diff for secrets: connection strings, tokens, keys, `.env` contents. **Stop if** you find one; unstage it and report.
- Commit in the repo's commit style. One logical change per commit.

**Done when:** `git status` is clean and every commit message follows the style.

### 4. Push and open the PR

`git push -u origin HEAD`. Then, if a PR already exists for this branch (`gh pr view --json number,url`), update its body; otherwise create it:

```bash
gh pr create --base <base> --title "<commit-style title>" --body "$(cat <<'EOF'
<what changed and why, three to eight lines, in the repo's domain vocabulary>

Contract impact:
- <contract>: <what changed>. Consumers: <repos>

Closes #<n>
Closes #<m>
EOF
)"
```

One `Closes #n` line per issue from step 1. The contract impact block lists every entry from step 1, and is omitted when the impact is none. A draft PR is marked ready with `gh pr ready`.

**Done when:** the PR exists, is not a draft, targets the base branch, and its body names every issue.

### 5. Wait for CI

`gh pr checks <number> --watch --fail-fast`.

**If a check fails:** read the failure with `gh run view <run-id> --log-failed`. If the cause is in this branch and the fix is small (a lint error, a flaky test you can make deterministic, a format issue), fix it, commit, push, and wait again, at most twice. Otherwise stop and report the failing job and its log excerpt.

**Done when:** every required check is green.

### 6. Merge

Read the merge method from `docs/agents/issue-tracker.md` (squash by default). Then:

```bash
gh pr merge <number> --<method> --delete-branch
```

**If the PR is not mergeable** because the base moved: `git fetch origin && git merge origin/<base>`. When that conflicts, call the Skill tool with "resolving-merge-conflicts", then verify (step 2), push, and return to step 5. Never `--abort`, never force-push.

**Done when:** `gh pr view <number> --json state,mergeCommit` reports `MERGED` and a commit SHA.

### 7. Confirm the issues are closed

For each issue from step 1: `gh issue view <n> --json state`. GitHub closes them on merge through the `Closes` lines; where one is still open, close it yourself with `gh issue close <n> --comment "Merged in #<pr>"`. When the issue was a ticket under a spec and it was the last open child, say so: the spec issue may be ready to close, but that is the user's call.

### 8. Clean up locally

```bash
git switch <base>
git pull --ff-only
git branch -D <branch>
```

### 9. Report

Five lines or fewer, plus one line per contract-impact entry: the PR URL, the merge commit, the issues closed, the backlog task ticked (or "no backlog"), and each of these that applies:

- **Contract impact: none.** Done.
- **Contract impact: changes the OpenAPI surface a frontend consumes through a generated client.** The frontend client is now stale. When this ship was reached from `contract-change`, that skill continues; otherwise tell the user to open a session in the frontend repo and run `/contract-change <this PR number>` so the seam gets closed.
- **Contract impact: any other contract.** For each entry, name the changed contract and its consuming repos, and tell the user each of those repos needs a follow-up change. Nothing here makes that change.
