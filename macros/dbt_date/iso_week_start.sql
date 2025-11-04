{%- macro exasol__iso_week_start(date) -%}
    {# Exasol doesn't support date_trunc('isoweek'). Calculate ISO week start (Monday) using day_of_week with ISO #}
    {% set off_set = dbt_date.day_of_week(date, isoweek=True) ~ " - 1" %}
    cast({{ dbt.dateadd("day", "-1 * (" ~ off_set ~ ")", date) }} as date)
{%- endmacro %}
