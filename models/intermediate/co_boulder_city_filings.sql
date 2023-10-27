
--     WITH transformed_filings AS (
--     SELECT
--         email as email,
--         first_name as first_name,
--         last_name as last_name,
--         official_website_url as official_website_url,
--         home_state as home_state,
--         office as office,
--         CONCAT(first_name, ' ', last_name) as candidate_full_name,
--         CASE
--             WHEN office ILIKE '%City Council%' THEN 'City Council'
--             ELSE NULL 
--         END AS political_scope,
--         CASE
--             WHEN office ILIKE '%City Council%' OR office ILIKE '%Mayor%' THEN 'city'
--             ELSE 'district'
--         END AS election_scope,
--         'city' AS district_type
--     FROM p6t_state_co.boulder_updated_filings as f
-- ),
-- transformed_filings_1 AS (
--     SELECT
--         f.email,
--         f.first_name
--         f.last_name
--         f.official_website_url
--         f.home_state
--         f.office
--         f.candidate_full_name
--         f.political_scope
--         f.district_type
--         slugify(candidate_full_name) AS politician_slug
--     FROM transformed_filings
-- ),
-- transformed_filings_2 AS (
--     SELECT
--         politician_slug as ref_key,
--         politician_slug as slug
--     FROM transformed_filings_1
-- )
-- SELECT
--     transformed_filings.*, 
--     transformed_filings_1.politician_slug,
--     transformed_filings_2.ref_key,
--     transformed_filings_2.slug,
    
-- FROM 
--     f 
--     LEFT JOIN transformed_filings_1 on email as 

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
        slugify(candidate_full_name) AS politician_slug
    FROM transformed_filings
)
SELECT
    f.*, 
    tf1.politician_slug,
    tf1.politician_slug as ref_key,
    tf1.politician_slug as slug
FROM 
    p6t_state_co.boulder_updated_filings AS f
LEFT JOIN transformed_filings AS tf ON f.email = tf.email
LEFT JOIN transformed_filings_1 AS tf1 ON tf.email = tf1.email

     




--Need to transform fields to match fields required to create pols and offices



--SET county as boulder

--office_id AS id,
--slugify(CONCAT('MN', ' ', f.office_title, ' ', f.county,  ' ', f.district , ' ', f.seat)) AS office_slug,


--Fields needed to create politicians
-- SELECT DISTINCT ON (politician_slug)
--     politician_id as id,
--     politician_slug as ref_key,
--     politician_slug as slug,
-- 	first_name,
-- 	middle_name,
-- 	last_name,
-- 	suffix,
-- 	preferred_name,
-- 	phone,
-- 	email,
--     state::state AS home_state





--Fields needed to create offices:
--  state::state,
--  state_id,
-- 	office_title AS title,
-- 	seat,
-- 	district,
--  political_scope::political_scope,
-- 	election_scope::election_scope,
-- 	district_type::district_type,
-- 	county


-- SELECT 
--     *,
--     --slugify (candidate_full_name) as slug

-- FROM transformed_filings






