SELECT DISTINCT ON (politician_slug)
    politician_id AS id,
    politician_slug AS ref_key,
    politician_slug AS slug,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    state::state AS home_state
FROM
    {{ ref ('mn_sos_local_filings') }}


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
