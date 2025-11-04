{% macro exasol__get_intervals_between(start_date, end_date, datepart) -%}
    {%- if datepart == 'week' -%}
        {#-- Exasol doesn't have WEEKS_BETWEEN, so truncate to week boundaries and calculate --#}
        {#-- This counts actual week boundaries, respecting NLS_FIRST_DAY_OF_WEEK --#}
        {%- call statement('get_intervals_between', fetch_result=True) %}
            select cast(days_between(
                date_trunc('week', {{ end_date }}),
                date_trunc('week', {{ start_date }})
            ) / 7 as integer)
        {%- endcall -%}
    {%- else -%}
        {#-- Use dbt's default datediff for other dateparts --#}
        {%- call statement('get_intervals_between', fetch_result=True) %}
            select {{ dbt.datediff(start_date, end_date, datepart) }}
        {%- endcall -%}
    {%- endif -%}

    {%- set value_list = load_result('get_intervals_between') -%}

    {%- if value_list and value_list['data'] -%}
        {%- set values = value_list['data'] | map(attribute=0) | list %}
        {{ return(values[0]) }}
    {%- else -%}
        {{ return(1) }}
    {%- endif -%}

{%- endmacro %}
