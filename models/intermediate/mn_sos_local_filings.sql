WITH transformed_filings AS (
    SELECT
        office_title AS office_title_raw,
        f.office_code AS state_id,
        f.candidate_name,
        'local' AS political_scope,
        -- Split candidate name into first, middle, last, and suffix
        f.campaign_phone AS phone,
        f.campaign_email AS email,
        f.county_id,
        vd.countyname AS county,
        REGEXP_REPLACE(
            office_title, '([^ ]+ Choice)', ''
        ) AS office_title_raw_no_choice,
        SPLIT_PART(
            f.candidate_name,
            ' ',
            1
        ) AS first_name,
        CASE
            WHEN
                SPLIT_PART(
                    f.candidate_name,
                    ' ',
                    3
                ) = ''
                THEN
                    ''
            ELSE
                SPLIT_PART(
                    f.candidate_name,
                    ' ',
                    2
                )
        END AS middle_name,
        CASE
            WHEN
                SPLIT_PART(
                    f.candidate_name,
                    ' ',
                    3
                ) = ''
                THEN
                    SPLIT_PART(
                        f.candidate_name,
                        ' ',
                        2
                    )
            ELSE
                SPLIT_PART(
                    f.candidate_name,
                    ' ',
                    3
                )
        END AS last_name,
        CASE
            WHEN
                SPLIT_PART(
                    f.candidate_name,
                    ' ',
                    4
                ) = ''
                THEN
                    ''
            ELSE
                SPLIT_PART(
                    f.candidate_name,
                    ' ',
                    4
                )
        END AS suffix,
        CASE
            WHEN f.candidate_name ~ '.*".*' THEN
                SUBSTRING(f.candidate_name FROM '.*"(.*)".*')
        END AS preferred_name,
        SLUGIFY(f.candidate_name) AS slug,
        CASE
            WHEN f.office_title ILIKE '%Choice%'
                THEN
                    'true'
            ELSE
                FALSE
        END AS is_ranked_choice,
        CASE
            WHEN f.office_title ILIKE '%Primary%'
                THEN
                    'primary'
            ELSE
                'general'
        END AS race_type,
        CASE
            WHEN f.office_title ILIKE '%Council Member%'
                THEN
                    'City Council Member'
            WHEN f.office_title ILIKE '%Mayor%'
                THEN
                    'Mayor'
            WHEN f.office_title ILIKE '%School Board%'
                THEN
                    'School Board Member'
            WHEN f.office_title ILIKE '%Town Supervisor%'
                THEN
                    'Town Supervisor'
            ELSE
                f.office_title
        END AS office_title,
        CASE
            WHEN f.office_title ILIKE '%Council Member%'
                THEN
                    'City Council'
            WHEN f.office_title ILIKE '%Mayor%'
                THEN
                    'Mayor'
            WHEN f.office_title ILIKE '%School Board%'
                THEN
                    'School Board'
            WHEN f.office_title ILIKE '%Town Supervisor%'
                THEN
                    'Town Supervisor'
            ELSE
                f.office_title
        END AS office_name,
        COALESCE(
            f.office_title ILIKE '%Special Election%',
            FALSE
        ) AS is_special_election,
        -- Determine election scope based on office title and other metadata
        -- Need to make this more general for other data inputs
        -- TODO: Create a macro for this
        CASE
            WHEN f.office_title ILIKE '%At Large%'
                THEN
                    'At Large'
            WHEN f.office_title ILIKE '%Seat%'
                THEN
                    SUBSTRING(
                        f.office_title,
                        'Seat ([A-Za-z0-9]+)'
                    )
        END AS seat,
        REPLACE(SUBSTRING(
            f.office_title,
            'Ward [0-9]{1,3} | District [0-9]{1,3}'
        ),
        'District ',
        '') AS district,
        CONCAT('ISD #', f.school_district_number) AS school_district,
        REPLACE(SUBSTRING(
            f.office_title,
            'Elect [0-9]{1,3}'
        ),
        'Elect ',
        '') AS num_elect,
        CASE
            WHEN
                f.office_title ILIKE '%Council Member%'
                OR f.office_title ILIKE '%Mayor%'
                THEN
                    'city'
            ELSE
                'district'
        END AS election_scope,
        CASE
            WHEN f.office_title ILIKE '%School%'
                THEN
                    'school'
            ELSE
                'city'
        END AS district_type,
        SUBSTRING(
            f.office_title,
            '\(([^0-9]*)\)'
        ) AS municipality
    FROM
        {{ ref("src_mn_sos_candidate_filings_local_2023") }} AS f
    LEFT JOIN
        p6t_state_mn.bdry_votingdistricts AS vd
        ON vd.countycode = f.county_id
    GROUP BY
        f.office_title,
        f.candidate_name,
        f.school_district_number,
        f.office_code,
        f.campaign_phone,
        f.campaign_email,
        f.county_id,
        vd.countyname
)

SELECT
    f.office_title,
    f.office_title_raw,
    f.office_title_raw_no_choice,
    f.state_id,
    f.first_name,
    f.middle_name,
    f.last_name,
    f.suffix,
    f.preferred_name,
    f.race_type,
    p.id AS politician_id,
    o.id AS office_id,
    r.id AS race_id,
    f.is_special_election,
    f.num_elect,
    f.county,
    f.is_ranked_choice,
    p.slug,
    f.email,
    'MN' AS state,
    f.seat,
    f.district,
    f.school_district,
    f.political_scope,
    f.election_scope,
    f.district_type,
    f.municipality,
    REGEXP_REPLACE(
        f.phone,
        '[^0-9]+',
        '',
        'g'
    ) AS phone,
    SLUGIFY(
        CONCAT(
            'MN',
            ' ',
            f.office_title,
            ' ',
            f.municipality,
            ' ',
            f.district,
            ' ',
            f.school_district,
            ' ',
            f.seat
        )
    ) AS office_slug,
    SLUGIFY(f.candidate_name) AS politician_slug
FROM
    transformed_filings AS f
LEFT JOIN politician AS p ON p.slug = f.slug
LEFT JOIN
    office AS o
    ON
        o.slug
        = SLUGIFY(
            CONCAT(
                'MN',
                ' ',
                f.office_title,
                ' ',
                f.municipality,
                ' ',
                f.district,
                ' ',
                f.school_district,
                ' ',
                f.seat
            )
        )
LEFT JOIN race AS r ON r.office_id = o.id
