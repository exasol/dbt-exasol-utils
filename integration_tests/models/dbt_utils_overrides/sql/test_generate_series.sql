
-- snowflake doesn't like this as a view because the `generate_series`
-- call creates a CTE called `unioned`, as does the `equality` generic test.
-- Ideally, Snowflake would be smart enough to know that these CTE names are
-- different, as they live in different relations. Materialize as table to avoid CTE naming conflicts.

{{ config(materialized='table') }}

with test_data AS (

    {{ dbt_utils.generate_series(10) }}

)

select generated_number from test_data
