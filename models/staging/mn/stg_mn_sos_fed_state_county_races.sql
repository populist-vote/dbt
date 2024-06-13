SELECT DISTINCT ON (office_id)
    office_id::uuid,
    slugify(
        concat(
            'mn',
            ' ',
            office_title,
            ' ',
            county,
            ' ',
            district,
            ' ',
            '2024',   -- TODO: Update this to be dynamic
            ' ',
            CASE WHEN race_type = 'primary' THEN 'primary' ELSE '' END
        )
    ) AS slug,
    office_title_raw AS title,
    race_type::race_type,
    state::state,
    is_special_election,
    num_elect::integer,
    party
FROM
    {{ ref('mn_sos_fed_state_county_filings') }}
