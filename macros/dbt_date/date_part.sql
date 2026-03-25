{#
Exasol implementation of date_part macro.
Maps all datepart values used by dbt_date to Exasol-native equivalents.
This single macro enables upstream defaults for day_of_week, day_of_year,
week_of_year, iso_week_of_year, and to_unixtimestamp to work without overrides.
#}

{% macro exasol__date_part(datepart, date) -%}
    {%- set dp = datepart | lower -%}
    {%- if dp == 'dayofweek' or dp == 'dow' -%}
        (to_char({{ date }}, 'D') - 1)
    {%- elif dp == 'dayofyear' or dp == 'doy' -%}
        cast(to_char({{ date }}, 'DDD') as {{ dbt.type_int() }})
    {%- elif dp == 'week' -%}
        cast(to_char({{ date }}, 'WW') as {{ dbt.type_int() }})
    {%- elif dp == 'isoweek' -%}
        week({{ date }})
    {%- elif dp == 'quarter' -%}
        cast(to_char({{ date }}, 'Q') as {{ dbt.type_int() }})
    {%- elif dp == 'epoch' or dp == 'epoch_seconds' -%}
        posix_time(convert_tz(cast({{ date }} as {{ dbt.type_timestamp() }}), 'UTC', dbtimezone))
    {%- else -%}
        extract({{ datepart }} from {{ date }})
    {%- endif -%}
{%- endmacro %}
