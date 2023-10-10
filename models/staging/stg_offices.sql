SELECT DISTINCT ON(slugify (CONCAT(office_state, ' ', office_title, ' ', seat , ' ', district , ' ', school_district, ' ', municipality, ' ', seat)))
    office_id AS id,
	slugify (CONCAT(office_state, ' ', office_title, ' ', seat , ' ', district , ' ', school_district, ' ', municipality, ' ', seat)) AS ref_key,
	slugify (CONCAT(office_state, ' ', office_title, ' ', seat , ' ', district , ' ', school_district, ' ', municipality, ' ', seat)) as slug, 
    office_state::state AS state,
    state_id,
	office_title AS title,
	seat,
	district,
	school_district,
    political_scope::political_scope,
	election_scope::election_scope,
	district_type::district_type,
	municipality
FROM
	{{ ref('mn_sos_local_filings') }}


-- INSERT INTO office (ref_key, slug, state, state_id, title, seat, district, school_district, political_scope, election_scope, district_type, municipality) (
-- 	SELECT
-- 		*
-- 	FROM
-- 		dbt_wiley.stg_offices)