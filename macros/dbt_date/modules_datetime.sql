{#
Exasol implementation of datetime macro.
Exasol TIMESTAMP type doesn't support timezone information, so we strip it using strftime().
#}

{% macro exasol__datetime(
    year, month, day, hour, minute, second, microsecond, tz
) %}
    {{
        return(
            modules.datetime.datetime(
                year=year,
                month=month,
                day=day,
                hour=hour,
                minute=minute,
                second=second,
                microsecond=microsecond,
            ).strftime("%Y-%m-%d %H:%M:%S")
        )
    }}
{% endmacro %}
