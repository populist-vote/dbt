SELECT DISTINCT ON(office_slug)
    --office_id AS id,
	office_slug AS ref_key,
	office_slug as slug, 
    home_state as state,
    --state_id,
	office_title AS title,
	seat,
	district,
	--school_district,
    political_scope as political_scope,
	election_scope as election_scope,
	district_type as district_type,
	'Boulder' as municipality,
	county as county
FROM
	{{ ref('co_boulder_city_filings') }}


-- INSERT INTO office (ref_key, slug, state, state_id, title, seat, district, school_district, political_scope, election_scope, district_type, municipality, county) (
-- 	SELECT
-- 		ref_key, slug, state, state_id, title, seat, district, school_district, political_scope, election_scope, district_type, municipality, county
-- 	FROM
-- 		dbt_wiley.stg_offices