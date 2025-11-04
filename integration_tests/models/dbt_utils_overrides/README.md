# dbt_utils Test Overrides for Exasol

## Why These Overrides Exist

Exasol has `DATA` as a reserved keyword. Many upstream dbt_utils tests use `with data as (...)` for CTE names, which causes syntax errors:

```sql
-- Upstream (fails on Exasol):
with data as (select 1)
select * from data
-- Error: syntax error, unexpected DATA_

-- Our override (works):
with test_data as (select 1)
select * from test_data
```

## Files in This Directory

All files are **automatically generated** from upstream dbt_utils tests with a simple find-and-replace:
- `with data as` → `with test_data as`
- `from data` → `from test_data`

## Regenerating Overrides

If upstream dbt_utils tests change, regenerate these overrides:

```bash
cd integration_tests
./create_overrides.sh
```

This script:
1. Finds all dbt_utils tests using `data` as a CTE name
2. Copies them to `models/dbt_utils_overrides/`
3. Replaces `data` with `test_data` throughout

## Upstream Contribution

This is a known issue that affects any database with reserved keywords. Consider:
- Opening a PR to dbt_utils to use `test_data` instead of `data`
- Benefits all adapters with strict reserved keyword handling
