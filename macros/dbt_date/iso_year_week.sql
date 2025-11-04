{#
Exasol implementation of iso_year_week macro.
Uses native IYYY and IW format elements to handle ISO week-year edge cases automatically.
Format: YYYY-Www (e.g., 2024-W01)
- IYYY: ISO year (accounts for weeks spanning year boundaries)
- IW: ISO week number (01-53)
#}

{%- macro exasol__iso_year_week(date) -%}
    to_char({{ date }}, 'IYYY"-W"IW')
{%- endmacro -%}
