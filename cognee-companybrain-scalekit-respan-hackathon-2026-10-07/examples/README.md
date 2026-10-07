# Starters

| Path | What it does |
|------|--------------|
| [`scalekit_to_cognee.py`](./scalekit_to_cognee.py) | Steps 1–2 of the loop: authorize a user on Slack + Google Drive through Scalekit, pull a channel's history and a Doc, `remember()` both into a per-user Cognee dataset with `node_set` provenance tags, then `recall()` a cross-source question. |

## Run the pull

```bash
uv pip install "cognee>=1.6.3" scalekit-sdk-python python-dotenv
cp ../.env.example .env   # fill in LLM_API_KEY and the three SCALEKIT_* values
python scalekit_to_cognee.py --user alice@acme.com --channel "#general" --file-id <google_doc_id>
```

Before running, create connections named `slack` and `googledrive` under
**AgentKit → Connections** in the Scalekit dashboard (or pass
`--slack-connection` / `--drive-connection` with your own names). The first
run prints an authorization link per connection; later runs skip it once the
connected account is `ACTIVE`.

Run it twice with two different `--user` values and you have the two
isolated brains the access story needs; the sharing step is in the main
[README](../README.md#5-access--one-scalekit-identifier-one-cognee-user).

Then open the graph:

```bash
cognee-cli -ui   # http://localhost:3000
```
