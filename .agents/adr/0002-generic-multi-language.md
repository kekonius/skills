# Any language, any architecture: stack packs and per-repo project facts

Decided 2026-11-20. Supersedes in part [ADR 0001](./0001-fork-of-mattpocock-skills-for-one-workflow.md).

## Context

ADR 0001 recorded the author's environment, established by inspection: .NET modular monoliths and a pnpm + Turborepo React frontend. The skills were written for it. C# and Vitest examples, `dotnet` and `pnpm` fallbacks, NetArchTest and dependency-cruiser as the architecture rules, and facts from one accounting product (tenancy-tree scoping, immutable posted entries, Swedish bookkeeping standards) sat inside the core skills.

Two things changed. The author also works in Rust and Python. And some work is microservices in separate repos, where a changed integration event or service API is as much a contract as the OpenAPI surface a frontend consumes.

## Decisions

1. **The core skills are language- and project-neutral.** They keep the repo's vocabulary (module, interface, seam, depth, adapter); "service" means a separately deployed module.
2. **Language specifics live in one model-invoked skill, `stack-conventions`,** as packs: csharp, rust, python, typescript, and react layered on typescript. Each pack maps the concepts onto one language. A repo's `docs/agents/stack.md` maps paths to packs, and only the matching packs load. A repo may keep its own pack under `docs/agents/packs/`.
3. **Architecture rules are whatever enforces them**: tests, compiler visibility, a linter, or contract tests between separately deployed services.
4. **Project facts live in per-repo configuration** written by `setup-kekonius-skills`. `docs/agents/invariants.md` holds project invariants, and `code-review` treats them exactly as its baseline, which keeps only language- and project-neutral checks: interface bypass, layer inversion, non-idempotent consumer, foreign write, secrets in code, and test shape. The last two hold at both scales, inside one deployable and between separately deployed services, and a repo without integration events or shared data never trips them.
5. **Contract impact covers every contract another deployable consumes** (HTTP APIs, integration event and message schemas, shared schemas), each with its consuming repos. `contract-change` still closes only the OpenAPI surface a frontend consumes through a generated client. For every other contract, `ship` names the consuming repos and flags the follow-up; nothing automates it.
6. **Examples use one neutral running domain**, an online shop.

## What this supersedes in ADR 0001

The **Stack** bullet of ADR 0001's Context stops being an assumption of the skills. It stays true of the author's primary repos, and is now expressed through the csharp, typescript, and react packs and those repos' own `stack.md` and `invariants.md`. The rest of ADR 0001 stands: Claude Code only, GitHub Issues only, the structure and conventions, and `ship` merging PRs.

## Consequences

- A product repo loses the tenant-scoping and immutability review checks until it re-runs `/setup-kekonius-skills` and restores them from the invariants template, which carries them word for word. That loss is why this ships as 2.0.0.
- A repo's existing `docs/agents/agent-brief.md` keeps the old contract-impact line and lacks the prototype-snippet exception until setup is re-run.
- Some stack- or product-flavoured wording stays on purpose, because those files are protected from rewording: the auth, tenancy, or money triggers in `grill-with-docs` and `wayfinder` (mirrored by `threat-model`'s description); the ERP, accountant, and OpenAPI-seam examples in `ask-kekonius`; and `contract-change` with its `contract-seams.md` template.
- Supporting a new language is a new pack, not an edit to every skill.
