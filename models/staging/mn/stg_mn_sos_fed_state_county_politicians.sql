SELECT DISTINCT ON (politician_slug)
    politician_id AS id,
    surrogate_key AS ref_key,
    politician_slug AS slug,
    full_name,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    state::state AS home_state
FROM
    {{ ref ('mn_sos_fed_state_county_filings') }}


{# INSERT INTO politician (
    ref_key,
    slug,
    full_name,
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
    full_name,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    home_state
FROM dbt_wiley.stg_mn_sos_county_politicians WHERE id IS NULL; #}
