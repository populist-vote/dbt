{% macro generate_race_slug(office_name, election_scope, district_type, district, school_district, hospital_district, seat, county, municipality, is_special_election, race_type, party, year='2024') %}
    
slugify(
    concat(
        'MN',
        ' - ',
        {{ office_name }},
        ' - ',
        CASE -- test election_scope
            WHEN {{ election_scope }} = 'state' THEN
                CASE	
                    WHEN {{ office_name }} = 'U.S. Senate' OR ({{ district }} IS null AND {{ seat }} IS null) THEN 
                    -- use full state name when there is no district or seat, or if U.S. Senate
                        -- SELECT name FROM us_states WHERE code ILIKE 'MN'
                        'Minnesota'
                    WHEN {{ seat }} ILIKE '%At Large%' THEN
                        concat('MN', ' - ', {{ seat }})
                    ELSE
                        concat('MN', ' - Seat ', {{ seat }})
                END
            WHEN {{ election_scope }} = 'county' THEN
                CASE
                    WHEN {{ district }} IS null THEN
                        concat({{ county }}, ' County, ', 'MN')
                    ELSE
                        concat({{ county }}, ' County, ', 'MN', ' - District ', {{ district }})
                END
            WHEN {{ election_scope }} = 'city' THEN
                CASE -- this list of municipalities have dupes so must add the county
                    WHEN {{ municipality }} IN ('Beaver Township', 'Becker Township', 'Clover Township', 
                                                'Cornish Township', 'Fairview Township', 'Hillman Township', 
                                                'Lawrence Township', 'Long Lake Township', 'Louisville Township', 
                                                'Moose Lake Township', 'Stokes Township', 'Twin Lakes Township') THEN
                        concat(
                            {{ municipality }}, 
                            ' - ', 
                            {{ county }}, 
                            ' County, ', 
                            'MN',
                            CASE
                                WHEN {{ seat }} IS null THEN ''
                                WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
                                ELSE ' - Seat ' || {{ seat }}
                            END
                        )
                    ELSE
                        concat(
                            {{ municipality }}, 
                            ', ', 
                            'MN',
                            CASE
                                WHEN {{ seat }} IS null THEN ''
                                WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
                                ELSE ' - Seat ' || {{ seat }}
                            END
                        )
                END
            WHEN {{ election_scope }} = 'district' THEN
                CASE -- test district_types
                    WHEN {{ district_type }} = 'us_congressional' THEN concat('MN', ' - District ', {{ district }})
                    WHEN {{ district_type }} = 'state_house' THEN concat('MN', ' - House District ', {{ district }})
                    WHEN {{ district_type }} = 'state_senate' THEN concat('MN', ' - Senate District ', {{ district }})
                    WHEN {{ district_type }} = 'county' THEN concat({{ county }}, ' County, ', 'MN', ' - District ', {{ district }})
                    
                    WHEN {{ district_type }} = 'city' THEN
                        CASE -- any numbers mean add 'District' before it, otherwise add whatever is in District (no offices with seats here)
                            WHEN {{ district }} ~ '^\d+$' THEN concat({{ municipality }}, ', ', 'MN', ' - District ', {{ district }})
                            ELSE concat({{ municipality }}, ', ', 'MN', ' - ', {{ district }})
                        END

                    WHEN {{ district_type }} = 'school' THEN
                        CASE -- tests if District exists, and then tests if Seat exists for each case
                            WHEN {{ district }} IS null THEN
                            -- e.g. "MN - ISD #508 - At Large"
                                concat(
                                    'MN', 
                                    ' - ', 
                                    {{ school_district }},
                                    CASE
                                        WHEN {{ seat }} IS null THEN ''
                                        WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
                                        ELSE ' - Seat ' || {{ seat }}
                                    END
                                )
                            WHEN {{ district }} ~ '^\d+$' THEN
                            -- e.g. "MN - ISD #709 - District 3"
                                concat(
                                    'MN', 
                                    ' - ', 
                                    {{ school_district }},
                                    ' - District ', 
                                    {{ district }},
                                    CASE
                                        WHEN {{ seat }} IS null THEN ''
                                        WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
                                        ELSE ' - Seat ' || {{ seat }}
                                    END
                                )
                            ELSE
                            -- e.g. "MN - ISD #2365 - Gibbon District"
                                concat(
                                    'MN', 
                                    ' - ', 
                                    {{ school_district }},
                                    ' - ', 
                                    {{ district }},
                                    CASE
                                        WHEN {{ seat }} IS null THEN ''
                                        WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
                                        ELSE ' - Seat ' || {{ seat }}
                                    END
                                )
                        END

                    WHEN {{ district_type }} = 'judicial' THEN concat('MN', ' - Seat ', {{ seat }})

                    WHEN {{ district_type }} = 'hospital' THEN
                        CASE 
                            WHEN {{ district }} IS null THEN
                            -- e.g. "Canby Community - At Large"
                                concat(
                                    {{ hospital_district }},
                                    CASE
                                        WHEN {{ seat }} IS null THEN ''
                                        WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
                                        ELSE ' - Seat ' || {{ seat }}
                                    END
                                )
                            WHEN {{ district }} ~ '^\d+$' THEN
                            -- e.g. "Cook County - District 1"
                                concat(
                                    {{ hospital_district }},
                                    ' - District ',
                                    {{ district }},
                                    CASE
                                        WHEN {{ seat }} IS null THEN ''
                                        WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
                                        ELSE ' - Seat ' || {{ seat }}
                                    END
                                )
                        END

                    WHEN {{ district_type }} = 'soil_and_water' THEN concat({{ county }}, ' County, ', 'MN', ' - District ', {{ district }})
                            
                    ELSE
                        null
                END

            ELSE -- national
                null
        END,
        
        ' - ',

        CASE
            WHEN {{ is_special_election }} = true THEN 'Special Election - ' ELSE ''
        END,
        CASE
            WHEN {{ race_type }} = 'primary'
                THEN concat(
                    'Primary',
                    CASE
                        WHEN {{ party }} = 'N' THEN ' - Nonpartisan'
                        WHEN {{ party }} = 'REP' THEN ' - Republican'
                        WHEN {{ party }} = 'DEM' THEN ' - Democratic'
                        ELSE ''
                    END
                )
            WHEN {{ race_type }} = 'general' THEN 'General'
            ELSE ''
        END,
        ' - ',
        {{ year }}   
    )
)






{% endmacro %}
