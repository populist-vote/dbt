{% macro get_office_title(office_title) %}
CASE
  WHEN {{ office_title }} ILIKE '%U.S. Senator%' THEN 'U.S. Senator'
  WHEN {{ office_title }} ILIKE '%U.S. Representative%' THEN 'U.S. Representative'
  WHEN {{ office_title }} ILIKE '%State Senator%' THEN 'State Senator'
  WHEN {{ office_title }} ILIKE '%State Representative%' THEN 'State Representative'
  WHEN {{ office_title }} ILIKE '%Soil and Water Supervisor%' THEN 'Soil and Water Supervisor'
  WHEN {{ office_title }} ILIKE '%County Park Commissioner%' THEN 'County Park Commissioner'
  WHEN {{ office_title }} ILIKE '%County Commissioner%' THEN 'County Commissioner'
  WHEN {{ office_title }} ILIKE '%Chief Justice - Supreme Court%' THEN 'Chief Justice'
  WHEN {{ office_title }} ILIKE '%Associate Justice - Supreme Court%' THEN 'Associate Justice'
  WHEN {{ office_title }} ILIKE '%Judge%' THEN 'Judge'

  -- Local Offices
  WHEN {{ office_title }} ILIKE '%Council Member%' THEN 'City Council Member'
  WHEN {{ office_title }} ILIKE '%City Clerk - Treasurer%' THEN 'City Clerk & Treasurer'
  WHEN {{ office_title }} ILIKE '%City Clerk%' THEN 'City Clerk'
  WHEN {{ office_title }} ILIKE '%City Treasurer%' THEN 'City Treasurer'
  WHEN {{ office_title }} ILIKE '%Mayor%' THEN 'Mayor'
  WHEN {{ office_title }} ILIKE '%Town Clerk - Treasurer%' THEN 'Town Clerk & Treasurer'
  WHEN {{ office_title }} ILIKE '%Town Clerk%' THEN 'Town Clerk'
  WHEN {{ office_title }} ILIKE '%Town Treasurer%' THEN 'Town Treasurer'
  WHEN {{ office_title }} ILIKE '%Town Supervisor%' THEN 'Town Supervisor'
  WHEN {{ office_title }} ILIKE '%School Board Member%' THEN 'School Board Member'
  WHEN {{ office_title }} ILIKE '%Hospital District Board Member%' THEN 'Hospital District Board Member'
  WHEN {{ office_title }} ILIKE '%Utility Board Commissioner%' THEN 'Utility Board Commissioner'
  WHEN {{ office_title }} ILIKE '%Board of Public Works%' THEN 'Board of Public Works Member'
  WHEN {{ office_title }} ILIKE '%Sanitary District Board Member%' THEN 'Sanitary District Board Member'
  ELSE {{ office_title }}
END
{% endmacro %}

{% macro get_office_name(office_title) %}
CASE
  WHEN {{ office_title }} ILIKE '%U.S. Senator%' THEN 'U.S. Senate'
  WHEN {{ office_title }} ILIKE '%U.S. Representative%' THEN 'U.S. House'
  WHEN {{ office_title }} ILIKE '%State Senator%' THEN 'State Senate'
  WHEN {{ office_title }} ILIKE '%State Representative%' THEN 'State House'
  WHEN {{ office_title }} ILIKE '%Soil and Water Supervisor%' THEN 'Soil and Water Supervisor'
  WHEN {{ office_title }} ILIKE '%County Park Commissioner%' THEN 'County Park Commissioner'
  WHEN {{ office_title }} ILIKE '%County Commissioner%' THEN 'County Commissioner'
  WHEN {{ office_title }} ILIKE '%Chief Justice - Supreme Court%' THEN 'Chief Justice'
  WHEN {{ office_title }} ILIKE '%Associate Justice - Supreme Court%' THEN 'Associate Justice'
  WHEN {{ office_title }} ILIKE '%Judge%' THEN 'Judge'

  -- Local Offices
  WHEN {{ office_title }} ILIKE '%Sanitary District Board Member%' THEN 'Sanitary District Board'
  WHEN {{ office_title }} ILIKE '%Council Member%' THEN 'City Council' 
  WHEN {{ office_title }} ILIKE '%City Clerk - Treasurer%' THEN 'City Clerk & Treasurer'
  WHEN {{ office_title }} ILIKE '%City Clerk%' THEN 'City Clerk'
  WHEN {{ office_title }} ILIKE '%City Treasurer%' THEN 'City Treasurer'
  WHEN {{ office_title }} ILIKE '%Mayor%' THEN 'Mayor'
  WHEN {{ office_title }} ILIKE '%Town Clerk - Treasurer%' THEN 'Town Clerk & Treasurer'
  WHEN {{ office_title }} ILIKE '%Town Clerk%' THEN 'Town Clerk'
  WHEN {{ office_title }} ILIKE '%Town Treasurer%' THEN 'Town Treasurer'
  WHEN {{ office_title }} ILIKE '%Town Supervisor%' THEN 'Town Supervisor'
  WHEN {{ office_title }} ILIKE '%School Board Member%' THEN 'School Board'
  WHEN {{ office_title }} ILIKE '%Hospital District Board Member%' THEN 'Hospital District Board'
  WHEN {{ office_title }} ILIKE '%Utility Board Commissioner%' THEN 'Utility Board Commissioner'
  WHEN {{ office_title }} ILIKE '%Board of Public Works%' THEN 'Board of Public Works'
  WHEN {{ office_title }} ILIKE '%Sanitary District Board Member%' THEN 'Sanitary District Board'
  ELSE {{ office_title }}
END
{% endmacro %}
