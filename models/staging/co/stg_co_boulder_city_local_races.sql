SELECT DISTINCT ON (office)
    'general' AS race_type,
    home_state AS state,
    FALSE AS is_special_election,
    CASE
        WHEN office ILIKE '%Mayor%' THEN 'Mayor (Boulder)'
        ELSE 'Council Member (Boulder)'
    END AS title,
    slugify(concat(county, ' ', office_title, ' ', '2023')) AS slug,
    CASE
        WHEN office ILIKE '%Mayor%' THEN NULL
        ELSE 4
    END AS num_elect
FROM
    {{ ref('co_boulder_city_filings') }}
