SELECT DISTINCT ON (office)
    CASE 
        WHEN office ILIKE '%Mayor%' THEN 'Mayor (Boulder)'
        ELSE 'Council Member (Boulder)'
    END AS title,
    slugify(CONCAT(county, ' ', office_title, ' ', '2023')) AS slug,
    'general' AS race_type,
    home_state AS state,
    FALSE as is_special_election,
    CASE 
        WHEN office ILIKE '%Mayor%' THEN NULL
        ELSE 4
    END AS num_elect
FROM
    {{ ref('co_boulder_city_filings') }}



-- INSERT INTO race (title, slug, office_id, race_type, state, is_special_election, num_elect) SELECT * FROM dbt_models.stg_races