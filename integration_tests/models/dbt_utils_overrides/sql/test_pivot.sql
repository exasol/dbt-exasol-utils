-- Hand-written Exasol copy of upstream dbt_utils test_pivot.sql.
-- pivot quotes its aliases ("red"), which keeps them lowercase on Exasol.
-- The expected seed has unquoted (uppercase) columns, so alias them back.

with pivoted as (
    select
        size,
        {{ dbt_utils.pivot('color', ['red', 'blue'], cmp='=') }}
    from {{ ref('data_pivot') }}
    group by size
)

select
    size,
    "red" as red,
    "blue" as blue
from pivoted
