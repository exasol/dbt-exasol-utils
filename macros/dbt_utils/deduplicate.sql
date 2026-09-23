{#
Exasol implementation of deduplicate macro.
The upstream default aliases subqueries as _inner and data. Exasol rejects
both (identifiers cannot start with an underscore, DATA is reserved).
Exasol supports QUALIFY, so filter with row_number() directly.
#}

{%- macro exasol__deduplicate(relation, partition_by, order_by) -%}

    select *
    from {{ relation }}
    qualify
        row_number() over (
            partition by {{ partition_by }}
            order by {{ order_by }}
        ) = 1

{%- endmacro -%}
