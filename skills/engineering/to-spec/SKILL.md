---
name: to-spec
description: "Turn the current conversation into a spec and publish it as a GitHub issue: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec. Do NOT interview the user; just synthesize what you already know.

The PR conventions and label vocabulary should have been provided to you in `docs/agents/`. If not, tell the user to run `/setup-kekonius-skills`.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect the ADRs and binding architecture docs in the area you're touching. A spec that contradicts one names the contradiction in Implementation Decisions and points at the ADR that will supersede it.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better: the ideal number is one.

   Check with the user that these seams match their expectations.

3. Write the spec using the template below, then publish it with `gh issue create`, applying `enhancement` (or `bug`) and the area labels that fit. Apply no triage role: a spec is the parent, and the tickets `to-tickets` cuts from it are what become `ready-for-agent`. If the user says this is a single-session build with no tickets, apply `ready-for-agent` to the spec itself instead.

   Report the issue number and URL.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As an accountant on a client node, I want to post a journal entry that balances in SEK, so that the ledger stays correct under Bokföringslagen
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified, and which layers of each
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions, and the ADRs that record them
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.

## Contract Impact

Whether this spec changes the HTTP surface a frontend consumes through a generated client. Either "none" or the list of endpoints added, changed, or removed. When it is not "none", the tickets that touch those endpoints ship with `contract-change` rather than `ship`.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested, and at which seams
- Prior art for the tests (i.e. similar types of tests in the codebase)
- Which architecture rules the change must keep green

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
