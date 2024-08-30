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
            ELSE 'N'
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
        CASE
            WHEN raw.office_title ~* 'Hospital District Board Member ([0-9]{1,2})' THEN
                substring(raw.office_title from '\(([^)]+)\)')
            WHEN raw.office_title ILIKE '%Hospital District Board Member at Large Koochiching%' THEN
                'Northern Itasca - Koochiching'
            WHEN raw.office_title ILIKE '%Hospital District Board Member at Large Itasca%' THEN
                'Northern Itasca - Itasca'
            WHEN raw.office_title ILIKE '%Hospital District Board Member at Large%' THEN
                substring(raw.office_title from '\(([^)]+)\)')
        END AS hospital_district,

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
        ON REGEXP_REPLACE(raw.county_id, '^0+', '') = vd.countycode
    WHERE raw.office_title != 'U.S. President & Vice President'
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
    {{ get_unique_politician_slug('p.id', 'f.slug') }} as filing_politician_slug,
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
    f.hospital_district,
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
    {{ generate_office_subtitle('f.office_name', 'f.election_scope', 'f.district_type', 'f.district', 'f.school_district', 'f.hospital_district', 'f.seat', 'f.county', 'f.municipality') }} AS office_subtitle,
    {{ get_political_scope('f.office_name', 'f.election_scope', 'f.district_type') }} AS political_scope,
    {{ generate_race_slug('f.office_name', 'f.election_scope', 'f.district_type', 'f.district', 'f.school_district', 'f.hospital_district', 'f.seat', 'f.county', 'f.municipality', 'f.is_special_election', 'f.race_type', 'f.party', '2024') }} as race_slug,
    {{ generate_race_title('f.office_name', 'f.election_scope', 'f.district_type', 'f.district', 'f.school_district', 'f.hospital_district', 'f.seat', 'f.county', 'f.municipality', 'f.is_special_election', 'f.race_type', 'f.party', '2024') }} as race_title,
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
LEFT JOIN address ra ON f.residence_street_address = ra.line_1
    AND f.residence_city = ra.city
    AND f.residence_state = ra.state
    AND f.residence_zip = ra.postal_code
LEFT JOIN address ca ON f.campaign_address = ca.line_1
    AND f.campaign_city = ca.city
    AND f.campaign_state = ca.state
    AND f.campaign_zip = ca.postal_code
LEFT JOIN politician AS p
   -- TODO: check residential address and campaign address to help determine if the politician already exists
    ON (
        (f.email IS NOT NULL AND LOWER(f.email) = LOWER(p.email) AND similarity(f.full_name, p.full_name) > 0.6)
        OR (f.phone IS NOT NULL AND f.phone <> '000' AND f.phone = p.phone AND similarity(f.full_name, p.full_name) > 0.6)
        OR (ra.id IS NOT NULL AND ra.id = p.residence_address_id AND similarity(f.full_name, p.full_name) > 0.6)
        OR (ca.id IS NOT NULL AND ca.id = p.campaign_address_id AND similarity(f.full_name, p.full_name) > 0.6)
        OR (f.full_name IS NOT NULL AND f.full_name = p.full_name)
        OR (
            f.slug IS NOT NULL 
            AND REGEXP_REPLACE(f.slug, '-[0-9]+$', '') = REGEXP_REPLACE(p.slug, '-[0-9]+$', '') 
        )
    )
LEFT JOIN
    office AS o
    ON
        o.slug
        = {{ generate_office_slug('f.office_name', 'f.election_scope', 'f.district_type', 'f.district', 'f.school_district', 'f.hospital_district', 'f.seat', 'f.county', 'f.municipality') }}
LEFT JOIN race AS r ON o.id = r.office_id 
    AND r.election_id = (SELECT id FROM election WHERE slug = 
        {% if race_type == 'general' %}
            'general-election-2024'
        {% elif race_type == 'primary' %}
            'minnesota-primaries-2024'
        {% endif %}
    )
{% if race_type == 'primary' %}
    AND (r.party_id IS NULL OR r.party_id = (SELECT id FROM party WHERE fec_code = f.party))
{% endif %}

{% endmacro %}
