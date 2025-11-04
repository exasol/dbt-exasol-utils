-- Exasol-compatible replacement for dbt_utils.sequential_values grouped by col_a
with windowed as (
  select
    "col_a",
    "my_even_sequence" as cur,
    lag("my_even_sequence") over (
      partition by "col_a"
      order by "my_even_sequence"
    ) as prev
  from {{ ref('data_test_sequential_values') }}
)
select *
from windowed
where prev is not null and cur <> prev + 2

