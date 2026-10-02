#!/bin/sh
# Install the cognee-hackathon-feedback skill into the current project.
#
# Local:   agent-skills/cognee-hackathon-feedback/install.sh --event "Redis Hackathon"
# Remote:  curl -fsSL https://raw.githubusercontent.com/topoteretes/cognee-hackathons/main/agent-skills/cognee-hackathon-feedback/install.sh \
#            | sh -s -- --event "Redis Hackathon"
#
# What it does (idempotent — safe to run twice):
#   1. copies SKILL.md and hook.sh to .claude/skills/ and .agents/skills/
#   2. appends a "cognee feedback" block to AGENTS.md and CLAUDE.md (creates them if missing)
#      carrying the event name
#   3. registers hook.sh on the `Stop` event in .claude/settings.json (Claude Code) and
#      .codex/hooks.json (Codex) — project files only, merged into any existing ones
#   4. adds cognee-feedback.md and .cognee-feedback.state to .gitignore
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
  for f in SKILL.md hook.sh; do
    if [ -n "$here" ] && [ -f "$here/$f" ]; then
      cp "$here/$f" "$dir/$NAME/$f"
    else
      curl -fsSL "$RAW_BASE/$f" -o "$dir/$NAME/$f"
    fi
  done
  chmod +x "$dir/$NAME/hook.sh"
done

# 2. the standing instruction — a skill only fires when the agent matches a request,
#    so the instruction that makes it watch the whole session lives in the file agents load every turn
block="<!-- $NAME -->
## cognee feedback (hackathon)

This project uses cognee at the \"$EVENT\" hackathon. Follow the
\`$NAME\` skill (\`.claude/skills/$NAME/SKILL.md\`):

- Whenever cognee errors, is slow, behaves unexpectedly, or I seem confused or
  annoyed about it, add an entry to \`./cognee-feedback.md\`.
- About every 10 minutes a hook ends your turn with a \"cognee-feedback
  checkpoint\" message: update the file as it says, briefly, then stop.
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

# 3. the checkpoint hook — same handler for both agents, on the end-of-turn event.
#    Project-scoped files only; merged into existing ones, never ~/.claude or ~/.codex.
hook_claude="sh \"\${CLAUDE_PROJECT_DIR:-.}/.agents/skills/$NAME/hook.sh\""
hook_codex="sh .agents/skills/$NAME/hook.sh"
mkdir -p .claude .codex
python3 - "$NAME" ".claude/settings.json" "$hook_claude" ".codex/hooks.json" "$hook_codex" <<'EOF'
import json, pathlib, sys
name, *pairs = sys.argv[1:]
for path, command in zip(pairs[::2], pairs[1::2]):
    p = pathlib.Path(path)
    data = json.loads(p.read_text()) if p.exists() and p.read_text().strip() else {}
    groups = data.setdefault("hooks", {}).setdefault("Stop", [])
    if any(f"{name}/hook.sh" in h.get("command", "") for g in groups for h in g.get("hooks", [])):
        continue
    groups.append({"hooks": [{"type": "command", "command": command, "timeout": 10,
                              "statusMessage": "cognee feedback checkpoint"}]})
    p.write_text(json.dumps(data, indent=2) + "\n")
EOF

# 4. keep the feedback file and the hook's clock out of the (often public) submission repo
touch .gitignore
for f in cognee-feedback.md .cognee-feedback.state; do
  grep -qx "$f" .gitignore || printf '%s\n' "$f" >> .gitignore
done

cat <<EOF
$NAME installed for "$EVENT".
  skill:        .claude/skills/$NAME/SKILL.md  (+ .agents/skills/)
  instruction:  AGENTS.md, CLAUDE.md  (section "cognee feedback (hackathon)")
  checkpoint:   .claude/settings.json + .codex/hooks.json → Stop → hook.sh, every ~10 min
  ignored:      cognee-feedback.md, .cognee-feedback.state
Participants: your agent now keeps a private record of how cognee behaves for
you in ./cognee-feedback.md — no quotes, keys, data or names. The organizers
will tell you where to hand it in. (Codex asks you to trust this project once;
say yes so the checkpoint runs.)
EOF
