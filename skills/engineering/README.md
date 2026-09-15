# Engineering

Skills for daily code work.

## User-invoked

Reachable only when you type them (`disable-model-invocation: true`).

- **[ask-kekonius](./ask-kekonius/SKILL.md)**: Ask which skill or flow fits your situation. A router over the skills in this repo.
- **[setup-kekonius-skills](./setup-kekonius-skills/SKILL.md)**: Configure this repo for the engineering skills (GitHub labels, PR conventions, ADR layout, backlog file). Run once per repo.
- **[grill-with-docs](./grill-with-docs/SKILL.md)**: Grilling session that also builds your project's domain model, sharpening terminology and updating `CONTEXT.md` and ADRs inline, with a threat-model pass when the change touches auth, tenancy, or money.
- **[to-spec](./to-spec/SKILL.md)**: Turn the current conversation into a spec and publish it as a GitHub issue. No interview, just synthesis, with a contract-impact section.
- **[to-tickets](./to-tickets/SKILL.md)**: Break a plan, spec, or conversation into tracer-bullet tickets on GitHub: sub-issues of the spec, native blocking edges, an agent brief each, labelled `ready-for-agent`.
- **[pick-up](./pick-up/SKILL.md)**: List the `ready-for-agent` frontier, pick a ticket, claim it, branch off a fresh base, and load its brief for `implement`.
- **[implement](./implement/SKILL.md)**: Build one ticket: understand, plan with an ordered task list, stop at the approval gate, drive `tdd` slice by slice, record ADRs, verify, `code-review`, then hand off to `ship`.
- **[implement-spec](./implement-spec/SKILL.md)**: Implement a whole spec AFK on one branch: implementer subagents in worktrees across the ticket frontier, merged back one by one, reviewed, then handed to `ship` as a single PR.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[tdd](./tdd/SKILL.md)**: Test-driven development with a red-green loop, one vertical slice at a time, at pre-agreed seams. xUnit and Vitest examples; a control needs a test that fails when the control is removed.
- **[domain-modeling](./domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model by challenging terms, stress-testing with scenarios, and updating `CONTEXT.md` and `docs/decisions/ADR-NNNN` inline.
- **[codebase-design](./codebase-design/SKILL.md)**: Shared discipline and vocabulary for designing deep modules: small interfaces, clean seams, testable through the interface, within the seams the architecture rules fix.
- **[ship](./ship/SKILL.md)**: Close the loop on a finished branch: verify, commit, push, PR, wait for CI, merge, confirm the issues closed, tick the backlog, clean up. Reached by `implement`, `implement-spec`, and `contract-change`, or by asking to ship.
- **[code-review](./code-review/SKILL.md)**: Three-axis review of the diff since a fixed point: **Standards** (repo coding standards plus a Fowler smell baseline), **Spec** (does it implement the agent brief?), and **Architecture** (architecture tests, binding docs, ADRs, tenancy and immutability invariants), run as parallel sub-agents.
