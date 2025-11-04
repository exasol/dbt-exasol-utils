{%- macro exasol__week_start(date) -%}
    {# Exasol doesn't support date_trunc('week'). Calculate week start (Sunday) using day_of_week #}
    {% set off_set = dbt_date.day_of_week(date, isoweek=False) ~ " - 1" %}
    cast({{ dbt.dateadd("day", "-1 * (" ~ off_set ~ ")", date) }} as date)
{%- endmacro %}
