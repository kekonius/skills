---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADRs and glossary) as we go.
disable-model-invocation: true
---

Call the Skill tool twice, for "grilling" and "domain-modeling".

When the plan touches authentication, authorization, tenant isolation, money movement, or an audit trail, also call the Skill tool with "threat-model" and run its pass on the affected endpoint or workflow before declaring the frontier empty. A control decided here lands in the spec; one discovered at review time lands as a rewrite.
