-- Weekly date_spine uses exasol__get_intervals_between: dbt-exasol's datediff has no 'week'.
-- Rows are start + 7k before end_date (end excluded):
--   2023-01-01 .. 2023-03-01 (59 days) -> 9 rows, last 2023-02-26
--   2023-01-01 .. 2023-01-29 (28 days) -> 4 rows, last 2023-01-22
--   2023-01-01 00:00 .. 2023-01-08 12:00 (timestamps, 7.5 days) -> 2 rows, last 2023-01-08

with partial_week as (
    {{ dbt_utils.date_spine("week", "date '2023-01-01'", "date '2023-03-01'") }}
),

exact_weeks as (
    {{ dbt_utils.date_spine("week", "date '2023-01-01'", "date '2023-01-29'") }}
),

timestamps as (
    {{ dbt_utils.date_spine("week", "timestamp '2023-01-01 00:00:00'", "timestamp '2023-01-08 12:00:00'") }}
),

checks as (
    select 'partial_week' as spine, count(*) as row_count, max(date_week) as last_week, 9 as expected_count, date '2023-02-26' as expected_last
    from partial_week
    union all
    select 'exact_weeks', count(*), max(date_week), 4, date '2023-01-22'
    from exact_weeks
    union all
    select 'timestamps', count(*), cast(max(date_week) as date), 2, date '2023-01-08'
    from timestamps
)

select *
from checks
where row_count != expected_count or last_week != expected_last
