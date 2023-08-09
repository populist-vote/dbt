SELECT DISTINCT
  full_name,
  office_title AS office_title_raw,
  p.id AS politician_id,
  p.first_name,
  p.middle_name,
  p.last_name,
  f.phone,
  f.email,
  CASE
    WHEN office_title ILIKE '%Council Member%'
      THEN
        'City Council'
    WHEN office_title ILIKE '%Mayor%'
      THEN
        'Mayor'
    WHEN office_title ILIKE '%School Board%'
      THEN
        'School Board'
    ELSE
      office_title
  END AS office_title,
  COALESCE(
    office_title ILIKE '%Special Election%',
    FALSE
  ) AS is_special_election,
  CASE WHEN office_title ILIKE '%At Large%' THEN 'At Large' END
    AS seat,
  REPLACE(
    SUBSTRING(office_title, 'Ward [0-9]{1,3} | District [0-9]{1,3}'),
    'District ',
    ''
  ) AS district,
  SUBSTRING(office_title, 'ISD #[0-9]{2,4}|SSD #[0-9]{1,4}')
    AS school_district,
  REPLACE(SUBSTRING(office_title, 'Elect [0-9]{1,3}'), 'Elect ', '')
    AS num_elect,
  CASE
    WHEN office_title ILIKE '%Council Member%' OR office_title ILIKE '%Mayor%'
      THEN 'city'
    ELSE 'district'
  END AS election_scope,
  CASE
    WHEN office_title ILIKE '%School%'
      THEN 'school'
    ELSE 'city'
  END AS district_type,
  SUBSTRING(office_title, '\(([^0-9]*)\)') AS municipality,
  REGEXP_REPLACE(p.phone, '[^0-9]+', '', 'g') AS p_phone
FROM
  p6t_state_mn.mn_candidate_filings_local_2023 AS f

-- LEFT JOIN race AS r
--   ON
--     r.office_id = o.id
--     AND r.election_id = (
--       SELECT id
--       FROM
--         election
--       WHERE
--         slug = 'mn-general-election-2023'
--       LIMIT 1
--     )
LEFT JOIN politician AS p
  ON p.slug = SLUGIFY(
    full_name
  )
  OR REGEXP_REPLACE(f.phone, '[^0-9]+', '', 'g')
  = REGEXP_REPLACE(p.phone, '[^0-9]+', '', 'g')
  AND p.home_state = 'MN'
ORDER BY politician_id
