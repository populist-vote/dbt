{% macro get_political_scope(office_name, election_scope, district_type) %}
    CASE 
        WHEN {{ election_scope }} = 'national' THEN 'federal'
        WHEN {{ election_scope }} = 'state' THEN 'state'
        WHEN {{ election_scope }} = 'district' THEN
            CASE
                WHEN {{ district_type }} = 'us_congressional' THEN
                    CASE
                        WHEN {{ office_name }} NOT LIKE 'U.S.%' THEN 'state'
                        ELSE 'federal' 
                    END -- Add this line
                WHEN {{ district_type }} = 'state_senate' THEN 'state'
                WHEN {{ district_type }} = 'state_house' THEN 'state'
                ELSE 'local'
            END
        ELSE 'local'
    END
{% endmacro %}
