SELECT DISTINCT ON (office_id, party)
    race_id AS id,
    office_id::uuid,

    -- need to add municipality for local races
    slugify(
        concat(
            state,
            ' ',
            office_name,
            ' ',
            CASE WHEN county IS NOT null THEN concat(county, ' County') END,
            ' ',
            CASE
                WHEN
                    district IS NOT null AND district_type != 'judicial'
                    THEN district
            END,
            ' ',
            seat,
            ' ',
            CASE
                WHEN is_special_election = true THEN 'special election' ELSE ''
            END,
            ' ',
            CASE
                WHEN race_type = 'primary'
                    THEN concat(
                        'primary', ' ', party
                    )
                WHEN race_type = 'general' THEN 'general'
                ELSE ''
            END,
            ' ',
            '2024'   -- TODO: Update this to be dynamic
        )
    ) AS slug,

    -- need to add municipality for local races
    concat(
        state,
        ' - ',
        office_name,
        ' - ',
        CASE WHEN county IS NOT null THEN concat(county, ' County - ') END,
        CASE
            WHEN
                district IS NOT null AND district_type != 'judicial'
                THEN concat(district, ' - ')
        END,
        CASE
            WHEN seat IS null THEN ''
            WHEN seat ILIKE 'At Large' THEN concat(seat, ' - ')
            ELSE concat(seat, ' - ')
        END,
        CASE
            WHEN is_special_election = true THEN 'Special Election - ' ELSE ''
        END,
        CASE
            WHEN race_type = 'primary'
                THEN concat(
                    'Primary - ', party
                )
            WHEN race_type = 'general' THEN 'General'
            ELSE ''
        END,
        ' - ',
        '2024'   -- TODO: Update this to be dynamic
    ) AS title,
    race_type::race_type,
    state::state,
    is_special_election,
    num_elect::integer,
    party
FROM
    {{ ref('int_mn_sos_fed_state_county_filings_primaries') }}
