{% macro get_election_scope(office_title, county_id) %}
CASE
  -- State Offices
  WHEN {{ office_title }} ILIKE '%U.S. Senate%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%Governor%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%Lieutenant Governor%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%Secretary of State%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%Attorney General%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%Treasurer%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%State Auditor%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%Board of Education%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%Supreme Court%' THEN 'state'
  WHEN {{ office_title }} ILIKE '%Court of Appeals%' THEN 'state'
  
  -- County Offices
  WHEN {{ office_title }} ILIKE '%County Attorney%' THEN 'county'
  WHEN {{ office_title }} ILIKE '%County Sheriff%' THEN 'county'
  WHEN {{ office_title }} ILIKE '%County Recorder%' THEN 'county'
  WHEN {{ office_title }} ILIKE '%County Surveyor%' THEN 'county'
  WHEN {{ office_title }} ILIKE '%County Treasurer%' THEN 'county'
  WHEN {{ office_title }} ILIKE '%County Coroner%' THEN 'county'
  WHEN {{ office_title }} ILIKE '%County Auditor/Treasurer%' THEN 'county'
  WHEN {{ office_title }} ILIKE '%County Auditor%' THEN 'county'
  WHEN {{ office_title }} ILIKE '%Soil & Water Supervisor%' AND {{ county_id }}::int IN (2, 10, 19, 56, 60, 62, 65, 69, 70, 82) THEN 'district'
  WHEN {{ office_title }} ILIKE '%Soil & Water Supervisor%' THEN 'county'
  
  -- District Offices (County Commissioners and County Park Commissioners are districts)
  WHEN {{ office_title }} ILIKE '%County Commissioner%' THEN 'district'
  WHEN {{ office_title }} ILIKE '%County Park Commissioner%' THEN 'district'
  
  -- City Offices
  WHEN {{ office_title }} ILIKE '%City%' AND ({{ office_title }} ILIKE '%Clerk%' OR {{ office_title }} ILIKE '%Treasurer%') THEN 'city'
  WHEN {{ office_title }} ILIKE '%City Council%' AND {{ office_title }} NOT ILIKE '%Ward%' AND {{ office_title }} NOT ILIKE '%District%' AND {{ office_title }} NOT ILIKE '%Precinct%' AND {{ office_title }} NOT ILIKE '%Section%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Mayor%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Town Clerk%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Town Treasurer%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Town Clerk - Treasurer%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Town Supervisor%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Hospital District Board%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Sanitary District Board%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Board of Public Works%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Utility Board Commissioner%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Police Chief%' THEN 'city'
  WHEN {{ office_title }} ILIKE '%Mayor Pro Tem%' THEN 'city'
  
  -- Default to 'unknown' if no match
  ELSE 'state'
END
{% endmacro %}