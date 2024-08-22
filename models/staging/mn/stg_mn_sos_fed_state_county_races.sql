{{ config(enabled=true) }}
SELECT DISTINCT ON (office_id)
    race_id AS id,
    office_id::uuid,
    race_slug AS slug,
    race_title AS title,
    party,
    race_type::race_type,
    state::state,
    is_special_election,
    num_elect::integer
FROM
    {{ ref('int_mn_sos_fed_state_county_filings') }}
