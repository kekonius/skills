# In Progress

Beta. These skills are linked locally by `scripts/link-skills.sh` so they get used and improved, but they are excluded from the plugin, the top-level README, and the router until they graduate to a promoted bucket. They can change or disappear without warning.

- **[retro](./retro/SKILL.md)**: Suggest improvements to the coding agent's environment (steering files, coding standards, automated checks, tooling) after a session. Design notes only, not functional yet. User-invoked.
- **[claude-handoff](./claude-handoff/SKILL.md)**: Hand the current conversation off to a fresh background agent that picks up the work immediately, seeded with a handoff summary via `claude --bg`. User-invoked.
- **[setup-ts-deep-modules](./setup-ts-deep-modules/SKILL.md)**: Wire dependency-cruiser into a TypeScript repo so each package is a deep module: implementation hidden in subfolders, reachable only through its entry-point files, tests exercising it through those. User-invoked.
- **[quality-attributes](./quality-attributes/SKILL.md)**: Specify a module's or service's vital few quality attributes as measurable six-part scenarios, and pick tactics for them. Model-invoked.
