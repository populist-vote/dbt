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
INSERT INTO politician (
    ref_key,
    slug,
    full_name,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    home_state
)
SELECT
    ref_key,
    slug,
    full_name,
    first_name,
    middle_name,
    last_name,
    suffix,
    preferred_name,
    phone,
    email,
    home_state
FROM dbt_models.stg_mn_sos_fed_state_county_politicians WHERE id IS NULL;
```

Then `dbt run`

```sql
INSERT INTO office (
    ref_key,
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
    ref_key,
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
INSERT INTO race (
    title, slug, office_id, race_type, state, is_special_election, num_elect
)
SELECT *
FROM dbt_models.stg_mn_sos_fed_state_county_races;
```

Then `dbt run`

```sql

INSERT INTO race_candidates (race_id, candidate_id)
SELECT
    race_id,
    candidate_id
FROM dbt_models.stg_mn_sos_county_race_candidates
ON CONFLICT DO NOTHING;
```
