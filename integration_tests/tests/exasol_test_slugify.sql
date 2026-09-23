-- Exasol copy of upstream dbt_utils tests/jinja_helpers/test_slugify.sql: OUTPUT is reserved.
with comparisons as (
  select '{{ dbt_utils.slugify("") }}' as actual_output, '' as expected
  union all
  select '{{ dbt_utils.slugify(None) }}' as actual_output, '' as expected
  union all
  select '{{ dbt_utils.slugify("!Hell0 world-hi") }}' as actual_output, 'hell0_world_hi' as expected
  union all
  select '{{ dbt_utils.slugify("0Hell0 world-hi") }}' as actual_output, '_0hell0_world_hi' as expected
)

select * 
from comparisons
where actual_output != expected
