#!/usr/bin/env bash
set -euo pipefail

# Checks the invariants CLAUDE.md states about skills and the files that index
# them. Exit 1 with one line per violation; exit 0 when everything agrees.
#
#   promoted (engineering/, productivity/):
#     - listed in its bucket README, the top-level README, and plugin.json
#     - user-invoked ones are named in the router (ask-kekonius)
#   non-promoted (in-progress/, deprecated/):
#     - listed in its bucket README
#     - absent from the top-level README, plugin.json, and the router
#   every plugin.json entry and README link resolves to a SKILL.md
#   frontmatter name matches the directory name
#   no em-dashes in prose

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

PROMOTED=(engineering productivity)
NON_PROMOTED=(in-progress deprecated)
ROUTER="skills/engineering/ask-kekonius/SKILL.md"
PLUGIN=".claude-plugin/plugin.json"
README="README.md"

fail=0
err() { echo "error: $*" >&2; fail=1; }

frontmatter_has() {
  # $1 = SKILL.md, $2 = regex; looks only between the first two --- lines
  awk 'NR==1 && $0=="---" {infm=1; next} infm && $0=="---" {exit} infm {print}' "$1" | grep -qE "$2"
}

for bucket in "${PROMOTED[@]}" "${NON_PROMOTED[@]}"; do
  [ -f "skills/$bucket/README.md" ] || err "skills/$bucket/README.md is missing"
done

for bucket in "${PROMOTED[@]}"; do
  for skill_md in skills/"$bucket"/*/SKILL.md; do
    [ -e "$skill_md" ] || continue
    dir="$(dirname "$skill_md")"
    name="$(basename "$dir")"

    frontmatter_has "$skill_md" "^name: *\"?$name\"?\$" || err "$skill_md: frontmatter name does not match directory '$name'"
    grep -qF "](./$name/SKILL.md)" "skills/$bucket/README.md" || err "$name: not listed in skills/$bucket/README.md"
    grep -qF "](./$dir/SKILL.md)" "$README" || err "$name: not listed in $README"
    grep -qF "\"./$dir\"" "$PLUGIN" || err "$name: not listed in $PLUGIN"

    if frontmatter_has "$skill_md" "^disable-model-invocation: *true" && [ "$name" != "ask-kekonius" ]; then
      grep -qF "/$name" "$ROUTER" || err "$name: user-invoked but not named in the router $ROUTER"
    fi
  done
done

for bucket in "${NON_PROMOTED[@]}"; do
  for skill_md in skills/"$bucket"/*/SKILL.md; do
    [ -e "$skill_md" ] || continue
    dir="$(dirname "$skill_md")"
    name="$(basename "$dir")"

    frontmatter_has "$skill_md" "^name: *\"?$name\"?\$" || err "$skill_md: frontmatter name does not match directory '$name'"
    grep -qF "](./$name/SKILL.md)" "skills/$bucket/README.md" || err "$name: not listed in skills/$bucket/README.md"
    grep -qF "/$dir/" "$README" && err "$name: is non-promoted ($bucket) but appears in $README"
    grep -qF "\"./$dir\"" "$PLUGIN" && err "$name: is non-promoted ($bucket) but appears in $PLUGIN"
    grep -qE "(^|[^a-z-])/$name([^a-z-]|\$)" "$ROUTER" && err "$name: is non-promoted ($bucket) but the router $ROUTER names it"
  done
done

# Every plugin entry resolves.
while IFS= read -r entry; do
  [ -f "$entry/SKILL.md" ] || err "$PLUGIN entry '$entry' has no SKILL.md"
done < <(grep -oE '"\./skills/[^"]+"' "$PLUGIN" | tr -d '"')

# Every README skill link resolves.
while IFS= read -r link; do
  [ -f "$link" ] || err "$README links to '$link', which does not exist"
done < <(grep -oE '\]\(\./skills/[^)]+/SKILL\.md\)' "$README" | sed -E 's/^\]\(//; s/\)$//' | sort -u)

# No em-dashes in prose. The character is built from its bytes so this file
# never contains one itself.
EM_DASH=$(printf '\xe2\x80\x94')
if grep -rIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=inbox "$EM_DASH" . >/dev/null; then
  grep -rIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=inbox "$EM_DASH" . | head -20 >&2
  err "em-dashes found (see lines above)"
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "consistency check passed"
