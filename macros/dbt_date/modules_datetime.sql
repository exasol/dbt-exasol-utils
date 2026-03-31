{#
Exasol override for dbt_date.datetime().
Exasol TIMESTAMP is timezone-naive, so we omit tzinfo.
Requires dbt-date >= 0.17.2 (dispatch support).
#}

{% macro exasol__datetime(
    year, month, day, hour, minute, second, microsecond, tz
) %}
  {{ return(
      modules.datetime.datetime(
          year=year,
          month=month,
          day=day,
          hour=hour,
          minute=minute,
          second=second,
          microsecond=microsecond,
      )
  ) }}
{% endmacro %}
