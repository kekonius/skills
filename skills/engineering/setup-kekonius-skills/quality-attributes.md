# Quality attributes

This repo's vital few quality attributes, highest importance first. `quality-attributes` works against them: a plan that weakens one surfaces the trade-off rather than absorbing it. Each is a six-part scenario whose response measure a check can fail on.

## 1. _<Attribute>_ (importance _<High/Medium/Low>_, difficulty _<High/Medium/Low>_)

- **Source**: _<who or what generates the stimulus>_
- **Stimulus**: _<what arrives>_
- **Artifact**: _<the module, service, data store, or pipeline it hits>_
- **Environment**: _<normal load, peak, degraded, mid-deploy>_
- **Response**: _<what the system does>_
- **Response measure**: _<measurable: p99 at most 300 ms, recovery under 10 s, a change in at most two days>_
- **Guarded by**: _<the check that fails when the measure is missed, or "not yet">_

_<Repeat for each of the 3 to 5 attributes.>_
