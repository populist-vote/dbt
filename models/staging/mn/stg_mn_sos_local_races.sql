SELECT DISTINCT ON (office_id)
    office_title AS title,
    office_id::uuid,
    race_type::race_type,
    state::state,
    is_special_election,
    num_elect::integer,
    slugify(concat(office_title, ' ', '2024')) AS slug
FROM
    {{ ref('int_mn_sos_local_filings_primaries') }}
