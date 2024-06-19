{{ config(enabled=false) }}

SELECT
    title,
    description,
    legiscan_bill_id,
    bill_number,
    legiscan_committee_id,
    legiscan_committee,
    legiscan_last_action_date,
    legiscan_last_action,
    full_text_url,
    political_scope,
    slug,
    status,
    session_id
FROM {{ ref('legiscan_federal_bills') }}
