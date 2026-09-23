# dbt-exasol-utils

Exasol adapter support for [`dbt_utils`](https://github.com/dbt-labs/dbt-utils) and [`dbt_date`](https://github.com/godatadriven/dbt-date) packages.

All macros behave identically to their upstream counterparts — refer to the original package documentation for usage details.

> **Community project** — not officially supported by Exasol.

## Installation

### 1. Add to `packages.yml`

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.4.0", "<1.5.0"]
  - package: godatadriven/dbt_date
    version: [">=0.21.0", "<0.22.0"]
  - git: https://github.com/exasol/dbt-exasol-utils.git
    revision: v0.3.0
```

### 2. Configure dispatch in `dbt_project.yml`

```yaml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['your_project_name', 'dbt_exasol_utils', 'dbt_utils']
  - macro_namespace: dbt_date
    search_order: ['your_project_name', 'dbt_exasol_utils', 'dbt_date']
```

### 3. Keep the default NLS date format

The macros in this package do not depend on Exasol NLS settings (`NLS_FIRST_DAY_OF_WEEK`, `NLS_DATE_LANGUAGE`, `NLS_DATE_FORMAT`, `NLS_TIMESTAMP_FORMAT`). This is tested.

Two things outside this package do depend on `NLS_DATE_FORMAT`: `dbt seed` with date columns, and ISO date strings in your own SQL (for example `cast('2024-01-31' as date)`). Keep the Exasol default `YYYY-MM-DD`. If your database uses another format, change the system default with `ALTER SYSTEM`. Do not use `on-run-start` hooks with `alter session`: dbt runs these hooks on one connection only, not on the connections that build models and run tests.

### 4. Install

```bash
dbt deps
```

## Exasol-specific notes

- **Timezone** — Exasol `TIMESTAMP` is timezone-naive. `convert_timezone()` passes through unchanged; all operations assume UTC.
- **Week start** — `week_start()` is Sunday and `iso_week_start()` is Monday, as in dbt_date on other databases, whatever `NLS_FIRST_DAY_OF_WEEK` is.
- **Names** — `day_name()` and `month_name()` return trimmed, capitalized English names, whatever `NLS_DATE_LANGUAGE` is.
- **`union_relations()`** — the source column is created quoted, because Exasol identifiers cannot start with an underscore. Query it as `"_dbt_source_relation"`.
- **Not supported** — `get_url_host()`, `get_url_path()` and `get_url_parameter()` need `split_part()`, which dbt-exasol does not support.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Run tests with `integration_tests/run_tests.sh`.

## License

MIT — see [LICENSE](LICENSE).
