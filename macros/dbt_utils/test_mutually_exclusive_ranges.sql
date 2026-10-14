{#
Exasol implementation of the mutually_exclusive_ranges generic test.
The upstream CTE calc selects an unqualified * next to other columns
(select *, ...). Exasol 2025.1 rejects that with "syntax error, unexpected ','";
newer versions accept it. Qualify the star with its CTE name.
#}

{% macro exasol__test_mutually_exclusive_ranges(model, lower_bound_column, upper_bound_column, partition_by=None, gaps='allowed', zero_length_range_allowed=False) %}
    {{ modules.re.sub(
        'select\\s+\\*,',
        'select window_functions.*,',
        dbt_utils.default__test_mutually_exclusive_ranges(model, lower_bound_column, upper_bound_column, partition_by, gaps, zero_length_range_allowed)
    ) }}
{% endmacro %}
