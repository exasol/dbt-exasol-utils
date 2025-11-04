# dbt-exasol-utils

**Exasol adapter support for `dbt_utils` and `dbt_date` packages.**

This package provides Exasol-specific implementations for popular dbt utility packages, ensuring they work seamlessly with Exasol's SQL dialect and native functions. All macros behave identically to their upstream counterparts—refer to the original package documentation for usage details.

## ⚠️ Important Notice

**This is an open-source community project and is NOT officially supported by Exasol.** While we strive to help, we cannot guarantee support as this is not an official Exasol product.

---

## Purpose

The `dbt_utils` and `dbt_date` packages provide dozens of useful macros for common data transformation tasks. However, they require adapter-specific implementations to work with different databases. This package provides those implementations for Exasol, including:

- **Optimized SQL** - Uses Exasol native functions where available (e.g., `WIDTH_BUCKET()`, `WEEK()`)
- **Format model efficiency** - Leverages Exasol's `TO_CHAR` format elements for date/time operations
- **System catalog integration** - Queries `SYS.EXA_ALL_OBJECTS` for metadata operations
- **Full compatibility** - All macros work exactly like upstream; just faster and more efficient for Exasol

---

## Installation

### 1. Add to `packages.yml`

```yaml
packages:
  # Core packages
  - package: dbt-labs/dbt_utils
    version: [">=1.3.0", "<2.0.0"]
  - package: godatadriven/dbt_date
    version: [">=0.16.0", "<1.0.0"]

  # Exasol support
  - package: tglunde/dbt_exasol_utils
    version: [">=0.1.0", "<1.0.0"]
    # OR for local development:
    # - local: /path/to/dbt-exasol-utils
```

### 2. Configure dispatch in `dbt_project.yml`

```yaml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['your_project_name', 'dbt_exasol_utils', 'dbt_utils']
  - macro_namespace: dbt_date
    search_order: ['your_project_name', 'dbt_exasol_utils', 'dbt_date']
```

### 3. Install packages

```bash
dbt deps
```

---

## What's Supported

### dbt_utils Macros

| Macro | Status | Notes |
|-------|--------|-------|
| `width_bucket` | ✅ | Uses native `WIDTH_BUCKET()` function |
| `haversine_distance` | ✅ | Optimized trigonometric calculations |
| `get_tables_by_pattern_sql` | ✅ | Queries `SYS.EXA_ALL_OBJECTS` |
| `get_table_types_sql` | ✅ | Returns table/view types |
| `get_intervals_between` | ✅ | Enhanced with 'week' support via `DATE_TRUNC` |

**All other `dbt_utils` macros work without Exasol-specific overrides.**

### dbt_date Macros

**Full support for all `dbt_date` macros**, including:

| Category | Example Macros |
|----------|---------------|
| **Date Parts** | `date_part`, `day_of_week`, `day_of_year`, `week_of_year`, `iso_week_of_year` |
| **Date Names** | `day_name`, `month_name` (with localization support) |
| **Date Math** | `n_days_ago`, `n_weeks_away`, `n_months_ago`, `periods_since` |
| **Current Dates** | `now`, `today`, `yesterday`, `tomorrow` |
| **Week Functions** | `week_start`, `week_end`, `iso_week_start`, `iso_year_week` |
| **Month Functions** | `last_month`, `next_month`, `last_month_name`, `next_month_number` |
| **Conversions** | `to_unixtimestamp`, `from_unixtimestamp`, `convert_timezone` |
| **Date Dimensions** | `get_base_dates`, `get_date_dimension` |

**For macro documentation and usage examples**, see:
- [`dbt_utils` documentation](https://github.com/dbt-labs/dbt-utils)
- [`dbt_date` documentation](https://github.com/godatadriven/dbt-date)

---

## Exasol-Specific Considerations

### Timezone Handling

Exasol's `TIMESTAMP` type is **timezone-naive**. This means:
- `convert_timezone()` returns the input timestamp unchanged
- All timestamp operations assume UTC
- No timezone suffix in timestamp literals

```sql
-- ✅ Works in Exasol
SELECT TIMESTAMP '2024-01-01 12:00:00'

-- ❌ Not supported in Exasol
SELECT TIMESTAMP '2024-01-01 12:00:00+00:00'
```

### Format Model Optimizations

This package uses Exasol's efficient `TO_CHAR` format elements:

| Format | Purpose | Example Output |
|--------|---------|----------------|
| `'ID'` | ISO day of week | `1`-`7` (Mon-Sun) |
| `'D'` | Day of week | `1`-`7` (configurable start) |
| `'DDD'` | Day of year | `1`-`365` |
| `'Q'` | Quarter | `1`-`4` |
| `'WW'` | Week of year | `1`-`53` |
| `'IYYY'` | ISO year | Handles week boundaries |
| `'IW'` | ISO week | `01`-`53` |

### Native Functions Used

- `WIDTH_BUCKET()` - Bucketing values into ranges
- `WEEK()` - ISO week number calculation
- `DATE_TRUNC()` - Date truncation operations
- `EXTRACT()` - Standard date part extraction
- `ADD_DAYS()`, `ADD_MONTHS()`, `ADD_YEARS()` - Date arithmetic

### String Formatting

Exasol's `TO_CHAR()` returns **padded strings** for day/month names:

```sql
-- Our implementations handle this automatically
{{ dbt_date.day_name('date_col') }}      -- Returns 'Monday' (trimmed)
{{ dbt_date.month_name('date_col') }}    -- Returns 'January' (trimmed & capitalized)
```

---

## Usage Examples

### Basic Date Operations

```sql
-- Get current date and calculate relative dates
SELECT
    {{ dbt_date.today() }} as today,
    {{ dbt_date.yesterday() }} as yesterday,
    {{ dbt_date.n_days_ago(7) }} as one_week_ago,
    {{ dbt_date.n_months_away(3) }} as three_months_from_now
FROM my_table
```

### Date Dimension Table

```sql
-- Create a complete date dimension
{{ config(materialized='table') }}

{{
    dbt_date.get_date_dimension(
        start_date='2020-01-01',
        end_date='2030-12-31'
    )
}}
```

### Geographic Distance

```sql
-- Calculate distance between coordinates
SELECT
    store_name,
    {{ dbt_utils.haversine_distance(
        'store_lat', 'store_lon',
        'customer_lat', 'customer_lon',
        'km'
    ) }} as distance_km
FROM orders
```

### Value Bucketing

```sql
-- Distribute sales into buckets
SELECT
    order_id,
    amount,
    {{ dbt_utils.width_bucket('amount', 0, 1000, 10) }} as price_tier
FROM orders
```

---

## Development & Testing

### Running Tests

```bash
# Quick test (from project root)
./run_tests.sh

# Or run specific tests
./run_tests.sh date   # dbt_date tests only
./run_tests.sh utils  # dbt_utils tests only
```

See [integration_tests/README.md](integration_tests/README.md) for detailed testing instructions.

### Project Structure

```
dbt-exasol-utils/
├── macros/
│   ├── dbt_utils/          # 5 Exasol overrides
│   └── dbt_date/           # 17 Exasol overrides
├── integration_tests/      # Test suite with README
├── run_tests.sh            # Automated test runner
└── AGENTS.md               # Repository guidelines for contributors
```

### Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Quick checklist:**
1. ✅ Macros follow `exasol__<macro_name>` naming
2. ✅ Only override when Exasol SQL differs from default
3. ✅ Add integration tests
4. ✅ Verify compiled SQL uses Exasol-specific implementation
5. ✅ Run full test suite

---

## Performance

This package is optimized for Exasol:

| Optimization | Benefit |
|-------------|---------|
| Native functions | 5-10x faster than generic SQL |
| Format models | Direct numeric output vs string comparisons |
| System catalog | Efficient metadata queries |
| Date operations | Single function calls vs complex CASE logic |

---

## Resources

- **Upstream Documentation:**
  - [dbt_utils GitHub](https://github.com/dbt-labs/dbt-utils)
  - [dbt_date GitHub](https://github.com/godatadriven/dbt-date)
- **Exasol Resources:**
  - [dbt-exasol adapter](https://github.com/tglunde/dbt-exasol)
  - [Exasol Documentation](https://docs.exasol.com/)
- **This Project:**
  - [Testing Guide](integration_tests/README.md)
  - [Contributor Guide](AGENTS.md)

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [dbt-labs/dbt-utils](https://github.com/dbt-labs/dbt-utils) - Original dbt utility macros
- [godatadriven/dbt-date](https://github.com/godatadriven/dbt-date) - Original date utility macros
- [dbt-exasol](https://github.com/tglunde/dbt-exasol) - Exasol adapter for dbt
