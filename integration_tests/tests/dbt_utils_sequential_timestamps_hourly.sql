-- Exasol-compatible replacement for dbt_utils.sequential_values on hourly timestamps
with windowed as (
  select
    "my_timestamp" as cur,
    lag("my_timestamp") over (order by "my_timestamp") as prev
  from {{ ref('data_test_sequential_timestamps') }}
)
select *
from windowed
where prev is not null and cast(cur as {{ dbt.type_timestamp() }}) 
      <> cast({{ dbt.dateadd('hour', 1, 'prev') }} as {{ dbt.type_timestamp() }})

