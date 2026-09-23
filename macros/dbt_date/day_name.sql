{%- macro exasol__day_name(date, short, language) -%}
    {# Exasol's to_char returns padded strings, so we need trim(). English is pinned, so NLS_DATE_LANGUAGE does not matter #}
    {%- if language == "default" -%}
        {%- set f = "Dy" if short else "Day" -%} trim(to_char({{ date }}, '{{ f }}', 'NLS_DATE_LANGUAGE=ENG'))
    {%- else -%} {{ dbt_date.day_name_localized(date, short, language) }}
    {%- endif -%}
{%- endmacro -%}
