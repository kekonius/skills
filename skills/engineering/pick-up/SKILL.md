---
name: pick-up
description: List the ready-for-agent tickets in this repo, pick one, claim it, branch, and load its agent brief so implement can start.
disable-model-invocation: true
argument-hint: "An issue number, or nothing to choose from the frontier"
---

# Pick up

Start a session from the issue tracker. The PR conventions and label vocabulary should have been provided to you in `docs/agents/`. If not, tell the user to run `/setup-kekonius-skills`.

## Process

### 1. Show the frontier

Skip this step when the user passed an issue number.

Query the open, unassigned `ready-for-agent` issues and their blocking state in one call:

```bash
gh api "repos/{owner}/{repo}/issues?labels=ready-for-agent&state=open&per_page=100" \
  --jq '.[] | select(.assignee == null) | {number, title, labels: [.labels[].name], blocked_by: .issue_dependencies_summary.blocked_by}'
```

Present them as a numbered list, **frontier first** (`blocked_by` is 0), then the blocked ones marked as such. Show number, title, area labels, and the blocker count. Let the user pick. Where the list is empty, say so and stop: `to-tickets` and `triage` are how tickets get here.

### 2. Claim it

`gh issue edit <n> --add-assignee @me`. The assignee is the claim: a concurrent session skips assigned tickets. If the ticket is blocked, say which issues block it and ask before claiming; the user may know a blocker is done but not closed.

### 3. Branch

Read the base branch and branch prefixes from `docs/agents/issue-tracker.md`. Then:

```bash
git fetch origin
git switch -c <prefix>/<issue-number>-<slug> origin/<base>
```

where `<prefix>` is `feat` for an enhancement and `fix` for a bug, and `<slug>` is the title in kebab-case, trimmed. Refuse to branch from a dirty working tree: report `git status` and stop.

### 4. Load the brief

`gh issue view <n> --comments`. Find the agent brief: the body when it is in the brief format, otherwise the last comment that is. Read the parent spec too when the ticket is a sub-issue (`Part of #<n>`, or the parent in `gh api repos/{owner}/{repo}/issues/<n>/parent`). Summarise for the user in five lines or fewer: what to build, the acceptance criteria count, contract impact, blocked by.

A ticket with no brief is not ready: tell the user to run `/triage` on it, unassign (`--remove-assignee @me`), and stop.

### 5. Hand off

Tell the user: the branch is `<name>`, the brief is loaded, and the next command is `/implement`. Nothing is built here.

**Done when:** the issue is assigned, the branch exists on the fresh base, the brief is in context, and the user has been told to run `/implement`.
