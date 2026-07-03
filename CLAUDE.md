# retro-blackness — Roblox Integration Service (Luau + Lune)

A standalone backend that integrates with Roblox in both directions, written in **Luau** (the
language Roblox develops and recommends) and run outside the Roblox engine via the **Lune**
runtime:
- **Outbound**: calls the Roblox Open Cloud API (users, place publishing, ...) with `@lune/net`.
- **Inbound**: receives webhook/event calls from running Roblox game servers via a `net.serve`
  HTTP server.

It also ships a **CI/CD pipeline that publishes in-game Luau (`game/`) to a Roblox experience**
via Open Cloud (Rojo build → publish place version).

> Migrated from an earlier Python/FastAPI implementation. The architecture, hard rules, and git
> workflow are unchanged; only the language and tooling differ.

## Toolchain

Managed by **Rokit** (`rokit.toml`), which pins: `lune`, `luau` (bare VM, for coverage),
`stylua`, `selene`, `luau-lsp`, `rojo`. One-time setup per clone:

```bash
rokit install            # install pinned tools into ~/.rokit/bin (on PATH)
lune setup               # generate @lune type definitions for luau-lsp (writes a .luaurc alias)
git config core.hooksPath .githooks   # enable the local pre-commit gate
```

## Architecture: DDD + Clean (Hexagonal) Architecture

Dependency rule: **dependencies only point inward**. Modules require each other with **relative
paths** (`require("../foo")`) — this resolves identically under Lune, the bare `luau` VM, and
luau-lsp (unlike `.luaurc` aliases, which the bare VM does not follow).

```
interfaces  --->  application  --->  domain
infrastructure  ------------------>  (implements ports defined in application)
```

- `src/domain/` — Entities, Value Objects, domain events, domain errors. **Pure Luau**: no
  `@lune/*` requires, no framework code. (This purity is what lets the coverage gate run under
  the bare `luau` VM — see Testing.)
- `src/application/` — Use cases (`commands/`, `queries/`) and **ports** (`roblox/ports.luau`:
  structural function-table types like `RobloxApiClientPort`, `GameEventNotifierPort`,
  `PlacePublisherPort`). Pure Luau. Depends only on `domain/` and its own ports.
- `src/infrastructure/` — Adapters implementing the ports using `@lune/*`: Open Cloud HTTP
  client, place publisher, webhook signature verifier (`@lune/serde` HMAC), settings from
  `@lune/process` env, logging notifier.
- `src/interfaces/` — Delivery: the `net.serve` request handler (`http/app.luau`), the route
  matcher (`http/router.luau`), REST + webhook routers, and the composition root
  (`dependencies.luau`). `src/main.luau` is the process entry point. Routers stay thin — they
  translate HTTP <-> use case calls and hold no business logic.

Each bounded context (e.g. `roblox`) gets its own subfolder inside each layer. Add new contexts
the same way rather than growing an existing one.

## Hard rules (non-negotiable)

1. **Max 500 lines per file.** Enforced by `scripts/check_file_length.luau` (CI + local hook).
2. **Max cyclomatic complexity of 10 per function.** Enforced by `scripts/check_complexity.luau`.
   NOTE: the Luau ecosystem has no mccabe-equivalent linter, so this is a documented **best-effort
   heuristic** (strips line comments, then counts decision keywords per function). Keep functions
   small; if the heuristic ever misfires, fix the code or refine the script — do not silently
   remove the gate.
3. **`domain/` never requires `application/`, `infrastructure/`, or `interfaces/`.**
   `application/` never requires `infrastructure/` or `interfaces/`. `domain/` and `application/`
   stay free of `@lune/*`. Enforced by `scripts/check_architecture_boundaries.luau` (CI + local
   hook) — a static, path-based check of `require(...)` targets, no automated linter can express
   this for Luau.
4. All outbound dependencies (HTTP, storage, queues) go through a port in
   `application/<context>/ports.luau` with a concrete adapter in `infrastructure/`. Never call
   `@lune/net` etc. directly from `application/` or `interfaces/`. **Every infrastructure
   adapter's constructor returns its port type**, never a type of its own (e.g.
   `signatureVerifier.new(secret): ports.SignatureVerifierPort`, not a locally-declared
   `SignatureVerifier` type) — this is what lets `interfaces/`/`application/` code depend on the
   port without ever requiring the concrete adapter module. Not automated (would need
   per-adapter special-casing for the composition root); check for it in review.
5. Business rules and validation live in `domain/` or `application/`, never in routers or adapters.
6. Every module is `--!strict` and passes `luau-lsp analyze --platform=standard`.
7. New behavior needs a test at the right level (see Testing).

## Testing methodology: TDD (mandatory)

- **Write the test first.** Red → green → refactor. No production code without a failing test first.
- **Test runner:** a small in-repo pure-Luau harness (`tests/support/testing.luau` +
  `expect.luau`). We deliberately do **not** use frktest/jest-lua: they can depend on Lune APIs,
  which would prevent the coverage subset from running under the bare `luau` VM. Specs must end
  with `return {}` (bare `luau` requires every required module to return a value).
- **Levels:** pure logic → `tests/unit/domain`; use cases → `tests/unit/application` (fake ports);
  adapters → `tests/integration` (spin a local `net.serve` stub); HTTP endpoints → `tests/e2e`.
- **Minimum 80% coverage, always.** `scripts/check_coverage.luau` runs the pure specs under
  `luau --coverage` and enforces ≥80% line coverage over `src/domain` + `src/application`.
  Coverage is measured only for those pure layers because the bare `luau` VM cannot load `@lune/*`;
  infrastructure/interfaces are exercised for correctness by the Lune suite but excluded from the
  percentage. This is a floor, not a target.
- **Regression before merge.** `scripts/run_tests.luau` (the full unit + integration + e2e suite)
  must pass before any merge. CI runs it on every PR and blocks merging on failure. Never merge a
  red or skipped check; never weaken the coverage gate to force a merge.

## Git workflow (mandatory)

- **Never commit directly to `main`.** All changes go through a feature branch + Pull Request
  (a local hook, `scripts/check_no_main_commit.sh`, blocks direct commits to `main`/`master`).
- Branch naming: `feature/<slug>`, `fix/<slug>`, `chore/<slug>`.
- For any change:
  1. `git checkout main && git pull --ff-only origin main`
  2. `git checkout -b feature/<slug>`
  3. Implement; keep commits scoped.
  4. Run the full local gate (see Commands) — all green before opening a PR.
  5. Push and open a PR against `main`.
- **After a PR is merged, sync local `main`:** `git checkout main && git pull --ff-only origin main`,
  then delete the merged branch.
- Do not force-push to `main`. Do not merge a PR with failing CI.

## Working agreement with Claude

- **Describe new work in [`project_description.md`](project_description.md).** That file is the
  intake point for plain-language, business-facing requests — what you want and why, not
  technical detail. Claude turns it into an implementation plan per the rule below.
- **Plan first, code second.** For anything beyond a trivial one-line fix, present an
  implementation plan (scope, files, approach, trade-offs) and wait for explicit approval before
  writing code. Plain-language descriptions of the desired behavior/bug are sufficient input.
- **Never improvise on missing knowledge.** If something is unclear, ambiguous, or full context is
  missing (this codebase, the Roblox APIs, Lune behavior), ask before proceeding. Ground answers
  and code in verified facts — docs, existing code, test output — not guesses.
- **Refactor continuously.** If something can be expressed more simply while staying clear, do it
  now rather than deferring. Good code health is a baseline expectation of every change.

## Publish pipeline (in-game Luau → Roblox)

- `game/` is a Rojo project (`game/default.project.json`) holding the in-game Luau
  (`game/src/**`). Replace the placeholder script with real game code.
- `.github/workflows/publish-roblox.yml` (trigger: manual `workflow_dispatch` or a published
  release — deliberately not every push) runs `rojo build` then `lune run scripts/publish` to
  publish a place version through Open Cloud (dogfooding the `PublishPlaceUseCase` +
  `place_publisher` adapter).
- Required GitHub Secrets: `RB_ROBLOX_OPEN_CLOUD_API_KEY` (with place-publish scope),
  `RB_UNIVERSE_ID`, `RB_PLACE_ID`.
- The exact Open Cloud publish endpoint should be confirmed against current Roblox docs before
  production use (noted in `place_publisher.luau`).

## Common commands

```bash
lune run scripts/run_tests.luau        # full regression suite (unit + integration + e2e)
lune run scripts/check_coverage.luau   # coverage gate (>= 80% over domain + application)
lune run scripts/check_complexity.luau # complexity gate (<= 10, heuristic)
lune run scripts/check_file_length.luau# file length gate (<= 500)
lune run scripts/check_architecture_boundaries.luau  # inward-only dependency rule (hard rule #3)
stylua --check src tests scripts       # format check   (stylua src tests scripts to fix)
selene src tests scripts               # lint
luau-lsp analyze --platform=standard src tests scripts   # strict type check

lune run src/main.luau                 # run the backend service locally
rojo build game/default.project.json -o build.rbxlx      # build the in-game place file
```
