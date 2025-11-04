{#
Exasol implementation of date_part macro.
Exasol doesn't support EXTRACT(QUARTER FROM date), so we use TO_CHAR for quarters.
#}

{% macro exasol__date_part(datepart, date) -%}
    {%- if datepart == 'quarter' -%}
        cast(to_char({{ date }}, 'Q') as {{ dbt.type_int() }})
    {%- else -%}
        extract({{ datepart }} from {{ date }})
    {%- endif -%}
{%- endmacro %}
