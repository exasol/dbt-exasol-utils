-- Exasol-compatible replacement for dbt_utils.sequential_values on my_even_sequence
with windowed as (
  select
    "my_even_sequence" as cur,
    lag("my_even_sequence") over (order by "my_even_sequence") as prev
  from {{ ref('data_test_sequential_values') }}
)
select *
from windowed
where prev is not null and cur <> prev + 2

