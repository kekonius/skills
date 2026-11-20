# Tactics

A **tactic** is one design move that controls one attribute's response. Patterns bundle several; infrastructure often provides them, so the work is choosing and judging them as much as building them. Each tree below is a goal, its categories, and the tactics under each, followed by the trade-off it usually costs.

## Performance: meet latency and throughput targets under load

- **Control resource demand**: manage work requests (rate limits, admission control); limit the response to bursts of events; prioritise events; reduce computational overhead; bound execution times; use a better algorithm.
- **Manage resources**: add resources; introduce concurrency; cache computed results; replicate or cache data; bound queue sizes; schedule resources.

Trade-off: caches and replicas buy latency with staleness and memory; concurrency buys throughput with complexity and new races.

## Availability: mask or repair faults so service stays within its target

- **Detect faults**: monitor; ping/echo; heartbeat; timestamp; sanity check; voting; exception detection; self-test.
- **Recover, prepare and repair**: redundant spare (active, passive, cold); rollback; retry; ignore faulty behaviour; graceful degradation; reconfiguration.
- **Recover, reintroduce**: shadow mode; state resynchronisation; escalating restart; non-stop forwarding.
- **Prevent faults**: removal from service; transactions; predictive model; exception prevention.

Trade-off: redundancy costs money and consistency effort; a retry against a receiver that is not idempotent duplicates work (see [MODULE-INTEGRATION.md](MODULE-INTEGRATION.md)).

## Deployability: get a validated change into production within time, cost, and risk bounds

- **Manage the pipeline**: scale rollouts (canary, blue-green, rolling); roll back; script every deployment command.
- **Manage the deployed system**: tolerate version skew between interacting deployables; package dependencies with the deployable; toggle features.

Trade-off: tolerating version skew needs backward- and forward-compatible contracts; every feature toggle is debt until it is removed.

## Modifiability: make change cheap and low-risk

- **Increase cohesion**: split a module; redistribute responsibilities so what changes together lives together.
- **Reduce coupling**: encapsulate behind a deeper interface; use an intermediary; abstract a capability several modules share; restrict dependencies with the architecture rules.
- **Defer binding**: polymorphism; configuration-time binding; discovery; parameters set at build or start time.

Trade-off: every indirection is a seam that must earn two adapters (`codebase-design`); deferred binding moves errors from build time to run time.

## Reviewing an existing system

The trees double as a review instrument. For each tactic under a vital-few attribute, record three answers:

1. **Used?** Yes, no, or partly.
2. **How realised, and how well?** Where it lives in the code or infrastructure, and its quality.
3. **Consequence**: what its presence or absence means for the attribute's scenarios.

A gap that threatens a scenario is a risk: record it beside the scenario it threatens, as _decision → consequence → threatened scenario_.
