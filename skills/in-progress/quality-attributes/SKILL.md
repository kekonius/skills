---
name: quality-attributes
description: Specify and rank a module's or service's quality attributes as measurable six-part scenarios, and pick tactics for them. Use when a plan sets a latency, availability, deployability, or modifiability target, adds cross-module or cross-service events or messaging, or splits or merges services.
---

# Quality attributes

A **quality attribute** is what a module or service must be beyond what it does: how fast, how available, how cheap to deploy or change. A vague one ("fast", "scalable") cannot be tested, so it erodes. Every attribute this skill touches ends as a **six-part scenario** with a measurable response measure, and only the **vital few** get designed for.

Security is a quality attribute with its own facilitator: call the Skill tool with "threat-model" for it. Language tooling (latency-budget tests, contract-test libraries, load tools) comes from the repo's pack: call the Skill tool with "stack-conventions".

## 1. Read the repo's priorities

When `docs/agents/quality-attributes.md` exists, it holds the repo's ranked scenarios. Work against them: a plan that weakens one is a trade-off to surface to the user, never a detail to absorb.

## 2. Find the vital few

For the module or service in play, list candidate attributes from the plan, the spec, and what the code already promises (a timeout, an SLA, a deploy cadence), including the implicit ones nobody states. Keep **3 to 5**. Each attribute optimised costs complexity and trades against the others; the aim is the least-worst design for these few.

Rank each by business importance and architectural difficulty, each High, Medium, or Low. High/High scenarios drive the design; the rest are recorded and watched.

When the user cannot give the priorities, ask two to four sharp questions, or proceed on stated assumptions that are easy to challenge ("assuming checkout stays under 50 requests per second..."). Every assumption is visible.

## 3. Write each as a six-part scenario

1. **Source**: who or what generates the stimulus (a user, a clock, an upstream service, an operator)
2. **Stimulus**: what arrives (a request, a fault, a change request, a load spike)
3. **Artifact**: what it hits (a module, a service, a data store, the pipeline)
4. **Environment**: the conditions (normal load, peak, degraded, mid-deploy)
5. **Response**: what the system does (serves it, fails over, rolls back)
6. **Response measure**: the measurable bar (p99 at most 200 ms, recovery under 10 s, a change in at most two days)

In one line: _When <source> sends <stimulus> to <artifact> during <environment>, the system <response>, measured by <response measure>._

> When a customer submits checkout to the Orders service at twice the usual peak, the order is accepted, with p99 latency at most 300 ms and no lost orders.

State latency as a percentile tail (p95, p99), never a mean. Sharpen a response measure until a test or a CI check could fail on it.

**Done when:** each vital-few attribute has a scenario whose response measure a check could fail on, ranked by importance and difficulty.

## 4. Pick tactics

For each High/High scenario, pick the tactics that serve it from [TACTICS.md](TACTICS.md) (performance, availability, deployability, modifiability), and name the trade-off each accepts: a tactic that helps one attribute usually costs another. A choice that is hard to reverse becomes an ADR: call the Skill tool with "domain-modeling".

When a scenario crosses modules or services (integration events or messaging, data another module owns, splitting or merging a service), read [MODULE-INTEGRATION.md](MODULE-INTEGRATION.md): granularity, data ownership, outbox and idempotent consumers, sagas, contracts, and replication lag.

## 5. Make each measure checkable

Name the check that guards each response measure (a latency-budget test, a contract test, an availability probe) next to its scenario. It runs with the repo's architecture rules, and `tdd` builds it like any other test. The scenarios and their checks go where the decision is recorded: the spec's Implementation Decisions, or the ADR.
