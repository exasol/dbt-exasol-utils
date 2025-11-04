{{ config(materialized='view') }}

-- Exasol-friendly wrapper: expose uppercase column name expected by equality test
select
    "date_day" as "DATE_DAY"
from {{ ref('data_date_spine') }}

