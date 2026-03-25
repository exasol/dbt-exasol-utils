{#
Exasol-specific test data overrides.

All default implementations come from the upstream dbt_date_integration_tests
package. We only override what differs for Exasol.

Thin wrappers below re-export upstream helpers so cross-package macro calls
resolve correctly when exasol__get_test_dates() delegates to the upstream.

exasol__get_test_timestamps:
  Exasol TIMESTAMP is timezone-naive, so both time_stamp and time_stamp_utc
  must be the same UTC value without timezone suffixes.

exasol__get_test_dates:
  Calls upstream and patches rounded_timestamp from '2021-06-07' to '2021-06-08'.
  Needed because exasol__get_test_timestamps uses UTC 14:35 (rounds UP),
  while upstream uses 07:35 local time (rounds down).
#}

{# Re-export upstream helpers for cross-package resolution #}
{% macro get_test_dates() %}{{ dbt_date_integration_tests.get_test_dates() }}{% endmacro %}
{% macro get_test_week_start_date() %}{{ return(dbt_date_integration_tests.get_test_week_start_date()) }}{% endmacro %}
{% macro get_test_week_end_date() %}{{ return(dbt_date_integration_tests.get_test_week_end_date()) }}{% endmacro %}
{% macro get_test_week_of_year() %}{{ return(dbt_date_integration_tests.get_test_week_of_year()) }}{% endmacro %}
{% macro get_test_timestamps() %}{{ return(dbt_date_integration_tests.get_test_timestamps()) }}{% endmacro %}

{% macro exasol__get_test_timestamps() -%}
    {{ return(["2021-06-07 14:35:20.000000", "2021-06-07 14:35:20.000000"]) }}
{%- endmacro %}

{% macro exasol__get_test_dates() -%}
    {%- set base_sql = dbt_date_integration_tests.get_test_dates() -%}
    {%- set old = "cast('2021-06-07' as " ~ dbt.type_timestamp() ~ ") as rounded_timestamp" -%}
    {%- set new = "cast('2021-06-08' as " ~ dbt.type_timestamp() ~ ") as rounded_timestamp" -%}
    {{ base_sql | replace(old, new) | replace("+00:00'", "'") }}
{%- endmacro %}
