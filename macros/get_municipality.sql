{% macro get_municipality(office_title, election_scope, district_type) %}
    CASE 
        -- WHEN ({{ election_scope }} = 'district' AND {{ district_type }} = 'city') OR {{ election_scope }} = 'city' THEN
        --     substring({{ office_title }} from '\(([^)]+)\)')
  
        -- City Offices
        WHEN
            {{ office_title }} ILIKE '%City Clerk - Treasurer%' OR
            {{ office_title }} ILIKE '%City Clerk%' OR
            {{ office_title }} ILIKE '%City Treasurer%' OR
            {{ office_title }} ILIKE '%Council Member%' OR
            {{ office_title }} ILIKE '%Mayor%' OR
            {{ office_title }} ILIKE '%Town Clerk - Treasurer%' OR
            {{ office_title }} ILIKE '%Town Clerk%' OR
            {{ office_title }} ILIKE '%Town Treasurer%' OR
            {{ office_title }} ILIKE '%Town Supervisor%' OR
            ({{ office_title }} ILIKE '%Hospital District Board%' AND ({{ office_title }} NOT ILIKE '%at Large%' OR {{ office_title }} NOT ILIKE '%(Cook County)%')) OR
            {{ office_title }} ILIKE '%Sanitary District Board%' OR
            {{ office_title }} ILIKE '%Board of Public Works%' OR
            {{ office_title }} ILIKE '%Utility Board Commissioner%' OR
            {{ office_title }} ILIKE '%Police Chief%'
        THEN
            substring({{ office_title }} from '\(([^)]+)\)')
        ELSE NULL
    END
{% endmacro %}