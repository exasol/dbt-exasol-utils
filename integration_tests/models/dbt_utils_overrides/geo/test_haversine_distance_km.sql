-- Hand-written Exasol copy of upstream dbt_utils test_haversine_distance_km.sql.
-- DATA is reserved (CTE renamed), and the seed is quoted (OUTPUT is a reserved word).
with test_data as (
    select * from {{ ref('data_haversine_km') }}
),
"final" as (
    select
        "output" as expected,
        cast(
            {{
                dbt_utils.haversine_distance(
                    lat1='"lat_1"',
                    lon1='"lon_1"',
                    lat2='"lat_2"',
                    lon2='"lon_2"',
                    unit='km'
                    )
            }} as {{ type_numeric() }}
        ) as actual
    from test_data
)
select
    expected,
    round(actual,0) as actual
from "final"
