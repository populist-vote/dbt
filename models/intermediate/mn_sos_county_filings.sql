WITH transformed_filings AS (
	SELECT
        office_title AS office_title_raw,
		office_id AS state_id,
		candidate_name,
		-- Split candidate name into first, middle, last, and suffix
		split_part(candidate_name,
			' ',
			1) First_Name,
		CASE WHEN split_part(candidate_name,
			' ',
			3) = '' THEN
			''
		ELSE
			split_part(candidate_name,
				' ',
				2)
		END middle_name,
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
		END last_name,
		CASE WHEN split_part(candidate_name,
			' ',
			4) = '' THEN
			''
		ELSE
			split_part(candidate_name,
				' ',
				4)
		END suffix,
		CASE WHEN candidate_name ~ '.*".*' THEN
			substring(candidate_name FROM '.*"(.*)".*')
		ELSE
			''
		END preferred_name,
		slugify (candidate_name) AS slug,
		CASE WHEN f.office_title ILIKE '%Choice%' THEN
			'true'
		ELSE
			FALSE
		END AS is_ranked_choice,
		CASE WHEN f.office_title ILIKE '%Primary%' THEN
			'primary'
		ELSE
			'general'
		END AS race_type,
		CASE WHEN f.office_title ILIKE '%Council Member%' THEN
			'City Council'
		WHEN f.office_title ILIKE '%Mayor%' THEN
			'Mayor'
		WHEN f.office_title ILIKE '%School Board%' THEN
			'School Board'
		WHEN f.office_title ILIKE '%Town Supervisor%' THEN
			'Town Supervisor'
        WHEN f.office_title ILIKE '%County Commissioner%' THEN
            'County Commissioner'
		ELSE
			f.office_title
		END AS office_title,
		COALESCE(f.office_title ILIKE '%Special Election%',
			FALSE) AS is_special_election,
		CASE WHEN f.office_title ILIKE '%At Large%' THEN
			'At Large'
		WHEN f.office_title ILIKE '%Seat%' THEN
			SUBSTRING(f.office_title,
				'Seat ([A-Za-z0-9]+)')
		ELSE
			NULL
		END AS seat,
		REPLACE(SUBSTRING(f.office_title,
				'Ward [0-9]{1,3} | District [0-9]{1,3}'),
			'District ',
			'') AS district,
		REPLACE(SUBSTRING(f.office_title,
				'Elect [0-9]{1,3}'),
			'Elect ',
			'') AS num_elect,
		'local' AS political_scope,
		-- Determine election scope based on office title and other metadata
		-- Need to make this more general for other data inputs
		-- TODO: Create a macro for this
		CASE WHEN f.office_title ILIKE '%Council Member%'
			OR f.office_title ILIKE '%Mayor%' THEN
			'city'
		ELSE
			'district'
		END AS election_scope,
		'county' AS district_type,
		SUBSTRING(f.office_title,
			'\(([^0-9]*)\)') AS race_description,
		campaign_phone AS phone,
		campaign_email AS email,
        county_id,
        vd.countyname AS county
		
	FROM
		p6t_state_mn.mn_candidate_filings_county_2023 AS f
    LEFT JOIN p6t_state_mn.bdry_votingdistricts AS vd ON vd.countycode = f.county_id
	GROUP BY
		f.office_title,
		f.candidate_name,
		f.office_id,
        f.county_id,
		f.campaign_phone,
		f.campaign_email,
        vd.countyname
)
SELECT
	office_title,
	office_title_raw,
	f.state_id,
	f.first_name,
	f.middle_name,
	f.last_name,
	f.suffix,
	f.preferred_name,
	f.race_type,
	p.id as politician_id,
    o.id as office_id,
	r.id as race_id,
	f.is_special_election,
	f.num_elect,
    county_id,
	is_ranked_choice,
	p.slug,
    REGEXP_REPLACE(f.phone,
			'[^0-9]+',
			'',
			'g') AS phone,
	f.email,
	'MN' AS state,
	f.seat,
	f.district,
	f.political_scope,
	f.election_scope,
	f.district_type,
    slugify(CONCAT('MN', ' ', f.office_title, ' ', f.county,  ' ', f.district , ' ', f.seat)) AS office_slug,
	slugify(candidate_name) AS politician_slug,
    f.county,
    race_description
FROM
	transformed_filings f
	LEFT JOIN politician AS p ON p.slug = f.slug
    LEFT JOIN office AS o ON o.slug = slugify(CONCAT('MN', ' ', f.office_title, ' ', f.county,  ' ', f.district , ' ', f.seat))
    LEFT JOIN race AS r ON r.office_id = o.id