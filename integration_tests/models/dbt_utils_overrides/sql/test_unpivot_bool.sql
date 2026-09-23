-- Hand-written Exasol copy of upstream dbt_utils test_unpivot_bool.sql.
-- Exasol stores unquoted column names in uppercase, so unpivot returns
-- uppercase property names, and booleans cast to string as TRUE/FALSE.

select
    customer_id,
    created_at,
    lower(prop) as prop,
    lower(val) as val
from (
    {{ dbt_utils.unpivot(
        relation=ref('data_unpivot_bool'),
        cast_to=type_string(),
        exclude=['customer_id', 'created_at'],
        field_name='prop',
        value_name='val'
    ) }}
) as sbq
