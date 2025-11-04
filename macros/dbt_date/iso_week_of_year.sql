{%- macro exasol__iso_week_of_year(date) -%}
    week({{ date }})
{%- endmacro %}
