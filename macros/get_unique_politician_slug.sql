{% macro get_unique_politician_slug(id, slug) %}
    CASE
        -- If the ID exists, a politician was matched based on email, phone, full_name, or slug, return the politician's slug associated with that ID
        WHEN {{ id }} IS NOT NULL THEN
            (SELECT slug FROM politician WHERE id = {{ id }})
        
        -- If the slug already exists, increment it
        WHEN EXISTS (
            SELECT 1 
            FROM politician 
            WHERE slug = {{ slug }}
        ) THEN
            {{ slug }} || '-' || COALESCE(
                (
                    SELECT MAX(SUBSTRING(slug FROM LENGTH({{ slug }}) + 2)::INT) 
                    FROM politician 
                    WHERE slug ~ ({{ slug }} || '-[0-9]+$')
                ), 0
            ) + 1
        
        -- If neither ID nor slug exists, return the slug 
        -- TODO check all the source slugs to make sure it's unique b/c we use a distinct(slug) to stage the politicians
        ELSE
            {{ slug }}
    END
{% endmacro %}
