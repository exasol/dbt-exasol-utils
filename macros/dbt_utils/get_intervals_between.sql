{% macro exasol__get_intervals_between(start_date, end_date, datepart) -%}
    {%- if datepart == 'week' -%}
        {#-- dbt-exasol's datediff has no 'week'. date_spine builds one row per interval and --#}
        {#-- keeps rows before end_date, so it needs the number of 7-day steps: ceil(seconds / 604800). --#}
        {#-- Seconds, not days: days_between ignores the time of day for timestamp inputs --#}
        {%- call statement('get_intervals_between', fetch_result=True) %}
            select cast(ceil(seconds_between({{ end_date }}, {{ start_date }}) / 604800) as integer)
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
