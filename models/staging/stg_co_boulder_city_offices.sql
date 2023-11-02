SELECT DISTINCT ON (office_slug)
    office_slug AS ref_key,
    office_slug AS slug,
    home_state AS state,
    office_title AS title,
    seat,
    district,
    political_scope AS political_scope,
    election_scope AS election_scope,
    district_type AS district_type,
    'Boulder' AS municipality,
    county AS county
FROM
    {{ ref('co_boulder_city_filings') }}
