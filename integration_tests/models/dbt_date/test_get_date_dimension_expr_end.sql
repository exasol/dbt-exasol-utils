{{ config(materialized='table') }}

-- Test get_date_dimension with an expression end date
{% set expr_end = "CAST(ADD_YEARS(DATE_TRUNC('year', NOW()), 2) AS DATE)" %}
{{ dbt_date.get_date_dimension("2015-01-01", expr_end) }}

