{% set exclude_field = '"field_3"' %}


with test_data AS (

    select
        {{ dbt_utils.star(from=ref('data_star'), except=[exclude_field]) }}

    from {{ ref('data_star') }}

)

select * from test_data
