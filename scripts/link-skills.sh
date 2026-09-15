#!/usr/bin/env bash
set -euo pipefail

# Links every skill in this repo into the local skill directories:
#   - ~/.claude/skills: Claude Code
#   - ~/.agents/skills: any other Agent Skills-compatible harness
# Each entry is a symlink into this repo, so a `git pull` is all that's needed
# to keep installed skills up to date. Re-run after adding, removing, or
# renaming a skill.
#
# `deprecated/` is skipped: a retired skill does not belong in a daily-driver
# skill directory. `in-progress/` IS linked: this local install is exactly where
# a beta skill gets its feedback.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")

names=()
srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  names+=("$(basename "$src")")
  srcs+=("$src")
done < <(find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0)

if [ "${#names[@]}" -eq 0 ]; then
  echo "no skills found under $REPO/skills" >&2
  exit 1
fi

for DEST in "${DESTS[@]}"; do
  # If $DEST is a symlink that resolves into this repo, the per-skill symlinks
  # would land back inside the repo's own skills/ tree. Bail out instead.
  if [ -L "$DEST" ]; then
    resolved="$(readlink -f "$DEST")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $DEST is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$DEST"

  # Remove stale links that point into this repo but whose skill no longer exists.
  for existing in "$DEST"/*; do
    [ -L "$existing" ] || continue
    target="$(readlink -f "$existing" || true)"
    case "$target" in
      "$REPO"/skills/*)
        [ -f "$target/SKILL.md" ] || { rm "$existing"; echo "unlinked $(basename "$existing") ($DEST)"; }
        ;;
    esac
  done

  for i in "${!names[@]}"; do
    name="${names[$i]}"
    src="${srcs[$i]}"
    target="$DEST/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "linked $name -> $src ($DEST)"
  done
done
