-- Exasol copy of upstream dbt_utils tests/sql/test_get_single_value_multiple_rows.sql: INPUT and OUTPUT are reserved.
{% set query %}
with input_rows as (
    select 1 as id, 4 as di 
    union all 
    select 2 as id, 5 as di
    union all 
    select 3 as id, 6 as di
)
{% endset %}

with comparisons as (
    select {{ dbt_utils.get_single_value(query ~ " select min(id) from input_rows") }} as actual_output, 1 as expected
    union all
    select {{ dbt_utils.get_single_value(query ~ " select max(di) from input_rows") }} as actual_output, 6 as expected
)
select * 
from comparisons
where actual_output != expected