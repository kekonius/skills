---
name: ask-kekonius
description: Ask which skill or flow fits your situation. A router over the skills in this repo.
disable-model-invocation: true
---

# Ask kekonius

You don't remember every skill, so ask.

A **flow** is a path through the skills. Most paths run along one **main flow**, and three **on-ramps** merge onto it. Everything else is standalone, or a vocabulary layer that runs underneath.

## The main flow: idea → ship

The route most work travels. You have an idea and want it built and merged.

1. **`/grill-with-docs`** sharpens the idea by interview. Start here whenever you are **working in a repo**: it's stateful, retaining what it learns in `CONTEXT.md` and ADRs. (No repo? Use `/grill-me` instead, covered under Standalone. Both run the same `/grilling` primitive.) When the change touches auth, tenancy, or money, it pulls in **`/threat-model`** so the STRIDE pass happens before the spec, not after the PR.
2. **Branch: can you settle every question in conversation?** If a question needs a runnable answer (state, business logic, a UI you have to see), detour through **`/prototype`**, bridged by **`/handoff`** in both directions (a prototype lives in its own directory; see Phase boundaries).
3. **Branch: is this a multi-session build?**
   - **Yes** → **`/to-spec`** (turn the thread into a spec issue), then **`/to-tickets`** to split it into tracer-bullet tickets on GitHub, each `ready-for-agent`, each declaring its blocking edges. Then either:
     - **`/implement-spec`** builds the whole spec AFK: implementer subagents in worktrees across the ready frontier, one PR at the end. Reach for it when every ticket is well-briefed and you are happy to review one large PR.
     - **`/pick-up`** per ticket, **`/clear`ing context between each one**, when you want to steer each ticket yourself.
   - **No** → **`/implement`** right here, in the same context window.

   **`/implement`** builds one ticket: understand, plan with an ordered task list, **stop at the approval gate**, then drive **`/tdd`** (one red-green slice at a time), run **`/code-review`** (standards, spec, architecture rules), and hand off to **`/ship`**.
4. **`/ship`** closes the loop: verify (build, tests, architecture tests, format), push, open the PR, wait for CI, merge, close the issue, tick the backlog, delete the branch. Every flow ends here.

Reach for **`/tdd`** on its own when you just want to build a concrete behaviour test-first without a full spec, and **`/code-review`** on its own whenever you want to review a branch or PR against a fixed point.

### The contract seam

When the change is a backend API change that the frontend consumes through the generated OpenAPI client, run **`/contract-change`** in place of a bare `/ship`. In the backend repo it confirms the contract moved, ships the backend PR, and hands you the next command; in the frontend repo it brings the backend up at the merged contract, regenerates the client, fixes what the typecheck rejects, and ships that PR too. Two linked PRs, backend first, never a half-done seam. `/ship` on its own tells you when you needed this.

### Context hygiene

Keep steps 1–3 in **one unbroken context window** (don't compact or clear until after `/to-tickets`) so the grilling, spec, and tickets all build on the same thinking. Each `/pick-up` or `/implement` then starts fresh, working from the ticket's agent brief.

The limit on this is the **smart zone**: the window (roughly 150k tokens on current models) within which the model still reasons sharply. If a session approaches it before `/to-tickets`, don't push on degraded; `/compact` at the nearest phase boundary and carry on (see Phase boundaries).

## On-ramps

A starting situation that generates work, then merges onto the main flow.

- **Tickets are waiting** → **`/pick-up`**. Lists the `ready-for-agent` issues in this repo, lets you pick one, creates the branch, loads the agent brief, and hands to `/implement`. The default way to start a session in a repo with a backlog.

- **Bugs and requests piling up** → **`/triage`**. It moves issues through triage roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) and writes agent briefs, which `/pick-up` later picks up. Triage is only for issues **you didn't create** or didn't fully specify: bug reports, incoming requests on an open source repo, a one-line note to yourself. Tickets that `/to-tickets` produced are already agent-ready, so don't triage them.

- **Something's broken** → **`/diagnosing-bugs`**. For the hard ones: the bug that resists a first glance, the intermittent flake, the regression that crept in between two known-good states. It refuses to theorise until it has a **tight feedback loop** (one command that already goes red on *this* bug), then fixes with a regression test.

- **A new module or project, too big for one session** → **`/wayfinder`**, the most cognitively demanding flow here. When the way from here to the destination isn't visible yet, it charts a **shared map** of **decision tickets** on GitHub and resolves them one at a time, producing **decisions, not deliverables**, until the way is clear. Where `/grill-with-docs` sharpens an idea you can hold in one session, wayfinder is for the idea you can't. A new ERP module, a new open source project: yes. A feature: no.

  When the map clears, **it hands off, it doesn't build**: merge onto the main flow at **`/to-spec`**, then `/to-tickets` and `/implement-spec` or `/pick-up` as usual.

## Codebase health

Not feature work, just upkeep.

- **`/improve-codebase-architecture`** runs whenever you have a spare moment to keep the codebase good for agents to operate in. It surveys for **deepening opportunities** against the architecture tests and docs; picking one _generates an idea_ you take into the main flow at `/grill-with-docs`. It finds the candidates; **`/codebase-design`** (below) is the bench you design the chosen one on.
- **`/git-guardrails`** installs the hook that keeps an agent from destroying work. Run once per machine. Push, merge, and feature-branch cleanup stay allowed, because `/ship` needs them; force-push, `reset --hard`, `clean -f`, discarding the working tree, and deleting the base branch are blocked.

## Vocabulary underneath

Model-invoked references that run *beneath* the other skills, each the single source of truth for its vocabulary. Reach for them directly when the **words**, not the process, are the problem; or let the skills above pull them in.

- **`/domain-modeling`**: sharpen the project's *domain* language: challenge a fuzzy term, resolve an overloaded word, record a hard-to-reverse decision as an ADR in the repo's ADR directory. It's the active discipline `/grill-with-docs` drives to keep `CONTEXT.md` a clean glossary.
- **`/codebase-design`** is the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) for designing a module's *shape*: a lot of behaviour behind a small interface at a clean seam. `/tdd` and `/improve-codebase-architecture` both speak it.
- **`/stack-conventions`** maps that vocabulary onto the repo's languages: one pack per language (seams, architecture-rule enforcement, tests and doubles, verify commands), loaded by path from `docs/agents/stack.md`. `/tdd`, `/code-review`, and `/ship` pull it in.
- **`/quality-attributes`** turns "fast" or "available" into the vital few six-part scenarios a check can fail on, with tactics, and a module-integration reference for events, data ownership, sagas, contracts, and splitting or merging services.
- **`/threat-model`** is the STRIDE facilitator for one endpoint or workflow. It asks first and fills gaps second; it never writes the model for you. `/grill-with-docs` reaches for it when a change touches auth, tenancy, or money.

## Phase boundaries

A **phase** is a chunk of work inside a session: the grilling, the implementation, the QA. At the **boundary** between two of them you have five options, and picking between them is the fuzziest decision in this whole map:

- **Continue**: stay put. Costs nothing, loses nothing.
- **`/clear`**: empty the window, when nothing here matters to what's next.
- **`/handoff`** writes a portable markdown file. Narrow: only for a **new directory or repo**, a **colleague**, or forking a side task **mid-phase**. What it buys is portability. The contract seam is the standard case: backend session → frontend session.
- **Subagent**: send a tightly-scoped task to its own window and get a report back.
- **`/compact`** compresses this context and seeds a fresh session with it. The **default**, at the bottom of the tree rather than the first reach.

Read [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) for the ordered tree: the five questions, the reasoning behind each branch, and why the primary-source cost makes **Continue** the one to rule out first. Make the decision **at** a boundary; mid-phase, continue or split the rest into subagents.

## Standalone

Off the main flow entirely.

- **`/grill-me`**: the same relentless interview as `/grill-with-docs`, but **stateless**: it saves nothing and builds no `CONTEXT.md`. Reach for it when you are **not in a repo** (a plan, a design, a piece of writing). In a repo, use `/grill-with-docs`: same interview, plus a paper trail.
- **`/grilling`** is the interview primitive itself: rounds, the frontier, facts are the agent's job and decisions are yours. Reach for it directly only when you want the interview with no wrapper around it.
- **`/resolving-merge-conflicts`** works an in-progress merge or rebase conflict hunk by hunk, resolving by **intent** traced to each side's primary source rather than by picking lines, then finishes the operation. It never runs `--abort`. Reach for it when you are already mid-conflict; `/ship` pulls it in itself when a PR stops being mergeable.
- **`/prototype`** is a small, throwaway program that answers one design question: does this state model feel right, or what should this UI look like. Throwaway is a constraint on how the code is written, not a promise to destroy it: the answer folds into the real code, and the prototype itself is kept on a `prototype/<name>` branch, pointed at from the implementation issue.
- **`/research`**: delegate reading legwork to a **background agent**: it investigates a question against **primary sources**, then leaves a cited Markdown file in the repo. Keep working while it reads. What it produces is something to take *into* `/grill-with-docs`.
- **`/to-questionnaire`** comes in when the thing blocking you isn't in your head or the codebase but in **someone else's**: an accountant, a client, a maintainer. It interviews you about the **send** (who it's going to, what you need back) and writes them a questionnaire. What comes back is material for `/grill-with-docs` or `/to-spec`.
- **`/wizard`** is for the steps only a **human** can take: provisioning infrastructure, credentials, CI secrets, an unfamiliar third-party dashboard, a one-off migration. It generates an interactive bash script so the procedure stops being something you re-explain every time. Model-invoked, so the agent reaches for it when it hits a wall only you can pass.
- **`/wait-what`** is the corrective for a message that didn't land. Use it mid-conversation, inside any other skill, and the agent re-pitches what it just said in plain English using the `CONTEXT.md` vocabulary.
- **`/teach`**: learn a concept over multiple sessions, using the current directory as a stateful workspace. Where the security learning project lives.
- **`/writing-for-agents`** is the reference for writing documents agents consume: skills, CLAUDE.md, pointed-at docs.

## Precondition

**`/setup-kekonius-skills`**: run once per repo before your first engineering flow. It records the PR conventions, triage labels, ADR layout, and backlog file the other skills read from `docs/agents/`.
