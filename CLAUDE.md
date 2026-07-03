# retro-blackness — Roblox Integration Service

Python backend integrating with Roblox in both directions:
- **Outbound**: calls the Roblox Open Cloud API (users, DataStores, Messaging Service, publishing, ...).
- **Inbound**: receives webhook/event calls from running Roblox game servers (Luau `HttpService`).

## Architecture: DDD + Clean (Hexagonal) Architecture

Dependency rule: **dependencies only point inward**. Outer layers depend on inner layers, never the reverse.

```
interfaces  --->  application  --->  domain
infrastructure  ------------------>  (implements ports defined in application/domain)
```

- `src/retro_blackness/domain/` — Entities, Value Objects, domain events, domain exceptions.
  Zero framework dependencies (no FastAPI, no httpx, no pydantic, no ORM). Pure Python.
- `src/retro_blackness/application/` — Use cases (`commands/`, `queries/`) and **ports**
  (abstract interfaces infrastructure must implement, e.g. `RobloxApiClientPort`). Orchestrates
  domain objects. No framework dependencies beyond typing.
- `src/retro_blackness/infrastructure/` — Adapters implementing application ports: the Roblox
  Open Cloud HTTP client, webhook signature verification, settings/config, persistence (when added).
- `src/retro_blackness/interfaces/` — Delivery mechanisms: FastAPI routers for the REST API
  (`interfaces/api/`) and inbound webhooks (`interfaces/webhooks/`), plus the DI composition
  (`interfaces/dependencies.py`). Routers stay thin — they translate HTTP <-> use case calls
  and must not contain business logic.

Each bounded context (e.g. `roblox`) gets its own subfolder inside each layer
(`domain/roblox/`, `application/roblox/`, ...). Add new bounded contexts the same way instead of
growing an existing one indefinitely.

## Hard rules (non-negotiable)

1. **Max 500 lines of code per file.** If a file grows past this, split it (extract a
   collaborator, a new use case, a new adapter). Enforced by `scripts/check_file_length.py`,
   wired into pre-commit and CI.
2. **Max cyclomatic complexity of 10 per function.** Enforced via Ruff's `C90` (mccabe) rule,
   `max-complexity = 10` in `pyproject.toml`. If a function needs to branch more than that,
   extract sub-functions or restructure with polymorphism/strategy objects.
3. **`domain/` never imports from `application/`, `infrastructure/`, or `interfaces/`.**
   `application/` never imports from `infrastructure/` or `interfaces/` — it only depends on
   ports it defines itself.
4. All new outbound dependencies (HTTP calls, queues, storage) go through a port
   (`application/<context>/ports.py`) with a concrete adapter in `infrastructure/`. Never call
   `httpx`/`boto3`/etc. directly from `application/` or `interfaces/`.
5. Business rules and validation live in `domain/` or `application/`, never in `interfaces/`
   routers or `infrastructure/` adapters.
6. Every public function/class has type hints. Run `mypy src` (strict mode) before considering
   work done.
7. New behavior needs a test at the appropriate level: pure logic → `tests/unit/domain`, a use
   case → `tests/unit/application` (with fake ports), an adapter → `tests/integration`, an HTTP
   endpoint → `tests/e2e`.

## Testing methodology: TDD (mandatory)

- **Write the test first.** Red → green → refactor: write a failing test that expresses the
  desired behavior, write the minimal code to make it pass, then refactor with the test as a
  safety net. Do not write production code for which no test failed first.
- **Minimum 80% test coverage, always.** Enforced by `--cov-fail-under=80` in `pyproject.toml`
  (`[tool.pytest.ini_options]` / `[tool.coverage.report]`) — `pytest` fails outright if total
  coverage drops below 80%. This is a floor, not a target: prefer meaningful tests over chasing
  the number.
- **The full test suite (unit + integration + e2e) is the regression suite.** It must be run,
  and pass, before any merge into `main`. CI (`.github/workflows/ci.yml`) runs it on every PR
  and blocks merging on failure — do not merge a PR with a red or skipped check, and do not
  weaken the coverage gate to force a merge through.

## Git workflow (mandatory)

- **Never commit directly to `main`.** All changes go through a feature branch + Pull Request,
  no exceptions (a local pre-commit hook blocks direct commits to `main`/`master`).
- Branch naming: `feature/<slug>`, `fix/<slug>`, `chore/<slug>`.
- Workflow for any change:
  1. `git checkout main && git pull --ff-only origin main`
  2. `git checkout -b feature/<slug>`
  3. Make the change, keep commits scoped and descriptive.
  4. Run `ruff check .`, `ruff format --check .`, `mypy src`, `python scripts/check_file_length.py`,
     `pytest` locally — all must pass before opening a PR.
  5. Push the branch and open a PR against `main` (`gh pr create` if the GitHub CLI is
     available, otherwise via the GitHub web UI).
- **After a PR is merged, always sync local `main`:**
  `git checkout main && git pull --ff-only origin main`, then delete the merged branch
  (`git branch -d <branch>`).
- Do not force-push to `main`. Do not merge a PR with failing CI (lint, complexity, type check,
  or tests).

## Working agreement with Claude

- **Plan first, code second.** For anything beyond a trivial one-line fix, present an
  implementation plan (scope, files touched, approach, trade-offs) and wait for explicit
  approval before writing code. Describing the desired behavior/bug in plain language is enough
  input for this — no special format required.
- **Never improvise on missing knowledge.** If something is unclear, ambiguous, or you lack
  full context (about this codebase, the Roblox APIs involved, or the intended behavior), ask
  before proceeding. Answers and code must be grounded in verified facts (docs, existing code,
  test results) — not guessed.
- **Refactor continuously.** While writing or refactoring, if something can be expressed more
  simply or concisely without losing clarity, do it immediately rather than leaving it for
  later. Keeping the code in good health is a baseline expectation, not an optional cleanup pass.

## Common commands

```bash
python -m pip install -e ".[dev]"   # install runtime + dev dependencies
pre-commit install                  # wire up git hooks (complexity/LOC/main-guard/mypy)

ruff check .                        # lint
ruff format .                       # format
mypy src                            # type check (strict)
ruff check --select C90 src tests   # cyclomatic complexity only
python scripts/check_file_length.py # file length only
pytest                               # full regression suite; coverage gate (80%) runs automatically

uvicorn retro_blackness.main:app --reload   # run the service locally
```
