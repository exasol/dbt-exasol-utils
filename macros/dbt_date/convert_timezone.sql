{%- macro exasol__convert_timezone(column, target_tz, source_tz) -%}
    convert_tz(
        cast({{ column }} as {{ dbt.type_timestamp() }}),
        '{{ source_tz }}',
        '{{ target_tz }}'
    )
{%- endmacro -%}
