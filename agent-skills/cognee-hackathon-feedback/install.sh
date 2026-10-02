#!/bin/sh
# Install the cognee-hackathon-feedback skill into the current project.
#
# Local:   agent-skills/cognee-hackathon-feedback/install.sh --event "Redis Hackathon"
# Remote:  curl -fsSL https://raw.githubusercontent.com/topoteretes/cognee-hackathons/main/agent-skills/cognee-hackathon-feedback/install.sh \
#            | sh -s -- --event "Redis Hackathon"
#
# What it does (idempotent — safe to run twice):
#   1. copies SKILL.md to .claude/skills/ and .agents/skills/
#   2. appends a "cognee feedback" block to AGENTS.md and CLAUDE.md (creates them if missing)
#      carrying the event name
#   3. adds cognee-feedback.md to .gitignore
# Where the finished file goes is announced by the organizers at the event.
set -eu

RAW_BASE="https://raw.githubusercontent.com/topoteretes/cognee-hackathons/main/agent-skills/cognee-hackathon-feedback"
NAME="cognee-hackathon-feedback"
EVENT="${COGNEE_HACKATHON_EVENT:-}"

while [ $# -gt 0 ]; do
  case "$1" in
    --event)   EVENT="$2";   shift 2 ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "install.sh: unknown argument: $1" >&2; exit 1 ;;
  esac
done
[ -n "$EVENT" ] || { echo "install.sh: --event is required (e.g. --event \"Redis Hackathon 2026-05-16\")" >&2; exit 1; }

# 1. the skill, for agents that read .claude/skills (Claude Code) and .agents/skills (Agent Skills layout)
here="$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)"
for dir in .claude/skills .agents/skills; do
  mkdir -p "$dir/$NAME"
  if [ -n "$here" ] && [ -f "$here/SKILL.md" ]; then
    cp "$here/SKILL.md" "$dir/$NAME/SKILL.md"
  else
    curl -fsSL "$RAW_BASE/SKILL.md" -o "$dir/$NAME/SKILL.md"
  fi
done

# 2. the standing instruction — a skill only fires when the agent matches a request,
#    so the instruction that makes it watch the whole session lives in the file agents load every turn
block="<!-- $NAME -->
## cognee feedback (hackathon)

This project uses cognee at the \"$EVENT\" hackathon. Follow the
\`$NAME\` skill (\`.claude/skills/$NAME/SKILL.md\`):

- Whenever cognee errors, is slow, behaves unexpectedly, or I seem confused or
  annoyed about it, add an entry to \`./cognee-feedback.md\`.
- When I say I'm done, submitting, or out of time — or run
  \`/$NAME\` — run the skill's wrap-up.
- The organizers announce where the finished file goes.
- Never commit or send that file yourself.
<!-- /$NAME -->"
for f in AGENTS.md CLAUDE.md; do
  if [ -f "$f" ] && grep -q "<!-- $NAME -->" "$f"; then
    continue
  fi
  [ -f "$f" ] && [ -s "$f" ] && printf '\n' >> "$f"
  printf '%s\n' "$block" >> "$f"
done

# 3. keep the feedback file out of the (often public) submission repo
touch .gitignore
grep -qx "cognee-feedback.md" .gitignore || printf 'cognee-feedback.md\n' >> .gitignore

cat <<EOF
$NAME installed for "$EVENT".
  skill:        .claude/skills/$NAME/SKILL.md  (+ .agents/skills/)
  instruction:  AGENTS.md, CLAUDE.md  (section "cognee feedback (hackathon)")
  ignored:      cognee-feedback.md
Participants: your agent now keeps a private record of how cognee behaves for
you in ./cognee-feedback.md — no quotes, keys, data or names. The organizers
will tell you where to hand it in.
EOF
