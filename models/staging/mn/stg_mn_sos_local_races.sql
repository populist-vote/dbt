SELECT DISTINCT ON (office_id)
    race_title AS title,
    office_id::uuid,
    party,
    race_type::race_type,
    state::state,
    is_special_election,
    num_elect::integer,
    race_slug AS slug
FROM
    {{ ref('int_mn_sos_local_filings_primaries') }}
