{{ config(enabled=false) }}

SELECT DISTINCT ON (f.last_name, f.office, f.state)
    f.first_name,
    f.last_name,
    f.suffix,
    f.office,
    f.district,
    f.candidate_id,
    f.party,
    f.party_id,
    f.state,
    f.incumbent_challenge,
    p.id AS politician_id,
    o.id AS office_id,
    r.id AS race_id
FROM {{ ref('int_fec_federal_candidates_2024') }} AS f
LEFT JOIN
    politician AS p
    ON
        LOWER(f.first_name) ILIKE CONCAT('%', LOWER(p.first_name), '%')
        AND LOWER(f.last_name) = LOWER(p.last_name)
        AND f.state = p.home_state::text
LEFT JOIN
    office AS o
    ON
        o.id
        = (
            SELECT DISTINCT o.id
            FROM office
            WHERE
                o.title = 'U.S. Representative'
                AND o.state::text = f.state
                AND (
                    f.district = o.district
                    OR f.district IS NULL AND o.district = 'At Large'
                )
        )
LEFT JOIN race AS r
    ON
        o.id = r.office_id
        AND f.party_id = r.party_id
LEFT JOIN election AS e
    ON r.election_id = e.id
WHERE
    f.office = 'H'
    AND (SELECT DATE_PART('year', e.election_date::date)) = 2024
