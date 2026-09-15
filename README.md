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

**Model-invoked**

- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model by challenging terms, stress-testing with scenarios, and updating `CONTEXT.md` and `docs/decisions/ADR-NNNN` inline.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the design tree is resolved.

**Model-invoked**

- **[grilling](./skills/productivity/grilling/SKILL.md)**: Interview the user relentlessly about a plan, decision, or idea until every branch of the design tree is resolved. The interview primitive behind `grill-me`, `grill-with-docs`, `triage`, `wayfinder` and `improve-codebase-architecture`.
- **[writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md)**: Writing documents for agents: skills, AGENTS.md/CLAUDE.md, and any doc an agent reaches by a pointer.

## Repo conventions

See [CLAUDE.md](./CLAUDE.md) for the rules this repo follows, [.agents/invocation.md](./.agents/invocation.md) for the invocation model, and [.agents/adr/](./.agents/adr/) for why it is shaped this way.
