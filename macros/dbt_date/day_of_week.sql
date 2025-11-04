{#
Exasol implementation of day_of_week macro.
Uses native format elements for efficient day-of-week calculation.
- ID format: ISO day of week (1-7, Monday=1 to Sunday=7)
- D format: Day of week (1-7, starting from NLS_FIRST_DAY_OF_WEEK, typically Sunday)
#}

{%- macro exasol__day_of_week(date, isoweek) -%}
    {%- if isoweek -%}
        cast(to_char({{ date }}, 'ID') as {{ dbt.type_int() }})
    {%- else -%}
        cast(to_char({{ date }}, 'D') as {{ dbt.type_int() }})
    {%- endif -%}
{%- endmacro %}
