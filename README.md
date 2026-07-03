# retro-blackness

Roblox integration service written in **Luau** and run standalone via the **Lune** runtime.
It calls the Roblox Open Cloud API, receives inbound webhooks from Roblox game servers, and
ships a CI/CD pipeline that publishes in-game Luau to a Roblox experience via Open Cloud.

Architecture, hard rules (≤500 LOC/file, complexity ≤10, TDD, ≥80% coverage, PR-only workflow),
and the publish pipeline are documented in [CLAUDE.md](CLAUDE.md) — read that first.

## Quick start

```bash
rokit install                          # install the pinned Luau toolchain (~/.rokit/bin on PATH)
lune setup                             # generate @lune type definitions for luau-lsp
git config core.hooksPath .githooks    # enable the local pre-commit gate
cp .env.example .env                   # fill in Open Cloud key / webhook secret

lune run src/main.luau                 # start the service (defaults to :8080)
lune run scripts/run_tests.luau        # run the full test suite
```

If you don't have Rokit yet: `Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression`
(Windows) or `curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash` (Linux/macOS), then `rokit self-install`.

## Layout

```
src/domain/          pure Luau: entities, value objects, events, errors
src/application/     use cases (commands/queries) + ports
src/infrastructure/  adapters: Open Cloud client, place publisher, webhook verifier, config
src/interfaces/      net.serve handler, routers, composition root
src/main.luau        process entry point
tests/               unit / integration / e2e specs (+ support harness)
scripts/             test runner + quality-gate scripts
game/                Rojo project for the in-game Luau published to Roblox
```

## Repository setup (one-time, GitHub)

To enforce "always via PR" at the platform level, enable branch protection on `main`:
Settings → Branches → require a pull request before merging and require the `quality-gates`
status check to pass.

For the publish pipeline, add repository secrets: `RB_ROBLOX_OPEN_CLOUD_API_KEY`,
`RB_UNIVERSE_ID`, `RB_PLACE_ID`.
