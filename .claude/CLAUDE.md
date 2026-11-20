Skills are organized into bucket folders under `skills/`:

- `engineering/`: daily code work
- `productivity/`: daily non-code workflow tools
- `in-progress/`: beta, linked locally for feedback, not shipped in the plugin
- `deprecated/`: no longer used

Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have a reference in the top-level `README.md`, an entry in `.claude-plugin/plugin.json`'s `skills` array (the plugin ships exactly the promoted set), and, when it is user-invoked, an entry in the router `ask-kekonius`. Skills in `in-progress/` and `deprecated/` must appear in none of those.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`. The promoted buckets' `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**; non-promoted bucket `README.md`s use a flat list.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true`, reachable only by the human) or model-invoked (model- or user-reachable). See [.agents/invocation.md](../.agents/invocation.md). Claude Code is the only harness targeted, so there is no `agents/openai.yaml`; `AGENTS.md` is a symlink to this file so any other harness reads the same conventions. This file lives at `.claude/CLAUDE.md` rather than the repo root because the repo root is also the plugin root, and `claude plugin validate --strict` rejects a root `CLAUDE.md` (a plugin never loads it); Claude Code reads `.claude/CLAUDE.md` as project instructions all the same.

[`ask-kekonius`](../skills/engineering/ask-kekonius/SKILL.md) is the router that maps every user-reachable skill and how they relate. Whenever you add, rename, remove, or change how a user-reachable skill fits the flows, re-read its `SKILL.md` and update it so the map stays accurate: a new skill it never mentions, or a stale one it still routes to, is a router that lies.

When writing or editing a skill, call the Skill tool with "writing-for-agents" first.

`.claude-plugin/plugin.json` carries the plugin version. Bump it by hand, in the same commit, whenever a promoted skill's behaviour changes: patch for a fix, minor for a new or removed skill. `.claude-plugin/marketplace.json` makes the repo its own single-plugin marketplace. Run `claude plugin validate . --strict` after touching either manifest.

`scripts/check-consistency.sh` enforces the listing rules above (promoted skills present in the bucket README, top-level README, `plugin.json`, and the router; non-promoted skills absent from all but their bucket README; every link and manifest entry resolving; no em-dashes). Run it before committing; CI (`.github/workflows/check.yml`) runs it and the plugin validation on every push and pull request.

To (re)link every skill outside `deprecated/` into `~/.claude/skills` and `~/.agents/skills`, run `scripts/link-skills.sh`. Each entry is a symlink into this repo, so a `git pull` keeps installed skills current; re-run the script after adding, removing, or renaming a skill.

Skills that touch an issue tracker assume **GitHub Issues** via the `gh` CLI. There is no tracker abstraction; do not add one.

Decisions about this repo's own shape live in `.agents/adr/`. Skill content adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) keeps that credit in `LICENSE`; never re-add the author's name, links, or branding inside a skill.

No em-dashes anywhere in this repo's prose (`SKILL.md` files, `README.md`, ADRs, scripts, JSON). Where a sentence reaches for one, rewrite it with a comma, colon, period, parentheses, or a conjunction, whichever the sentence actually wants; never do a blind character substitution.
