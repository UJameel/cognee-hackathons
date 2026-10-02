# Agent skills

Skills for the participant's **coding agent** (Claude Code, Codex, Cursor, …),
as opposed to the cognee procedural skills some events ingest with
`cognee.remember(..., content_type="skills")`. Each lives in its own folder as
`<name>/SKILL.md` and is event-independent — copy it into the starter
material of any hackathon.

## cognee-hackathon-feedback

Keeps a private record of the participant's experience with cognee during the
event — errors, slow steps, confusion, workarounds, and how frustrating each
one was — in `./cognee-feedback.md`, and tells the participant at wrap-up how
to send it to the cognee team. It records sentiment, never quotes; no keys,
`.env`, data, or names ever go in the file. The agent never sends or commits it.

### Add it to a starter repo

```bash
mkdir -p .claude/skills
cp -r agent-skills/cognee-hackathon-feedback .claude/skills/
echo "cognee-feedback.md" >> .gitignore
```

Agents that read the Agent Skills layout instead of `.claude/skills/` take the
same folder under `.agents/skills/`.

A skill only runs when the agent decides it applies, and "watch the whole
session" is not a request it will match on its own — so also add this standing
instruction to the project's `CLAUDE.md` / `AGENTS.md`, which agents load every
turn:

```markdown
## cognee feedback (hackathon)
This project uses cognee. Whenever cognee errors, is slow, behaves unexpectedly,
or I seem confused or annoyed about it, follow the `cognee-hackathon-feedback`
skill and update ./cognee-feedback.md. When I say I'm done or submitting, run
the skill's wrap-up. Never commit or send that file.
```

Participants can also run the wrap-up explicitly with
`/cognee-hackathon-feedback` — announce that before the submission deadline.

### Before the event

- Fill the two placeholders in the skill's wrap-up message (`<EMAIL>` and the
  Discord `<INVITE>`), or point them at an upload field on the submission form.
- Dry-run it once: break the install on purpose, act confused, say "I'm done",
  and read the file it produces.
- One line in the event README telling participants the file exists, what it
  contains, and that saying "no cognee feedback" deletes it.
