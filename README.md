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
