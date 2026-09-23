{#
Exasol implementation of get_column_values macro.
Same as the upstream default, but the result alias is quoted: VALUE is a
reserved word in Exasol, so the default "as value" is a syntax error.
#}

{% macro exasol__get_column_values(table, column, order_by='count(*) desc', max_records=none, default=none, where=none) -%}
    {#-- Prevent querying of db in parsing mode. This works because this macro does not create any new refs. #}
    {%- if not execute -%}
        {% set default = [] if not default %}
        {{ return(default) }}
    {% endif %}

    {%- do dbt_utils._is_ephemeral(table, 'get_column_values') -%}

    {%- set target_relation = table -%}
    {% set relation_exists = (load_relation(target_relation)) is not none %}

    {%- call statement('get_column_values', fetch_result=true) %}

        {%- if not relation_exists and default is none -%}

          {{ exceptions.raise_compiler_error("In get_column_values(): relation " ~ target_relation ~ " does not exist and no default value was provided.") }}

        {%- elif not relation_exists and default is not none -%}

          {{ log("Relation " ~ target_relation ~ " does not exist. Returning the default value: " ~ default) }}

          {{ return(default) }}

        {%- else -%}

            select
                {{ column }} as {{ adapter.quote('value') }}

            from {{ target_relation }}

            {% if where is not none %}
            where {{ where }}
            {% endif %}

            group by {{ column }}
            order by {{ order_by }}

            {% if max_records is not none %}
            limit {{ max_records }}
            {% endif %}

        {% endif %}

    {%- endcall -%}

    {%- set value_list = load_result('get_column_values') -%}

    {%- if value_list and value_list['data'] -%}
        {%- set values = value_list['data'] | map(attribute=0) | list %}
        {{ return(values) }}
    {%- else -%}
        {{ return(default) }}
    {%- endif -%}

{%- endmacro %}
