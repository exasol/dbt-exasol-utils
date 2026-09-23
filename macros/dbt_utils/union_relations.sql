{#
Exasol implementation of union_relations macro.
The default source column is _dbt_source_relation. Exasol identifiers cannot
start with an underscore unless quoted, so quote it and delegate to the default.
Query it as "_dbt_source_relation" (quoted, lowercase).
#}

{%- macro exasol__union_relations(relations, column_override=none, include=[], exclude=[], source_column_name='_dbt_source_relation', where=none) -%}
    {%- if source_column_name is not none and source_column_name.startswith('_') -%}
        {%- set source_column_name = adapter.quote(source_column_name) -%}
    {%- endif -%}
    {{ return(dbt_utils.default__union_relations(relations, column_override, include, exclude, source_column_name, where)) }}
{%- endmacro -%}
