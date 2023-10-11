SELECT DISTINCT ON (office_id)
	office_title_raw AS title,
	slugify (CONCAT(office_title_raw, ' ', '2023')) AS slug,
	office_id::uuid,
	race_type::race_type,
	state::state,
	is_special_election,
	num_elect::integer
FROM
	{{ ref('mn_sos_local_filings') }}


-- INSERT INTO race (title, slug, office_id, race_type, state, is_special_election, num_elect) SELECT * FROM dbt_models.stg_races