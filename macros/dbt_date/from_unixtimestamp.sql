{%- macro exasol__from_unixtimestamp(epochs, format) -%}
    {%- if format == "seconds" -%}
        convert_tz(from_posix_time({{ epochs }}), dbtimezone, 'UTC')
    {%- elif format == "milliseconds" -%}
        convert_tz(from_posix_time({{ epochs }} / 1000), dbtimezone, 'UTC')
    {%- else -%}
        {{
            exceptions.raise_compiler_error(
                "value "
                ~ format
                ~ " for `format` for from_unixtimestamp is not supported."
            )
        }}
    {% endif -%}
{%- endmacro %}
