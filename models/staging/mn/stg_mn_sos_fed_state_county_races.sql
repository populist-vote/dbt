{{ config(enabled=false) }}
SELECT DISTINCT ON (office_id, party)
    race_id AS id,
    office_id::uuid,

    -- need to add municipality for local races
    race_slug AS slug,

    -- need to add municipality for local races
    race_title AS title,
    race_type::race_type,
    state::state,
    is_special_election,
    num_elect::integer,
    party
FROM
    {{ ref('int_mn_sos_fed_state_county_filings_primaries') }}
