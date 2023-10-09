SELECT
    politician_id as id,
    politician_ref_key as ref_key,
    politician_ref_key as slug,
	first_name,
	middle_name,
	last_name,
	suffix,
	preferred_name,
	campaign_phone AS phone,
	campaign_email AS email,
    office_state::state AS home_state
FROM
	{{ ref ('mn_sos_local_filings') }}