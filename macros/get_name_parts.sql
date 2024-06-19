{% macro get_name_parts(full_name) %}
split_part({{ full_name }}, ' ', 1) AS first_name,
CASE
    WHEN split_part({{ full_name }}, ' ', 3) = '' THEN ''
    ELSE split_part({{ full_name }}, ' ', 2)
END AS middle_name,
CASE
    WHEN split_part({{ full_name }}, ' ', 3) = '' THEN split_part({{ full_name }}, ' ', 2)
    ELSE split_part({{ full_name }}, ' ', 3)
END AS last_name,
CASE
    WHEN split_part({{ full_name }}, ' ', 4) = '' THEN ''
    ELSE split_part({{ full_name }}, ' ', 4)
END AS suffix,
CASE
    WHEN {{ full_name }} ~ '.*".*'
        THEN substring({{ full_name }} FROM '.*"(.*)".*')
    WHEN {{ full_name }} ~ '.*\((.*)\).*' THEN
        substring({{ full_name }} FROM '.*\((.*)\).*')
END AS preferred_name
{% endmacro %}
