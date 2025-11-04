with test_data AS (

    select * from {{ ref('data_test_fewer_rows_than_table_1') }}

)

select
   "col_a", "field"
from test_data