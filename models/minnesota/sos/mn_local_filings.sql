SELECT DISTINCT ON (f.candidate_name)
  f.candidate_name,
  f.office_title AS office_title_raw,
  p.id AS politician_id,
  p.first_name,
  p.middle_name,
  p.last_name,
  f.campaign_phone,
  f.campaign_email,
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
  SUBSTRING(f.office_title, 'ISD #[0-9]{2,4}|SSD #[0-9]{1,4}')
    AS school_district,
  REPLACE(SUBSTRING(f.office_title, 'Elect [0-9]{1,3}'), 'Elect ', '')
    AS num_elect,
  CASE
    WHEN f.office_title ILIKE '%Council Member%' OR f.office_title ILIKE '%Mayor%'
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
LEFT JOIN politician AS p
  ON p.slug = SLUGIFY(
    f.candidate_name
  )
  OR REGEXP_REPLACE(f.campaign_phone, '[^0-9]+', '', 'g')
  = REGEXP_REPLACE(p.phone, '[^0-9]+', '', 'g')
  AND p.home_state = 'MN'
ORDER BY f.candidate_name

