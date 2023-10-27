SELECT DISTINCT ON (office_slug)
    office_id AS id,
    office_slug AS ref_key,
    office_slug AS slug,
    state::state,
    state_id,
    office_title AS title,
    seat,
    district,
    political_scope::political_scope,
    election_scope::election_scope,
    district_type::district_type,
    county
FROM
    {{ ref('mn_sos_county_filings') }}

-- INSERT INTO office (ref_key, slug, state, state_id, title, seat, district, political_scope, election_scope, district_type, county)
-- SELECT
-- 	ref_key,
-- 	slug,
-- 	state,
-- 	state_id,
-- 	title,
-- 	seat,
-- 	district,
-- 	political_scope,
-- 	election_scope,
-- 	district_type,
-- 	county
-- FROM
-- 	dbt_models.stg_mn_sos_county_offices;
