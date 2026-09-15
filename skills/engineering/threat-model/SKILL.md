---
name: threat-model
description: Facilitate a STRIDE threat model for one endpoint or workflow. Use when the user asks to threat model a feature, when a change touches authentication, authorization, tenant isolation, money movement, or an audit trail, or when grill-with-docs reaches a security-sensitive branch. Guides the user through the analysis rather than producing the model for them.
---

# Threat model

Your role here is facilitator, not author. Ask, prompt, and challenge. The user's own first pass is the point: a model handed over finished teaches nothing and gets rubber-stamped.

## Procedure

1. **Scope it.** Ask which endpoint or workflow. Refuse to model the whole system at once: one flow at a time.

2. **Draw the flow.** List actors, data stores, and trust boundaries for that flow. This part you can do, since it is descriptive, not analytical. In a multi-tenant system the tenancy tree is a trust boundary of its own: name which node scope each actor holds. Confirm the drawing with the user before moving on.

3. **Walk STRIDE, one letter at a time.** For each category, ask the user what they see first. Wait for an answer. Then, and only then, add what they missed.

   - **S**poofing: can an actor claim to be someone else, or another node?
   - **T**ampering: can data change without detection?
   - **R**epudiation: can someone deny an action they took?
   - **I**nformation disclosure: who can read what they should not, including across the tenancy tree?
   - **D**enial of service: what starves or blocks the flow?
   - **E**levation of privilege: how does a low-privilege user, or a user on one node, gain more?

   In a financial or accounting workflow, spend the most time on **T**, **R**, and **E**. That is where fraud lives. In a multi-tenant workflow, **I** and **E** across nodes come next.

4. **Rate and decide.** For each threat: likelihood, impact, and one of mitigate / accept / transfer. Push back on "mitigate" for everything: accepting a risk deliberately and writing down why is a senior move, and the write-up needs at least one.

5. **Turn mitigations into tests.** Every control the user chooses to mitigate with gets a named test that fails when the control is removed. Write the test names down now; `tdd` builds them.

6. **Write it up.** The write-up goes where the repo keeps it: `docs/threat-model.md`, or `docs/security/<flow>.md` when the repo has that directory, or the spec's Implementation Decisions when this ran inside `grill-with-docs`. When the repo's `CLAUDE.md` declares the threat-model file author-owned, hand the user the write-up in the conversation and remind them the file is theirs; do not write it.

**Done when:** every STRIDE letter has been walked, every threat has a rating and a decision, at least one risk is accepted with a reason, and every mitigation names its test.

## Anti-patterns to avoid

- Producing a complete list before the user has tried. This is the main failure mode.
- Generic OWASP items with no connection to this flow's specifics.
- Treating "we use HTTPS" as a mitigation for tampering by an authenticated insider.
- Treating the EF Core query filter as a mitigation for cross-node disclosure without a test that proves the filter is applied on this query path.
