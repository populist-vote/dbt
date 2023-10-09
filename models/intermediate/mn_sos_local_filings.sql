SELECT DISTINCT ON (f.candidate_name)
  -- Split candidate name into first, middle, last, and suffix
  split_part(candidate_name,' ',1) First_Name,
  case when split_part(candidate_name,' ',3) ='' then '' else split_part(candidate_name,' ',2) end middle_name,
  case when split_part(candidate_name,' ',3) ='' then split_part(candidate_name,' ',2) else split_part(candidate_name,' ',3) end last_name,
  case when split_part(candidate_name,' ',4) ='' then '' else split_part(candidate_name,' ',4) end suffix,
  -- test for name in quotes, if matches it is preferred name
  case when candidate_name ~ '.*".*' then substring(candidate_name from '.*"(.*)".*') else '' end preferred_name,
  f.office_title AS office_title_raw,
  p.id AS politician_id,
  f.campaign_phone,
  f.campaign_email,
  o.id AS office_id,
  r.id AS race_id,
  f.office_code as state_id,
  slugify(f.office_title) AS office_ref_key,
  slugify(f.candidate_name) AS politician_ref_key,
  'MN' as office_state,
  CASE 
    WHEN f.office_title ILIKE '%Primary%'
      THEN 'primary'
    ELSE
      'general'
  END AS race_type,
  CASE
    WHEN f.office_title ILIKE '%Council Member%'
      THEN
        'City Council'
    WHEN f.office_title ILIKE '%Mayor%'
      THEN
        'Mayor'
    WHEN f.office_title ILIKE '%School Board%'
      THEN
        'School Board'
    ELSE
      f.office_title
  END AS office_title,
  COALESCE(
    f.office_title ILIKE '%Special Election%',
    FALSE
  ) AS is_special_election,
  CASE WHEN f.office_title ILIKE '%At Large%' THEN 'At Large' END
    AS seat,
  REPLACE(
    SUBSTRING(f.office_title, 'Ward [0-9]{1,3} | District [0-9]{1,3}'),
    'District ',
    ''
  ) AS district,
  school_district_number AS school_district,
  REPLACE(SUBSTRING(f.office_title, 'Elect [0-9]{1,3}'), 'Elect ', '')
    AS num_elect,
  'local' AS political_scope,
  -- Determine election scope based on office title and other metadata
  -- Need to make this more general for other data inputs
  -- TODO: Create a macro for this
  CASE WHEN f.office_title ILIKE '%Council Member%' OR f.office_title ILIKE '%Mayor%'
      THEN 'city'
    ELSE 'district'
  END AS election_scope,
  CASE
    WHEN f.office_title ILIKE '%School%'
      THEN 'school'
    ELSE 'city'
  END AS district_type,
  SUBSTRING(f.office_title, '\(([^0-9]*)\)') AS municipality,
  REGEXP_REPLACE(p.phone, '[^0-9]+', '', 'g') AS p_phone
FROM
  p6t_state_mn.mn_candidate_filings_local_2023 AS f
-- Join politicians that already exist in our database using a slugified full name and phone lookup
LEFT JOIN politician AS p
  ON p.slug = SLUGIFY(
    f.candidate_name
  )
  OR REGEXP_REPLACE(f.campaign_phone, '[^0-9]+', '', 'g')
  = REGEXP_REPLACE(p.phone, '[^0-9]+', '', 'g')
  AND p.home_state = 'MN'
-- Join populist offices using an office title and municipality/district/school district OR slug comparison
LEFT JOIN
  office AS o
  ON o.state_id = f.office_code 
LEFT JOIN 
  race AS r
  ON r.office_id = o.id
ORDER BY f.candidate_name

