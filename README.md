# kekonius-skills

Claude Code skills for one engineer's loop: idea → grilling → spec → tickets → implement → review → ship. Works in any language and any architecture, from a modular monolith to separately deployed services across several repos: language specifics live in stack packs (C#, Rust, Python, TypeScript, React), project rules in per-repo config. GitHub Issues is the tracker.

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

Then, once per repo, run `/setup-kekonius-skills` to configure labels, ADR layout, the backlog file, stack packs, project invariants, and quality attributes.

## Reference

Skills split on one axis: who can invoke them. **User-invoked** skills are reachable only when you type them (`/grill-me`); their job is to orchestrate. **Model-invoked** skills can be invoked by you or reached for automatically by the agent when the task fits; they hold the reusable discipline. A user-invoked skill may invoke model-invoked skills, but never another user-invoked one.

### Engineering

Skills for daily code work.

**User-invoked**

- **[ask-kekonius](./skills/engineering/ask-kekonius/SKILL.md)**: Ask which skill or flow fits your situation. A router over the skills in this repo.
- **[setup-kekonius-skills](./skills/engineering/setup-kekonius-skills/SKILL.md)**: Configure this repo for the engineering skills (GitHub labels, PR conventions, ADR layout, backlog file, stack packs, project invariants, quality attributes). Run once per repo.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)**: Grilling session that also builds your project's domain model, sharpening terminology and updating `CONTEXT.md` and ADRs inline, with a threat-model pass when the change touches auth, tenancy, or money, and a quality-attributes pass when it touches events between modules or services, a latency or availability target, or a service split.
- **[to-spec](./skills/engineering/to-spec/SKILL.md)**: Turn the current conversation into a spec and publish it as a GitHub issue. No interview, just synthesis, with a contract-impact section.
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)**: Break a plan, spec, or conversation into tracer-bullet tickets on GitHub: sub-issues of the spec, native blocking edges, an agent brief each, labelled `ready-for-agent`.
- **[pick-up](./skills/engineering/pick-up/SKILL.md)**: List the `ready-for-agent` frontier, pick a ticket, claim it, branch off a fresh base, and load its brief for `implement`.
- **[implement](./skills/engineering/implement/SKILL.md)**: Build one ticket: understand, plan with an ordered task list, stop at the approval gate, drive `tdd` slice by slice, record ADRs, verify, `code-review`, then hand off to `ship`.
- **[implement-spec](./skills/engineering/implement-spec/SKILL.md)**: Implement a whole spec AFK on one branch: implementer subagents in worktrees across the ticket frontier, merged back one by one, reviewed, then handed to `ship` as a single PR.
- **[contract-change](./skills/engineering/contract-change/SKILL.md)**: Ship a backend API change and the frontend client regeneration it forces, as two linked PRs, backend first. Run in the backend repo, then in the frontend repo.
- **[triage](./skills/engineering/triage/SKILL.md)**: Move issues and external PRs through a state machine of triage roles: categorise, verify, grill if needed, and write agent briefs. For issues you didn't create or fully specify.
- **[wayfinder](./skills/engineering/wayfinder/SKILL.md)**: Plan a new module or project, too big for one session, as a shared map of decision tickets on GitHub, resolved one at a time until the way to the destination is clear.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)**: Survey a codebase for deepening opportunities against its architecture rules and docs, present the candidates, then grill through whichever one you pick.
- **[git-guardrails](./skills/engineering/git-guardrails/SKILL.md)**: Install the hook that blocks force-push, `reset --hard`, `clean -f`, discarding the working tree, and deleting the base branch, while push, merge, and feature-branch cleanup stay allowed. Once per machine.

**Model-invoked**

- **[prototype](./skills/engineering/prototype/SKILL.md)**: Build a throwaway prototype to answer a design question: a single shareable HTML file for state/logic, or several toggleable UI variations on one route.
- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)**: Disciplined diagnosis loop for hard bugs and performance regressions: build a feedback loop that goes red on this bug → minimise → hypothesise → instrument → fix → regression-test.
- **[research](./skills/engineering/research/SKILL.md)**: Investigate a question against high-trust primary sources and capture the findings as a cited Markdown file in the repo, run as a background agent.
- **[tdd](./skills/engineering/tdd/SKILL.md)**: Test-driven development with a red-green loop, one vertical slice at a time, at pre-agreed seams, with test tooling and examples from the stack pack; a control needs a test that fails when the control is removed.
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model by challenging terms, stress-testing with scenarios, and updating `CONTEXT.md` and `docs/decisions/ADR-NNNN` inline.
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)**: Shared discipline and vocabulary for designing deep modules: small interfaces, clean seams, testable through the interface, within the seams the architecture rules fix.
- **[stack-conventions](./skills/engineering/stack-conventions/SKILL.md)**: How this repo's languages express seams, architecture rules, tests, test doubles, and verify commands, through one pack per language (C#, Rust, Python, TypeScript, React) mapped to paths in `docs/agents/stack.md`. Only the matching packs load.
- **[quality-attributes](./skills/engineering/quality-attributes/SKILL.md)**: Specify a module's or service's vital few quality attributes as measurable six-part scenarios and pick tactics for them, with a module-integration reference for events and messaging between modules or services, data ownership, sagas, contracts, and splitting or merging services.
- **[ship](./skills/engineering/ship/SKILL.md)**: Close the loop on a finished branch: verify, commit, push, PR, wait for CI, merge, confirm the issues closed, tick the backlog, clean up. Reached by `implement`, `implement-spec`, and `contract-change`, or by asking to ship.
- **[resolving-merge-conflicts](./skills/engineering/resolving-merge-conflicts/SKILL.md)**: Work through an in-progress git merge or rebase conflict hunk by hunk, resolving by intent traced to each side's primary source, then finish the operation, never `--abort`.
- **[wizard](./skills/engineering/wizard/SKILL.md)**: Generate an interactive bash wizard that walks a human through steps only they can perform: provisioning infrastructure, credentials or CI secrets, an unfamiliar third-party dashboard, a one-off migration or cutover.
- **[threat-model](./skills/engineering/threat-model/SKILL.md)**: Facilitate a STRIDE threat model for one endpoint or workflow: asks first, fills gaps second, turns every mitigation into a named test, never writes the model for you.
- **[code-review](./skills/engineering/code-review/SKILL.md)**: Three-axis review of the diff since a fixed point: **Standards** (repo coding standards plus a Fowler smell baseline), **Spec** (does it implement the agent brief?), and **Architecture** (architecture tests, binding docs, ADRs, invariants, including the repo's own from `docs/agents/invariants.md`), run as parallel sub-agents.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the design tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)**: Compact the current conversation into a handoff document so another agent can continue the work.
- **[teach](./skills/productivity/teach/SKILL.md)**: Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[to-questionnaire](./skills/productivity/to-questionnaire/SKILL.md)**: Turn a decision you can't answer alone into a Markdown questionnaire for the one person who can (filled in async, or together over a meeting).
- **[wait-what](./skills/productivity/wait-what/SKILL.md)**: Fire this the moment a message doesn't land. The agent re-pitches it with the context you're missing, in plain English, using your `CONTEXT.md` vocabulary.

**Model-invoked**

- **[grilling](./skills/productivity/grilling/SKILL.md)**: Interview the user relentlessly about a plan, decision, or idea until every branch of the design tree is resolved. The interview primitive behind `grill-me`, `grill-with-docs`, `triage`, `wayfinder` and `improve-codebase-architecture`.
- **[writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md)**: Writing documents for agents: skills, AGENTS.md/CLAUDE.md, and any doc an agent reaches by a pointer.

### In progress

Beta skills live in [`skills/in-progress/`](./skills/in-progress/README.md). They are linked locally by the script above but not shipped in the plugin.

## Repo conventions

See [CLAUDE.md](./.claude/CLAUDE.md) for the rules this repo follows, [.agents/invocation.md](./.agents/invocation.md) for the invocation model, and [.agents/adr/](./.agents/adr/) for why it is shaped this way. `scripts/check-consistency.sh` checks that every skill is listed where it should be and nowhere else; CI runs it on every push.
