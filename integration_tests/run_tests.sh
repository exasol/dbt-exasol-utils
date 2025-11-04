#!/bin/bash
set -euo pipefail

# Integration test runner for dbt-exasol-utils
# Usage:
#   ./run_tests.sh           # Run all tests
#   ./run_tests.sh date      # Run only dbt_date tests
#   ./run_tests.sh utils     # Run only dbt_utils tests (datetime + overrides)
#   ./run_tests.sh compile   # Compile only and show example SQL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  dbt-exasol-utils Integration Test Runner${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Ensure venv
if [ -z "${VIRTUAL_ENV:-}" ]; then
  if [ -d "../.venv" ]; then
    echo -e "${YELLOW}Activating ../.venv...${NC}"
    # shellcheck disable=SC1091
    source ../.venv/bin/activate
  else
    echo -e "${YELLOW}Creating uv venv and installing deps...${NC}"
    uv venv ../.venv
    # shellcheck disable=SC1091
    source ../.venv/bin/activate
    uv pip install -q dbt-core dbt-exasol
  fi
fi

# Verify dbt is available
if ! command -v dbt >/dev/null 2>&1; then
  echo -e "${YELLOW}✗ dbt not found in PATH${NC}"
  echo "Install with: uv pip install dbt-core dbt-exasol"
  exit 1
fi

echo -e "${GREEN}✓ dbt version: $(dbt --version | head -1)${NC}"
echo ""

export DBT_PROFILES_DIR="$SCRIPT_DIR"

echo -e "${YELLOW}Installing/updating packages...${NC}"
dbt deps
echo ""

case "${1:-}" in
  date)
    echo -e "${BLUE}Running dbt_date tests only...${NC}"
    dbt seed --select dbt_date --full-refresh || true
    dbt run  --select dbt_date --full-refresh
    dbt test --select dbt_date
    ;;
  utils)
    echo -e "${BLUE}Running dbt_utils tests (datetime + overrides)...${NC}"
    dbt seed --full-refresh
    # Upstream datetime + local overrides
    dbt run  --select "path:dbt_packages/dbt_utils/integration_tests/models/datetime" "path:models/dbt_utils_overrides" --full-refresh
    # Exclude upstream equality YAML (replaced by local override) and upstream data schema tests
    dbt test --select "path:dbt_packages/dbt_utils/integration_tests/models/datetime" "path:models/dbt_utils_overrides" \
             --exclude "path:dbt_packages/dbt_utils/integration_tests/models/datetime/schema.yml" \
                       "path:dbt_packages/dbt_utils/integration_tests/data/schema_tests/schema.yml"
    ;;
  compile)
    echo -e "${BLUE}Compiling models...${NC}"
    dbt compile
    echo ""
    echo -e "${GREEN}Example Exasol-specific SQL (width_bucket):${NC}"
    echo "─────────────────────────────────────────────────────"
    head -20 target/compiled/dbt_exasol_utils_integration_tests/models/dbt_utils_overrides/sql/test_width_bucket.sql || true
    echo "─────────────────────────────────────────────────────"
    ;;
  *)
    echo -e "${BLUE}Running full test suite...${NC}"
    dbt seed --full-refresh
    dbt run  --full-refresh
    # Exclude upstream dbt_date tests (timezone) and only specific upstream YAMLs we replace locally
    dbt test --exclude package:dbt_date_integration_tests \
                      "path:dbt_packages/dbt_utils/integration_tests/data/schema_tests/schema.yml" \
                      "path:dbt_packages/dbt_utils/integration_tests/models/datetime/schema.yml"
    ;;
esac

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Done${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
