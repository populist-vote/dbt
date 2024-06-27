{% macro select_filing_offices(source_table) %}
SELECT DISTINCT ON (office_slug)
    office_id AS id,
    office_slug AS ref_key,
    office_slug AS slug,
    state::state,
    state_id,
    office_title AS title,
    office_subtitle AS subtitle,
    office_name AS name, -- noqa: RF04
    office_subtitle,
    seat,
    district,
    school_district,
    political_scope::political_scope,
    election_scope::election_scope,
    district_type::district_type,
    municipality,
    county
FROM
    {{ ref(source_table) }}
{% endmacro %}
