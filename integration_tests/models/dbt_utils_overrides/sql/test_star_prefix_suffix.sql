{% set prefix_with = 'prefix_' if target.type != 'snowflake' else 'PREFIX_' %}
{% set suffix_with = '_suffix' if target.type != 'snowflake' else '_SUFFIX' %}

with test_data AS (

    select
        {{ dbt_utils.star(from=ref('data_star'), prefix=prefix_with, suffix=suffix_with) }}

    from {{ ref('data_star') }}

)

select * from test_data