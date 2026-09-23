{#
Exasol implementation of the fewer_rows_than generic test.
The upstream default names its last CTE "final" (reserved in Exasol) and groups
by the alias of a constant join key, which Exasol rejects. Delegate to the default,
rename the CTE and drop the constant from GROUP BY (grouping by a constant is a no-op).
#}

{% macro exasol__test_fewer_rows_than(model, compare_model, group_by_columns) %}
    {{ dbt_utils.default__test_fewer_rows_than(model, compare_model, group_by_columns)
        | replace('final as (', 'final_result as (')
        | replace('select * from final', 'select * from final_result')
        | replace('group by id_dbtutils_test_fewer_rows_than,', 'group by ')
        | replace('group by id_dbtutils_test_fewer_rows_than', '') }}
{% endmacro %}
