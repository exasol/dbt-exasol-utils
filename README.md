# dbt-exasol-utils

Exasol adapter support for [`dbt_utils`](https://github.com/dbt-labs/dbt-utils) and [`dbt_date`](https://github.com/godatadriven/dbt-date) packages.

All macros behave identically to their upstream counterparts — refer to the original package documentation for usage details.

> **Community project** — not officially supported by Exasol.

## Installation

### 1. Add to `packages.yml`

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.3.0", "<1.4.0"]
  - package: godatadriven/dbt_date
    version: [">=0.17.0", "<0.18.0"]
  - git: https://github.com/exasol/dbt-exasol-utils.git
    revision: v0.2.0
```

### 2. Configure dispatch in `dbt_project.yml`

```yaml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['your_project_name', 'dbt_exasol_utils', 'dbt_utils']
  - macro_namespace: dbt_date
    search_order: ['your_project_name', 'dbt_exasol_utils', 'dbt_date']
```

### 3. Set NLS session formats

Exasol uses session defaults to parse dates and timestamps. Add these to your `dbt_project.yml` to avoid implicit conversion errors:

```yaml
on-run-start:
  - "alter session set NLS_DATE_FORMAT = 'YYYY-MM-DD'"
  - "alter session set NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF6'"
  - "alter session set NLS_DATE_LANGUAGE = 'ENG'"
  - "alter session set NLS_FIRST_DAY_OF_WEEK = 'MONDAY'"
```

### 4. Install

```bash
dbt deps
```

## Exasol-specific notes

- **Timezone** — Exasol `TIMESTAMP` is timezone-naive. `convert_timezone()` passes through unchanged; all operations assume UTC.
- **String padding** — `day_name()` and `month_name()` are automatically trimmed and capitalized.
- **Native functions** — Uses `WIDTH_BUCKET()`, `WEEK()`, `DATE_TRUNC()`, `POSIX_TIME()` where available for better performance.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Run tests with `integration_tests/run_tests.sh`.

## License

MIT — see [LICENSE](LICENSE).
