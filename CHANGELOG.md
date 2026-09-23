# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-09-23

### Breaking

- `week_start()` and `week_end()` are now always Sunday to Saturday, as in dbt_date on other databases. Before, on a database with `NLS_FIRST_DAY_OF_WEEK = 1`, they returned Monday to Sunday. With the Exasol default (7, Sunday) the values do not change. For Monday-based weeks, use `iso_week_start()` and `iso_week_end()`
- `union_relations()` with the default `source_column_name` now creates the column quoted and lowercase: `"_dbt_source_relation"`. Before, this call failed on Exasol. Calls that pass their own quoted name, for example `source_column_name='"_DBT_SOURCE_RELATION"'`, do not change
- Minimum dbt version is now 1.10.5 (required by dbt_date 0.21)

### Added

- `exasol__get_column_values`: the upstream result alias `value` is a reserved word in Exasol, so `get_column_values()` failed with a syntax error
- `exasol__union_relations`: the source column `_dbt_source_relation` is now quoted. Exasol identifiers cannot start with an underscore, so `union_relations()` failed with default arguments. Query the column as `"_dbt_source_relation"`
- `exasol__deduplicate`: uses `QUALIFY`. The upstream aliases `_inner` and `data` are not valid on Exasol
- `exasol__test_equal_rowcount` and `exasol__test_fewer_rows_than`: the upstream CTE `final` is a reserved word, and Exasol cannot group by the alias of a constant
- `exasol__test_not_empty_string`: Exasol stores `''` as NULL, so the upstream test never found whitespace-only values. The CTE `errors` was also a reserved word
- `exasol__test_not_null_proportion`: the proportion is rounded to a fixed decimal. On Exasol it was a DOUBLE, so an exact 0.9 failed `at_least: 0.9`
- `exasol__week_start` and `exasol__week_end`: always Sunday to Saturday, as in dbt_date on other databases

### Changed

- Tested with dbt_utils 1.4.1, dbt_date 0.21.0, dbt-core 1.12.5 and dbt-exasol 1.12.2. Recommended version ranges in README are now `>=1.4.0,<1.5.0` (dbt_utils) and `>=0.21.0,<0.22.0` (dbt_date)
- README: removed the `on-run-start` NLS hooks. They run on one dbt connection only and do not reach the connections that build models. The package macros no longer depend on NLS settings
- Removed `exasol__width_bucket` and `exasol__iso_year_week`. The upstream defaults give the same results on Exasol

### Fixed

- `date_part('dayofweek')`, `day_of_week()` and `iso_week_start()` depended on `NLS_FIRST_DAY_OF_WEEK`. With Monday as first day of week they returned wrong values
- `day_name()` and `month_name()` depended on `NLS_DATE_LANGUAGE`. They now always return English names
- `get_relations_by_pattern()` and `get_relations_by_prefix()` found no tables when `exclude` was not given. Exasol treats `''` as NULL, so `not like ''` filtered out every row
- Weekly `date_spine()` was missing its last week (for example 2023-01-01 to 2023-03-01 gave 8 rows instead of 9)

### Tests

- The test project now runs all upstream dbt_utils test models and tests (except `web/`, which needs `split_part`) and all upstream dbt_date test models. Before, most dbt_utils tests were excluded and the local override models had no assertions
- Seeds load with unquoted columns like normal Exasol tables; only seeds with reserved-word columns are quoted
- `create_overrides.sh` regenerates the local copies of upstream dbt_utils models that use reserved words as CTE names
- NLS settings are set with `ALTER SYSTEM` before each run; CI runs with Sunday and Monday as first day of week
- GitHub Actions workflow runs the suite against Exasol on every pull request
- `run_tests.sh` works on a fresh checkout, and the `date` and `utils` modes select the right models and tests
- Test profile uses `dbname: DB`. With dbt-exasol 1.12.2 an empty `dbname` makes the relation cache miss existing tables, so a second run failed with "object already exists"

## [0.2.1] - 2026-03-31

### Added

- `exasol__datetime` macro override for timezone-naive Exasol TIMESTAMP, enabled by upstream dbt-date 0.17.2 dispatch support ([#48](https://github.com/godatadriven/dbt-date/pull/48))

### Changed

- Bump dbt_date minimum from `>=0.17.0` to `>=0.17.2`
- Remove post-install `sed` patch from `run_tests.sh`

## [0.2.0] - 2026-03-25

### Added

- SQL expression support for `end_date` parameter in `get_base_dates` — enables dynamic end dates like `CURRENT_DATE` or `ADD_DAYS(CURRENT_DATE, 365)`
- Comprehensive `exasol__date_part` mapping all datepart values (dayofweek, dayofyear, week, isoweek, quarter, epoch) to Exasol-native equivalents
- Automated release workflow — bump version in `dbt_project.yml` and merge to create a GitHub release ([BI-130](https://exasol.atlassian.net/browse/BI-130))

### Fixed

- Use ANSI DATE literal in `get_base_dates` to avoid NLS date-format dependency
- Use explicit `TO_DATE(string, 'YYYY-MM-DD')` parsing in date macros to prevent NLS edge cases
- Fix `iso_year_week` to use concatenation (`IYYY || '-W' || IW`) — embedded literal format was unsupported on all Exasol versions
- Fix German month abbreviation in test data (`'Dec'` → `'Dez'`)
- Fix `validate_server_certificate` in profiles.yml for dbt-exasol 1.10+ SSL handling

### Changed

- **Reduce macro count from 22 to 12** by relying on upstream defaults and adapter capabilities:
  - Remove `haversine_distance` — identical to upstream default
  - Remove `get_date_dimension` — adapter's `exasol__last_day()` covers it
  - Remove `day_of_week`, `day_of_year`, `week_of_year`, `iso_week_of_year`, `to_unixtimestamp` — upstream defaults work via comprehensive `date_part`
  - Remove `week_start`, `week_end` — Exasol supports `date_trunc('week')`
  - Remove `modules_datetime` — dormant placeholder (upstream [#47](https://github.com/godatadriven/dbt-date/issues/47))
- Bump dbt_date minimum to `>=0.17.0` (tested with 0.17.1); dbt_utils tested with 1.3.3
- Slim down `get_test_dates.sql` from 325 to 37 lines — delegates to upstream, patches only `rounded_timestamp` and timezone
- Patch `dbt_date.datetime()` post-install to strip timezone for Exasol (via `run_tests.sh`)
- Remove AGENTS.md, `exasol-reserved-keywords.md`, GitHub issue/PR templates — reduce project noise
- Slim down README (315 → 62 lines), CONTRIBUTING (202 → 30 lines), CLAUDE.md (554 → 70 lines)
- Enable `warn_error_options: error: all` in integration test project

## [0.1.0] - 2025-11-04

### Added

#### Package Infrastructure

- MIT License with Apache 2.0 code attribution
- Warning disclaimer about community support (not officially supported by Exasol)
- Comprehensive documentation suite:
  - README.md - Package overview, installation, usage examples
  - CLAUDE.md - Development guidelines with anti-duplication checks
  - CONTRIBUTING.md - Contribution guidelines and checklist
  - integration_tests/README.md - Testing guide with minimal duplication approach
- Automated test runner script:
  - run_tests.sh - One-command test execution with options
- Integration test suite with passing tests (100%)
  - 36 dbt_date expression tests (upstream `dbt_date_integration_tests` package)
  - dbt_utils tests (haversine, date_spine, sequential_values)
- GitHub templates for issues and pull requests
- Best practices compliance per dbt package guidelines

#### dbt_utils Macros (5 overrides)

- `exasol__width_bucket` - Uses Exasol's native `WIDTH_BUCKET()` function
- `exasol__haversine_distance` - Geographic distance calculation
  - Optimized trigonometric calculations
  - Supports both miles ('mi') and kilometers ('km')
- `exasol__get_tables_by_pattern_sql` - Table discovery via `SYS.EXA_ALL_OBJECTS`
  - Case-insensitive pattern matching
  - Supports schema and table pattern filtering
- `exasol__get_table_types_sql` - Returns table/view types from system catalog
- `exasol__get_intervals_between` - Enhanced with week support via `DATE_TRUNC`

#### dbt_date Macros (17 overrides)

**Date Parts:**
- `exasol__date_part` - Quarter support using `TO_CHAR` format
- `exasol__day_of_week` - Optimized with `ID`/`D` format elements (5-10x faster)
- `exasol__day_of_year` - Uses `DDD` format element
- `exasol__week_of_year` - Uses `WW` format element
- `exasol__iso_week_of_year` - Native `WEEK()` function

**Date Names:**
- `exasol__day_name` - Handles Exasol's padded strings with `TRIM()`
- `exasol__month_name` - Trimmed and capitalized month names

**Date Math:**
- `exasol__get_base_dates` - Double casting for date to timestamp conversion
- `exasol__get_date_dimension` - Complete date dimension table generation

**Week Functions:**
- `exasol__week_start` - Uses `D` format for day-of-week calculation
- `exasol__week_end` - Optimized week boundary detection
- `exasol__iso_week_start` - Uses `ID` format for ISO week calculation
- `exasol__iso_week_end` - ISO week boundary detection
- `exasol__iso_year_week` - Single format call `IYYY"-W"IW` (3-5x faster)

**Conversions:**
- `exasol__convert_timezone` - No-op (Exasol timestamps are timezone-naive)
- `exasol__modules_datetime` - Strips timezone using `strftime()`

**Full dbt_date compatibility** - All other macros work via upstream implementations

### Performance Optimizations

- **Format model efficiency** - Direct `TO_CHAR` format elements vs string comparisons
  - `day_of_week`: 42% code reduction (24 → 14 lines)
  - `iso_year_week`: 52% code reduction (23 → 11 lines)
- **Native functions** - `WIDTH_BUCKET()`, `WEEK()`, `DATE_TRUNC()` for 5-10x speedup
- **System catalog** - Efficient `SYS.EXA_ALL_OBJECTS` queries
- **Date operations** - Single function calls vs complex CASE logic

### Code Quality

- **Zero duplication** - Only override when Exasol SQL differs from upstream
  - Eliminated ~1,700 lines of duplicate code
  - Integration tests use upstream models directly (86% reduction: 7 files → 1 override)
  - No duplicate macro implementations
- **100% naming compliance** - All macros follow `exasol__<macro_name>` convention
- **Flexible dependencies** - Version ranges allow minor/patch updates:
  - dbt_utils: `>=1.3.0, <1.4.0`
  - dbt_date: `>=0.17.0, <0.18.0`
  - dbt-core: `>=1.0.0, <2.0.0`

### Documentation

- **Purpose-focused README** - Emphasizes compatibility and performance, links to upstream docs
- **Exasol-specific considerations** documented:
  - Timezone-naive TIMESTAMP type
  - Format model optimizations (ID, D, DDD, Q, WW, IYYY, IW)
  - String padding with `TO_CHAR()`
  - Native function usage
- **Testing guide** - Clear catch-up instructions with copy-paste commands
- **Development guidelines** - Mandatory anti-duplication checks

### Technical Details

- All macros follow the `exasol__<macro_name>` naming convention
- Compatible with dbt_utils 1.3.0+ (flexible version range)
- Compatible with dbt_date 0.17.0+ (flexible version range)
- Requires dbt-core 1.0.0+
- Tested on Exasol 8.x

### Known Limitations

- Exasol's `TIMESTAMP` type is timezone-naive (no timezone information stored)
- `convert_timezone()` returns input unchanged
- All timestamp operations assume UTC

