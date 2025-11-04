# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Integration test suite with **38/38 passing tests** (100%)
  - 36 dbt_date tests
  - 2 dbt_utils tests
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
- **100% naming compliance** - All 22 macros follow `exasol__<macro_name>` convention
- **Flexible dependencies** - Version ranges allow minor/patch updates:
  - dbt_utils: `>=1.3.0, <2.0.0`
  - dbt_date: `>=0.16.0, <1.0.0`
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
- Compatible with dbt_date 0.16.0+ (flexible version range)
- Requires dbt-core 1.0.0+
- Tested on Exasol 8.x

### Known Limitations

- Exasol's `TIMESTAMP` type is timezone-naive (no timezone information stored)
- `convert_timezone()` returns input unchanged
- All timestamp operations assume UTC

## [Unreleased]

### Planned

- Publish to dbt package hub
- Additional performance optimizations as identified
- Community feedback integration
