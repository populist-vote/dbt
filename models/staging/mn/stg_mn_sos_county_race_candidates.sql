SELECT DISTINCT ON (politician_id)
    politician_id AS candidate_id,
    race_id
FROM
    {{ ref('mn_sos_county_filings') }}
