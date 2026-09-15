# kekonius-skills

Claude Code skills for one engineer's loop: idea → grilling → spec → tickets → implement → review → ship. Built for .NET modular monoliths and a pnpm + Turborepo React frontend, with GitHub Issues as the tracker.

Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). Same structure, same conventions, skills rewritten for this workflow.

## Installation

**As a plugin** (managed, read-only, updates on pull):

```bash
claude plugin marketplace add kekonius/skills
claude plugin install kekonius-skills@kekonius
```

**On this machine, from a clone** (symlinks, so `git pull` updates everything):

```bash
git clone https://github.com/kekonius/skills ~/dev/skills
~/dev/skills/scripts/link-skills.sh
```

Then, once per repo, run `/setup-kekonius-skills` to configure labels, ADR layout, and the backlog file.

## Reference

Skills split on one axis: who can invoke them. **User-invoked** skills are reachable only when you type them (`/grill-me`); their job is to orchestrate. **Model-invoked** skills can be invoked by you or reached for automatically by the agent when the task fits; they hold the reusable discipline. A user-invoked skill may invoke model-invoked skills, but never another user-invoked one.

### Engineering

Skills for daily code work.

**User-invoked**

- **[ask-kekonius](./skills/engineering/ask-kekonius/SKILL.md)**: Ask which skill or flow fits your situation. A router over the skills in this repo.
- **[setup-kekonius-skills](./skills/engineering/setup-kekonius-skills/SKILL.md)**: Configure this repo for the engineering skills (GitHub labels, PR conventions, ADR layout, backlog file). Run once per repo.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)**: Grilling session that also builds your project's domain model, sharpening terminology and updating `CONTEXT.md` and ADRs inline, with a threat-model pass when the change touches auth, tenancy, or money.
- **[to-spec](./skills/engineering/to-spec/SKILL.md)**: Turn the current conversation into a spec and publish it as a GitHub issue. No interview, just synthesis, with a contract-impact section.
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)**: Break a plan, spec, or conversation into tracer-bullet tickets on GitHub: sub-issues of the spec, native blocking edges, an agent brief each, labelled `ready-for-agent`.
- **[pick-up](./skills/engineering/pick-up/SKILL.md)**: List the `ready-for-agent` frontier, pick a ticket, claim it, branch off a fresh base, and load its brief for `implement`.
- **[implement](./skills/engineering/implement/SKILL.md)**: Build one ticket: understand, plan with an ordered task list, stop at the approval gate, drive `tdd` slice by slice, record ADRs, verify, `code-review`, then hand off to `ship`.
- **[implement-spec](./skills/engineering/implement-spec/SKILL.md)**: Implement a whole spec AFK on one branch: implementer subagents in worktrees across the ticket frontier, merged back one by one, reviewed, then handed to `ship` as a single PR.
- **[contract-change](./skills/engineering/contract-change/SKILL.md)**: Ship a backend API change and the frontend client regeneration it forces, as two linked PRs, backend first. Run in the backend repo, then in the frontend repo.
- **[git-guardrails](./skills/engineering/git-guardrails/SKILL.md)**: Install the hook that blocks force-push, `reset --hard`, `clean -f`, discarding the working tree, and deleting the base branch, while push, merge, and feature-branch cleanup stay allowed. Once per machine.

**Model-invoked**

- **[tdd](./skills/engineering/tdd/SKILL.md)**: Test-driven development with a red-green loop, one vertical slice at a time, at pre-agreed seams. xUnit and Vitest examples; a control needs a test that fails when the control is removed.
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model by challenging terms, stress-testing with scenarios, and updating `CONTEXT.md` and `docs/decisions/ADR-NNNN` inline.
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)**: Shared discipline and vocabulary for designing deep modules: small interfaces, clean seams, testable through the interface, within the seams the architecture rules fix.
- **[ship](./skills/engineering/ship/SKILL.md)**: Close the loop on a finished branch: verify, commit, push, PR, wait for CI, merge, confirm the issues closed, tick the backlog, clean up. Reached by `implement`, `implement-spec`, and `contract-change`, or by asking to ship.
- **[threat-model](./skills/engineering/threat-model/SKILL.md)**: Facilitate a STRIDE threat model for one endpoint or workflow: asks first, fills gaps second, turns every mitigation into a named test, never writes the model for you.
- **[code-review](./skills/engineering/code-review/SKILL.md)**: Three-axis review of the diff since a fixed point: **Standards** (repo coding standards plus a Fowler smell baseline), **Spec** (does it implement the agent brief?), and **Architecture** (architecture tests, binding docs, ADRs, tenancy and immutability invariants), run as parallel sub-agents.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the design tree is resolved.

**Model-invoked**

- **[grilling](./skills/productivity/grilling/SKILL.md)**: Interview the user relentlessly about a plan, decision, or idea until every branch of the design tree is resolved. The interview primitive behind `grill-me`, `grill-with-docs`, `triage`, `wayfinder` and `improve-codebase-architecture`.
- **[writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md)**: Writing documents for agents: skills, AGENTS.md/CLAUDE.md, and any doc an agent reaches by a pointer.

## Repo conventions

See [CLAUDE.md](./CLAUDE.md) for the rules this repo follows, [.agents/invocation.md](./.agents/invocation.md) for the invocation model, and [.agents/adr/](./.agents/adr/) for why it is shaped this way.
