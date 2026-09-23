-- Hand-written Exasol copy of upstream dbt_utils test_unpivot.sql.
-- Exasol stores unquoted column names in uppercase, so unpivot returns
-- uppercase property names. Upstream does not lowercase them for Exasol.

select
    customer_id,
    created_at,
    lower(prop) as prop,
    val
from (
    {{ dbt_utils.unpivot(
        relation=ref('data_unpivot'),
        cast_to=type_string(),
        exclude=['customer_id', 'created_at'],
        remove=['name'],
        field_name='prop',
        value_name='val'
    ) }}
) as sbq
