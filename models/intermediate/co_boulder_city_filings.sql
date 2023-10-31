WITH transformed_filings AS (
    SELECT
        email as email,
        first_name as first_name,
        last_name as last_name,
        official_website_url as official_website_url,
        home_state as home_state,
        office as office,
        office as office_title,
        'city wide' as district,
        'Boulder' AS county,
        CONCAT(first_name, ' ', last_name) as candidate_full_name,
        CASE
            WHEN office ILIKE '%City Council%' THEN 'City Council'
            ELSE NULL 
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
        slugify(candidate_full_name) AS politician_slug,
        CASE
            WHEN office ILIKE '%City Council%' OR office ILIKE '%Mayor%' THEN 'city'
            ELSE 'district'
        END AS election_scope,
        CASE 
            WHEN office ILIKE '%Mayor%' then 'Mayor'
            ELSE 'At Large'
        END AS seat,
        'city' AS district_type

    FROM transformed_filings
)
SELECT
    tf.*, 
    tf1.politician_slug,
    tf1.politician_slug as slug,
    tf1.election_scope,
    tf1.district_type,
    tf1.seat,
    slugify(tf.home_state || ' ' || tf.office_title || ' ' || tf.county || ' ' || tf.district || ' ' || tf1.seat) AS office_slug
FROM 
    p6t_state_co.boulder_updated_filings AS f
LEFT JOIN transformed_filings AS tf ON f.email = tf.email
LEFT JOIN transformed_filings_1 AS tf1 ON tf.email = tf1.email


--fields for politician table
----Where is the id field coming from?
--politician_id as id






--fields needs for office table:
-- SELECT DISTINCT ON(office_slug)
-- office_id AS id,

-- office_slug AS ref_key,
-- office_slug as slug, 
    ---- create office slug
    -- slugify(CONCAT('MN', ' ', f.office_title, ' ', f.county,  ' ', f.district , ' ', f.seat)) AS office_slug,
-- state::state,
-- state_id,
-- office_title AS title,
-- seat,
-- district,
-- political_scope::political_scope,
-- election_scope::election_scope,
-- district_type::district_type,
-- county
     

-- create office slug
-- slugify(CONCAT('MN', ' ', f.office_title, ' ', f.county,  ' ', f.district , ' ', f.seat)) AS office_slug,





