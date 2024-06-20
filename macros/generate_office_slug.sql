{% macro generate_office_slug(office_name) %}
  slugify({{office_name}})
{% endmacro %}
