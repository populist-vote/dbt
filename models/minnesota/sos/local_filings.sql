SELECT DISTINCT ON (f.candidate_name)
  f.candidate_name,
  f.office_title AS office_title_raw,
  p.id AS politician_id,
  p.first_name,
  p.middle_name,
  p.last_name,
  f.campaign_phone,
  f.campaign_email,
  o.id AS office_id,
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
  
  -- ----------------------------------
  -- OFFICE NOTES
  -- ----------------------------------

  -- title = what the person in office would be called, e.g. "Senator"
  -- name = name of the office, e.g. "U.S. Senate"
  -- political_scope = local, state, or federal
  -- election_scope = city, county, state, national, district
  -- district_type = the type of district, used to determine which field is referenced for the district
  -- district = the district name (e.g. 2, 3B, Ward 5)
  -- school_district = a field specifically for school districts (e.g. ISD #761)
  -- hospital_district = a field specifically for hospital districts
  -- soil_and_water_district = a field specifically for soil and water districts
  -- seat = sometimes offices will have multiple specific seats
  
  -- HOW TO BUILD OFFICE SUBTITLES
  --
  --  FEDERAL AND STATE OFFICES
  --
  --  if ((political_scope == federal OR political_scope == state) && election_scope == state)
  --    subtitle = state (full, e.g. "Minnesota")
  --  if (political_scope == federal && election_scope == district)
  --    subtitle = state abbv + " - District " + district (e.g. "MN - District 6")
  --  if (political_scope == state && election_scope == district && district_type == state_house)
  --    subtitle = state abbv + " - House District " + district (e.g. "MN - House District 3B")
  --  if (political_scope == state && election_scope == district && district_type == state_senate)
  --    subtitle = state abbv + " - Senate District " + district (e.g. "MN - Senate District 30")
  --
  --  MUNICIPAL OFFICES
  --
  --  if (political_scope == local && election_scope == city)
  --    subtitle = municipality + ", " + state abbv (e.g. "St. Louis, MN")
  --  if (political_scope == local && election_scope == district && district_type == city)
  --    subtitle = municipality + ", " + state abbv + " - " + district (e.g. "St. Louis, MN - Ward 3")
  --
  --  COUNTY OFFICES
  --
  --  if (political_scope == local && election_scope == county)
  --    subtitle = county + " County," + state abbv (e.g. "Pine County, MN")
  --  if (political_scope == local && election_scope == district && district_type == county)
  --    subtitle = county + " County," + state abbv + " - District " + district (e.g. "Pine County, MN - District 1")  
  --
  --  SCHOOL DISTRICTS
  --  
  --  if (political_scope == local && election_scope == district && district_type == school)
  --    subtitle = state abbv + " - " school_district (e.g. "MN - ISD #861")
  --  if (political_scope == local && election_scope == district && district_type == school && district != null)
  --    subtitle = state abbv + " - " school_district + " - District " + district (e.g. "MN - ISD #728 - District 1")
  --
  --  JUDGES
  --
  --  if (political_scope == local && election_scope == district && district_type == judicial)
  --    subtitle = state abbv + " - District " district (e.g. "MN - District 2")
  --
  --  SEATS
  --
  --  if seat != NULL
  --    add the seat to the end of the subtitle like " - Seat " + seat (e.g. "Zumbro Township, MN - Seat 2")
  --
  --  MORE TO COME

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
  -- Determine election scope based on office title and other metadata
  -- Need to make this more general for other data inputs
  -- TODO: Create a macro for this
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
  ON 
    o.title = office_title AND o.state = 'MN'
    AND (o.municipality = SUBSTRING(office_title, '\(([^0-9]*)\)')
    OR o.district
    = REPLACE(
      SUBSTRING(office_title, 'Ward [0-9]{1,3} | District [0-9]{1,3}'),
      'District ',
      ''
    )
    OR o.school_district
    = SUBSTRING(office_title, 'ISD #[0-9]{2,4}|SSD #[0-9]{1,4}'))
  OR o.slug
  = SLUGIFY(CONCAT(office_title, ' ', municipality, ' ', 'mn', ' ', district, ' ', school_district))
ORDER BY f.candidate_name

