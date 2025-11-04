# Repository Guidelines

## Project Structure & Module Organization
- Root is a dbt package with Exasol overrides. Macros live in `macros/dbt_utils/` and `macros/dbt_date/`. Root `dbt_project.yml` configures dispatch.
- Integration tests are a dbt project in `integration_tests/` that uses upstream tests via `model-paths`, with minimal local overrides in `integration_tests/models/dbt_utils_overrides/`.
- Support files: `integration_tests/packages.yml`, `integration_tests/profiles.yml`, and `integration_tests/run_tests.sh` (test runner).

## Build, Test, and Development Commands
- Environment (required): `uv venv .venv && source .venv/bin/activate && uv pip install dbt-core dbt-exasol`
- Quick run (from repo root): `integration_tests/run_tests.sh` (or `... date|utils|compile`).
- Manual run:
  - `cd integration_tests && dbt deps`
  - `dbt seed --profiles-dir . --full-refresh`
  - `dbt run  --profiles-dir . --full-refresh`
  - `dbt test --profiles-dir .`

## Coding Style & Naming Conventions
- SQL: 2-space indent, uppercase keywords, `snake_case` identifiers/filenames.
- Macros: Exasol overrides use `exasol__macro_name`; route via `adapter.dispatch`. Prefer `type_*` macros and `limit_zero()` over literals.
- Keep files only when Exasol SQL differs. Do not duplicate upstream implementations.

## Testing Guidelines
- Use upstream tests directly via `model-paths`; keep local overrides minimal (e.g., reserved keywords like `DATA`, quoted seed columns).
- Tests mirror macro structure (1:1 where practical) under `integration_tests/models/`.
- Exasol timestamp behavior: TIMESTAMPs are timezone-naive. Where upstream tests assert timezone-aware values, add a local rewrite under `integration_tests/models/` (see `dbt_date/test_dates.sql`).
- Run `integration_tests/run_tests.sh` or the manual sequence above; ensure all impacted macros have coverage.

## Commit & Pull Request Guidelines
- Conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- Public artifacts (commits/PRs/docs) must not mention AI or Claude.
- PRs: explain problem/solution, link issues, and include passing test evidence. Update README/CHANGELOG when user-facing behavior changes.

## Security & Configuration Tips
- Always use the local profile: `integration_tests/profiles.yml` via `--profiles-dir integration_tests` (or `--profiles-dir .` inside that folder). Do not use `~/.dbt`.
- Never commit credentials; sanitize logs before sharing.
