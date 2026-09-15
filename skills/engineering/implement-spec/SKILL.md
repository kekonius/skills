---
name: implement-spec
description: "Implement a whole spec AFK on one branch: work its tickets as a task graph with implementer subagents in worktrees across the ready frontier, merge each back, review, and hand off to ship as a single PR."
disable-model-invocation: true
argument-hint: "The spec issue number"
---

# Implement spec

You have been given a spec issue. Its tickets are its sub-issues on GitHub, each carrying an agent brief and blocking edges. The goal is **one PR** that implements the entire spec on a single branch, then hands to `ship`.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, exploration notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** run in the background where possible for **maximum concurrency**.

The PR conventions are in `docs/agents/issue-tracker.md`; if it is missing, tell the user to run `/setup-kekonius-skills`.

## Steps

1. **Read the graph.** `gh issue view <spec> --comments` for the spec, then its children:

   ```bash
   gh api "repos/{owner}/{repo}/issues/<spec>/sub_issues" \
     --jq '.[] | {number, title, state, assignee: .assignee.login, blocked_by: .issue_dependencies_summary.blocked_by}'
   ```

   Read each open ticket's brief. Read enough to hold the task graph: which tickets are on the frontier now, which unlock when.

2. **Explore once (optional).** Use an **exploration subagent** to do any codebase or documentation reading the tickets share. It saves its notes as markdown in a directory outside the repo that every later subagent can read (the scratchpad directory). Implementer subagents then implement rather than explore.

3. **Branch and draft the PR.** From a fresh base: `git fetch origin && git switch -c feat/<spec>-<slug> origin/<base>`. Push it and open a draft PR whose body says `Closes #<spec>` and one `Closes #<ticket>` per ticket. Assign each ticket to `@me` as you start it, so a concurrent session skips it.

4. **Implement the frontier.** For each ready ticket, start an **implementer subagent** in its own worktree and branch (`git worktree add ../<repo>-<ticket> -b ticket/<number> feat/<spec>-<slug>`). Its brief is pointers only: the ticket number, the spec number, the notes directory, the PR branch. Its instructions: read the brief, call the Skill tool with "tdd", build the slice at the brief's seams with tests, run the touched tests and the build, commit in the repo's commit style, and report the commit range and anything the brief got wrong.

5. **Merge each one back.** When an implementer completes, a **merger subagent** merges its branch into the PR branch. It calls the Skill tool with "resolving-merge-conflicts" when needed, runs the build and the touched tests on the merged result, and pushes. A merge that goes red is the implementer's to fix, in the same worktree, before it merges.

6. **Advance the frontier.** A merged ticket may unblock others. Recompute the frontier from the graph and start implementers for the newly ready tickets. Repeat until every ticket is merged.

7. **Review.** Call the Skill tool with "code-review" against the base branch. Hand every finding to a single **implementer subagent** on the PR branch to fix, then re-run the review once.

8. **Verify.** Run the full suite, the architecture tests, and the format check on the PR branch. Everything green.

9. **Clean up worktrees.** `git worktree remove` each implementer worktree and delete its branch.

10. **Hand off.** `gh pr ready <number>`, then call the Skill tool with "ship". Ship merges the PR, which closes the spec and every ticket through the `Closes` lines.

**Done when:** ship reports the PR merged, the worktrees are gone, and every ticket and the spec are closed.
