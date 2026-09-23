{#
Set system-wide NLS defaults on the test database before a run.
on-run-start hooks only reach dbt's master connection, not the connections that
build models and run tests, so session settings cannot be tested that way.
Called by run_tests.sh as a separate dbt invocation; later invocations open new
sessions that get these defaults. Only for the local/CI test database.
#}

{% macro set_system_nls(first_day_of_week=7, date_format='YYYY-MM-DD', timestamp_format='YYYY-MM-DD HH24:MI:SS.FF6', date_language='ENG') %}
    {% do run_query("alter system set NLS_FIRST_DAY_OF_WEEK = " ~ first_day_of_week) %}
    {% do run_query("alter system set NLS_DATE_FORMAT = '" ~ date_format ~ "'") %}
    {% do run_query("alter system set NLS_TIMESTAMP_FORMAT = '" ~ timestamp_format ~ "'") %}
    {% do run_query("alter system set NLS_DATE_LANGUAGE = '" ~ date_language ~ "'") %}
    {{ log("System NLS: first_day_of_week=" ~ first_day_of_week ~ ", date_format=" ~ date_format ~ ", timestamp_format=" ~ timestamp_format ~ ", date_language=" ~ date_language, info=True) }}
{% endmacro %}
