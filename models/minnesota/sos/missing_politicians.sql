SELECT DISTINCT ON (candidate_name)
	split_part(candidate_name,
		' ',
		1) as first_name,
	CASE WHEN split_part(candidate_name,
		' ',
		3) = '' THEN
		''
	ELSE
		split_part(candidate_name,
			' ',
			2)
	END as middle_name,
	CASE WHEN split_part(candidate_name,
		' ',
		3) = '' THEN
		split_part(candidate_name,
			' ',
			2)
	ELSE
		split_part(candidate_name,
			' ',
			3)
	END as last_name,
	CASE WHEN candidate_name LIKE '% Jr%' THEN
		'Jr.'
	WHEN candidate_name LIKE '% Sr%' THEN
		'Sr.'
	WHEN candidate_name LIKE '% III' THEN
		'III'
	ELSE NULL
	END as suffix,
	slugify(candidate_name) as slug,
		'MN' as home_state,
	campaign_phone as phone,
	campaign_email as email
	FROM {{ ref('mn_local_filings')}} WHERE politician_id IS NULL
