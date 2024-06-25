{% macro process_mn_sos_candidate_filings(source_table, race_type='general') %}

WITH transformed_filings AS (
    SELECT
        raw.office_title AS office_title_raw,
        raw.office_id AS state_id,
        raw.candidate_name,
        -- Split candidate name into first, middle, last, preferred and suffix
        CASE 
            WHEN raw.party_abbreviation = 'R' THEN 'REP'
            WHEN raw.party_abbreviation = 'DFL' THEN 'DEM'
            WHEN raw.party_abbreviation = 'NP' THEN 'N'
            ELSE raw.party_abbreviation
        END AS party,
        raw.campaign_phone AS phone,
        raw.campaign_email AS email,
        raw.campaign_website AS campaign_website,
        raw.county_id,
        vd.countyname AS county,
        raw.candidate_name AS full_name,
        {{ get_name_parts('raw.candidate_name') }},
        slugify(raw.candidate_name) AS slug,
        CASE
            WHEN raw.office_title ILIKE '%Choice%'
                THEN
                    'true'
            ELSE
                FALSE
        END AS is_ranked_choice,
        '{{ race_type }}' AS race_type, 
        {{ get_office_title('raw.office_title') }} as office_title,
        {{ get_office_name('raw.office_title') }} as office_name,
        coalesce(
            raw.office_title ILIKE '%Special Election%',
            FALSE
        ) AS is_special_election,

        -- get Seat
        CASE
            WHEN raw.office_title ILIKE 'U.S. Senator'
                THEN '1'
            WHEN raw.office_title ILIKE '%At Large%'
                THEN
                    'At Large'
            WHEN raw.office_title ILIKE '%Seat%'
                THEN
                    substring(
                        raw.office_title,
                        'Seat ([A-Za-z0-9]+)'
                    )
            WHEN raw.office_title ILIKE '%District Court%' OR raw.office_title ILIKE '%Supreme Court%'
                THEN
                    substring(
                        raw.office_title,
                        'Court ([0-9]{1,3})'
                    )
            WHEN raw.office_title ILIKE '%Court of Appeals%'
                THEN
                    substring(
                        raw.office_title,
                        'Appeals ([0-9]{1,3})'
                    )
            WHEN raw.office_title ILIKE '%School Board Member Position%' AND (raw.office_title ILIKE '%ISD #535%' OR raw.office_title ILIKE '%ISD #206%')
                THEN
                    substring(
                        raw.office_title,
                        'Position ([0-9]{1,3})'
                    )
            ELSE
                NULL
        END AS seat,
        
        -- get District
        {{ get_district('raw.office_title') }} as district,

        -- get School District
        substring(office_title, '\((SSD #[0-9]+|ISD #[0-9]+)\)') as school_district,

        -- get Hospital District

        -- get NUM_ELECT
        replace(substring(
            raw.office_title,
            'Elect [0-9]{1,3}'
        ),
        'Elect ',
        '') AS num_elect,
        
        -- get Election Scope
        {{ get_election_scope('raw.office_title', 'raw.county_id') }} as election_scope,

        -- get District Type
        {{ get_district_type('raw.office_title', 'raw.county_id') }} as district_type,

        -- get Race Description
        substring(
            raw.office_title,
            '\(([^0-9]*)\)'
        ) AS race_description,

        -- get Municipality
        {{ get_municipality('raw.office_title', 'election_scope', 'district_type') }} AS municipality,
        
        -- Candidate residence address
        CASE
            WHEN raw.residence_street_address IN ('PRIVATE', 'NOT REQUIRED')
            THEN NULL
            ELSE raw.residence_street_address
        END AS residence_street_address,
        CASE
            WHEN raw.residence_street_address IN ('PRIVATE', 'NOT REQUIRED')
            THEN NULL
            ELSE raw.residence_city
        END AS residence_city,
        CASE
            WHEN raw.residence_street_address IN ('PRIVATE', 'NOT REQUIRED')
            THEN NULL
            ELSE raw.residence_state
        END AS residence_state,
        CASE
            WHEN raw.residence_street_address IN ('PRIVATE', 'NOT REQUIRED')
            THEN NULL
            ELSE raw.residence_zip
        END AS residence_zip,

        -- Campaign address
        CASE
            WHEN raw.campaign_address IN ('PRIVATE', 'NOT REQUIRED')
            THEN NULL
            ELSE raw.campaign_address
        END AS campaign_address,
        CASE
            WHEN raw.campaign_address IN ('PRIVATE', 'NOT REQUIRED')
            THEN NULL
            ELSE raw.campaign_city
        END AS campaign_city,
        CASE
            WHEN raw.campaign_address IN ('PRIVATE', 'NOT REQUIRED')
            THEN NULL
            ELSE raw.campaign_state
        END AS campaign_state,
        CASE
            WHEN raw.campaign_address IN ('PRIVATE', 'NOT REQUIRED')
            THEN NULL
            ELSE raw.campaign_zip
        END AS campaign_zip
    FROM
        {{ source("mn_sos", source_table) }}
        AS raw
    LEFT JOIN
        p6t_state_mn.bdry_votingdistricts AS vd
        ON raw.county_id = vd.countycode
    GROUP BY
        raw.office_title,
        raw.candidate_name,
        raw.office_id,
        raw.county_id,
        raw.campaign_phone,
        raw.campaign_email,
        raw.campaign_website,
        raw.party_abbreviation,
        vd.countyname,
        raw.residence_street_address,
        raw.residence_city,
        raw.residence_state,
        raw.residence_zip,
        raw.campaign_address,
        raw.campaign_city,
        raw.campaign_state,
        raw.campaign_zip
)

SELECT
    p.id AS politician_id,
    f.slug as filing_politician_slug,
    p.slug as politician_slug,
    f.full_name,
    f.first_name,
    f.middle_name,
    f.last_name,
    f.suffix,
    f.preferred_name,
    f.party,
    f.office_title_raw,
    f.office_title,
    f.office_name,
    f.state_id,
    f.race_type,
    o.id AS office_id,
    r.id AS race_id,
    r.election_id,
    f.is_special_election,
    f.num_elect,
    f.county_id,
    f.is_ranked_choice,
    f.email,
    f.campaign_website,
    'MN' AS state,
    f.seat,
    f.district,
    f.school_district,
    f.election_scope,
    f.district_type,
    f.county,
    f.municipality,
    f.race_description,
    regexp_replace(
        f.phone,
        '[^0-9]+',
        '',
        'g'
    ) AS phone,
    {{ generate_office_slug('f.office_name', 'f.election_scope', 'f.district_type', 'f.district', 'f.school_district', 'f.hospital_district', 'f.seat', 'f.county', 'f.municipality') }} AS office_slug,
    {{ generate_office_subtitle('f.state_id', 'f.office_name', 'f.election_scope', 'f.district_type', 'f.district', 'f.school_district', 'f.hospital_district', 'f.seat', 'f.county', 'f.municipality') }} AS office_subtitle,
    {{ get_political_scope('f.office_name', 'f.election_scope', 'f.district_type') }} AS political_scope,
    residence_street_address,
    residence_city,
    residence_state,
    residence_zip,

    -- Campaign address
    campaign_address,
    campaign_city,
    campaign_state,
    campaign_zip
FROM
    transformed_filings AS f
LEFT JOIN
    politician AS p
    ON (f.full_name = p.full_name OR f.slug = p.slug)
LEFT JOIN
    office AS o
    ON
        o.slug
        = {{ generate_office_slug('f.office_name', 'f.election_scope', 'f.district_type', 'f.district', 'f.school_district', 'f.hospital_district', 'f.seat', 'f.county', 'f.municipality') }}
LEFT JOIN race AS r ON o.id = r.office_id 
    AND r.election_id = (SELECT id FROM election WHERE slug = 'minnesota-primaries-2024') 
    AND (r.party_id = NULL OR  r.party_id = (SELECT id FROM party WHERE fec_code = f.party))

{% endmacro %}
