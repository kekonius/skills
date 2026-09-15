---
name: improve-codebase-architecture
description: Survey a codebase for deepening opportunities against its architecture rules and docs, present the candidates, then grill through whichever one you pick.
disable-model-invocation: true
argument-hint: "A module, subsystem, or pain point, or nothing to infer from the commit history"
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability. This is a survey that finds candidates, not a rescue: it hands you the list and grills the one you pick.

This command is _informed_ by the project's domain model, its binding rules, and a shared design vocabulary:

- Call the Skill tool with "codebase-design" for the architecture vocabulary (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**) and its principles (the deletion test, "the interface is the test surface", "one adapter = hypothetical seam, two = real"). Use these terms exactly in every suggestion, and don't drift into "component," "service," "API," or "boundary."
- The domain language in `CONTEXT.md` gives names to good seams; the ADRs (directory per `docs/agents/domain.md`, default `docs/decisions/`) record decisions this command should not re-litigate.
- The **architecture rules** the repo enforces with tests (NetArchTest, dependency-cruiser) and documents in its architecture and convention docs fix some seams in advance. A candidate that moves one of those seams is an ADR-sized proposal, marked as such, never a quiet refactor.

## Process

### 1. Explore

**Scope before you scan: YAGNI.** Deepening a module pays off by making future changes to it easier, so put extra weight on the parts of the codebase that have recently changed. Decide *where* to look before you look:

- If the user named a direction (a module, a subsystem, a pain point), take it, and skip the inference below.
- Otherwise, walk back a good stretch of the commit history (`git log --oneline --stat`) to find the codebase's hot spots, the files and areas that keep coming up, and let those paths pull your attention first. If the changes are scattered with no clear hot spot, widen the net.

Read `CONTEXT.md`, the architecture and convention docs `CLAUDE.md` names, and the ADRs in the area first. Run the architecture tests once so you know the rules bite and where the suite already has coverage.

Then spawn a sub-agent to walk the codebase. Don't follow rigid heuristics; explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow**, with an interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams, or reach through a `.Contracts` project or package entry point with a type that carries more than the contract should?
- Which parts of the codebase are untested, or hard to test through their current interface, or tested with a container where the rule lives in memory?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

**Done when:** you have three to seven candidates, each tied to a hot spot or the user's direction, and none of them merely restates a rule the architecture tests already enforce.

### 2. Present candidates

Present the candidates in the conversation as a numbered list, strongest first. For each:

- **Modules**: which modules and layers are involved, in `CONTEXT.md` and `codebase-design` vocabulary
- **Problem**: why the current shape causes friction, with the deletion-test verdict
- **Solution**: plain English description of what would change: what becomes the interface, what moves behind the seam
- **Benefits**: in terms of locality and leverage, and which tests would be replaced by tests at the new interface
- **Dependencies**: the category each dependency falls into (see `codebase-design`'s deepening reference), which decides how the deepened module is tested
- **Recommendation strength**: `Strong`, `Worth exploring`, or `Speculative`
- **Rules touched**: none, or the architecture rule or ADR the candidate would move, marked as needing an ADR

End with a **Top recommendation**: which candidate you'd tackle first and why.

**Use `CONTEXT.md` vocabulary for the domain, and the `codebase-design` vocabulary for the architecture.** If `CONTEXT.md` defines "Journal entry," talk about "the posting module," not "the `PostEntryConsumer`," and not "the posting service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Say so plainly: _"contradicts ADR-0007, but worth reopening because…"_. Don't list every theoretical refactor an ADR forbids.

Do NOT propose interfaces yet. After the list, ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, call the Skill tool with "grilling" to walk the decision tree with them: constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Side effects happen inline as decisions crystallize; call the Skill tool with "domain-modeling" to keep the domain model current as you go:

- **Naming a deepened module after a concept not in `CONTEXT.md`?** Add the term to `CONTEXT.md`. Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `CONTEXT.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing; skip ephemeral reasons ("not worth it right now") and self-evident ones.
- **Want to explore alternative interfaces for the deepened module?** Call the Skill tool with "codebase-design" and use its design-it-twice parallel sub-agent pattern.

When the tree is resolved, the candidate is an idea with a shape. Tell the user the next step is `/grill-with-docs` or straight to `/to-spec`, depending on whether anything is still open. Nothing is refactored here.
