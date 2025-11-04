# dbt-exasol-utils Integration Tests

Integration tests for dbt-exasol-utils using upstream dbt_utils and dbt_date test suites.

## Approach: Minimal Overrides

**Goal**: Use maximum upstream tests with minimal local customization.

### Configuration

```yaml
# dbt_project.yml
seeds:
  +quote_columns: true  # Handles Exasol reserved keywords automatically
```

### Why This Works

**Exasol Reserved Keywords Problem:**
- Upstream test seeds contain columns like `output`, `condition`, `value`, `month`, `source`
- These are reserved keywords in Exasol (467 total)
- Without quoting: `CREATE TABLE (output INT)` → syntax error

**Solution: Option B (Chosen)**
- Set `+quote_columns: true` for all seeds
- Creates quoted lowercase columns: `"output"`, `"condition"`, `"value"`
- Update 16 model overrides to reference quoted seed columns
- **Result: 16 custom files** (vs 26 with seed overrides)

**Exasol Timestamp Note:**
- Exasol TIMESTAMP does not include timezone offsets.
- Upstream `dbt_date` test `test_dates` asserts timezone-aware values; a local rewrite (`models/dbt_date/test_dates.sql`) removes timezone-specific assertions while preserving functional coverage.

### Model Overrides

16 models have local overrides in `models/dbt_utils_overrides/`:

**Reason 1: "data" keyword conflict** (most files)
- Upstream uses `with data as (...)`
- `DATA` is reserved in Exasol
- Override renames to `with test_data as (...)`

**Reason 2: Quoted seed columns** (added via Option B)
- Reference seed columns as quoted lowercase: `"col_a"`, `"field_1"`, `"amount"`
- CTE names that are reserved: `"final"` (reserved keyword)
- Macro parameters: `['"column_1"', '"column_2"']` (quoted in strings)

### File Structure

```
integration_tests/
├── dbt_project.yml          # +quote_columns: true
├── models/
│   └── dbt_utils_overrides/  # 16 local overrides
│       ├── generic_tests/    # 3 files
│       ├── geo/              # 2 files
│       └── sql/              # 11 files
└── run_tests.sh              # Test runner script
```

### Test Execution

```bash
# From repo root
integration_tests/run_tests.sh            # Full suite
integration_tests/run_tests.sh date       # dbt_date only
integration_tests/run_tests.sh utils      # dbt_utils only

# Or within integration_tests/
./run_tests.sh                            # Full suite
```

### Maintenance

When upstream changes:
1. Seeds automatically sync (no local overrides)
2. Check if new models conflict with "data" keyword
3. If new seed columns added, update model SQL quoting as needed

### Statistics

- **Seeds**: 75/75 (100% ✅, 0 custom overrides)
- **Models**: 19/21 passing (90.5% ✅)
  - 16 custom overrides for Exasol compatibility
  - 2 skipped (web/ tests require split_part())
  - 2 failing (dbt_date upstream issues)
- **Code Reuse**: ~70% upstream tests used directly
