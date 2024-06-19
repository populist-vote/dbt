{{ config(enabled=false) }}
SELECT
    candidate_id,
    INITCAP(SPLIT_PART(name, ',', 1)) AS last_name,
    TRIM(REGEXP_REPLACE(
        INITCAP(SPLIT_PART(name, ',', 2)),
        '(Jr\.|Sr\.|Jr|Sr|Ms|Mr|Ms\.|Mr\.)',
        ''
    )) AS first_name,
    CASE
        WHEN name ILIKE '% Jr%' THEN 'Jr.'
        WHEN name ILIKE '% Sr%' THEN 'Sr.'
        WHEN name ILIKE '%II' THEN 'II'
    END AS suffix,
    office,
    party,
    candidate_status,
    district_number AS district,
    has_raised_funds,
    incumbent_challenge,
    state,
    (
        SELECT id FROM public.party WHERE fec_code = party
    ) AS party_id
FROM {{ ref('src_fec_candidate_summary_2024') }}
ORDER BY office, state, district, last_name, first_name
