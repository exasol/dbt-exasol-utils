{#
Exasol implementation of week_end macro.
Upstream default uses last_day(date, 'week'), which follows NLS_FIRST_DAY_OF_WEEK
on Exasol. Use the Sunday-based week_start plus 6 days.
#}

{%- macro exasol__week_end(date) -%}
    {%- set dt = dbt_date.week_start(date) -%} {{ dbt_date.n_days_away(6, dt) }}
{%- endmacro %}
