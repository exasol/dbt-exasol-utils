-- Exasol-adjusted equality for test_date_spine vs data_date_spine
with a as (
    select "DATE_DAY" from {{ ref('test_date_spine') }}
),
b as (
    select "DATE_DAY" from {{ ref('data_date_spine_upper') }}
),
a_minus_b as (
    select "DATE_DAY" from a
    except
    select "DATE_DAY" from b
),
b_minus_a as (
    select "DATE_DAY" from b
    except
    select "DATE_DAY" from a
),
unioned as (
    select 'a_minus_b' as which_diff, a_minus_b.* from a_minus_b
    union all
    select 'b_minus_a' as which_diff, b_minus_a.* from b_minus_a
)
select * from unioned

