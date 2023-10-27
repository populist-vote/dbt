WITH transformed_filings AS (
    SELECT
        email AS email,
        first_name AS first_name,
        last_name AS last_name,
        official_website_url AS official_website_url,
        home_state AS home_state,
        office AS office,
        office AS office_title,
        'city wide' AS district,
        'Boulder' AS county,
        CONCAT(first_name, ' ', last_name) AS candidate_full_name,
        CASE
            WHEN office ILIKE '%City Council%' THEN 'City Council'
        END AS political_scope

    FROM p6t_state_co.boulder_updated_filings
),

transformed_filings_1 AS (
    SELECT
        email,
        first_name,
        last_name,
        official_website_url,
        home_state,
        office,
        candidate_full_name,
        political_scope,
        'city' AS district_type,
        SLUGIFY(candidate_full_name) AS politician_slug,
        CASE
            WHEN
                office ILIKE '%City Council%' OR office ILIKE '%Mayor%'
                THEN 'city'
            ELSE 'district'
        END AS election_scope,
        CASE
            WHEN office ILIKE '%Mayor%' THEN 'Mayor'
            ELSE 'At Large'
        END AS seat

    FROM transformed_filings
)

SELECT
    tf.*,
    tf1.politician_slug,
    tf1.politician_slug AS slug,
    tf1.election_scope,
    tf1.district_type,
    tf1.seat,
    SLUGIFY(
        tf.home_state
        || ' '
        || tf.office_title
        || ' '
        || tf.county
        || ' '
        || tf.district
        || ' '
        || tf1.seat
    ) AS office_slug
FROM
    p6t_state_co.boulder_updated_filings AS f
LEFT JOIN transformed_filings AS tf ON f.email = tf.email
LEFT JOIN transformed_filings_1 AS tf1 ON tf.email = tf1.email
