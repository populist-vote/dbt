SELECT DISTINCT ON (office_title, district, municipality, school_district)
  f.municipality,
  f.school_district,
  f.district,
  f.district_type,
  f.num_elect,
  f.is_special_election,
  f.election_scope,
  office_title_raw,
  office_title,
  o.id
FROM {{ ref('local_filings') }} f
LEFT JOIN
  office AS o
  ON 
    o.title = office_title AND o.state = 'MN'
    AND (o.municipality = SUBSTRING(office_title, '\(([^0-9]*)\)')
    OR o.district
    = REPLACE(
      SUBSTRING(office_title, 'Ward [0-9]{1,3} | District [0-9]{1,3}'),
      'District ',
      ''
    )
    OR o.school_district
    = SUBSTRING(office_title, 'ISD #[0-9]{2,4}|SSD #[0-9]{1,4}'))
  OR o.slug
  = SLUGIFY(CONCAT(office_title, ' ', f.municipality, ' ', 'mn', ' ', f.district, ' ', f.school_district))
  
-- Add this to get only missing offices
-- WHERE o.id IS NULL

-- Use the following insert statement to create these missing offices;

-- INSERT INTO office (title, name, slug, municipality, school_district, district, district_type, election_scope, political_scope)
-- SELECT
-- 	  office_title,
-- 		office_title,
-- 		SLUGIFY(CONCAT(office_title, ' ', municipality, ' ', 'mn', ' ', district, ' ', school_district)),
-- 		municipality,
-- 		school_district,
-- 		district,
-- 		district_type::district_type,
-- 		election_scope::election_scope,
-- 		'state'::political_scope FROM dbt_wiley.missing_offices