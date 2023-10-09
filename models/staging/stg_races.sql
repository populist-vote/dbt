SELECT DISTINCT ON (office_title_raw)
	office_title_raw AS title,
	slugify (office_title_raw) AS slug,
	office_id::uuid,
	race_type::race_type,
	office_state::state AS state,
	is_special_election,
	num_elect::integer
FROM
	{{ ref('mn_sos_local_filings') }}