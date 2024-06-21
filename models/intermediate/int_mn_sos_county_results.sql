{{ config(enabled=false) }}
SELECT DISTINCT ON (
    results.candidate_name,
    results.office_name,
    results.votes_for_candidate::int
)
    results.office_name,
    p.id AS politician_id,
    results.candidate_name,
    results.votes_for_candidate AS votes,
    results.total_number_of_votes_for_office_in_area AS total_votes,
    results.number_of_precincts_reporting,
    results.total_number_of_precincts_voting_for_the_office,
    race.id AS race_id,
    race.winner_ids,
    race.num_elect

FROM {{ ref('mn_sos_fed_state_county_filings' ) }} AS f
LEFT JOIN politician AS p ON p.slug = f.politician_slug
LEFT JOIN
    p6t_state_mn.results_2023_county_races AS results
    ON SLUGIFY(results.candidate_name) = f.politician_slug
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
                f.county,
                ' ',
                f.district,
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
