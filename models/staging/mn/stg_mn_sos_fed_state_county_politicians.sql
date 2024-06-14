SELECT DISTINCT ON (politician_slug)
    politician_id AS id,
    politician_slug AS slug,
    full_name,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    state::state AS home_state,
    party
FROM
    {{ ref ('mn_sos_fed_state_county_filings') }}
