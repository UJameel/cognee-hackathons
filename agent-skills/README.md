# Agent skills

Skills for the participant's **coding agent** (Claude Code, Codex, Cursor, …) —
not the cognee procedural skills some events ingest with
`cognee.remember(..., content_type="skills")`. Each is a self-contained folder
that works at any event.

## cognee-hackathon-feedback

The participant's agent keeps a private record of how cognee behaved for them
during the event — errors, slow steps, confusion, workarounds, and how
frustrating each one was — in `./cognee-feedback.md`, and at wrap-up tells them
where to send it. It records sentiment, never quotes; no keys, `.env`, data, or
names ever go in the file, and the agent never sends or commits it.

### Install — one command, in the starter repo or the participant's own

```bash
curl -fsSL https://raw.githubusercontent.com/topoteretes/cognee-hackathons/main/agent-skills/cognee-hackathon-feedback/install.sh \
  | sh -s -- --event "Redis Hackathon 2026-05-16" --contact "hackathon@cognee.ai"
```

(or, from a checkout of this repo, `agent-skills/cognee-hackathon-feedback/install.sh --event … --contact …`).

That puts the skill in `.claude/skills/` and `.agents/skills/`, appends a
"cognee feedback (hackathon)" section to `AGENTS.md` and `CLAUDE.md` carrying
the event name and the contact, and adds `cognee-feedback.md` to `.gitignore`.
It is idempotent. Nothing else is needed: the `AGENTS.md`/`CLAUDE.md` section
is what makes the agent watch the whole session — a skill on its own only
fires when the agent matches a request — and it is where the skill reads the
event name and destination from, so the skill file itself never changes
per event.

`--contact` is where participants send the file: an email, a Discord channel,
or an upload field on the submission form (recommended — they are already
there). Without it the cognee Discord is used.

### Organizer checklist

- Run the installer in the event's starter template and commit the result, so
  participants who clone it get everything. Put the one-liner in the event
  README for teams bringing their own repo.
- Add one line to the event README: *"Your agent keeps a private record of how
  cognee behaved for you in `cognee-feedback.md` — no quotes, keys, data, or
  names. Send it in with your submission."*
- Dry-run once before the event: break the install on purpose, act confused,
  say "I'm done", and read the file it produces.
- Before the submission deadline, announce: *"run `/cognee-hackathon-feedback`
  now, then send the file"*.
- After the event, drop the collected files in one folder and
  `cognee.remember("./feedback", dataset_name="hackathon-<event>")` — the YAML
  header fields (stage, sentiment, minutes lost, outcome) are then queryable.
