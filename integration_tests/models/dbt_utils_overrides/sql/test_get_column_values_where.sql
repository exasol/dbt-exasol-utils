-- Hand-written Exasol copy of upstream dbt_utils test_get_column_values_where.sql.
-- The seed is quoted (CONDITION is a reserved word), so its columns are referenced quoted.

{% set column_values = dbt_utils.get_column_values(ref('data_get_column_values_where'), '"field"', where="\"condition\" = 'left'") %}

-- Create a relation using the values
{% for val in column_values -%}
select {{ string_literal(val) }} as field {% if not loop.last %}union all{% endif %}
{% endfor %}
