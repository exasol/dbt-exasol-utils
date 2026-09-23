{#
Exasol implementation of week_start macro.
Upstream default uses date_trunc('week'), which follows NLS_FIRST_DAY_OF_WEEK on Exasol.
dbt_date defines week_start as Sunday, so subtract the Sunday-based day of week instead.
#}

{%- macro exasol__week_start(date) -%}
    {#-- day_of_week is 1 for Sunday, so the offset is day_of_week - 1 --#}
    {% set off_set = dbt_date.day_of_week(date, isoweek=False) ~ " - 1" %}
    cast({{ dbt.dateadd("day", "-1 * (" ~ off_set ~ ")", date) }} as date)
{%- endmacro %}
