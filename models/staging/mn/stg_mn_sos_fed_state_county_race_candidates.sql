{{ config(enabled=false) }}
SELECT DISTINCT ON (politician_id)
    politician_id AS candidate_id,
    race_id
FROM
    {{ ref('int_mn_sos_fed_state_county_filings_primaries') }}
