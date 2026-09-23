# CLAUDE.md

Guidance for Claude Code when working with this repository.

## What This Is

A dbt package providing Exasol-specific macro overrides for `dbt_utils` and `dbt_date`. Uses dbt's dispatch mechanism — only override when Exasol SQL differs from the default.

## Public-Facing Guidelines

DO NOT mention Claude or AI in commits, PRs, issues, code comments, or documentation (except this file).

## Critical Rule: No Duplication

**Before adding any macro**, check the upstream default and the dbt-exasol adapter. Only create an `exasol__` override if the default SQL genuinely doesn't work on Exasol. If in doubt, try deleting the override and running tests.

Current overrides (20 total):
- `macros/dbt_date/` (10): date_part, convert_timezone, day_name, month_name, from_unixtimestamp, iso_week_start, week_start, week_end, get_base_dates, modules_datetime (datetime)
- `macros/dbt_utils/` (10): get_intervals_between, get_table_types_sql, get_tables_by_pattern_sql, get_column_values, union_relations, deduplicate, test_equal_rowcount, test_fewer_rows_than, test_not_empty_string, test_not_null_proportion

Macros must not depend on NLS settings (`NLS_FIRST_DAY_OF_WEEK`, `NLS_DATE_LANGUAGE`, `NLS_DATE_FORMAT`). Never use `to_char(d, 'D')`, `date_trunc('week')` or `to_char` names without `'NLS_DATE_LANGUAGE=ENG'`.

Key design: `date_part.sql` is comprehensive (handles dayofweek, dayofyear, week, isoweek, quarter, epoch) which lets upstream defaults for `day_of_week`, `day_of_year`, `week_of_year`, `iso_week_of_year`, and `to_unixtimestamp` work without overrides.

## Testing

```bash
integration_tests/run_tests.sh          # full suite
integration_tests/run_tests.sh date     # dbt_date only
integration_tests/run_tests.sh utils    # dbt_utils only
EXA_FIRST_DAY_OF_WEEK=1 integration_tests/run_tests.sh   # Monday week start (CI runs 7 and 1)
EXA_DSN=localhost:8564 integration_tests/run_tests.sh    # another Exasol instance
```

Requires a local Exasol instance (Docker). Connection config: `integration_tests/profiles.yml`. CI: `.github/workflows/test.yml`.

**Upstream tests validate our overrides.** The test project runs:
- all upstream dbt_date test models and tests (`dbt_date_integration_tests` package), except `test_dates`, which we replace. Do NOT remove this dependency from `integration_tests/packages.yml`
- all upstream dbt_utils test models and tests except `web/` (needs `split_part`, which dbt-exasol does not support)

Local copies of upstream dbt_utils models live in `integration_tests/models/dbt_utils_overrides/` (see its README). Regenerate with `integration_tests/create_overrides.sh` after a dbt_utils version change. Local copies of upstream tests are `integration_tests/tests/exasol_*.sql`.

## Known Workarounds

1. **`dbt_date.datetime()` upstream test data** — upstream `get_test_dates.sql` calls `modules.datetime.datetime(...)` directly with `tzinfo`, bypassing dispatch. Our `exasol__get_test_dates()` handles this via `replace("+00:00'", "'")`. Upstream issue #47 is closed (macro dispatch added in 0.17.2), but the test data still calls `modules.datetime` directly as of 0.21.0, so the workaround stays.

2. **Seed quoting** — seeds load with unquoted (uppercase) columns, like normal Exasol tables. Only seeds with a reserved word as column name (`OUTPUT`, `VALUE`, `CONDITION`, `MONTH`, `SOURCE`) or mixed case on purpose are quoted; see `seeds:` in `integration_tests/dbt_project.yml`.

3. **`get_test_dates.sql`** — delegates to upstream default, patches `rounded_timestamp` (UTC 14:35 rounds up to next day) and timezone suffix via Jinja `replace`.

4. **`dbname: DB` in `profiles.yml`** — dbt-exasol 1.12.2 lists relations with `database='db'`. An empty `dbname` gives nodes `database=''`, the cache misses every existing table, and a second `--full-refresh` run fails with "object already exists". Keep `dbname` non-empty.

5. **Fresh checkout bootstrap** — `packages.yml` references `dbt_packages/dbt_date/integration_tests`, which exists only after a first `dbt deps`. `run_tests.sh` installs once without that line when the folder is missing.

6. **NLS settings in tests** — `on-run-start` hooks run only on dbt's master connection, not on the connections that build models and run tests. `run_tests.sh` sets NLS defaults with `ALTER SYSTEM` (`integration_tests/macros/set_system_nls.sql`) in a separate `dbt run-operation`, so every later connection gets them.

## Exasol Constraints

- `TIMESTAMP` is timezone-naive — no `+00:00` suffix
- `date_trunc('isoweek')` not supported — `iso_week_start` needs manual calculation
- `to_char()` pads strings — `day_name` and `month_name` need `trim()`/`initcap()`
- `to_char(d, 'D')`, `date_trunc('week')` and `last_day(d, 'week')` follow `NLS_FIRST_DAY_OF_WEEK` — day of week is computed from a known Sunday instead
- `''` is NULL — `col = ''` never matches, `not like ''` filters every row
- Reserved words often used as names upstream: `DATA`, `SOURCE`, `VALUE`, `OUTPUT`, `FINAL`, `ERRORS`, `INPUT`; identifiers cannot start with `_` unless quoted
- `GROUP BY` cannot use the alias of a constant
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
