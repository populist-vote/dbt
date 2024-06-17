{% macro mn_sos_filings_fed_state_county(source_table) %}

WITH transformed_filings AS (
    SELECT
        office_title AS office_title_raw,
        f.office_id AS state_id,
        f.candidate_name,
        -- Split candidate name into first, middle, last, preferred and suffix
        'local' AS political_scope,
        f.party_abbreviation AS party,
        {{ get_district_type('f.office_title', 'f.county_id') }} as district_type,
        f.campaign_phone AS phone,
        f.campaign_email AS email,
        f.county_id,
        vd.countyname AS county,
        f.candidate_name AS full_name,
        split_part(
            f.candidate_name,
            ' ',
            1
        ) AS first_name,
        CASE
            WHEN
                split_part(
                    f.candidate_name,
                    ' ',
                    3
                ) = ''
                THEN
                    ''
            ELSE
                split_part(
                    f.candidate_name,
                    ' ',
                    2
                )
        END AS middle_name,
        CASE
            WHEN split_part(f.candidate_name, ' ', 3) = ''
                THEN split_part(f.candidate_name, ' ', 2)
            ELSE split_part(f.candidate_name, ' ', 3)
        END AS last_name,
        CASE
            WHEN
                split_part(
                    f.candidate_name,
                    ' ',
                    4
                ) = ''
                THEN
                    ''
            ELSE
                split_part(
                    f.candidate_name,
                    ' ',
                    4
                )
        END AS suffix,
        CASE
            WHEN f.candidate_name ~ '.*".*'
                THEN
                    substring(f.candidate_name FROM '.*"(.*)".*')
            WHEN f.candidate_name ~ '.*\((.*)\).*' THEN
                substring(f.candidate_name FROM '.*\((.*)\).*')
        END AS preferred_name,
        slugify(f.candidate_name) AS slug,
        CASE
            WHEN f.office_title ILIKE '%Choice%'
                THEN
                    'true'
            ELSE
                FALSE
        END AS is_ranked_choice,
        'primary' AS race_type, -- TODO: Update this to be dynamic
        {{ get_office_title('f.office_title') }} as office_title,
        {{ get_office_name('f.office_title') }} as office_name,
        coalesce(
            f.office_title ILIKE '%Special Election%',
            FALSE
        ) AS is_special_election,
        CASE
            WHEN f.office_title ILIKE '%At Large%'
                THEN
                    'At Large'
            WHEN f.office_title ILIKE '%Seat%'
                THEN
                    substring(
                        f.office_title,
                        'Seat ([A-Za-z0-9]+)'
                    )
            WHEN f.office_title ILIKE '%Court%'
                THEN
                    substring(
                        f.office_title,
                        'Court ([A-Za-z0-9]+)'
                    )
            ELSE
                ''
        END AS seat,
        {{ get_district('f.office_title') }} as district,
        replace(substring(
            f.office_title,
            'Elect [0-9]{1,3}'
        ),
        'Elect ',
        '') AS num_elect,
        {{ get_election_scope('f.office_title', 'f.county_id') }} as election_scope,
        substring(
            f.office_title,
            '\(([^0-9]*)\)'
        ) AS race_description
    FROM
        {{ source("mn_sos", source_table) }}
        AS f
    LEFT JOIN
        p6t_state_mn.bdry_votingdistricts AS vd
        ON f.county_id = vd.countycode
    GROUP BY
        f.office_title,
        f.candidate_name,
        f.office_id,
        f.county_id,
        f.campaign_phone,
        f.campaign_email,
        f.party_abbreviation,
        vd.countyname
)

SELECT
    f.office_title,
    f.office_name,
    f.office_title_raw,
    f.state_id,
    f.full_name,
    f.first_name,
    f.middle_name,
    f.last_name,
    f.suffix,
    f.preferred_name,
    f.party,
    f.race_type,
    p.id AS politician_id,
    o.id AS office_id,
    r.id AS race_id,
    f.is_special_election,
    f.num_elect,
    f.county_id,
    f.is_ranked_choice,
    p.slug,
    f.email,
    'MN' AS state,
    f.seat,
    f.district,
    f.political_scope,
    f.election_scope,
    f.district_type,
    f.county,
    f.race_description,
    regexp_replace(
        f.phone,
        '[^0-9]+',
        '',
        'g'
    ) AS phone,
    slugify(
        concat(
            'mn',
            ' ',
            f.office_title,
            ' ',
            f.county,
            ' ',
            f.district,
            ' ',
            f.seat
        )
    ) AS office_slug,
    slugify(f.candidate_name) AS politician_slug
FROM
    transformed_filings AS f
LEFT JOIN
    politician AS p
    ON
        f.email = p.email
        OR f.phone = p.phone
        OR f.full_name = p.full_name
        OR f.slug = p.slug
LEFT JOIN
    office AS o
    ON
        o.slug
        = slugify(
            concat(
                'MN',
                ' ',
                f.office_title,
                ' ',
                f.county,
                ' ',
                f.district,
                ' ',
                f.seat
            )
        )
LEFT JOIN race AS r ON o.id = r.office_id

{% endmacro %}
