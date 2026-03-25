# Integration Tests

```bash
./run_tests.sh          # full suite
./run_tests.sh date     # dbt_date only
./run_tests.sh utils    # dbt_utils only
```

Requires a local Exasol instance (e.g., `exasol/docker-db` on port 8563). Connection config in `profiles.yml`.

## Approach

Uses upstream test suites directly. Local overrides only where needed:

- **`models/dbt_utils_overrides/`** — 16 models rename `DATA` CTE (Exasol reserved keyword) to `test_data`
- **`macros/get_test_dates.sql`** — patches upstream test data for timezone-naive timestamps and rounded values
- **`+quote_columns: true`** in seeds handles Exasol reserved keyword columns

## Maintenance

When upstream updates:
1. Run tests — most changes flow through automatically
2. Check if new models use `with data as (...)` — add override if so
3. Review `run_tests.sh` excludes if test count changes
