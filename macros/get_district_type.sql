{% macro get_district_type(office_title, county_id) %}
    CASE 
        WHEN {{ office_title }} ILIKE '%U.S. House%' THEN 'us_congressional'
        WHEN {{ office_title }} ILIKE '%State Senate%' THEN 'state_senate'
        WHEN {{ office_title }} ILIKE '%State House%' THEN 'state_house'
        WHEN {{ office_title }} ILIKE '%Soil and Water Supervisor%' AND {{ county_id }}::int IN (2, 10, 19, 56, 60, 62, 65, 69, 70, 82) THEN 'soil_and_water'
        WHEN {{ office_title }} ILIKE '%County Commissioner%' THEN 'county'
        WHEN {{ office_title }} ILIKE '%County Park Commissioner%' THEN 'county'
        WHEN {{ office_title }} ILIKE '%City Council%' THEN 'city'
        WHEN {{ office_title }} ILIKE '%Ward%' THEN 'city'
        WHEN {{ office_title }} ILIKE '%District%' THEN 'city'
        WHEN {{ office_title }} ILIKE '%Precinct%' THEN 'city'
        WHEN {{ office_title }} ILIKE '%Section%' THEN 'city'
        WHEN {{ office_title }} ILIKE '%School Board%' THEN 'school'
        WHEN {{ office_title }} ILIKE '%District Court%' THEN 'judicial'
        WHEN {{ office_title }} ILIKE '%Hospital District Board%' THEN 'hospital'
        ELSE NULL
    END
{% endmacro %}
