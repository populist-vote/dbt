WITH local_results AS (
    SELECT * FROM p6t_state_mn.results_2023_municipal_races_and_questions
    UNION ALL
    SELECT * FROM p6t_state_mn.results_2023_school_board_races
)

SELECT DISTINCT ON (
    results.candidate_name,
    results.office_name,
    results.votes_for_candidate::int
)
    results.office_name,
    f.politician_id,
    results.candidate_name,
    results.votes_for_candidate AS votes,
    results.total_number_of_votes_for_office_in_area AS total_votes,
    results.number_of_precincts_reporting,
    results.total_number_of_precincts_voting_for_the_office,
    o.id AS office_id,
    race.id AS race_id,
    race.winner_ids,
    race.num_elect

FROM {{ ref('mn_sos_local_filings' ) }} AS f
LEFT JOIN politician AS p ON p.slug = f.slug
LEFT JOIN
    local_results AS results
    ON SLUGIFY(results.candidate_name) = f.slug
LEFT JOIN
    office AS o
    ON
        o.slug
        = SLUGIFY(
            CONCAT(
                'MN',
                ' ',
                f.office_title,
                ' ',
                f.municipality,
                ' ',
                f.district,
                ' ',
                f.school_district,
                ' ',
                f.seat
            )
        )
LEFT JOIN race ON race.office_id = o.id
WHERE
    results.number_of_precincts_reporting
    = results.total_number_of_precincts_voting_for_the_office
ORDER BY
    results.office_name ASC,
    results.votes_for_candidate::int DESC
