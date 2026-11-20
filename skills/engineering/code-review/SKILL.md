---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along three axes: Standards (does the code follow this repo's documented coding standards?), Spec (does the code match what the originating issue asked for?), and Architecture (does it keep the repo's binding architecture rules and ADRs?). Runs the reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Three-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue?
- **Architecture**: does the code keep the repo's binding architecture rules, ADRs, and tenancy or security invariants?

All three run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

The PR conventions should have been provided to you in `docs/agents/`. If `docs/agents/issue-tracker.md` is missing, tell the user to run `/setup-kekonius-skills`.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `master`, `HEAD~5`, etc.). If they didn't specify one, default to the base branch named in `docs/agents/issue-tracker.md`.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside three parallel sub-agents.

### 2. Identify the spec source

Look for the originating issue, in this order:

1. Issue references in the commit messages or branch name (`#123`, `Closes #45`, `feat/123-slug`), fetched with `gh issue view <n> --comments`. The agent brief in the body or last brief comment is the spec; read the parent spec issue too when the ticket has one.
2. A path or issue number the user passed as an argument.
3. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent is skipped and the report says "no spec available".

### 3. Identify the standards and architecture sources

**Standards**: anything in the repo that documents how code should be written: `docs/conventions/coding-standards.md`, `CONTRIBUTING.md`, the conventions section of `CLAUDE.md`, an `.editorconfig` with rules tooling does not already enforce, and the house opinions of the repo's stack pack.

**Stack pack**: call the Skill tool with "stack-conventions" and take from the loaded pack its house opinions and its architecture-rule enforcement and verify commands. Sub-agents cannot call skills, so step 4 pastes these excerpts into their prompts.

**Architecture**: the binding docs `CLAUDE.md` names (an architecture doc, a multitenancy or authorization convention, a testing strategy), the ADRs in the area the diff touches, and whatever enforces the repo's architecture rules: tests, compiler visibility, a linter, or contract tests between separately deployed services, with the commands that run them (as the repo documents, or from the pack). Where the repo has none of these, the Architecture axis carries only the invariants below.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

The Architecture axis always carries the **invariant baseline** below, which applies even when a repo documents nothing:

- **Boundary reach**: a module referencing another module's internals rather than its contract or public entry point.
- **Layer inversion**: domain code depending on infrastructure (an ORM, a bus, a framework) rather than the other way round.
- **Scoping bypass**: a query or write on tenant-scoped data that sidesteps the automatic filter or stamping (raw SQL, `IgnoreQueryFilters`, bulk verbs, a hand-built command).
- **Secrets in code**: a connection string, token, or key in source or committed config.
- **Immutability breach**: an update or delete path on data the domain declares append-only or immutable (posted entries, audit logs).
- **Test shape**: new behaviour without a test at the documented seam, or an integration test where the strategy says unit, and vice versa.

### 4. Spawn the sub-agents in parallel

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, the pack's house opinions pasted as documented standards, **plus the smell baseline pasted in full** (the sub-agent has no other access to it).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The fetched contents of the agent brief and, where present, the parent spec.
- The brief: "Report: (a) acceptance criteria the brief asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep), including anything the brief listed as out of scope; (c) criteria that look implemented but where the implementation looks wrong; (d) whether the brief's contract impact matches what the diff actually changes on the HTTP surface. Quote the brief line for each finding. Under 400 words."

**Architecture sub-agent prompt** should include:

- The diff command and commit list.
- The list of architecture-source files and ADRs from step 3, the pack's architecture-rule enforcement and the commands that check it, pasted, **plus the invariant baseline pasted in full**.
- The brief: "First run the commands that check the architecture rules and report their results verbatim. Then report, per hunk: (a) every place the diff breaks a documented rule or contradicts an ADR: cite the doc and the rule; (b) any baseline invariant breach: name it and quote the hunk; (c) any decision in the diff that meets the ADR bar (hard to reverse, surprising without context, a real trade-off) but has no ADR. A documented rule overrides the baseline. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the three reports under `## Standards`, `## Spec`, and `## Architecture` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the axes are deliberately separate (see _Why three axes_).

End with a one-line summary per axis: total findings and the worst issue _within that axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent. A failing architecture-rule check is reported as the worst issue on its axis regardless of anything else the sub-agent found.

## Why three axes

A change can pass two axes and fail the third:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**
- Code that is clean and correct but reaches across a module boundary or bypasses tenant scoping → **Standards pass, Spec pass, Architecture fail.** This is the failure that ships silently: nothing in the feature's own tests notices.

Reporting them separately stops one axis from masking another.
