{{ config(materialized='table') }}

-- Local smoke test: get_date_dimension should compile and run on Exasol
-- for a fixed date range. This replicates typical usage in consuming projects.

{{ dbt_date.get_date_dimension("2015-01-01", "2022-12-31") }}

