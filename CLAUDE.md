# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Start

**🧪 Testing (Most Common Task):**
- **Script:** `integration_tests/run_tests.sh` (from repo root), or run inside `integration_tests/` as `./run_tests.sh` — supports `date|utils|compile`
- **Detailed guide:** [integration_tests/README.md](integration_tests/README.md) - Testing guide with minimal duplication approach

**📋 Development Guidelines:**
- See sections below for code patterns, anti-duplication rules, and architecture

## Project Overview

This is a dbt package that provides Exasol-specific implementations for `dbt_utils` and `dbt_date` macros. The package uses dbt's dispatch mechanism to override generic implementations with optimized Exasol SQL.

**Key point**: This is NOT a standalone application. It's a library package meant to be installed by other dbt projects.

## ⚠️ Public-Facing Guidelines

**DO NOT mention Claude or AI assistance in public-facing content:**
- ❌ Commit messages
- ❌ Pull request descriptions
- ❌ Issue comments
- ❌ Code comments
- ❌ Documentation (except CLAUDE.md)

**It's fine to have:**
- ✅ CLAUDE.md (development guidelines file)
- ✅ Claude-specific configuration files
- ✅ Internal development notes

**Reason:** The project should appear as human-authored professional work. While Claude assists with development, the public face of the project should reflect the maintainer's ownership and expertise.

## Primary Goal

**The goal of this project is to make sure that the `dbt-date` package and `dbt-utils` package fully work with Exasol by providing Exasol-specific macro overrides.**

When adding or modifying macros:
1. **Always check `~/dbt-date` and `~/dbt-utils` repositories** to verify what macros exist and their signatures
2. **Reference `~/dbt-exasol`** for Exasol adapter-specific implementations and patterns
3. Ensure all overrides follow the correct macro signatures from upstream packages
4. Test that macros work correctly with Exasol SQL syntax

## ⚠️ CRITICAL: Prevent Code Duplication

**NEVER duplicate code from upstream packages.** This project had 1,700+ lines of unnecessary duplicates that were removed.

### Integration Tests - Use Upstream Directly

**CRITICAL RULE:** Minimize local test files. Use upstream tests through `model-paths` configuration.

**DO:**
- ✅ Add upstream test paths to `dbt_project.yml` model-paths
- ✅ Add upstream seed paths to `dbt_project.yml` seed-paths
- ✅ Let dispatch mechanism route to our Exasol overrides automatically
- ✅ Only create local files when absolutely necessary (e.g., unsupported features)

**DON'T:**
- ❌ Copy test SQL files from upstream locally
- ❌ Copy seed CSV files from upstream locally
- ❌ Duplicate test YAML files from upstream
- ❌ Create custom tests when upstream tests exist

**Example of correct approach:**
```yaml
# integration_tests/dbt_project.yml
model-paths:
  - "models"  # Only local overrides if absolutely needed
  - "dbt_packages/dbt_date/integration_tests/models"  # Use upstream directly!
  - "dbt_packages/dbt_utils/integration_tests/models/sql"  # Use upstream directly!
```

**Why this matters:** Our goal is 100% upstream test usage. Tests validate that our Exasol macro overrides work correctly with the same test cases other adapters use.

### How Dispatch Works

When dbt encounters `{{ dbt_date.some_macro(...) }}`:
1. First looks for `exasol__some_macro` in this project ✓
2. If not found, looks for `default__some_macro` in upstream dbt-date ✓
3. Uses whichever is found first

**This means:** You only need `exasol__` overrides when Exasol SQL syntax differs from the default!

### Before Adding Any Macro File

**MANDATORY checks before creating/modifying a macro:**

```bash
# 1. Does this file exist in upstream?
ls ~/dbt-date/macros/**/*macro_name.sql
ls ~/dbt-utils/macros/**/*macro_name.sql

# 2. If it exists, compare with upstream
diff ~/dbt-date/macros/path/macro_name.sql macros/dbt_date/macro_name.sql

# 3. If identical or has no exasol__ macro, DELETE IT
# The dispatch mechanism will use upstream automatically
```

### When to Add Exasol Overrides

**ONLY create/keep a macro file if:**

✅ **Exasol SQL syntax differs** from default implementation:
- Need `trim()` because Exasol's `to_char()` pads strings
- Need `initcap()` for capitalization
- Need different date/time functions
- Need Exasol-specific system tables

❌ **DO NOT create a file if:**
- It's a pure wrapper/convenience function (e.g., `yesterday`, `tomorrow`)
- Logic works the same across all databases (e.g., `day_of_month`)
- It's a helper/utility macro with no database-specific code
- It just calls other macros without Exasol-specific SQL

### File Structure

**Only keep `exasol__` overrides, never duplicate base implementations:**

```sql
-- ✅ CORRECT: Only the Exasol override
{%- macro exasol__day_name(date, short, language) -%}
    {# Exasol needs trim() for padded strings #}
    {%- if language == "default" -%}
        {%- set f = "Dy" if short else "Day" -%}
        trim(to_char({{ date }}, '{{ f }}'))
    {%- else -%}
        {{ dbt_date.day_name_localized(date, short, language) }}
    {%- endif -%}
{%- endmacro -%}

-- ❌ WRONG: Don't include the dispatch wrapper or other adapter overrides
{%- macro day_name(date, short=True, language="default") -%}
    {{ adapter.dispatch("day_name", "dbt_date")(date, short, language) }}
{%- endmacro -%}
{%- macro default__day_name(...) -%} ... {%- endmacro -%}
{%- macro snowflake__day_name(...) -%} ... {%- endmacro -%}
{%- macro exasol__day_name(...) -%} ... {%- endmacro -%}
```

### Regular Audit

Periodically check for duplicates:

```bash
cd /Users/mikhail.zhadanov/dbt-exasol-utils

# Check each macro against upstream
for file in macros/dbt_date/*.sql; do
    basename=$(basename "$file")
    upstream_file=$(find ~/dbt-date/macros -name "$basename" -type f)
    if [ -n "$upstream_file" ]; then
        if diff -q "$file" "$upstream_file" > /dev/null 2>&1; then
            echo "⚠️  DUPLICATE: $basename - DELETE THIS FILE"
        fi
    fi
done
```

### Why This Matters

- **Maintenance burden**: Duplicates must be manually updated when upstream changes
- **Sync issues**: Easy to miss upstream bug fixes or improvements
- **Bloat**: Adds unnecessary code to review and test
- **Confusion**: Unclear which version is authoritative

**Rule of thumb:** If you can't explain why Exasol needs different SQL, don't override it.

## Test Status

**All integration tests passing: 38/38 (100%)**
- ✅ dbt_date: 36/36 tests passing
- ✅ dbt_utils: 2/2 tests passing (haversine_distance_km, haversine_distance_mi)

**Key Implementation Notes:**
1. **Upstream packages must remain clean** - ~/dbt-date and ~/dbt-utils should have NO Exasol code
2. **All Exasol overrides belong in this project** in macros/dbt_date/ and macros/dbt_utils/
3. **Exasol timezone constraints** - Exasol TIMESTAMP type doesn't support timezone info:
   - Test data uses same timestamp values for time_stamp and time_stamp_utc when timezone is UTC
   - datetime macro tests use strftime() directly to strip timezone info
   - rounded_timestamp values adjusted to account for UTC-only timestamps

## Testing Strategy

**Borrow integration tests from upstream repositories instead of creating custom tests.**

The `~/dbt-date` and `~/dbt-utils` repositories contain proven integration tests. Use those:

```bash
# Check what integration tests exist upstream
ls ~/dbt-date/integration_tests/models/
ls ~/dbt-utils/integration_tests/models/

# Copy and adapt relevant tests to integration_tests/models/
```

**Benefits:**
- Ensures compatibility with exact same test cases as other adapters
- Avoids reinventing test logic
- Tests are already proven to work correctly
- Easier to maintain alignment with upstream changes

**Only create custom tests when:**
- Testing Exasol-specific optimizations (e.g., native WIDTH_BUCKET vs generic implementation)
- Upstream tests don't exist for a specific macro
- Need to test Exasol-specific edge cases

### Integration Test Strategy: Minimize Duplication

**✅ Current approach:** Use upstream models directly with minimal local overrides

```yaml
# integration_tests/dbt_project.yml
model-paths:
  - "models"  # Contains local overrides in models/dbt_utils_overrides/
  - "dbt_packages/dbt_date/integration_tests/models"  # ✅ Use upstream models
  - "dbt_packages/dbt_utils/integration_tests/models/datetime"  # ✅ Use upstream
  # NOTE: generic_tests/, geo/, sql/ excluded - have local overrides for 'data' keyword
```

**How we minimize duplication:**

1. **Use upstream model SQL files directly** - No local copies except where required
2. **Local overrides only for incompatibilities** - Currently 16 tests need `data` → `test_data` rename
3. **Reserved keyword workaround** - Exasol treats `DATA` as reserved, but upstream uses `with data as`
   - Script: `integration_tests/create_overrides.sh` auto-generates fixes
   - Location: `integration_tests/models/dbt_utils_overrides/`
   - Change: Simple find-replace `data` → `test_data` in CTE names
3. **Use exasol__ macro overrides** - Customize test data via macros/get_test_dates.sql

**Local test file overrides (only 1 file!):**
- `models/dbt_date/test_dates.yml` - Modified line 112 to use strftime() for timezone-naive datetime:
  ```yaml
  # Upstream: expression: "datetime_datetime = cast('{{ dbt_date.datetime(...) }}' as {{ dbt.type_timestamp() }})"
  # Ours:     expression: "datetime_datetime = cast('{{ modules.datetime.datetime(...).strftime(\"%Y-%m-%d %H:%M:%S\") }}' as {{ dbt.type_timestamp() }})"
  ```

  **Why this override is needed:** Exasol's TIMESTAMP type doesn't support timezone information. The upstream test uses `dbt_date.datetime()` which includes timezone (e.g., '1997-09-29 06:14:00+00:00'), but Exasol rejects this format. Our override uses strftime() to strip timezone.

**Exasol-specific test macros:**
- `macros/get_test_dates.sql` - Contains `exasol__get_test_dates()` and `exasol__get_test_timestamps()` overrides:
  - Timezone handling: both time_stamp and time_stamp_utc use same UTC value (Exasol timestamps are timezone-naive)
  - Datetime formatting: uses strftime() to strip timezone from datetime values
  - Rounded timestamp values: adjusted to '2021-06-08' for UTC-only timestamps

**Benefits of this approach:**
- ✅ Only 1 file to maintain (test_dates.yml) instead of 7+ files
- ✅ Automatic updates when upstream adds new models or tests
- ✅ Clear separation: SQL models from upstream, YAML tests override only when needed
- ✅ Macro overrides follow standard dispatch pattern

**Maintenance:** When upstream dbt_date changes, only review test_dates.yml if test structure changes.

## Development Workflow - IMPORTANT

**ALWAYS commit changes to git before making modifications.** This makes it easy to restore if something goes wrong.

```bash
# Before making any changes
git add .
git commit -m "Descriptive message of current state"

# Then proceed with modifications
```

This practice is especially important when:
- Modifying existing macros
- Running tests that might reveal issues
- Making structural changes to the project

## Local Database Configuration

**IMPORTANT: Use local profiles.yml - DO NOT rely on ~/.dbt/profiles.yml**

The integration tests use a local `integration_tests/profiles.yml` that connects to a local Exasol instance:

```yaml
exasol:
  target: prod
  outputs:
    prod:
      type: exasol
      dsn: localhost/nocertcheck:8563
      user: sys
      password: exasol
      dbname: ''
      schema: dbt_test
      timestamp_format: "YYYY-MM-DD HH:MI:SS.FF6"
      threads: 4
```

**Key settings:**
- `dsn: localhost/nocertcheck:8563` - Always use local Exasol for testing (nocertcheck disables SSL cert validation)
- `timestamp_format: "YYYY-MM-DD HH:MI:SS.FF6"` - **Required** for timestamp compatibility with dbt-date tests
- Local profiles.yml ensures consistent test environment and avoids using user-specific ~/.dbt/profiles.yml

**To run tests:**
```bash
cd integration_tests
source ../.venv/bin/activate
dbt seed   # Load test data
dbt run    # Run all models
dbt test   # Run all tests
```

## Architecture

### Macro Dispatch Pattern

All macros follow dbt's adapter dispatch pattern:

```sql
{% macro exasol__macro_name(args) %}
    -- Exasol-specific implementation using native functions
{% endmacro %}
```

The dispatch mechanism (configured in consuming projects' `dbt_project.yml`) ensures Exasol-specific macros are used instead of generic ones.

### Package Structure

```
macros/
├── dbt_utils/          # 5 Exasol overrides for dbt_utils macros
│   ├── width_bucket.sql               # Uses native WIDTH_BUCKET() function
│   ├── haversine_distance.sql         # Geographic distance with trig functions
│   ├── get_tables_by_pattern_sql.sql  # Queries SYS.EXA_ALL_OBJECTS
│   ├── get_table_types_sql.sql        # Returns table/view types
│   └── get_intervals_between.sql      # Adds 'week' support via DATE_TRUNC
└── dbt_date/           # 41+ Exasol overrides for dbt_date macros
    ├── date_part.sql              # Quarter support using TO_CHAR
    ├── get_base_dates.sql         # Date spine generation
    ├── get_date_dimension.sql     # Full date dimension table
    └── [37+ calendar helpers]
```

### Exasol-Specific Patterns

1. **Native Function Usage**: Prefer Exasol's built-in functions (e.g., `WIDTH_BUCKET()`) over complex CASE statements for performance
2. **System Tables**: Use `SYS.EXA_ALL_OBJECTS` for metadata queries
3. **Date Functions**:
   - Use `TO_CHAR(date, 'Q')` for quarter extraction (Exasol doesn't support `EXTRACT(QUARTER ...)`)
   - Use `DATE_TRUNC('week', ...)` for week-based date operations
4. **Type Casting**: Use `{{ dbt.type_int() }}` for cross-adapter type compatibility

## Development Commands

### Testing Environment Setup

**IMPORTANT**: Always use uv venv for testing to ensure consistent environment:

```bash
# 1. Create venv (first time only)
cd /Users/mikhail.zhadanov/dbt-exasol-utils
uv venv .venv

# 2. Install dbt-exasol from local development version
source .venv/bin/activate
uv pip install -e ~/dbt-exasol

# 3. Verify installation
dbt --version
dbt debug  # Should show Exasol connection configured
```

## Testing

All testing happens in the `integration_tests/` directory:

**Before running tests:**
```bash
# Activate venv
source .venv/bin/activate

# Install package dependencies (first time only)
cd integration_tests
dbt deps
```

**Running tests:**

```bash
# Setup (one-time)
cd integration_tests
dbt deps

# Run all tests
dbt run

# Run specific test
dbt run --select test_width_bucket

# Run multiple specific tests
dbt run --select test_width_bucket test_haversine_distance test_date_spine

# View compiled SQL (to verify native Exasol functions are used)
dbt compile
cat target/compiled/dbt_exasol_utils_integration_tests/models/test_width_bucket.sql
```

### Prerequisites for Testing

- Exasol database instance (local or remote)
- dbt-exasol adapter installed
- Connection configured in `~/.dbt/profiles.yml` with profile name `exasol`

### Verifying Dispatch Works

Check compiled SQL to ensure Exasol-specific implementation is used:

**Good** (Exasol-specific):
```sql
width_bucket(val, 0, 100, 10)
```

**Bad** (generic fallback):
```sql
CASE WHEN mod(cast(val as numeric(28,6)), ...) = 0 THEN 1 ELSE 0 END + ...
```

If you see the "bad" version, the dispatch configuration is not working.

## Adding New Macros

1. **Create macro file** in `macros/dbt_utils/` or `macros/dbt_date/`
   - File name: `macro_name.sql` (NOT `exasol__macro_name.sql`)
   - Macro name inside: `{% macro exasol__macro_name(...) %}`

2. **Create integration test** in `integration_tests/models/dbt_utils/` or `integration_tests/models/dbt_date/`
   - Test file name MUST match macro name exactly: `macro_name.sql` (same as macro file name)
   - Test structure MUST follow this pattern for SQL-level validation:

   ```sql
   {{ config(materialized='table') }}

   -- Test: macro_name() description of what it does
   -- Pattern: Query succeeds only if macro_result = expected_value
   SELECT
       macro_result,
       expected_value
   FROM (
       SELECT
           {{ dbt_utils.macro_name(...) }} as macro_result,
           expected_value as expected_value
   )
   WHERE macro_result = expected_value
   ```

   **Why this pattern?**
   - Test passes/fails at SQL execution level (not by reading results back)
   - If macro returns wrong value, WHERE clause filters all rows → empty table → test effectively fails
   - If macro is correct, table is created with expected data → test passes
   - Exasol validates correctness, not Python code

3. **Run test**:
   ```bash
   cd integration_tests
   dbt run --select dbt_utils.macro_name  # or dbt_date.macro_name
   ```

4. **Update documentation in README.md**:
   - Add macro to "Supported Macros" list with link: `**[\`macro_name\`](#macro_name)**`
   - Add usage example section with anchor: `##### <a name="macro_name"></a>\`macro_name\``
   - Include:
     - Brief description
     - At least 1-2 code examples showing typical usage
     - Comments indicating expected output format where helpful
   - Follow the existing pattern in README.md for consistency

5. **Update other docs**:
   - CHANGELOG.md - Add entry for the new macro
   - integration_tests/README.md - Update test coverage if needed

## Test Structure - Mirrored Organization

Tests mirror the macro directory structure exactly for easy navigation:

```
macros/                              integration_tests/models/
├── dbt_utils/                       ├── dbt_utils/
│   ├── width_bucket.sql       →     │   ├── width_bucket.sql
│   ├── haversine_distance.sql →     │   ├── haversine_distance.sql
│   └── ...                          │   └── ...
└── dbt_date/                        └── dbt_date/
    ├── date_part.sql          →         ├── date_part.sql
    ├── day_name.sql           →         ├── day_name.sql
    └── ...                              └── ...
```

**Benefits:**
- One test file per macro (1:1 mapping)
- Same file names make it obvious which test covers which macro
- Easy to find and update tests when modifying macros
- Clear test coverage at a glance

## Important Notes

- **Macro naming**: Files use `macro_name.sql`, but macros inside use `exasol__macro_name`
- **Test naming**: Test files match macro file names exactly (e.g., `width_bucket.sql` tests `width_bucket.sql`)
- **Test location**: Tests live in `integration_tests/models/{package}/` subdirectories
- **Dispatch search order**: Must be configured in consuming projects as `['project_name', 'dbt_exasol_utils', 'dbt_utils']`
- **Dependencies**: Requires `dbt-labs/dbt_utils` and `godatadriven/dbt_date` (versions specified in integration_tests/packages.yml)
- **dbt version**: Requires dbt >= 1.0.0, < 2.0.0
- **Not for production commits**: This is an open-source community project, not officially supported by Exasol

## Profile Configuration

Integration tests expect a profile named `exasol` in `~/.dbt/profiles.yml`:

```yaml
exasol:
  target: dev
  outputs:
    dev:
      type: exasol
      dsn: hostname:8563
      user: username
      password: password
      dbname: schema_name
      schema: schema_name
```

## Code Quality Standards

This is a production-ready open-source package. Maintain professional standards:

### Documentation
- **Keep docs current**: Update README.md, CHANGELOG.md, and CONTRIBUTING.md with any changes
- **No internal notes**: Delete temporary files like SUMMARY.md, TODO.md, or development notes before committing
- **Professional tone**: All documentation should be clear, concise, and helpful for users

### Code Quality
- **Test coverage**: Every macro must have a corresponding integration test in `integration_tests/models/`
- **Verify dispatch**: Always check compiled SQL to ensure Exasol-specific implementations are used (not generic fallbacks)
- **Performance**: Prefer Exasol native functions over complex SQL workarounds
- **Error handling**: Handle edge cases (NULL values, empty strings, boundary conditions)

### Commit Practices
- **Conventional commits**: Use `feat:`, `fix:`, `docs:`, `test:`, `refactor:` prefixes
- **No secrets**: Never commit credentials, API keys, or connection strings
- **Clean history**: Squash WIP commits before merging to main
- **Update CHANGELOG**: Add entry for user-facing changes

### File Organization
- **No clutter**: Keep only essential files in root (README, CHANGELOG, CONTRIBUTING, LICENSE, CLAUDE.md)
- **Organized macros**: All macros in `macros/dbt_utils/` or `macros/dbt_date/` subdirectories
- **Test organization**: Integration tests in `integration_tests/models/` with descriptive names

### Before Each Commit
- [ ] All tests pass: `cd integration_tests && dbt run`
- [ ] Documentation updated (if applicable)
- [ ] CHANGELOG.md updated (for user-facing changes)
- [ ] No temporary/internal files added
- [ ] Compiled SQL verified for at least one affected macro
