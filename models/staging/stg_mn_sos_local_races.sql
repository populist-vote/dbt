SELECT DISTINCT ON (office_id)
    office_title_raw_no_choice AS title,
    office_id::uuid,
    race_type::race_type,
    state::state,
    is_special_election,
    num_elect::integer,
    slugify(concat(office_title_raw_no_choice, ' ', '2023')) AS slug
FROM
    {{ ref('mn_sos_local_filings') }}


-- INSERT INTO race (title, slug, office_id, race_type, state, is_special_election, num_elect) SELECT * FROM dbt_models.stg_races
