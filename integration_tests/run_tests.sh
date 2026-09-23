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
# Fresh checkout: packages.yml references dbt_packages/dbt_date/integration_tests,
# which only exists after a first install. Install without it once, then run full deps.
UPSTREAM_TESTS="dbt_packages/dbt_date/integration_tests"
if [ ! -f "$UPSTREAM_TESTS/dbt_project.yml" ]; then
  echo -e "${YELLOW}Bootstrapping packages (first install)...${NC}"
  cp packages.yml packages.yml.full
  grep -v "$UPSTREAM_TESTS" packages.yml.full > packages.yml
  dbt deps || { mv packages.yml.full packages.yml; exit 1; }
  mv packages.yml.full packages.yml
fi
dbt deps

echo ""

# System NLS defaults for this run. Macros must not depend on them: CI runs with
# EXA_FIRST_DAY_OF_WEEK=7 (Exasol default, Sunday) and 1 (Monday).
# Skipped for compile, which needs no database.
if [ "${1:-}" != "compile" ]; then
  dbt run-operation set_system_nls --args "{first_day_of_week: ${EXA_FIRST_DAY_OF_WEEK:-7}, date_format: '${EXA_DATE_FORMAT:-YYYY-MM-DD}'}"
  echo ""
fi

# dbt_date models and tests: local models/dbt_date plus the upstream dbt_date test package
DATE_NODES="path:models/dbt_date package:dbt_date_integration_tests"

case "${1:-}" in
  date)
    echo -e "${BLUE}Running dbt_date tests (local + upstream models)...${NC}"
    dbt run  --select "$DATE_NODES" --full-refresh
    dbt test --select "$DATE_NODES"
    ;;
  utils)
    echo -e "${BLUE}Running dbt_utils tests (upstream + Exasol copies)...${NC}"
    dbt seed --full-refresh
    dbt run  --exclude "$DATE_NODES" --full-refresh
    dbt test --exclude "$DATE_NODES"
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
    dbt test
    ;;
esac

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Done${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
