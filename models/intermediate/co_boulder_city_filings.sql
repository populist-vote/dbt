WITH transformed_filings AS (
    SELECT
        email as email,
        first_name as first_name,
        last_name as last_name,
        official_website_url as official_website_url,
        home_state as home_state,
        office as office,
        CONCAT(first_name, ' ', last_name) as candidate_full_name,
        CASE
            WHEN office ILIKE '%City Council%' THEN 'City Council'
            ELSE NULL 
        END AS political_scope,
        CASE
            WHEN office ILIKE '%City Council%' OR office ILIKE '%Mayor%' THEN 'city'
            ELSE 'district'
        END AS election_scope,
        'city' AS district_type
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
        district_type,
        election_scope,
        slugify(candidate_full_name) AS politician_slug

    FROM transformed_filings
)
SELECT
    f.*, 
    tf1.politician_slug,
    tf1.politician_slug as ref_key,
    tf1.politician_slug as slug,
    tf1.election_scope, 
    tf1.district_type 
FROM 
    p6t_state_co.boulder_updated_filings AS f
LEFT JOIN transformed_filings AS tf ON f.email = tf.email
LEFT JOIN transformed_filings_1 AS tf1 ON tf.email = tf1.email

     
--Where is the id field coming from?
--politician_id as id







