SELECT DISTINCT ON (full_name)
	split_part(full_name,
		' ',
		1) as first_name,
	CASE WHEN split_part(full_name,
		' ',
		3) = '' THEN
		''
	ELSE
		split_part(full_name,
			' ',
			2)
	END as middle_name,
	CASE WHEN split_part(full_name,
		' ',
		3) = '' THEN
		split_part(full_name,
			' ',
			2)
	ELSE
		split_part(full_name,
			' ',
			3)
	END as last_name,
	CASE WHEN full_name LIKE '% Jr%' THEN
		'Jr.'
	WHEN full_name LIKE '% Sr%' THEN
		'Sr.'
	WHEN full_name LIKE '% III' THEN
		'III'
	ELSE NULL
	END as suffix,
	slugify(full_name) as slug,
		'MN' as home_state,
	phone,
	email
	FROM {{ ref('mn_local_filings')}} WHERE politician_id IS NULL
