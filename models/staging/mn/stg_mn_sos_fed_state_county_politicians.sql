SELECT DISTINCT ON (filing_politician_slug)
    politician_id AS id,
    filing_politician_slug AS slug,
    full_name,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    state::state AS home_state,
    party,
    residence_street_address,
    residence_city,
    residence_state,
    residence_zip,
    campaign_website,
    campaign_address,
    campaign_city,
    campaign_state,
    campaign_zip
FROM
    {{ ref ('int_mn_sos_fed_state_county_filings_primaries') }}
