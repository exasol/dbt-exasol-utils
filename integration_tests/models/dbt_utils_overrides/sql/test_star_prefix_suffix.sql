-- Hand-written Exasol copy of upstream dbt_utils test_star_prefix_suffix.sql.
-- DATA is reserved (CTE renamed). star quotes prefixed aliases by default, which
-- gives "prefix_FIELD_1_suffix" on Exasol; unquoted aliases match the expected seed.

with test_data as (

    select
        {{ dbt_utils.star(from=ref('data_star'), prefix='prefix_', suffix='_suffix', quote_identifiers=False) }}

    from {{ ref('data_star') }}

)

select * from test_data
