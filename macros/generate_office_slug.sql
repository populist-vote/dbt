{% macro generate_office_slug(state, office_name, county, district, seat) %}
slugify(
    CASE
      WHEN {{ state }} IS NOT NULL AND {{ office_name }} IS NOT NULL AND {{ county }} IS NOT NULL AND {{ district }} IS NOT NULL AND {{ seat }} IS NOT NULL THEN
        {{ state }} || '-' || {{ office_name }} || '-' || {{ county }} || '-' || {{ district }} || '-' || {{ seat }}
      WHEN {{ state }} IS NOT NULL AND {{ office_name }} IS NOT NULL AND {{ county }} IS NOT NULL AND {{ district }} IS NOT NULL THEN
        {{ state }} || '-' || {{ office_name }} || '-' || {{ county }} || '-' || {{ district }}
      WHEN {{ state }} IS NOT NULL AND {{ office_name }} IS NOT NULL AND {{ county }} IS NOT NULL THEN
        {{ state }} || '-' || {{ office_name }} || '-' || {{ county }}
      WHEN {{ state }} IS NOT NULL AND {{ office_name }} IS NOT NULL THEN
        {{ state }} || '-' || {{ office_name }}
      ELSE
        {{ state }} || '-' || {{ office_name }}
    END
  )
{% endmacro %}
