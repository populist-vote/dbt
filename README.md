## Populist Data Pipeline | DBT

### Setup

For local setup, you will need a `profiles.yaml` file in your `~/.dbt` directory. This file is not included in the repo for security reasons. You can find an example of here: https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles

You can use the command `dbt debug` to test your connection.

### Running

`dbt run` will run all models in the project. You can also run individual models with `dbt run --models <model_name>`

### Resources:

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

### Candidate Filing Pipeline

To create the required records from new MN candidate filing source data, we need to run the following SQL:

```sql
WITH residence_address AS (
    INSERT INTO address (line_1, city, state, postal_code, country)
    SELECT
        residence_street_address,
        residence_city,
        residence_state,
        residence_zip,
        'USA'
    FROM dbt_models.stg_mn_sos_fed_state_county_politicians
    WHERE residence_street_address IS NOT NULL
    AND residence_city IS NOT NULL
    AND residence_city IS NOT NULL
    AND residence_state IS NOT NULL
    AND residence_zip IS NOT NULL
    RETURNING id, line_1, city, state, postal_code, country
),
campaign_address AS (
    INSERT INTO address (line_1, city, state, postal_code, country)
    SELECT
        campaign_address,
        campaign_city,
        campaign_state,
        campaign_zip,
        'USA'
    FROM dbt_models.stg_mn_sos_fed_state_county_politicians
    WHERE campaign_address IS NOT NULL
    AND campaign_city IS NOT NULL
    AND campaign_state IS NOT NULL
    AND campaign_zip IS NOT NULL
    RETURNING id, line_1, city, state, postal_code, country
)
INSERT INTO politician (
    slug,
    full_name,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    home_state,
    party_id,
    campaign_website_url,
    residence_address_id,
    campaign_address_id
)
SELECT
    p.slug,
    p.full_name,
    p.first_name,
    p.middle_name,
    p.last_name,
    p.suffix,
    p.preferred_name,
    p.phone,
    p.email,
    p.home_state,
    party.id AS party_id,
    p.campaign_website,
    ra.id AS residence_address_id,
    ca.id AS campaign_address_id
FROM dbt_models.stg_mn_sos_fed_state_county_politicians p
LEFT JOIN address ra ON p.residence_street_address = ra.line_1
    AND p.residence_city = ra.city
    AND p.residence_state = ra.state
    AND p.residence_zip = ra.postal_code
LEFT JOIN address ca ON p.campaign_address = ca.line_1
    AND p.campaign_city = ca.city
    AND p.campaign_state = ca.state
    AND p.campaign_zip = ca.postal_code
LEFT JOIN party ON p.party = party.fec_code
WHERE p.id IS NULL;
```

Then `dbt run`

```sql
INSERT INTO office (
    slug,
    state,
    state_id,
    title,
    seat,
    district,
    political_scope,
    election_scope,
    district_type,
    county
)
SELECT
    slug,
    state,
    state_id,
    title,
    seat,
    district,
    political_scope,
    election_scope,
    district_type,
    county
FROM
    dbt_models.stg_mn_sos_fed_state_county_offices
WHERE id IS NULL;
```

Then `dbt run`

```sql
INSERT INTO race (title, slug, office_id, race_type, state, is_special_election, num_elect, election_id, party_id)
SELECT
	filings.title,
	filings.slug,
	filings.office_id,
	filings.race_type,
	filings.state,
	filings.is_special_election,
	filings.num_elect,
	(
		SELECT
			id
		FROM
			election
		WHERE
			slug = 'minnesota-primaries-2024'), -- Add correct slug (this is for primary races)
    (
        SELECT id FROM party WHERE fec_code = filings.party
    )
	FROM
		dbt_models.stg_mn_sos_fed_state_county_races filings;
```

Then `dbt run`

```sql
INSERT INTO race_candidates (race_id, candidate_id)
SELECT
    race_id,
    candidate_id
FROM dbt_models.stg_mn_sos_fed_state_county_race_candidates
ON CONFLICT DO NOTHING;
```
