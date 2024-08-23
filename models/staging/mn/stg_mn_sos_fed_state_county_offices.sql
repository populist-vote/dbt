{{ config(enabled=false) }}
SELECT DISTINCT ON (office_slug)
    office_id AS id,
    office_slug AS slug,
    state::state,
    state_id,
    office_title AS title,
    office_name AS name, -- noqa: RF04
    office_subtitle,
    seat,
    district,
    political_scope::political_scope,
    election_scope::election_scope,
    district_type::district_type,
    county
FROM
    {{ ref('int_mn_sos_fed_state_county_filings') }}
WHERE office_title != 'U.S. President & Vice President'
