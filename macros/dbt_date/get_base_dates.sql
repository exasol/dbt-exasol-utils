{#
Exasol implementation of get_base_dates macro.
For Exasol, we need to cast date strings to DATE first, then to TIMESTAMP.
#}

{% macro exasol__get_base_dates(start_date, end_date, n_dateparts, datepart) %}

    {%- if start_date and end_date -%}
        {#
         Decide if inputs are literal YYYY-MM-DD or SQL expressions.
         If literal, wrap with TO_DATE(...,'YYYY-MM-DD'); otherwise, cast the expression.
        #}
        {%- set sd = start_date | trim -%}
        {%- set ed = end_date   | trim -%}
        {%- set sd_lower = sd | lower -%}
        {%- set ed_lower = ed | lower -%}
        {%- set sd_is_expr = '(' in sd or ' ' in sd or sd_lower[:5] == 'date ' or 'now' in sd_lower or 'add_' in sd_lower or 'current' in sd_lower -%}
        {%- set ed_is_expr = '(' in ed or ' ' in ed or ed_lower[:5] == 'date ' or 'now' in ed_lower or 'add_' in ed_lower or 'current' in ed_lower -%}

        {%- if not sd_is_expr -%}
            {%- set start_date = (
                "cast(TO_DATE('" ~ sd ~ "','YYYY-MM-DD') as " ~ dbt.type_timestamp() ~ ")"
            ) -%}
        {%- else -%}
            {%- set start_date = (
                "cast((" ~ sd ~ ") as " ~ dbt.type_timestamp() ~ ")"
            ) -%}
        {%- endif -%}

        {%- if not ed_is_expr -%}
            {%- set end_date = (
                "cast(TO_DATE('" ~ ed ~ "','YYYY-MM-DD') as " ~ dbt.type_timestamp() ~ ")"
            ) -%}
        {%- else -%}
            {%- set end_date = (
                "cast((" ~ ed ~ ") as " ~ dbt.type_timestamp() ~ ")"
            ) -%}
        {%- endif -%}

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
