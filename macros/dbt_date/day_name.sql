{%- macro exasol__day_name(date, short, language) -%}
    {# Exasol's to_char returns padded strings, so we need trim() #}
    {%- if language == "default" -%}
        {%- set f = "Dy" if short else "Day" -%} trim(to_char({{ date }}, '{{ f }}'))
    {%- else -%} {{ dbt_date.day_name_localized(date, short, language) }}
    {%- endif -%}
{%- endmacro -%}
