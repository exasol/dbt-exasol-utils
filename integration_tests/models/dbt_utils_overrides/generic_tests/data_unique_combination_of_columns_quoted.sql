-- data_unique_combination_of_columns is quoted (MONTH is reserved). The tests in schema.yml use quoted column names.

select * from {{ ref('data_unique_combination_of_columns') }}
