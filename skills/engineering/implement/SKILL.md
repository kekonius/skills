---
name: implement
description: "Build one ticket: understand, plan with an ordered task list, stop at the approval gate, then drive tdd slice by slice, record decisions, verify, review, and hand off to ship."
disable-model-invocation: true
argument-hint: "An issue number, or nothing to use the brief already in context"
---

# Implement

Build the work described by one ticket, on the current branch, and hand the finished branch to `ship`. The ticket is the agent brief loaded by `pick-up`, the issue number passed as an argument (fetch it with `gh issue view <n> --comments`), or, with neither, the spec agreed in this conversation.

The domain doc rules are in `docs/agents/domain.md` when the repo has been set up; without them, read `CONTEXT.md` and the ADRs in the area if they exist, and proceed silently if not.

## Process

### 1. Understand before you act

Study the relevant existing code, the patterns already in use, the binding architecture and convention docs `CLAUDE.md` names, and the ADRs in the area. Use the domain vocabulary from `CONTEXT.md`. State, briefly, what you found and how it constrains the work: which module and layers change, which seam the behaviour lands at, which rules bite.

**Done when:** you can name the module, the seam, and the rules, and nothing in the brief is still a guess.

### 2. Plan, with an ordered task list

Produce a short plan plus an **implementation-ordered** checklist: the smallest sensible units, in the order they are built and tested, each one a vertical slice that ends green. Name the **seams** the tests go at (the `tdd` skill requires them pre-agreed). Name any decision that will need an ADR. State the **contract impact**: none, or the endpoints that change. Track the list with your in-session todo list.

### 3. STOP and get approval

Present the plan and the ordered task list, then **wait for the user to review and explicitly approve before writing or modifying any implementation code.** No implementation, not scaffolding, not a quick fix, happens before approval. Questions, analysis, and proposals are always allowed before approval; code changes are not.

**Done when:** the user has said yes to the plan and the seams.

### 4. Build, one slice at a time

Call the Skill tool with "tdd" and work the task list in order: for each slice, a failing test at the agreed seam, the minimum implementation, green. Run the build or typecheck after every slice and the touched test file after every change; the full suite runs once at the end. Commit after each slice in the repo's commit style, one logical change per commit.

Tests ship with the code. Code without a test at the seam is not done, and nobody needs to say so each time.

### 5. Record the why

When a decision made while building meets the ADR bar (hard to reverse, surprising without context, a real trade-off), call the Skill tool with "domain-modeling" and write the ADR now, in the same branch. When a term was sharpened, update `CONTEXT.md` in the same call.

### 6. Verify

Build, then run the full test suite, the architecture tests, and the format check. Everything green.

**Stop if** anything is red: fix it within the loop, or if the fix changes the plan, go back to the user.

### 7. Review

Call the Skill tool with "code-review" against the base branch. Fix every hard finding on the Standards and Architecture axes and every missing or wrong acceptance criterion on the Spec axis; judgement-call smells are yours to accept or decline with a one-line reason. Re-run step 6 after the fixes.

### 8. Hand off

Call the Skill tool with "ship". The ship report says whether the contract impact needs `contract-change` afterwards.

**Done when:** ship reports the PR merged, or has stopped with a reason you have relayed to the user.
