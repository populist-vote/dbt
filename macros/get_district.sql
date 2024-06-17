{% macro get_district(office_title) %}
    CASE
        -- Match patterns like "Judge 6th District", "6th District", etc., and capture the whole phrase
        WHEN {{ office_title }} ~* '([0-9]{1,3}(st|nd|rd|th)? District)' THEN
            substring({{ office_title }} FROM '([0-9]{1,3}(st|nd|rd|th)? District)')

        -- Match patterns like "District 6", "District 6A", etc., and capture only the number part
        WHEN {{ office_title }} ~* 'District ([0-9]{1,3}[A-Z]?)' THEN
            substring({{ office_title }} FROM 'District ([0-9]{1,3}[A-Z]?)')

        ELSE
            ''
    END
{% endmacro %}
