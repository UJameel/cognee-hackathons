# Build a Company Brain — AI Agents with Memory, Context and Secure Access

📍 **San Francisco · 2026-10-07 · 2:00 PM – 7:30 PM PT · part of #SFTechWeek**

🧠 **Cognee × Scalekit × Respan** 🚀

Most companies have their knowledge scattered across documents, Slack
conversations, code, tickets, CRM systems and other business apps. The
challenge is not simply giving an AI agent *access* to those tools — it is
giving the agent a **persistent understanding of the company**, while making
sure every user only sees and acts on what they are authorized to.

In this hackathon you build a **Company Brain** out of three layers:

| Layer | Tool | What it does |
|-------|------|--------------|
| **Access** | [Scalekit](https://docs.scalekit.com/agentkit/overview/) | Pulls data from each user's Google Drive, Slack, Gmail, GitHub, Notion, … through managed OAuth. Your code never touches a token. |
| **Memory** | [Cognee](https://github.com/topoteretes/cognee) | Turns what Scalekit pulls into one knowledge graph the agent can `remember` into and `recall` from, per user, per dataset. |
| **Evals** | [Respan](https://www.respan.ai/) | Traces your agents' runs and scores them with evaluators, so you can show the brain actually does the job — before and after a change. |

The goal: build something that makes us think
*"this is what it would look like if a company had a brain."*

## What You Build

A Company Brain for a team workflow, wired end to end:

1. **Pull with Scalekit** — connect **at least two** systems of record
   (Drive + Slack, GitHub + Notion, Gmail + HubSpot, …) through Scalekit
   AgentKit connectors. Each user authorizes once; your agent pulls on their
   behalf using their `identifier`.
2. **Remember with Cognee** — send what you pulled into Cognee with
   `cognee.remember(...)`, tagged by source and scoped to the user who is
   allowed to see it. Cognee extracts entities and relationships into one
   graph across sources, so "the doc, the thread and the PR about the launch"
   become one connected thing.
3. **Wire agents for tasks** — build the agent(s) that use the brain to
   **retrieve knowledge, coordinate work, or take action**: a pre-meeting
   brief, an expert finder, a ticket triager, an onboarding guide, a "who
   decided this and why" assistant. Agents `recall` from Cognee and, when
   they need to act, write back through Scalekit (post to Slack, draft an
   email, open an issue).
4. **Evaluate with Respan** — trace the agent runs and score them against a
   scenario set with Respan evaluators. Change the brain or the agent, re-run,
   and show the **before/after** scores.

Move beyond single-app demos. Projects should reflect how teams actually
work: across documents, collaboration tools, engineering systems and business
apps, with more than one person and more than one permission level.

## Architecture — Pull → Remember → Act → Evaluate

```text
   Google Drive   Slack   Gmail   GitHub   Notion   HubSpot   ...
        │          │        │        │        │        │
        └──────────┴────────┴───┬────┴────────┴────────┘
                                │  OAuth per user, tokens stored + refreshed
                                ▼
                  ┌───────────────────────────────┐
                  │  Scalekit AgentKit             │   ACCESS
                  │  execute_tool(identifier=...)  │   who may read / act on what
                  └──────────────┬────────────────┘
                                 │  documents, threads, issues, emails
                                 ▼
                  ┌───────────────────────────────┐
                  │  Cognee                        │   MEMORY
                  │  remember(data, node_set=[…],  │   one graph across sources,
                  │           dataset_name=…,      │   one dataset per user / team,
                  │           user=…)              │   permissions enforced on recall
                  │  recall(question, user=…)      │
                  └──────────────┬────────────────┘
                                 │  grounded context
                                 ▼
                  ┌───────────────────────────────┐
                  │  Your agent(s)                 │   TASKS
                  │  brief · triage · find-expert  │   act via Scalekit:
                  │  …traced + scored by Respan    │   post, draft, open issue
                  └──────────────┬────────────────┘
                                 ▼
                           [ your team ]
```

Three things judges look for in that diagram:

- **Access shapes the experience.** The same question asked by two users with
  different Scalekit connections / Cognee permissions should get different
  answers — and the demo should show it.
- **Memory is cross-source.** A good answer stitches a Drive doc, a Slack
  thread and a GitHub issue together. A single-connector brain is a RAG demo.
- **Evaluation is part of the build.** A scenario set scored in Respan, run
  before and after a change, beats a hand-picked screenshot.

## Prizes

Prizes are announced at kickoff. Expect an afternoon of building, feedback,
demos and prizes from the partners.

## Demo Format

You will have **3 minutes** to stand out:

- Present your Company Brain idea and the team workflow it solves.
- Run a live demo: pull → remember → agent task → eval scores.
- Show the access story: what changes when a different user asks.

## Schedule

All times **Pacific Time (PT)**. Final timings are confirmed at kickoff.

| Time | What |
|------|------|
| 2:00 PM | Doors open + networking |
| 2:30 PM | Opening remarks + partner walkthroughs |
| 3:00 PM | Hacking begins |
| 6:00 PM | Project submission deadline — finalists selected |
| 6:15 PM | Finalist demos & judging |
| 7:00 PM | Awards |
| 7:30 PM | Event wrap-up & doors close |

## Setup

> **Bring a laptop and a GitHub account.** We hand out an LLM API key
> (OpenAI) at kickoff. Scalekit has a free tier that is enough for the event;
> creating that account ahead of time saves you ten minutes, but is not
> required.

### Prerequisites

- Python 3.10 – 3.14
- `uv` (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- A Scalekit account — free tier is enough: <https://app.scalekit.com>
- An LLM API key — **provided by us at kickoff** (or bring your own from any
  [supported provider](https://docs.cognee.ai/setup-configuration/llm-providers))

### 1. Install

```bash
uv venv && source .venv/bin/activate
uv pip install "cognee>=1.6.3" scalekit-sdk-python python-dotenv
```

### 2. Configure the LLM

```bash
export LLM_API_KEY="<key-we-give-you-at-the-event>"
```

Or copy [`.env.example`](./.env.example) to `.env` and fill it in. Cognee
reads `.env` from the working directory. Prefer another provider? Set
`LLM_PROVIDER` / `LLM_MODEL` per the
[provider docs](https://docs.cognee.ai/setup-configuration/llm-providers).

### 3. Scalekit — connect the data sources

Scalekit AgentKit gives your agent per-user, OAuth-managed connections to
400+ apps and prebuilt tools on each (`gmail_fetch_mails`,
`slack_fetch_conversation_history`, `googledrive_export_file`, …). You pass a
stable `identifier` for the user; Scalekit adds their token, calls the API and
returns JSON.

1. In the Scalekit dashboard, copy **Developers → API Credentials** into your
   `.env`:
   ```text
   SCALEKIT_ENVIRONMENT_URL=https://<env>.scalekit.dev
   SCALEKIT_CLIENT_ID=skc_...
   SCALEKIT_CLIENT_SECRET=...
   ```
2. Under **AgentKit → Connections**, create one connection per source you
   want (e.g. `slack`, `googledrive`, `gmail`). The name you give a connection
   is the `connection_name` your code passes. Some connectors (Slack, for
   one) can use Scalekit's own OAuth app; Google Drive needs your own Google
   OAuth client. Each connector page says which and walks you through it.
3. Authorize each **user** once per connection, then pull:

```python
import os
from scalekit import ScalekitClient

sk = ScalekitClient(
    env_url=os.environ["SCALEKIT_ENVIRONMENT_URL"],
    client_id=os.environ["SCALEKIT_CLIENT_ID"],
    client_secret=os.environ["SCALEKIT_CLIENT_SECRET"],
)
actions = sk.actions

identifier = "alice@acme.com"   # stable, hard-to-guess id for THIS user

# One-time consent per user per connection (no-op once the account is ACTIVE)
account = actions.get_or_create_connected_account(connection_name="slack", identifier=identifier)
if account.connected_account.status != "ACTIVE":
    link = actions.get_authorization_link(connection_name="slack", identifier=identifier)
    print("Authorize Slack:", link.link)
    input("Press Enter after authorizing...")

# Every call afterwards: Scalekit adds the user's token for you
history = actions.execute_tool(
    tool_name="slack_fetch_conversation_history",
    tool_input={"channel": "#launch", "limit": 200},
    connection_name="slack",
    identifier=identifier,
)
messages = history.data["messages"]
```

Useful read tools to start from:

| Source | Tool | Returns |
|--------|------|---------|
| Slack | `slack_fetch_conversation_history` | messages in one channel/DM, paginated by `cursor` |
| Slack | `slack_search_messages` | text search across the workspace |
| Google Drive | `googledrive_search_files` / `googledrive_list_folder_contents` | file ids + metadata |
| Google Drive | `googledrive_export_file` | a Doc/Sheet/Slide exported to a MIME type (`text/plain`, `text/csv`) |
| Gmail | `gmail_fetch_mails` | messages matching a Gmail `query` |

Every connector page lists its tools and their inputs:
[Slack](https://docs.scalekit.com/agentkit/connectors/slack) ·
[Google Drive](https://docs.scalekit.com/agentkit/connectors/googledrive/) ·
[all connectors](https://docs.scalekit.com/agentkit/connectors/).
`actions.list_tools(connection_name="slack")` returns the same schemas from
code — handy for handing them straight to an LLM as tool definitions.
Building with a coding agent? `npx @scalekit-inc/cli setup` installs
Scalekit's skills into Claude Code / Cursor / Codex.

### 4. Cognee — remember what you pulled

Cognee's memory API is four calls: `remember`, `recall`, `improve`, `forget`.
Turn each pulled item into text and `remember` it, tagging the source with
`node_set` so the graph keeps provenance and the demo can show *where* an
answer came from:

```python
import asyncio
import cognee


async def main():
    # 1. Remember — runs add + cognify (+ improve) and builds the graph.
    #    One document per channel keeps the conversation context together.
    transcript = "\n".join(
        f"[slack #launch · {m['user']} · {m['ts']}] {m['text']}" for m in reversed(messages)
    )
    await cognee.remember(
        transcript,
        dataset_name="acme-brain",
        node_set=["source:slack", "channel:launch"],
    )

    doc = actions.execute_tool(
        tool_name="googledrive_export_file",
        tool_input={"file_id": "<file_id>", "mime_type": "text/plain"},
        connection_name="googledrive",
        identifier=identifier,
    )
    await cognee.remember(
        str(doc.data),                 # exported Doc text — inspect .data for the exact shape
        dataset_name="acme-brain",
        node_set=["source:googledrive", "doc:launch-plan"],
    )

    # 2. Recall — auto-routes to the best search strategy
    results = await cognee.recall(
        "What did we decide about the launch date, and who owns the announcement?",
        datasets=["acme-brain"],
    )
    for r in results:
        print(r.source, "→", r.text)

    # 3. Session memory for the agent's scratchpad (fast tier, bridged to the graph)
    await cognee.remember("Alice asked about the launch date", session_id="alice-chat-1")
    await cognee.recall("what did Alice ask?", session_id="alice-chat-1")


asyncio.run(main())
```

Other things worth knowing:

- `remember()` accepts text, file paths and URLs; a folder or a GitHub repo URL
  becomes a code graph (`content_type="code"` for repos pulled from GitHub).
- `recall()` picks a search strategy for you. Pin one with
  `query_type=SearchType.GRAPH_COMPLETION` (graph-heavy questions),
  `SearchType.CHUNKS` (raw passages, no LLM) or `SearchType.TEMPORAL`
  ("what happened in September?").
- `cognee-cli -ui` starts the local server + graph explorer at
  <http://localhost:3000>. Open it during the demo — the graph is the pitch.
- `improve(dataset="acme-brain")` runs the enrichment stages; `forget(...)`
  removes a document, a dataset, or everything.
- Prefer a managed instance? `await cognee.serve(url=..., api_key=...)` points
  every call at Cognee Cloud. Ask at the Cognee table for a key.

A complete starter — authorize, pull Slack + Drive, remember per user, recall
across both — is [`examples/scalekit_to_cognee.py`](./examples/scalekit_to_cognee.py).

### 5. Access — one Scalekit identifier, one Cognee user

The brief asks you to *"show how secure user-level access and authorization
shape the experience."* Scalekit gives you the first half (what a user may
pull); Cognee gives you the second (what a user may recall). Line them up: the
Scalekit `identifier` **is** the Cognee user's email.

```python
import os
os.environ["ENABLE_BACKEND_ACCESS_CONTROL"] = "true"   # set BEFORE the first cognee call

import cognee
from cognee.modules.users.methods import create_user, get_user_by_email
from cognee.modules.data.methods import get_authorized_existing_datasets
from cognee.modules.users.permissions.methods import authorized_give_permission_on_datasets


async def get_or_create_user(email: str):
    return await get_user_by_email(email) or await create_user(email, "hackathon-pw")


alice = await get_or_create_user("alice@acme.com")
bob = await get_or_create_user("bob@acme.com")

# Each user's pulls land in a dataset only they can read
await cognee.remember(alice_slack_text, dataset_name="alice-brain", user=alice)
await cognee.remember(bob_drive_text, dataset_name="bob-brain", user=bob)

# Bob's readable set is only his own brain — Alice's is invisible to him.
# (Passing datasets=["alice-brain"] with user=bob raises DatasetNotFoundError:
#  names resolve only among datasets the user owns.)
readable = await get_authorized_existing_datasets(None, "read", bob)
print([d.name for d in readable])                                   # -> ['bob-brain']

# ... until Alice shares it
(ds,) = await get_authorized_existing_datasets(["alice-brain"], "share", alice)
await authorized_give_permission_on_datasets(bob.id, [ds.id], "read", alice.id)

# Shared datasets are reached by id, not by name
readable = await get_authorized_existing_datasets(None, "read", bob)
print([d.name for d in readable])                                   # -> ['bob-brain', 'alice-brain']
print(await cognee.recall("launch date?", dataset_ids=[d.id for d in readable], user=bob))
```

With access control on, every user+dataset gets its own isolated graph and
vector store (default Ladybug + LanceDB). A full worked example — two users,
isolation, then a grant — is in the previous hackathon's
[`multiuser.py`](../cognee-gtm-brain-hackathon-2026-06-26/src/gtm_brain/multiuser.py).

### 6. Respan — trace and evaluate the agents

Respan traces every LLM call, tool run and retrieval in an agent run as one
span tree, and scores runs with evaluators (LLM judge, deterministic Python
check, or human review) over a testset. Instrument with the `respan-ai`
Python SDK (`Respan()` once at startup, a decorator on the function that
handles a request), build a testset from your scenario questions, and run the
same evaluator before and after you change the brain.

The Respan team walks through setup and hands out access at kickoff. Docs:
[tracing](https://www.respan.ai/ai-tracing) ·
[evals](https://www.respan.ai/ai-evals) ·
[SDK on GitHub](https://github.com/respanai/respan).

## Judging

Full rubric in [`challenge/COMPANY_BRAIN.md`](./challenge/COMPANY_BRAIN.md).
In short (100 points):

```text
30 - Company Brain quality      cross-source answers, real team workflow, actions taken
20 - Secure access story        Scalekit per-user connections ↔ Cognee per-user memory, demonstrated
20 - Evaluation                 scenario set, independent scorer, traced runs, before/after
15 - Memory design              what goes in the graph, how it's tagged, how it improves
10 - Reproducibility            we can run it from the README with our own keys
 5 - Demo                       3 minutes, live, shows all three layers
```

## Submission

Each team submits:

- a short writeup of the Company Brain and the team workflow it solves
- the implementation: Scalekit pull, Cognee ingestion, the agent(s), the eval
- the eval results: scenario set, before/after scores, link to the traces
- the access story: which users, which connections, what each can see
- a 3-minute demo

Use [`templates/SUBMISSION.md`](./templates/SUBMISSION.md) — copy it into your
team repo (or the PR description) and fill it in. Submit by opening a PR to
this repo that adds `submissions/<team-name>/SUBMISSION.md` under this folder,
or hand the link to an organizer before the deadline.

## Ideas to Build

- **Pre-meeting brief** — for each calendar event in the next 24 h, pull the
  attendees' recent Slack threads, shared Drive docs and open GitHub issues,
  remember them, and have the agent write the brief and post it to the
  owner's DM. Eval: does the brief mention the open decision from the last
  thread?
- **Who knows about X** — an expert finder over Slack + GitHub + Drive
  authorship. Eval: top-1 person for 10 held-out questions.
- **Decision archaeology** — "why did we pick Postgres?" answered from the RFC
  doc, the thread where it was argued, and the PR that did it, with citations.
  Eval: every answer cites at least two sources.
- **Onboarding buddy** — a new hire's brain only sees what their role is
  granted; the agent explains the team's systems from that view and files
  "I couldn't find X" gaps as Notion/Linear tasks.
- **Support triage** — Gmail + HubSpot + GitHub: route an incoming customer
  email to the right owner with the account's history attached. Eval: correct
  owner, correct linked issue.

## Resources

- Scalekit: [AgentKit overview](https://docs.scalekit.com/agentkit/overview/) ·
  [Python SDK](https://docs.scalekit.com/agentkit/sdks/python/) ·
  [connectors](https://docs.scalekit.com/agentkit/connectors/) ·
  [meeting-prep agent walkthrough](https://www.scalekit.com/blog/meeting-prep-ai-agent-development)
- Cognee: [docs](https://docs.cognee.ai/) ·
  [repo](https://github.com/topoteretes/cognee) ·
  [company brain cookbooks](https://github.com/topoteretes/cognee/tree/main/examples/cookbooks/company_brain) ·
  [Discord](https://discord.gg/NQPKmU5CCg)
- Respan: [tracing](https://www.respan.ai/ai-tracing) ·
  [evals](https://www.respan.ai/ai-evals) ·
  [SDK](https://github.com/respanai/respan)
- Previous company-brain hackathons in this repo:
  [`cognee-companybrain-hackathon-2026-06-16`](../cognee-companybrain-hackathon-2026-06-16),
  [`cognee-cloud-hackathon-2026-06-19`](../cognee-cloud-hackathon-2026-06-19),
  [`cognee-gtm-brain-hackathon-2026-06-26`](../cognee-gtm-brain-hackathon-2026-06-26)
- Event page: [Partiful](https://partiful.com/e/0x6c9gSKGDZi9mYMESyl)
- Capture friction for the Cognee team as you go:
  [`agent-skills/cognee-hackathon-feedback`](../agent-skills/cognee-hackathon-feedback)
