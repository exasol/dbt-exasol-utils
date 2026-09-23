# Contributing

## Setup

```bash
git clone https://github.com/exasol/dbt-exasol-utils.git
cd dbt-exasol-utils
uv venv .venv && source .venv/bin/activate
uv pip install dbt-exasol
```

You need a local Exasol instance for testing (e.g., `exasol/docker-db`).

## Adding a macro

1. Only override when Exasol SQL differs from the upstream default
2. File: `macros/dbt_date/macro_name.sql` or `macros/dbt_utils/macro_name.sql`
3. Macro name: `exasol__macro_name`
4. Run tests: `integration_tests/run_tests.sh`
5. Update CHANGELOG.md

## Running tests

```bash
integration_tests/run_tests.sh          # full suite
integration_tests/run_tests.sh date     # dbt_date only
integration_tests/run_tests.sh utils    # dbt_utils only
```

Options (environment variables):

- `EXA_FIRST_DAY_OF_WEEK=1` runs with Monday as first day of week (default 7, Sunday). CI runs both. Macros must not depend on NLS settings
- `EXA_DSN=host:port` points to another Exasol instance (default `localhost:8563`)

After a dbt_utils version change, run `integration_tests/create_overrides.sh` to regenerate the local copies of upstream test models (see `integration_tests/models/dbt_utils_overrides/README.md`).

## Commits

Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`.

## License

Contributions are licensed under the MIT License.
