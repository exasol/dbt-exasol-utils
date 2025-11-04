{%- macro exasol__week_end(date) -%}
    {# Calculate week end (Saturday) as week_start + 6 days #}
    {%- set dt = dbt_date.week_start(date) -%} {{ dbt_date.n_days_away(6, dt) }}
{%- endmacro %}
