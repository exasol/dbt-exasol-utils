{{ config(materialized='table') }}

with base_dates as (
  {{ dbt_date.get_base_dates("2015-01-01", "2022-12-31") }}
)
select date_day from base_dates

