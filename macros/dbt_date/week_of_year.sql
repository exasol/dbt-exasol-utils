{%- macro exasol__week_of_year(date) -%}
    {# WW = week of year where week 1 starts on the first day of the year (non-ISO) #}
    cast(to_char({{ date }}, 'WW') as {{ dbt.type_int() }})
{%- endmacro %}

