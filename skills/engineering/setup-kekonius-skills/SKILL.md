---
name: setup-kekonius-skills
description: "Configure this repo for the engineering skills: GitHub labels, pull request conventions, domain doc layout, and the backlog file. Run once per repo before first use of the other engineering skills."
disable-model-invocation: true
---

# Setup kekonius skills

Scaffold the per-repo configuration the engineering skills assume:

- **Issue tracker**: GitHub Issues, always. What this records is *how this repo* uses them: labels, PR conventions, merge method, the backlog file.
- **Triage labels**: the label strings for the five canonical triage roles.
- **Domain docs**: where `CONTEXT.md` and ADRs live, and the rules for reading them.

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Read whatever exists; don't assume:

- `git remote -v`: the repo must be on GitHub. If it is not, stop and tell the user these skills assume GitHub Issues.
- `gh repo view --json defaultBranchRef,squashMergeAllowed,mergeCommitAllowed,rebaseMergeAllowed,deleteBranchOnMerge,viewerDefaultMergeMethod`: base branch and merge method.
- `gh label list --limit 200 --json name,description`: which of the five triage roles exist, and which area labels the repo already uses.
- `git log --oneline -20`: the commit message style in use (conventional-commit prefixes or not).
- `.github/workflows/`: which checks run on a PR, so `ship` knows what to wait for.
- `CLAUDE.md` and `AGENTS.md` at the repo root: does either exist? Is there already an `## Agent skills` section?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root.
- ADR directories: `docs/decisions/`, `docs/adr/`, and any `src/*/docs/adr/`. Note the filename pattern in use (`ADR-0001-slug.md`, `0001-slug.md`).
- `docs/tasks/*.md`: a backlog checklist.
- `docs/agents/`: this skill's prior output.
- Generated API clients: a package whose scripts run `openapi-typescript` (or another generator) against a fetched spec. Note the package name, the generate command, and the spec URL its fetch script reads.
- Served API document: a backend that exposes `/openapi/*.json` (or `/swagger/*.json`). Note the route and the host's run command.
- Monorepo signals: `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, several `.csproj` modules under `src/Modules/`. Present only in a genuinely multi-context repo; their absence means single-context, which is almost every repo.

**Done when:** every bullet above has a finding, present or absent.

### 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order. One section, one answer, then the next. Lead each section with the recommended answer so the user can accept it in a word. Skip a section entirely when exploration already settled it.

**Section A: Pull request conventions.** Propose what exploration found: base branch, branch prefixes (`feat/`, `fix/`, `chore/` by default), commit style, merge method (squash by default), and the CI checks `ship` waits for. Ask one question: is this right?

**Section B: Triage labels.** Ask exactly one question:

> Keep the default triage labels? (recommended: **yes**)

The defaults are the five canonical roles, each label string equal to its name: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. On **yes**, create any that are missing with `gh label create <name> --description "<meaning>"`. Only if the user says no, usually because the tracker already uses other names, collect the overrides so the skills apply existing labels instead of creating duplicates.

Area labels (module, layer, phase) are the repo's own. Record the ones that exist; invent none.

**Section C: Domain docs.** Default to **single-context**: one `CONTEXT.md` at the root and one ADR directory. Propose the ADR directory and filename pattern exploration found, or `docs/decisions/ADR-NNNN-<slug>.md` when there is none. Write it without asking unless exploration found monorepo signals; then offer **multi-context** (a root `CONTEXT-MAP.md` pointing at per-context `CONTEXT.md` files) and confirm.

**Section D: Backlog.** Skip when `docs/tasks/` is absent. When present, ask one question:

> Keep `docs/tasks/<file>.md` as a checklist that `ship` ticks when it closes an issue? (recommended: **yes**)

On **no**, record that the backlog is retired and the file is left alone.

**Section E: Contract seams.** Skip when exploration found no generated client. When it found one, ask for each client package, in one exchange: the local path of the backend repo that serves its spec, and the command that starts that backend. Propose what you can infer (a sibling directory under the same parent, the run command in that repo's `CLAUDE.md`). The base branch, spec URL, and generate command come from exploration.

**Done when:** every section has an answer or was skipped for a stated reason.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to `CLAUDE.md` or `AGENTS.md` (see step 4 for which)
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`, `docs/agents/agent-brief.md`, and, when Section E ran, `docs/agents/contract-seams.md`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create.

Always edit the one that's already there. If an `## Agent skills` block already exists, update it in place rather than appending a duplicate, and leave the surrounding sections untouched.

The block:

```markdown
## Agent skills

### Issue tracker

GitHub Issues. [one line: base branch, merge method, backlog file or none]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one line: default roles, or the overrides]. See `docs/agents/triage-labels.md`.

### Domain docs

[one line: "single-context" or "multi-context", ADR directory]. See `docs/agents/domain.md`.

### Agent briefs

Tickets that are `ready-for-agent` carry a brief in the format in `docs/agents/agent-brief.md`.

### Contract seams

[only when Section E ran: one line naming the client package(s) and the backend they consume]. See `docs/agents/contract-seams.md`.
```

Then write the docs files from the seed templates in this skill folder, filling in what step 2 settled:

- [issue-tracker.md](./issue-tracker.md): GitHub conventions, PR conventions, backlog, wayfinding operations
- [triage-labels.md](./triage-labels.md): role to label mapping
- [domain.md](./domain.md): domain doc consumer rules and layout
- [agent-brief.md](./agent-brief.md): the ticket body format, copied verbatim
- [contract-seams.md](./contract-seams.md): one row per generated client, only when Section E ran

Create any missing triage labels now, per Section B.

**Done when:** the block is in place, the files exist, and `gh label list` shows all five roles.

### 5. Done

Tell the user the setup is complete and that `to-spec`, `to-tickets`, `triage`, `wayfinder`, `pick-up`, `ship`, and `contract-change` now read from `docs/agents/`. They can edit those files directly later; re-running this skill is only needed to start from scratch.
