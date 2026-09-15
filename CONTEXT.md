# kekonius-skills

A collection of Claude Code skills for one engineer's workflow: .NET modular monoliths on PostgreSQL and RabbitMQ, a pnpm + Turborepo React frontend, GitHub Issues as the tracker. Skills are organized into buckets and consumed by per-repo configuration emitted by `/setup-kekonius-skills`.

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
The `docs/tasks/*.md` file some repos keep as a derived, human-readable view of open work. GitHub Issues are the source of truth; the backlog is regenerated from them, never edited as a second tracker.

**Ship**:
The closing move of a change: verify, push, open the PR, wait for CI, merge, close the **Issue**, update the **Backlog**, delete the branch. Done by `/ship`.

**Contract change**:
A backend API change that also changes the generated OpenAPI client in the frontend monorepo. Always two linked PRs, backend first. Done by `/contract-change`.

**Approval gate**:
The point in `/implement` where the plan and ordered task list are shown and no implementation code is written until the user approves.

**Architecture rules**:
The dependency and boundary rules a repo enforces with architecture tests (NetArchTest on the backend, dependency-cruiser on the frontend). `/code-review` checks a diff against them as its third axis.

**Decision record (ADR)**:
A file under `docs/decisions/ADR-NNNN-<slug>.md` recording a non-trivial design decision and its reasoning. `/domain-modeling` writes them.

**Promoted**:
A skill in `engineering/` or `productivity/`. Promoted skills ship in the plugin and appear in the README and the router.

## Relationships

- An **Issue** may be a **Ticket**; every **Ticket** is an **Issue**
- A **Ticket** carries one **Agent brief** and one **Triage role** at a time
- `/implement` builds one **Ticket** and ends by calling `/ship`
- A **Contract change** produces two **Ship**s, backend first

## Flagged ambiguities

- "backlog" used to mean both the tracker and the markdown file. Resolved: the tracker is GitHub Issues; **Backlog** is only the derived `docs/tasks` view.
