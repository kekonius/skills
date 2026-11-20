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
- **[contract-change](./contract-change/SKILL.md)**: Ship a backend API change and the frontend client regeneration it forces, as two linked PRs, backend first. Run in the backend repo, then in the frontend repo.
- **[triage](./triage/SKILL.md)**: Move issues and external PRs through a state machine of triage roles: categorise, verify, grill if needed, and write agent briefs. For issues you didn't create or fully specify.
- **[wayfinder](./wayfinder/SKILL.md)**: Plan a new module or project, too big for one session, as a shared map of decision tickets on GitHub, resolved one at a time until the way to the destination is clear.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)**: Survey a codebase for deepening opportunities against its architecture rules and docs, present the candidates, then grill through whichever one you pick.
- **[git-guardrails](./git-guardrails/SKILL.md)**: Install the hook that blocks force-push, `reset --hard`, `clean -f`, discarding the working tree, and deleting the base branch, while push, merge, and feature-branch cleanup stay allowed. Once per machine.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[prototype](./prototype/SKILL.md)**: Build a throwaway prototype to answer a design question: a single shareable HTML file for state/logic, or several toggleable UI variations on one route.
- **[diagnosing-bugs](./diagnosing-bugs/SKILL.md)**: Disciplined diagnosis loop for hard bugs and performance regressions: build a feedback loop that goes red on this bug → minimise → hypothesise → instrument → fix → regression-test.
- **[research](./research/SKILL.md)**: Investigate a question against high-trust primary sources and capture the findings as a cited Markdown file in the repo, run as a background agent.
- **[tdd](./tdd/SKILL.md)**: Test-driven development with a red-green loop, one vertical slice at a time, at pre-agreed seams, with test tooling and examples from the stack pack; a control needs a test that fails when the control is removed.
- **[domain-modeling](./domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model by challenging terms, stress-testing with scenarios, and updating `CONTEXT.md` and `docs/decisions/ADR-NNNN` inline.
- **[codebase-design](./codebase-design/SKILL.md)**: Shared discipline and vocabulary for designing deep modules: small interfaces, clean seams, testable through the interface, within the seams the architecture rules fix.
- **[stack-conventions](./stack-conventions/SKILL.md)**: How this repo's languages express seams, architecture rules, tests, test doubles, and verify commands, through one pack per language (C#, Rust, Python, TypeScript, React) mapped to paths in `docs/agents/stack.md`. Only the matching packs load.
- **[ship](./ship/SKILL.md)**: Close the loop on a finished branch: verify, commit, push, PR, wait for CI, merge, confirm the issues closed, tick the backlog, clean up. Reached by `implement`, `implement-spec`, and `contract-change`, or by asking to ship.
- **[resolving-merge-conflicts](./resolving-merge-conflicts/SKILL.md)**: Work through an in-progress git merge or rebase conflict hunk by hunk, resolving by intent traced to each side's primary source, then finish the operation, never `--abort`.
- **[wizard](./wizard/SKILL.md)**: Generate an interactive bash wizard that walks a human through steps only they can perform: provisioning infrastructure, credentials or CI secrets, an unfamiliar third-party dashboard, a one-off migration or cutover.
- **[threat-model](./threat-model/SKILL.md)**: Facilitate a STRIDE threat model for one endpoint or workflow: asks first, fills gaps second, turns every mitigation into a named test, never writes the model for you.
- **[code-review](./code-review/SKILL.md)**: Three-axis review of the diff since a fixed point: **Standards** (repo coding standards plus a Fowler smell baseline), **Spec** (does it implement the agent brief?), and **Architecture** (architecture tests, binding docs, ADRs, invariants, including the repo's own from `docs/agents/invariants.md`), run as parallel sub-agents.
