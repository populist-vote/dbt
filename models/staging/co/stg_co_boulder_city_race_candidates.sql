{{ config(enabled=false) }}
SELECT DISTINCT ON (politician_id)
    politician_id AS candidate_id,
    race_id
FROM
    {{ ref('int_co_boulder_city_filings') }}
