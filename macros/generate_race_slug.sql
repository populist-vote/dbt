{% macro generate_race_slug(office_name, county, district, district_type, seat, is_special_election, race_type, party, year='2024') %}
    
    
    
    
    
        slugify(
        concat(
            'mn',
            ' ',
            {{ office_name }},
            ' ',
            CASE WHEN {{ county }} IS NOT null THEN concat({{ county }}, ' County') END,
            ' ',
            CASE
                WHEN
                    {{ district }} IS NOT null AND {{ district_type }} != 'judicial'
                    THEN {{ district }}
            END,
            ' ',
            {{ seat }},
            ' ',
            CASE
                WHEN {{ is_special_election }} = true THEN 'special election' ELSE ''
            END,
            ' ',
            CASE
                WHEN {{ race_type }} = 'primary'
                    THEN concat(
                        'primary', ' ', {{ party }}
                    )
                WHEN {{ race_type }} = 'general' THEN 'general'
                ELSE ''
            END,
            ' ',
            {{ year }}   -- TODO: Update this to be dynamic
        )
    )






{% endmacro %}
