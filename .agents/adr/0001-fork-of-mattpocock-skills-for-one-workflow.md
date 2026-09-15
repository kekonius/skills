# Fork mattpocock/skills into a single-harness, GitHub-only skill set

Decided 2026-09-15, at the start of this repo.

## Context

[mattpocock/skills](https://github.com/mattpocock/skills) (MIT) is a well-structured set of agent skills with a bucket layout, an invocation model, a router, a setup skill, and plugin manifests. Its skills were already installed per repo, copied by skills.sh, in two of the author's repos. The copies drift, carry another author's branding, and assume choices (multiple trackers, multiple harnesses, a public docs site) that do not hold here.

The author's environment, established by inspection rather than interview:

- **Stack**: .NET 10 / C# 14 modular monoliths (EF Core, Dapper, PostgreSQL, MassTransit on RabbitMQ, Aspire, Elasticsearch, OpenTelemetry, xUnit, Testcontainers, NetArchTest) and a pnpm + Turborepo frontend (React 19, TypeScript, Vite, TanStack, Tailwind v4, shadcn on Base UI, a generated OpenAPI client). Sweden-first product work plus a security engineering learning project.
- **Harness**: Claude Code only. No Codex, Cursor, or other agent on the machine.
- **Tracker**: GitHub Issues with a `ready-for-agent` label vocabulary already in use, PRs on every repo, `docs/tasks/*.md` backlogs and `docs/decisions/ADR-NNNN` files in each repo.
- **Loop**: understand, plan with an ordered task list, a hard approval gate, implement with tests, record an ADR, verify, branch and PR. Where it breaks: shipping (PRs sit because merging is manual and nothing closes the issue or backlog) and the two-repo seam (a backend contract change needs a client regeneration that gets half done).

## Decisions

1. **Same structure and conventions as the reference**, adapted, not copied: bucket layout, promoted vs non-promoted, user- vs model-invoked, a router, a setup skill, `CLAUDE.md` as the source of truth, `CONTEXT.md` glossary, plugin manifests, the linking script, the em-dash ban, and the "call the Skill tool" wording.
2. **Claude Code only.** No `agents/openai.yaml`. Keep the `AGENTS.md` symlink and harness-neutral wording because they are free.
3. **GitHub Issues only, hard-coded.** No tracker abstraction, no GitLab or local-markdown templates. The setup skill asks about labels and doc layout, not about which tracker. `docs/tasks` backlogs become a derived view of open issues or are retired.
4. **Claude Code may merge PRs.** `ship` merges after CI is green. `git-guardrails` is adapted to allow push and merge while still blocking history-destroying commands.
5. **Keep every promoted skill from the reference**, adapted where the layout, tracker, or examples differ. The author wants the set to serve an open source project too, which is why `triage`, `wayfinder`, `wizard`, `teach`, `wait-what`, and `to-questionnaire` stay despite being rarely needed solo.
6. **Promote `implement-spec` and `git-guardrails`** from the reference's non-promoted buckets. Park `retro`, `claude-handoff`, and `setup-ts-deep-modules` in `in-progress/`. Drop `setup-pre-commit`, `loop-me`, the three `writing-*` skills, `migrate-to-shoehorn`, and `scaffold-exercises`. No `misc/` bucket.
7. **Four new skills**: `ship`, `contract-change`, `threat-model` (generalised from the VendorPay repo's local skill), and `pick-up`.
8. **Public, solo-maintained, light machinery.** Keep `plugin.json` and `marketplace.json` with a hand-bumped version. Drop changesets, `package.json`, `CHANGELOG.md`, the docs mirror, `.out-of-scope/`, and the canonical install block. One CI job: plugin validation plus a consistency check between the promoted buckets, `README.md`, `plugin.json`, and the router.

## Consequences

- Adding a tracker or a harness later is a deliberate change with its own ADR, not a branch in every skill.
- Every promoted skill has four places to keep in sync (bucket README, top-level README, `plugin.json`, router); the consistency check exists to make that mechanical.
- Version bumps are a human habit, not a bot. If the repo gains users, changesets can be added without restructuring.
