{{ config(materialized='table') }}

-- Local rewrite of upstream dbt_date test_dates to be Exasol-friendly.
-- Note: Exasol TIMESTAMPs do not carry timezone information; timezone-specific
-- assertions are removed/normalized in this test.

{{ exasol__get_test_dates() }}

