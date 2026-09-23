-- data_test_at_least_one is quoted (VALUE is reserved). The tests in schema.yml use quoted column names.

select * from {{ ref('data_test_at_least_one') }}
