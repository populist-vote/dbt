{{ config(enabled=false) }}
SELECT DISTINCT ON (politician_slug)
    politician_slug AS ref_key,
    politician_slug AS slug,
    first_name,
    last_name,
    email,
    home_state
FROM
    {{ ref ('int_co_boulder_city_filings') }}
