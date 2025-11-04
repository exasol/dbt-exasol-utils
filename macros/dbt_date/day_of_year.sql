{%- macro exasol__day_of_year(date) -%}
    cast(to_char({{ date }}, 'DDD') as {{ dbt.type_int() }})
{%- endmacro %}
