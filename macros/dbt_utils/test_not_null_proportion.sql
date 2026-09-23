{#
Exasol implementation of the not_null_proportion generic test.
On Exasol the upstream sum(...) / cast(count(*) as numeric) returns DOUBLE, so an
exact 0.9 comes out as 0.8999... and fails "at_least: 0.9". Round the proportion
to a fixed decimal before comparing.
#}

{% macro exasol__test_not_null_proportion(model, group_by_columns) %}
    {{ dbt_utils.default__test_not_null_proportion(model, group_by_columns, **kwargs)
        | replace(') as not_null_proportion', ') as decimal(18,6)) as not_null_proportion')
        | replace('sum(case when', 'cast(sum(case when') }}
{% endmacro %}
