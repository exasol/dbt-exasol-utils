with test_data AS (

    select * from {{ ref('data_test_equal_rowcount') }}

)

select
    "field"
from test_data