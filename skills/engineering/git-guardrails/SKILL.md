---
name: git-guardrails
description: "Install the Claude Code hook that blocks history- and working-tree-destroying git commands (force push, reset --hard, clean -f, checkout ., restore ., deleting the base branch) while leaving push, merge, and feature-branch cleanup allowed for ship. Run once per machine."
disable-model-invocation: true
---

# Git guardrails

Install a `PreToolUse` hook that intercepts Bash commands and blocks the git operations that destroy work, before they run. Push and PR merge stay allowed: `ship` needs them. What gets blocked is the set of commands whose damage a PR cannot undo.

## What gets blocked

- `git push --force`, `git push -f`, `--force-with-lease`, and the `+refspec` form
- `git push` that deletes the base branch (`--delete master`, `:master`, and the `main` equivalents)
- `git reset --hard`
- `git clean -f`, `git clean -fd`, and every `-f` combination
- `git checkout .` and `git restore .` (discarding the whole working tree)
- `git branch -D master` / `main` (feature branches stay deletable, which `ship` relies on)
- `git stash drop` and `git stash clear`

When blocked, the agent sees a message saying the user has prevented the command.

## Steps

### 1. Ask scope

Ask the user: install for **all projects** (`~/.claude/settings.json`, recommended, once per machine) or **this project only** (`.claude/settings.json`)?

### 2. Copy the hook script

The bundled script is at [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh). Copy it to:

- **Global**: `~/.claude/hooks/block-dangerous-git.sh`
- **Project**: `.claude/hooks/block-dangerous-git.sh`

Make it executable with `chmod +x`.

### 3. Add the hook to settings

**Global** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

**Project** (`.claude/settings.json`): the same block with `"$CLAUDE_PROJECT_DIR"/.claude/hooks/block-dangerous-git.sh` as the command.

If the settings file already exists, merge the hook into the existing `hooks.PreToolUse` array. Don't overwrite other settings.

### 4. Ask about customisation

Ask if the user wants to add or remove patterns. The base branch names are the one thing likely to differ per machine; edit the `PROTECTED_BRANCHES` line in the copied script accordingly.

### 5. Verify

Run three probes against the installed script:

```bash
echo '{"tool_input":{"command":"git push --force origin master"}}' | <path-to-script>; echo "exit $?"
echo '{"tool_input":{"command":"git branch -D feat/123-slug"}}' | <path-to-script>; echo "exit $?"
echo '{"tool_input":{"command":"git push -u origin HEAD"}}' | <path-to-script>; echo "exit $?"
```

The first exits 2 with a BLOCKED message on stderr; the other two exit 0.

**Done when:** all three probes behave as stated and the settings file contains the hook.
