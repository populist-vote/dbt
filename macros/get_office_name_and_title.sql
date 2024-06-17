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
  ELSE {{ office_title }}
END
{% endmacro %}
