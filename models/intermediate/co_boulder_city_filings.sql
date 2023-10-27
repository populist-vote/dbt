--WITH transformed_filings AS 
    SELECT
        email as email,
        first_name as first_name,
        last_name as last_name,
        official_website_url as official_website_url,
        home_state as home_state,
        office as office,
        CONCAT(first_name, '', last_name) as candidate_full_name,
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


-- SELECT 
--     *,
--     slugify (candidate_full_name) as slug
-- FROM transformed_filings






--     email,
--     office,
--     political_scope,
--     election_scope,
--     district_type,
--     first_name,
--     last_name,
--     official_website_url,
--     home_state
--     --id as uuid