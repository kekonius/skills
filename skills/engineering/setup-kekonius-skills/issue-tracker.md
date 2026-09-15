# Issue tracker: GitHub

Issues, specs, and tickets for this repo live as GitHub Issues. Use the `gh` CLI for every operation; it infers the repo from `git remote -v`.

## Issues

- **Create**: `gh issue create --title "..." --body "..." --label "..."`. Use a heredoc for multi-line bodies.
- **Read**: `gh issue view <number> --comments`.
- **List**: `gh issue list --state open --json number,title,body,labels --jq '...'` with `--label` and `--state` filters.
- **Comment**: `gh issue comment <number> --body "..."`.
- **Labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`.
- **Close**: `gh issue close <number> --comment "..."`.

Area labels this repo uses: _<fill in from `gh label list`, or "none">_. Apply the ones that fit when creating an issue; never create new area labels without asking.

When a skill says "publish to the issue tracker": create a GitHub issue. When a skill says "fetch the relevant ticket": `gh issue view <number> --comments`.

## Pull requests

- **Base branch**: `_<master or main>_`. Never commit to it directly.
- **Branch naming**: `feat/<kebab>`, `fix/<kebab>`, `chore/<kebab>`, one branch per issue.
- **Commit style**: _<conventional-commit prefixes (`feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `chore:`), or the repo's own>_.
- **PR title**: same style as the commits. **PR body**: what changed and why, then `Closes #<issue>`.
- **Create**: `gh pr create --base <base> --title "..." --body "..."`.
- **Merge method**: _<squash / merge / rebase>_. `gh pr merge <number> --<method> --delete-branch`.
- **CI checks to wait for**: _<workflow or job names from `.github/workflows/`>_. `gh pr checks <number> --watch` blocks until they finish.
- **Auto-merge policy**: `ship` merges once every check is green and the PR has no requested changes. A red check is never merged around.

## Backlog

_<one of the two lines below; delete the other>_

- `docs/tasks/<file>.md` is a checklist of tasks, each referencing its issue. When `ship` closes an issue, it ticks the matching task (`- [ ]` to `- [x]`) and adds the closing date, in the same PR or a follow-up commit.
- No backlog file. GitHub Issues are the only list of open work.

## Agent briefs

A ticket that is `ready-for-agent` carries an agent brief in its body or as the last triage comment: a behavioural spec with acceptance criteria and scope boundaries, written to survive refactors (types and contracts named, file paths and line numbers avoided). `pick-up` and `implement` read it as the contract; the rest of the thread is context.

## Wayfinding operations

Used by `wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: an issue labelled `wayfinder:map`, holding the Destination / Notes / Decisions-so-far / Not-yet-specified / Out-of-scope body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue: `gh api --method POST repos/<owner>/<repo>/issues/<map>/sub_issues -F sub_issue_id=<child-db-id>`, where the database id comes from `gh api repos/<owner>/<repo>/issues/<n> --jq .id` (not the `#number`, not the `node_id`). Where sub-issues are unavailable, add the child to a task list in the map body and put `Part of #<map>` at the top of the child body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's native issue dependencies: `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`. GitHub reports `issue_dependencies_summary.blocked_by` (open blockers only, the live gate). Where dependencies are unavailable, fall back to a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children, drop any with an open blocker or an assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me`, the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer (gist + link) to the map's Decisions-so-far.
