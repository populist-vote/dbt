{% macro generate_race_title(office_name, county, district, district_type, seat, is_special_election, race_type, party, year) %}
    
    
    
    
    
        concat(
        'mn',
        ' - ',
        {{ office_name }},
        ' - ',
        CASE WHEN {{ county }} IS NOT null THEN concat({{ county }}, ' County - ') END,
        CASE
            WHEN
                {{ district }} IS NOT null AND {{ district_type }} != 'judicial'
                THEN concat({{ district }}, ' - ')
        END,
        CASE
            WHEN {{ seat }} IS null THEN ''
            WHEN {{ seat }} ILIKE 'At Large' THEN concat({{ seat }}, ' - ')
            ELSE concat({{ seat }}, ' - ')
        END,
        CASE
            WHEN {{ is_special_election }} = true THEN 'Special Election - ' ELSE ''
        END,
        CASE
            WHEN {{ race_type }} = 'primary'
                THEN concat(
                    'Primary - ', {{ party }}
                )
            WHEN {{ race_type }} = 'general' THEN 'General'
            ELSE ''
        END,
        ' - ',
        {{ year }}   
    )




{% endmacro %}
