SELECT DISTINCT ON (politician_id)
    politician_id AS candidate_id,
    race_id
FROM
    {{ ref('co_boulder_city_filings') }}
