{#
Exasol implementation of get_base_dates macro.
For Exasol, we need to cast date strings to DATE first, then to TIMESTAMP.
#}

{% macro exasol__get_base_dates(start_date, end_date, n_dateparts, datepart) %}

    {%- if start_date and end_date -%}
        {# Use explicit format models to avoid NLS-dependent parsing #}
        {%- set start_date = (
            "cast(TO_DATE('" ~ start_date ~ "','YYYY-MM-DD') as " ~ dbt.type_timestamp() ~ ")"
        ) -%}
        {%- set end_date = (
            "cast(TO_DATE('" ~ end_date ~ "','YYYY-MM-DD') as " ~ dbt.type_timestamp() ~ ")"
        ) -%}

    {%- elif n_dateparts and datepart -%}

        {%- set start_date = dbt.dateadd(
            datepart, -1 * n_dateparts, dbt_date.today()
        ) -%}
        {%- set end_date = dbt_date.tomorrow() -%}
    {%- endif -%}

    with
        date_spine as (

            {{
                dbt_date.date_spine(
                    datepart=datepart,
                    start_date=start_date,
                    end_date=end_date,
                )
            }}

        )
    select
        cast(d.date_{{ datepart }} as {{ dbt.type_timestamp() }}) as date_{{ datepart }}
    from date_spine d
{% endmacro %}
