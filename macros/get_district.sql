{% macro get_district(office_title) %}
    CASE
        -- Soil & Water Supervisor Districts with subdistricts
        WHEN {{ office_title }} ILIKE '%Soil and Water Supervisor%' AND {{ office_title }} ILIKE '%(North)%' THEN 
            CONCAT(substring({{ office_title }} FROM 'District ([0-9]{1,3}[A-Z]?)'), ' (North)')
        WHEN {{ office_title }} ILIKE '%Soil and Water Supervisor%' AND {{ office_title }} ILIKE '%(South)%' THEN 
            CONCAT(substring({{ office_title }} FROM 'District ([0-9]{1,3}[A-Z]?)'), ' (South)')
        WHEN {{ office_title }} ILIKE '%Soil and Water Supervisor%' AND {{ office_title }} ILIKE '%(East)%' THEN 
            CONCAT(substring({{ office_title }} FROM 'District ([0-9]{1,3}[A-Z]?)'), ' (East)')
        WHEN {{ office_title }} ILIKE '%Soil and Water Supervisor%' AND {{ office_title }} ILIKE '%(West)%' THEN 
            CONCAT(substring({{ office_title }} FROM 'District ([0-9]{1,3}[A-Z]?)'), ' (West)')

        -- City Council districts with exceptions
        WHEN {{ office_title }} ILIKE '%Council Member Wards%' AND {{ office_title }} ILIKE '%Red Wing%' THEN 
            substring({{ office_title }} FROM '(Wards [0-9]{1,3} & [0-9]{1,3})')
        WHEN {{ office_title }} ILIKE '%Council Member Ward%' THEN 
            substring({{ office_title }} FROM '(Ward [0-9A-Z]+)')
        WHEN {{ office_title }} ILIKE '%Council Member Precinct%' AND {{ office_title }} ILIKE '%Glencoe%' THEN 
            substring({{ office_title }} FROM '(Precinct [0-9]{1,3})')
        WHEN {{ office_title }} ILIKE '%Council Member Section%' AND {{ office_title }} ILIKE '%Crystal%' THEN 
            substring({{ office_title }} FROM '(Section [I|II])')

        -- School Board districts with exceptions
        WHEN {{ office_title }} ILIKE '%School Board Member Fairfax District%' THEN 
            'Fairfax District'
        WHEN {{ office_title }} ILIKE '%School Board Member Gibbon District%' THEN 
            'Gibbon District'
        WHEN {{ office_title }} ILIKE '%School Board Member Winthrop District%' THEN 
            'Winthrop District'
        WHEN {{ office_title }} ILIKE '%School Board Member Russell District%' THEN 
            'Russell District'
        WHEN {{ office_title }} ILIKE '%School Board Member Tyler District%' THEN 
            'Tyler District'
        WHEN {{ office_title }} ILIKE '%School Board Member Ruthton District%' THEN 
            'Ruthton District'
        -- ISD #861 uses Position # as District #
        WHEN {{ office_title }} ILIKE '%School Board Member Position%' AND {{ office_title }} ILIKE '%ISD #861%' THEN 
            substring({{ office_title }} FROM 'Position ([0-9]{1,3})')

        -- Hospital Districts for subdistricts in Cook County Hospital District
        WHEN {{ office_title }} ILIKE '%Hospital District Board%' AND {{ office_title }} ILIKE '%(Cook County)%' THEN
            substring({{ office_title }} FROM 'Board Member ([0-9]{1,3})')

        -- Judicial districts
        WHEN {{ office_title }} ~* '([0-9]{1,3}(st|nd|rd|th)? District)' THEN
            substring({{ office_title }} FROM '([0-9]){1,3}(st|nd|rd|th)? District')

        -- Generic patterns
        WHEN {{ office_title }} ~* 'District ([0-9]{1,3}[A-Z]?)' THEN
            substring({{ office_title }} FROM 'District ([0-9]{1,3}[A-Z]?)')

        ELSE
            NULL
    END
{% endmacro %}
