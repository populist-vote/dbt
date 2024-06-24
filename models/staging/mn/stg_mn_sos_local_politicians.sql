SELECT DISTINCT ON (filing_politician_slug)
    politician_id AS id,
    filing_politician_slug AS slug,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    campaign_website,
    state::state AS home_state,
    residence_street_address,
    residence_city,
    residence_state,
    residence_zip,

    -- Campaign address
    campaign_address,
    campaign_city,
    campaign_state,
    campaign_zip
FROM
    {{ ref ('int_mn_sos_local_filings_primaries') }}


{# INSERT INTO politician (
    ref_key,
    slug,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    home_state
)
SELECT
    ref_key,
    slug,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    home_state
FROM dbt_models.stg_politicians #}
