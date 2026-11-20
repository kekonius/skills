# kekonius-skills

A collection of Claude Code skills for one engineer's workflow, in any language and any architecture: a modular monolith, or separately deployed services across several repos. GitHub Issues is the tracker. Language specifics live in **Stack packs**; project facts live in per-repo configuration emitted by `/setup-kekonius-skills`. Skills are organized into buckets.

## Language

**Issue**:
A single tracked unit of work in a repo's GitHub Issues: a bug, a spec, or a ticket produced by `to-tickets`.
_Avoid_: task, item, card

**Ticket**:
An **Issue** created by `to-tickets` or `wayfinder` to be worked by one agent session. A ticket carries an **Agent brief** and its blocking edges. Use "ticket" only for these; a bug report or a spec is an **Issue**.

**Agent brief**:
The body of a **Ticket**: a durable, behavioural specification with acceptance criteria and scope boundaries, written so it survives refactors. The brief is the contract; the discussion is context.

**Triage role**:
A canonical state label on an **Issue**: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. `/setup-kekonius-skills` maps each role to the label string a repo actually uses.

**Backlog**:
The `docs/tasks/*.md` checklist some repos keep as a human-readable, implementation-ordered view of the work, each task referencing its issue. GitHub Issues are the source of truth; `ship` ticks the matching task when it closes an issue, and nothing else edits the file as a tracker.

**Ship**:
The closing move of a change: verify, push, open the PR, wait for CI, merge, close the **Issue**, update the **Backlog**, delete the branch. Done by `/ship`.

**Contract impact**:
The contracts another deployable consumes that a change adds, changes, or removes (an HTTP API, an integration event or message schema, a shared schema), each with the repos that consume it. Stated in the spec and every **Agent brief**; reported by **Ship**.

**Contract change**:
A backend API change that also changes the generated OpenAPI client in the frontend monorepo. Always two linked PRs, backend first. Done by `/contract-change`.

**Approval gate**:
The point in `/implement` where the plan and ordered task list are shown and no implementation code is written until the user approves.

**Architecture rules**:
The dependency and seam rules a repo enforces, by whatever enforces them: architecture tests, compiler visibility, a linter, or contract tests between separately deployed services. `/code-review` checks a diff against them as its third axis.

**Stack pack**:
A file that maps the skills' concepts onto one language: module interface, architecture-rule enforcement, tests and test doubles, integration-test infrastructure, verify commands, house opinions, examples. Built in to `stack-conventions`, or repo-local under `docs/agents/packs/`. A repo's `docs/agents/stack.md` maps its paths to packs.
_Avoid_: language profile, stack config

**Invariants file**:
A repo's `docs/agents/invariants.md`: project rules `/code-review` holds on every diff, exactly as it holds its invariant baseline. Written by `/setup-kekonius-skills`.

**Service**:
A module deployed separately. Use the word only in that sense; inside one deployable, say module.

**Decision record (ADR)**:
A file under `docs/decisions/ADR-NNNN-<slug>.md` recording a non-trivial design decision and its reasoning. `/domain-modeling` writes them.

**Promoted**:
A skill in `engineering/` or `productivity/`. Promoted skills ship in the plugin and appear in the README and the router.

## Relationships

- An **Issue** may be a **Ticket**; every **Ticket** is an **Issue**
- A **Ticket** carries one **Agent brief** and one **Triage role** at a time
- `/implement` builds one **Ticket** and ends by calling `/ship`
- A **Contract change** produces two **Ship**s, backend first
- A **Contract change** is the one kind of **Contract impact** a skill closes; **Ship** flags every other kind for a follow-up in the consuming repos
- A repo maps each path to one or more **Stack packs**

## Flagged ambiguities

- "backlog" used to mean both the tracker and the markdown file. Resolved: the tracker is GitHub Issues; **Backlog** is only the `docs/tasks` checklist.
