{{ config(enabled=false) }}
WITH transformed_bills AS (
    SELECT
        title,
        description,
        bill_id::integer AS legiscan_bill_id,
        session_id AS legiscan_session_id,
        bill_number,
        status_desc,
        status_date,
        committee_id::integer AS legiscan_committee_id,
        committee AS legiscan_committee,
        last_action_date::date AS legiscan_last_action_date,
        last_action AS legiscan_last_action,
        url AS full_text_url,
        state_link,
        'federal'::political_scope AS political_scope,
        COALESCE((
            JSON_BUILD_OBJECT(
                1, 'introduced', 2, 'in_consideration', 4, 'became_law'
            )::jsonb
        )
        ->> status, 'introduced'
        )::bill_status AS status,
        SLUGIFY(CONCAT('us', '-', bill_number, '-', '2023-2024')) AS slug,
        (
            SELECT id
            FROM session
            WHERE legiscan_session_id = session_id::integer
        ) AS session_id
    FROM {{ ref('src_legiscan_us_congress_2023_2024') }}
)

SELECT * FROM transformed_bills
