{% macro exasol__get_table_types_sql() %}
            lower(object_type) as {{ adapter.quote('table_type') }}
{% endmacro %}
