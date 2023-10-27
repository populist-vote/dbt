SELECT DISTINCT ON (office_id)
    office_title_raw AS title,
    office_id::uuid,
    race_type::race_type,
    state::state,
    is_special_election,
    num_elect::integer,
    slugify(
        concat(
            'mn',
            ' ',
            office_title,
            ' ',
            county,
            ' ',
            district,
            ' ',
            '2023',
            ' ',
            CASE WHEN race_type = 'primary' THEN 'primary' ELSE '' END
        )
    ) AS slug
FROM
    {{ ref('mn_sos_county_filings') }}


-- INSERT INTO politician (ref_key, slug, first_name, middle_name, last_name, suffix, preferred_name, phone, email, home_state) 
-- 	SELECT
-- 		ref_key, slug, first_name, middle_name, last_name, suffix, preferred_name, phone, email, home_state	
-- 	FROM dbt_models.stg_mn_sos_county_politicians WHERE id IS null;


-- INSERT INTO office (ref_key, slug, state, state_id, title, seat, district, political_scope, election_scope, district_type, county) 
-- 	SELECT
-- 		ref_key, slug, state, state_id, title, seat, district, political_scope, election_scope, district_type, county
-- 	FROM
-- 		dbt_models.stg_mn_sos_county_offices WHERE id IS null;

-- INSERT INTO race (title, slug, office_id, race_type, state, is_special_election, num_elect) SELECT * FROM dbt_models.stg_mn_sos_county_races;

-- INSERT INTO race_candidates (race_id, candidate_id) SELECT race_id, candidate_id FROM dbt_models.stg_mn_sos_county_race_candidates;
