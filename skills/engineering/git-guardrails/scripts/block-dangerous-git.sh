#!/usr/bin/env bash
# PreToolUse hook for Claude Code: blocks git commands that destroy history or
# the working tree. Push, merge, and feature-branch deletion stay allowed so the
# ship skill can do its job. Exit 2 blocks the command; exit 0 lets it run.

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

# Branches that must never be deleted or force-pushed. Edit to match your repos.
PROTECTED_BRANCHES='(master|main)'

DANGEROUS_PATTERNS=(
  "git[[:space:]]+push[^|;&]*(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+[^[:space:]]+)"
  "git[[:space:]]+push[^|;&]*--delete([[:space:]]+[^[:space:]-]+)?[[:space:]]+${PROTECTED_BRANCHES}([[:space:]]|$)"
  "git[[:space:]]+push[^|;&]*[[:space:]]:${PROTECTED_BRANCHES}([[:space:]]|$)"
  "git[[:space:]]+reset[^|;&]*--hard"
  "git[[:space:]]+clean[^|;&]*[[:space:]]-[a-zA-Z]*f"
  "git[[:space:]]+checkout[[:space:]]+(--[[:space:]]+)?\.([[:space:]]|$)"
  "git[[:space:]]+restore[[:space:]]+(--[[:space:]]+)?\.([[:space:]]|$)"
  "git[[:space:]]+branch[^|;&]*[[:space:]]-D[[:space:]]+${PROTECTED_BRANCHES}([[:space:]]|$)"
  "git[[:space:]]+stash[[:space:]]+(drop|clear)"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches guardrail pattern '$pattern'. The user has prevented you from running this. Explain what you wanted to do and let the user run it." >&2
    exit 2
  fi
done

exit 0
