# CLAUDE.md

Guidance for Claude Code when working with this repository.

## What This Is

A dbt package providing Exasol-specific macro overrides for `dbt_utils` and `dbt_date`. Uses dbt's dispatch mechanism — only override when Exasol SQL differs from the default.

## Public-Facing Guidelines

DO NOT mention Claude or AI in commits, PRs, issues, code comments, or documentation (except this file).

## Critical Rule: No Duplication

**Before adding any macro**, check the upstream default and the dbt-exasol adapter. Only create an `exasol__` override if the default SQL genuinely doesn't work on Exasol. If in doubt, try deleting the override and running tests.

Current overrides (13 total):
- `macros/dbt_date/` (9): date_part, convert_timezone, day_name, month_name, from_unixtimestamp, iso_week_start, iso_year_week, get_base_dates, modules_datetime
- `macros/dbt_utils/` (4): width_bucket, get_intervals_between, get_table_types_sql, get_tables_by_pattern_sql

Key design: `date_part.sql` is comprehensive (handles dayofweek, dayofyear, week, isoweek, quarter, epoch) which lets upstream defaults for `day_of_week`, `day_of_year`, `week_of_year`, `iso_week_of_year`, and `to_unixtimestamp` work without overrides.

## Testing

```bash
integration_tests/run_tests.sh          # full suite (39/39 passing)
integration_tests/run_tests.sh date     # dbt_date only
integration_tests/run_tests.sh utils    # dbt_utils only
```

Requires a local Exasol instance (Docker). Connection config: `integration_tests/profiles.yml`.

**Upstream tests validate our overrides.** The `dbt_date_integration_tests` package provides 36 expression tests. Do NOT remove this dependency from `integration_tests/packages.yml`.

## Known Workarounds

1. **`dbt_date.datetime()` upstream test data** — upstream `get_test_dates.sql` calls `modules.datetime.datetime(...)` directly with `tzinfo`, bypassing dispatch. Our `exasol__get_test_dates()` handles this via `replace("+00:00'", "'")`. Upstream issue: https://github.com/godatadriven/dbt-date/issues/47

2. **dbt_utils column quoting** — upstream tests use `DATA` as CTE name (Exasol reserved keyword). Local overrides in `models/dbt_utils_overrides/` rename to `test_data`. Some upstream schema tests excluded via `--exclude` in run_tests.sh.

3. **`get_test_dates.sql`** — delegates to upstream default, patches `rounded_timestamp` (UTC 14:35 rounds up to next day) and timezone suffix via Jinja `replace`.

## Exasol Constraints

- `TIMESTAMP` is timezone-naive — no `+00:00` suffix
- `date_trunc('isoweek')` not supported — `iso_week_start` needs manual calculation
- `to_char()` pads strings — `day_name` and `month_name` need `trim()`/`initcap()`
- `EXTRACT(QUARTER)` not supported — `date_part` uses `to_char('Q')`

## Coding Style

- SQL: 2-space indent, uppercase keywords, `snake_case` identifiers
- Macros: `exasol__macro_name` in file `macro_name.sql`
- Conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- Update CHANGELOG.md for user-facing changes

## References

- Upstream repos: `~/dbt-date`, `~/dbt-utils`, `~/dbt-exasol`
- Dependency versions: `integration_tests/packages.yml`
- dbt_date dispatch gap tracking: BI-130 (Jira), [#47](https://github.com/godatadriven/dbt-date/issues/47) (GitHub)
