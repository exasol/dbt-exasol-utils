{% macro exasol__get_tables_by_pattern_sql(schema_pattern, table_pattern, exclude='', database=target.database) %}

        select distinct
            root_name as {{ adapter.quote('table_schema') }},
            object_name as {{ adapter.quote('table_name') }},
            {{ dbt_utils.get_table_types_sql() }}
        from sys.exa_all_objects
        where object_type in ('TABLE', 'VIEW')
        and lower(root_name) like lower('{{ schema_pattern }}')
        and lower(object_name) like lower('{{ table_pattern }}')
        and lower(object_name) not like lower('{{ exclude }}')

{% endmacro %}
