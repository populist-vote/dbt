{{ config(enabled=false) }}

SELECT {{ dbt_utils.generate_surrogate_key(['email', 'first_name', 'last_name', 'office']) }} as _surrogate_key, * FROM p6t_state_co.boulder_updated_filings --noqa