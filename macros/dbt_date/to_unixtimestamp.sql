{%- macro exasol__to_unixtimestamp(timestamp) -%}
    posix_time(convert_tz(cast({{ timestamp }} as {{ dbt.type_timestamp() }}), 'UTC', dbtimezone))
{%- endmacro %}
