# retro-blackness

Roblox integration service: calls the Roblox Open Cloud API and receives inbound webhooks from
Roblox game servers.

Architecture, hard rules, and the git workflow are documented in [CLAUDE.md](CLAUDE.md) — read
that first.

## Quick start

```bash
python -m venv .venv
.venv\Scripts\activate        # Windows
python -m pip install -e ".[dev]"
pre-commit install
cp .env.example .env           # fill in Roblox API key / webhook secret
uvicorn retro_blackness.main:app --reload
```

## Repository setup (one-time, GitHub)

To enforce "always via PR" at the platform level, enable branch protection on `main`:
Settings → Branches → Add rule → `main` → require a pull request before merging, require
status checks to pass (`quality-gates`), and this repo has no direct-push exceptions.
