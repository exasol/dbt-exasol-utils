{%- macro exasol__month_name(date, short, language) -%}
    {# Exasol's to_char returns padded strings and uppercase, so we need trim() and initcap() #}
    {%- if language == "default" -%}
        {%- set f = "Mon" if short else "Month" -%} initcap(trim(to_char({{ date }}, '{{ f }}')))
    {%- else -%} {{ dbt_date.month_name_localized(date, short, language) }}
    {%- endif -%}
{%- endmacro %}
