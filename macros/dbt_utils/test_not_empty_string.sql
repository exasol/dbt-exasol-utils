{#
Exasol implementation of the not_empty_string generic test.
Exasol stores '' as NULL, so the upstream "col = ''" never matches, and its CTE
name "errors" is a reserved word. A value is empty here when it is not NULL but
trim() makes it NULL (whitespace only). Without trim_whitespace, Exasol cannot
hold an empty string, so the test finds no rows.
#}

{% macro exasol__test_not_empty_string(model, column_name, trim_whitespace=true) %}

    select *
    from {{ model }}
    where {{ column_name }} is not null
    {%- if trim_whitespace == true %}
      and trim({{ column_name }}) is null
    {%- else %}
      and length({{ column_name }}) = 0
    {%- endif %}

{% endmacro %}
