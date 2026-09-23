-- Hand-written Exasol copy of upstream dbt_utils test_safe_divide.sql.
-- The seeds are quoted (OUTPUT is a reserved word), so their columns are referenced quoted.

with data_safe_divide as (
    select * from {{ ref('data_safe_divide') }}
),

data_safe_divide_numerator_expressions as (
    select * from {{ ref('data_safe_divide_numerator_expressions') }}
),

data_safe_divide_denominator_expressions as (
    select * from {{ ref('data_safe_divide_denominator_expressions') }}
)

select
    {{ dbt_utils.safe_divide('"numerator"', '"denominator"') }} as actual,
    "output" as expected
from data_safe_divide

union all

select
    {{ dbt_utils.safe_divide('"numerator_1" * "numerator_2"', '"denominator"') }} as actual,
    "output" as expected
from data_safe_divide_numerator_expressions

union all

select
    {{ dbt_utils.safe_divide('"numerator"', '"denominator_1" * "denominator_2"') }} as actual,
    "output" as expected
from data_safe_divide_denominator_expressions
